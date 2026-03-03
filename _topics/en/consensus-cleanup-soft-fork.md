---
title: Consensus cleanup soft fork
shortname: consensus cleanup

title-aliases:
  - BIP54

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Soft Forks
  - Scripts and Addresses
  - Mining

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Consensus cleanup soft fork** is a proposal to address several
  issues in Bitcoin's consensus rules that date back to the original
  version of Bitcoin released in 2009.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP54

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Cleanup soft fork proposal
    url: /en/newsletters/2019/03/05#cleanup-soft-fork-proposal

  - title: Consensus cleanup background
    url: /en/newsletters/2019/03/05#appendix-consensus-cleanup-background

  - title: "Consensus cleanup discussion: codeseparator & sighash types"
    url: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion

  - title: "CoreDev.tech discussion: cleanup soft fork"
    url: /en/newsletters/2019/06/12/#cleanup-discussion

  - title: "2019 year-in-review: consensus cleanup soft fork proposal"
    url: /en/newsletters/2019/12/28/#cleanup

  - title: Discussion of minimum safe transaction sizes
    url: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion

  - title: "Renewed discussion of consensus cleanup soft fork"
    url: /en/newsletters/2024/04/03/#revisiting-consensus-cleanup

  - title: "Question: where exactly is the 'off-by-one' difficulty bug and how does it relate to time warp?"
    url: /en/newsletters/2024/04/24/#where-exactly-is-the-off-by-one-difficulty-bug

  - title: Notes from Bitcoin developer discussion about consensus cleanup
    url: /en/newsletters/2024/05/01/#coredev-tech-berlin-event

  - title: "Discussion about mitigating merkle tree vulnerabilities in the proposed consensus cleanup soft fork"
    url: /en/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities

  - title: "Discussion about fixing Murch-Zawy time warp and duplicate transactions in consensus cleanup"
    url: /en/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal

  - title: "Announcement of updates to the consensus cleanup soft fork proposal"
    url: /en/newsletters/2025/02/07/#updates-to-cleanup-soft-fork-proposal

  - title: "Draft BIP published for consensus cleanup"
    url: /en/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup

  - title: "BIPs #1800 merges BIP54, which specifies the consensus cleanup soft fork proposal"
    url: /en/newsletters/2025/05/09/#bips-1800

  - title: "Bitcoin Core #32155 updates the internal miner to comply with consensus cleanup requirements"
    url: /en/newsletters/2025/05/16/#bitcoin-core-32155

  - title: "BIPs #1760 merges BIP53, which specifies a consensus change to forbid 64 byte transactions"
    url: /en/newsletters/2025/05/30/#bips-1760

  - title: "Bitcoin Core #32521 makes legacy transactions with more than 2500 sigops non-standard"
    url: /en/newsletters/2025/07/25/#bitcoin-core-32521

  - title: "BIP54 implementation and test vectors"
    url: /en/newsletters/2025/11/07/#bip54-implementation-and-test-vectors

  - title: "Discussion of BIP54's timewarp fix and its impact on the 2106 block timestamp overflow issue"
    url: /en/newsletters/2026/01/02/#relax-bip54-timestamp-restriction-for-2106-soft-fork

  - title: "Addressing remaining points on BIP54"
    url: /en/newsletters/2026/02/06/#addressing-remaining-points-on-bip54

  - title: "Bitcoin Inquisition adds an implementation of the BIP54 consensus cleanup soft fork rules"
    url: /en/newsletters/2026/02/13/#bitcoin-inquisition-99

## Optional.  Same format as "primary_sources" above
see_also:
 - title: Soft fork activation
   link: topic soft fork activation

 - title: "CVE-2017-12842: fake SPV proofs using 64-byte transactions"
   link: "https://bitcoinops.org/en/topics/cve/#CVE-2017-12842"
---
After a prior draft in 2019 was deferred, renewed efforts since 2023
substantiated into a concrete proposal, BIP54: Consensus Cleanup. The soft fork
proposal advocates for fixing the following four issues.

- **Time warp bug**: an [off-by-one error][topic time warp] in the difficulty adjustment algorithm
  permits a majority hashrate attacker to arbitrarily increase block cadence.
  This is mitigated by limiting the permitted timestamps for the first block
  in difficulty periods and requiring that an entire difficulty period has
  a non-negative duration.

- **Slow-to-validate blocks**: attackers may use uncommon script patterns to compose blocks
  that are prohibitively expensive to process. These forms of malicious
  transactions are prevented by introducing limits on signature operations
  that curb this malicious use but far exceed organic uses.

- **Merkle tree weakness**: the construction of the merkle tree on a block’s
  transactions treats transactions with witness-stripped sizes of
  64 bytes indistinguishably from inner nodes. Forbidding such transactions prevents two ways of
  [misrepresenting the content][topic merkle tree vulnerabilities] of a valid block.

- **Duplicate transaction vector**: Some early coinbase transactions exhibit
  patterns that would allow them to be [replayed][topic duplicate transactions] in future blocks. Requiring
  that the locktime of coinbase transactions is set to a specific value based
  on the block height enforces that future coinbase transactions are unique
  without needing to enforce BIP30 checks for those blocks.

{% include references.md %}
