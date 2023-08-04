---
title: 'Bitcoin Optech Newsletter #262'
permalink: /en/newsletters/2023/08/02/
name: 2023-08-02-newsletter
slug: 2023-08-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to transcripts of recent LN specification
meetings and summarizes a thread about the safety of blind MuSig2
signing.  Also included are our regular sections with descriptions
of new releases, release candidates, and notable code changes to popular
Bitcoin infrastructure software.

## News

- **Transcripts of periodic LN specification meetings:** Carla
  Kirk-Cohen [posted][kc scripts] to the Lightning-Dev mailing list to
  announce that the last several video conference meetings to discuss
  changes to the LN specification were transcribed.  The transcripts are
  now [available][btcscripts spec] on Bitcoin Transcripts.  In related
  news, as discussed a few weeks ago during the in-person LN developer
  conference, the `#lightning-dev` IRC chatroom on the [Libera.chat][]
  network has seen a significant burst of renewed activity for
  LN-related discussion. {% assign timestamp="1:13" %}

- **Safety of blind MuSig2 signing:** Tom Trevethan [posted][trevethan
  blind] to the Bitcoin-Dev mailing list to request a review of a
  cryptographic protocol planned as part of a [statechains][topic
  statechains] deployment.  The goal was to deploy a service that would
  use its private key to create a [MuSig2][topic musig] partial
  signature without gaining any knowledge about what it was signing or
  how its partial signature was used.  The blind signer would simply
  report how many signatures it had created with a particular key.

    Discussion on the list examined pitfalls of various constructions
    related to the specific problem and of [even more generalized blind
    schnorr signing][generalized blind schnorr].  Also mentioned was a
    year-old [gist][somsen gist] by Ruben Somsen about a 1996 protocol
    for blind [Diffie-Hellman (DH) key exchange][dhke], which can be used for
    blinded ecash.  [Lucre][] and [Minicash][] are previous
    implementations of this scheme unrelated to Bitcoin, and [Cashu][]
    is an implementation related to Minicash that also integrates
    support for Bitcoin and LN.  Anyone interested in cryptography may
    find the thread interesting for its discussion of cryptographic
    techniques. {% assign timestamp="5:07" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.11.1][] is the latest release of this self-hosted
  payment processor.  The 1.11.x release series includes improvements to
  invoice reporting, additional upgrades to the checkout process, and
  new features for the point of service terminal. {% assign timestamp="24:30" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26467][] allows the user to specify which output of a
  transaction is change in `bumpfee`. The wallet deducts value from
  this output to add fees when creating the [replacement transaction][topic rbf]. By
  default, the wallet attempts to detect a change output automatically
  and creates a new one if it fails to do so. {% assign timestamp="25:31" %}

- [Core Lightning #6378][] and [#6449][core lightning #6449] will mark
  an offchain incoming [HTLC][topic htlc] as failed if the node is
  unable (or unwilling because of fee costs) to time out a corresponding
  onchain HTLC.  For example, Alice's node forwards an HTLC to Bob's
  node with an expiry of 20 blocks and Bob's node forwards an HTLC with
  the same payment hash to Carol's node with an expiry of 10 blocks.
  Subsequently, the channel between Bob and Carol is forced closed
  onchain.

    After the 10-block expiry, there arises a situation that should not
    be common: Bob's node either spends using the refund condition but
    the transaction doesn't confirm, or he determines that the cost of fees to
    claim the refund are higher than the value and doesn't create a
    spend.  Prior to this PR, Bob's node wouldn't create an offchain
    cancellation of the HTLC he received from Alice because that could
    allow Alice to keep the money she forwarded to Bob and for Carol to
    claim the money Bob forwarded to her, costing Bob the amount of the
    HTLC.

    However, after the 20-block expiry of the HTLC Alice offered him, she
    can force-close the channel to attempt to receive a refund of the
    amount she forwarded to Bob, and her software may automatically do
    this to prevent Alice from potentially losing the money to a node
    upstream of her.  But, if she force-closes the channel, she
    might end up in the same position as Bob: she's either unable to
    claim the refund or doesn't attempt it because it's not economical.
    That means a useful channel between Alice and Bob was closed for no
    gain to either one of them.  This problem could be repeated multiple
    times for any hops upstream of Alice, resulting in a cascade of
    unwanted channel closures.

    The solution implemented in this PR is for Bob to wait as long as
    is reasonable to claim a refund and, if it's not going to happen,
    create an offchain cancellation of the HTLC he received from Alice,
    allowing their channel to continue operating even if it means he
    might lose the amount of the HTLC. {% assign timestamp="27:19" %}

- [Core Lightning #6399][] adds support to the `pay` command for paying
  invoices created by the local node.  This can simplify account
  management code for software that calls CLN in the background, as
  discussed in a recent [mailing list thread][fiatjaf custodial]. {% assign timestamp="33:03" %}

- [Core Lightning #6389][] adds an optional CLNRest service, "a
  lightweight Python-based Core Lightning plugin that transforms RPC
  calls into a REST service. By generating REST API endpoints, it
  enables the execution of Core Lightning's RPC methods behind the
  scenes and provides responses in JSON format."  See its
  [documentation][clnrest doc] for details. {% assign timestamp="35:48" %}

- [Core Lightning #6403][] and [#6437][core lightning #6437] move the
  runes authorization and authentication mechanism out of CLN's commando
  plugin (see [Newsletter #210][news210 commando]) and into its core
  functionality, allowing other plugins to use them.  Several
  commands related to creating, destroying, and renaming runes are also
  updated. {% assign timestamp="37:37" %}

- [Core Lightning #6398][] extends the `setchannel` RPC with a new
  `ignorefeelimits` option that will ignore the minimum onchain fee
  limits for the channel, allowing the remote channel counterparty to
  set a feerate below the minimum the local node will permit.  This can
  help work around a potential bug in another LN node implementation or
  can be used to eliminate fee contention as a source of problems in
  partly trusted channels. {% assign timestamp="39:52" %}

- [Core Lightning #5492][] adds User-level Statically Defined Tracepoints
  (USDT) and the means to use them.  These allow users to probe the
  internal operation of their node for debugging without introducing any
  significant overhead when tracepoints aren't being used.  See
  [Newsletter #133][news133 usdt] for the previous inclusion of USDT
  support into Bitcoin Core. {% assign timestamp="45:52" %}

- [Eclair #2680][] adds support for the quiescence negotiation protocol
  that is required by the [splicing protocol][topic splicing] proposed
  in [BOLTs #863][].  The quiescence protocol prevents the two nodes
  sharing a channel from sending each other any new [HTLCs][topic htlc]
  until a certain operation has completed, such as agreeing on the
  parameters of a splice and cooperatively signing the onchain splice-in
  or splice-out transaction.  An HTLC received during splice negotiation
  and signing may invalidate previous negotiations and signatures, so
  it's simpler to simply pause HTLC relay for the few network round
  trips required to get the splice transaction mutually signed.  Eclair
  already supports splicing, but this change brings it closer to
  supporting the same splicing protocol that other node software will
  likely use. {% assign timestamp="51:42" %}

- [LND #7820][] adds to the `BatchOpenChannel` RPC all the fields
  available to the non-batched `OpenChannel` RPC except for
  `funding_shim` (not needed for batched opens) and `fundmax` (you
  can't give one channel all of the balance when opening multiple
  channels). {% assign timestamp="53:57" %}

- [LND #7516][] extends the `OpenChannel` RPC with a new `utxo`
  parameter that allows specifying one or more UTXOs from the wallet
  which should be used to fund the new channel. {% assign timestamp="54:57" %}

- [BTCPay Server #5155][] adds a reporting page to the back office that provides
  payment and onchain wallet reports, the ability to export to CSV, and is
  extendable by plugins. {% assign timestamp="57:26" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="863,26467,6378,6449,6399,6389,6403,6437,6398,5492,2680,7820,7516,5155" %}
[clnrest doc]: https://github.com/rustyrussell/lightning/blob/02c2d8a9e3b450ce172e8bc50c855ac2a16f5cac/plugins/clnrest/README.md
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[kc scripts]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004025.html
[btcscripts spec]: https://btctranscripts.com/lightning-specification/
[libera.chat]: https://libera.chat/
[trevethan blind]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021792.html
[generalized blind schnorr]: https://gist.github.com/moonsettler/05f5948291ba8dba63a3985b786233bb
[somsen gist]: https://gist.github.com/RubenSomsen/be7a4760dd4596d06963d67baf140406
[lucre]: https://github.com/benlaurie/lucre
[minicash]: https://github.com/phyro/minicash
[cashu]: https://github.com/cashubtc/cashu
[fiatjaf custodial]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004008.html
[news210 commando]: /en/newsletters/2022/07/27/#core-lightning-5370
[dhke]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[btcpay server 1.11.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.11.1
