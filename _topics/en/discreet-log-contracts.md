---
title: Discreet Log Contracts (DLCs)

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: dlc

## Optional.  An entry will be added to the topics index for each alias
# aliases:
#   - TODO

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Discreet Log Contracts (DLCs)** are a contract protocol where two or
  more parties agree to exchange money dependent on the outcome of a
  certain event as determined by an oracle (or several oracles). After
  the event happens, the oracle publishes a commitment to the outcome of
  the event that the winning party can use to claim their funds. The
  oracle doesn’t need to know the terms of the contract (or even that
  a contract was made).

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Discreet log contracts (original paper)
      link: https://adiabat.github.io/dlc.pdf

    - title: Introduction to discreet log contracts
      link: https://github.com/discreetlogcontracts/dlcspecs/blob/master/Introduction.md

    - title: Discreet Log Contract Interoperability Specification
      link: https://github.com/discreetlogcontracts/dlcspecs/

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Drafting of an interoperability specification for DLCs
    url: /en/newsletters/2020/01/22/#protocol-specification-for-discreet-log-contracts-dlcs

  - title: Beta application announced for creating test DLC derivatives
    url: /en/newsletters/2020/08/19/#crypto-garage-announces-p2p-derivatives-beta-application-on-bitcoin

  - title: "2020 year-in-review: four compatible implementations of DLCs"
    url: /en/newsletters/2020/12/23/#dlc

  - title: New mailing list for discussion of DLC protocol development
    url: /en/newsletters/2021/02/10/#new-mailing-list-for-discreet-log-contracts

  - title: Discussion of fraud proofs in DLC v0 specification
    url: /en/newsletters/2021/03/03/#fraud-proofs-in-the-v0-discreet-log-contract-dlc-specification

  - title: Alpha release of Suredbits's DLC wallet
    url: /en/newsletters/2021/07/21/#suredbits-announces-dlc-wallet-alpha-release

  - title: Discussion about DLC specification breaking changes
    url: /en/newsletters/2021/09/29/#discussion-about-dlc-specification-breaking-changes

  - title: Mailing list post about DLCs over LN
    url: /en/newsletters/2021/11/10/#dlcs-over-ln

  - title: Discussion about how CTV or other covenant features could make DLCs much more efficient
    url: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script

  - title: Using Bitcoin-compatible BLS signatures for DLCs
    url: /en/newsletters/2022/08/17/#using-bitcoin-compatible-bls-signatures-for-dlcs

  - title: "Proposal for vault-enabling opcodes could also make DLCs much more efficient"
    url: /en/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes

  - title: "Wallet 10101 allows pooling funds between LN and DLCs"
    url: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Signature adaptors
    link: topic adaptor signatures
---
The transactions creating and settling the contract can be made
indistinguishable from many other Bitcoin transactions or they can be
executed within an LN channel. This makes DLCs more private and
efficient than other known oracle-based contract methods.
Additionally, DLCs are arguably more secure than earlier oracle-based
methods because an oracle that commits to a false result
generates clear evidence of fraud.

The original DLC construction was specific to [schnorr
signatures][topic schnorr signatures].  Later, a version was developed
to use [signature adaptors][topic adaptor signatures] that are
compatible with Bitcoin's existing ECDSA signature scheme.

**Note on spelling:** the name is a play on the *discrete* log
problem, which gives the protocol its [security][dlp], and DLC's
enhanced privacy making the contracts more *discreet*.  The spelling
used by the idea's original author and the DLC interoperability
specification is *discreet log contracts*.

{% include references.md %}
[dlp]: https://en.wikipedia.org/wiki/Discrete_logarithm#Cryptography
