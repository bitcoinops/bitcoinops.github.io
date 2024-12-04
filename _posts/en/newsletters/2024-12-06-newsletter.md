---
title: 'Bitcoin Optech Newsletter #332'
permalink: /en/newsletters/2024/12/06/
name: 2024-12-06-newsletter
slug: 2024-12-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the disclosure of a transaction
censorship vulnerability and summarizes discussion about the consensus
cleanup soft fork proposal.  Also included are our regular sections
announcing new releases and release candidates and describing notable
changes to popular Bitcoin infrastructure software.

## News

- **Transaction censorship vulnerability:** Antoine Riard [posted][riard
  censor] to the Bitcoin-Dev mailing list about a method for preventing
  a node from broadcasting a transaction belonging to a connected
  wallet.  If the connected wallet belongs to the user's LN node, the
  attack can be used to prevent the user from securing funds owed to
  them before a timeout expires and allows their counterparty to steal
  the funds.

  There are two versions of the attack, both of which take advantage of
  limits within Bitcoin Core related to the maximum number of
  unconfirmed transactions it will broadcast or accept within a certain
  period of time.  These limits prevent it from placing an excessive
  burden on its peers or being denial-of-service attacked.

  The first version of the attack, called _high overflow_ by Riard,
  takes advantage of Bitcoin Core only broadcasting a maximum of 1,000
  unconfirmed transaction announcements at a time to its peers.  If more
  than 1,000 transactions are queued to be transmitted, the highest
  feerate transactions are announced first.  After sending a batch of
  announcements, Bitcoin Core will wait to send more transactions until
  its recent average rate of announcements is seven transactions per
  second.

  If all 1,000 initial announcements pay a higher feerate than the
  transaction the victim wants to broadcast, and if an attacker
  continues to send the victim node at least seven transactions per
  second above that feerate, the attacker can prevent the broadcast
  indefinitely.  Most attacks on LN will need to delay broadcast for
  between 32 blocks (Core Lightning defaults) and 140 blocks (Eclair
  defaults), which at 10 sats/vbyte would cost between 1.3 BTC ($130,000
  USD) and 5.9 BTC ($590,000 USD), although Riard notes that a careful
  attacker who is well connected to other relay nodes (or directly to
  large miners) may be able to significantly reduce these costs.

  The second version of the attack, called _low overflow_ by Riard,
  takes advantage of Bitcoin Core refusing to allow its queue of
  unrequested transactions to grow beyond 5,000 per peer.  The attacker
  sends the victim a huge number of transactions at a minimum feerate;
  the victim announces these to its honest peers and the peers queue the
  announcements; periodically, they attempt to drain the queue by
  requesting the transactions but a deficit builds until it reaches the
  5,000 announcement limit.  At that point, the peers ignore further
  announcements until the queue has partially drained.  If the victim's
  honest transaction is announced during that time, the peers will
  ignore it.  This attack can be significantly cheaper than the
  high-overflow variant because the attacker's junk transactions can
  pay the minimum transaction relay fee.  However, the attack may be
  less reliable, in which case the attacker loses money spent on fees
  without gaining anything from the theft.

  At their simplest, the attacks do not appear to be concerning.  Very
  few channels are likely to have pending payments exceeding the cost of
  the attack.  Riard recommends that users of high-value LN channels
  operate additional full nodes, including those that do not accept
  inbound connections and which use _blocks only mode_ to ensure that
  they only relay unconfirmed transactions submitted by a local wallet.
  More sophisticated attacks that lower costs, or attacks that use the
  same set of junk transactions to attack multiple LN channels
  simultaneously, could affect even lower-value channels.  Riard
  suggests several mitigations for LN implementations and leaves for
  later discussion possible changes to Bitcoin Core's P2P relay protocol
  that could address the issue.

  _Note to readers:_ we apologize if there are any errors in the above
  description; we only learned of the disclosure shortly before we
  went to publish this week's newsletter.

- **Continued discussion about consensus cleanup soft fork proposal:**
  Antoine Poinsot [posted][poinsot time warp] to the existing Delving
  Bitcoin thread about the [consensus cleanup][topic consensus cleanup]
  soft fork proposal.  In addition to the already proposed fix for the
  classic [time warp vulnerability][topic time warp], he proposed also
  including a fix for the recently discovered Zawy-Murch time warp (see
  [Newsletter #316][news316 time warp]).  He favored a fix originally
  proposed by Mark "Murch" Erhardt: "require that the last block in a
  difficulty period _N_ has a higher timestamp than the first block in
  the same difficulty period _N_".

  Anthony Towns [favored][towns time warp] an alternative solution
  proposed by Zawy that would forbid any block from claiming it was
  produced more than two hours before any previous block.  Zawy
  [noted][zawy time warp] that his every-block solution would increase the
  risk of miners losing money from running outdated software but it
  would also make timestamps more accurate for other uses, such as
  [timelocks][topic timelocks].

  Separately, both on [Delving Bitcoin][poinsot duptx delv] and the
  [Bitcoin-Dev mailing list][poinsot duptx ml], Poinsot sought feedback
  about which proposed solution to use to prevent block 1,983,702 and
  some later blocks from [duplicating][topic duplicate transactions] a
  previous coinbase transaction (which could lead to loss of money and
  the creation of an attack vector).  Four proposed solutions are
  presented, all of which would only directly affect miners---so
  [feedback from miners][mining-dev] would be especially appreciated.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Eclair v0.11.0][] is the latest release of this popular LN node
  implementation.  It "adds official support for BOLT12 [offers][topic
  offers] and makes progress on liquidity management features
  ([splicing][topic splicing], [liquidity ads][topic liquidity
  advertisements], and [on-the-fly funding][topic jit channels])."  The
  release also stops accepting new non-[anchor channels][topic anchor
  outputs].  Also included are optimizations and bug fixes.

- [LDK v0.0.125][] is the latest release of this library for building
  LN-enabled applications.  It contains several bug fixes.

- [Core Lightning 24.11rc3][] is a release candidate for the next major
  version of this popular LN implementation.

- [LND 0.18.4-beta.rc1][] is a release candidate for a minor version of
  this popular LN implementation.

- [Bitcoin Core 28.1RC1][] is a release candidate for a maintenance
  version of the predominant full node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30708][] rpc: add getdescriptoractivity

- [Core Lightning #7832][] anchors: create low priority anchor to spend commit tx within a week.

- [LND #8270][] DynComms [1/n]: Implement Quiescence Protocol

- [LND #8390][] Add Experimental Endorsement Signalling

- [BIPs #1534][] Add BIP 349: OP_INTERNALKEY

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30708,7832,8270,8390,1534" %}
[core lightning 24.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc3
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 time warp]: /en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[poinsot time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/53
[towns time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/54
[zawy time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/55
[poinsot duptx delv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/51
[poinsot duptx ml]: https://groups.google.com/g/bitcoindev/c/KRwDa8aX3to
[mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/qyrPzU1WKSI
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[riard censor]: https://groups.google.com/g/bitcoindev/c/GuS36ldye7s
