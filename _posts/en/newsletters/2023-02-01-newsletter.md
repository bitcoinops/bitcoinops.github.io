---
title: 'Bitcoin Optech Newsletter #236'
permalink: /en/newsletters/2023/02/01/
name: 2023-02-01-newsletter
slug: 2023-02-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal for serverless payjoin and
describes an idea for allowing proof of payment for LN async payments.
Also included is our regular section with descriptions of notable
changes to popular Bitcoin infrastructure software.

## News

- **Serverless payjoin proposal:** [[Dan Gould]] [posted][gould payjoin] to
  the Bitcoin-Dev mailing list a proposal and [proof of concept
  implementation][payjoin impl] for a serverless version of [BIP78][],
  the [payjoin][topic payjoin] protocol.

    Without payjoin, a typical Bitcoin payment only includes inputs from
    the spender, leading to transaction surveillance organizations
    adopting the [common input ownership heuristic][] where they assume
    all inputs in a transaction belong to the same wallet.  Payjoin
    breaks this heuristic by allowing the receiver to contribute inputs
    to the payment.  This provides an immediate privacy improvement to
    the users of payjoin and generally improves the privacy of all Bitcoin
    users by making the heuristic less reliable.

    However, payjoin isn't as flexible as typical Bitcoin payments.
    Most typical payments can be sent when the receiver is offline, but
    payjoin requires the receiver to be online to contribute and sign
    for their inputs.  The existing payjoin protocol also requires the
    receiver to accept HTTP requests at a network address accessible to
    the spender, which is commonly accomplished by the receiver running
    a webserver on a public IP address which contains payjoin-compatible
    software.  As mentioned in [Newsletter #132][news132 payjoin], one
    suggestion for increasing the use of payjoin would be to allow
    payjoin on a more P2P basis between typical end-user wallets.

    Gould suggests building into payjoin-compatible wallets a
    lightweight HTTP server with [noise protocol][] encryption support
    plus the ability to use the [TURN protocol][] to traverse [NAT][].
    This would allow two wallets to communicate interactively for the
    brief period it takes to create a payjoin payment, with no need for
    a long-term webserver.  This does not allow payjoins to be created
    while the receiver is offline, although Gould does suggest
    investigating the [nostr protocol][] for future proposals to enable
    "async payjoin".

    As of this writing, no replies to the proposal have been posted to
    the mailing list.

- **LN async proof of payment:** as mentioned in [last week's
  newsletter][news235 async], LN developers are seeking a method for
  sending [async payments][topic async payments] that provide the
  spender with proof they paid the receiver.  An async payment allows
  a spender (Alice) to send an LN payment to a receiver (Bob)
  through a normal series of forwarding hops---including a Lightning
  Service Provider (LSP) that will hold the payment for Bob if he is
  offline at the moment.  When Bob notifies the LSP that he's back
  online, the LSP will begin forwarding the payment the rest of the way
  to Bob.

    A challenge with this approach in the current [HTLC][topic
    htlc]-based LN is that, if Bob is offline, he can't provide Alice
    with a payment-specific invoice that references a secret he's
    chosen.  Alice can instead choose her own secret and include it in
    the async payment she sends Bob---this is called a [keysend][topic
    spontaneous payments] payment---but since Alice knew the keysend
    secret all along, she can't use her knowledge of it as proof that
    she paid Bob.  Alternatively, Bob could pre-generate several
    standard invoices and give them to his LSP, who could distribute
    them to potential spenders like Alice.  Paying those invoices would
    generate proof of payment when Bob ultimately accepted payment, but
    it would allow the LSP to distribute the same invoice to several
    spenders, causing them all to pay the same secret.  When the LSP learned
    the secret as a consequence of Bob accepting the first of those
    payments, the LSP would be able to steal payments for the remainder
    of the payments to the reused invoice---making the pre-generated
    invoice solution for HTLCs only secure if Bob trusts his LSP.

    This week, Anthony Towns [proposed][towns async] a solution based on
    [signature adaptors][topic adaptor signatures].  This would depend
    on the planned upgrade of LN to use [PTLCs][topic ptlc].  Bob would
    pre-generate a series of signature nonces and give them to his LSP.
    The LSP would give a signature nonce to Alice, Alice would choose a
    message for her proof of payment (e.g. "Alice paid Bob 1000 sats at
    2023-02-01 12:34:56Z"), and then use Bob's nonce and her message
    to generate a signature adaptor for her PTLC.  When Bob comes back
    online, the LSP forwards him the payment and Bob verifies the nonce
    hasn't been used before, that he agrees with the message, that the
    payment is otherwise valid, and that the signature adaptor math is
    valid; he then accepts the payment and Alice, when she ultimately
    receives the settled PTLC, will have a signature from Bob that
    commits to her chosen message.

    Towns's solution involves the LSP receiving pre-generated invoices
    from Bob---this is similar to the insecure/trusted solution for
    HTLCs, yet the PTLC signature adaptor solution is secure and
    trustless because each payment from a different spender (like Alice)
    uses a different PTLC public key point and Bob is able to prevent
    nonce reuse.  Each PTLC point is different because it derives from a
    unique message selected by each spender.  Bob is able to prevent
    nonce reuse by checking for reused nonces before he accepts each
    payment.

    In his post, Towns [references][towns sa1] two [previous][towns sa2]
    mailing list posts he's written about LN proof of payment using
    signature adaptors.  As of this writing, no replies to the idea have
    been posted to the mailing list.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26471][] reduces the default mempool capacity to 5MB
  (from 300MB) when a user turns on `-blocksonly` mode. Since unused
  mempool memory is shared with dbcache, this change also reduces the
  default dbcache size in `-blocksonly` mode. Users may still configure
  a larger mempool capacity using the `-maxmempool` option.

- [Bitcoin Core #23395][] adds a `-shutdownnotify` configuration option to `bitcoind` which
  executes a custom user command when `bitcoind` shuts down normally
  (the command will not be executed during a crash).

- [Eclair #2573][] begins accepting [keysend][topic spontaneous
  payments] payments that don't contain a [payment secret][topic payment
  secrets] even when Eclair advertises that the payment secret is
  mandatory.  According to the pull request description, LND and Core
  Lightning both send keysend payments without payment secrets.  Payment
  secrets were designed to support [multipath payments][topic multipath
  payments], so Eclair is leaving it up to those other node
  implementations to ensure they only send single-path keysend payments.

- [Eclair #2574][], related to the above pull request, stops including
  payment secrets in the keysend payments it sends.  According to the
  pull request description, LND rejects keysend payments that contain a
  payment secret, even though such rejections are not described in
  the [BLIP3][] specification of keysend.

- [Eclair #2540][] makes several changes to how Eclair stores data about
  funding and commitment transactions in preparation for later adding
  support for [splicing][topic splicing].  See [#2584][eclair #2584]
  for the current draft pull request that would add experimental
  splicing support.

- [LND #7231][] adds RPCs and options to `lncli` for signing and
  verifying messages.  For P2PKH, the format is compatible with the
  `signmessage` RPC first added to Bitcoin Core in 2011.  For P2WPKH and
  P2SH-P2WPKH (also called Nested P2PKH, or NP2PKH), the same format is
  used.  This format includes the expectation that the signature will be
  in ECDSA format and verification requires deriving the public key from
  the signature.  For P2TR addresses, which would normally be used with
  [schnorr signatures][topic schnorr signatures], it's not possible to
  derive the public key from the signature if Bitcoin's schnorr
  signature algorithm is used.  Instead, ECDSA signatures are generated
  and verified for P2TR addresses.

    Note: Optech generally [recommends against][p4tr new hd] using ECDSA
    signature functions with keys intended for use with schnorr
    signatures, but LND developers have taken [extra precautionary
    steps][osuntokun sigs] to avoid problems.

- [LDK #1878][] adds the ability to set a per-payment (rather than
  global) `min_final_cltv_expiry` value.  This value determines the
  maximum number of blocks the receiver has to claim a payment before it
  expires.  The standard default value is 18 blocks but receivers can
  request more time by setting a parameter in a [BOLT11][] invoice.

    In order for LDK to support this feature in combination with its unique
    implementation of [stateless invoices][topic stateless invoices],
    LDK encodes the value into the [payment secret][topic payment
    secrets] that the spender is obliged to send.  It provides 12 bits
    for the expiry value, which allows expiries of up to 4,096 blocks
    (about 4 weeks).

- [LDK #1860][] adds support for channels using [anchor outputs][topic
  anchor outputs].

{% include references.md %}
{% include linkers/issues.md v=2 issues="26471,23395,2573,2574,2584,2540,1878,1860,7231" %}
[common input ownership heuristic]: https://en.bitcoin.it/wiki/Privacy#Common-input-ownership_heuristic
[news132 payjoin]: /en/newsletters/2021/01/20/#payjoin-adoption
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021364.html
[payjoin impl]: https://github.com/chaincase-app/payjoin/pull/21
[noise protocol]: http://www.noiseprotocol.org/
[turn protocol]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[nostr protocol]: https://github.com/nostr-protocol/nostr
[news235 async]: /en/newsletters/2023/01/25/#request-for-proof-that-an-async-payment-was-accepted
[towns async]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003831.html
[towns sa1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001034.html
[towns sa2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001490.html
[osuntokun sigs]: https://github.com/lightningnetwork/lnd/pull/7231#issuecomment-1407138812
[p4tr new hd]: /en/preparing-for-taproot/#use-a-new-bip32-key-derivation-path
