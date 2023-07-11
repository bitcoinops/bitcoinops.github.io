---
title: Onion messages

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
    - title: Onion message support
      link: https://github.com/lightning/bolts/pull/759

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposal for LN direct messages
    url: /en/newsletters/2020/02/26/#ln-direct-messages

  - title: "C-Lightning #3600 adds experimental support for onion messages using blinded paths"
    url: /en/newsletters/2020/04/08/#onion-messages

  - title: "Eclair #1957 adds basic support for onion messages"
    url: /en/newsletters/2021/11/17/#eclair-1957

  - title: "C-Lightning #4921 updates the implementation of onion messages"
    url: /en/newsletters/2021/12/08/#c-lightning-4921

  - title: "Eclair #2061 adds initial support for onion messages"
    url: /en/newsletters/2021/12/08/#eclair-2061

  - title: "2021 year-in-review: onion messages"
    url: /en/newsletters/2021/12/22/#offers

  - title: "Eclair #2099 adds onion message configuration option for controling when to relay messages"
    url: /en/newsletters/2022/01/05/#eclair-2099

  - title: "Eclair #2117 adds onion message replies in preparation for supporting offers"
    url: /en/newsletters/2022/01/12/#eclair-2117

  - title: "Eclair #2133 begins relaying onion messages by default"
    url: /en/newsletters/2022/01/26/#eclair-2133

  - title: "Proposal to charge for onion message bandwidth"
    url: /en/newsletters/2022/03/09/#paying-for-onion-messages

  - title: "Proposals to either rate limit or charge for onion messages"
    url: /en/newsletters/2022/07/06/#onion-message-rate-limiting

  - title: "LDK #1503 adds support for onion messages"
    url: /en/newsletters/2022/08/24/#ldk-1503

  - title: "LDK #1652 adds support for onion message reply paths"
    url: /en/newsletters/2022/08/31/#ldk-1652

  - title: "2022 year-in-review: onion messages"
    url: /en/newsletters/2022/12/21/#onion-message-limiting

  - title: "LDK #2294 adds support for replying to onion messages"
    url: /en/newsletters/2023/06/21/#ldk-2294

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Blinded paths
    link: topic rv routing

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Onion messages** are messages that can be sent across the LN network
  by nodes that support the protocol.  Messages don't use HTLCs,
  minimizing the use of LN node resources.
---

{% include references.md %}
{% include linkers/issues.md issues="" %}
