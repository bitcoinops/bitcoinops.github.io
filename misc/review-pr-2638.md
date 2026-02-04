# PR 2638 review notes (local)

## Access attempts

Unable to fetch the PR or patch from GitHub in this environment due to a CONNECT tunnel 403 error:

- `git fetch origin pull/2638/head:pr-2638` → `fatal: unable to access 'https://github.com/bitcoinops/bitcoinops.github.io.git/': CONNECT tunnel failed, response 403`
- `curl -L -o /tmp/pr-2638.patch https://github.com/bitcoinops/bitcoinops.github.io/pull/2638.patch` → `curl: (56) CONNECT tunnel failed, response 403`

## Local build command reference

The CI job runs `make production`, which expands to `clean`, `all`, and `production-test`. The Makefile shows the checks that can fail for new newsletter content, including Markdown linting, required frontmatter, duplicate titles/slugs, and HTML validation post-build.
