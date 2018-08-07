---
title: 'Bitcoin Optech Newsletter #7'
permalink: /en/newsletters/2018/08/07/
name: 2018-08-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes the usual dashboard and action items, a
link to discussion about generalized Bitcoin contracts over Lightning
Network, a brief description of a recently-announced library for
scalability-enhancing BLS signatures, and some notable commits from the
Bitcoin Core, LND, and C-Lightning projects.

## Action items

- Optech has begun planning its first European workshop, which is set to
  take place in Paris sometime in November. If any member companies who
  think they'll be able to attend have topics they're interested in
  discussing, please [email Optech][optech email]. More information on
  the workshop will be released in a few weeks.

## Dashboard items

{% assign img1_label = "Transactions signaling opt-in RBF, August 2017 - August 2018" %}

- Transaction [fees remain very low][fee metrics]: Anyone who can wait 10 or
  more blocks for confirmation can reasonably pay the default minimum fee rate.
  It’s a good time to [consolidate UTXOs][consolidate info].

- Adoption of opt-in RBF remains fairly low, but has materially grown the past
  year, increasing from [1.5% to 5.7% of transactions][rbf data]. This data was
  sourced from Optech's beta dashboard, which we encourage people to try out and
  provide us feedback!

    ![{{img1_label}}](/img/posts/rbf.png)
    *{{img1_label}},
    source: [Optech dashboard][rbf data]*

## News

- **Discussion of arbitrary contracts over LN:** a [thread][contract
  thread] on the Lightning Network (LN) development mailing list last
  week described the basic principles for performing arbitrary Bitcoin
  contracts in a payment channel.  Instead of an independent contract
  that resolves to True in order to be a valid transaction, the exact
  same contract is included in a LN payment and must return true in
  order for the in-channel payment transaction to be valid.  Everything
  else in the arbitrary contract as well as the LN payment can stay the
  same, with some specific exceptions discussed in this thread started
  by knowledgeable pseudonymous researcher ZmnSCPxj.

- **Library announced for BLS signatures:** well-known developer Bram
  Cohen [announced][bls announce] a "first draft (but fully functional)
  library for doing [BLS signatures][] based on a construction based on
  [MuSig][]".  These signatures provide most of the same benefits of
  Schnorr signatures as described in [Newsletter #3's featured news][#3
  schnorr] but also allow non-interactive signature aggregation which
  can allow for greater scalability by reducing the amount of signature
  data in the block chain (possibly by a very large percentage) and
  potentially enhancing privacy by implementing techniques for
  non-interactive coinjoins such as those described in the [Mimblewimble
  paper][].

    BLS signatures do come with three downsides that have lead most
    Bitcoin protocol developers to focus on Schnorr signatures for the
    short-term.  The first is that there's no known way to verify them
    as fast as Schnorr signatures---and signature verification speed is
    also important for network scalability.  Second, to prove that BLS
    signatures are secure requires making an additional assumption about
    part of the scheme being secure that isn't required for proving the
    security of Bitcoin's current scheme (ECDSA) or proposed
    Schnorr-based scheme.  Finally, BLS signatures have only been around
    for about half as long as Schnorr signatures, are even less commonly
    used, and are not believed to have received the same amount of
    expert review as Schnorr signatures.

    Still, this open source library gives developers a convenient way to
    begin experimenting with BLS signatures and even start to use them
    in applications that don't need to be as secure as the Bitcoin
    network.



## Notable commits

*Notable commits this week in [Bitcoin Core][core commits], [LND][lnd
commits], and [C-lightning][cl commits].*

{% include linkers/github-log.md 
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="ef4fac0ea5b4891f4529e4b59dfd1f7aeb3009b5"
  end="2b67354aa584c4aabae049a67767ac7b70e2d01a"
%}
{% include linkers/github-log.md 
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="92b0b10dc75de87be3a9f895c8dfc5a84a2aec7a"
  end="f0f5e11b826e020c11c37343bcbaf9725627378b"
%}
{% include linkers/github-log.md 
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="0b597f671aa31c1c56d32a554fcdf089646fc7c1"
  end="80a8e57ede82292818032eeb3510da067fddfd5e"
%}

- [Bitcoin Core #13697][]: This PR by Pieter Wuille mentioned in
  [Newsletter #5][] to add [output script descriptors][] support to the
  upcoming 0.17 RPC `scantxoutset` has been merged.  These descriptors
  provide a comprehensive way to describe to software what output
  scripts you want to find, and it's expected to be adapted over time to
  other parts of the Bitcoin Core API such as [importprivkey][rpc
  importprivkey], [importaddress][rpc importaddress], [importpubkey][rpc
  importpubkey], [importmulti][rpc importmulti], and [importwallet][rpc
  importwallet].

- [Bitcoin Core #13799][]: Prior to the first Optech newsletter, a PR
  was merged that deliberately caused Bitcoin Core to abort startup if
  the configuration file or start-up parameters contained an option
  Bitcoin Core didn't recognize.  This greatly simplified debugging of
  common errors such as typos---but it also prevented users from putting
  options in their bitcoin.conf that applied to clients such as
  `bitcoin-cli`.  This new PR removes the startup abort and simply
  produces a warning.  Probably for a future release, a mechanism for
  client compatibility will be implemented and the startup abort will be
  restored.

- [LND #1579][]: This updates the primary backend interfaces (such as
  bitcoind, btcd, and neutrino SPV) to be compatible with the latest
  (and hopefully final) version of [BIP158][] compact block filters as
  implemented in the btcd full node, btcwallet, and Neutrino light
  wallet.  These filters allow a client to determine whether or a not a
  block probably contains a transaction that affects their wallet,
  similar to [BIP37][] bloom filters but much more efficiently for the
  server (as they don't need to rescan old blocks) and with additional
  privacy for the client as they don't directly give the server any
  information about what transactions they're interested in.

- [LND #1543][]: This PR continues work towards creating LN watchtowers
  that can assist light clients and other programs that aren't online by
  monitoring for attempted channel theft and broadcasting the user's
  pre-signed breach remedy transaction.  This particular PR adds
  watchtower version 0 encoding and encryption methods by cryptographer
  Conner Fromknecht.

- [C-lightning 55d450ff][]: C-lightning refuses to forward payments when
  the forwarding fee exceeds a certain percentage of the payment.
  However, when the amount being forwarded is tiny, e.g. buying just a few
  pixels for 10 nBTC each on [Satoshis.Place][], this rule was always
  triggered because the minimum fee floor was always a high percentage
  (e.g.  paying 10 nBTC with a minimum fee of 10 nBTC is a 100% fee).
  This PR provides a new rule that allows payments with forwarding fees
  up to 50 nBTC to go through regardless of their fee percentage and
  adds an option so that users can customize that value.

{% include references.md %}
{% include linkers/issues.md issues="13697,13799,1579,1543" %}

[bls announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016273.html
[#3 schnorr]: {{news3}}#featured-news-schnorr-signature-proposed-bip
[musig]: https://blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures.html
[bls signatures]: https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham
[mimblewimble paper]: https://scalingbitcoin.org/papers/mimblewimble.txt
[c-lightning 55d450ff]: https://github.com/ElementsProject/lightning/commit/55d450ff00ce80b01c5c64c072a47fea42657673
[satoshis.place]: https://satoshis.place/
[contract thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001383.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[rbf data]: https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1&from=now-1y&to=now
