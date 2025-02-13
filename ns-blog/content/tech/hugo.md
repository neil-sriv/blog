+++
title = "Hugo"
date = "2025-02-12T23:14:05-05:00"

#
# description is optional
#
# description = "An optional description for SEO. If not provided, an automatically created summary will be used."

tags = ["tech", "hugo", "blog"]
+++

## setting up my personal blog with `hugo`
maybe it's because I've been reading a ton of blog posts on `bluesky` from other engineers and developers or maybe it's because I have a oversized belief that my thoughts are actually interesting (like most software engineers), but I'm finally starting a blog.

after doing a bit of research, I settled on using `hugo` for my auto-generated website and hosting through `github pages`. I considered some self-hosting alternatives like `nginx` and `caddy`, but after docs on the `hugo` site made it really easy to auto-deploy on `github pages`. 
> turns out, auto-deployment is a bitch to solve by yourself on a self-hosted machine. I'm not trying to deal with jenkins or buildkite.

### let's get into it
now the `hugo` docs may have helped with the deployment, but their ease-of-use ended there.


### what the heck is {{}}
### templates, archetypes, and lookup order, oh my!
### pagination - bless [jmooring](https://github.com/jmooring)
### anything else?
the only annoying part of the workflow left at this point (besides any site framework changes), is that in order to actually publish a new post, I have to move the content from my editor, `obsidian`, to my `hugo` git repository and push my changes. it may be possible to use `rsync` or symlinks to link my `obsidian` content directory directly to a directory in my blog repo, but I'm thinking about exploring ways to access my `obsidian` synced vaults via an API.