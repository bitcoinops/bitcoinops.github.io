---
title: Silent payments

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP352 silent payments
      link: BIP352

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

  - title: Notes from Bitcoin developer discussion about multiple aspects of silent payments
    url: /en/newsletters/2024/05/01/#coredev-tech-berlin-event

  - title: "BIPs #1458 adds BIP352 for silent payments"
    url: /en/newsletters/2024/05/17/#bips-1458

  - title: "Discussion about using PSBTs with silent payments"
    url: /en/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments

  - title: "Continued discussion about using PSBTs with silent payments"
    url: /en/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments

  - title: "BIPs #1620 and #1622 make minor updates to the BIP352 specification of silent payments"
    url: /en/newsletters/2024/06/28/#bips-1620

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

Traditionally, a user who receives payments should generate a new Bitcoin
address for every payment. This is because receiving multiple payments
to the same address reveals that the same user received those payments,
even if the outputs are later spent in separate transactions.
This is known as [address reuse][topic output linking].

Using a new address often requires a secure interaction between sender
and receiver so that the receiver can provide a fresh address every time.
However, interaction is often infeasible and in many cases undesirable.

With silent payments, a receiver can generate and publish a single silent
payment address, eliminating the need for interaction.
The sender then selects one or more of their chosen inputs and uses their
secret key(s) together with public key of the silent payment address to
derive a shared secret which is used to generate the destination.

The intended recipient detects the payment by scanning transactions
in the blockchain and performing an ECDH calculation with the summed
input public keys of the transaction and the scan key from their address.
The main downside is that it is more computationally expensive than
simply scanning the UTXO set for a `scriptPubKey` as in [BIP32][]-style wallets.
Additionally, using silent payments in a collaborative setting such as
[coinjoining][topic coinjoin] is left for future work, and it remains an open
question whether such collaboration can be made provably secure.

{% include references.md %}
{% include linkers/issues.md issues="" %}
