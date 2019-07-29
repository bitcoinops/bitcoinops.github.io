all: build test

preview:
	bundle exec jekyll clean
	bundle exec jekyll serve --future --drafts --unpublished --incremental

build:
	bundle exec jekyll clean
	bundle exec jekyll build --future --drafts --unpublished
	bundle --version | tee -a _site/build.txt

test:
	## Check compatibility schema against data files
	# $S ! find _data/compatibility -type f -exec bundle exec _contrib/schema-validator.rb _data/schemas/compatibility.yaml {} \; | grep .
	## Check for Markdown formatting problems
	@ ## - MD009: trailing spaces (can lead to extraneous <br> tags
	bundle exec mdl -g -r MD009 .

	## Check for broken Markdown reference-style links that are displayed in text unchanged, e.g. [broken][broken link]
	! find _site/ -name '*.html' | xargs grep ']\[' | grep -v skip-test | grep .
	! find _site/ -name '*.html' | xargs grep '\[^' | grep .

	## Check that posts declare a slug, see issue #155 and PR #156
	! git --no-pager grep -L "^slug: " _posts
	## Check that all slugs are unique
	! git --no-pager grep -h "^slug: " _posts | sort | uniq -d | grep .

	## Check for broken links
	bundle exec htmlproofer --check-html --disable-external --url-ignore '/^\/bin/.*/' ./_site
