---
title: 'Bitcoin Optech Newsletter #344'
permalink: /en/newsletters/2025/03/07/
name: 2025-03-07-newsletter
slug: 2025-03-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the disclosure of a vulnerability
affecting old versions of LND and summarizes a discussion about the Bitcoin
Core Project's priorities.  Also included are our regular sections
describing discussion related to consensus changes, announcing new
releases and release candidates, and summarizing notable changes to
popular Bitcoin infrastructure software.

## News

- **Disclosure of fixed LND vulnerability allowing theft:** Matt
  Morehouse [posted][morehouse failback] to Delving Bitcoin to announce
  the [responsible disclosure][topic responsible disclosures] of a
  vulnerability that affected LND versions before 0.18.  Upgrading to
  0.18 or (ideally) the [current version][lnd current] is recommended.
  An attacker who shares a channel with a victim node and who can also
  somehow cause the victim's node to restart at a particular time can
  trick LND into both paying for and refunding the same HTLC, allowing
  the attacker to steal nearly the entire value of a channel.

  Morehouse notes that the other LN implementations have all
  independently discovered and fixed this vulnerability, including as
  early as 2018 (see [Newsletter #17][news17 cln2000]), but the LN
  specification doesn't describe the correct behavior (and may even
  require the incorrect behavior).  He has [opened a PR][bolts #1233] to
  update the specification.

- **Discussion about Bitcoin Core's priorities:** several blog posts
  by Antoine Poinsot about the future of the Bitcoin Core
  project were linked in a [thread][poinsot pri] on Delving Bitcoin.  In
  the [first][poinsot pri1] blog post, Poinsot describes the benefits of
  long-term goal setting and the costs of ad hoc decision-making.  In
  the [second][poinsot pri2] post, he argues that "Bitcoin Core should
  be a robust backbone for the Bitcoin network, balancing between
  securing the Bitcoin Core software and implementing new features to
  strengthen and improve the Bitcoin network."  In the [third][poinsot
  pri3] post, he recommends splitting the existing project into three
  projects: a node, a wallet, and a GUI.  This is within reach today
  thanks to the multiple-year effort of the multiprocess sub-project
  (see [Newsletter #39][news39 multiprocess] for our first mention of
  this sub-project in 2019).

  Anthony Towns [questions][towns pri] whether multiprocess would really
  allow an effective split, as the individual components would remain
  tightly coupled.  Many changes to one project would also require
  changes to the other projects.  However, it would be a clear
  win to move features that don't currently require a node into a
  library or tool that can be maintained independently.  He also
  describes how some people are using nodes today with middleware that
  makes it easy for users to connect their wallets to their own
  nodes using blockchain indexes (basically [a
  personal block explorer][topic block explorers])---something the
  Bitcoin Core project has previously rejected including in its node
  directly.  Finally, he [notes][towns pri2] that "to [him], providing
  wallet features (mostly) and a GUI (to a lesser extent[...]) is a way
  of keeping us honest to the principle of bitcoin being usable by a
  decentralized bunch of hackers, versus being something that you can
  only really use if you’re a whale or an established corporation
  willing to make a big investment."

  David Harding expresses [concern][harding pri] that refocusing the
  main project on just consensus code and P2P relay will make it harder
  for everyday users to use a full node to validate their own incoming
  wallet transactions.  He asks Poinsot and other contributors to
  consider focusing instead on making Bitcoin Core easier for everyday
  users.  He describes the power of full node validation: those who
  operate the full nodes that validate the predominate amount of economic
  activity have the ability to define Bitcoin's consensus rules.  In an
  example, he shows that even a 30 minute change in what rules are
  enforced could lead to the politically permanent destruction of
  cherished properties of Bitcoin, such as the 21M BTC limit.  He
  believes that everyday users are more strongly invested in Bitcoin's
  properties than organizations that run nodes on behalf of their
  customers.  If developers of Bitcoin Core value the current consensus
  rules, Harding argues that making it easy for everyday users to
  personally validate their wallet transactions is as important for
  security as preventing and eliminating bugs that could lead to severe
  vulnerabilities.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Bitcoin Forking Guide:** Anthony Towns [announced][towns bfg] to
  Delving Bitcoin a guide to how to build community consensus for
  changes to Bitcoin's consensus rules.  He splits the social consensus
  building into four stages---research and development, power user
  exploration, industry evaluation, and investor review.  He then
  briefly touches on the technical steps that come at the end of the
  process to activate the change in Bitcoin software.

  His post notes that "it’s only a guide to the cooperative path, where
  you make a change that makes everyone’s life better, and more or less
  everyone ends up agreeing that the change makes everyone’s lives
  better."  He also warns that "it's also only a fairly high-level
  guide."

- **Update on BIP360 pay-to-quantum-resistant-hash (P2QRH):** developer
  Hunter Beast [posted][beast p2qrh] an update on his research into
  [quantum resistance][topic quantum resistance] for [BIP360][] to the
  Bitcoin-Dev mailing list.  He's made changes to the list of
  quantum-secure algorithms he's proposing to use, is looking for
  someone to champion development of a pay-to-taproot-hash (P2TRH)
  scheme (see [Newsletter #141][news141 p2trh]), and is considering
  targeting the same security level as currently provided by Bitcoin
  (NIST II) rather than a higher level (NIST V) that requires more block
  space and CPU verification time.  His post received multiple replies.

- **Private block template marketplace to prevent centralizing MEV:** Matt
  Corallo and developer 7d5x9 [posted][c7 mev] to Delving Bitcoin about
  allowing parties to bid in public markets for selected space within
  miner block templates.  For example, "I’ll pay X [BTC] to include
  transaction Y as long as it comes before any other transactions which
  interact with the smart contract identified by Z".  This is something
  that transaction creators on Bitcoin already want for various
  protocols, such as certain [colored coin protocols][topic client-side
  validation], and it's likely to become even more desirable in the
  future as new protocols are developed (including proposals requiring
  consensus changes such as certain [covenants][topic covenants]).

  If the service of preferential transaction ordering within block
  templates is not provided by a trust-reduced public market, it's
  probable that it will instead be provided by large miners, who will
  compete with users of the various protocols.  This will require the
  miners obtain large amounts of capital and technical sophistication,
  likely leading to them earning significantly higher profits than smaller
  miners without those capabilities.  This will centralize mining and
  allow the large miners to censor Bitcoin transactions more easily.

  The developers propose providing trust reduction by allowing miners to
  work on blinded block templates whose complete transactions aren't
  revealed to the miner until they've produced sufficient proof of work
  to publish the block.  The developers propose two mechanisms for
  achieving this without requiring any consensus changes:

  - **Trusted block templates:** a miner connects to a marketplace, selects
    the bids it wants to include in a block, and asks the marketplace to
    construct a block template.  The marketplace responds with a block
    header, coinbase transaction, and partial merkle branch that allow
    the miner to generate proof of work for that template without
    learning its exact contents.  If the miner does produce the network
    _target_ amount of proof of work, it submits the header and coinbase
    transaction to the marketplace, which verifies the proof of work,
    adds it to the block template, and
    broadcasts the block.  The marketplace might include a transaction
    paying the miner in the block template or it might pay the miner
    separately at a later time.

  - **Trusted execution environments:** miners obtain a device with a
    [TEE][] secure enclave, connect to marketplaces and select bids they
    want to include in their blocks, and receive the transactions in
    those bids encrypted to the TEE's enclave key.  The block template
    is constructed within the TEE and the TEE provides the host operating
    system with the header, coinbase transaction, and partial merkle
    branch.  If the target proof of work is generated, the miner
    provides it to the TEE, which verifies it and returns the full
    decrypted block template for the miner to add to the header and broadcast.  Again, the block
    template might include a transaction paying the miner from a UTXO
    belonging to the marketplace or the marketplace might pay the miner
    later.

  Both schemes would effectively require multiple competing
  marketplaces, with the proposal noting that the expectation would be
  that some community members and organizations would operate marketplaces
  on a non-profit basis to help preserve decentralization against the
  dominance of a single trusted marketplace.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.02][] is a release of the next major version of
  this popular LN node.  It includes support for [peer storage][topic
  peer storage] (used for storing encrypted penalty transactions that can be
  retrieved and decrypted to provide a type of [watchtower][topic
  watchtowers]) in addition to other improvements and bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #3019][] Prioritize remote commitment instead of local one

- [Eclair #3016][] Add scripts for taproot channels

- [LDK #3342][] Introduce RouteParametersConfig

- [Rust Bitcoin #4114][] Policy: Relax MIN_STANDARD_TX_NONWITNESS_SIZE to 65

- [Rust Bitcoin #4111][] Add support for pay to anchor outputs

- [BIPs #1758][] BIP374: Add message to rand computation

- [BIPs #1750][] BIP329: add optional data fields, fix a JSON type

- [BIPs #1712][] and [#1771][bips #1771] BIP3 updated BIP process

{% include snippets/recap-ad.md when="2025-03-11 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3019,3016,3342,4114,4111,1758,1750,1712,1771,1233" %}
[Core Lightning 25.02]: https://github.com/ElementsProject/lightning/releases/tag/v25.02
[news39 multiprocess]: /en/newsletters/2019/03/26/#bitcoin-core-10973
[news141 p2trh]: /en/newsletters/2021/03/24/#we-could-add-a-hash-style-address-after-taproot-is-activated
[poinsot pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/
[poinsot pri1]: https://antoinep.com/posts/core_project_direction/
[poinsot pri2]: https://antoinep.com/posts/stating_the_obvious/
[poinsot pri3]: https://antoinep.com/posts/bitcoin_core_scope/
[towns pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/3
[towns pri2]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/15
[harding pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/10
[towns bfg]: https://delvingbitcoin.org/t/bitcoin-forking-guide/1451
[beast p2qrh]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8797807d-e017-44e2-b419-803291779007n@googlegroups.com/
[c7 mev]: https://delvingbitcoin.org/t/best-worst-case-mevil-response/1465
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news17 cln2000]: /en/newsletters/2018/10/16/#c-lightning-2000
[morehouse failback]: https://delvingbitcoin.org/t/disclosure-lnd-excessive-failback-exploit/1493
[lnd current]: https://github.com/lightningnetwork/lnd/releases
