---
title: 'Bitcoin Optech Newsletter #321'
permalink: /en/newsletters/2024/09/20/
name: 2024-09-20-newsletter
slug: 2024-09-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a proof-of-concept implementation for
proving in zero-knowledge that an output is part of the UTXO set,
describes one new and two previous proposals for allowing offline LN
payments, and summarizes research about DNS seeding for non-IP network
addresses.  Also included are our regular sections describing changes to
clients and services, announcing new releases and release candidates,
and summarizing notable changes to popular Bitcoin infrastructure
software.

## News

- **Proving UTXO set inclusion in zero knowledge:** Johan Halseth
  [posted][halseth utxozk] to Delving Bitcoin to announce a
  proof-of-concept tool that allows someone to prove that they control
  one of the outputs in the current UTXO set without revealing which
  output.  The eventual goal is to allow the co-owners of an LN funding
  output to prove they control a channel without revealing any specific
  information about their onchain transactions.  That proof can be
  attached to next-generation [channel announcement messages][topic
  channel announcements] that are used to build decentralized routing
  information for LN.

  The method used differs from the aut-ct method described in
  [Newsletter #303][news303 aut-ct], and some of the discussion focused
  on clarifying the differences.  Additional research is needed, with
  Halseth describing several open problems.

- **LN offline payments:** Andy Schroder [posted][schroder lnoff] to
  Delving Bitcoin to sketch a communication process an LN wallet could
  use to generate tokens that could be provided to an internet-connected
  wallet in order to pay it.  For example, Alice's wallet would normally
  be connected to an always-online LN node she controls or that is
  controlled by a _Lightning service provider_ (LSP).  While online,
  Alice will pregenerate authentication tokens.

  Later, when Alice's node is offline and she wants to pay Bob, she
  gives Bob an authentication token that allows him to connect to her
  always-online node or LSP and withdraw an amount indicated by Alice.
  She can provide the authentication token to Bob using [NFC][] or
  another widely available data transfer protocol that doesn't require
  Alice to access the internet, keeping the protocol simple and making
  it easy to implement on devices with limited computing resources (such as
  smart cards).

  Developer ZmnSCPxj [mentioned][zmn lnoff] an alternative approach he
  had previously described and Bastien Teinurier [referenced][t-bast
  lnoff] a method for node remote control he designed for this type of
  situation (see [Newsletter #271][news271 noderc]).

- **DNS seeding for non-IP addresses:** developer Virtu [posted][virtu seed]
  to Delving Bitcoin a survey of the availability of seed nodes on
  [anonymity networks][topic anonymity networks] and discussed methods
  for allowing new nodes that exclusively use those networks to learn
  about peers through DNS seeders.

  As background, a Bitcoin node or P2P client needs to learn the
  network addresses of peers that it can download data from.  Newly
  installed software, or software that has been offline for a long time,
  may not know the network address of any active peers.  Normally,
  Bitcoin Core nodes solve this by querying a DNS seed that returns the
  IPv4 or IPv6 addresses of several peers that are likely to be
  available.  If DNS seeding fails, or if it's unavailable (such as for
  anonymity networks that don't use IPv4 or IPv6 addresses), Bitcoin
  Core includes the network addresses of peers that were available when
  the software release was made; those peers are used as _seed nodes_,
  where the node requests additional peer addresses from the seed node
  and uses them as potential peers.  DNS seeds are preferred over seed nodes
  as their information is usually more current and the global DNS
  caching infrastructure can prevent a DNS seed from learning the
  network address of each querying node.

  Virtu examined the seed nodes listed in the last four major
  releases of Bitcoin Core and found that a satisfactory number of them
  were still available, indicating that users of anonymity networks
  should be able to find peers.  They and other discussion participants
  also examined the possibility of modifying Bitcoin Core to allow it to
  use DNS seeding for anonymity networks via either DNS `NULL` records
  or encoding alternative network addresses into pseudo-IPv6 addresses.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 3.1.0][] is a release of the next version of this package
  providing a common interface to multiple different hardware signing
  devices.  This release adds support for the Trezor Safe 5 and makes
  several other improvements and bug fixes.

- [Core Lightning 24.08.1][] is a maintenance release that fixes crashes
  and other bugs discovered in the recent 24.08 release.

- [BDK 1.0.0-beta.4][] is a release candidate for this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet` and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API."

- [Bitcoin Core 28.0rc2][] is a release candidate for the next major
  version of the predominant full node implementation.  A [testing
  guide][bcc testing] is available.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

_Note: the commits to Bitcoin Core mentioned below apply to its master
development branch, so those changes will likely not be released until
about six months after the release of the upcoming version 28._

- [Bitcoin Core #28358][] drops the `dbcache` limit because the previous 16 GB
  limit was no longer sufficient to complete an Initial Block Download (IBD)
  without flushing the UTXO set from RAM to disk, which can
  [provide][lopp cache] about a 25% speed up. It was decided to remove the
  limit rather than raise it because there was no optimal value
  that would be future-proof and to give users complete flexibility.

- [Bitcoin Core #30286][] optimizes the candidate search algorithm used in
  cluster linearizations, based on the framework laid out in Section 2 of
  this [Delving Bitcoin post][delving cluster], but with some modifications.
  These optimizations minimize iterations to improve linearization performance,
  but may increase startup and per-iteration costs. This is part of the [cluster
  mempool][topic cluster mempool] project. See Newsletter [#315][news315
  cluster].

- [Bitcoin Core #30807][] changes the signaling of an [assumeUTXO][topic
  assumeutxo] node that is syncing the background chain from `NODE_NETWORK` to
  `NODE_NETWORK_LIMITED` so that peer nodes don’t request blocks older than about a week from it. This
  fixes a bug where a peer would request a historical block and get no response,
  causing it to disconnect from the assumeUTXO node.

- [LND #8981][] refactors the `paymentDescriptor` type to only use it within
  the `lnwallet` package. This is to later replace `paymentDescriptor` with a
  new structure called `LogUpdate` to simplify how updates are logged and
  handled, as part of a series of PRs implementing dynamic commitments, a type
  of [channel commitment upgrade][topic channel commitment upgrades].

- [LDK #3140][] adds support for paying static [BOLT12][topic offers] invoices
  to send [async payments][topic async payments] as an always online sender as
  defined in [BOLTs #1149][], but without including the invoice request in the
  payment [onion message][topic onion messages]. Sending as an often offline
  sender or receiving async payments is not yet possible, so the flow cannot yet
  be tested end-to-end.

- [LDK #3163][] updates the [offers][topic offers] message flow by introducing a
  `reply_path` in BOLT12 invoices. This allows the payer to send the error
  message back to the payee in case of an invoice error.

- [LDK #3010][] adds functionality for a node to retry sending an invoice
  request to an [offer][topic offers] reply path if it hasn't yet received the
  corresponding invoice.  Previously, if an invoice request message on a single
  reply path offer failed due to network disconnection, it wasn't retried.

- [BDK #1581][] introduces changes to the [coin selection][topic coin selection]
  algorithm by allowing for a customizable fallback algorithm in the
  `BranchAndBoundCoinSelection` strategy. The signature of the `coin_select`
  method is updated to allow a random number generator to be passed directly to
  the coin selection algorithm. This PR also includes additional refactorings,
  internal fallback handling, and simplification of error handling.

- [BDK #1561][] removes the `bdk_hwi` crate from the project, to simplify
  dependencies and CI. The `bdk_hwi` crate contained `HWISigner`, which has now
  been moved to the `rust_hwi` project.
  
{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28358,30286,30807,8981,3140,3163,3010,1581,1561,1149" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[halseth utxozk]: https://delvingbitcoin.org/t/proving-utxo-set-inclusion-in-zero-knowledge/1142/
[schroder lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/
[virtu seed]: https://delvingbitcoin.org/t/hardcoded-seeds-dns-seeds-and-darknet-nodes/1123
[news303 aut-ct]: /en/newsletters/2024/05/17/#anonymous-usage-tokens
[nfc]: https://en.wikipedia.org/wiki/Near-field_communication
[zmn lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/2
[t-bast lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/4
[news271 noderc]: /en/newsletters/2023/10/04/#secure-remote-control-of-ln-nodes
[hwi 3.1.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.1.0
[core lightning 24.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.1
[delving cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303#h-2-finding-high-feerate-subsets-5
[lopp cache]: https://github.com/bitcoin/bitcoin/pull/28358#issuecomment-2186630679
[news315 cluster]: /en/newsletters/2024/08/02/#bitcoin-core-30126
