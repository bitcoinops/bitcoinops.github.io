We have heard from wallet providers that a reason for their hesitation
to default to receiving to bech32 addresses is concern that they’d see a
significant increase in customer support requests. Despite this, some
wallets already default to bech32 addresses and others plan to move to
use them soon, such as [Bitcoin
Core][core bech32 plan].

We solicited input from a number of services including BitGo, BRD,
Conio, Electrum, and Gemini regarding their customer support burden from
use of bech32 addresses. Most services report minimal issues ("no
support requests" and "there isn’t too much confusion").

One service said, "So Bitcoin address-related customer support tickets
increased 50%, but the absolute number of tickets is so small that not
sure we can give too much significance. There have never been many
tickets on this subject either before or after Bech32 so not sure this
is an important point in making the argument for exchanges to make the
switch. Instead, I might suggest focusing on fees, which really can add
up if you are using an old wallet implementation."

Electrum has seen some reports though, which are public, such as
["strange addresses"] and ["Localbitcoins does not support sending to
bech32"].

While not conclusive, it is reassuring that services opting to support
receiving to bech32 addresses have not seen a negative impact on their
customer support teams. The suggestion above to consider fee savings
likely far outweighs concerns, and is consistent with Bitcoin Optech’s
[guidance][save money with bech32].  With few negative reports and
significant potential fee savings for those wallets and services that
support receiving to bech32 addresses, it may be time for more wallets
to begin making bech32 their default address format.  If that happens,
it’ll be even more important for other wallets and services to support
sending to bech32 addresses.

[core bech32 plan]: /en/newsletters/2019/04/02/#news
["strange addresses"]: https://github.com/spesmilo/electrum/issues/5382
["localbitcoins does not support sending to bech32"]: https://github.com/spesmilo/electrum/issues/5371
[save money with bech32]: https://bitcoinops.org/en/bech32-sending-support/#fee-savings-with-native-segwit
