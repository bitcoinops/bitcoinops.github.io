---
title: 'Bitcoin Optech Newsletter #433'
permalink: /en/newsletters/2026/11/27/
name: 2026-11-27-newsletter
slug: 2026-11-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability affecting older versions of
Bitcoin Core, summarizes the disclosure of a denial-of-service vulnerability in
Core Lightning, and relays discussion about refreshing the BIP editor team.
Also included are our regular sections with selected questions and answers
from the Bitcoin Stack Exchange, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Disclosure of a medium-severity vulnerability in Bitcoin Core:** Greg
  Sanders [posted][sanders adv ml] to the Bitcoin-Dev mailing list a Bitcoin
  Core [security advisory][core orphan inv stall] for a vulnerability that
  allowed a peer to temporarily stop a node from processing blocks and
  transactions. It affects all 29.x releases, 30.x before [30.5][core 30.5],
  and 31.x before [31.3][core 31.3]. Version 32.1 already includes the fix.
  The 29.x series has reached end of life and will not receive a fix, so its
  users should upgrade to a maintained release.

  Bitcoin Core stores transactions whose parents it has not yet seen, called
  orphans. Since 29.0, each time a peer announced the wtxid of a stored
  orphan, the node checked every parent of that orphan against its mempool
  and its filters of recently seen transactions. An `inv` message can contain
  up to 50,000 announcements, and duplicates were not skipped. An attacker
  could send an orphan with thousands of missing parents, followed by `inv`
  messages repeating its wtxid 50,000 times. According to the advisory, each
  such message stalled the node for over a dozen seconds, during which it
  processed no messages from other peers, including blocks. [Bitcoin Core
  #35878][] now processes each announced transaction only once per `inv`
  message.

  The vulnerability was discovered in July by Project Loupe, [responsibly
  disclosed][topic responsible disclosures] by Sanders, and independently
  reported by stutxo in August. Because it was classified as easily
  discoverable (see [Newsletter #429][news429 policy]), the advisory was
  published alongside 30.5 and 31.3.

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

{% include snippets/recap-ad.md when="2026-12-01 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35878" %}
[sanders adv ml]: https://groups.google.com/g/bitcoindev/c/lFzWO5W9pBE
[core orphan inv stall]: https://bitcoincore.org/en/2026/11/20/disclose-orphan-inv-stall/
[core 31.3]: https://bitcoincore.org/en/2026/11/20/release-31.3/
[core 30.5]: https://bitcoincore.org/en/2026/11/20/release-30.5/
[news429 policy]: /en/newsletters/2026/10/30/#bitcoin-core-security-policy-update
