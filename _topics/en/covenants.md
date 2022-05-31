---
title: Covenants

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Covenants** are a category of proposed changes to Bitcoin's
  consensus rules that would allow a script to prevent an authorized
  spender from spending to certain other scripts.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: Enhancing Bitcoin transactions with covenants
    link: https://fc17.ifca.ai/bitcoin/papers/bitcoin17-final28.pdf

  - title: BIP119 OP_CHECKTEMPLATEVERIFY proposal
    link: https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Scaling Bitcoin Tokyo 2018, Script Roundtable: OP_CHECKSIGFROMSTACK"
    url: /en/newsletters/2018/10/09/#discussion-the-evolution-of-bitcoin-script

  - title: "New proposed opcode: OP_CHECKOUTPUTSHASHVERIFY"
    url: /en/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments

  - title: "CoreDev.tech discussion: potential script changes"
    url: /en/newsletters/2019/06/12/#potential-script-changes

  - title: Bitcoin vaults without covenants
    url: /en/newsletters/2019/08/14#bitcoin-vaults-without-covenants

  - title: OP_CHECKOUTPUTSHASHVERIFY renamed OP_CHECKTEMPLATEVERIFY and updated
    url: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv

  - title: Suggested changes to OP_CHECKTEMPLATEVERIFY proposal
    url: /en/newsletters/2019/12/18/#proposed-changes-to-bip-ctv

  - title: "2019 year-in-review: OP_CHECKTEMPLATEVERIFY"
    url: /en/newsletters/2019/12/28/#ctv

  - title: OP_CHECKTEMPLATEVERIFY workshop report
    url: /en/newsletters/2020/02/12/#op-checktemplateverify-ctv-workshop

  - title: Vault prototype using pre-signed transactions
    url: /en/newsletters/2020/04/22/#vaults-prototype

  - title: Demo implementation of a multisig vaults covenant prototype
    url: /en/newsletters/2020/04/29/#multiparty-vault-architecture

  - title: Discussion about how Simplicity could be used for covenants
    url: /en/newsletters/2020/08/05/#bip-taproot

  - title: "Replicating the `OP_CSFS` covenant-enabling opcode with `OP_CAT` and schnorr signatures"
    url: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat

  - title: "OP_TAPLEAF_UPDATE_VERIFY opcode proposed with a taproot-native covenant design"
    url: /en/newsletters/2021/09/15/#covenant-opcode-proposal

  - title: "Proposal for composable `OP_TX` opcode useful for constructing covenants"
    url: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash

  - title: "Proposed `OP_EVICT` opcode to make covenants more efficient"
    url: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership

  - title: "Discussion about the risks of allowing recursive covenants"
    url: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness

  - title: "When would enabling `OP_CAT` allow recursive covenants?"
    url: /en/newsletters/2022/05/18/#when-would-enabling-op-cat-allow-recursive-covenants

  - title: "Updated `OP_TX` opcode useful for constructing covenants"
    url: /en/newsletters/2022/05/18/#updated-op-tx-proposal

  - title: "Discussion about Miner Extractable Value (MEV) risk from recursive covenants"
    url: /en/newsletters/2022/05/25/#miner-extractable-value-discussion

## Optional.  Same format as "primary_sources" above
see_also:
  - title: An early description of covenants in Bitcoin
    link: https://bitcointalk.org/index.php?topic=278122.0

  - title: OP_CHECKSIGFROMSTACK
    link: topic op_checksigfromstack

  - title: OP_CHECKTEMPLATEVERIFY
    link: topic op_checktemplateverify

  - title: Vaults
    link: topic vaults
---
> "In the context of Bitcoin, the most useful definition of
> covenant is that it's when the scriptPubKey of a UTXO restricts the
> scriptPubKey in the output(s) of a tx spending that UTXO."  ---Anthony
> Towns ([source][towns covenant definition])

For example, a covenant may normally only allow spending to a
whitelisted set of scripts, such as returning bitcoins to the user's own
balance or spending to a staging address that only allows spending to
any arbitrary address after a period of time.

{% include references.md %}
[towns covenant definition]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019795.html
