---
title: Zero-conf channels

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
    - title: "BOLTs #910 specifying zero-conf channels"
      link: https://github.com/lightning/bolts/pull/910

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Discussion about standardizing zero-conf channel opens
    url: /en/newsletters/2021/07/07/#zero-conf-channel-opens

  - title: "Rust-Lightning #1078 adds channel_type negotiation useful for zero-conf channels"
    url: /en/newsletters/2021/11/10/#rust-lightning-1078

  - title: "2021 year-in-review: zero-conf channel opens"
    url: /en/newsletters/2021/12/22/#zeroconfchan

  - title: "LDK #1311 adds support for SCID alias field useful for zero-conf channels"
    url: /en/newsletters/2022/03/23/#ldk-1311

  - title: "BOLTs #910 adds an `option_zeroconf` feature bit"
    url: /en/newsletters/2022/06/08/#bolts-910

  - title: "LDK #1401 adds support for zero-conf channel opens"
    url: /en/newsletters/2022/06/08/#ldk-1401

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
  **Zero-conf channels**, also called turbo channels, are new
  single-funded channels where the funder gives some or all of their
  initial funds to the acceptor. Those funds are not secure until the
  channel open transaction receives a sufficient number of
  confirmations, so there’s no risk to the acceptor spending some of
  those funds back through the funder using the standard LN protocol.
---
For example, Alice has several BTC in an account at Bob's custodial
exchange.  Alice asks Bob to open a new channel paying her 1.0 BTC.
Because Bob trusts himself not to double-spend the channel he just
opened, he can allow Alice to send 0.1 BTC through his node to
third-party Carol even before the channel open transaction has received
a single confirmation.

{:.center}
![Zero-conf channel illustration](/img/posts/2021-07-zeroconf-channels.png)

Zero-conf channels were in use via various ad hoc mechanisms prior to a
standardized mechanisim for them being added to the LN protocol in 2022.

{% include references.md %}
{% include linkers/issues.md issues="" %}
