---
title: Client-side validation

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - RGB
  - Taro
  - Taproot Assets

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Taro transferrable token scheme"
    url: /en/newsletters/2022/04/13/#transferable-token-scheme

  - title: "Update on RGB"
    url: /en/newsletters/2023/04/19/#rgb-update

  - title: "Specifications published for taproot assets"
    url:  /en/newsletters/2023/09/13/#specifications-for-taproot-assets

  - title: "Taproot Assets v0.4.0-alpha released"
    url: /en/newsletters/2024/08/23/#taproot-assets-v0-4-0-alpha-released

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Pay to Contract (P2C)"
    link: topic p2c

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Client-side validation protocols** allow a Bitcoin transaction to
  commit to some data whose validity is determined separate from the
  validity of the transaction under Bitcoin's consensus rules.  The
  client-side validation can take advantage of consensus rules, such as
  only allowing an output to be spent once within a valid block chain,
  but it may also impose additional rules known only to those interested
  in the validation.

---
A conceptually simple client-side validation protocol might assign an
off-chain state (like an amount of owned tokens) with a particular UTXO.
Only the set of validators needs to know
about that assignment; it does not need to be published anywhere public, such as the blockchain.
When the UTXO is spent, the
user can update the state and use spending transactions
to assign the new state to a new UTXO. This mechanism is known as
**single-use seals**, and it leverages anti-double-spending property of bitcoin.

As an example, if Alice
currently controls the UTXO associated with the token and Bob wants to
buy it from her, she can provide him with evidence of the original
assignment and then he can use his validated copy of the block chain
plus client-side validation to verify the history of every transfer of the
token leading up to Alice.  He can also verify that a transaction
created by Alice is correctly formatted to assign the token to a UTXO
that Bob controls.

**[RGB][]** is a client-side validation protocol for working with arbitrary
reachable state and Turing-complete state evolution rules. It uses
taproot-embedded OP_RETURN commitments (named **tapret**) to allow
transactions to commit to smart contract state.

**[Taproot Assets][]**, formerly called **Taro**, is a protocol heavily
inspired by RGB that uses [taproot][topic taproot]'s commitment
structure to allow transactions to commit to tokens. Unlike RGB, it
does not allow state types other than token and doesn't have Turing
completeness.
Taproot's construction itself derives from pay-to-contract.  As the name
suggests, initial protocol development is specifically focused on the
transfer of assets (that is, digital tokens that represent assets).

Both protocols are designed to be compatible with offchain transactions,
such as LN payments.  Similar to the lifecycle of an LN channel, an
onchain setup transaction is published that commits the tokens to the
mutual control of involved parties; a series of offchain transactions
each commits to the current allocation of the tokens between the
parties; and a transaction containing the final commitment is published
onchain.

Only wallets that want to support RGB or Taproot Assets need to
understand the protocol, and only a wallet that wants to send or receive
a specific token or other client-side validation contract needs to know
anything about that contract.  To everyone else, transactions created
with RGB and Taproot Assets look like regular Bitcoin transactions.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[rgb]: https://rgb.tech/
[taproot assets]: https://docs.lightning.engineering/the-lightning-network/taproot-assets/
