+++
title = "setting up a personal blog with hugo"
date = "2025-02-13T23:14:05-05:00"

#
# description is optional
#
# description = "An optional description for SEO. If not provided, an automatically created summary will be used."

tags = ["tech", "hugo", "blog"]
+++
> [!WARNING] caveat
> I'm writing based on my own experiences using `hugo` and my understanding of how things work, I'll probably get things wrong so please refer to the [`hugo docs`](https://gohugo.io/documentation/) for correctness

maybe it's because I've been reading a ton of blog posts on `bluesky` from other engineers and developers or maybe it's because I have a oversized belief that my thoughts are actually interesting (like most software engineers), but I'm finally starting a blog.

after doing a bit of research, I settled on using `hugo` for my auto-generated website and hosting through `github pages`. I considered some self-hosting alternatives like `nginx` and `caddy`, but the docs on the `hugo` site made it really easy to auto-deploy on `github pages`. 
> turns out, auto-deployment is a bitch to solve by yourself on a self-hosted machine. I'm not trying to deal with jenkins or buildkite.
>
> plus the fact that github pages is free doesn't hurt either

it wasn't even too hard to set-up a custom domain with github pages as well. probably a solid option for static/server-side-rendered website hosting in 2025.

### let's get into it
to be honest, I'm not a prolific frontend engineer, I'm barely competent with `html`, and less than competent with `css`. I've never used site generators and I use markdown in `obsidian` just to take notes and keep track of personal documents. 

now the `hugo` docs may have helped with the deployment, but their ease-of-use ended there. I ended up digging through `hugo` forums, asking `chatgpt`, and old fashioned trial n' error to eventually get a working site with all the bells and whistles I wanted.
### what the heck is {{}}
 `hugo` has custom syntax, templating, functions, methods, archetypes...the list goes on forever. it took me quite a while to finally figure out that in `.html` template files and `.md` archetype files you could use  `{{ <command> }}` to access and work with pages, tags, and other data from my website. you can use this to create relative links, set-up reusable page structures, and plenty more.

this is a snippet that displays links to the 5 most recent posts on my site with the date they were posted

```
{{ $recent_posts := ( (where .Site.Pages "IsPage" true).ByDate.Reverse) | first 5 }}
<p>here's a list of my most recent posts</p>
<ul>
{{ range $recent_posts }}
<li>
    <time datetime="{{ .Date.Format "Jan 02, 2006" }}">{{ .Date.Format "Jan 02, 2006" }}</time>:
    <a href="{{ .RelPermalink }}">{{.LinkTitle}}</a>
</li>
{{ end }}
</ul>
```
note how you can grab posts from the site with `.Site.Pages` and filter/sort them using methods like `where` and `.ByDate`.
### ʕ•ᴥ•ʔ {#bear}
one of the first big mistakes I made was using the [`hugo-bearblog`](https://github.com/janraasch/hugo-bearblog) theme. now I have nothing against it, but the example site and styling left much to be desired. I didn't like that you were limited to only a `blog` section header, code block styling was atrocious, and honestly probably since it was my first attempt, I had lots of trouble updating the templates with my own ideas.

thankfully, I eventually found [`hugo-bearcub`](https://github.com/clente/hugo-bearcub) that seems to be just as fast as `hugo-bearblog`, highly accessible, and with a less opinionated structure. I was able to implement my own sections and updated the `nav.html` template to render any a header link for any section I care to generate.
``` {#nav.html}
<a href="{{ "" | relURL }}">home</a>
{{ range .Site.Menus.main }}
<a href="{{ .URL }}">{{ lower .Name }}</a>
{{ end }}
```
the `range` function syntax pattern is a bit strange to me coming from a mostly `python` and `java` background, but it reminds for a `for each` loop.

the other really strange thing to me about `hugo` syntax is that you have to use a `.` to reference the current local variable (*I think?*)
### templates, archetypes, and lookup order, oh my!
`hugo` compiles the static site beginning at the `index.html` page
#### partial templates
partial templates allow you to pre-define html rendering patterns for parts of the webpage, like the above [`nav.html`](#nav.html)

not all markdown support comes out of the box unfortunately, specifically `blockquotes`. Normally you can specify a type of `blockquote` style, like `NOTE` or `WARNING`, and you get a nicely formatted and colored section:

\<INSERT PICTURE OF BLOCKQUOTE HERE\>

unfortunately for me, rendering blockquotes with types is not supported by default. so I had to write a new partial template:
> and by "write", I of course mean, "found on github"

```
{{ $emojis := dict
  "caution" ":exclamation:"
  "important" ":information_source:"
  "note" ":information_source:"
  "tip" ":bulb:"
  "warning" ":warning:"
}}

{{ if eq .Type "alert" }}
  <blockquote class="alert alert-{{ .AlertType }}">
    <p class="alert-heading">
      {{ transform.Emojify (index $emojis .AlertType) }}
      {{ with .AlertTitle }}
        {{ . }}
      {{ else }}
        {{ or (i18n .AlertType) (title .AlertType) }}
      {{ end }}
    </p>
    {{ .Text }}
  </blockquote>
{{ else }}
  <blockquote>
    {{ .Text }}
  </blockquote>
{{ end }}
```
### pagination - bless [jmooring](https://github.com/jmooring)

### shortcodes or longcodes
it's truly insane to me that ``
### anything else? {#anything-else}
there is anchor link support in markdown by default with the pattern
```
[heading link](#heading)

### heading name {#heading}
```
for example:
[ʕ•ᴥ•ʔ](#bear)

but I do miss the on-hover, click-to-copy anchor link pattern from `confluence` and `quip`

the only annoying part of the workflow left at this point (besides pretty much any site framework changes), is that in order to actually publish a new post, I have to move the content from my editor, `obsidian`, to my `hugo` git repository and push my changes. it may be possible to use `rsync` or symlinks to link my `obsidian` content directory directly to a directory in my blog repo, but I'm thinking about exploring ways to access my `obsidian` synced vaults via an API.

I think it'd be a fun challenge to somehow set up `bluesky` comments on my blog posts, I've seen others do something similar a few times but haven't looked into it.
