---
title: Bitcoin URI scheme

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: bip21

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - BIP21
  - BIP321

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Invoicing
  - Wallet Collaboration Tools

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP21
      link: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki

    - title: BIP321
      link: https://github.com/bitcoin/bips/blob/master/bip-0321.mediawiki

    - title: "Revisiting BIP21"
      link: https://delvingbitcoin.org/t/revisiting-bip21/630

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: DNS-based payment instructions use BIP21 URIs
    url: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions
    date: 2024-02-21

  - title: Revisiting how BIP21 URIs are specified and used
    url: /en/newsletters/2024/03/06/#updating-bip21-bitcoin-uris
    date: 2024-03-06
    feature: true

  - title: BIP321 proposed as a modern URI scheme for payment instructions
    url: /en/newsletters/2025/05/02/#bips-1555
    date: 2025-05-02

  - title: BIP21 marked as replaced by BIP321
    url: /en/newsletters/2025/10/03/#bips-1911
    date: 2025-10-03

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
  **BIP21 bitcoin URI scheme** encodes a payment instruction in one string:
  the `bitcoin:` scheme, an address, and optional parameters such as an
  amount or a label.  The specification requires a legacy P2PKH address as
  the body, but wallets commonly put other address formats there, and the
  scheme is increasingly used to carry persistent identifiers for silent
  payments and offers.  BIP321 has been proposed as its replacement.
---
BIP21 defines `bitcoin:` URIs: the scheme, a Bitcoin address, and optional
parameters encoded like an HTTP query string, for example
`bitcoin:1Bob...?amount=0.001&label=...`.  The specification defines the
`amount`, `label` and `message` parameters; later proposals added parameters
for other address formats (such as `bech32m=`), for [payjoin][topic payjoin]
and for other payment protocols.

The specification requires the body to be a legacy P2PKH address, with other
address types passed as parameters.  That is not how the scheme is used in
practice: wallets routinely put bech32 or bech32m addresses in the body, and
some leave the body empty when only an alternative payment protocol is used.
The URI is also increasingly used to carry persistent identifiers, such as
those for [silent payments][topic silent payments] and [offers][topic
offers], which is a different job from naming an address.

In 2024, Josie Baker reopened the question of how the scheme is specified and
how it is actually used.  BIP321, merged in 2025, proposes a modern URI
scheme that describes payment instructions as a set of parameters rather
than a single address, and BIP21 has since been marked as replaced by it.

{% include references.md %}
{% include linkers/issues.md issues="" %}
