---
title: LNURL

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Lightning Addresses

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network
  - Invoicing

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "LNURL Documents (LUDs)"
      link: https://github.com/lnurl/lud

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Discussion about a BIP70 replacement, including a version that works with LNURL"
    url: /en/newsletters/2021/03/03/#discussion-about-a-bip70-replacement

  - title: "Phoenix v1.4.12 adds support for the LNURL-pay protocol"
    url: /en/newsletters/2021/06/23/#phoenix-adds-lnurl-pay

  - title: "Stacker News launched with LNURL authentication"
    url: /en/newsletters/2021/07/21/#lightning-powered-news-site-stacker-news-launches

  - title: "Lightning Address identifiers announced based on LNURL"
    url: /en/newsletters/2021/09/22/#lightning-address-identifiers-announced

  - title: "BTCPay Server #3083 allows administrators to log in using LNURL authentication"
    url: /en/newsletters/2022/01/26/#btcpay-server-3083

  - title: "C-Lightning #5121 updates its `invoice` RPC for improved LNURL compatibility"
    url: /en/newsletters/2022/04/06/#c-lightning-5121

  - title: Large size of blinded paths may make them dependent on invoice protocols like LNURL or offers
    url: /en/newsletters/2022/06/15/#blinded-paths

  - title: Dicussion about how to make LNURL and offers compatible
    url: /en/newsletters/2022/06/15/#lnurl-plus-bolt12

  - title: "BTCPay Server #3709 adds support for pull payments to be received via a LNURL withdraw"
    url: /en/newsletters/2022/07/06/#btcpay-server-3709

  - title: Discussion about offers-compatible Lightning addresses
    url: /en/newsletters/2023/11/22/#offers-compatible-ln-addresses

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Offers
    link: topic offers

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **LNURL** is a set of protocols for communicating information using
  URLs and HTTPS.  Perhaps the most common use of LNURL is transferring
  BOLT11 invoices.  A related protocol is **Lightning Addresses** which
  allow transforming a static identifier that looks like an RFC822 email
  address into a BOLT11 invoice.
---
An upside of LNURL is their flexibility and use of widely understood
HTTP: a web developer can use their existing skills to interact with LN
clients.  This allows web developers to handle business logic on the web
side of their application and only use a LN node to send and receive
payments.  It also makes it easy for web developers to use LN node
capabilities in new and interesting ways, such as LNURL-based
authentication.

A downside of LNURL is that hosted LNURL services may learn information
about their users' payments and other actions.  For example, many
Lightning Addresses are managed by centralized services that have the
capability to intercept payments and potentially track how much a user
receives through their Lightning Address.  For this reason, alternatives
to LNURL or additional layers on top of it have been proposed.

{% include references.md %}
{% include linkers/issues.md issues="" %}
