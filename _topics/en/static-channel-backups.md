---
title: Static channel backups

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BOLT2

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "C-Lightning #1854 partly implements option_data_loss_protect"
    url: /en/newsletters/2018/08/28/#c-lightning-1854

  - title: "LND #2370 now updates a channel.backup file each time a new channel is opened or closed"
    url: /en/newsletters/2019/01/29/#lnd-2370

  - title: Closing lost channels with only a BIP32 seed and option_data_loss_protect
    url: /en/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed

  - title: "Core Lightning 0.12 adds support for static channel backups"
    url: /en/newsletters/2022/08/24/#core-lightning-0-12-0

  - title: "Core Lightning #5361 adds experimental support for peer storage backups"
    url: /en/newsletters/2023/02/15/#core-lightning-5361

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Static channel backups** are backup files that only need to be
  updated when an LN node opens or closes a new channel.  In case of data
  loss, they allow the node to attempt to get the latest channel state from their
  remote peer.


---
The mechanism allows a node that has potentially lost some of its
state to encourage its peer to initiate a channel close. Since the peer
should still have the most recent state, it can close the channel using that
state and allow both nodes to receive their most recent balances.

This method does carry two risks:

- **Advertising weakness:** the peer can guess that something is wrong
and attempt to steal funds from the stale node by closing the channel
using an old state. But the risk is mitigated in large part by the LN
penalty mechanism: if the stale node does have a revocation of that old
state in its backups, it can create a breach remedy transaction (justice
transaction) that will seize *all* of the lying peer’s funds from that
channel. Because of this risk, peers using the `option_data_loss_protect`
mechanism have an incentive to close the channel honestly with the
latest state when they hear from a stale node.

- **Mutual loss:** if both peers lose state, or if the remote peer
  becomes permanently unavailable, static channel backups can't help
  recover the current channel state.

{% include references.md %}
{% include linkers/issues.md issues="" %}
