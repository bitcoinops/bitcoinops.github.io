---
title: 'Bitcoin Optech Newsletter #205'
permalink: /en/newsletters/2022/06/22/
name: 2022-06-22-newsletter
slug: 2022-06-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed option for Bitcoin Core that
would make it easier to enable transaction replacement even for
transactions that don't opt-in to BIP125, links to information about the
Hertzbleed sidechannel vulnerability, summarizes the conclusion of a
discussion about time stamping system design, and examines a new
anti-sybil protocol that uses Bitcoin UTXOs.  Also included are our
regular sections with descriptions of interesting new features in Bitcoin
clients and services, announcements of new releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Full replace by fee:** [two][bitcoin core #25353] pull
  [requests][bitcoin core #25373] have been opened to add support to
  Bitcoin Core for full Replace By Fee ([RBF][topic rbf]) as an option
  that is off by default.  If enabled, any unconfirmed transaction in
  that node's mempool could be replaced by an alternative version of
  that transaction which pays a higher feerate (among other rules).

  Currently Bitcoin Core only allows RBF if the version of the
  transaction to be replaced has a signaling bit enabled, as defined in
  [BIP125][].  This creates a challenge for multiparty contract
  protocols, such as LN and [DLCs][topic dlc], where it is sometimes
  possible for one party to remove the BIP125 signal from a transaction
  in order to prevent other parties from using transaction replacement.
  This can lead to delays, and in the worst case it may lead to a loss
  of funds in protocols that depend on timely confirmation (such as for
  [HTLCs][topic htlc]).

  [One of the PRs][bitcoin core #25353] quickly received significant
  developer support.  Because it only adds the ability to enable full
  RBF---but does not enable it by default---it does not change Bitcoin
  Core's current default behavior.  In the long-term, some developers
  will likely advocate for enabling full RBF by default, so a thread was
  [started][rbf discussion] on the Bitcoin-Dev mailing list this week to
  give developers of services, applications, and alternative full node
  software a chance to argue against the direction of providing a full
  RBF option and perhaps eventually enabling it by default.

- **Hertzbleed:** a recently [disclosed][hertzbleed] security
  vulnerability affecting many (perhaps all) popular laptop, desktop,
  and server CPU processors may allow attackers to discover private keys
  when those keys are being used to create signatures for Bitcoin
  transactions (or perform other similar operations).  The noteworthy
  aspect of this attack is that it may affect signature generation code
  that was specifically written to always use the same type and number
  of CPU operations in order to prevent leaking information to
  attackers.

  Exploiting the vulnerability would require an attacker to measure
  either the power consumption of a CPU chip or measure the duration
  of parts of the signing operation.  Ideally for an attacker, they
  would be able to take measurements while a user creates many
  signatures using the same private key.  As such, the vulnerability is
  more likely to affect frequently used hot wallets, such as those used
  by hosted services and LN routing nodes, and cases of [address
  reuse][topic output linking].  Mostly or entirely offline
  wallets that are used in secure environments would be much more
  resistant to attacks.

  As of this writing, it isn't entirely clear how significant the
  vulnerability is for Bitcoin users.  Many wallets today, including
  several popular hardware signing devices, are already known to use
  signature generation code that's vulnerable to power and timing
  analysis, so perhaps nothing is changed for those users.  For users of
  more secure code, it is possible that developers will implement
  additional protections.  If you have any questions or concerns about
  the software you use, please contact its developers through the
  appropriate support channels (such as [Bitcoin Stack Exchange][] for
  many free and open source software Bitcoin projects).

- **Timestamping design:** A protracted debate on the Bitcoin-Dev
  mailing list about the design of the Bitcoin-based [Open Timestamps][]
  (OTS) system seemed to [conclude][poelstra timestamping] this week.
  The source of the debate appears to have been the existence of two
  different designs for time stamping systems:

    - *Time Stamped Proofs of Existence (TSPoE):* a Bitcoin transaction
      commits to a hash digest which commits to a document.  When the
      transaction is confirmed in a block, it's possible for the creator
      of the commitment to prove to third parties that the document
      existed at the time the block was created.  Notably, each time
      stamping transaction can be completely independent from other time
      stamping transactions, meaning it's possible to timestamp the same
      document multiple times with no connection between the time
      stamps.

    - *Event Ordering (EO):* a series of transactions all related to
      each other in a specified manner each commits to documents in a
      way that allows any user of the system to see all the commitments.
      For any document that is timestamped two or more times under this
      system, it is possible to determine when it was first timestamped.

  The TSPoE system as implemented by OTS is essentially perfectly
  efficient.  It uses the same amount of global storage space to time
  stamp an unlimited number of documents, with each person who requests
  a timestamp being responsible for storing their time stamp proofs.
  This system also has the advantage of being simple both in concept and
  implementation.

  The EO system requires all full participants store the commitments to
  every document.  This can be much less efficient and adds complexity.
  The tradeoff is that it does allow participants to verify when a
  document was first published to the system.

  The discussion did not lead to any announced changes in any system or
  proposal, such as Open Timestamps or transaction sponsorship (the
  original topic of discussion, see [Newsletter #116][news116
  sponsorship]).  It did seem to surprise several discussion
  participants that they could each have different concepts of what
  "time stamping" implied.

- **New RIDDLE anti-sybil method:** Adam "Waxwing" Gibson
  [posted][gibson riddle post] to the Bitcoin-Dev mailing list a
  [proposal][gibson riddle gist] for an [anti-sybil][sybil] mechanism
  that uses the Bitcoin UTXO set and which can provide reasonably good
  privacy.  A user can generate a list of UTXOs where one of the UTXOs
  belongs to the user and the rest belong to other users.  The user then
  creates a signature which provably came from an owner
  of one of the listed UTXOs but does not reveal which owner created it.

  A malicious user could generate many such proofs but only a finite
  number of them before they exhaust the pool of options, restricting
  their ability to overconsume scarce network resources.  The malicious
  user could also use a UTXO for as long as possible and then spend it
  to obtain a new UTXO, but this would incur a transaction fee.  That
  costliness also deters abuse.  Services could further limit
  sybils by limiting which UTXOs the user could select.  For example, a
  service might only accept a signature over UTXOs that are 1 BTC in
  value and which have remained unspent for a year.

  Gibson proposes that membership proofs could come in two forms: a
  global proof and a local proofs.  Global proofs would be shared
  between verifiers so that, under ideal conditions, a user could only
  create one proof per UTXO in the global context.  For example, the
  user would only be able to sign up for one account for each year-old
  UTXO worth 1 BTC.

  Local contexts would be specific to a single verifier (or a group of
  associated verifiers, such as on a decentralized exchange).  For
  example, a user could use a UTXO to access APIs on service A and then
  reuse the same UTXO for service B.

  Additionally, high value UTXOs could be treated as multiple UTXOs of a
  lower value, so a 10 BTC UTXO could allow a user to sign up for 10
  different accounts at different services each requiring 1 BTC of
  capital in the global context.

  Although the RIDDLE protocol does provide privacy advantages over
  other anti-sybil mechanisms, Gibson does warn that information from
  use of the system can be combined with other available information to
  potentially reduce the user's privacy.  He writes, "there is no
  possibility that this kind of system can provide iron-clad privacy
  guarantees. If protecting the location of the real signing utxo is a
  matter of life and death, on no account use a system like this!"

  On the Lightning-Dev mailing list, developer [[ZmnSCPxj]]
  [suggested][zmnscpxj riddle] RIDDLE might be an option for separating
  LN's anti-sybil mechanism from UTXO-based channel identifiers which,
  in the era of [taproot][topic taproot] and [signature
  aggregation][topic musig], unnecessarily disclose which onchain
  transactions are LN channel opens and mutual closes.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Zeus adds taproot support:**
  [Zeus v0.6.5-rc1][] adds [taproot][topic taproot] send and receive support for LND v0.15+ backends.

- **Wasabi Wallet 2.0 released:**
  This [coinjoin][topic coinjoin] software [release][wasabi 2.0] implements the
  [WabiSabi protocol][news194 wabisabi] among other improvements.

- **Sparrow adds taproot hardware signing:**
  By upgrading to [HWI 2.1.0][], Sparrow [1.6.4][sparrow 1.6.4] adds taproot
  signing support for certain hardware signing devices.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.0-beta.rc6][] is a release candidate for the next major
  version of this popular LN node.

- [LDK 0.0.108][] and 0.0.107 are releases that add support for [large
  channels][topic large channels] and [zero-conf channels][topic
  zero-conf channels] in addition to providing code that allows mobile
  clients to sync network routing information (*gossip*) from a server,
  plus other features and bug fixes.

- [BDK 0.19.0][] adds experimental support for [taproot][topic taproot]
  through [descriptors][topic descriptors], [PSBTs][topic psbt], and
  other sub-systems.  It also adds a new [coin selection
  algorithm][topic coin selection].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core GUI #602][] writes settings changed in the GUI to a file
  also loaded by the headless daemon (`bitcoind`) so the changed
  settings are used no matter how the user starts Bitcoin Core.

- [Eclair #2224][] adds support Short Channel Identifier (scid) aliases
  and the [zero-conf channel][topic zero-conf channels] type.  The scid
  aliases can improve privacy and also make it possible for nodes to
  easily refer to a channel before it has been sufficiently confirmed.
  Zero-conf channels allow two nodes to agree to use a channel for
  routing payments before it has been sufficiently confirmed, which can
  be secure under certain restraints.

- [HWI #611][] adds single-sig support for [bech32m addresses][topic
  bech32] with the BitBox02 hardware signing device.

{% include references.md %}
{% include linkers/issues.md v=2 issues="602,2224,611,25353,25373" %}
[lnd 0.15.0-beta.rc6]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc6
[ldk 0.0.108]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.108
[bdk 0.19.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.19.0
[rbf discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020557.html
[hertzbleed]: https://www.hertzbleed.com/
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[poelstra timestamping]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020569.html
[gibson riddle post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020555.html
[gibson riddle gist]: https://gist.github.com/AdamISZ/51349418be08be22aa2b4b469e3be92f
[bitcoin stack exchange]: https://bitcoin.stackexchange.com/
[open timestamps]: https://opentimestamps.org/
[sybil]: https://en.wikipedia.org/wiki/Sybil_attack
[zmnscpxj riddle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003607.html
[Zeus v0.6.5-rc1]: https://github.com/ZeusLN/zeus/releases/tag/v0.6.5-rc1
[wasabi 2.0]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.0.0
[news194 wabisabi]: /en/newsletters/2022/04/06/#wabisabi-alternative-to-payjoin
[HWI 2.1.0]: /en/newsletters/2022/03/23/#hwi-2-1-0-rc-1
[sparrow 1.6.4]: https://github.com/sparrowwallet/sparrow/releases/tag/1.6.4
