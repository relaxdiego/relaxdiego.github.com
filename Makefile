# Every command this blog needs. Run `make` on its own to see the list.
#
# The tools come from devbox. With direnv they are already on your PATH when
# you cd into this directory; without it, prefix any target with `devbox run`,
# as in `devbox run -- make build`.

.DEFAULT_GOAL := help
.PHONY: help dev build resume clean check test-snippets

## Show this list
help:
	@grep -B1 -E '^[a-z-]+:' $(MAKEFILE_LIST) \
	  | grep -A1 '^##' \
	  | awk '/^##/ { d = substr($$0, 4) } /^[a-z-]+:/ { printf "  \033[1m%-14s\033[0m %s\n", substr($$1, 1, length($$1)-1), d }'

## Serve the site locally and rebuild the resume as you edit it
dev:
	process-compose up

## Build the whole site into public/
build: resume test-snippets
	hugo --gc --minify

## Render the resume to HTML and PDF
resume: static/resume/index.html static/resume.pdf

# Both outputs are generated, so both are gitignored and both are rebuilt in
# CI. The HTML is rendered with the site's own stylesheet, embedded rather than
# linked, so the resume looks like the blog and still stands on its own.
# docinfo=shared is what pulls in styles/docinfo.html, the theme script the
# blog's own pages share. The resume shows no theme button - there is no
# template here to put one in - but it follows a choice made on any other
# page of the site.
static/resume/index.html: resume/index.adoc resume/resume.adoc styles/site.css styles/docinfo.html
	@mkdir -p $(@D)
	asciidoctor --base-dir . -a stylesdir=styles -a stylesheet=site.css \
	  -a docinfo=shared -a docinfodir=styles -o $@ $<

static/resume.pdf: resume/index.adoc resume/resume.adoc
	@mkdir -p $(@D)
	asciidoctor-pdf --base-dir . -o $@ $<

## Delete everything that is generated
clean:
	rm -rf public resources static/resume static/resume.pdf .hugo_build.lock

# Each test is a plain script of bare asserts that imports its sibling module
# by name, so it only runs from inside its own directory. These guard the prose:
# a post that claims Python behaves a certain way should fail the build when it
# stops being true. `build` depends on this target, so python is a devbox
# package and CI runs the tests on every deploy.
#
## Run the tests that sit beside the posts' code snippets
test-snippets:
	@command -v python3 >/dev/null 2>&1 \
	  || { echo "test-snippets needs python3 on PATH" >&2; exit 1; }
	@fail=0; \
	for t in $$(find snippets -name '*_test.py' | sort); do \
	  if out=$$(cd $$(dirname $$t) && python3 $$(basename $$t) 2>&1); then \
	    printf '  ok    %s\n' "$$t"; \
	  else \
	    printf '  FAIL  %s\n' "$$t"; \
	    printf '%s\n' "$$out" | sed 's/^/          /'; \
	    fail=1; \
	  fi; \
	done; \
	exit $$fail

## Fail if the pinned Hugo version and the installed one disagree
check:
	@want=$$(tr -d '[:space:]' < HUGO_VERSION); \
	got=$$(hugo version); \
	case "$$got" in \
	  *"v$$want+extended"*) echo "ok: Hugo $$want" ;; \
	  *) echo "HUGO_VERSION says $$want but hugo reports: $$got" >&2; exit 1 ;; \
	esac
