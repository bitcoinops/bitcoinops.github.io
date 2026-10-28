---
title: 'Bitcoin Optech Newsletter #429'
permalink: /en/newsletters/2026/10/30/
name: 2026-10-30-newsletter
slug: 2026-10-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a protocol for creating silent payment
transactions from multiparty wallets, summarizes the responsible disclosure of
a denial-of-service vulnerability that affected older versions of Core
Lightning, and explains Bitcoin Core's updated security policy for easily
discoverable vulnerabilities. Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange, announcements
of new releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Silent payments for multiparty wallets**: Oleksandr Kurbatov
  [posted][sp multi del] to Delving Bitcoin to describe a protocol
  to use multiparty inputs in [silent payment][topic silent payments]
  transactions. [BIP352][] does not recommend using that kind of
  input due to lack of a security proof. The protocol allows
  a multiparty sender to compute the ECDH share as a weighted sum of
  the signers' contributions, while providing an aggregated
  [DLEQ][topic dleq] proof, called AggDLEQ, to prove that the ECDH
  share is correctly derived from the input key. The proposal works
  with several multiparty protocols, such as [FROST][BIPs #2070]
  and [MuSig2][topic musig].

  The proposed protocol relies on two rounds. A coordinator provides
  context, containing signer set, signing protocol coefficients and
  tweak, key material, the transaction, and a session ID. During the
  first round, each signer generates two random nonces and sends messages
  needed for AggDLEQ back to the coordinator, such as the ECDH
  share computed from their own key fragment and nonce commitments.
  Those messages are used by the coordinator to compute the combined
  ECDH share and a challenge. During the second round, each signer
  produces a contribution to the proof based on the provided challenge.
  If the responses are correct, the coordinator aggregates all the
  responses into a single proof compatible with [BIP374][].

  Kurbatov stated that the protocol needs no changes to BIP352, BIP374,
  BIP375, or the MuSig2 and FROST signing protocols, and no new PSBT
  fields, because the AggDLEQ messages are exchanged only between the
  signers over the wallet's coordinator channel. He said a paper with
  security proofs is under internal review, but noted that its claim that
  corrupted signers and the coordinator cannot forge a proof or a
  signature relies on an assumption whose hardness is an open question.

FIXME:bitschmidty

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

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-11-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2070" %}

[sp multi del]: https://delvingbitcoin.org/t/silent-payments-for-multiparty-wallets/2960
