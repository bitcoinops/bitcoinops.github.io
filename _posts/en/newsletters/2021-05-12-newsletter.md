---
title: 'Bitcoin Optech Newsletter #148'
permalink: /en/newsletters/2021/05/12/
name: 2021-05-12-newsletter
slug: 2021-05-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a security disclosure affecting
protocols depending on a certain BIP125 opt-in replace by fee behavior
and includes our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, announcements of new software releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **CVE-2021-31876 discrepancy between BIP125 and Bitcoin Core implementation:**
  the [BIP125][] specification of opt-in Replace By Fee ([RBF][topic
  rbf]) says that an unconfirmed parent transaction that signals
  replaceability makes any child transactions that spend the parent's
  outputs also replaceable through inferred inheritance.  This week,
  Antoine Riard [posted][riard cve-2021-31876] to the Bitcoin-Dev
  mailing list the full disclosure of his previously privately reported
  finding that Bitcoin Core does not implement this behavior.  It is
  still possible for child transactions to be replaced if they
  explicitly signal replaceability or for them to be evicted from the
  mempool if their parent transaction is replaced.

    Riard analyzed how the inability to use inherited replaceability
    might affect various current and proposed protocols.  Only LN
    appears to be affected and only in the sense that an existing attack
    (see [Newsletter #95][news95 atomicity attack]) that uses
    [pinning][topic transaction pinning] becomes cheaper.  The ongoing
    deployment of [anchor outputs][topic anchor outputs] by
    various LN implementations will eliminate the ability to perform that
    pinning.

    As of this writing, there has not been any substantial discussion of
    the issue on the mailing list.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:jnewbery or jonatack

{% include functions/details-list.md
  q0="FIXME"

  a0="FIXME"

  a0link="https://bitcoincore.reviews/FIXME#FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust-Lightning 0.0.14][] is a new release that makes Rust Lightning
  more compatible with getting data from Electrum-style servers, adds
  additional configuration options, and improves compliance with the LN
  specification, among other bug fixes and improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #20867][] Support up to 20 keys for multisig under Segwit context FIXME:jnewbery

- [Bitcoin Core GUI #125][] enables users to adjust the autoprune block space
  size from the default in the intro dialog.  It also adds an improved
  description for how the pruned storage works, clarifying that the entire
  blockchain must be downloaded and processed but will be discarded in
  the future to keep disk usage low.

- [C-Lightning #4489][] dual funding plugin FIXME:dongcarl

- [C-Lightning #4496][] adds the ability for plugins to register topics
  about which they plan to publish notifications.  Other plugins can
  subscribe to those topics to receive notifications.
  C-Lightning already had several built-in topics, but this merged PR
  allows plugin authors to create and consume notifications for any
  new topic category they'd like to use.

- [Rust Bitcoin #589][] starts the process of implementing support for [taproot][topic
  taproot] with [schnorr signatures][topic schnorr signatures].  The
  existing ECDSA support is moved to a new module but continues to be
  exported under existing names to preserve API compatibility.  A new
  `util::schnorr` module adds support for [BIP340][] schnorr key
  encodings.  Issue [#588][rust bitcoin #588] is being used to track the
  complete implementation of taproot compatibility.

{% include references.md %}
{% include linkers/issues.md issues="20867,125,4489,4496,589,588" %}
[riard cve-2021-31876]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018893.html
[news95 atomicity attack]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[rust-lightning 0.0.14]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.14
