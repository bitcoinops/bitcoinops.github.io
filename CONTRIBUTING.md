# Contributing

## Newsletter

The newsletter is published weekly, on Wednesdays, around 15:00 UTC. Typically a
pull request for the newsletter is opened the Saturday before publishing. Any
review of the newsletter PRs is appreciated. However, feedback received after
Tuesday UTC may not be incorporated due to time constraints.

### Translations

The Bitcoin Optech website supports multiple languages for both newsletters and
blog posts. If you are interested in contributing translations for the
newsletter (thank you!), we have some best practices to help keep things
standardized:

- View the list of existing open pull requests to see which newletters/blogs
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
