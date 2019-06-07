[Last week][Newsletter #47], we described one of the costs of not
upgrading to bech32 sending support---users might think your service is
out-of-date and so look for alternative services.  This week, we'll look
at the stronger form of that argument: wallets which already can **only
receive to bech32 addresses.**  If the users of these wallets
want to receive a payment or make a withdrawal from your service, and
you don't yet support sending to bech32 addresses, they'll either have
to use a second wallet or have to use one of your competitors.

<!-- Wasabi source: their documentation; see provided links -->
- [Wasabi wallet][], known for its privacy-enhancing coinjoin mode and
  mandatory user coin control, [only accepts payments to bech32
  addresses][wasabi bech32 only].  This relatively-new wallet was
  designed around compact block filters similar to those described in
  [BIP158][].  However, since all of the filters are served by Wasabi's
  infrastructure, the [decision was made]["only generate filters
  regarding bech32 addresses"] to minimize filter size by only
  including P2WPKH outputs and spends in the filter.  This means the
  wallet can't see payments to other output types, including P2SH for
  P2SH-wrapped segwit addresses.

<!-- Trust wallet source: private conversation harding had with a tester
of this wallet in Februray 2019 -->
- [Trust wallet][] is a fairly new proprietary wallet owned by the
  Binance cryptocurrency exchange and compatible with Android and iOS.
  As a new wallet, they didn't need to implement legacy address
  receiving support, so they only implemented segwit.  That makes bech32
  the only supported way to send bitcoins to this wallet.

<!-- Electrum source: harding tested default download from their website 2019-05-27 -->
- [Electrum][] is a popular wallet for desktop and mobile.  When
  creating a new wallet seed, you can choose between a legacy wallet and
  a segwit wallet, with segwit being the current default.  Users
  choosing a segwit wallet seed will only be able to generate bech32
  addresses for receiving.  Electrum warns users about the compatibility
  issues this may create with software and services that haven't
  upgraded to bech32 sending support yet:

    ![Dialog in Electrum allowing the user to choose the address type
    and warning them that some services may not support bech32
    addresses](/img/posts/2019-05-electrum-choose-wallet-type.png)

    Please note that it's neither required nor recommended for wallet
    authors to create a new seed in order to support a new address
    format.  Other wallets, such as Bitcoin Core 0.16.0 and above, can
    produce legacy, p2sh-segwit, and bech32 addresses all from the same
    seed---the user just needs to specify which address type they want
    (if they don't want the default).

As time goes on, we expect more new wallets to only implement receiving
to the current best address format. Today that's v0 segwit addresses for
P2WPKH and P2WSH using bech32, but if Taproot is adopted, it will use v1
segwit addresses that will [also use bech32][news45 bech32].  The longer your service
delays implementing bech32 sending support, the more chance you'll have
of losing customers because they can't request payments from you using
their preferred wallet.

[wasabi bech32 only]: https://github.com/zkSNACKs/WalletWasabi/blob/master/WalletWasabi.Documentation/FAQ.md#my-wallet-cant-send-to-bech32-addresses---what-wallets-can-i-use-instead
["only generate filters regarding bech32 addresses"]: https://github.com/zkSNACKs/Meta/blob/master/README.md#wasabi-wallet-under-the-hood
[wasabi wallet]: https://wasabiwallet.io/
[trust wallet]: https://trustwallet.com/
[electrum]: https://electrum.org/
[news45 bech32]: {{news45}}#bech32-sending-support
