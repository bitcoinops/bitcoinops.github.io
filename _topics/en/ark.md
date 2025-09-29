---
title: Ark protocol

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: ark

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:

  - title: "Arkade implementation"
    link: https://github.com/arkade-os

  - title: "Arkade technical documentation"
    link: https://docs.arkadeos.com

  - title: "Second implementation"
    link: https://codeberg.org/ark-bitcoin

  - title: "Second technical documentation"
    link: https://docs.second.tech/

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposal for a managed joinpool protocol
    url: /en/newsletters/2023/05/31/#proposal-for-a-managed-joinpool-protocol
    feature: true

  - title: Improving LN scalability with covenants in a similar way to Ark
    url: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability

  - title: "Implementation of Ark demonstrated on mainnet"
    url: /en/newsletters/2024/10/18/#bark-ark-implementation-announced

  - title: "Ark Wallet SDK released"
    url: /en/newsletters/2025/02/21/#ark-wallet-sdk-released

  - title: "Bark implementation of Ark is now available on signet"
    url: /en/newsletters/2025/03/21/#bark-launches-on-signet

  - title: "Summary and criticism of CTV + CSFS benefits for Ark"
    url: /en/newsletters/2025/04/04/#ark

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Joinpools
    link: topic joinpools

  - title: Covenants
    link: topic covenants

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  In the **Ark protocol**, a large number of users trustlessly share onchain UTXOs
  using trees of pre-signed, offchain transactions. By sharing UTXOs and transacting
  offchain, Ark users can spread the cost of onchain fees across multiple participants,
  minimizing individual transaction costs while maintaining self-custody of their bitcoin.

---
Ark transaction trees are constructed periodically through an interactive
process known as "rounds". Each round involves multiple users and a counterparty
(an Ark operator), who together construct and sign the transaction tree, then
broadcast the root transaction onchain. Users securely store their branch and
leaf transactions offchain. This package of offchain transactions is known as a
VTXO (virtual UTXO), which serves as the core unit of value on Ark.

To unilaterally withdraw bitcoin from Ark, a user broadcasts their branch and
leaf transactions in sequence, ultimately releasing their portion of the shared
UTXO to an onchain output under their sole control. However, under normal
operations, users will typically prefer cooperative exits, where they spend
their VTXO to receive an onchain UTXO from the Ark operator.

VTXOs "expire" according to an absolute timelock. After this timelock expires,
both the Ark operator and users can unilaterally spend the bitcoin. To maintain
trustlessness, users must ensure their VTXOs are spent into a new transaction
tree before expiry. This expiry mechanism allows the Ark operator to efficiently
recover liquidity that has been allocated to previous rounds and external
spending operations.

Payments between Ark users are handled as offchain, pre-signed extensions of the
transaction tree. Each payment transaction requires co-signatures from both the
sender and the Ark operator, meaning receivers must trust that the sender will
not collude with the operator to double-spend.

Users can chain these payments by spending a received VTXO before it's included
in a new round. In payment chains, any sender in the chain could collude with
the operator to double-spend the entire chain.

Upon receiving a VTXO, users can either roll it into a new round to regain
trustlessness, or spend it to another user before the expiry deadline.

Ark can be implemented on Bitcoin without requiring consensus changes, but would
support significantly more users—and achieve greater fee efficiency—if covenant
features like [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] were added
to Bitcoin.

{% include references.md %}
{% include linkers/issues.md issues="" %}
