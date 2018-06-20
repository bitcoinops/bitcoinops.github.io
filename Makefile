all: build test

preview:
	bundle exec jekyll clean
	bundle exec jekyll serve --future --drafts --unpublished --incremental

build:
	bundle exec jekyll clean
	bundle exec jekyll build --future --drafts --unpublished

test:
	bundle exec htmlproofer --check-html --disable-external --url-ignore '/^\/bin/.*/' ./_site
