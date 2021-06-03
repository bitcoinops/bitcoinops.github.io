all: test-before-build build test-after-build
production: all production-test

## If we call git in our tests without using the --no-pager option
## or redirecting stdout to another command, fail unconditionally.
## This addresses an issue where `make` can't be run within an IDE because
## it tries to paginate the output, see:
## https://github.com/bitcoinops/bitcoinops.github.io/pull/494#discussion_r546376335
export GIT_PAGER='_contrib/kill0'

clean:
	bundle exec jekyll clean

preview:
	## Don't do a full rebuild (to save time), but always rebuild index.html
	rm _site/index.html || true
	bundle exec jekyll serve --future --drafts --unpublished --incremental

build:
	bundle exec jekyll clean
	bundle exec jekyll build --future --drafts --unpublished

test-before-build:
	## Check schemas against data files
	! find _data/compatibility -type f | while read file ; do bundle exec _contrib/schema-validator.rb _data/schemas/compatibility.yaml $$file || echo Error: $$file ; done | grep .
	! find _topics/ -type f | while read file ; do bundle exec _contrib/schema-validator.rb _data/schemas/topics.yaml $$file || echo Error: $$file ; done | grep .

	## Ensure topics have a bold term on their first line
	! git --no-pager grep -A1 ^excerpt: -- _topics/ | sed '/:excerpt:/d; /^--$$/d' | grep -v '\*\*' | grep -q .

	## Check for Markdown formatting problems
	@ ## - MD009: trailing spaces (can lead to extraneous <br> tags
	bundle exec mdl -g -r MD009 .

	## Check that posts declare a slug, see issue #155 and PR #156
	! git --no-pager grep -L "^slug: " _posts
	## Check that all slugs are unique
	! git --no-pager grep -h "^slug: " _posts | sort | uniq -d | grep .
	## Check for things that should probably all be on one line
	@ ## Note: double $$ in a makefile produces a single literal $
	! git --no-pager grep -- '^ *- \*\*[^*]*$$'
	! git --no-pager grep -- '^ *- \[[^]]*$$'
	## Check for unnecessarily fully qualified URLs (breaks local previews and internal link checking)
	! git --no-pager grep -- '^\[.*]: https://bitcoinops.org' | grep -v skip-test | grep .
	! git --no-pager grep -- '](https://bitcoinops.org' | grep -v skip-test | grep .
	## Check for duplicate words
	@ ## Only applies to *.md files
	@ ## Add <!-- skip-duplicate-words-test --> to same line to skip this test
	@ ## Ignores any strings with non alphabetical characters
	export LC_ALL=C ; ! git ls-files '*.md' | while read file ; do \
	    cat $$file \
	      | sed '/skip-duplicate-words-test/d' \
	      | sed '/^#/d' \
	      | tr ' ' '\n' \
	      | sed 's/ *//g;' \
	      | sed 's/^.*[^a-zA-Z].*/ /; /^$$/d;' \
	      | uniq -d \
	      | sed '/^ $$/d' \
	      | sed "s|.*|Duplicate word in $$file: &|" ; \
	done | grep .

	## Check that newly added or modifyed PNGs are optimized
	_contrib/travis-check-png-optimized.sh

	## Check for duplicate links in any particular topic file
	! git grep url:  _topics/ | sed 's/ \+/ /g' | sort | uniq -d | grep .

	## Check for mistakes typical spell checkers can't catch
	! git --no-pager grep -i '[d]iscrete log contract'

test-after-build:
	## Check for broken Markdown reference-style links that are displayed in text unchanged, e.g. [broken][broken link]
	! find _site/ -name '*.html' | xargs grep ']\[' | grep -v skip-test | grep .
	! find _site/ -name '*.html' | xargs grep '\[^' | grep .

	## Check for duplicate anchors
	! find _site/ -name '*.html' | while read file ; do \
	  cat $$file \
	  | egrep -o "(id|name)=[\"'][^\"']*[\"']" \
	  | sed -E "s/^(id|name)=//; s/[\"']//g" \
	  | sort | uniq -d \
	  | sed "s|.*|Duplicate anchor in $$file: #&|" ; \
	done | grep .

	## Check for broken links
	bundle exec htmlproofer --check-html --disable-external --url-ignore '/^\/bin/.*/' ./_site

## Tests to run last because they identify problems that may not be fixable during initial commit review.
## However, these should not be still failing when the site goes to production
production-test:
	## Fail if there are any FIXMEs in site source code; add "skip-test" to the same line of source code to skip
	! git --no-pager grep FIXME | grep -v skip-test | grep .

new-topic:
	_contrib/new-topic

email: clean
	@ echo
	@ echo "[NOTICE] Latest Newsletter: http://localhost:4000/en/newsletters/$$(ls _posts/en/newsletters/ | tail -1 | tr "-" "/" | sed 's/newsletter.md//')"
	@ echo
	$(MAKE) preview JEKYLL_ENV=email
