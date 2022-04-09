---
title: 'Bitcoin Optech Newsletter #195'
permalink: /en/newsletters/2022/04/13/
name: 2022-04-13-newsletter
slug: 2022-04-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a protocol for transferring non-bitcoin
tokens in Bitcoin transactions and LN payments and links to a proposed
BIP for the MuSig2 multisignature protocol.  Also included are our
regular sections with the summary of a Bitcoin Core PR Review Club
meeting, announcements of new software releases and release candidates,
and descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **Transferable token scheme:** Olaoluwa Osuntokun  [posted][osuntokun
  taro] to the Bitcoin-Dev and Lightning-Dev mailing lists a set of
  proposed BIPs for the *Taro* protocol that will allow users
  to record the creation and transfer of non-bitcoin
  tokens on Bitcoin's block chain.  For example, Alice can issue 100 tokens, transfer 50 to Bob,
  and Bob can further exchange 25 of the tokens for 10 BTC with Carol.
  The idea is similar to previous ideas implemented for Bitcoin but
  differs in its details, such as by reusing several design elements
  from [taproot][topic taproot] to reduce the amount of new code that
  needs to be written and by using merkle trees to reduce the amount of
  data that needs to be transferred to prove certain operations occurred.

    Taro is [intended][gentry taro] to be used with LN for routable
    offchain transfers.  Similar to previous proposals for cross-asset
    transfers on LN, intermediate nodes that just route payments won't
    need to be aware of the Taro protocol or the details of the assets
    being transferred---they'll just transfer BTC using the same protocol
    as any other LN payment.

    The idea received a moderate amount of discussion on the mailing
    lists this week.

- **MuSig2 proposed BIP:** Jonas Nick, Tim Ruffing, and Elliott Jin
  [posted][nick musig2] a [proposed BIP][musig2 bip] to the Bitcoin-Dev
  mailing list for [MuSig2][topic musig], a [multisignature][topic
  multisignature] protocol for creating public keys and signatures.
  Multiple private keys controlled by separate parties or software can
  use MuSig2 to derive an aggregate public key without any of the
  separate parties needing to share any private information with each
  other.  Later, an aggregate signature may also be created, again
  without requiring the sharing of any private information.  The
  aggregate public key and aggregate signature look to third parties
  like any other public key and [schnorr signature][topic schnorr
  signatures], so it isn't revealed how many parties or private keys
  were involved in creating the aggregated keys or signatures, improving
  privacy over onchain multisig where the number of separate keys and
  signatures is revealed.

    MuSig2 is superior in almost all imagined applications over the
    original MuSig proposal (now called *MuSig1*).  MuSig2 is easier to
    implement than the alternative MuSig-DN (deterministic nonce),
    although there are tradeoffs between MuSig2 and MuSig-DN that some
    application developers may wish to consider when choosing which
    protocol to use.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:glozow

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/23542#l-FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.106][] is the latest release of this LN node library.  It
  adds support for channel identifier `alias` field proposed in [BOLTs
  #910][] which LDK uses to enhance privacy in some cases and includes
  several other features and bug fixes.

- [BTCPay Server 1.4.9][] is the latest release of this popular payment
  processing software.

- [Bitcoin Core 23.0 RC4][] is a release candidate for the next major
  version of this predominant full node software.  The [draft release
  notes][bcc23 rn] list multiple improvements that advanced users and
  system administrators are encouraged to [test][test guide] before the final release.

- [LND 0.14.3-beta.rc1][] is a release candidate with several bug fixes
  for this popular LN node software.

- [Core Lightning 0.11.0rc1][] is a release candidate for the next major
  version of this popular LN node software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24152][] policy / validation: CPFP fee bumping within packages FIXME:adamjonas

- [Bitcoin Core #24098][] updates the `/rest/headers/` and
  `/rest/blockfilterheaders/` RPCs to use query parameters for
  additional options (e.g. `?count=<count>`) as an alternative to endpoints (e.g.
  `/<count/`).  The documentation is updated to encourage use of the
  query parameters over the endpoint parameters.

- [Bitcoin Core #24147][] adds backend support for [miniscript][topic
  miniscript].  Subsequent PRs [#24148][bitcoin core #24148] and
  [#24149][bitcoin core #24149] will, if merged, add support for using
  miniscript in [output script descriptors][topic descriptors] and in
  the wallet's signing logic.

- [Core Lightning #5165][] updates the name of the C-Lightning Project
  to [Core Lightning][core lightning repo], or CLN for short.

- [Core Lightning #5068][] adds support for attaching
  `option_payment_metadata` invoice data to a payment, adding payer-side
  support for [stateless invoices][topic stateless invoices].
  Receiver-side support is not added to CLN in this PR.

{% include references.md %}
{% include linkers/issues.md v=2 issues="24152,24098,24147,24148,24149,5165,5068" %}
[bitcoin core 23.0 rc4]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[core lightning 0.11.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc1
[gentry taro]: https://lightning.engineering/posts/2022-4-5-taro-launch/
[osuntokun taro]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003539.html
[nick musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020198.html
[musig2 bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[ldk 0.0.106]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.106
[btcpay server 1.4.9]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.9
