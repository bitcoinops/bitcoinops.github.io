---
title: Segregated witness

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: segwit

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP141 segregated witness
      link: BIP141

    - title: BIP143 verification of signatures in spends of segwit v0 witness programs
      link: BIP143

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Temporary reduction in segwit block production
    url: /en/newsletters/2018/11/06/#temporary-reduction-in-segwit-block-production

  - title: "Bitcoin Core #14454 adds support to the importmulti RPC for segwit addresses and scripts"
    url: /en/newsletters/2018/11/06/#bitcoin-core-14454

  - title: "Bitcoin Core #14811 updates the getblocktemplate RPC to require that the segwit flag be passed"
    url: /en/newsletters/2019/01/08/#bitcoin-core-14811

  - title: "Question: Are there still miners or mining pools which refuse to implement SegWit?"
    url: /en/newsletters/2019/04/30/#are-there-still-miners-or-mining-pools-which-refuse-to-implement-segwit

  - title: "Bitcoin Core #14039 causes Bitcoin Core to reject legacy transactions encoded as segwit"
    url: /en/newsletters/2019/04/30/#bitcoin-core-14039

  - title: "Bitcoin Core #15846 relays and mines transactions paying any segwit address version"
    url: /en/newsletters/2019/04/30/#bitcoin-core-15846

  - title: Fee overpayment attack on multi-input segwit transactions
    url: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions

  - title: "BIPs #933 adds BIP339 for transaction relay announcement using segwit wtxids"
    url: /en/newsletters/2020/07/01/#bips-933

  - title: "Bitcoin Core #18044 adds support for announcing and requesting transactions by their segwit wtxid"
    url: /en/newsletters/2020/07/29/#bitcoin-core-18044

  - title: "BIPs #947 updates the BIP325 specification of signet to allow segwit-style virtual transactions"
    url: /en/newsletters/2020/08/05/#bips-947

  - title: "Bitcoin Core #21009 removes logic needed to upgrade a pre-segwit node to segwit"
    url: /en/newsletters/2021/05/05/#bitcoin-core-21009

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Taproot
    link: topic taproot

  - title: Bech32 addresses
    link: topic bech32

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Segregated witness** (segwit) was a soft fork that activated in 2017.

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
