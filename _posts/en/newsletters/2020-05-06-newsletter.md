---
title: 'Bitcoin Optech Newsletter #96'
permalink: /en/newsletters/2020/05/06/
name: 2020-05-06-newsletter
slug: 2020-05-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a discussion about using enhanced QR
codes for communicating large transactions, includes a field report from
Suredbits about building a high-availability LN node, and briefly
summarizes several recently transcribed talks and conversations.  Also
included are our regular sections with releases, release candidates, and
notable code changes from popular Bitcoin infrastructure software.

## Action items

{:.center style="font-size: 1.5em"}
<!-- $$\frac{50}{2^{\lfloor height/210000 \rfloor}}$$ -->
![Happy halving!](/img/posts/2020-05-halving.png)

## News

- **QR codes for large transactions:** QR codes can practically contain
  up to about 3 kilobytes of data, which is enough to accommodate
  typical user transactions but far too small to contain the largest
  transactions users can normally send.  Riccardo
  Casatta and Christopher Allen each posted to the Bitcoin-Dev mailing
  list ([1][casatta qr], [2][allen qr]) a request for discussion
  hopefully leading to standardization of a method for visual
  communication of [Partially Signed Bitcoin Transactions][topic psbt]
  (PSBTs) and other potentially large data blobs related to Bitcoin
  wallet interaction.  See the [previous discussion][qr old] in the
  Specter DIY repository and [continue the discussion][qr new] in the
  Airgapped Signing repository.

## Field report: running a Lightning node in an enterprise environment

{% include articles/suredbits-enterprise-ln.md %}

## Recently transcribed talks and conversations

*[Bitcoin Transcripts][] is the home for transcripts of technical
Bitcoin presentations and discussions. In this new <!-- TODO: remove "new" next month --> monthly feature, we
highlight a selection of the transcripts from the previous month.*

- **Simplicity---Next-Generation Smart Contracting** Adam Back presented at a
  Blockstream webinar on Simplicity, a next-generation, low-level
  alternative to Bitcoin Script focused on provable security and
  expressiveness. Back discussed how Simplicity, if enabled in Bitcoin
  today, would allow developers to implement new functionality like
  [SIGHASH_NOINPUT][topic sighash_noinput] without necessarily needing a soft fork. He also
  displayed a [demo][simplicity demo] showing what you can do with
  Simplicity today.  ([transcript][simplicity xs], [video][simplicity
  vid], [slides][simplicity slides])

- **Attacking Bitcoin Core** Amiti Uttarwar presented at LA BitDevs.
  Uttarwar discussed how changes to Bitcoin’s peer-to-peer layer should
  be assessed according to five goals: reliability, timeliness,
  accessibility, privacy, and upgradability. She discussed the dangers of
  network partitions and [eclipse attacks][topic eclipse attacks]---and then explained why
  block-relay-only connections and anchor nodes are effective
  mitigations.  ([transcript][attacking xs], [video][attacking vid])

- **LND v0.10** Laolu Osuntokun, Joost Jager, and Oliver Gugger
  presented in virtual reality at Reckless VR. Osuntokun presented Tor
  and RPC enhancements in the latest release of LND plus a new channel
  feature called [anchor outputs][topic anchor outputs] that addresses
  the challenge of estimating onchain fees months in advance.
  Jager discussed the challenges of [multipart payments][topic multipath
  payments] including the splitting algorithm, what happens when the
  shards of the payment arrive at different times, and strategies for
  handling multipart payment failures. Gugger ended by discussing Partially
  Signed Bitcoin Transaction ([PSBT][topic psbt]) channel funding and
  the channel abstraction work that made this possible.
  ([transcript][lnd10 xs], [video][lnd10 vid])

- **Grokking Bitcoin** Kalle Rosenbaum participated in a Bitcoin developer meetup
  and gave a presentation at London Bitcoin Devs.  The
  meetup discussion focused on the role of Bitcoin technical
  education, [BIP32][] HD wallets, and soft fork upgrades.  For the
  presentation, Rosenbaum used the content in his book to discuss how
  the segwit upgrade of 2017 addressed transaction malleability and
  quadratic hashing.  ([Meetup transcript][grok xs2], [presentation
  transcript][grok xs1], [presentation video][grok vid], [presentation
  slides][grok slides])

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.8.2][c-lightning 0.8.2] is a new version release
  that adds support for opening channels of any size (using the
  `--large-channels` configuration parameter), provides a keysend plugin
  for receiving [spontaneous payments][topic spontaneous payments], and
  contains several other new features and bug fixes. Additionally, both
  novice and experienced users are encouraged to read the project's new
  [FAQ][cl faq].

- [LND 0.10.0-beta][lnd 0.10.0-beta] is a major version release that
  adds support for sending [multipath payments][topic multipath
  payments], funding channels using an external wallet via [Partially
  Signed Bitcoin Transactions][topic psbt] (PSBTs), the ability to create
  invoices larger than 0.043 BTC, and several other new features and bug
  fixes.  Additionally, users may wish to read the new [Operational
  Safety documentation][lnd op safety].

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] is a release candidate
  for the next major version of Bitcoin Core.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Rust-Lightning][rust-lightning repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until version 0.21, about six months after the release of the upcoming
version 0.20.*

- [Bitcoin Core #16528][] allows the `createwallet` RPC to create a
  wallet that uses [output script descriptors][topic descriptors] to
  derive just the particular scriptPubKeys that the wallet uses to
  receive payments.  This is a major improvement over the way legacy
  wallets scan for payments by deriving every type of script handled by
  the wallet for each public key in the wallet---a technique that dates
  back to the original Bitcoin 0.1 release's support for receiving to
  both P2PK and P2PKH scriptPubKeys.  Descriptor wallets should be more
  efficient (because they don't need to scan for unused script types),
  easier to upgrade to new types of script (e.g. for [taproot][topic
  taproot]), and easier to use with external tools (e.g. multisig
  wallets or [HWI][topic hwi]-compatible hardware wallets via
  [partially-signed bitcoin transactions][topic psbt]).

    By default, descriptor wallets use the popular [BIP32][] HD wallet
    paths specified by BIPs [44][BIP44], [49][BIP49], and [84][BIP84]
    rather than the non-standardized fully-hardened path used in legacy
    Bitcoin Core HD wallets.  A number of wallet RPCs are unavailable
    with descriptor wallets, either because they don't make sense with
    descriptors or because developers are still adapting them to new
    edge cases.  The merge of this PR early in the 0.21 development
    cycle and the decision to make descriptor wallets a non-default
    option will give the new features six months to mature before
    their expected release.

- [Bitcoin Core #18038][] P2P: Mempool tracks locally submitted
  transactions to improve wallet privacy FIXME:bitschmidty

- [BIPs #893][] makes several changes to the [BIP340][] specification of
  [schnorr][topic schnorr signatures] pubkeys and signatures, with
  related changes also being made to the [BIP341][] specification of
  [taproot][topic taproot].  The major changes include:

    - *Alternative x-only pubkey tiebreaker:* this changes which variant
      of a public key to use when only its x-coordinate is known,
      as previously discussed (see [Newsletter #83][news83 alt
      tiebreaker]).

    - *Updated nonce generation recommendations:* the suggested method
      to use for generating a signature nonce has been updated to
      prevent implementation-specific vulnerabilities (see previous
      discussion in Newsletters [#83][news83 precomputed] and
      [#91][news91 power analysis]).

    - *Updated tagged hashes:* the tag prefixed to hash function input
      for schnorr signatures has been updated to deliberately break
      compatibility with the old draft specification.  Otherwise,
      libraries written for the old code might sometimes generate
      signatures valid under the new code, and sometimes might not,
      leading to confusion.  This was also previously mentioned in
      [Newsletter #83][news83 alt tiebreaker].

- [BIPs #903][] simplifies the [BIP322][] specification of [generic
  signed messages][topic generic signmessage] as previously proposed
  (see [Newsletter #91][news91 bip322 update]), the change mainly
  removes details that allowed signing the same message for multiple
  scripts (addresses) in the same proof.

- [BIPs #900][] updates the [BIP325][] specification of [signet][topic
  signet] so that all signets use the same hardcoded genesis block
  (block 0) but independent signets can be differentiated by their
  [network magic][] (message start bytes).  In the updated protocol, the
  message start bytes are the first four bytes of a hash digest of the
  network's challenge script (the script used to determine whether a
  block has a valid signature).  The change was [motivated][dorier
  signet] by a desire to simplify the development of applications that
  want to use multiple signets but which need to call libraries that
  hardcode the genesis blocks for the networks they support.

{% include references.md %}
{% include linkers/issues.md issues="16528,18038,893,903,900" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2
[news83 alttiebreaker]: /en/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[dorier signet]: https://github.com/bitcoin/bitcoin/pull/16411#issuecomment-577999888
[cl faq]: https://github.com/ElementsProject/lightning/blob/master/doc/FAQ.md
[news91 bip322 update]: /en/newsletters/2020/04/01/#proposed-update-to-bip322-generic-signmessage
[casatta qr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017794.html
[allen qr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017795.html
[qr old]: https://github.com/cryptoadvance/specter-diy/issues/57
[qr new]: https://github.com/BlockchainCommons/AirgappedSigning/issues/4
[lnd op safety]: https://github.com/lightningnetwork/lnd/blob/master/docs/safety.md
[news83 alt tiebreaker]: /en/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[news83 precomputed]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news91 power analysis]: /en/newsletters/2020/04/01/#mitigating-differential-power-analysis-in-schnorr-signatures
[network magic]: https://btcinformation.org/en/glossary/start-string
[bitcoin transcripts]: https://twitter.com/btctranscripts
[simplicity demo]: https://asciinema.org/a/rhIsJBixoB3k8yuFQQr2UGAQN
[simplicity xs]: https://diyhpl.us/wiki/transcripts/blockstream-webinars/2020-04-08-adam-back-simplicity/
[simplicity vid]: https://www.youtube.com/watch?v=RZNCk-nyx_A
[simplicity slides]: https://docsend.com/view/svs27jr
[attacking xs]: https://diyhpl.us/wiki/transcripts/la-bitdevs/2020-04-16-amiti-uttarwar-attacking-bitcoin-core/
[attacking vid]: https://www.youtube.com/watch?v=8TaY730YlMg
[lnd10 xs]: https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-04-18-laolu-joost-oliver-lnd0.10/
[lnd10 vid]: https://www.youtube.com/watch?v=h34fUGuDjMg
[grok xs1]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-04-29-kalle-rosenbaum-grokking-bitcoin/
[grok vid]: https://www.youtube.com/watch?v=6tHnYyaw0qw
[grok slides]: http://rosenbaum.se/ldnbitcoindev/drawing.sozi.html
[grok xs2]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-04-22-socratic-seminar/
