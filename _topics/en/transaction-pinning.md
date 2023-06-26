---
title: Transaction pinning

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Security Problems
  - Fee Management
  - Contract Protocols
  - Transaction Relay Policy

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Transaction pinning** is a method for making fee bumping
  prohibitively expensive by abusing node protections against
  attacks that can waste bandwidth, CPU, and memory.  This can make fee
  management more difficult in multiparty contract protocols (such as LN).

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: What is transaction pinning?
    url: /en/newsletters/2018/11/27/#what-is-transaction-pinning

  - title: Eltoo may not be entirely reliable because of transaction pinning
    url: /en/newsletters/2018/12/28/#april

  - title: Proposal to override some BIP125 RBF conditions to avoid pinning
    url: /en/newsletters/2019/06/12/#proposal-to-override-some-bip125-rbf-conditions

  - title: Discussion of attacks against LN, including transaction pinning
    url: /en/newsletters/2020/08/05/#chicago-meetup-discussion

  - title: Using attacks such as transaction pinning against eltoo
    url: /en/newsletters/2020/08/12/#discussion-about-eltoo-and-sighash-anyprevout

  - title: Pinning attacks against a coinswap protocol
    url: /en/newsletters/2020/09/09/#continued-coinswap-discussion

  - title: "Transaction fee sponsorship proposal to attempt to eliminate pinning"
    url: /en/newsletters/2020/09/23/#transaction-fee-sponsorship

  - title: "BOLT5 updated to prevent a transaction pinning attack"
    url: /en/newsletters/2020/12/16/#bolts-803

  - title: CVE-2021-31876 reduces expected cost of some pinning attacks
    url: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation

  - title: Idea to prevent pinning by allowing transaction to signal that descendant limits
    url: /en/newsletters/2022/03/16/#ideas-for-improving-rbf-policy

  - title: Idea to use transaction introspection to prevent RBF pinning
    url: /en/newsletters/2022/05/18/#using-transaction-introspection-to-prevent-rbf-pinning

  - title: Proposed relay of v3 transactions designed to avoid pinning attacks
    url: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty

  - title: Proposed ephemeral anchors to help mitigate pinning attacks
    url: /en/newsletters/2022/10/26/#ephemeral-anchors

  - title: Implementation of proposed ephemeral anchors to help prevent pinning attacks
    url: /en/newsletters/2022/12/07/#ephemeral-anchors-implementation

  - title: "Question about how to pin a transaction by requiring a fee bump pay a 500x fee"
    url: /en/newsletters/2023/04/26/#how-would-an-adversary-increase-the-required-fee-to-replace-a-transaction-by-up-to-500-times

  - title: Preventing coinjoin pinning with v3 transaction relay
    url: /en/newsletters/2023/06/28/#preventing-coinjoin-pinning-with-v3-transaction-relay

## Optional.  Same format as "primary_sources" above
see_also:
   - title: CPFP carve out
     link: topic cpfp carve out
---
Nodes such as Bitcoin Core that allow transactions to be replaced
(RBF) or packaged with higher-fee child transactions (CPFP) place
restrictions on those replacements in order to prevent various DoS
attacks.  However, when two or more people each have the ability to
fee bump a transaction, this makes it possible for one of them to
*pin* their version of a transaction at one of the limits and prevent
other participants from using fee bumping.

Some of the limits that can be abused to enable transaction pinning
include:

- **[BIP125][] RBF rule #3** requires a replacement transaction
  pay a higher absolute fee (not just feerate) than the sum of fees paid
  by the transaction being replaced and all of its children.  This can
  allow an attacker to attach a large and low-feerate transaction to
  the transaction they want to pin, forcing any fee bump to pay for the
  replacement of the large child transaction.  E.g., with the 2019
  Bitcoin Core defaults, an attacker can require an honest participant
  pay a minimum of 0.001 BTC to fee bump a transaction (or even
  greater amounts in some cases).  <!-- 0.001 BTC = 100,000 vbyte tx
  at minimum relay fee of 0.00001 BTC/kvB plus a tiny bit extra if the
  100k tx is replaced with a small tx.  Extended reasoning here:
  https://github.com/lightningnetwork/lightning-rfc/pull/688#issuecomment-549951387 -->

- **Maximum package size limitations** prevent CPFP from being used if
  a transaction has more than 101,000 vbytes of children or other
  descendants in a mempool, or has more than 25 descendants or
  ancestors.  This can allow an attacker to completely block fee
  bumping by creating the maximum amount of child transactions.  If
  the attacker has to create those transactions for other reasons
  (e.g. because they operate a service paying to users), this attack
  can be free.  For some two-party contract protocols (such as current
  LN), this is mitigated by [CPFP carve out][topic cpfp carve out].

{% include references.md %}
