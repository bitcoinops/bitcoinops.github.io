---
title: 'Bitcoin Optech Newsletter #94'
permalink: /en/newsletters/2020/04/22/
name: 2020-04-22-newsletter
slug: 2020-04-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a prototype for creating vaults using
pre-signed transactions and includes our regular sections about notable
changes to services, client software, and popular Bitcoin infrastructure
projects.

## Action items

*None this week.*

## News

- **Vaults prototype:** Bryan Bishop has [announced][bishop vaults] a
  Python-language [prototype][vaults prototype] of the vaults
  [covenant][topic covenants] described in [Newsletter #59][news59
  vaults].  The mechanism uses ephemeral keys and pre-signed time-locked
  transactions to allow you to detect that someone used one of your
  private keys in an attempted theft.  You (or a watchtower
  acting on your behalf) can then activate an emergency protocol
  to recover most of the secured funds.  The prototype also includes an
  implementation of the same basic mechanism using [BIP119][]'s proposed
  opcode `OP_CHECKTEMPLATEVERIFY`.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **BTCPay adds support for sending and receiving payjoined payments:**
  [payjoin][topic payjoin] is a protocol that increases the privacy of Bitcoin
  payments by including inputs from both the spender and the receiver in
  an onchain transaction.  This prevents an outside observer examining
  block chain data from assuming all inputs in that transaction belong
  to the same user (e.g.[^payjoin-table]). If a significant number of people
  use payjoin, this makes the [common input heuristic][] used by block
  chain analysts much less reliable, improving privacy for even Bitcoin
  users who aren't using payjoin.

    This week, BTCPay [announced][btcpay pj announce] the release of
    version 1.0.4.0 which includes an implementation of payjoin support
    for both receiving payments in payment processor mode and sending
    them using BTCPay's internal wallet.  For details on using the
    protocol, see their [user guide][btcpay pj ug].  For technical
    details on their implementation, see their [specification][btcpay pj
    spec] or the [issue][btcpay-doc 486] where future improvements are
    being actively discussed.  For this change to have the maximum
    impact, other popular wallets need to implement support for creating
    compatible payjoin payments.

- **Lightning Labs drafts Lightning Service Authentication Tokens (LSAT) specification:**
  Lightning Labs has [announced][ll lsat announcement] LSAT, a
  [specification][lsat spec], which outlines a protocol for purchasing tokens
  (macaroons) over LN and using them in an application as both authentication
  and API payment mechanisms.

- **Lightning Labs announces Faraday for channel management:**
  [Faraday][ll faraday announcement] is a tool for LND node operators that
  analyzes existing channels and makes recommendations to close problematic or
  under-performing channels. Such channels display attributes such as low volume,
  low uptime, or high fees.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] is a release candidate
  for the next major version of Bitcoin Core.

- [LND 0.10.0-beta.rc4][lnd 0.10.0-beta] allows testing the next major
  version of LND.  Prospective testers are encouraged to read LND
  developer Olaoluwa Osuntokun's [introduction to the release
  candidate][lnd rc intro] from the [LND engineering mailing list][].

- [C-Lightning 0.8.2-rc1][c-lightning 0.8.2] is the first release
  candidate for the next version of C-Lightning.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Rust-Lightning][rust-lightning repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #17595][] adds support for [reproducibly building][topic
  reproducible builds] the Windows versions of Bitcoin Core using [GNU Guix][].
  The last remaining target platform for Guix reproducible
  builds, macOS, has an open [draft PR][Bitcoin Core #17920].

- [C-Lightning #3611][] adds a `keysend` plugin that allows a node to
  securely receive [spontaneous payments][topic spontaneous
  payments]---payments not preceded by the generation of an invoice.
  These work by having the sender of a payment choose its payment
  preimage (normally chosen by the receiver), derive its payment hash
  (normally included in an invoice), encrypt the preimage to the
  receiver's node pubkey, and send a payment with the encrypted data to
  the receiver secured by the payment hash.  The receiver decrypts the
  preimage and uses it to claim the payment like normal.  In order to
  allow payment tracking, `lightningd` automatically creates an internal
  invoice for the decrypted preimage before claiming a spontaneous
  payment.  An obvious use for spontaneous payments is donations, but a
  less obvious use is for sending chat messages with a payment such as
  via the LND-compatible [WhatSat][] software and the
  C-Lightning-compatible [noise][] plugin.

- [C-Lightning #3623][] adds a minimal implementation (only available
  with the configuration parameter `--enable-experimental-features`) for
  spending payments using [blinded paths][].  As described in
  [Newsletter #92][news92 blinded paths], blinded paths make it possible
  to route a payment without the originator learning the destination's
  network identity or the full path used.  This not only improves the
  privacy of the origination and destination endpoints but also the
  privacy of any unannounced nodes along the blinded paths.  The minimal
  implementation in this PR is mainly designed for testing, such as with
  a work-in-progress implementation being developed for Eclair.

- [LND #4163][] adds a `version` RPC that returns information about the
  LND server version and build flags.  This makes it easier for
  applications to ensure they're compatible with the currently running
  LND version.

- [Rust-Lightning #441][] adds support for sending and receiving basic
  [multipath payments][topic multipath payments].
  This implementation is not fully usable yet as
  follow-up pull requests are needed to [add support for route
  finding][rl mpp next] and for [timing out partial
  payments][rust-lightning #587].

## Footnotes

    {% capture today-private %}Inputs:<br>&nbsp;&nbsp;Alice (1 BTC)<br>&nbsp;&nbsp;Alice (4 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Alice's change (2 BTC)<br>&nbsp;&nbsp;Bob's revenue (3 BTC){% endcapture %}
    {% capture today-public %}Inputs:<br>&nbsp;&nbsp;Spender (1 BTC)<br>&nbsp;&nbsp;Spender (4 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Spender or Receiver (2 BTC)<br>&nbsp;&nbsp;Spender or Receiver (3 BTC){% endcapture %}
    {% capture payjoin-private %}Inputs:<br>&nbsp;&nbsp;Alice (1 BTC)<br>&nbsp;&nbsp;Alice (4 BTC)<br>&nbsp;&nbsp;Bob (3 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Alice's change (2 BTC)<br>&nbsp;&nbsp;Bob's revenue & change (6 BTC){% endcapture %}
    {% capture payjoin-public %}Inputs:<br>&nbsp;&nbsp;Spender or Receiver (1 BTC)<br>&nbsp;&nbsp;Spender or Receiver (4 BTC)<br>&nbsp;&nbsp;Spender or Receiver (3 BTC)<br><br>Outputs:<br>&nbsp;&nbsp;Spender or Receiver (2 BTC)<br>&nbsp;&nbsp;Spender or Receiver (6 BTC){% endcapture %}

[^payjoin-table]:
    An example of what the users participating in a payjoin know about
    a transaction versus what block chain analysts can infer.

    <div markdown="1" class="xoverflow">

    | | What Alice and Bob know | What the network sees |
    |-|-|-|
    | **Current norm** | {{today-private}} | {{today-public}} |
    | **With payjoin** | {{payjoin-private}} | {{payjoin-public}} |

    </div>

{% include references.md %}
{% include linkers/issues.md issues="17595,3611,3623,4163,441,587,17920" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta.rc4
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2rc1
[noise]: https://github.com/lightningd/plugins/tree/master/noise
[blinded paths]: https://github.com/lightningnetwork/lightning-rfc/blob/route-blinding/proposals/route-blinding.md
[rl mpp next]: https://github.com/rust-bitcoin/rust-lightning/issues/431#issuecomment-571757632
[btcpay pj ug]: https://docs.btcpayserver.org/features/payjoin
[btcpay pj spec]: https://docs.btcpayserver.org/features/payjoin/payjoin-spec
[btcpay-doc 486]: https://github.com/btcpayserver/btcpayserver-doc/issues/486
[lnd rc intro]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/UoyCGu-RvnM
[lnd engineering mailing list]: https://groups.google.com/a/lightning.engineering/forum/#!forum/lnd
[bishop vaults]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017755.html
[vaults prototype]: https://github.com/kanzure/python-vaults
[news59 vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[btcpay pj announce]: https://blog.btcpayserver.org/btcpay-server-1-0-4-0/
[news92 blinded paths]: /en/newsletters/2020/04/08/#blinded-paths
[whatsat]: https://github.com/joostjager/whatsat
[common input heuristic]: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
[GNU Guix]: https://www.gnu.org/software/guix/
[ll lsat announcement]: https://lightning.engineering/posts/2020-03-30-lsat/
[lsat spec]: https://lsat.tech/
[ll faraday announcement]: https://lightning.engineering/posts/2020-04-02-faraday/