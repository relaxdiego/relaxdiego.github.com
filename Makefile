# Every command this blog needs. Run `make` on its own to see the list.
#
# The tools come from devbox. With direnv they are already on your PATH when
# you cd into this directory; without it, prefix any target with `devbox run`,
# as in `devbox run -- make build`.

.DEFAULT_GOAL := help
.PHONY: help dev build resume clean check

## Show this list
help:
	@grep -B1 -E '^[a-z-]+:' $(MAKEFILE_LIST) \
	  | grep -A1 '^##' \
	  | awk '/^##/ { d = substr($$0, 4) } /^[a-z-]+:/ { printf "  \033[1m%-8s\033[0m %s\n", substr($$1, 1, length($$1)-1), d }'

## Serve the site locally and rebuild the resume as you edit it
dev:
	process-compose up

## Build the whole site into public/
build: resume
	hugo --gc --minify

## Render the resume to HTML and PDF
resume: static/resume/index.html static/resume.pdf

# Both outputs are generated, so both are gitignored and both are rebuilt in
# CI. `-a webfonts!` drops the Google Fonts <link>, leaving a page that is
# complete on its own — the same reason the site's CSS is written inline.
static/resume/index.html: resume/index.adoc resume/resume.adoc
	@mkdir -p $(@D)
	asciidoctor --base-dir . -a webfonts! -o $@ $<

static/resume.pdf: resume/index.adoc resume/resume.adoc
	@mkdir -p $(@D)
	asciidoctor-pdf --base-dir . -o $@ $<

## Delete everything that is generated
clean:
	rm -rf public resources static/resume static/resume.pdf .hugo_build.lock

## Fail if the pinned Hugo version and the installed one disagree
check:
	@want=$$(tr -d '[:space:]' < HUGO_VERSION); \
	got=$$(hugo version); \
	case "$$got" in \
	  *"v$$want+extended"*) echo "ok: Hugo $$want" ;; \
	  *) echo "HUGO_VERSION says $$want but hugo reports: $$got" >&2; exit 1 ;; \
	esac
