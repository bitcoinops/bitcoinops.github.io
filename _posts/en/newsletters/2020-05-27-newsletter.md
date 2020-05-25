---
title: 'Bitcoin Optech Newsletter #99'
permalink: /en/newsletters/2020/05/27/
name: 2020-05-27-newsletter
slug: 2020-05-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about the minimum allowed
transaction size and includes our regular sections with popular
questions and answers from the Bitcoin StackExchange, releases and
release candidates, and notable merges from Bitcoin infrastructure
projects.

## Action items

*None this week.*

## News

<!-- "as small as 60 bytes" because the transaction Voegtlin describes
on the list was actually 62 bytes (confirmed by private email) but 60
bytes is indeed the smallest possible (see HTML comment in Newsletter 36;
Voegtlin agrees) -->

- **Minimum transaction size discussion:** Thomas Voegtlin
  [posted][voegtlin min] to the Bitcoin-Dev mailing list about creating
  transactions with stripped sizes (non-witness sizes) as small as 60
  bytes.  Bitcoin Core refuses to relay or mine transactions [smaller
  than 82 bytes][min nonwit].  Gregory Sanders [notes][sanders cve] that
  the motivation for this rule is [CVE-2017-12842][] (described in
  [Newsletter #27][news27 cve-2017-12842]) where an attacker who can get
  a specially-crafted 64-byte transaction confirmed into a block can use
  it to convince SPV lightweight clients that one or more other
  arbitrary transactions have been confirmed, such as fake transactions
  that pay to lightweight wallets.  As described in [Newsletter
  #36][news36 tree attacks], permanently eliminating the ability to
  perform that attack was proposed in the [consensus cleanup soft
  fork][topic consensus cleanup] by forbidding transactions with a
  stripped size of fewer than 65 bytes.

    After describing the motivation for the current relay rule, Sanders
    [asks][sanders 64] whether the rule can be simplified to only forbid
    transactions whose stripped size is exactly 64 bytes.  ZmnSCPxj
    [replies][zmn padding] that anything under 64 bytes could still be
    vulnerable, but that the 65-bytes-or-greater rule seems fine.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are the sizes of single-sig and 2-of-3 multisig taproot inputs?]({{bse}}96017)
  Murch lists a variety of ways of spending from a [taproot][topic taproot] output and their
  associated costs.

- [What if the mempool exceeds 300 MB?]({{bse}}96068)
  Andrew Chow and Murch outline how a node behaves after its mempool's
  maximum size is reached. The node will begin to drop transactions with the
  lowest feerate and increase its `minMempoolFeeRate` communicated to peers in
  order to keep the mempool size under that node's `maxmempool` configuration.

- [Why isn't RFC6979 used for schnorr signature nonce generation?]({{bse}}95762)
  Pieter Wuille describes some of the downsides of using [RFC6979][] and why
  [BIP340][] uses a simpler nonce-generation algorithm inspired by [Ed25519][].

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0rc2][bitcoin core 0.20.0] is the most recent
  release candidate for the next major version of Bitcoin Core.

- [LND 0.10.1-beta.rc2][] is the latest release candidate for the next
  maintenance release of LND.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until version 0.21, about six months after the release of the upcoming
version 0.20.*

- [Bitcoin Core #18956][] uses the API on Windows systems to require
  Windows 7 or later.  All release notes since the October 2018 release
  of [Bitcoin Core 0.17][0.17 compat] have announced that the only
  supported versions of Windows are version 7 or later.

- [Bitcoin Core #18861][] prevents the node from replying to a P2P
  protocol `getdata` request for a transaction that it hasn't yet
  announced to the requesting peer.  This prevents surveillance nodes from
  circumventing Bitcoin Core's existing privacy-enhancing behavior of
  waiting a slightly different amount of time for each peer (or group of
  peers) before announcing new transactions to them, causing each
  transaction to propagate across the network using a different path.
  Randomizing the propagation path of each transaction makes it less
  reliable for surveillance nodes to assume that the first node announcing
  a transaction was the first node to receive it.

- [Bitcoin Core #17681][] allows the wallet to internally derive new
  addresses for a [BIP32][] HD wallet seed even after that seed is no
  longer the wallet's active seed.  This makes it safe to switch to a
  new HD seed with the `sethdseed` (set HD seed) RPC even while the node
  is performing an initial block chain download, such as when restoring
  a wallet backup on a newly-started node---the updated code ensures the
  wallet will see any payments to addresses previously derived from the
  old HD seed.

- [Bitcoin Core #18895][] updates the RPCs that return data about
  individual transactions in the mempool (e.g. `getrawmempool` and
  `getmempoolentry`) with an `unbroadcast` field that indicates whether
  or not any of the local node's peers have requested a copy of the
  transaction (see [Newsletter #96][news96 unbroadcast] for a summary of
  broadcast tracking).  Additionally, the `getmempoolinfo` RPC is
  updated with an `unbroadcastcount` field indicating the number of
  unbroadcast transactions.  For privacy, the broadcast status of a
  transaction is only tracked if it was submitted by either the node's
  wallet or the `sendrawtransaction` RPC.

- [Bitcoin Core #18677][] adds a new `--enable-multiprocess` build
  configuration option that will produce additional binaries alongside
  the existing `bitcoind` and `bitcoin-qt` binaries.  For now, the only
  difference between the new and old binaries is their name.  However,
  if [PR #10102][Bitcoin Core #10102] is merged, the new binaries will
  split the functions of node, wallet, and GUI into separate executables
  that communicate with each other when necessary.  The build option is
  currently disabled by default.  See also [Newsletter #39][news39
  multiprocess] for the last time we wrote about the multiprocess
  sub-project.

- [Bitcoin Core #18594][] allows `bitcoin-cli -getinfo` to print the
  balance of each wallet loaded in multiwallet mode.

- [C-Lightning #3738][] adds initial support for [BIP174][] Partially
  Signed Bitcoin Transactions ([PSBT][topic psbt]), making use of
  [libwally's PSBT support][libwally psbt].  The only user-visible change
  is that the PSBT form of the transaction is returned by the
  `txprepare` RPC, but the PR is tagged in GitHub as working towards
  dual funding of new channels (see [Newsletter #83][news83 interactive]
  for discussion of using PSBT for interactive construction of funding transactions).

- [LND #4227][] tighten up signing; ultimate goal supporting HW devices for signing. FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="18956,18861,3738,4227,17681,18895,18677,10102,18594" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta.rc2
[0.17 compat]: https://bitcoincore.org/en/releases/0.17.0/#compatibility
[min nonwit]: https://github.com/bitcoin/bitcoin/blob/99813a9745fe10a58bedd7a4cb721faf14f907a4/src/policy/policy.h#L25
[voegtlin min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017883.html
[sanders cve]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017884.html
[sanders 64]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017885.html
[news27 cve-2017-12842]: /en/newsletters/2018/12/28/#cve-2017-12842
[news36 tree attacks]: /en/newsletters/2019/03/05/#merkle-tree-attacks
[news96 unbroadcast]: /en/newsletters/2020/05/06/#bitcoin-core-18038
[news39 multiprocess]: /en/newsletters/2019/03/26/#bitcoin-core-10973
[libwally psbt]: https://github.com/ElementsProject/libwally-core/pull/126
[news83 interactive]: /en/newsletters/2020/02/05/#psbt-interaction
[zmn padding]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017886.html
[RFC6979]:https://tools.ietf.org/html/rfc6979
[Ed25519]:https://ed25519.cr.yp.to/