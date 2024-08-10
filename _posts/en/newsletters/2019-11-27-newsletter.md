---
title: 'Bitcoin Optech Newsletter #74'
permalink: /en/newsletters/2019/11/27/
name: 2019-11-27-newsletter
slug: 2019-11-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new major version of Bitcoin Core,
provides some updates on Bitcoin and LN developer mailing lists,
and describes recent developments in the ongoing schnorr/taproot review.
Also included are our regular sections with top-voted questions and
answers from the Bitcoin Stack Exchange and notable changes to popular
Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade to Bitcoin Core 0.19.0.1:** users are encouraged to upgrade to the
  latest [release][bitcoin core 0.19.0.1], which contains new features and
  multiple bug fixes.  This is the first release version of the 0.19
  series after a [bug][Bitcoin Core #17449] affecting the 0.19.0
  tagged version was found and fixed.

## News
{% comment %}<script>
// commit count: git shortlog -no-merges -s v0.18.1..v0.19.0 | awk '{print $1}' | numsum
// contributor count: wc -l on list in release notes
</script>{% endcomment %}

- **Bitcoin Core 0.19 released:** featuring over 1,000 commits from
  more than 100 contributors, the
  [latest Bitcoin Core release][bitcoin core 0.19.0.1] offers several new
  user-visible features, numerous bug fixes, and multiple improvements
  to internal systems such as P2P network handling.  Some changes which
  may be especially interesting to newsletter readers include:

  - *CPFP carve-out:* this [new mempool policy][topic cpfp carve out]
    helps two-party contract protocols (such as the current LN) ensure
    that both parties will be able to use Child-Pays-For-Parent (CPFP)
    fee bumping (see [Newsletter #63][news63 carve-out]).  LN
    developers already have a proposal under discussion for how
    they'll use this feature to simplify fee management for commitment
    transactions (see newsletters [#70][news70 simple commits] and
    [#71][news71 ln carve-out]).

  - *BIP158 block filters (RPC only):* users can now set a new
    configuration option, `blockfilterindex`, if they want Bitcoin
    Core to generate [compact block filters][topic compact block
    filters] as specified by [BIP158][].  The filter for each block
    can then be retrieved using the new RPC `getblockfilter`.  Filters
    can be provided to a compatible lightweight client to allow it to
    determine whether a block might contain any transactions involving
    its keys (see [Newsletter #43][news43 core bip158] for more
    information).  [PR#16442][Bitcoin Core #16442] is currently open
    to add support for the corresponding [BIP157][] protocol that will
    allow sharing these filters with clients over the P2P network.

  - *Deprecated or removed features:* support for the [BIP70][]
    payment protocol, [BIP37][] P2P protocol bloom filters, and
    [BIP61][] P2P protocol reject messages has been disabled by
    default, eliminating the source of various problems (respectively,
    see Newsletters [#19][news19 bip70], [#57][news57 bip37], and
    [#37][news37 bip61]).  The payment protocol and reject messages
    are scheduled to be fully removed in the next major Bitcoin Core
    version about six months from now.

  - *Customizable permissions for whitelisted peers:* when
    specifying which peers or interfaces should be whitelisted, users
    can now specify which special features the whitelisted peers
    can access.  Previously, whitelisted peers wouldn't be banned and
    received relayed transactions faster.  These defaults haven't
    changed, but now it's possible to toggle those settings on a
    per-peer basis or to allow specified whitelisted peers to request
    BIP37 bloom filters even though they're disabled for
    non-whitelisted peers by default.  For details, see [Newsletter
    #60][news60 16248].

  - *GUI improvements:* graphical users can now create new wallets
    for use with multiwallet mode from the GUI's *file* menu (see
    [Newsletter #63][news63 new wallet]).  The GUI also now provides
    users with [bech32][topic bech32] Bitcoin addresses by default,
    but users can easily request a backwards-compatible P2SH-P2WPKH
    address by toggling a checkbox next to the button to generate an
    address (see [Newsletter #42][news42 core gui bech32]).

  - *Optional privacy-preserving address management:* a new
    `avoid_reuse` wallet flag, which can be toggled using a new
    `setwalletflag` RPC, can be enabled to prevent the wallet from
    spending bitcoins received to an address that was previously
    used (see [Newsletter #52][news52 avoid_reuse]).  This prevents
    certain privacy leaks based on block chain analysis such as [dust
    flooding][].

  For a full list of notable changes, links to the PRs where those
  changes were made, and additional information useful to node
  operators, please see the Bitcoin Core project's [release notes][notes
  0.19.0].

- **New LND mailing list and new host of existing mailing lists:** a [new
  mailing list][lnd engineering] hosted by Google Groups was announced
  for LND application developers, with an [initial post][osuntokun lnd
  plans] by Olaoluwa
  Osuntokun describing short-term goals for LND's next release.
  Separately, the existing mailing lists for [Bitcoin-Dev][] and
  [Lightning-Dev][] have recently had their hosting [transferred][togami
  ml update] to Oregon State University's [Open Source Lab][osl] (OSL), a
  well-respected organization that provides hosting to a variety of open
  source projects.  Optech extends our thanks to Warren Togami, Bryan Bishop, and everyone else involved in
  maintaining all of Bitcoin's many open communication channels, without
  which this newsletter wouldn't exist.

- **Schnorr/Taproot updates:** participants in the [taproot review
  group][] have been continuing their review of the proposed soft fork
  changes to Bitcoin, with many interesting questions being asked and
  answered in the [logged][tbr log] ##taproot-bip-review IRC chatroom on
  the Freenode network.  Additionally, some participants have been
  writing their own implementations of parts of the BIPs, including for
  the libbitcoin and bcoin full verification nodes.

  Two informative blog posts were also posted this week related to the
  security of multiparty schnorr signatures.  Blockstream engineer
  Jonas Nick [describes][nick musig] the [MuSig][] multiparty
  signature scheme that is designed to allow users of [bip-schnorr][] to
  aggregate multiple public keys into a single pubkey.  They can
  later sign for that key for using a single signature generated collaboratively
  among themselves.  Nick describes the three steps of the MuSig signing
  protocol---the exchange of nonce commitments, the exchange of
  nonces, and the exchange of partial signatures (with the nonces and the
  partial signatures then being aggregated to produce the final
  signature).  To save time when speed is critical (e.g. in creating
  LN channel commitment transactions), some people might want to
  exchange nonce commitments and then nonces before they know what
  transaction they want to commit to with their signature---but this
  is unsafe due to Wagner's algorithm, as Nick briefly explains.  The
  only information that can be safely shared before each participant
  knows the transaction to sign is the nonce commitment.  (Not
  mentioned in the blog post, but discussed on IRC, was that Pieter
  Wuille and others have been investigating a construction based on a
  Zero Knowledge Proof (ZKP) that could allow reduced interactivity.)
  The blog post concludes with a suggestion that interested readers
  review the MuSig implementation in [libsecp256k1-zkp][], which is
  designed to help developers use the protocol safely.

  Influenced by Jonas Nick's presentation on this topic at the Berlin
  Lightning Conference, Adam Gibson wrote a separate [blog
  post][gibson wagners] that describes Wagner's algorithm in much more
  detail with a mix of math, intuitive analysis, and topical
  information Bitcoiners may find interesting (such as the amusing
  tidbit of [Wagner's paper][] citing both Adam Back and Wei Dai
  several years before Nakamoto did [the same][bitcoin.pdf], though
  for different work).  Anyone interested in developing their own
  cryptographic protocols is recommended to read both posts, as each
  complements the other without being repetitive about the subject.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Would a schnorr pubkey be a different length than a taproot pubkey like P2WPKH and P2WSH?]({{bse}}91531)
  Murch explains that, unlike segwit v0 which has different P2WPKH and P2WSH
  output types and lengths, all segwit v1 Pay-to-Taproot (P2TR) outputs are
  always the same length.

- [MuSig Signature Interactivity]({{bse}}91534)
  Justinmoon asks why [MuSig][] signing is always interactive and about secure,
  offline interactive signing. Nickler explains each of the rounds involved
  with MuSig signing as well as some pitfalls to avoid during signing.

- [How does the bech32 length-extension mutation weakness work?]({{bse}}91602)
  Jnewbery asks for details about why adding or removing q characters
  immediately before the final p character of an address can sometimes
  produce a new bech32 address that's valid.
  Pieter Wuille provides some algebraic details about why the problem is
  more likely to occur than the roughly 1-in-a-billion chance expected
  for any random length-change error to go undetected.  MCCCS provides a
  second explanation using some of the applicable code from Bitcoin
  Core.

- [What is the difference between Bitcoin policy language and Miniscript?]({{bse}}91565)
  Pieter Wuille, James C., and sanket1729 explain the relationship
  between Bitcoin Script, the policy language (a tool for humans to
  design spending conditions), and miniscript (a more structured
  representation of Bitcoin Script for communication and analysis).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17265][] and [#17515][Bitcoin Core #17515] complete the
  removal of the dependency on OpenSSL, which has been used since the
  original Bitcoin 0.1 release but was the cause of [consensus
  vulnerabilities][non-strict der], [remote memory leaks][heartbleed]
  (potential private key leaks), [other bugs][cve-2014-3570], and [poor
  performance][libsecp256k1 sig speedup].

- [Bitcoin Core #16944][] updates the GUI to generate a [BIP174][]
  Partially Signed Bitcoin Transaction (PSBT) and automatically copies
  it to the clipboard if the user tries to create a transaction in a
  watch-only wallet that has its private keys disabled.  The PSBT can
  then be copied into another application for signing (e.g. [HWI][topic
  hwi]).  The GUI doesn't yet provide a special dialog for copying the
  signed PSBT back in for broadcasting.

- [Bitcoin Core #17290][] changes which coin selection algorithm is used
  in cases where the user requests certain inputs be used or asks that
  the fee be selected from the payment amounts.  These now use Bitcoin
  Core's normal default algorithm of Branch and Bound (BnB).  BnB was
  designed to minimize fees and maximize privacy by optimizing for the
  creation of changeless transactions.

- [C-Lightning #3264][] includes several mitigations for [LND
  #3728][], a bug in the implementation of gossip queries.  This
  change also adds two new command line parameters useful for testing
  and debugging, `--hex` and `--features`.

- [C-Lightning #3274][] causes `lightningd` to refuse to start if it
  detects that `bitcoind` is now on a lower block height than it was the
  last time `lightningd` was run.  If a lower height is seen while
  `lightningd` is running, it will simply wait until a higher height is
  seen.  Block heights can decrease during a block chain reorganization,
  during a block chain reindex, or if the user runs certain commands
  intended for developer testing. <!-- e.g.  invalidateblock --> It's
  easier and safer for `lightningd` to wait for those situations to be
  resolved by `bitcoind` than it is to try to work around the problems.
  However, if the LN user really wants to use the truncated chain, they
  can start `lightningd` with the `--rescan` parameter to reprocess the
  block chain.  <!-- yes, that parameter is for lightningd (not
  bitcoind); see test in this PR -->

- [Eclair #1221][] adds a `networkstats` API that returns various
  information about the LN network as observed from the local node,
  including the number of known channels, number of known LN nodes, the
  capacity of LN nodes (grouped into percentiles), and the fees that nodes are
  charging (also grouped into percentiles).

- [LND #3739][] makes it possible to specify what node should be the
  last hop on a route before a payment is delivered to the receiver.
  In conjunction with other still-pending work, such as [LND #3736][], this
  will make it possible for a user to rebalance their channels using
  built-in LND features (instead of requiring external tools, as is
  currently the case).

- [LND #3729][] makes it possible to generate invoices with millisatoshi
  precision.  Previously, LND would not generate invoices with
  sub-satoshi precision.

- [LND #3499][] extends several RPCs, such as `listpayments` and
  `trackpayment` to provide information about [multipath
  payments][topic multipath payments], payments that can have multiple
  parts that are sent over different routes.  These are not fully
  supported by LND yet, but this merged PR makes it easier to add
  support later.  Additionally, previously-sent payments that have only
  a single part are converted into the same structure used for
  multipath, but they are shown as only having one part.

{% include linkers/issues.md issues="17449,3499,3729,3739,1221,16442,17265,17515,16944,3264,3728,3274,17290,3736" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bitcoin core 0.19.0.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.0.1/
[notes 0.19.0]: https://bitcoincore.org/en/releases/0.19.0.1/
[news63 carve-out]: /en/newsletters/2019/09/11/#bitcoin-core-16421
[news70 simple commits]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[news71 ln carve-out]: /en/newsletters/2019/11/06/#continued-discussion-of-ln-anchor-outputs
[news43 core bip158]: /en/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[news19 bip70]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[news57 bip37]: /en/newsletters/2019/07/31/#bloom-filter-discussion
[news37 bip61]: /en/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[news63 new wallet]: /en/newsletters/2019/09/11/#bitcoin-core-15450
[news42 core gui bech32]: /en/newsletters/2019/04/16/#bitcoin-core-15711
[news52 avoid_reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
[dust flooding]: {{bse}}81509
[news60 16248]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[togami ml update]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-11-21.html#l-23
[nick musig]: https://medium.com/blockstream/insecure-shortcuts-in-musig-2ad0d38a97da
[gibson wagners]: https://joinmarket.me/blog/blog/avoiding-wagnerian-tragedies/
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[lnd engineering]: https://groups.google.com/a/lightning.engineering/forum/#!forum/lnd
[osuntokun lnd plans]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/GtcrXNhTLqQ
[bitcoin-dev]: https://lists.linuxfoundation.org/mailman/listinfo/bitcoin-dev
[lightning-dev]: https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[osl]: https://osuosl.org/
[taproot review group]: https://github.com/ajtowns/taproot-review
[tbr log]: http://www.erisian.com.au/taproot-bip-review/
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[wagner's paper]: https://people.eecs.berkeley.edu/~daw/papers/genbday-long.ps
[non-strict der]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
[musig]: https://eprint.iacr.org/2018/068
