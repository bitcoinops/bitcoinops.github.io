---
title: 'Bitcoin Optech Newsletter #303'
permalink: /en/newsletters/2024/05/17/
name: 2024-05-17-newsletter
slug: 2024-05-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a new scheme for anonymous usage
tokens that could be used for LN channel announcements and multiple
other sybil-resistant coordination protocols, links to discussion about
a new BIP39 seed phrase splitting scheme, announces an alternative to
BitVM for verifying successful execution of arbitrary programs in
interactive contract protocols, and relays suggestions for updating the
BIPs process.

## News

- **Anonymous usage tokens:** Adam Gibson [posted][gibson autct] to
  Delving Bitcoin about a scheme he has developed to allow anyone who
  can [keypath-spend][topic taproot] a UTXO to prove they could spend it
  without revealing which UTXO it is.  This follows Gibson's previous
  work developing anti-sybil mechanisms [PoDLE][news85 podle] (used in
  the Joinmarket [coinjoin][topic coinjoin] implementation) and
  [RIDDLE][news205 riddle].

  One use he describes is announcing LN channels.  Each LN node
  announces its channels to other LN nodes so that they can find paths
  for routing funds across the network.  Much of that channel
  information is stored in memory and the announcements are often
  rebroadcast to ensure they reach as many nodes as possible.  If an
  attacker could cheaply announce fake channels, they could waste an
  excessive amount of honest nodes' memory and bandwidth in addition to
  disrupting pathfinding.  LN nodes deal with this today by
  only accepting announcements that are signed by a key that belongs to
  a valid UTXO.  <!-- ignoring for this description that the current LN
  protocol requires only P2WSH UTXOs --> That requires the channel
  co-owners to identify the specific UTXO they co-own, which may associate
  those funds with other past or future onchain transactions they create
  (or lead to someone making an inaccurate association).

  With Gibson's scheme, called anonymous usage tokens [with] curve trees
  (autct), the channel co-owners could sign a message without revealing
  their UTXO.  An attacker without a UTXO couldn't create a valid
  signature.  An attacker who did have a UTXO could create a
  valid signature---but they would have to keep as much money in that
  UTXO as an LN node would need to keep in a channel, limiting
  the worst case of any attack.  See [Newsletter #261][news261 lngossip]
  for a previous discussion of disassociating [channel
  announcements][topic channel announcements] from particular UTXOs.

  Gibson also describes several other ways autct could be used.  A
  basic mechanism for accomplishing this type of privacy---ring
  signatures---has been known for a long time, but Gibson uses a new
  cryptographic construction ([curve trees][]) to make the proofs more
  compact and faster to verify.  He also has each proof privately commit
  to the key used so a single UTXO can't be used to create an unlimited
  number of valid signatures.

  In addition to publishing [code][autct repo], Gibson also published a
  proof-of-concept [forum][hodlboard] that requires providing an autct
  proof to sign up, providing an environment where everyone is
  known to be a holder of bitcoins but no one needs to provide any
  identifying information about themselves or their bitcoins. {% assign timestamp="1:58" %}

- **BIP39 seed phrase splitting:** Rama Gan [posted][gan penlock] to the
  Bitcoin-Dev mailing list a link to a [set of tools][penlock website]
  they have developed for generating and splitting a [BIP39][] seed
  phrase without using any electronic computing equipment (except to
  print instructions and templates).  This is similar to [codex32][topic
  codex32] but operates on BIP39 seed words that are compatible with
  almost all current hardware signing devices and many software wallets.

  Andrew Poelstra, co-author of codex32, [replied][poelstra penlock1]
  with several comments and suggestions.  Without us trying both
  schemes---which would take several hours each---the exact set of
  tradeoffs between them isn't clear to us.  However, both seem to offer
  the same fundamental capabilities: instructions for securely
  generating a seed offline; the ability to split the seed into multiple
  shares using [Shamir's secret sharing][sss]; the ability to
  reconstitute the shares into the original seed; and the ability to
  verify checksums on both the shares and the original seed, allowing
  users to detect data corruption early when the original data might
  still be recoverable. {% assign timestamp="31:48" %}

- **Alternative to BitVM:** Sergio Demian Lerner and several co-authors
  [posted][lerner bitvmx] to the Bitcoin-Dev mailing list about a new
  virtual CPU architecture based in part on the ideas behind
  [BitVM][topic acc].  The goal of their project, BitVMX, is to be able
  to efficiently prove the proper execution of any program that can be
  compiled to run on an established CPU architecture, such as
  [RISC-V][].  Like BitVM, BitVMX does not require any consensus changes,
  but it does require one or more designated parties to act as a trusted
  verifier.  That means multiple users interactively participating in a
  contract protocol can prevent any one (or more) of the parties from
  withdrawing money from the contract unless that party successfully
  executes an arbitrary program specified by the contract.

  Lerner links to a [paper][bitvmx paper] about BitVMX which compares it
  to the original BitVM (see [Newsletter #273][news273 bitvm]) and to
  the limited details available about follow-up projects from the
  original BitVM developers.  An accompanying [website][bitvmx website]
  provides additional information in a slightly less technical form. {% assign timestamp="38:05" %}

- **Continued discussion about updating BIP2:** Mark "Murch" Erhardt
  [continued][erhardt bip2] the discussion on the Bitcoin-Dev mailing
  list about updating [BIP2][], which is the document that currently
  describes the Bitcoin improvement proposals (BIP) process.  His email
  describes several problems, suggests solutions for many of them,
  and solicits feedback on his suggestions as well as proposals for
  solutions to the remaining problems.  For previous discussion about
  updating BIP2, see [Newsletter #297][news297 bip2]. {% assign timestamp="40:41" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.18.0-beta.rc2][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="44:25" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Core Lightning #7190][] adds an additional offset (called `chainlag`)
  into the [HTLC][topic htlc] timelock calculation.  This allows HTLCs
  to target the current block height instead of the most recent block
  that the LN node has processed (its sync height).  This makes it safe
  for a node to send payments during the blockchain sync process. {% assign timestamp="44:51" %}

- [LDK #2973][] implements support for `OnionMessenger` to intercept [onion messages][topic onion messages] on
  behalf of offline peers. It generates events on message interception and on
  the peer's return to online status for forwarding. Users should maintain an
  _allow list_ to only store messages for relevant peers. This is a
  stepping stone to supporting [async payments][topic async payments]
  through `held_htlc_available` [BOLTs #989][].  In that protocol, Alice
  wants to pay Carol through Bob, but Alice doesn't know if Carol is
  online.  Alice sends an onion message to Bob; Bob holds the message
  until Carol comes online; Carol opens the message, which tells her to
  request a payment from Alice (or Alice's Lightning service provider);
  Carol requests the payment and Alice sends it in the normal way. {% assign timestamp="46:18" %}

- [LDK #2907][] extends `OnionMessage` handling to accept an optional
  `Responder` input and return an object `ResponseInstructions` that indicates how
  the response to the message should be handled. This change enables asynchronous
  onion messaging responses and opens the door to more complex response
  mechanisms, such as might be needed for [async payments][topic async
  payments]. {% assign timestamp="48:21" %}

- [BDK #1403][] updates the `bdk_electrum` crate to make use of new
  sync/full-scan structures introduced in [BDK #1413][], queryable `CheckPoint`
  linked list [BDK #1369][], and cheaply-clonable transactions in `Arc`
  pointers [BDK #1373][]. This change improves the performance of
  wallets scanning for transaction data using an Electrum-style server.
  It is also now an option to fetch `TxOut`s to allow for
  fee calculation on transactions received from an external wallet. {% assign timestamp="48:59" %}

- [BIPs #1458][] adds [BIP352][] which proposes [silent payments][topic silent
  payments], a protocol for reusable
  payment addresses that generate a unique onchain address each time it is
  used. The BIP draft was first discussed in [Newsletter #255][news255 bip352]. {% assign timestamp="50:57" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-21 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7190,2973,2907,1403,1458,989,1413,1369,1373" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[gibson autct]: https://delvingbitcoin.org/t/anonymous-usage-tokens-from-curve-trees-or-autct/862/
[news261 lngossip]: /en/newsletters/2023/07/26/#updated-channel-announcements
[news205 riddle]: /en/newsletters/2022/06/22/#new-riddle-anti-sybil-method
[news85 podle]: /en/newsletters/2020/02/19/#using-podle-in-ln
[curve trees]: https://eprint.iacr.org/2022/756
[autct repo]: https://github.com/AdamISZ/aut-ct
[hodlboard]: https://hodlboard.org/
[gan penlock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9bt6npqSdpuYOcaDySZDvBOwXVq_v70FBnIseMT6AXNZ4V9HylyubEaGU0S8K5TMckXTcUqQIv-FN-QLIZjj8hJbzfB9ja9S8gxKTaQ2FfM=@proton.me/
[penlock website]: https://beta.penlock.io/
[poelstra penlock1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZkIYXs7PgbjazVFk@camus/
[sss]: https://en.m.wikipedia.org/wiki/Shamir%27s_secret_sharing
[lerner bitvmx]: https://mailing-list.bitcoindevs.xyz/bitcoindev/5189939b-baaf-4366-92a7-3f3334a742fdn@googlegroups.com/
[risc-v]: https://en.wikipedia.org/wiki/RISC-V
[bitvmx paper]: https://bitvmx.org/files/bitvmx-whitepaper.pdf
[news273 bitvm]: /en/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[bitvmx website]: https://bitvmx.org/
[erhardt bip2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0bc47189-f9a6-400b-823c-442974c848d5@murch.one/
[news297 bip2]: /en/newsletters/2024/04/10/#updating-bip2
[news255 bip352]: /en/newsletters/2023/06/14/#draft-bip-for-silent-payments
