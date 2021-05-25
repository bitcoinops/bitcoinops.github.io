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

## Celebrating Optech Newsletter #150
*by [John Newbery][], Founder, Optech*

This is the 150th regular Optech weekly newsletter that we've written for the
Bitcoin technical community. Pausing only for short breaks around the Christmas
holidays, we've published digests of the most important events in Bitcoin
and Lightning development every week since June 2018.

Optech was started with some very simple goals: to help Bitcoin businesses adopt
technologies that allow Bitcoin to scale, and to highlight the amazing
technical work happening in the open source Bitcoin community. Although we
couldn't foresee exactly what form that would take three years ago, it's a
mission that we continue to believe in, and that guides all the work we do.
Since June 2018, we've:

* Published 150 [newsletters][], numerous [blog posts][] and field reports,
  a [special series on bech32][bech32], and an [interactive taproot workshop][]. In
  total, we've published around 250,000 words -- enough to fill around 700
  printed pages. <!-- wc _posts/en/newsletters/*md _posts/en/*md
  _includes/articles/*md _includes/specials/2019-exec-briefing/*md
  _includes/specials/bech32/*md-->

* Reached 4,100 email subscribers and almost 11,000 twitter followers.

* Started seeing some of our newsletters translated into [Japanese][] and
  [Spanish][] by members of the community.

* Produced and maintained a [topics index][] -- a single location where readers
  can track the evolution of Bitcoin and Lightning proposals and improvements.

The newsletters are the work of many contributors. Foremost amongst them is
[Dave Harding][], who writes the majority of our content. To say that Dave is
prolific is an understatement -- week after week, he produces concise,
clear summaries of the enormously varied research and development happening
across the Bitcoin ecosystem. We're lucky to have someone of his breadth of
knowledge, dedication and humility documenting Bitcoin. The extensive body of
work that he's produced for Optech and other projects is a huge asset for all
present and future Bitcoiners.

The supporting roles are filled by other Optechers. [Mike Schmidt][]
writes our regular sections on Stack Exchange Q&As and Notable Changes to
Bitcoin Software and Infrastructure, and makes sure that the newsletter arrives
in everyone's inbox on time. [Jon Atack][] contributes our regular summary
of Bitcoin Core PR Review Club. As well as Mike and Jon, [Carl Dong][], [Adam
Jonas][], [Mark Erhardt][] and I contribute occasional PR summaries and review
each week's newsletter to try to ensure the content we produce is accurate and
clear.

Special thanks to [Shigeyuki Azuchi][], who translates our newsletters into
Japanese, and [Akio Nakamura][] who has also translated and reviewed our
Japanese material.

Thanks to all the members of the Bitcoin community -- too numerous to name
individually -- who have reviewed our newsletters, helped us understand
concepts, and opened issues and PRs when we've made mistakes.

All of this work is made possible by our generous [supporters][], primarily
our [founding sponsors][] - Wences Casares, John Pfeffer and Alex Morcos.

Finally, thank you, our readers. We love being part of this community and
contributing to this ecosystem. Knowing how valuable this resource is to so many
people, and hearing feedback from our readers is hugely rewarding for us. If you
want to contribute, or have suggestions for how we can improve, please don't
hesitate to contact us at [info@bitcoinops.org][info].

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why are there more than two transaction outputs in a coinbase transaction?]({{bse}}105831)
  Andrew Chow explains some common outputs in a coinbase transaction:

    * a single miner block reward payment

    * multiple payments, as with a mining pool paying miners

    * [BIP141][bip141 commitment]'s `OP_RETURN` witness commitment

    * additional `OP_RETURN` commitments, as in [merge mining][se 273 merge
      mining] and other protocols

- [fundrawtransaction - what is it?]({{bse}}105811)
  Pieter Wuille illustrates what the `fundrawtransaction` RPC does by providing
  4 examples of how to send coins using the RPC.

- [What previously existing technologies made Bitcoin possible?]({{bse}}106000)
  Murch provides a summary, based on the [Bitcoin's Academic Pedigree
  paper][bitcoins academic pedigree paper], of the existing technological ingredients
  that were combined to create Bitcoin. These technologies are linked
  timestamping/verifiable logs, byzantine fault tolerance, proof of work,
  digital cash, and public keys as identities.

- [How can I follow the progress of miner signaling for Taproot activation?]({{bse}}105853)
  In addition to Hampus Sjöberg's [https://taproot.watch][taproot watch website] website, Bitcoin
  Core users can use `getblockchaininfo` to get a count of signaling blocks and
  `getblock`'s versionhex field, where the signaling version bits reside, to
  observe signaling.

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

- [Bitcoin Core #21843][] adds a `network` argument to the `getnodeaddresses`
  RPC. When `getnodeaddresses` is called with this argument set to a supported network type (`ipv4`,
  `ipv6`, `onion` or `i2p`), it will only return known addresses on the
  specified network. When called without the `network` argument,
  `getnodeaddresses` will return known addresses from all networks.

- [Eclair #1810][] makes it mandatory for peers to signal and comply with the
  `payment_secret` feature bit. The payment secrets feature thwarts [a recipient
  de-anonymization attack][payment secrets recipient deanon] and provides
  additional protection against [improper image revelation][CVE-2020-26896]. The
  feature is supported across all major implementations and is mandatory for
  payments to [LND][LND paysec] and [Rust-Lightning][RL paysec].

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
[john newbery]: https://twitter.com/jfnewbery
[newsletters]: /en/newsletters/
[blog posts]: /en/blog/
[bech32]: /en/bech32-sending-support/
[interactive taproot workshop]: /en/schorr-taproot-workshop/
[japanese]: /ja/publications/
[spanish]: /es/publications/
[topics index]: /en/topics/
[dave harding]: https://dtrt.org/
[mike schmidt]: https://twitter.com/bitschmidty
[jon atack]: https://twitter.com/jonatack
[carl dong]: https://twitter.com/carl_dong
[adam jonas]: https://twitter.com/adamcjonas
[mark erhardt]: https://twitter.com/murchandamus
[shigeyuki azuchi]: https://github.com/azuchi
[akio nakamura]: https://github.com/AkioNak
[supporters]: /#supporters
[founding sponsors]: /about/#founding-sponsors
[info]: mailto:info@bitcoinops.org
[bip141 commitment]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#commitment-structure
[se 273 merge mining]: https://bitcoin.stackexchange.com/questions/273/how-does-merged-mining-work
[bitcoins academic pedigree paper]: https://queue.acm.org/detail.cfm?id=3136559
[taproot watch website]: https://taproot.watch
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[payment secrets recipient deanon]: /en/newsletters/2019/12/04/#c-lightning-3259
[LND paysec]: /en/newsletters/2020/12/02/#lnd-4752
[RL paysec]: /en/newsletters/2021/05/05/#rust-lightning-893
