---
title: 'Bitcoin Optech Newsletter #108'
permalink: /en/newsletters/2020/07/29/
name: 2020-07-29-newsletter
slug: 2020-07-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow upgrading LN
channel commitment transaction formats without opening new channels.
Also included are our regular sections with selected questions and
answers from the Bitcoin StackExchange, recent releases and release
candidates, and notable changes to popular Bitcoin infrastructure
projects.

## Action items

*None this week.*

## News

- **Upgrading channel commitment formats:** Olaoluwa Osuntokun
  [posted][osuntokun upgrade] to the Lightning-Dev mailing list this
  week with a suggested extension to the LN specification that will
  allow two peers with an existing channel to negotiate a
  new commitment transaction using a different format.  Commitment
  transactions are used to allow LN nodes to publish the current channel
  state on chain, but the existing protocol only allows nodes to upgrade
  to new commitment formats by opening new channels.  Osuntokun's
  proposal would allow a node to signal to its peer that it wants to
  switch formats.  If the peer agrees, the two nodes would port their
  existing channel state over to the new format and then use the new
  format going forward.

    All discussion participants seemed to support the basic idea.
    Bastien Teinturier [suggested][teinturier simple] that
    it would be simplest to only allow switching commitment formats when
    channels had no pending payments (HTLCs)---implying nodes would
    need to pause sending or relaying payments in a particular channel
    in order to upgrade it.

    ZmnSCPxj [noted][zmnscpxj re-funding] that the same basic idea could
    be used to essentially update the funding transaction offchain, such
    as the case where [taproot][topic taproot]
    and [SIGHASH_ANYPREVOUT][topic sighash_noinput] are implemented,
    allowing [Eltoo][topic eltoo]-based channel commitments to be used.  In
    ZmnSCPxj's proposal, the output of the existing funding transaction
    would be paid to a new funding transaction that is kept offchain.  If
    the channel terminates with a mutual close, the original funding
    transaction output is paid to the final channel balances; otherwise,
    the offchain secondary funding transaction can be published onchain
    and the channel can be resolved using the appropriate unilateral
    close protocol.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
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

- [C-Lightning 0.9.0rc3][C-Lightning 0.9.0] is a release candidate for
  an upcoming major release.  It adds support for the updated `pay`
  command and new `keysend` RPC described in [last week's
  newsletter's][news107 notable] *notable code changes* section.  It also
  includes several other notable changes and multiple bug fixes.

- [Bitcoin Core 0.20.1rc1][Bitcoin Core 0.20.1] is a release candidate
  for an upcoming maintenance release.  In addition to bug fixes and
  some RPC behavior changes resulting from those fixes, the planned
  release provides compatibility with recent versions of [HWI][topic
  HWI] and its support for hardware wallet firmware released for the
  [fee overpayment attack][].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19473][] net: Add -networkactive option
  FIXME:bitschmidty

- [Bitcoin Core #18044][] adds support for witness txid (wtxid)
  transaction inventory announcements (`inv`) and requests (`getdata`)
  as described in BIP339 (see [Newsletter #104][news104 bip339]).  Prior
  to this merge, all Bitcoin nodes announced new unconfirmed
  transactions to their peers by the transaction's txid.  However, txids
  don't commit to the witness data in segwit transactions, so a node that
  downloads an invalid or unwanted segwit transaction can't safely
  assume that any transaction with that same txid is also invalid or
  unwanted.  That means nodes may waste bandwidth by downloading the
  same bad transaction over and over from each peer announcing that
  transaction.

    So far this hasn't been an issue---honest peers usually don't
    announce transactions they wouldn't accept themselves, so only a
    disruptive peer that wanted to waste its own upload bandwidth would
    advertise invalid or unwanted transactions.  However, one type of
    unwanted transaction today are spends of v1 segwit UTXOs---the types
    of spends the [BIP341][] specification of [taproot][topic taproot]
    plans to use.  If taproot activates, this means newer taproot-aware
    nodes will advertise taproot spends to older taproot-unaware nodes.
    Each time one those taproot-unaware nodes receives a
    taproot-spending transaction, it will download it, realize it uses
    v1 segwit, and throw it away.  This could be very wasteful of
    network bandwidth, both for older taproot-unaware nodes and newer
    taproot-aware nodes.  This same problem applies to other proposed
    changes to network relay policy.

    The solution implemented in this merged PR is to announce
    transactions by their wtxid---which includes a commitment to the
    witness data for segwit transactions.  A taproot implementation in
    Bitcoin Core (see [PR #17977][Bitcoin Core #17977]) could then only
    relay transactions by their wtxid to prevent newer nodes from
    accidentally spamming older nodes.

    However, after this PR was merged into Bitcoin Core's master
    development branch, it was [discussed][meeting xscript] during the
    weekly Bitcoin Core Development Meeting whether taproot's soft
    dependency on wtxid relay will make it more complicated to backport
    taproot to the current 0.20.x branch of Bitcoin Core.  Four options
    were mentioned during the meeting and in subsequent discussions:

    1. **Backport wtxid:** both wtxid relay and taproot will be
       backported if there's a 0.20.x taproot release.  John Newbery has
       already created a [wtxid relay backport][].

    2. **Don't backport wtxid:** only backport taproot and just accept that
       transaction announcements will use more bandwidth than usual
       until everyone has upgraded to wtxid-using nodes.

    3. **Don't relay taproot:** only backport taproot but don't enable
       relaying of taproot transactions on backported nodes.  This
       prevents the immediate bandwidth waste but it may make it harder to
       get taproot-spending transactions to miners and will reduce the
       speed and efficiency of [BIP152][] compact blocks.  Worse compact
       block performance may temporarily increase the number of stale
       blocks that miners create (especially since the [public FIBRE
       network][] has recently shut down).

    4. **Don't backport anything:** don't backport wtxid relay or
       taproot---let taproot wait until some time after the release of Bitcoin
       Core 0.21, roughly [expected][Bitcoin Core #18947] in December
       2020.

    No clear conclusion on which of these options to follow has been
    reached.

- [Eclair #1485][] adds support for [spontaneous payments][topic
  spontaneous payments] using the same keysend protocol previously
  implemented by LND (see [Newsletter #30][news30 spont]) and
  C-Lightning (see Newsletters [#94][news94 keysend plugin] and
  [#107][news107 keysend rpc]).  This merged PR supports both receiving
  spontaneous payments (labeled as donations) and sending payments
  using the new `sendWithPreimage` method.

- [Eclair #1484][] adds low-level support for the changes to commitment
  transactions for [anchor outputs][topic anchor outputs].  Not yet
  added is higher-level support that will allow Eclair to negotiate
  the use of anchor outputs with peers, but this early step does pass
  all [proposed test vectors][BOLTs #688 eclair tests].

- [LND #4455][] PSBT: add no_publish flag for safe batch channel opens v2 FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="19473,18044,17977,18947,1485,1484,4455" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0rc3
[Bitcoin Core 0.20.1]: https://bitcoincore.org/bin/bitcoin-core-0.20.1/
[fee overpayment attack]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[osuntokun upgrade]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002763.html
[teinturier simple]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002764.html
[zmnscpxj re-funding]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-July/002765.html
[news104 bip339]: /en/newsletters/2020/07/01/#bips-933
[news30 spont]: /en/newsletters/2019/01/22/#pr-opened-for-spontaneous-ln-payments
[news94 keysend plugin]: /en/newsletters/2020/04/22/#c-lightning-3611
[news107 keysend rpc]: /en/newsletters/2020/07/22/#c-lightning-3792
[meeting xscript]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2020/bitcoin-core-dev.2020-07-23-19.00.log.html#l-63
[news107 notable]: /en/newsletters/2020/07/22/#notable-code-and-documentation-changes
[bolts #688 eclair tests]: https://github.com/lightningnetwork/lightning-rfc/pull/688#issuecomment-656737250
[public fibre network]: http://bitcoinfibre.org/public-network.html
[wtxid relay backport]: https://github.com/bitcoin/bitcoin/pull/19606
