---
title: Vaults

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Security Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Vault** are a type of covenant that require two separate
  transactions to appear in two different blocks in order for a user to
  spend money from their wallet.  The first transaction signals that
  someone is attempting to spend the money and gives the user a chance
  to block the second transaction that completes the spend.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Möser-Eyal-Sirer vault proposal
      link: https://hackingdistributed.com/2016/02/26/how-to-implement-secure-bitcoin-vaults/

    - title: Vaults using OP_CHECKSIGFROMSTACK and OP_CAT
      link: https://blockstream.com/2016/11/02/en-covenants-in-elements-alpha/

    - title: Vaults without changing Bitcoin consensus rules
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017229.html

    - title: Custody Protocols Using Bitcoin Vaults
      link: https://arxiv.org/abs/2005.11776

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Bitcoin vaults without covenants & weaknesses in previous vault proposals"
    url: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants

  - title: "2019 year-in-review: vaults without covenants"
    url: /en/newsletters/2019/12/28/#vaults

  - title: "OP_CHECKTEMPLATEVERIFY (CTV) workshop discussion: using CTV with vaults"
    url: /en/newsletters/2020/02/12/#op-checktemplateverify-ctv-workshop

  - title: Vault prototype written in Python
    url: /en/newsletters/2020/04/22/#vaults-prototype

  - title: "Revault: an implementation of multiparty vaults"
    url: /en/newsletters/2020/04/29/#multiparty-vault-architecture

  - title: Presentation of the Revault multiparty vault architecture
    url: /en/newsletters/2020/06/03/#the-revault-multiparty-vault-architecture

  - title: Service proposed for storing presigned vault transactions
    url: /en/newsletters/2020/07/01/#proposed-service-for-storing-relaying-and-broadcasting-presigned-transactions

  - title: "2020 year in review: vaults"
    url: /en/newsletters/2020/12/23/#vaults

  - title: "Making hardware wallets compatible with advanced features, like vaults"
    url: /en/newsletters/2021/01/20/#making-hardware-wallets-compatible-with-more-advanced-bitcoin-features

  - title: "Using schnorr signatures plus `OP_CAT` to create vaults"
    url: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat

  - title: "Updating vaults for taproot"
    url: /en/newsletters/2021/09/08/#preparing-for-taproot-12-vaults-with-taproot

  - title: "OP_TAPLEAF_UPDATE_VERIFY opcode proposed that would simplify some vault designs"
    url: /en/newsletters/2021/09/15/#covenant-opcode-proposal

  - title: "Should vaults always have a cooperative taproot keypath spend?"
    url: /en/newsletters/2021/10/13/#vaults

  - title: Design and code for a CTV-based vault
    url: /en/newsletters/2022/03/16/#continued-ctv-discussion

  - title: Proposal to use simple vaults as one benchmark for comparing different covenant designs
    url: /en/newsletters/2022/04/27/#suggested

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Python-vaults
    link: https://github.com/kanzure/python-vaults

  - title: Revault multiparty vaults demo
    link: https://github.com/re-vault/revault-demo

  - title: Bitcoin-vault
    link: https://github.com/JSwambo/bitcoin-vault

  - title: Covenants
    link: topic covenants
---
A vault protocol specifies a minimum amount of time or number of blocks that
must pass between the two transactions, giving the user that amount of
time to notice if someone stole their private key and is attempting to
steal their money.  If the user detects the theft attempt, most vault
designs also allow the user to either send the money to a safe address
that uses a more secure script or to permanently destroy the money
to prevent the thief from profiting from their attack.

Some vault designs rely on [covenants][topic covenants] that require
consensus changes to Bitcoin.  Other vault designs use existing
protocol features plus techniques such as signing transactions long
in advance of needing them and then destroying the means to sign
alternative transactions (either by securely deleting the signing key
or by using multisig to ensure multiple independent keys would need to
be compromised).

{% include references.md %}
