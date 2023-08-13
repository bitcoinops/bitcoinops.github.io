---
title: 'Bitcoin Optech Newsletter #264'
permalink: /en/newsletters/2023/08/16/
name: 2023-08-16-newsletter
slug: 2023-08-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about adding expiration
dates to silent payment addresses and provides an overview of a draft BIP
for serverless payjoin.  A contributed field report describes the
implementation and deployment of a MuSig2-based wallet for scriptless
multisignatures.  Also included are our regular sections with
announcements of new releases and release candidates and descriptions of
notable changes to popular Bitcoin infrastructure projects.

<!-- FIXME:delete this line if MuSig2 article is included in the newsletter, otherwise revise lede -->

## News

- **Adding expiration metadata to silent payment addresses:** Peter Todd
  [posted][todd expire] to the Bitcoin-Dev mailing list a recommendation
  to add a user-chosen expiration date to addresses for [silent
  payments][topic silent payments].  Unlike regular Bitcoin addresses
  that result in [output linking][topic output linking] if used to
  receive multiple payments, addresses for silent payments result in a
  unique output script every time they are properly used.  This can
  significantly improve privacy when it's impossible or inconvenient for
  receivers to provide spenders with a different regular address for
  each separate payment.

    Peter Todd notes that it would be desirable for all addresses to
    expire: at some point, most users are going to stop using a wallet.
    The expected one-time use of regular addresses makes expiry less of
    a concern, but the expected repeated use of silent payments makes it
    more important that they include an expiry time.  He suggests the
    inclusion of either a two-byte expiry time in addresses that would
    support expiry dates up 180 years from now or a three-byte time that
    would support expiry dates up to about 45,000 years from now.

    The recommendation received a moderate amount of discussion on the
    mailing list, with no clear resolution as of this writing.

- **Serverless payjoin:** Dan Gould [posted][gould spj] to the
  Bitcoin-Dev mailing list a [draft BIP][spj bip] for _serverless
  payjoin_ (see [Newsletter #236][news236 spj]).  By itself, [payjoin][topic payjoin] as
  specified in [BIP78][] expects the receiver to operate a server for
  securely accepting [PSBTs][topic psbt] from spenders.  Gould proposes an asynchronous
  relay model that would start with a receiver using a [BIP21][] URI to
  declare the relay server and symmetric encryption key they wanted to
  use for receiving payjoin payments.  The spender would encrypt a PSBT
  of their transaction and submit it to the receiver's desired relay.  The
  receiver would download the PSBT, decrypt it, add a signed input to
  it, encrypt it, and submit it back to the relay.  The spender
  downloads the revised PSBT, decrypts it, ensures that it is correct,
  signs it, and broadcasts it to the Bitcoin network.

    In a [reply][gibson spj], Adam Gibson warned about the danger of
    including the encryption key in the BIP21 URI and the risk to
    privacy of the relay being able to correlate the receiver's and
    spender's IP addresses with the set of the transactions broadcast
    within a window of time near when they completed their session.
    Gould [has since revised][gould spj2] the proposal in an attempt
    to address Gibson's concern about the encryption key.

    We expect to see continued discussion about the protocol.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test release candidates.*

- [Core Lightning 23.08rc2][] is a release candidate for the next major
  version of this popular LN node implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27213][] helps Bitcoin Core make and maintain
  connections to peers on a more diverse set of networks, reducing the
  risk of [eclipse attacks][topic eclipse attacks] in some situations.
  An eclipse attack occurs when a node is unable to connect to even a
  single honest peer, leaving it with dishonest peers who can give it a
  different set of blocks than the rest of the network.  That can be
  used to persuade the node that certain transactions have been
  confirmed even though the rest of the network disagrees, potentially
  tricking the node operator into accepting bitcoins that they'll never
  be able to spend.  Increasing the diversity of connections can also help
  prevent accidental network partitions where peers on a small network
  become isolated from the main network and so fail to receive the
  latest blocks.

    The merged PR attempts to open a connection to at least one peer on
    each reachable network and will prevent the sole peer on any network
    from being automatically evicted.

- [Bitcoin Core #28008][] adds the encryption and decryption routines
  planned to be used for the implementation of the [v2 transport
  protocol][topic v2 P2P transport] as specified in [BIP324][].  Quoting
  from the pull request, the following ciphers and classes are added:

    - "The ChaCha20Poly1305 AEAD from RFC8439 section 2.8"

    - "The [Forward Secrecy] FSChaCha20 stream cipher as specified in
      BIP324, a rekeying wrapper around ChaCha20"

    - "The FSChaCha20Poly1305 AEAD as specified in BIP324, a rekeying
      wrapper around ChaCha20Poly1305"

    - "A BIP324Cipher class that encapsulates key agreement, key
      derivation, and stream ciphers and AEADs for BIP324 packet
      encoding"

- [LDK #2308][] allows a spender to include custom Tag-Length-Value
  (TLV) records in their payments which receivers using LDK or a
  compatible implementation can now extract from the payment.  This can
  make it easy to send custom data and metadata with a payment.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27213,28008,2308" %}
[todd expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021849.html
[gould spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021868.html
[spj bip]: https://github.com/bitcoin/bips/pull/1483
[gibson spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021872.html
[gould spj2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021880.html
[news236 spj]: /en/newsletters/2023/02/01/#serverless-payjoin-proposal
[core lightning 23.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc2
