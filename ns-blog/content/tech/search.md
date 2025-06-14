+++
title = "building semantic and keyword search on cockroachDB"
date = "2025-06-02T11:25:06-06:00"

tags = ["blog","cockroach","cockroachlabs","database","postgres","rds","software","swe","tech","search", "elasticsearch", "vector","vectorsearch", "semantic", "semanticsearch", "pgvector", "embedding", "semantic-search"]
+++
## why is search interesting?
`search` as a concept has dominated software since even before `Google`'s success in monetizing it from graph searching algorithms to networking to vector databases. personally, I find the implementation details quite interesting because there are a myriad of optimizations, algorithms, and implementations to help store *relevant* information about a piece of data, such that you can identify when it is the correct time to fetch that data. 


it's not the most commonly worked on topic either. the majority of software engineers can build a simple CRUD application with sign-in, but they often use third-party libraries or services for search implementations. and we aren't talking about pure frontend search over arrays of objects. I'm referring to specialized indexes and databases of search *documents*.

I was also partially inspired by `cockroach labs` [post](https://www.cockroachlabs.com/blog/vector-search-pgvector-cockroachdb/) on building vector search in the first place.
## why not elasticsearch
for the simple reason of not wanting to pay for a managed search service or use valuable memory and storage on a dedicated search container and index on my deploy. plus, the added benefit of showing that you don't need the fanciest tools to get a basic search implementation.

## what is "semantic" search
the last thing to talk about before getting into the technicals is `semantic search`. there are simple implementations of text search that essentially just do "keyword searching" and `elasticsearch` includes features like indexing on attributes of data, but both of these solutions usually fail to parse the *meaning* of a piece of text before indexing it. *meaning* can be subjective but typically it's helpful to think about the context of a word in a sentence or paragraph. it's sometimes helpful to know that a phrase is "positive" or perhaps more relevant to specific locations and people rather than if someone searches for an exact keyword that is in the search entry.

## implementation overview
the basic implementation plan is to create a table of search `documents` that includes a raw text column, a column for keyword search values, and a column for semantic search values. the keyword search values will be computed using a stored/computed db column with `to_tsvector`, a `postgres` built-in function to convert text to a form optimized for text search. the semantic search values are computed using optimized text embedding models like `nomic-embed-text` and google's `models/text-embedding-004`. lastly, I'll add an index for each column: an inverted index for keyword search and a vector index for semantic search.

I'll also need to create an association table to map the models I want to search over to their relevant search documents. for now it will be fine to assume that each model will only correspond to one document.

### `cockroachdb` custom set-up
referring to `cockroach labs` vector search [post](https://www.cockroachlabs.com/docs/stable/full-text-search) and their full-text search [docs](https://www.cockroachlabs.com/docs/stable/full-text-search), I knew that `pgvector` was supported, vector indexing was coming in `v25.2.0`, and `tsvector` was already supported.

I did have to pull the unstable `v25.2.0` image (`cockroachdb/cockroach-unstable:v25.2.0-rc.1`) for local development and enable vector indexing with

```sql
SET CLUSTER SETTING feature.vector_index.enabled = true;
```



### document model
here's a brief mermaid diagram outlining our models and relationships, I'll break this down incrementally.
```mermaid
erDiagram
    HybridSearchDocument ||--o{ HybridSearchDocumentAssociation : has
    HybridSearchDocument {
        int id
        string raw_text
        tsvector text_tsv
        vector[768] text_embedding_768
    }

    HybridSearchDocumentAssociation {
        int id
        int hybrid_search_document_id FK
        string model_api_identifier
        string model_type
    }

    HybridSearchDocumentAssociation }o--|| User : references
    HybridSearchDocumentAssociation }o--|| Group : references
    HybridSearchDocumentAssociation }o--|| Letter : references
    HybridSearchDocumentAssociation }o--|| Question : references
    HybridSearchDocumentAssociation }o--|| Response : references

    User {
        string api_identifier PK
    }

    Group {
        string api_identifier PK
    }

    Letter {
        string api_identifier PK
    }

    Question {
        string api_identifier PK
    }

    Response {
        string api_identifier PK
    }

```

first, take a look at the document model

```python
from pgvector import Vector

class HybridSearchDocument:
	...
    raw_text: Mapped[str] = mapped_column(nullable=False)

    text_tsv_expr_literal = literal_column("text_tsv", type_=TSVECTOR)

    text_embedding_768: Mapped[Vector] = mapped_column(
        Vector(dim=768), nullable=False
    )
```

there are only 3 interesting columns:
- `raw_text`: the raw text that users may be searching for. This will be compiled at document creation time and filled with relevant content for the corresponding model, like `name`, `description`, `creator`, etc.
- `text_tsv_expr_literal`: this is a `literal` column, meaning not managed by `sqlalchemy` directly since `sqlalchemy` seemed to have issues with computed columns. the column is instantiated through a database migration and is a "STORED" column that will directly compute the `ts_vector` value of the `raw_text` column:
```sql
ALTER TABLE hybrid_search_document ADD COLUMN IF NOT EXISTS text_tsv TSVECTOR AS (to_tsvector('english', raw_text)) STORED;
```
- `text_embedding_768`: the vector generated by an embedding model based off the `raw_text`. This will be computed at document creation time. I use `768` as the dimension size since that is the most common dimension size computed by embedding models.

### indexes
to more efficiently execute an actual search query, I need some important indexes:

an inverted index on the computed `tsvector` column
```sql
CREATE INVERTED INDEX IF NOT EXISTS content_search_inverted_idx ON hybrid_search_document (text_tsv);
```
inverted indexes are probably the most common kind of index for search data since I am pretty much always searching for the actual contents of a `document` and never for a specific `document` itself. Basically I am never going from `document` -> `search values`.

and a `Vector` index on the embedded `Vector` column
```sql
CREATE VECTOR INDEX IF NOT EXISTS embedding_768_vector_idx ON hybrid_search_document (text_embedding_768);
```

unfortunately, neither of these indexes could be managed by `sqlalchemy` either and had to be manually added to the tables via migration as well.

so the search document table is actually fully set-up now and I can add documents and construct search queries. But how will I know what model/data the document actually represents? simplest solution is an association table
### association table
the association table will actually be fairly abstract in this scenario since I don't want to add `ForeignKeys` every time a new searchable model is added. so I use weak references to a model's unique identifier and hydrate the model references after each search query. this can be optimized with batching queries per model table as well.
```python
class HybridSearchDocumentAssociation:
    hybrid_search_document_id: Mapped[int] = mapped_column(
        ForeignKey(
            "hybrid_search_document.id",
            name="association_hybrid_search_document_id_fkey",
            ondelete="CASCADE",
        ),
        nullable=False,
    )
    model_api_identifier: Mapped[str] = mapped_column(nullable=False)
    model_type: Mapped[str] = mapped_column(nullable=False)

    document: Mapped["HybridSearchDocument"] = relationship(
        back_populates="associations",
    )

class HybridSearchDocument:
	...
	associations: Mapped[list[HybridSearchDocumentAssociation]] = relationship(
	"HybridSearchDocumentAssociation", back_populates="document"
    )
```

the 3 interesting columns this time are:
- `hybrid_search_document_id`: a foreign key column that links an association to a document. the delete behavior is set to remove associations if a document is removed
- `model_api_identifier`: a weak reference to the unique identifier for the model that is related to the search query. for now, each model will be one-to-one with a search document.
- `model_type`: just a quick categorization column to help batch hydration queries

I also added `sqlalchemy` relationships on both the document class and the association class so that I can reference the associations from its document after a search query.

### search queries
I ended up writing 3 query functions: one for semantic search, one for keyword search, and one for a union of the two.

```python
def semantic_search_hybrid_search_document(
    db: Session, query: str, limit: int = 10
) -> list[HybridSearchDocument]:
    text_embedding = _generate_text_embedding(query)
    return (
        db.query(HybridSearchDocument)
        .filter(
            HybridSearchDocument.text_embedding_768.l2_distance(text_embedding)
            < 0.5
        )
        .order_by(
            HybridSearchDocument.text_embedding_768.l2_distance(text_embedding)
        )
        .limit(limit)
        .all()
    )
```

for semantic search, it's necessary to first generate a text embedding from the search query and use that to find search results. `Vector` columns from `pgvector` have an `l2_distance` comparator which compares the euclidian distance from an input embedding. and I arbitrarily chose `0.5` as my distance limit.
```python
def keyword_search_hybrid_search_document(
    db: Session, query: str, limit: int = 10
) -> list[HybridSearchDocument]:
    tsquery = func.plainto_tsquery("english", query)
    return (
        db.query(HybridSearchDocument)
        .filter(HybridSearchDocument.text_tsv_expr_literal.op("@@")(tsquery))
        .order_by(
            func.ts_rank(
                HybridSearchDocument.text_tsv_expr_literal, tsquery
            ).desc()
        )
        .limit(limit)
        .all()
    )
```
for keyword search, I used a specific query function which will tokenize the search query. and then the actual comparator operator is `@@` which is the `postgres` text search match operator.
```python
def dual_search_hybrid_search_document(
    db: Session, query: str, limit: int = 10
) -> list[HybridSearchDocument]:
    text_embedding = _generate_text_embedding(query)
    tsquery = func.plainto_tsquery("english", query)
    return (
        db.query(HybridSearchDocument)
        .filter(
            or_(
                HybridSearchDocument.text_embedding_768.l2_distance(
                    text_embedding
                )
                < 0.5,
                HybridSearchDocument.text_tsv_expr_literal.op("@@")(tsquery),
            )
        )
        .order_by(
            HybridSearchDocument.text_embedding_768.l2_distance(
                text_embedding
            ),
            func.ts_rank(
                HybridSearchDocument.text_tsv_expr_literal, tsquery
            ).desc(),
        )
        .limit(limit)
        .all()
    )
```
lastly for dual search, I just `or` the two filters together.
### result hydration
the search queries just return search documents, so next I have to "hydrate" my search results with the models they are associated with.

I already have model getters based on their reference ids and the tables have the necessary index to make it fast
```python
def get_models(
    db: Session, model_cls: type[API_CLS], api_ids: list[str]
) -> Sequence[API_CLS]:
	return db.query(model_cls)
		.filter(model_cls.api_identifier.in_(api_ids))
		.all()
```

the more interesting part was linking each model to it's search association rows by `HybridSearchDocumentAssociation.model_type`. I use a `registry pattern` to register searchable sqlalchemy models with their search `model_type`:
```python
SEARCH_MODEL_REGISTRY: RegistrationDict[str, type[APIIdentified]] = (
    RegistrationDict("SEARCH_MODEL_REGISTRY")
)

def register_searchable_model(model_type: str):
    def decorator(cls: type[APIIdentified]) -> type[APIIdentified]:
        @wraps(cls)
        def wrapper(*args, **kwargs):
            return cls(*args, **kwargs)

        SEARCH_MODEL_REGISTRY[model_type] = cls
        return cls

    return decorator
```

the actual usage becomes very simple:
```python
@register_searchable_model("letter")
class Letter:
	...
```

> [!NOTE] caveat about registration pattern
> this relies on all models being imported when my app starts up to ensure that the `SEARCH_MODEL_REGISTRY` is fully populated. I achieve this by ensuring that I run a function `import_all_sqla_models` which imports all `sqla` models at startup


## what's left?
### document creation and backfills
#### creation
I have 5 different models that will be searchable in the initial release:
two party-type models
- `User`
- `Group`
content-type models that have large text strings
- `Letter`
- `Question`
- `Response`

I need to add logic for creating a search document when each individual model is created, something like
```python
def create_user(...):
	user = User.create(...)
	# TODO: define the raw text for a user
	raw_text = f"name:{user.name};email:{user.email}"
	user_document = create_hybrid_search_document(raw_text, user.api_identifier, "user")
```

defining the text shape for each model will be the bulk of the work here but there is lots of room to iterate and test things out.\
#### backfills
I'll need to create scripts to backfill documents for all existing models in production. these scripts will be idempotent so they can be re-run to regenerate search documents in case the logic for converting models to representative text changes.

### search filtering
it would be useful to filter to just types of models that a user wanted in particular or even filter on the attributes of a model. for example, searching for only `users` or searching for `users` that are in a particular `group`

### model relationships
if you think about all the models as a connected, bi-directional, cyclic graph, keeping track of the edges could be useful from a search perspective. for example, if I search for a user's email, maybe it would be good to also see all the groups they are in.

the overhead of maintaining this may be tough though, especially because we are not dealing with a `dag` or a `polytree`.

## future use-cases for embedded text vectors
- RAG-implementations can use semantic search to find related content to improve the context for an LLM
- data-science use-cases like clustering and anomaly detection
- recommendations by finding content that similar to a user's content