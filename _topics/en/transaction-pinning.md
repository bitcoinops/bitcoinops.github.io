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
  management more difficult in multipart contract protocols (such as LN).

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
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
    pay a higher absolute fee (not just feerate) than the transaction
    being replaced and any of its children.  This can allow an attacker
    to attach a large and low-feerate transaction to the transaction
    they want to pin, forcing any fee bump to pay for the
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

## Optional.  Same format as "primary_sources" above
see_also:
   - title: CPFP carve out
     link: topic cpfp carve out
---
