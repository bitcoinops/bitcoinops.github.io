---
title: 'Bitcoin Optech Newsletter #51'
permalink: /en/newsletters/2019/06/19/
name: 2019-06-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests testing on RCs for both LND and
C-Lightning, describes using ECDH for uncoordinated LN payments,
summarizes a proposal to add information about delays to LN routing replies,
and includes summaries of some interesting talks from the recent 'Breaking
Bitcoin' conference in Amsterdam.  Also included are our regular sections on
bech32 sending support and notable changes in popular
Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test C-Lightning and LND RCs:** both [C-Lightning][cl rc] and
  [LND][lnd rc] are in the process of testing Release Candidates (RC)
  for their next releases.  Experienced users of either program are
  encouraged to help test the RCs so that any remaining bugs can be
  identified and fixed before final release.

## News

- **Using ECDH for uncoordinated LN payments:** Stephan Snigirev sent
  two ideas to the LN development mailing list in a single
  [post][snigirev post].  The first idea involves reusing an existing
  part of the protocol to enable *spontaneous payments,* a payment that
  Alice sends to Bob without her needing to request an invoice from Bob.
  As described in [Newsletter #30][], these are currently proposed for
  LND by having Alice select a pre-image, encrypt it to Bob's key, and
  put it into an otherwise-unused part of an LN routing packet when Alice
  pays the hash of the pre-image.  When Bob receives the encrypted
  pre-image, he decrypts it and releases it to claim the payment.

  Snigirev's idea eliminates the need to route the encrypted pre-image.
  He notes that the routing of a payment from Alice to Bob already
  requires them to have a common shared secret (derived using Elliptic
  Curve Diffie-Hellman ([ECDH][]).  This secret can be hashed once to
  produce a unique pre-image known to both of them, and that pre-image
  can be hashed again to be the payment hash.  To use this system,
  whenever Bob receives a payment to a hash that he didn't create an
  invoice for, he simply generates the double hash of that session's
  shared secret and sees if it matches.  If so, he generates the single
  hash and claims the payment.  C-Lightning developer Christian Decker
  has written a [proof of concept][decker spontaneous] patch and plugin
  for C-Lightning that implements this.

    Snigirev's second idea allows an offline device, such as a vending
    machine, to generate a unique LN invoice that can be paid by an
    online user to another online node that knows how to produce the
    pre-image and claim the payment on behalf of the offline device.
    This results in the payer receiving the pre-image as a proof of
    payment.  The payer can then show this proof to the offline
    device to receive the promised good or service, such as food from a
    vending machine.  Again, this uses a shared secret derived using
    ECDH---but in this case the secret is shared between the offline
    device that generates the invoice and the online node that
    ultimately receives the payment.  See Snigirev's post for the
    protocol details.

- **Authenticating messages about LN delays:** when a payment fails in
  LN, it's often possible for the node attempting the payment to receive
  an authenticated message from one of the two nodes involved in the
  payment failure.  This allows the paying node to mark the channel
  between those two nodes as unreliable and choose other channels for
  future payments.  But LND developer Joost Jager [notes][jager delays]
  on the the LN development mailing list that "non-ideal payment
  attempts [can also be] successful payments for which it took a long
  time to receive the [success] message."  He proposes that each node
  relaying a message back to the paying node add two timestamps to the
  message, one timestamp when the node offered to route a payment and
  one timestamp when it learned either that the payment had failed or
  that it succeeded.  This would allow the paying node to determine
  where delays occurred during the routing of the payment and avoid
  those channels in the future.

    To prevent some nodes along the path from lying about other nodes,
    he propose the error messages and timestamps be protected by a
    message authentication code.  This could also prevent intermediate
    nodes from corrupting encrypted error messages from endpoint nodes.

    Jager's proposal also discusses how this type of system could be
    implemented in the current routing protocol and how it could
    address concerns related to routing privacy.  The proposal
    has received a moderate amount of positive discussion on the mailing
    list so far.

## Breaking Bitcoin

[Breaking Bitcoin][bb website] was a Bitcoin technology conference that took
place in Amsterdam last weekend. It was well attended by both Bitcoin protocol
developers and applications engineers.  Videos of the [Saturday][bb sat video]
and [Sunday][bb sun video] are available, as are several [transcripts][bb transcripts] by Bitcoin
developer Bryan Bishop (kanzure).

The following talks may be of particular interest to readers of the Bitcoin Optech newsletter:

- [**Breaking Bitcoin Privacy**][bb belcher video] - [Chris Belcher][],
  creator of coinjoin implementation Joinmarket, gave an overview of privacy in
  Bitcoin. Belcher has previously written a [literature review on
  privacy][belcher privacy review], and this very accesible talk touched on many
  of the topics in that review. He started by explaining why privacy is
  important in Bitcoin, described some commonly-used
  heuristics used by chain analysis companies to link Bitcoin addresses and
  transactions, and demonstrated how coinjoins and payjoins can be used to break
  those heuristics and thwart chain analysis. He finished by talking
  about how layer 2 technologies such as LN have the potential to improve
  privacy since they remove privacy-leaking data from the blockchain.
  ([transcript][bb belcher transcript]).

- [**Bitcoin Build System Security**][bb dong video] - Chaincode Labs engineer
  [Carl Dong][] gave a pre-recorded presentation on build security in Bitcoin
  Core and then answered audience questions over video link. Dong's talk
  addressed the question: "If I download a Bitcoin Core executable from
  bitcoincore.org, how can I know what code I'm running?" The Bitcoin Core
  project currently uses reproducible [gitian][] builds to ensure that the built binary
  corresponds to the source code, but Dong explains that _reproducibility is not
  enough_---if the reproducible build toolchain uses precompiled binaries, then
  those toolchain binaries could be compromised and used to undetectably
  insert malicious code into the compiled binary. Dong went on to describe
  _reproducible_ and _bootstrappable_ builds, where the number of precompiled
  binaries used in the toolchain is reduced to a minimum, and he gave an update on
  his project to integrate [guix][] (pronounced 'geeks') builds into Bitcoin
  Core to minimize trust in the build toolchain. ([transcript][bb dong transcript]).

- [**Secure Protocols on bip-taproot**][bb nick video] - Blockstream engineer
  [Jonas Nick][] gave an update on some of the work he and his colleagues have
  been doing to build secure protocols using schnorr signatures and the taproot
  construction. He started by explaining how the proposed [bip-taproot][] works
  ([more background][bg taproot]) and then explained some practical considerations
  when building protocols using schnorr/taproot: external signers that can't leak private
  keys through nonce bias, key aggregation and threshold signatures using Musig,
  and blind schnorr signatures. As the schnorr/taproot proposal develops and (maybe)
  approaches activation, companies that wish to take advantage of the new functionality
  offered by the proposal need to consider these practical aspects of building
  secure products and protocols. ([transcript][bb nick transcript]).

- [**Extracting Seeds from Hardware Wallets**][bb guillemet video] - Ledger CSO
  [Charles Guillemet][] gave an eye-opening talk about security issues with
  several hardware wallets on the market. He spoke about previously-revealed
  exploits that he and his team have discovered, as well as new exploits for
  which he didn't give the method in order to protect users. The attacks
  described used a mixture of physical access, side-channels, and exploiting
  insecure cryptography implementations. This was a fascinating talk for anyone
  working with or using hardware wallets to protect their Bitcoin.
  ([transcript][bb guillemet transcript]).

- [**Cryptographic Vulnerabilities in Threshold Wallets**][bb shlomovits video] -
  One of the most hotly-anticipated aspects of schnorr signatures is the
  ability to implement key aggregation and threshold signature schemes.
  Similar schemes are possible (although much more complex to implement) using
  the ECDSA signing algorithm which is currently used in Bitcoin. ZenGo
  co-founder [Omer Shlomovits][] described some of those ECDSA key-aggregation
  and threshold signature schemes and showed how many of the implementations for
  those schemes contained bugs due to faulty assumptions when optimizing the
  algorithms. (no transcript available).

## Bech32 sending support

*Week 14 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/14-security.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15024][] allows the `importmulti` RPC to derive
  specific private keys using an [output script descriptor][output
  script descriptors] and then import the resultant keys.

- [Bitcoin Core #15834][] fixes the transaction relay bug introduced in
  [#14897][Bitcoin Core #14897] where a node would sometimes stop
  receiving any new mempool transactions despite having a good
  connection to other nodes (see [Newsletter #43][news43 merges] for
  details and previous mitigations, or [#15776][Bitcoin Core #15776] for
  an excellent description of the bug and an initially-proposed
  solution).

- [LND #3133][] adds support for "altruist" watchtowers and clients.
  Watchtowers send breach remedy transactions (justice transactions) on
  behalf of clients that are currently offline to ensure that those
  clients' counterparties can't steal any money.  The ideal watchtower
  for general deployment is incentivized to do this by receiving a
  modest monetary reward for sending remedy transactions, but managing
  the incentive adds complexity---so this initial version of the complete
  system uses simpler altruist watchtowers that don't receive any reward via the protocol
  but otherwise provide both the client and server components for
  complete enforcement.  You can setup a watchtower for your own
  channels or you can use the watchtowers of reliable friends.  All the
  configuration parameters necessary are documented in LND's runtime
  help.  Developer Will O'Beirne also has an [example tutorial][watchtower
  tutorial] that helps you setup watchtowers, attempt to breach a test
  channel, and then observe the watchtower protect that channel's funds.

- [LND #3140][] adds support for RBF and CPFP fee bumping when LND is
  sending sweep transactions using one or more of its onchain UTXOs.

- [LND #3134][] allows users to integrate LND with the [Prometheus][]
  monitoring solution for collecting statistics and sending alerts.

- [C-Lightning #2672][] adds new RPCs that can be used to open a channel
  using funds from an external wallet.  The `fundchannel_start` RPC
  starts opening a new channel with a specified node and returns a
  bech32 address that the external wallet should pay *using only segwit
  inputs and without broadcasting the transaction.*  When that
  transaction has been created, its serialized form can be provided to
  the `fundchannel_complete` RPC to securely finish the channel
  negotiation and broadcast the transaction.  Alternatively, the
  `fundchannel_cancel` RPC can be called to abort the channel setup
  before funds are sent.  Because most external wallets will broadcast
  transactions automatically, these options need to be enabled
  explicitly using a configuration option---but they make it possible
  for external wallets to better integrate with C-Lightning directly.

- [C-Lightning #2700][] limits the amount of gossip requested by only
  requesting gossip from a subset of a node's peers.  This continues the
  work across all major LN implementations of trying to reduce the
  amount of data sent via gossip now that the network has grown to
  thousands of peers.

- [C-Lightning #2699][] extends the `fundchannel` RPC with a new `utxo`
  parameter that allows the user to specify which of the UTXOs
  from C-Lightning's built-in wallet to use to fund a new channel.

- [C-Lightning #2696][] adds a new `listtransactions` RPC method that
  lists all the onchain transactions created by the program and what
  they were used for (setup, unilateral close, mutual close, or
  anti-cheat).  Other changes in this PR ensure that all the necessary
  data to provide these results is stored in the database.

- [Eclair #1009][] allows Eclair to search through gossiped node
  announcements to find the IP address of channel peers by their pubkeys
  in case any peer gets disconnected and has its IP address change.

- [BIPs #555][] adds [BIP136][] for bech32-encoded transaction positions
  within the block chain.  For example, the position identifier of the
  first transaction in the chain (the Genesis block's generation
  transaction) is `tx1:rqqq-qqqq-qmhu-qhp`.  This idea was first
  [proposed][bech32 pos ref] to the Bitcoin-Dev mailing list over two
  years ago with [suggested use cases][pos ref anchor] including identifying
  which transactions contain information useful to third-party
  applications, such as timestamped decentralized identity references.

{% include linkers/issues.md issues="15024,2696,1009,15834,3133,3140,3134,2700,2699,555,2672,14897,15776" %}
[bech32 series]: /en/bech32-sending-support/
[bech32 pos ref]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014396.html
[news43 merges]: {{news43}}#notable-code-and-documentation-changes
[cl rc]: https://github.com/ElementsProject/lightning/tags
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[snigirev post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002009.html
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[decker spontaneous]: https://github.com/cdecker/lightning/tree/stepan-pay
[jager delays]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002015.html
[bb website]: https://breaking-bitcoin.com/
[bb sat video]: https://www.youtube.com/watch?v=DKOG0BQMmmg
[bb sun video]: https://www.youtube.com/watch?v=DqhxPWsJFZE
[bb transcripts]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/
[bb belcher video]: https://youtu.be/DKOG0BQMmmg?t=8266
[Chris Belcher]: https://twitter.com/chris_belcher_
[belcher privacy review]: https://en.bitcoin.it/wiki/Privacy
[bb belcher transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/breaking-bitcoin-privacy/
[bb dong video]: https://youtu.be/DKOG0BQMmmg?t=19828
[Carl Dong]: https://twitter.com/carl_dong
[gitian]: https://gitian.org/
[guix]: https://www.gnu.org/software/guix/
[bb dong transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/bitcoin-build-system/
[bb nick video]: https://youtu.be/DKOG0BQMmmg?t=21860
[Jonas Nick]: https://twitter.com/n1ckler
[bg taproot]: {{news46}}/
[bb nick transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/secure-protocols-bip-taproot/
[bb guillemet video]: https://youtu.be/DqhxPWsJFZE?t=9534
[Charles Guillemet]: https://twitter.com/p3b7_
[bb guillemet transcript]: http://diyhpl.us/wiki/transcripts/breaking-bitcoin/2019/extracting-seeds-from-hardware-wallets/
[bb shlomovits video]: https://youtu.be/DqhxPWsJFZE?t=15879
[Omer Shlomovits]: https://twitter.com/OmerShlomovits
[watchtower tutorial]: https://github.com/wbobeirne/watchtower-example
[prometheus]: https://prometheus.io/
[pos ref anchor]: https://github.com/bitcoin/bips/pull/555#issuecomment-315517707
