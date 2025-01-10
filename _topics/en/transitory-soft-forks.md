---
title: Transitory soft forks

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Automatically reverting ('transitory') soft forks"
      link: https://gnusha.org/pi/bitcoindev/64a34b4d46461da322be51b53ec2eb01@dtrt.org/

    - title: Transitory Soft Forks for Consensus Cleanup Forks
      link: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Proposal for a transitory soft fork to activate `OP_CHECKTEMPLATEVERIFY`"
    url: /en/newsletters/2022/04/27/#relayed

  - title: Transitory soft forks for cleanup soft forks
    url: /en/newsletters/2025/01/03/#transitory-soft-forks-for-cleanup-soft-forks

  - title: Transitory soft fork for disabling EC operations due to perceived quantum computer risks
    url: /en/newsletters/2025/01/03/#quantum-computer-upgrade-path

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Transitory soft forks** are soft forks that automatically revert
  after a period of time if Bitcoin users don't extend them or make
  them permanent.
---
The response to the [BIP50][] consensus failure included a transitory
soft fork that briefly limited the maximum block size.  The idea of
doing something similar for adding features was proposed as a compromise
between advocates of [OP_CHECKTEMPLATEVERIFY][topic
op_checktemplateverify] and those who either doubted its utility or
preferred to wait for a better alternative.  Since then, the idea has
also been proposed to derisk consensus changes designed to fix bugs and
improve security.

{% include references.md %}
{% include linkers/issues.md issues="" %}
