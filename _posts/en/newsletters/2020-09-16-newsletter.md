---
title: 'Bitcoin Optech Newsletter #115'
permalink: /en/newsletters/2020/09/16/
name: 2020-09-16-newsletter
slug: 2020-09-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter recommends checking for nodes vulnerable to the
InvDoS attack, briefly describes that attack, summarizes another attack
against LN channels, and links to the announcement of the Crypto Open
Patent Alliance.  Also included are our regular sections with releases,
release candidates, and notable changes to popular Bitcoin
infrastructure projects.

## Action items

- **Check for nodes vulnerable to the InvDoS attack:** an attack
  disclosed this week affects several old versions of full node software
  (including altcoins).  According to the [paper][invdos paper],
  affected Bitcoin software includes "Bitcoin Core v0.16.0, Bitcoin Core
  v0.16.1, Bitcoin Knots v0.16.0, all beta versions of bcoin up to
  v1.0.0-pre, [and] all versions of btcd up to v0.20.1-beta."  The
  latest released versions of Bitcoin Core, Bitcoin Knots, bcoin, and
  btcd all contain fixes.  See the *News* section below for details.

## News

- **Inventory out-of-memory Denial-of-Service attack (InvDoS):** Braydon
  Fuller and Javed Khan [posted][invdos post] to the Bitcoin-Dev mailing
  list an attack ([website][invdos site], [paper][invdos paper],
  [CVE-2018-17145][]) they'd previously disclosed to the
  maintainers of various Bitcoin and Bitcoin-derived full nodes.  The
  attack consisted of `inv` (inventory) messages Bitcoin nodes use to
  notify their peers of the hash of new transactions (or other data).
  Normally, when a peer receives an inventory, it checks to see if it
  already has a transaction with that hash and then requests full copies
  of any previously-unseen transactions.  In the attack, an attacker would flood the
  victim with an excessive number of `inv` messages, each containing
  nearly the maximum allowed number of transaction hashes.  When too
  many of these inventories were queued, the victim's node would run out
  of memory and crash.

  Several of the affected programs had code that limited the number of
  inventories that should've been queued, but the researchers were
  able to circumvent those protections.  As a bug that could only crash
  nodes, it could not be used to directly steal from affected nodes.
  However, it could be used to execute [eclipse attacks][topic eclipse
  attacks] that could ultimately steal money---although there's no
  indication the attack was ever used in public.

  All users are encouraged to upgrade to the latest released version
  of their preferred full node software or to review the list of
  vulnerable and patched versions on the [website][invdos site].

- **Stealing onchain fees from LN HTLCs:** Antoine Riard [posted][riard
  post] to the Lightning-Dev mailing list a potential vulnerability in a
  recent update to the LN specification (see [Newsletter #112][news112
  bolts688]). When LN payments are made according to the updated
  specification, each remote party includes a [flag][sighash] in the signature for
  their half of the 2-of-2 multisig script.  The flag, called
  `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`, allows the payment (called an
  HTLC) to be placed into a transaction containing other inputs and
  outputs.  This is designed to allow multiple HTLCs  to be bundled
  together into a transaction that also contains an extra input that
  pays any additional transaction fees and an optional extra output that
  collects any money left over from paying those extra fees.  This makes
  it possible to wait until those HTLCs need to be confirmed before
  choosing what feerate to pay.

  {:.center}
  ![Spending HTLCs with a fee-bumping input and a change output](/img/posts/2020-09-htlc-fee-bumping.dot.png)

  However, Riard notes that the specification's earlier mechanism of
  committing to variable feerates for HTLCs is still available.  This
  can allow an attacker to commit to a high fee for multiple HTLCs
  and then construct a transaction that combines those HTLCs with just
  an additional output that claims some of the funds expected to be used as fees.  Riard's email
  describes how to use this basic technique in a more complex attack
  to maximize the amount stolen.

  {:.center}
  ![Using a change output to steal fees from HTLCs that overpay fees](/img/posts/2020-09-htlc-fee-stealing.dot.png)

  Several solutions were proposed, the simplest of which might be to
  have HTLCs only pay a minimal relay fee---requiring the party
  broadcasting the HTLCs add any additional necessary fees.  No LN
  implementation defaults to using this recent specification update
  yet, so only users who have played with experimental options related
  to [anchor outputs][topic anchor outputs] should be affected.

- **Crypto Open Patent Alliance:** Square [announced][square tweet] the
  formation of an [organization][copa] to coordinate the pooling of patents
  related to cryptocurrency technology.  Members allow anyone to use
  their patents freely and, in exchange, receive the ability to use
  patents in the pool in defense against patent aggressors.  In addition
  to Square, Blockstream also [announced][blockstream tweet] it is
  joining the pool.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.9.1][C-Lightning 0.9.1] is the a new release that
  contains a number of new features and bug fixes, including all the new
  capabilities described in the following *notable changes* section.
  See the project's [release notes][cl 0.9.1 rn] for details.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #4020][] adds a new `channel_state_changed` notification
  hook that will be called each time a channel changes state, such as
  going from the "normal" operational state to "shutting down" when
  being closed.

- [C-Lightning #3812][] adds a `multiwithdraw` RPC that allows sending
  funds onchain to multiple addresses for [payment batching][topic payment batching].

- [C-Lightning #3763][] adds a `multifundchannel` RPC that allows
  funding several channels at the same time using a single deposit
  transaction with multiple outputs.  This can save 75% or more on
  transaction fees due to the efficiency advantage of payment batching.
  As an experiment, this new feature was [used][russell tweet] to open a channel to
  every functional and publicly listed LN node on testnet in a [single
  transaction][russell tx].

- [C-Lightning #3973][] adds support for the accepter side of dual-funded
  channels.  These are channels where both participants contribute funds
  rather than just a single initiator contributing funds (see
  Newsletters [#22][news22 dual] and [#83][news83 dual]).  The initial implementation of the opener side
  is still being worked on, although there's a [draft][neigut
  interactive funding] of the related specification changes.

- [C-Lightning #3870][] implements a *scorched earth* fee bumping
  mechanism for penalty transactions.  If the remote peer broadcasts an
  old channel state, the local node can use the corresponding revocation
  key to create a penalty transaction that spends all of the funds
  claimed by the non-compliant peer.  To avoid this, the peer might
  attempt to bribe miners to ignore the honest node's penalty
  transaction.  With a scorched earth policy, the honest node
  fee bumps its penalty transaction so that it pays its entire value to
  fees---ensuring the non-compliant peer does not profit from its
  attempted theft.  In theory, if thieves know they cannot profit from
  an attack, they won't try it.  This PR seems to have been
  [inspired][C-Lightning #3832] by a Lightning-Dev mailing list
  discussion in July, see [Newsletter #104][news104 scorched earth].

  The implementation of the scorched earth policy C-Lightning uses is
  to periodically fee bump the penalty transaction, eventually
  replacing it with a transaction that spends all of its value to
  fees.  Anyone else implementing a similar policy may want to review
  this code for the way it addresses subtle potential issues such as
  minimum transaction sizes (see [Newsletter #99][news99 min]) and a
  year-old change to a maximum fee API in Bitcoin Core  (see [Newsletter
  #39][news39 maxfeerate]).

- [LND #4310][] adds the ability to create and use profiles with
  `lncli`.  A profile automatically applies its saved parameters to all
  connections, making it useful for people who always use the same
  non-default parameters or who connect to multiple servers.  For
  example, instead of calling `lncli --rpcserver=10019 --network=regtest
  getinfo`, a user may create a profile and then use just `lncli -p test
  getinfo`.  The PR additionally allows LND's authentication credentials
  ("macaroons") to optionally be stored in the profile using encryption.

- [LND #4558][] updates LND's existing [anchor outputs][topic anchor
  outputs] implementation to match the latest version of the
  specification, merged three weeks ago (see [Newsletter #112][news112
  bolts688]).  It also removes anchor outputs from the set of experimental features
  with the plan to make it enabled by default in the next major release
  of LND.

- [Rust-Lightning #618][] adds C/C++ bindings support for rust-lightning. This
  provides a framework that can be used to create APIs in other languages
  such as Swift, Java, Kotlin, and JavaScript.
  The approach chosen results in a more performant and memory-efficient method than
  alternatives such as JSON or RPC, which is particularly important on mobile and
  limited-resource environments. See the [bindings documentation][bindings readme] for more details.

- [Libsecp256k1 #558][] implements [schnorr signature][topic schnorr signatures]
  verification and single-party signing over the secp256k1 elliptic curve as
  standardized in [BIP340][]. Compared to the existing ECDSA signatures used in
  Bitcoin, schnorr signatures rely on fewer security assumptions, are
  non-malleable, and allow for much simpler key aggregation schemes such as
  [MuSig][topic musig]. Schnorr signatures are also a key component of
  [taproot][topic taproot], which uses aggregated schnorr signatures for "everyone
  agrees" key-path spends. Spending a taproot output using the key-path offers
  better spending condition privacy and reduces signature sizes. Bitcoin Core
  has correspondingly [updated][Bitcoin Core #19944] their internal libsecp256k1 tree to
  incorporate this change.

{% include references.md %}
{% include linkers/issues.md issues="4020,3812,3763,3973,3870,3832,4310,4558,618,558,19944" %}
[C-Lightning 0.9.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.1rc2
[cl 0.9.1 rn]: https://github.com/ElementsProject/lightning/blob/817a7533d16263a63f50df7557a60479622d15d6/CHANGELOG.md#091---2020-09-15-the-antiguan-btc-maximalist-society
[russell tweet]: https://twitter.com/rusty_twit/status/1304581535849275393
[russell tx]: https://blockstream.info/testnet/tx/cde8bedfec5e683298bb67116f0f33a4d6384b7947a889b226301bf28bab035c
[news112 bolts688]: /en/newsletters/2020/08/26/#bolts-688
[news22 dual]: /en/newsletters/2018/11/20/#dual-funded-channels
[news83 dual]: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news99 min]: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion
[news39 maxfeerate]: /en/newsletters/2019/03/26/#bitcoin-core-13541
[invdos paper]: https://invdos.net/paper/CVE-2018-17145.pdf
[invdos post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018164.html
[invdos site]: https://invdos.net/
[cve-2018-17145]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17145
[riard post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-September/002796.html
[square tweet]: https://twitter.com/sqcrypto/status/1304087270736236544
[copa]: https://open-patent.org/
[blockstream tweet]: https://twitter.com/Blockstream/status/1304529416131940352
[neigut interactive funding]: https://github.com/niftynei/lightning-rfc/pull/1
[news104 scorched earth]: /en/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives
[sighash]: https://btcinformation.org/en/developer-guide#signature-hash-types
[bindings readme]: https://github.com/rust-bitcoin/rust-lightning/tree/main/lightning-c-bindings
[hwi]: https://github.com/bitcoin-core/HWI
