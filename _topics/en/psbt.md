---
title: Partially signed bitcoin transactions
shortname: psbt

aliases:
  - BIP174
  - PSBT

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Partially Signed Bitcoin Transactions (PSBTs)** are a data format
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
  PSBT later.  Finally, that fully signed PSBT can be converted into a
  complete ready-to-broadcast transaction.

  The basic details about PSBTs and a specification for the original
  version 0 PSBTs are published in [BIP174][].  Version 2 PSBTs are
  described in [BIP370][].  There are no version 1 PSBTs.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP174
    - title: BIP370

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: PSBT discussion
    url: /en/newsletters/2018/07/03/#bip174-discussion

  - title: Features included in Bitcoin Core 0.17
    url: /en/newsletters/2018/07/10/#bip174

  - title: New Bitcoin Core RPCs for initial PSBT support
    url: /en/newsletters/2018/07/24/#bip174-partially-signed-bitcoin-transaction-psbt-support-merged

  - title: Three new Bitcoin Core RPCs for managing PSBTs
    url: /en/newsletters/2019/02/19/#bitcoin-core-13932

  - title: Discussion of PSBT extension fields
    url: /en/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts

  - title: PSBT enhancements included in Bitcoin Core 0.18
    url: /en/newsletters/2019/05/07/#more-psbt-tools-and-refinements

  - title: Update to the utxoupdatepsbt RPC in Bitcoin Core
    url: /en/newsletters/2019/07/10/#bitcoin-core-15427

  - title: Modifying BIP174 for extensibility
    url: /en/newsletters/2019/08/07/#bip174-extensibility

  - title: Range of identifiers allocated to proprietary PSBT extensions
    url: /en/newsletters/2019/11/13/#bips-849

  - title: "Bitcoin Core #16373 allows the bumpfee RPC used for RBF to return a PSBT"
    url: /en/newsletters/2020/01/15/#bitcoin-core-16373

  - title: "Bitcoin Core #17492 allows the wallet GUI to place a PSBT in the clipboard"
    url: /en/newsletters/2020/01/29/#bitcoin-core-17492

  - title: CKBunker using PSBTs for an HSM
    url: /en/newsletters/2020/02/19/#ckbunker-using-psbts-for-an-hsm

  - title: "Bitcoin Core #17264 includes HD derivation path in PSBTs by default"
    url: /en/newsletters/2020/03/04/#bitcoin-core-17264

  - title: "LND #4079 adds support for funding channels with PSBTs"
    url: /en/newsletters/2020/04/08/#lnd-4079

  - title: "Bitcoin Core #17509 allows saving and loading PSBTs from files"
    url: /en/newsletters/2020/04/29/#bitcoin-core-17509

  - title: "LND 0.10 presentation: funding channels using PSBTs"
    url: /en/newsletters/2020/05/06/#lnd-v0-10

  - title: LND 0.10.0-beta released with support for funding channels using PSBTs
    url: /en/newsletters/2020/05/06/#lnd-0-10-0-beta

  - title: "C-Lightning #3738 adds initial support for creating PSBTs"
    url: /en/newsletters/2020/05/27/#c-lightning-3738

  - title: "Bitcoin Core #18027 adds GUI support for signing & broadcasting PSBTs"
    url: /en/newsletters/2020/06/24/#bitcoin-core-18027

  - title: "Bitcoin Core #19215 adds additional data to PSBTs for segwit inputs"
    url: /en/newsletters/2020/07/08/#bitcoin-core-19215

  - title: "C-Lightning #3775 adds RPCs for creating and using PSBTs"
    url: /en/newsletters/2020/07/08/#c-lightning-3775

  - title: "Electrum 4.0.1 replaces their partial transactions format with PSBTs"
    url: /en/newsletters/2020/07/22/#electrum-adds-lightning-network-and-psbt-support

  - title: Initial release of Lily Wallet supports PSBTs
    url: /en/newsletters/2020/07/22/#lily-wallet-initial-release

  - title: "Field Report: Using PSBT at River Financial"
    url: /en/river-descriptors-psbt/
    date: 2020-07-29

  - title: "LND #4455 makes it safe to batch open channels using PSBTs"
    url: /en/newsletters/2020/07/29/#lnd-4455

  - title: BIP174 specification of PSBT updated in response to fee overpayment attack
    url: /en/newsletters/2020/08/05/#bips-948

  - title: "Bitcoin Core #18654 adds new RPC specifically for RBF fee bumping PSBTs"
    url: /en/newsletters/2020/08/19/#bitcoin-core-18654

  - title: "BIPs #955 updates BIP174 PSBT to standardize supplying hash preimages"
    url: /en/newsletters/2020/08/26/#bips-955

  - title: Joinmarket 0.7.0 adds support for PSBTs
    url: /en/newsletters/2020/09/23/#joinmarket-0-7-0-adds-bip78-psbt

  - title: "LND #4389 adds a new `psbt` wallet subcommand for creating & signing PSBTs"
    url: /en/newsletters/2020/10/07/#lnd-4389

  - title: A new backwards-incompatible version of PSBT is proposed
    url: /en/newsletters/2020/12/16/#new-psbt-version-proposed

  - title: New PSBT Toolkit software provides GUI for working with PSBTs
    url: /en/newsletters/2020/12/16/#psbt-toolkit-v0-1-2-released

  - title: "LND 0.12.0-beta adds a new `psbt` wallet subcommand for PSBTs"
    url: /en/newsletters/2021/01/27/#lnd-0-12-0-beta

  - title: "BIPs #988 updates BIP174 to require output fields be initialized"
    url: /en/newsletters/2021/02/10/#bips-988

  - title: "BIPs #1055 updatse BIP174 with new versioning information"
    url: /en/newsletters/2021/02/10/#bips-1055

  - title: "C-Lightning #4428 switches an RPC to accepting PSBTs for enhance validation"
    url: /en/newsletters/2021/03/24/#c-lightning-4428

  - title: "BIPs #1059 publishes the draft specification for v2 PSBTs as BIP370"
    url: /en/newsletters/2021/03/24/#bips-1059

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Output Script Descriptors
    link: topic descriptors
  - title: Miniscript
    link: topic miniscript
---
