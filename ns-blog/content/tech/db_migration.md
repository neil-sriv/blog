+++
title = "migrating my aws database to cockroach labs in 12 hours"
date = "2025-04-09T01:01:56-04:00"

tags = ["blog","hugo","software","swe","tech","database", "migration", "postgres", "aws", "rds", "cockroach", "cockroachlabs"]
+++
if you don't know, I run a side project called Ring, a small newsletter platform where groups of friends answer monthly questions that are collected and sent in an email. the entire project is hosted for free on AWS on a single EC2 machine with 1GB of memory and a postgres rds instance. unfortunately, these free tier benefits only last 1 year...

so at the beginning of march, I finally get the dreaded email that my aws free tier benefits were ending on the 31st. I, of course, immediately forget about this and procrastinate doing anything about it. to be fair, I was moving into a new apartment and was very distracted. regardless, I found myself on March 31st with about 12 hours before I was about to get hit by an estimated $60 monthly bill for running everything.

the bill breakdown was about:
- $45 for 750 hours (24/7 up-time) 10 GB postgres rds database
- $10 for 750 hours (24/7 up-time) 1 GB EC2 machine
- <$5 for miscellaneous aws services (S3, VPC, CDN, etc.)

so with a limited timeline, I decided to just focus on the high database cost problem for now.

TL;DR: I migrated my 2GB Postgres database from AWS RDS to CockroachDB in a day to avoid a $60/month bill. here’s how I pulled it off (and how TLS almost broke me).
## so what do I actually need?
- a managed RDS database
- free if possible
- current DB size is about 2GB so probably at least 5 GB would be good
- 750 hours of uptime
- compatibility with postgres, sqlalchemy, and alembic all preferred

## are there really no free databases these days??
unfortunately not really! it's been long since the days where you could spin up heroku compute instances, mongodb nosql databases, or most personal usage of common software infrastructure for free. *well at least the limits are way lower now and the timelines are shortish.* I began searching around for options of free managed database hosting services; chatgpt is great for enumerating options and giving pros/cons but make sure you double check what's provided. I was misled a couple times and thought certain options were possible but they had sunset their free options or the limits were too strict.
> specifically planetscale has no more free tier and supabase limits are too low

## bugs to the rescue
my savior ended up being [**cockroach labs**](https://www.cockroachlabs.com/pricing/) with 10GB of free storage (amazing) and 50 million read units (no idea what that means). I'd never heard of cockroach before but it's a distributed database service, meaning it was built with replication and sharding across multiple database nodes as the primary focus. I don't really need all that but it does implement the postgres wire protocol, so the majority of all postgres features should work out of the box. there is additionally a sqlalchemy extension that enabled working with cockroach and alembic should work automatically.

## how do you actually migrate a database
well the correct way is through something called logical replication and dual writing data to two databases concurrently. but I have a 2 GB database with about 19 tables, so I can get away with just pg_dumping the database to a file and then executing the sql in it directly.

## downtime
downtime considerations are incredibly critical when migrating a database. if you have an "always available" service, downtime is likely not an actual option for you. in that case, you must use dual-writing and a cut-over to actually migrate onto another database. however, my newsletter service gets spiky traffic and has no real concerns with downtime as long as there are no newsletters scheduled soon. so I pushed a frontend image that was a simple downtime page informing users that the web-app would be up and running in a few days.
## let's get started
time to get my hands dirty and jump in.

I have a local database used for development and testing. it runs in a docker container with a persisted volume. can I do the same thing with cockroach and test running my app locally, migrating all the data from my local postgres container, and running alembic migrations?

### docker containers
> [!NOTE] docker vs orbstack
> since I develop on macOS, I actually use `orbstack` instead of `docker desktop` with no issues

so my current postgres container is set up like this
```yaml
db:
    restart: unless-stopped
    container_name: ring-db
    image: postgres:16.1
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - 8004:5432
    expose:
      - 5432
    environment:
      - POSTGRES_USER=REDACTED
      - POSTGRES_PASSWORD=REDACTED
      - POSTGRES_DB=ring
    profiles: [ "dev" ]
    networks:
      - default
```
and it was pretty simple to get the cockroach container to run as well
```yaml
  cockroach:
    image: cockroachdb/cockroach:latest
    container_name: ring-cockroach
    restart: unless-stopped
    profiles: [ "dev" ]
    command: start-single-node --certs-dir=/root/.cockroach-certs
    ports:
      - 26257:26257
      - 8007:8080
    environment:
      - COCKROACH_USER=ringcockroach
      - COCKROACH_PASSWORD=ringcockroach
      - COCKROACH_DATABASE=ring
    volumes:
      - cockroach-data:/cockroach/cockroach-data
      - ./certs:/root/.cockroach-certs
    networks:
      - default
```
note the command: `start-single-node` since I don't need to spin up multiple nodes with replication or sharding.

the docs suggested spinning up in `--insecure-mode`, but that caused failures to create the default `COCKROACH_USER` with `COCKROACH_PASSWORD`. using the *secure* mode with ssl ended up being *interesting...*

> [!ERROR] TLS 😭
> I honestly don't know what TLS is and I am too lazy to really figure it out.
> however
> that really blew up in my face when trying to manage my `cockroachdb` local docker container. 
> > for my production server, the `cockroach` cloud set-up gives you the exact cert that you need and tells you where to mount it 🤷‍♂️. no problems there so far
> 
> the docs kept talking about doing things in insecure mode for local development, but then it wouldn't auto create the db user that I wanted. when naively doing things in secure mode, I thought it worked automatically; but that's only because I
> first started the container in insecure mode so it auto created my db user and database, then took it down and restarted it in secure mode so it automatically generated TLS certs for the cockroach user. and then since I'm using docker volumes to persist the state, things were working fine for the first day or two
> 
> but when I had to nuke my docker volume and restore from a backup because I messed up my database, I ended up in TLS hell.
> 
> the iteration cycle was spin up docker container while viewing logs -> things break -> take down container -> delete volume -> start again, over and over I was doing this with different certs, mounting the certs in different locations, trying different commands (e.g. cockroach start-single-node --cert-principal-map).
> 
> I eventually succeeded by creating the CA cert, the node cert, and a client cert for the "root" user and mounting all of those into a specified certs dir in my `cockroachdb` container. then when spinning up the container for the first time, it would auto create a client cert for the specified `COCKROACH_USER` I wanted. and now I can finally spin up and down the container as many times as I want. I don't get why I need all these certs **and** a "root" client cert when I only want access as the `COCKROACH_USER`.
> > noting that if I remove my volume in the future for a hard reset, I will need to remove the autogenerated cert files from my certs directory mount
>

it was really convenient to be able to just `docker volume rm` and reset the persisted database as I was iterating on trying to get the `cockroach` db container up and running correctly

### fastapi x sqlalchemy x cockroach
replacing `postgres` with `cockroach` was really simple since I use `sqlalchemy` to connect to my database.

all I had to do was set my connection string to reference my `cockroach` container and pass the user and password for the `ring` database
```env {title = ".env"}
COCKROACH_DATABASE_URI=cockroachdb://COCKROACH_USER:COCKROACH_PASSWORD@cockroach:26257/ring?sslmode=require
```
then I added the `sqlalchemy-cockroachdb` library using `uv`
> [!NOTE] uv
> I use `uv` to manage my python project with a `pyproject.toml` which keeps things in sync and manages dependencies automatically
```sh
uv add sqlalchemy-cockroachdb
```

I was able to create my `sqlalchemy` database engine in the exact same way I was doing it with `postgres` and just swapped the connection string.
```python {title = "sqlalchemy_base.py"}
engine = create_engine(
    get_config().cockroach_database_uri,
)
```
> [!NOTE] get_config
> `get_config` is a cached function I wrote that just returns a `BaseSettings` object for my `fastapi` project. `BaseSettings` allows you to pass configuration settings to your `fastapi` app on startup through environment variables with `pydantic` features like field validation and computed fields.

for `alembic` and `pytest`, I used the same approach of swapping the connection string and had no issues
```python {title = "env.py"}
config.set_main_option("sqlalchemy.url", get_config().cockroach_database_uri)
```

```python {title = "conftest.py"}
engine = create_engine(config.cockroach_database_uri)
```

this is all it took to swap over to using `cockroach` for my local development environment, testing environment, and alembic configuration
### migrating my data - pg_dump for the win
dumping an entire database is as simple as running a single command
```sh
docker exec ring-db pg_dump -U ring-postgres -d ring > local.sql
```
and then importing that into my `cockroach` container also only took a single command
```
docker exec -i ring-cockroach ./cockroach sql -d ring --url="postgresql://ringcockroach@127.0.0.1:26257/ring?sslcert=%2Froot%2F.cockroach-certs%2Fclient.root.crt&sslkey=%2Froot%2F.cockroach-certs%2Fclient.root.key&sslmode=verify-full&sslrootcert=%2Froot%2F.cockroach-certs%2Fca.crt" < local.sql
```
if you are wondering where I got the connection url from, `cockroach` actually prints it out for you on container start which is super convenient (since, again, I don't know how TLS works)

I did basically the same thing for my production database with the only added complexity being that I had to upload my dump from the EC2 to S3 and I used my production database connection string and password.

## cutover time
at this point, I merged and pushed my changes to production since I was relatively sure that I could start reading from my new database and I wanted to start live testing before I decommissioned my postgres DB. I felt safe doing this because I had my pg_dump backup of all production data and knew that I could always restore from there.

and just like magic, the site worked perfectly on my first try.

no, I'm serious!

it was a pretty cool feeling to be able to just switch databases and have no issues or real user impact.

## what's next
I haven't dove into any of the `cockroachdb` special stuff yet, sharding, replication, or other distributed database features but that will be on the back-burner. next step is to migrate off my EC2 container! I think that the couple dollars for S3 and Cloudfront CDN are pretty cheap but I don't want to pay $10 for the EC2.

finding a free hosting provider for a 750 hour uptime 1 GB EC2 is pretty difficult (okay maybe impossible). so I think this is a good opportunity to remove my celery dependency for async scheduled task execution and be able to use either serverless or cold start servers for my fastAPI backend. I'm not sure what my celery replacement will be yet but for the API server, there are options like Neon and Fly.io.
