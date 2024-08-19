---
title: Testnet

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Testnet3
  - Testnet4

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Developer Tools

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: High block production rate on testnet leading to degradation of service
    url: /en/newsletters/2018/07/03/#testnet-high-block-production-rate

  - title: Discussion of resetting testent
    url: /en/newsletters/2018/09/04/#discussion-of-resetting-testnet

  - title: CVE-2018-17144 duplicate inputs bug exploited on testnet
    url: /en/newsletters/2018/10/02/#cve-2018-17144-duplicate-inputs-bug-exploited-on-testnet

  - title: "Open source release of esplora, a block explorer supporting testnet"
    url: /en/newsletters/2018/12/11/#modern-block-explorer-open-sourced

  - title: "Feedback requested on signet, an alternative to testnet"
    url: /en/newsletters/2019/03/12/#feedback-requested-on-signet

  - title: "C-Lightning #3268 changes the default network from Bitcoin testnet to Bitcoin mainnet"
    url: /en/newsletters/2019/12/04/#c-lightning-3268

  - title: "BOLTs #682 updates `init` message to prevent mainnet nodes from connecting to testnet nodes"
    url: /en/newsletters/2020/02/26/#bolts-682

  - title: "Question: will there by a testnet4?"
    url: /en/newsletters/2020/08/26/#will-there-be-a-testnet4-or-do-we-not-need-a-testnet-reset-once-we-have-signet

  - title: "C-Lightning #3763 adds a new RPC used to open a channel to every public testnet LN node"
    url: /en/newsletters/2020/09/16/#c-lightning-3763

  - title: "Bitcoin PR review club on signet with questions and answers about testnet"
    url: /en/newsletters/2020/10/14/#bitcoin-core-pr-review-club

  - title: "Instructions for creating taproot transactions on testnet"
    url: /en/newsletters/2021/10/20/#testing-taproot

  - title: "Software incorrectly implementing compact block filtering failed on testnet"
    url: /en/newsletters/2021/11/10/#additional-compact-block-filter-verification

  - title: "Bitcoin Core #23882 updates documentation about testnet3 to mention the BIP30 problem"
    url: /en/newsletters/2022/01/12/#bitcoin-core-23882

  - title: "Bitcoin Core #18554 prevents the same wallet from being used on mainnet and testnet"
    url: /en/newsletters/2022/05/04/#bitcoin-core-18554

  - title: "BOLTs #968 adds default TCP ports for nodes using Bitcoin testnet and signet"
    url: /en/newsletters/2022/06/01/#bolts-968

  - title: "Question about why both testnet and signet use the `tb1` bech32 address prefix?"
    url: /en/newsletters/2023/01/25/#why-doesn-t-signet-use-a-unique-bech32-prefix

  - title: "Service bit for Utreexo set for testing on testnet and signet"
    url: /en/newsletters/2023/03/15/#service-bit-for-utreexo

  - title: "Bitcoin Core #28354 begins rejecting non-standard transactions by default on testnet"
    url: /en/newsletters/2023/09/06/#bitcoin-core-28354

  - title: "Core Lightning 24.02 includes the fix for a transaction parsing bug on testnet"
    url: /en/newsletters/2024/02/28/#core-lightning-24-02

  - title: "Discussion about resetting and modifying testnet"
    url: /en/newsletters/2024/04/10/#discussion-about-resetting-and-modifying-testnet

  - title: "CoreDev.tech Berlin event with discussion about testnet4"
    url: /en/newsletters/2024/05/01/#coredev-tech-berlin-event

  - title: "BIP and experimental implementation of testnet4"
    url: /en/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4

  - title: "Bitcoin Core PR Review Club about testnet4"
    url: /en/newsletters/2024/07/12/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #29775 adds a `testnet4` configuration option"
    url: /en/newsletters/2024/08/09/#bitcoin-core-29775

  - title: "BIPs #1601 adds BIP94 specifying testnet4"
    url: /en/newsletters/2024/08/09/#bips-1601

  - title: "New time warp attack discovered during analysis of testnet4's attempted time warp fix"
    url: /en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4

  - title: "New CPUNet testnet announced with a modified PoW algorithm designed for CPU-only mining"
    url: /en/newsletters/2024/08/23/#cpunet-testnet-announced

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Signet
    link: topic signet

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Testnet** is a testing network included with Bitcoin Core and
  supported by many other Bitcoin applications.  **Testnet3** is the
  longest-running incarnation of testnet as of 2024, with **testnet4**
  currently being a recently started replacement.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
