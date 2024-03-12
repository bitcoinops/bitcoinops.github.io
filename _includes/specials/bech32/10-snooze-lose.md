Up until this point in our series encouraging wallets and services to
support sending to bech32 native segwit addresses, we've focused
almost exclusively on technical information.  Today, this section
expresses an opinion: the longer you delay implementing bech32 sending
support, the worse some of your users and potential users will think of
your software or service.

> "They can only pay legacy addresses."<br>
> "Oh.  Let's look for another service that supports current technology."

Services that only support legacy addresses are likely to become a cue
to users that minimal development effort is being put into maintaining
their Bitcoin integration.  We expect that it'll send the same signal to
users as a website in 2019 that's covered in Shockwave/Adobe Flash
elements and that claims it's best viewed in Internet Explorer 7 (or
see an even more [imaginative comparison][nullc bank analogy] written by Gregory
Maxwell.)

Bech32 sending is not some experimental new technology that still needs
testing---native segwit unspent outputs currently hold [over 200,000
bitcoins][].  Bech32 sending is also something that's easy to implement
(see Newsletters [#38][news38 bech32] and [#40][news40 bech32]).  Most
importantly, as more and more wallets and services upgrade to bech32
*receiving* by default, it's going to become obvious which other
services haven fallen behind by not providing sending support.

If you haven't implemented bech32 sending support yet, we suggest you
try to get it implemented by 24 August 2019 (the two-year anniversary of
segwit activation).  Not long after that, Bitcoin Core's next release is
expected to begin defaulting to bech32 receiving addresses in its GUI
and perhaps also its API methods (see Newsletters [#40][Newsletter #40 bech32]
and [#42][Newsletter #42 bech32]).  We expect other wallets to do the
same---except for the ones that have already made bech32 their default
(or even their only supported address format).

[nullc bank analogy]: https://old.reddit.com/r/Bitcoin/comments/9iw1p2/hey_guys_its_time_to_make_bech32_standard_on/e6onq8t/
[over 200,000 bitcoins]: https://p2sh.info/dashboard/db/p2wpkh-statistics?orgId=1
[news38 bech32]: /en/newsletters/2019/03/19/#bech32-sending-support
[news40 bech32]: /en/newsletters/2019/04/02/#bech32-sending-support
[newsletter #40 bech32]: /en/newsletters/2019/04/02/#bitcoin-core-schedules-switch-to-default-bech32-receiving-addresses
[newsletter #42 bech32]: /en/newsletters/2019/04/16/#bitcoin-core-15711
