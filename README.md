# relaxdiego.com

Mark Maglana's technical blog. Built with [Hugo](https://gohugo.io/), served by
GitHub Pages.

## Getting set up

Install [devbox](https://www.jetify.com/devbox) and
[direnv](https://direnv.net/), then:

```
direnv allow
```

That is the whole setup. devbox puts Hugo, AsciiDoctor, process-compose, and
make on your PATH at the versions pinned in `devbox.lock`, so what you build
here is what CI builds. Without direnv, prefix any command with `devbox run`,
as in `devbox run -- make build`.

## Commands

Run `make` on its own to see them:

| Command       | What it does                                        |
| ------------- | --------------------------------------------------- |
| `make dev`    | Serve the site at http://localhost:1313 and watch it |
| `make build`  | Build the whole site into `public/`                  |
| `make resume` | Render the resume to HTML and PDF                    |
| `make clean`  | Delete everything that is generated                  |
| `make check`  | Fail if the pinned Hugo version drifted              |

`make dev` runs two processes under process-compose: Hugo's own server, which
watches `content/` and `layouts/`, and a watcher that re-renders the resume
whenever its AsciiDoc changes. It binds to `0.0.0.0`, so you can open the site
from a phone on the same network.

## Where things live

```
content/posts/   one file per post, named YYYY-MM-DD-slug.md
content/_index.md  the homepage
layouts/         the four templates and one shortcode the site uses
static/          images, favicons, the CA certificate page — copied as-is
snippets/        real code used by posts, with its tests beside it
resume/          the resume, in AsciiDoc
drafts/          unfinished posts; Hugo never sees this directory
```

## Writing a post

Add a file to `content/posts/` named `YYYY-MM-DD-slug.md`:

```
---
title: "The title, in quotes"
date: 2026-08-21
slug: the-url-this-post-will-live-at
categories: ["one", "two"]
---
```

`date` and `slug` are both required and both deliberate. The published URL is
`/YYYY/MM/<slug>.html`, which is the shape this blog has used since 2011.
Nothing derives it from the filename, so renaming a file never moves a page.

Add `draft: true` to keep a post out of the built site while still committing
it. `make dev` shows drafts; `make build` does not.

### Code in a post

Ordinary code goes in a fenced block. Add `{linenos=table}` after the language
for line numbers:

````
```python {linenos=table}
print("hello")
```
````

Code that should be *known to work* goes in `snippets/` next to a test that
exercises it, and the post pulls it in:

```
{{< snippet file="iso8601/s01_simple_case.py" lang="python" linenos="true" >}}
```

The post and the working code can then never drift apart.

## Deploying

Push to `master`. `.github/workflows/deploy.yml` renders the resume, builds the
site, and publishes it to GitHub Pages. The repository's Pages source must be
set to **GitHub Actions** under Settings → Pages.

## Two things that must not change

**The URLs.** Every post has lived at `/YYYY/MM/slug.html` since 2011. Inbound
links, search results, and Wayback Machine snapshots all depend on that. The
`permalinks` and `uglyURLs` settings in `hugo.toml` are what hold it.

**The inline stylesheet.** `layouts/baseof.html` carries the site's CSS inside a
`<style>` tag rather than linking a file, and the resume is rendered with
`-a webfonts!` for the same reason. A single saved copy of any page — an
archive snapshot, a file on a disk — then still reads correctly on its own,
with nothing left to download.
