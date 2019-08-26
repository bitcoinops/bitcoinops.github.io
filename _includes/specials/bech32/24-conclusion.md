After six months and over 10,000 words published, this is our last
bech32 sending support section.  Our goal was to gently persuade as many
developers as possible to add support for paying bech32 addresses in
their applications.  We hoped that would make it easier for segwit-ready
wallets to switch from using P2SH-wrapped segwit addresses by default to
more efficient native segwit bech32 addresses.

By our efforts and by the efforts of many other Bitcoiners, we think
we're on the brink of success: 19 of the 23 popular
wallets and services we've [evaluated][bech32 compat] are ready to pay
bech32 addresses and 4 already
generate bech32 receiving addresses by default.

Every week, it's looking more and more reasonable for wallets to switch
to bech32 soon, and we expect to hear from an increasing number of
developers that their next major release will default to bech32
receiving addresses.  This will lower the transaction fees for the users
of that software and make more block space available to all Bitcoin
users, helping to keep fees lower for everyone a little bit longer.

Even though this series has ended, we'll continue to update the segwit
section of the [compatibility matrix][] and report on notable bech32
developments in the other parts of the weekly newsletter.  We thank all
of you for reading this series and for helping to improve Bitcoin
scalability one wallet and service at a time.

[bech32 compat]: /en/bech32-sending-support/#insights-from-segwit-compatibility-matrix
