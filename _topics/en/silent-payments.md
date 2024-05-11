---
title: Silent payments

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Silent Payments
      link: https://gist.github.com/RubenSomsen/c43b79517e7cb701ebf77eec6dbb46b8

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Silent payments proposed
    url: /en/newsletters/2022/04/06/#delinked-reusable-addresses

  - title: Updated alternative to BIP47 reusable payment codes compared to silent payments
    url: /en/newsletters/2022/07/06/#updated-alternative-to-bip47-reusable-payment-codes

  - title: Updated silent payments PR
    url: /en/newsletters/2022/08/24/#updated-silent-payments-pr

  - title: "BIPs #1349 adds BIP351 for a payment protocol inspired by silent payments"
    url: /en/newsletters/2022/10/05/#bips-1349

  - title: "2022 year-in-review: silent payments"
    url: /en/newsletters/2022/12/21/#silent-payments

  - title: Summaries of Bitcoin Core developers in-person meeting
    url: /en/newsletters/2023/05/17/#summaries-of-bitcoin-core-developers-in-person-meeting

  - title: Draft BIP for silent payments
    url: /en/newsletters/2023/06/14/#draft-bip-for-silent-payments

  - title: "Bitcoin Core PR Review Club summary of #28122 adding silent payments"
    url: /en/newsletters/2023/08/09/#bitcoin-core-pr-review-club

  - title: "Proposal to add expiration metadata to silent payment addresses"
    url: /en/newsletters/2023/08/16/#adding-expiration-metadata-to-silent-payment-addresses

  - title: "Human readable payment instructions proposed that are compatible with silent payment addresses"
    url: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Output linking
    link: topic output linking

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Silent payments** are a type of payment that can be made to a
  unique onchain address for every payment even though the receiver
  provided the spender with a reusable (offchain) address.  This helps
  improve privacy.

---

Traditionally, a new address should be generated for every
payment. This is because when you receive several payments
to the same Bitcoin address, it is a given that the same
person or entity received all of those payments even if the outputs are later
spent in separate transactions. This is known as [address reuse][topic output linking].

Using a new address often requires a secure interaction between sender
and receiver so that the receiver can provide a fresh address everytime.
However, interaction is often infeasible and in many cases undesirable.

With silent payments, a receiver can generate a silent payment address
and make it publicly known, thus eliminating the need for interaction.
The sender can select one or more of their chosen inputs and use their
secret key(s) to derive the shared secret (together with public key of
the silent payment address), which is used to generate the destination.

The intended recipient detects the payment by scanning eligible transactions
in the blockchain, before performing an ECDH calculation with the summed
input public keys of the transaction and the scan key from their address.
This is the main downside in that it is more computationally expensive than
simply scanning the UTXO set for a `scriptPubKey` as in [BIP32][] style wallets.
Additionally, using silent payments in a collaborative setting is left for
future work, and it remains an open question whether this is provably secure.

{% include references.md %}
{% include linkers/issues.md issues="" %}
