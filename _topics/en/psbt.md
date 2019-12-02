---
title: Partially-signed bitcoin transactions (PSBTs)

aliases:
  - BIP174

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Partially-Signed Bitcoin Transactions (PSBTs)** are a data format
  that allows wallets and other tools to exchange information about a
  Bitcoin transaction and the signatures necessary to complete it.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  A PSBT can be created that identifies a set of UTXOs to spend and a
  set of outputs to receive that spent value.  Then information about
  each UTXO that's necessary to generate a signature for it can added,
  possibly by a separate tool, such as the UTXO's script or its precise
  bitcoin value.

  The PSBT can then be copied by any means to a program that can sign it.  For
  multisig wallets or cases where different wallets control different
  inputs, this last step can be repeated multiple times by different
  programs on different copies of the PSBT.  Multiple PSBTs each with
  one or more necessary signatures can be integrated into a single
  PSBT later.  Finally, that fully-signed PSBT can be converted into a
  complete ready-to-broadcast transaction.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP174

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: PSBT discussion
    url: /en/newsletters/2018/07/03/#bip174-discussion
    date: 2018-07-03

  - title: Features included in Bitcoin Core 0.17
    url: /en/newsletters/2018/07/10/#bip174
    date: 2018-07-10

  - title: New Bitcoin Core RPCs for initial PSBT support
    url: /en/newsletters/2018/07/24/#bip174-partially-signed-bitcoin-transaction-psbt-support-merged
    date: 2018-07-24

  - title: Three new Bitcoin Core RPCs for managing PSBTs
    url: /en/newsletters/2019/02/19/#bitcoin-core-13932
    date: 2019-02-19

  - title: Discussion of PSBT extension fields
    url: /en/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts
    date: 2019-03-12

  - title: PSBT enhancements included in Bitcoin Core 0.18
    url: /en/newsletters/2019/05/07/#more-psbt-tools-and-refinements
    date: 2019-05-07

  - title: Update to the utxoupdatepsbt RPC in Bitcoin Core
    url: /en/newsletters/2019/07/10/#bitcoin-core-15427
    date: 2019-07-10

  - title: Modifying BIP174 for extensibility
    url: /en/newsletters/2019/08/07/#bip174-extensibility
    date: 2019-08-07

  - title: Range of identifiers allocated to proprietary PSBT extensions
    url: /en/newsletters/2019/11/13/#bips-849
    date: 2019-11-13

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Output Script Descriptors
    link: topic descriptors
  - title: Miniscript
    link: topic miniscript
---
