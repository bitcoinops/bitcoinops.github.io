---
title: 'Bitcoin Optech Newsletter #0'
permalink: /en/newsletters/2018/06/08/
name: 2018-06-08-newsletter
slug: 2018-06-08-newsletter
type: newsletter
layout: newsletter
lang: en
version: 1
excerpt: >
  A trial run of the Optech newsletter including news about the
  `OP_CODESEPARATOR` opcode, BetterHash mining protocol, and BIP157/158
  compact block filters.
---

**This newsletter from June 8th 2018 was a preview run of the Optech newsletter.**

*Technical news about Bitcoin from last Friday to this Thursday, June 1st through June 7th.*

## Summary

A new maintenance release of Bitcoin Core is coming soon with a change to relay policy, hash rate has been increasing rapidly so it could be a good time to send low-fee transactions, wallet providers may want to investigate proposed [BIP174][BIP174] before it’s fully implemented, filters for P2P lightweight clients are heavily discussed, feedback is requested on proposals to change private key serialization and how mining pools communicate with their hashers, and Bitcoin Core merges an optimization to build merkle trees up to about 7x faster.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki

## Key action items

- **Check for use of the `CodeSeparator` opcode:** Bitcoin Core 0.16.1, expected to be released within the next week or so, will [no longer relay][standardness_rules] legacy (non-segwit) transactions using this opcode. As far as Bitcoin Core contributors know, nobody uses this opcode, but if your organization does use it or plans to use it, you should immediately [contact a protocol developer][contact_dev] or optech team member ASAP to inform them of this. Ultimately it is possible that this opcode will be removed from the Bitcoin Protocol for legacy transactions via a soft fork.

[contact_dev]: https://bitcoincore.org/en/contact/
[standardness_rules]: https://github.com/bitcoin/bitcoin/pull/11423

- **[Test release candidates][rc] for Bitcoin Core version 0.16.1.** RC1 available now; RC2 likely to be available shortly. This release will contain bugfixes particularly important for miners. There are no major changes for spender-receivers and API providers, but they may benefit from bugfixes.

[rc]: https://bitcoincore.org/bin/bitcoin-core-0.16.1/

## Dashboard updates

- **Hash rate increases:** the difficulty of mining increased almost 15% this week and shorter-term averages of network hash rate show continued growth. This means that blocks are being produced more frequently than normal and this will likely hold down transaction fees for as long as the trend continues. It’s a good time to [consolidate transaction outputs][consolidate] or otherwise send low-fee transactions.

[consolidate]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **Very low-fee transactions:** an increase in the number of very-low fee transactions paying less than 10 nanobitcoins per vbyte has been observed on nodes with non-default transaction acceptance policy (the default policy is to reject transactions paying less than 10 nBTC/vbyte). This may indicate misconfigured wallets paying fees that are too low, or it may indicate that some spenders believe this is a viable strategy to save on fees. It may be worth experimenting to determine whether these extremely low fees can be used for consolidations and other time-insensitive intrawallet transfers.

## News

- **[BIP174][BIP174] discussion and review ongoing:** this BIP creates a standardized format for wallets to reliably share information related to unsigned and partially signed transactions. This is expected to be implemented in Bitcoin Core and may also be implemented in other wallets, allowing software wallets, hardware wallets, and offline (cold) wallets to easily interact with each other for both single-signature and multi-signature transactions. This BIP has the potential to become an industry standard and so all major wallet providers are encouraged to investigate the specification.

  The [proposed implementation of BIP174][PR12136] was previously added to Bitcoin Core’s [high priority review queue][high priority] and received significant discussion this week, with at least one bug being found and one protocol developer suggesting that parts of the proposal can be split up.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[PR12136]: https://github.com/bitcoin/bitcoin/pull/12136
[high priority]: https://github.com/bitcoin/bitcoin/projects/8

- **[BIP157][BIP157]/[BIP158][BIP158] lightweight client filters:** these BIPs allow nodes to create a compact index of transaction data for each block on the chain and then distribute copies of that index to light clients who request them. The client can then privately determine whether or not the block might contain any of the client’s transactions.

  Exactly what data should be indexed was [heavily discussed][BIP158 discussion] on the mailing list this week. This probably does not directly affect most large receiver-spenders and API services, but any providers planning to release wallets using the peer-to-peer network protocol may want to review the BIPs.

  Bitcoin Core PR [#13243][PR 13243], merged this week, is part of an effort to bring this feature to Bitcoin Core.

[BIP157]: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
[BIP158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[BIP158 discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016057.html
[PR 13243]: https://github.com/bitcoin/bitcoin/pull/13243

- **[Proposed BIP][bech32 keys] for private key & HD wallet serialization:** currently private keys are usually transmitted using the same encoding as legacy Bitcoin addresses, and HD wallet extended keys and seeds are transmitted using either the same format, hex, or a mnemonic phrase. This new proposal would allow using the bech32 format used for native segwit addresses.

  [Discussion][bech32 keys discussion] focused on whether or not to use the exact bech32 standard or a modification of it that would be more resistant to transcription and data loss errors. Services that plan to accept or distribute secret key material may wish to contribute to reviewing the specification.

[bech32 keys]: https://gist.github.com/jonasschnelli/68a2a5a5a5b796dc9992f432e794d719
[bech32 keys discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **[BetterHash mining protocol][BetterHash spec]:** A proposed replacement for the Stratum mining protocol currently almost universally used for mining pools to distribute work to individual miners. The proposal claims to provide better security for the pool operator and allows individual miners to select what transactions they include in their blocks, increasing Bitcoin censorship resistance and also possibly making miners using the protocol more effective. The protocol is championed by the developer and operator of the [FIBRE network][FIBRE] used by almost all miners.

  The protocol has been in semi-private development for some time and is just now being distributed for public comment. Organizations planning to sell or operate mining equipment are encouraged to review the protocol, as are any groups or individuals desiring changes to Bitcoin’s consensus rules so that the protocol can potentially be made forward compatible with those changes. There has not yet been much [on-list discussion][BetterHash discussion] of the proposal.

[BetterHash spec]: https://github.com/TheBlueMatt/bips/blob/betterhash/bip-XXXX.mediawiki
[FIBRE]: http://bitcoinfibre.org/
[BetterHash discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016077.html

## On this day in Bitcoin commit history…

- **<!--n-->2017:** Andrew Chow authored commit [ec6902d][commitec6902d] paving the way to remove the last parts of the confusing “safe mode” functionality added to Bitcoin 0.3.x after the [value overflow incident][value overflow].

[commitec6902d]: https://github.com/bitcoin/bitcoin/commit/ec6902d0ea2bbe75179684fc71849d5e34647a14
[value overflow]: https://en.bitcoin.it/wiki/Value_overflow_incident

- **<!--n-->2016:** Luke Dashjr’s PR [#7935][PR7953] was merged adding support for [BIP9] versionbits to the GetBlockTemplate RPC call, allowing miners to signal support for future soft forks—such as the soft fork that activated [BIP141] segregated witness.

[PR7953]: https://github.com/bitcoin/bitcoin/pull/7935
[BIP9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
[BIP141]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki

- **<!--n-->2015:** Gavin Andresen authored commit [65b94545][commit65b94545] to refine the criteria a node uses to detect that it may no longer be receiving blocks from the best block chain.

[commit65b94545]: https://github.com/bitcoin/bitcoin/commit/65b94545036ae6e38e79e9c7166a3ba1ddb83f66

- **<!--n-->2014:** Cozz Lovan authored commit [95a93836][commit95a93836] removing a legacy part of the GUI that assumed any transaction fee below 0.01 BTC was a low transaction fee.

[commit95a93836]: https://github.com/bitcoin/bitcoin/commit/95a93836d8ab3e5f2412503dfafdf54db4f8c1ee

- **<!--n-->2013:** Wladimir van der Laan authored commit [3e9c8ba][commit3e9c8ba] fixing a bug related to the data directory.

[commit3e9c8ba]: https://github.com/bitcoin/bitcoin/commit/3e9c8bab54371364f8e70c3b44e732c593b43a76

- **<!--n-->2012:** Luke Dashjr authored several commits (e.g. [9655d73][commit9655d73]) related to enabling IPv6 support.

[commit9655d73]: https://github.com/bitcoin/bitcoin/commit/9655d73f49cd4da189ddb2ed708c26dc4cb3babe

- **<!--n-->2011, 2010, 2009:** no commits dated June 8th.
