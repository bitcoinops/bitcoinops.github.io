---
title: Rendez-vous routing

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: rv routing

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Hidden destinations
  - Blinded paths
  - Route blinding

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Route blinding
      link: https://github.com/lightningnetwork/lightning-rfc/blob/route-blinding/proposals/route-blinding.md

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Lightning Network protocol 1.1 goals: hidden destinations"
    url: /en/newsletters/2018/11/20/#hidden-destinations

  - title: "Decoy nodes and lightweight rendez-vous routing (blinded paths)"
    url: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing

  - title: "C-Lightning #3600 adds experimental support for onion messages using blinded paths"
    url: /en/newsletters/2020/04/08/#c-lightning-3600

  - title: "C-Lightning #3623 adds a minimal implementation for spending payments using blinded paths"
    url: /en/newsletters/2020/04/22/#c-lightning-3623

  - title: "Discussion about the need for LNURL or offers for effective blinded paths"
    url: /en/newsletters/2022/06/15/#blinded-paths

  - title: "Eclair #2253 adds support for relaying blinded payments"
    url: /en/newsletters/2022/08/03/#eclair-2253

  - title: "Eclair #2418 and #2408 add support for receiving payments sent with blinded routes"
    url: /en/newsletters/2022/09/21/#eclair-2418

  - title: "Core Lightning #5646 adds support for forwarding blinded payments"
    url: /en/newsletters/2022/11/02/#core-lightning-5646

  - title: "Eclair #2482 allows sending payments using blinded routes"
    url: /en/newsletters/2023/01/04/#eclair-2482

  - title: "BOLTs #765 adds route blinding to the LN specification"
    url: /en/newsletters/2023/04/05/#bolts-765

  - title: "LND #7710 adds the ability to retrieve extra data about an HTLC in support of route blinding"
    url: /en/newsletters/2023/06/28/#lnd-7710

  - title: "LDK #2120 adds support for finding a route to a receiver who is using blinded paths"
    url: /en/newsletters/2023/06/28/#ldk-2120

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Unannounced channels
    link: topic unannounced channels

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Rendez-vous routing**, **hidden destinations**, and **blinded paths** are
  names for techniques that allow an LN node to send a payment to an
  unannounced node without learning where that node is in the
  network topology or what channels it shares with other nodes.

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
