---
title: Timelocks

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses
  - Contract Protocols
  - Transaction Relay Policy

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP65 `OP_CHECKLOCKTIMEVERIFY` for absolute timelocks in scripts
      link: BIP65

    - title: BIP68 relative timelocks using consensus-enforced sequence numbers
      link: BIP68

    - title: BIP112 `OP_CHECKSEQUENCEVERIFY` for relative timelocks in scripts
      link: BIP112

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: For BIP322 generic signed messages, unclear how to support timelocks
    url: /en/newsletters/2018/09/18/#bip322-generic-signed-message-format

  - title: Transaction pinning as a major challenge for protocols involving timelocks
    url: /en/newsletters/2018/12/04/#cpfp-carve-out

  - title: Lightning Loop announce, using submarine swaps with onchain timelocks
    url: /en/newsletters/2019/03/26/#loop-announced

  - title: Fidelity bonds based on long-term timelocks
    url: /en/newsletters/2019/07/31/#fidelity-bonds-for-improved-sybil-resistance

  - title: Using decrementing locktimes instead of eltoo for statechains
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo

  - title: New cross-chain coinswap construction that only requires timelocks on one chain
    url: /en/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap

  - title: One-block relative timelocks to prevent pinning issues in coinswaps
    url: /en/newsletters/2020/09/09/#continued-coinswap-discussion

  - title: Research into conflicts between timelocks and heightlocks
    url: /en/newsletters/2020/09/23/#research-into-conflicts-between-timelocks-and-heightlocks

  - title: "BOLTs #803 updates BOLT5 with recommendations for handling timelocks near maturity"
    url: /en/newsletters/2020/12/16/#bolts-803

  - title: Challenges related to timelocks when using CPFP fee bumping in LN
    url: /en/newsletters/2021/04/21/#using-anchor-outputs-by-default-in-lnd

  - title: "Soft fork proposal for fee-dependent timelocks"
    url: /en/newsletters/2024/01/03/#fee-dependent-timelocks

  - title: "BIP46 added for timelocked fidelity bonds"
    url: /en/newsletters/2024/07/19/#bips-1599

## Optional.  Same format as "primary_sources" above
see_also:
  - title: HTLCs
    link: topic HTLC

  - title: PTLCs
    link: topic PTLC

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Timelocks** are encumbrances that prevent a transaction or the spend of an
  output from being confirmed prior to a maturity time or block height.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
