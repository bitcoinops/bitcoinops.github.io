---
title: Stuck funds problem

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: stuck-funds

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network
  - Liquidity Management

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLTS issue #728: stuck funds"
      link: https://github.com/lightning/bolts/issues/728

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: C-Lightning prevents the funder from spending the full balance
    url: /en/newsletters/2020/02/19/#c-lightning-3500
    date: 2020-02-19
    feature: true

  - title: Eclair accepts HTLCs that push a peer below the channel reserve
    url: /en/newsletters/2023/05/31/#eclair-2666
    date: 2023-05-31

  - title: Eclair forwards HTLCs to peers below the reserve after splicing or dual funding
    url: /en/newsletters/2023/11/08/#eclair-2761
    date: 2023-11-08

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
  **Stuck funds problem** is a Lightning channel state in which neither
  party can move funds.  If the party that funded the channel has spent its
  balance, the other party cannot pay it, because adding an HTLC increases
  the commitment transaction's size and the resulting fee, which the funder
  has to pay and can no longer afford.  The channel stays unusable until the
  balance or the fee arrangement changes.
---
The problem appears when the party responsible for paying the channel's
commitment transaction fees no longer has enough balance to cover them.  In
the example discussed on the BOLTS repository, Alice funds a channel and
pays Bob her whole available balance.  Alice cannot spend any more, as
expected, but Bob cannot pay Alice either: adding an [HTLC][topic htlc]
makes the commitment transaction larger, which raises its fee, and that fee
comes out of the funder's balance -- which is now empty.  The channel is
therefore unusable in both directions, even though it still holds funds.

Several mitigations have been adopted at the implementation level.  The
first was a short-term fix that prevents the funder from spending its entire
available balance, leaving enough behind to pay for future fee increases.
Later work relaxed the channel reserve instead: Eclair began accepting an
HTLC that would reduce a peer's balance below the reserve, since the reserve
exists to punish outdated closes, and a peer that accepts an HTLC has more at
stake than the reserve anyway.  A related change allows forwarding a limited
number of HTLCs to a peer below the reserve when the situation arises after
[splicing][topic splicing] or [dual funding][topic dual funding].

The underlying constraint is a property of the fee mechanism rather than a
bug: whoever pays for the commitment transaction must keep enough balance to
do so, and protocol changes that move fees, add inputs or change the reserve
rules also change when the problem can appear.

{% include references.md %}
{% include linkers/issues.md issues="" %}
