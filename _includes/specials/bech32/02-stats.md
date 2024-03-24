As described [last week][bech32 easy], implementing just segwit
spending should be easy.  Yet we suspect some managers might wonder
whether there are enough people using segwit to justify their team
spending development effort on it.  This week, we look at sites that
track various segwit adoption statistics so that you can decide whether
it's popular enough that your wallet or service might become an outlier
by failing to support it soon.

Optech tracks statistics about segwit use on our [dashboard][optech
dashboard]; another site tracking related statistics is [P2SH.info][].
We see an average of about 200 outputs per block are sent to native
segwit addresses (bech32).  Those outputs are then spent in about 10% of all
Bitcoin transactions.  That makes payments involving native segwit addresses
more popular than almost all altcoins.

![Screenshot of Optech Dashboard segwit usage stats](/img/posts/2019-03-segwit-usage.png)

However, many wallets want to use segwit but still need to deal with
services that don't yet have bech32 sending support.  These wallets can
generate a P2SH address that references their segwit details, which is
less efficient than using bech32 but more efficient than not using
segwit at all.  Because these are normal P2SH addresses, we can't tell
just by looking at transaction outputs which P2SH addresses are
pre-segwit P2SH outputs and which contain a nested segwit
commitment, and so we don't know the actual number of payments to
nested-segwit addresses.  However, when one of these outputs is spent,
the spender reveals whether the output was segwit. The above statistics
sites report that currently about 37% of transactions contain at least
one spend from a nested-segwit output.  That corresponds to about 1,400
outputs per block on average.

Any wallet that supports P2SH nested segwit addresses also likely
supports bech32 native addresses, so the number of transactions made by
wallets that want to take advantage of bech32 sending support is
currently over 45% and rising.

To further gauge segwit popularity, you might also want to know which
notable Bitcoin wallets and services support it.  For that, we recommend
the community-maintained [bech32 adoption][] page on the Bitcoin Wiki or
the [when segwit][] page maintained by BRD wallet.

The statistics and compatibility data show that segwit is already well
supported and frequently used, but that there are a few notable holdouts
that haven't yet provided support.  It's our hope that our campaign and
other community efforts will help convince the stragglers to catch up on
bech32 sending support so that all wallets that want to take advantage
of native segwit can do so in the next few months.

[bech32 easy]: /en/newsletters/2019/03/19/#bech32-sending-support
[optech dashboard]: https://dashboard.bitcoinops.org/
[p2sh.info]: https://p2sh.info/
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[when segwit]: https://whensegwit.com/
