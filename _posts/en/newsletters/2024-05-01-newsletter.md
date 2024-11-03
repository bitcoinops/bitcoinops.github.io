---
title: 'Bitcoin Optech Newsletter #300'
permalink: /en/newsletters/2024/05/01/
name: 2024-05-01-newsletter
slug: 2024-05-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a CTV-like proposal that uses
commitments embedded in public keys, examines the analysis of a contract
protocol with Alloy, announces the arrests of Bitcoin developers, and
links to summaries of a CoreDev.tech developer meetup.  Also included
are our regular sections announcing new releases and release candidates
and summarizing notable changes to popular Bitcoin infrastructure
software.

## News

- **CTV-like exploding keys proposal:** Tadge Dryja [posted][dryja
  exploding] to Delving Bitcoin a proposal for a slightly more efficient
  version of the core idea of [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV).  With CTV, Alice can pay to an output
  like:

  ```text
  OP_CTV <hash>
  ```

  The preimage for the hash digest is a commitment to the key parts of a
  transaction, most especially the amount of each output and the script
  to pay for each output. For example:

  ```text
  hash(
    2 BTC to KeyB,
    3 BTC to KeyC,
    4 BTC to KeyD
  )
  ```

  The `OP_CTV` opcode will succeed if it's executed in a transaction
  that exactly matches those parameters.  That means Alice's output in
  one transaction can be spent in a second transaction without requiring
  an additional signature or any other data, as long as that second
  transaction matches what Alice expected.

  Dryja suggests an alternative method.  Alice pays to a public key
  (similar to a [taproot][topic taproot] output but with a different
  segwit version).  The public key is constructed from a [MuSig2][topic
  musig] aggregation of one or more actual public keys plus a tweak for
  each key that securely commits to an amount.  For example (adapted
  from Dryja's post):

  ```text
  musig2(
    KeyB + hash(2 BTC, KeyB)*G,
    KeyC + hash(3 BTC, KeyC)*G,
    KeyD + hash(4 BTC, KeyD)*G
  )
  ```

  A transaction will be valid if it pays the underlying public keys in
  exactly the amounts specified.  No signature is required in that case.
  This saves some space when compared to CTV in taproot, a
  minimum of about 16 vbytes<!-- for CTV, the internal key needs to be
  revealed (~8 vbytes) and the CTV tapscript needs to be revealed (~8
  vbytes)-->.  It seems to use about the same amount of space when compared to CTV
  in a bare script (i.e., directly placed in an output script).

  When CTV is used in taproot, a keypath spend mutually agreed upon by
  all involved can be provided as an alternative to executing the CTV,
  allowing the parties to change where the funds go.  Exploding keys
  allows the same thing by the people who control KeyB, KeyC, KeyD.
  The efficiency is the same either way.

  Dryja writes that exploding keys "gives the basic functionality of
  OP_CTV, while saving a few bytes of witness data. On its own it's
  maybe not all that compelling, but I wanted to put it out there as
  maybe it could be a useful primitive as part of a more complex
  covenant construction." {% assign timestamp="0:59" %}

- **Analyzing a contract protocol with Alloy:** Dmitry Petukhov
  [posted][petukhov alloy] to Delving Bitcoin a [specification][petukhov
  spec] he had created using the [Alloy][] specification language for
  the simple `OP_CAT`-based vault described in [Newsletter #291][news291
  catvault].  Petukhov used Alloy to [find][petukhov mods] several
  useful modifications and to highlight important constraints
  that any potential implementors should observe.  We recommend anyone
  interested in formal
  modeling of contract protocols read his post and his extensively
  documented specification. {% assign timestamp="13:07" %}

- **Arrests of Bitcoin developers:** as widely reported elsewhere, two
  developers of the Samourai privacy-enhanced Bitcoin wallet were
  arrested last week in relation to their software, based on charges by
  U.S. law enforcement.  Subsequently, two other companies have
  announced their intention to stop serving U.S. customers due to the
  legal risks.

  Optech's specialty is writing about Bitcoin technology, so we plan to
  leave reporting about this legal situation to other publications---but
  we urge anyone interested in the success of Bitcoin, especially those
  in the U.S. or with ties to its people, to stay informed and to
  consider offering support when opportunities arise. {% assign timestamp="22:37" %}

- **CoreDev.tech Berlin event:** many Bitcoin Core contributors met in person
  for a periodic [CoreDev.tech][] event last month in Berlin.
  [Transcripts][coredev xs] for some of the sessions from the event have been
  provided by attendees.  Presentations, code reviews, working groups, or other
  sessions covered, among other topics:

  - ASMap research findings
  - assumeUTXO Mainnet Readiness
  - BTC Lisp
  - CMake
  - cluster mempool
  - coin selection
  - cross-input signature aggregation
  - current network spam
  - fee estimation
  - general BIP discussion
  - great consensus cleanup
  - GUI discussions
  - legacy wallet removal
  - libbitcoinkernel
  - MuSig2
  - P2P monitoring
  - package relay review
  - private transaction broadcasting
  - review of current GitHub Issues
  - review of current GitHub PRs
  - signet/testnet4
  - silent payments
  - Stratum v2 template provider
  - warnet
  - weak blocks

 {% assign timestamp="28:53" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Inquisition 25.2][] is the latest release of this
  experimental full node designed for testing protocol changes on
  [signet][topic signet].  The latest version adds support for
  [OP_CAT][topic op_cat] on signet. {% assign timestamp="31:35" %}

- [LND v0.18.0-beta.rc1][] is a release candidate for the next major
  version of this popular LN node. {% assign timestamp="35:59" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #27679][] allows notifications sent using the [ZMQ][]
  dispatcher to be published to a Unix domain socket.  This was
  previously supported (possibly unintentionally) by passing a configuration
  option in a way that wasn't documented.  [Bitcoin Core #22087][] made
  configuration option parsing more strict, breaking the undocumented
  support in Bitcoin Core 27.0, which [affected LND][gugger zmq] and
  possibly other programs.  This PR makes the option officially
  supported and slightly changes its semantics to make it consistent
  with other options for Unix sockets in Bitcoin Core, such as the
  change described in [Newsletter #294][news294 sockets]. {% assign timestamp="36:48" %}

- [Core Lightning #7240][] adds support for retrieving required blocks
  from the Bitcoin P2P network if the local Bitcoin node has pruned
  them.  If the CLN node needs a block that has been pruned by its local
  `bitcoind`, it will call the Bitcoin Core RPC `getblockfrompeer` to
  request it from a peer.  If the block is successfully retrieved,
  Bitcoin Core authenticates it by connecting it to the header
  it keeps (even for pruned blocks) and saves it locally, where it
  can be retrieved using standard block-retrieval RPCs. {% assign timestamp="39:39" %}

- [Eclair #2851][] begins depending on Bitcoin Core 26.1 or greater and
  removes code for ancestor-aware funding.  Instead, the upgrade allows
  it to use Bitcoin Core's new native code that is designed to compensate for any _fee
  deficit_ (see [Newsletter #269][news269 fee deficit]). {% assign timestamp="43:39" %}

- [LND #8147][], [#8422][lnd #8422], [#8423][lnd #8423], [#8148][lnd
  #8148], [#8667][lnd #8667], and [#8674][lnd #8674] replace LND's old
  sweeper with a new implementation, allowing the broadcast of
  settlement transactions and any transactions needed to effectively fee
  bump them.  Both the old and new implementations mostly accept the
  same parameters, such as the deadline by which the transaction must be
  confirmed and the starting feerate to use, with the new implementation
  also adding a `budget` that is the maximum amount to pay in fees.  The
  new implementation provides more configurability, makes writing tests
  easier, makes use of both [CPFP][topic cpfp] and [RBF][topic rbf] fee
  bumping (each when appropriate), does a better job of batching fee
  bumps to save on fees, and only updates feerates each block rather
  than every 30 seconds. {% assign timestamp="45:49" %}

- [LND #8627][] now defaults to rejecting user-requested changes to
  channel settings that require above-zero _inbound forwarding fees_.  For
  example, imagine Alice wants to forward a payment through Bob to
  Carol.  By default, Bob can no longer use the newly-added LND feature
  for inbound forwarding fees (see [Newsletter #297][news297 inbound])
  to require that Alice pay extra.  This new default ensures that Bob's
  node remains compatible with nodes that don't support inbound
  forwarding fees (which is currently almost all LN nodes).  Bob can
  choose to be backwards incompatible by overriding the default with the
  `accept-positive-inbound-fees` LND configuration setting, or he can
  possibly achieve the desired result while remaining backwards
  compatible by raising his outbound forwarding fee to Carol and then
  using negative inbound forwarding fees to offer discounts on payments
  that don't originate from Alice. {% assign timestamp="47:37" %}

- [Libsecp256k1 #1058][] changes the algorithm used for generating
  public keys and signatures.  Both the old algorithm and the new
  algorithm run in constant time to avoid creating timing
  [side-channel][topic side channels] vulnerabilities.  Benchmarks with the
  new algorithm show it to be about 12% faster.  A [short blog
  post][stratospher comb] by one of the PR reviewers describes how the
  new algorithm works. {% assign timestamp="1:00:01" %}

- [BIPs #1382][] assigns [BIP331][] to the proposal for [ancestor
  package relay][topic package relay]. {% assign timestamp="1:02:01" %}

- [BIPs #1068][] swaps two parameters in [BIP47][] version 1 reusable
  payment codes to match an implementation in Samourai wallet.  Details
  about where to find information for later versions of reusable
  payment codes is also added to the BIP.  Note that Samourai's initial
  implementation of BIP47 occurred years ago and that this PR was open
  for over three years before its merge this past week. {% assign timestamp="1:03:35" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27679,7240,2851,22087,8147,8422,8423,8148,8667,8627,1058,1382,1068,8674" %}
[gugger zmq]: https://github.com/lightningnetwork/lnd/pull/8664#issuecomment-2065802617
[news269 fee deficit]: /en/newsletters/2023/09/20/#bitcoin-core-26152
[news 297 inbound]: /en/newsletters/2024/04/10/#lnd-6703
[stratospher comb]: https://github.com/stratospher/blogosphere/blob/main/sdmc.md
[petukhov alloy]: https://delvingbitcoin.org/t/analyzing-simple-vault-covenant-with-alloy/819
[petukhov mods]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576/16
[petukhov spec]: https://gist.github.com/dgpv/514134c9727653b64d675d7513f983dd
[alloy]: https://en.wikipedia.org/wiki/Alloy_(specification_language)
[dryja exploding]: https://delvingbitcoin.org/t/exploding-keys-covenant-construction/832
[zmq]: https://en.wikipedia.org/wiki/ZeroMQ
[news291 catvault]: /en/newsletters/2024/02/28/#simple-vault-prototype-using-op-cat
[news297 inbound]: /en/newsletters/2024/04/10/#lnd-6703
[news294 sockets]: /en/newsletters/2024/03/20/#bitcoin-core-27375
[bitcoin inquisition 25.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v25.2-inq
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[coredev.tech]: https://coredev.tech/
[coredev xs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-04/
