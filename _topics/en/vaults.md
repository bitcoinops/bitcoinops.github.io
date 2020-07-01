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

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
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
    date: 2019-08-14

  - title: "2019 year-in-review: vaults without covenants"
    url: /en/newsletters/2019/12/28/#vaults
    date: 2019-12-28

  - title: "OP_CHECKTEMPLATEVERIFY (CTV) workshop discussion: using CTV with vaults"
    url: /en/newsletters/2020/02/12/#op-checktemplateverify-ctv-workshop
    date: 2020-02-12

  - title: Vault prototype written in Python
    url: /en/newsletters/2020/04/22/#vaults-prototype
    date: 2020-04-22

  - title: "Revault: an implementation of multiparty vaults"
    url: /en/newsletters/2020/04/29/#multiparty-vault-architecture
    date: 2020-04-29

  - title: Presentation of the Revault multiparty vault architecture
    url: /en/newsletters/2020/06/03/#the-revault-multiparty-vault-architecture
    date: 2020-06-03

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
