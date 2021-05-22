---
title: 'Bitcoin Optech Newsletter #150'
permalink: /en/newsletters/2021/05/26/
name: 2021-05-26-newsletter
slug: 2021-05-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a change of networks for several IRC
channels and celebrates Optech's 150th newsletter.  Also included are
our regular sections with popular questions and answers from the Bitcoin
Stack Exchange, new software releases and release candidates, and notable
changes to popular Bitcoin infrastructure projects.

## News

{% comment %}<!-- IRC move would probably be better as an Action Item,
but I'd prefer not to have an empty News section if we can avoid it -harding -->{% endcomment %}

- **IRC channels moving to Libera.Chat:** in the weekly Bitcoin Core
  developer meeting, it was [decided][bccdev meeting libera] that the
  meeting on Thursday, May 27th, will be the last meeting held on the
  Freenode network.  Bots, logging, other infrastructure, future
  meetings, and general discussion will be moved to `#bitcoin-core-dev`
  on the [Libera.Chat][] network.  Actions by the Freenode
  administrators occurring shortly before publication of this newsletter
  seem to have forced the move to occur early Wednesday morning (UTC).
  Several other channels related to
  Bitcoin and LN are also moving.  For help finding the current network
  for various channels, see the Bitcoin Wiki's [list of IRC channels][].
  If you operate a channel that's moving and don't have a Wiki account
  to update that list yourself, please let the editors know in
  `#bitcoin-wiki` on Libera.

## FIXME: anniversary

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.6.0][] is a new release that with several improvements that
  enhance user security and privacy.  It also provides compatibility
  with future software that may use [taproot][topic taproot] addresses.

- [LND 0.13.0-beta.rc3][LND 0.13.0-beta] is a release candidate that
  adds support for using a pruned Bitcoin full node, allows receiving
  and sending payments using Atomic MultiPath ([AMP][topic multipath payments]),
  and increases its [PSBT][topic psbt] capabilities, among other improvements
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*


- [Bitcoin Core #21843][] rpc: enable GetAddr, GetAddresses, and getnodeaddresses by network FIXME:jnewbery

- [Eclair #1810][] Make payment_secret mandatory FIXME:dongcarl

- [Eclair #1774][] extends Java's built-in `SecureRandom()` [CSPRNG][]
  function with a secondary source of weaker randomness.  The weaker
  randomness is hashed and the hash digest xored with the primary
  randomness so that, even if `SecureRandom()` produces predictable
  results due to some bug discovered in the future, there's a chance
  Eclair will continue to have enough entropy so that its cryptographic
  operations remain unexploitable.

- [BIPs #1089][] assigns [BIP87][] to a proposal previously [discussed
  on the mailing list][spigler independent] for creating a standardized
  set of [BIP32][] paths for multisig wallets regardless of their
  multisig parameters, what address type they use, or other script-level
  details.  Instead, users of the proposed standard store those details
  in an [output script descriptor][topic descriptors].
  This eliminates the need for wallets to implement multiple different
  standards for slight variations on multisig (e.g. [BIP45][BIP45] and
  the `m/48'` standard) or create new standards for things that can be
  handled by descriptors.  Although using a descriptor rather than a
  standardized script does mean more data needs to be backed up, the
  actual difference is small---most of the data in a typical multisig
  descriptor will be the extended public keys (xpubs) that need to be
  backed up by each party to a multisig anyway, so the additional
  information about the script template and the descriptor's checksum
  only add a small amount of overhead by comparison.

- [BIPs #1025][] assigns [BIP88][] to the standardized format described
  in [Newsletter #105][news105 path templates] for describing what BIP32
  key derivation paths a wallet should support.  Path templates provide
  a compact way for the user to specify which paths they
  want to use. The compactness of path templates makes it easy to back
  up the template along with the seed, helping prevent users from losing
  funds.  An additional feature of the proposed path templates is the
  ability to describe derivation limits (e.g. that a wallet should
  derive no more than 50,000 keys in a particular path), which can make
  it practical for a recovery procedure to scan for bitcoins received to
  all possible wallet keys, eliminating concerns about gap limits in HD
  wallets.

- [BIPs #1097][] assigns [BIP129][] to the Bitcoin Secure Multisig Setup
  (BSMS) described in [Newsletter #136][news136 bsms], which explains
  how wallets, particularly hardware signing devices, can securely exchange the
  information necessary to become signers for a multisig wallet. The
  information that needs to be exchanged includes the script template to
  use (e.g.  P2WSH with 2-of-3 keys required to sign) and each signer’s
  [BIP32][] extended public key (xpub) at the key path it plans to use
  for signing.  The protocol uses a coordinator to collect the required
  information and create an output script descriptor, which the
  individual signers then verify to ensure it properly includes their
  key.

{% include references.md %}
{% include linkers/issues.md issues="21843,1810,1774,1089,1025,1097" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc3
[news105 path templates]: /en/newsletters/2020/07/08/#proposed-bip-for-bip32-path-templates
[news136 bsms]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[csprng]: https://en.wikipedia.org/wiki/Cryptographically-secure_pseudorandom_number_generator
[eclair 0.6.0]: https://github.com/ACINQ/eclair/releases/tag/v0.6.0
[bccdev meeting libera]: http://www.erisian.com.au/bitcoin-core-dev/log-2021-05-20.html#l-582
[libera.chat]: https://libera.chat/
[list of IRC channels]: https://en.bitcoin.it/wiki/IRC_channels
[spigler independent]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018630.html
