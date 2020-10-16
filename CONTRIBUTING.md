# Contributing

## Newsletter

The newsletter is published weekly, on Wednesdays, around 15:00 UTC. Typically a
pull request for the newsletter is opened the Saturday before publishing. Any
review of the newsletter PRs is appreciated. However, feedback received after
Tuesday UTC may not be incorporated due to time constraints.

## Topics pages

New topics pages are added to https://bitcoinops.org/en/topics periodically.
If you are interested in writing a new topic page, please contact the Optech
maintainers.

Additionally, new links are added to the existing topics pages every week in
the same pull request as for that week's newsletter. The most efficient way
to review the changes is to look at the diff and verify that the links work.
You can check the links locally or on the netlify preview:

- Checkout the branch locally.
- (If testing locally) run `make preview` in one terminal, to serve the site locally on port 4000.
- In another terminal, run:

  `PR_NUMBER=474; BASEURL="https://deploy-preview-$PR_NUMBER--bitcoinops.netlify.app/" ; git diff master _topics/ | sed "s'url: /'url: ${BASEURL:-http://localhost:4000/}'" | colordiff | less -r`
  (for a remote preview, changing `PR_NUMBER` to the number of the PR).

  `BASEURL="" ; git diff master _topics/ | sed "s'url: /'url: ${BASEURL:-http://localhost:4000/}'" | colordiff | less -r`
  (for a local preview)

  This converts the relative links in the topics page to absolute links.
  `colordiff` makes it easier to see the changed lines and can be dropped from
  the command if you don't have it installed.
- Click on each link to verify that they're correctly formed.

## Translations

The Bitcoin Optech website supports multiple languages for both newsletters and
blog posts. If you are interested in contributing translations for the
newsletter (thank you!), we have some best practices to help keep things
standardized:

- View the list of existing open pull requests to see which newsletters/blogs
  are already being translated
- Ensure your language is listed under the `languages` field in the
  `_config.yml` file
  - We are using the [2 character ISO 639-1 language codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
- Create a file with the same name as the `en` language variant:
  - For newsletters, place the file in `_posts/<language code>/newsletters/`
  - For blog posts, place the file in `_posts/<language code>/`
- Set the `lang` field to `<language code>`
- Append `-<language code>` to both the `slug` and `name` fields
- When linking to material on the Optech site, link to the appropriate
  translation, if one is available.
  - When linking to a specific header/bullet within a page, #anchor links are [automatically generated](https://github.com/bitcoinops/bitcoinops.github.io/blob/master/_plugins/auto-anchor.rb).
      - Due to [limitations](https://github.com/bitcoinops/bitcoinops.github.io/pull/349)
        in the automatic anchoring process, some languages need HTML comments
        inserted into the header/bullet to ensure a unique anchor is generated.
        For example, see the `<!--1-->` [comment](https://github.com/bitcoinops/bitcoinops.github.io/commit/4e450d1a1f72219ec50ad91edae605647164d25d#diff-435f99f277721eff9e2f244149575f41R41)
        in this Japanese newsletter.
- To help with reviewing, squash commits where it makes sense
- Using a commit message similar to `news70: add Japanese translation` helps
  keep translations easily visible in the commit log
- Testing your translation
  - Follow the instuctions in the [README.md](https://github.com/bitcoinops/bitcoinops.github.io/blob/master/README.md)
    - `make preview` to view the local website and review
    - `make production` to run additional checks (link checking, linting, etc)
  - For the page you have translated, ensure that the language code link shows
    up on the `en` language variant
  - Check that the page renders properly
- Create a pull request to the
  [https://github.com/bitcoinops/bitcoinops.github.io]() repository
  - One newsletter per PR allows for easier review
  - Allowing edits from maintainers permits maintainers to make additional
    commits to your PR branch
- Pat yourself on the back for your contribution!

Due to the timeliness of the newsletters, we ask that, where possible,
translation PRs are opened within a week of the original newsletter being
published for new newsletters. That said, we also encourage translation of
older newsletters and blog posts as well.

## Reviewing changes to the website generation code

When reviewing changes to the Jekyll code that generates the website, it's useful to compare
the generated website before and after the change. To do so, you can run the following commands:

```bash
git checkout $reviewbranch  # Checkout the branch that you want to review
rm -rf _site.bak  # Remove the backup site directory if it exists
JEKYLL_ENV=local make build  # Do a clean build of the site to the _site directory. The local env is to remove the 'updated' field which causes irrelevant diffs
mv _site _site.bak  # Rename the generated site directory
git checkout master  # Checkout the base branch
JEKYLL_ENV=local make build  # Do a clean build of the site to the _site directory
diff -ruN _site _site.bak  # Compare the generated sites (-r for recursive, -u for unified, -N for new file)
```

## Compatibility Matrix Data

The compatibility matrix section of the website is built from
[YAML](https://yaml.org/) files located in [_data/compatibility/](_data/compatibility/).
Each wallet also requires a markdown file in
[en/compatibility/](en/compatibility/). The compatibility images (usability
screenshots, logos) are located in [img/compatibility/](img/compatibility/) with
sub-folders for each wallet or service. Make sure to optimize any png files using
`optipng -o7 <filename>`. These files are free for anyone to repurpose/republish
elsewhere.

We welcome pull requests to the compatibility matrix, including
testing the latest versions of previously tested services/wallets, adding notable
usability screenshots, or adding new service/wallet tests.

When contributing changes to the compatibility matrix data files, review and adhere to
the YAML schema located in [_data/schemas/compatibility.yaml](_data/schemas/compatibility.yaml).

If you believe any of the data in the compatibility matrix is incorrect, you
can also [submit an issue](../../issues/) detailing what is wrong and how to correct it.

If you want to request a new service or wallet be evaluated, or a new test that you
think is useful, please also submit an issue.
