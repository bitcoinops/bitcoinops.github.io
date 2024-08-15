---
title: Channel commitment upgrades

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLT 2: upgrade protocol on reestablish"
      link: https://github.com/lightning/bolts/pull/868

    - title: Dynamic commitments
      link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003531.html

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Upgrading channel commitment formats
    url: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats

  - title: "C-Lightning #4532 adds experimental support for upgrading a channel"
    url: /en/newsletters/2021/06/09/#c-lightning-4532

  - title: Updating LN commitments
    url: /en/newsletters/2022/04/06/#updating-ln-commitments

  - title: Analysis of multiple proposals for upgrading LN channels
    url: /en/newsletters/2024/05/24/#upgrading-existing-ln-channels

  - title: "BOLTs #869 introduces a new channel quiescence protocol, in part for channel upgrades"
    url: /en/newsletters/2024/06/28/#bolts-869

  - title: "LND #8952 refactors code to make it easier to implement dynamic commitments"
    url: /en/newsletters/2024/08/09/#lnd-8952

  - title: "LND #8967 adds Stfu wire message to lock channel state before initiating protocol upgrades"
    url: /en/newsletters/2024/08/16/#lnd-8967

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Anchor outputs
    link: topic anchor outputs

  - title: "LN-Symmetry (Eltoo)"
    link: topic eltoo

  - title: PTLCs
    link: topic ptlc

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Channel commitment upgrades** are changes to the format of the
  onchain commitment transaction used by LN, or any other change which
  would affect the commitment transaction.  Upgrading the LN protocol
  for these changes requires extra care because both nodes involved in a
  channel need to agree perfectly on the commitment format.

---
Upgrades of this nature can also be challenging when the upgraded
commitment transaction can't directly spend from the setup transaction
which established a channel.  For example, the original LN protocol
establishes channels with payment to a P2WSH output in the setup
transaction.  By contrast, the LN protocol may later expect commitment
transactions to spend from a [taproot][topic taproot] P2TR output.
The simplest way to deal with this transition would be P2WSH users to
close their channels and reopen them using P2TR, but that would be
wasteful, so developers work on channel commitment upgrade mechanisms
that don't require unnecessary channel closure.

{% include references.md %}
{% include linkers/issues.md issues="" %}
