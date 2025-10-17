---
title: 'Bitcoin Optech Newsletter #376'
permalink: /en/newsletters/2025/10/17/
name: 2025-10-17-newsletter
slug: 2025-10-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares an update on the proposal for nodes to share their
current block template and summarizes a paper outlining a covenant-less vault
construction. Also included are our regular sections announcing new releases and
release candidates and describing notable changes to popular Bitcoin
infrastructure software.

## News


- **B-SSL a Secure Bitcoin Signing Layer:** Francesco Madonna [posted][francesco
  post] to Delving Bitcoin about a concept which is a covenant-less
  [vault][topic vaults] model using [taproot][topic taproot],
  [`OP_CHECKSEQUENCEVERIFY`][op_csv], and [`OP_CHECKLOCKTIMEVERIFY`][op_cltv].
  In the post, he mentions that it uses existing Bitcoin primitives, which is
  important because most vault proposals require a soft fork.

  In the design, there are three different spend paths:

  1. A fast path for normal operation where an optional Convenience Service (CS)
  can enforce the chosen delay.

  2. A one-year fallback with custodian B.

  3. A three-year custodian path in case of disappearance or inheritance events.

  There are 6 different keys A, A₁, B, B₁, C and CS where B₁, and C are
  custodially held and are only used at the same time in the recovery path.

  This setup creates an environment where the user can lock up their funds and
  be fairly sure that the custodians they have entrusted their funds to won’t
  steal. While this does not restrict where the funds can move to like a
  [covenant][topic covenants] would, this setup does provide a more resilient
  scheme for self-custody with custodians. In the post, Francesco calls for
  readers to review and discuss the [white paper][bssl whitepaper] before anyone
  tries to implement this idea.

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

{% include snippets/recap-ad.md when="2025-10-21 16:30" %}
{% include references.md %}
[francesco post]: https://delvingbitcoin.org/t/concept-review-b-ssl-bitcoin-secure-signing-layer-covenant-free-vault-model-using-taproot-csv-and-cltv/2047
[op_cltv]: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
[op_csv]: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
[bssl whitepaper]: https://github.com/ilghan/bssl-whitepaper/blob/main/B-SSL_WP_Oct_11_2025.pdf
