{% auto_anchor %}
This week we look at some of the [top-voted bech32 questions and
answers][top bech32 qa] from the Bitcoin StackExchange.  This includes
everything since bech32 was first announced about two years ago.

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Will a Schnorr soft fork introduce a new address format?]({{bse}}82952)
  Although upgrading to bech32 sending support
  should be easy, you probably don't want to repeat that work for
  Bitcoin's next upgrade or the upgrade after that.  Pieter Wuille
  answers this question by explaining how an upgrade to Schnorr-based
  public keys and signatures can still use bech32 addresses.  (Optech
  will be covering this issue in greater detail in a future section.)

- [Is it safe to translate a bech32 P2WPKH address into a legacy P2PKH address?]({{bse}}62207)
  If you read [Newsletter #38][bech32 easy],
  you'll notice that the difference between a P2WPKH and P2PKH address
  for the same underlying public key is only a few characters in a
  scriptPubKey, making it possible to automatically convert one into the
  other.  This answer by Andrew Chow and its accompanying comments
  explains why that's a bad idea that could cause users to lose funds.

- [Why does the bech32 decode function require specifying the address's Human Readable Part (HRP) instead of extracting it automatically?]({{bse}}83454)
  The HRP is separated from the rest of
  the address by a `1`, so it seems like the decoder could ignore that
  part all on its own.  Pieter Wuille explains that calling the decoder
  with the expected HRP ensures that you don't accidentally pay bitcoin
  to an address meant for testnet, litecoin, or some other network.
  Gregory Maxwell also corrects an additional assumption of the asker.

- [What block explorers recognize bech32 addresses?]({{bse}}66458)
  More than two years after bech32 was first proposed and a year after
  this question was first asked, several popular block explorers don't
  support search or display of bech32 addresses.  The answer to this
  question suggests anyone who wants to learn the bech32 status of
  various block explorers should check the [bech32 adoption][] Bitcoin
  Wiki page.

[bech32 easy]: {{news38}}#bech32-sending-support
[top bech32 qa]: https://bitcoin.stackexchange.com/search?tab=votes&q=bech32
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
{% endauto_anchor %}
