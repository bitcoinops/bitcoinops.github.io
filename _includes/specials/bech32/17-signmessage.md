As we've shown in earlier parts of this series, bech32 addresses are
better in almost every way than legacy addresses---they allow users to
[save fees][bech32 save fees], they're [easier to transcribe][bech32
transcribe], address [typos can be located][bech32 locate typos], and
they're [more efficient in QR codes][bech32 qr codes].  However, there
is one feature that legacy P2PKH addresses support that is not widely
supported by native segwit wallets---message signing support.  In the
spirit of full disclosure and the hopes of spurring wallet developers
into action, we'll take a look at this missing piece of bech32 address
support.

For background, many wallets allow a user with a legacy P2PKH address to
sign an arbitrary text message using the private key ultimately
associated with that address:

    $ bitcoin-cli getnewaddress "" legacy
    125DTdGU5koq3YfAnA5GNqGfC8r1AZR2eh

    $ bitcoin-cli signmessage 125DTdGU5koq3YfAnA5GNqGfC8r1AZR2eh Test
    IJPKKyC/eFmYsUxaJx9yYfnZkm8aTjoN3iv19iZuWx7PUToF53pnQFP4CrMm0HtW1Nn0Jcm95Le/yJeTrxJwgxU=

Unfortunately, there's no widely-implemented method for creating signed
messages for legacy P2SH, P2SH-wrapped segwit, or native segwit
addresses.  In Bitcoin Core and many other wallets, trying to use
anything besides a legacy P2PKH address will fail:

    $ bitcoin-cli getnewaddress "" bech32
    bc1qmhtn8x34yq9t7rvw9x6kqx73vutqq2wrxawjc8

    $ bitcoin-cli signmessage bc1qmhtn8x34yq9t7rvw9x6kqx73vutqq2wrxawjc8 Test
    error code: -3
    error message:
    Address does not refer to key

Some wallets do support message signing for segwit addresses---but in a
non-standardized way.  For example, the [Trezor][trezor segwit
signmessage] and [Electrum][electrum segwit signmessage] wallets each
provide message signing support for P2WPKH and P2SH-wrapped P2WPKH
addresses.  Yet both implementations were made independently and use
slightly different protocols, so they're [unable to verify][trezor
electrum incompatible] signatures produced by the other system.
Additionally, the algorithms used by all wallets we're aware of can't be
easily adapted to P2SH and P2WSH scripts used for multisig and other
advanced encumbrances.  That means message signing today is universally
limited to users of single-sig addresses.

There is a proposed standard that should allow any address type or
script to be used to create a signed message, [BIP322][].  The protocol
should even be forward compatible with future segwit versions, such as
[bip-taproot][] and [bip-tapscript][] (with some unresolved limitations
related to time locks).  Unfortunately, even though the proposal was
first made more than a year ago (see [Newsletter #13][]), there's no
implementation for it---not even a proposed implementation under review.

This leaves users of segwit without the same level of message signing
support available to users of legacy addresses, and it may represent a
reason some users are unwilling to move to segwit addresses.  The only
solutions, besides wallets abandoning message signing support, are for
wallet developers to agree on a standard and then widely implement it.


[bech32 save fees]: /en/bech32-sending-support/#fee-savings-with-native-segwit
[bech32 transcribe]: /en/bech32-sending-support/#reading-and-transcribing-bech32-addresses
[bech32 locate typos]: /en/bech32-sending-support/#locating-typos-in-bech32-addresses
[bech32 qr codes]: /en/bech32-sending-support/#creating-more-efficient-qr-codes-with-bech32-addresses
[trezor segwit signmessage]: https://github.com/trezor/trezor-mcu/issues/169
[electrum segwit signmessage]: https://github.com/spesmilo/electrum/issues/2977
[trezor electrum incompatible]: https://github.com/spesmilo/electrum/issues/3861
