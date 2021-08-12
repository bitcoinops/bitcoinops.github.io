---
title: 'Bitcoin Optech Newsletter #100'
permalink: /en/newsletters/2020/06/03/
name: 2020-06-03-newsletter
slug: 2020-06-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposed design for a coinswap
implementation, describes new middleware for allowing lightweight
wallets to request information directly from a user's own node, and highlights
two transaction size calculators.  Also included are our regular
sections with descriptions of several recently transcribed talks, new
releases and release candidates, and notable changes to popular Bitcoin
infrastructure software.  A special final section celebrates the
publication of Newsletter #100.

## Action items

*None this week.*

## News

- **Design for a coinswap implementation:** Chris Belcher
  [posted][belcher coinswap] a design for a full-featured coinswap
  implementation.  Coinswap is a protocol that allows two users to
  create a pair of transactions that look like regular payments but which
  actually swap their coins with each other.  This improves the privacy
  of not just the coinswap users but all Bitcoin users, as anything that
  looks like a payment could have instead been a coinswap.

    Belcher's post summarizes the history of the coinswap idea, suggests
    ways the multisig conditions needed for coinswap could be disguised
    as more common transaction types, proposes using a market for
    liquidity (like JoinMarket already does), describes splitting and
    routing techniques to reduce privacy losses from amount correlation
    or spying participants, mentions alternative coinswap protocols such
    as succinct atomic swaps (see [Newsletter #98][news98 sas]), suggests
    combining coinswap with [payjoin][topic payjoin], and discusses some
    of the backend requirements for the system.  Additionally,
    he compares coinswap to other privacy techniques such as using LN,
    [coinjoin][topic coinjoin], payjoin, and [payswap][zmn payswap].

    Belcher has a history of creating and maintaining privacy-enhancing
    open source software for Bitcoin, such as [JoinMarket][] and
    [Electrum Personal Server][eps], which gives particular weight to
    the conclusion of his email: "I intend to create this CoinSwap
    software.  It will be almost completely decentralized and available
    for all to use for free."

- **New node-to-wallet middleware:** Nadav Ivgi [announced][ivgi bwt]
  the alpha release of Bitcoin Wallet Tracker (BWT), a program that
  interacts with Bitcoin Core's wallet using its standard RPC interface,
  uses that data to build additional indexes necessary for lightweight
  wallets, and then makes that data available via both the Electrum
  Server protocol and BWT's own [extensive HTTP-based API][bwt api].
  Similar to Electrum Personal Server, this allows users who prefer the
  UI of a lightweight wallet (such as Electrum) to retrieve block and
  transaction data from their own full verification node for additional
  security.  There's no significant overhead to BWT's approach: its
  additional indexes are stored only in memory and it can work with
  pruned nodes in [many cases][bwt pruning], allowing a combined `bitcoind` and `bwt`
  setup to use only a few gigabytes of disk space.

    Ivgi also provides a [plugin][bwt plugin] that simplifies setting up
    BWT with an Electrum client, and it may also be possible to use BWT
    with other wallets that support the Electrum Server protocol, such
    as [Edge][], [Blue Wallet][], [Eclair mobile][], and [Phoenix][].

    BWT's HTTP protocol supports additional features beyond those
    available in the Electrum Server protocol, such as key origin
    information useful for interaction with HD wallets and wallet
    collaboration tools such as [PSBT][topic psbt].  His email also
    notes that future versions of BWT may support [output script
    descriptors][topic descriptors], allowing wallets to produce and
    consume standardized descriptions of their script templates.

- **Transaction size calculators:** Jameson Lopp [posted][lopp size] to
  the Bitcoin-Dev mailing list with links to a [transaction size
  calculator][lopp calc] he'd developed as well as a similar [calculator
  developed by Optech][optech calc].  Neither tool claims to be complete
  or bug-free, but both should be useful to developers who want to
  make a quick comparison between the sizes of different types of transactions.

## Recently transcribed talks and conversations

*[Bitcoin Transcripts][] is the home for transcripts of technical
Bitcoin presentations and discussions. In this monthly feature, we
highlight a selection of the transcripts from the previous month.*

- **LN backups:** Christian Decker presented at Potzblitz on the latest
  state of LN backups. He discussed the approaches of other
  implementations such as Eclair and LND before explaining why
  C-Lightning is using a synchronous database log plugin. Later, he
  described why LN backups are more complex than onchain backups, the
  prospects of adding [SIGHASH_NOINPUT][topic sighash_anyprevout] or
  `SIGHASH_ANYPREVOUT` to Bitcoin to enable [eltoo-based][topic eltoo]
  payment channels, and the current modularity of the LN protocol.
  ([transcript][decker xs], [video][decker vid])

- **Payjoin/P2EP:** Adam Gibson led a discussion at London BitDevs about
  [payjoin][topic payjoin], a protocol that allows both the sender and
  receiver of a payment to contribute inputs to the transaction.  This
  breaks the [common input ownership assumption][] and subset sum
  analysis, improving the privacy of both the sender and the receiver.
  Gibson went through the history
  of the concept and described the existing implementations of payjoin
  in JoinMarket and Samourai before examining details of the recent
  BTCPay Server implementation. He ended by outlining several different
  ways a wallet can be fingerprinted, such as the number of signatures
  required, what timelocks are used, and whether the opt-in
  Replace-By-Fee ([RBF][topic rbf]) flag is set.  ([transcript][gibson
  xs], [video][gibson vid])

- **LSAT---your ticket aboard the lightning native web:** Oliver Gugger
  presented the Lightning Service Authentication Token (LSAT) at
  Reckless VR in virtual reality. LSAT is a proposed protocol
  specification combining HTTP, macaroons, and Lightning. It's designed
  to fulfill the purpose of the HTTP 402 Payment Required response code.
  Gugger described the authentication flow and the role of macaroons as
  pseudonymous user authentication. The question and answer session
  focused on use cases and the benefits of using LSAT, such as enhanced
  user privacy and improved sign-up experience.
  ([transcript](https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-05-16-oliver-gugger-lsat/),
  [video](https://www.youtube.com/watch?v=IW08RJUpzw0))

- **Sydney meetup discussion:** A number of Bitcoin and LN developers
  joined this Sydney meetup to discuss topics including: the scalability
  issues of onboarding millions of LN clients, Rust code integration
  into Bitcoin Core, dual funding in C-Lightning, and future soft fork
  activation mechanisms. The history of Linux kernel development and segwit
  activation were each explored for insights into when or whether the Rust
  language should be introduced to Bitcoin Core and the exact mechanism
  that should be used to activate proposed soft forks such as
  [taproot][topic taproot] in the future. The transcript was anonymized to
  encourage open discussion.  ([transcript][sydney xs])

- **The Revault multiparty vault architecture:** Kevin Loaec and Antoine
  Poinsot presented their vault design *Revault* at London Bitcoin
  Devs. They outlined specific details such as its reliance on
  co-signing servers and how it compares to other vault designs
  that require key deletion, anticipating spending amounts, or both.
  Their presentation was preceded the week before by a broader discussion
  on vaults, [covenants][topic covenants], and `OP_CHECKTEMPLATEVERIFY`
  (`OP_CTV`). This included the merits of the different use cases of
  `OP_CTV` and a possible path to it being soft forked into Bitcoin.
  Additional discussion focused on the current state of the mempool
  policy in Bitcoin Core and how it creates challenges such as
  [transaction pinning][topic transaction pinning] that affect the
  security of both vault designs and the LN protocol.  ([Meetup
  transcript][london xs], [Presentation transcript][revault xs], [Meetup
  video][london vid], [Presentation video][revault vid])

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- **Bitcoin Core 0.20.0** has been tagged and will likely be released
  around the same time this newsletter is published.  We'll describe
  this new major release in more detail next newsletter.

- [LND 0.10.1-beta.rc3][] is the latest release candidate for the next
  maintenance release of LND.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until version 0.21, about six months after the release of the upcoming
version 0.20.*

- [Bitcoin Core #19010][] and [Bitcoin Core #19044][] are the third and fourth
  steps, respectively, of a [series of five pull requests][Bitcoin Core #18876]
  towards support for serving [compact block filters][topic compact block
  filters] on the P2P network, as specified in [BIP157][]. The first step was
  covered in [Newsletter #98][news98 bitcoin core 18877].

    With these changes, nodes that enable the compact block filter index with the
    `-blockfilterindex` configuration parameter can now respond to `getcfcheckpt`,
    `getcfheaders`, and `getcfilters` requests with the corresponding `cfcheckpt`,
    `cfheaders`, and `cfilters` responses. The node does not yet advertise support
    for BIP157 with `NODE_COMPACT_FILTERS` in its version message. The final step,
    [Bitcoin Core #19070][], is under review at the time of this writing and
    would enable nodes to signal the ability to serve compact block filters.
    The feature is disabled by default and can be enabled with the
    `-peerblockfilters` configuration parameter.

- [Bitcoin Core #16939][] changes how long Bitcoin Core waits until
  it queries DNS seeds for the IP addresses of potential peers.
  Previously, if the node had peer IP addresses in its database, it
  would try opening several connections and wait 11 seconds for
  successful connections before requesting new addresses.  Now, if it
  has more than 1,000 IP addresses in its database---which is common for
  nodes that have been online more than a few hours---it'll wait up to 5
  minutes before querying.  This improves the chance that a restarted
  node will entirely use P2P address discovery without relying on the
  centralized DNS seeds.

- [LND #4228][] adds a new wallet command, `labeltx`, for labeling past onchain
  transactions. This is a continuation of the work done in [LND #4213][], which
  allowed setting a label when sending a payment.  Labels are personal
  wallet metadata that help the user remember who they paid and what
  they bought; the labels aren't part of the onchain transactions and
  aren't shared with any other user.

## On the occasion of Optech Newsletter #100

> "I am somewhat surprised that nobody has taken to [writing] weekly
> summaries of research and development activity. Summarizing recent
> work is a valuable task that others can engage in just by reading the
> mailing list and aggregating multiple thoughts together."
>
> {:.right}
> ---Bryan Bishop, [19 August 2015][bishop summaries]

Almost five years after Bishop made the above comment, we remain
convinced that writing weekly summaries of research and development
activity is a task that's valuable to both the open source Bitcoin
development community and to the many businesses that depend upon the
community's work.  But in the two years we've been producing this
newsletter, we've also discovered that summarizing isn't quite as quick
and simple as we initially expected it to be.  Accordingly, we'd like to
take this chance to thank the people who make this newsletter possible
by generously contributing a significant amount of their valuable time,
week after week: [Adam Jonas][], [Carl Dong][], [David A. Harding][],
[John Newbery][], [Jon Atack][], [Mike Schmidt][], and [Steve Lee][].

We additionally thank the experienced Bitcoin and LN contributors who
kindly provided us with special help on certain complex topics or who
contributed field reports and other additional content to the newsletter
over the past two years.

Publishing a high-quality weekly newsletter and working to fulfill other
aspects of Optech's [mission][about page] wouldn't be possible without
the financial support of our member companies.  We thank them for their
continuing commitment to improving communication between Bitcoin users,
developers, and businesses.

{:.center style="font-size: 1.5em"}
![Thank you to our members!](/img/posts/2020-06-members.png)

We also remain eternally thankful to our founding sponsors [Wences
Casares][], [John Pfeffer][], and [Alex Morcos][] <!-- same order as on
About page --> as well as to organizations such as [Chaincode Labs][]
and [Square Crypto][] who allow and encourage their staff to use
their work hours to contribute to Optech.

{% include references.md %}
{% include linkers/issues.md issues="19010,16939,4228,19044,18876,19070,4213" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta.rc3
[bishop summaries]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-August/010488.html
[news98 sas]: /en/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[belcher coinswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017898.html
[zmn payswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017595.html
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[eps]: https://github.com/chris-belcher/electrum-personal-server
[lopp size]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017905.html
[lopp calc]: https://jlopp.github.io/bitcoin-transaction-size-calculator/
[optech calc]: /en/tools/calc-size/
[about page]: /about/
[ivgi bwt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017906.html
[bwt api]: https://github.com/shesek/bwt#http-api
[bwt plugin]: https://github.com/shesek/bwt#electrum-plugin
[edge]: https://edge.app/
[blue wallet]: https://bluewallet.io/
[eclair mobile]: https://github.com/ACINQ/eclair-mobile
[phoenix]: https://phoenix.acinq.co/
[Adam Jonas]: https://github.com/adamjonas
[Carl Dong]: https://github.com/dongcarl
[David A. Harding]: https://github.com/harding
[John Newbery]: https://github.com/jnewbery
[Jon Atack]: https://github.com/jonatack
[Mike Schmidt]: https://github.com/bitschmidty
[Steve Lee]: https://github.com/moneyball
[Wences Casares]: https://en.wikipedia.org/wiki/Wences_Casares
[John Pfeffer]: https://twitter.com/jlppfeffer
[Alex Morcos]: https://twitter.com/morcosa
[Chaincode Labs]: https://chaincode.com/
[bwt pruning]: https://github.com/shesek/bwt#pruning
[Square Crypto]: https://twitter.com/sqcrypto
[decker xs]: https://diyhpl.us/wiki/transcripts/lightning-hack-day/2020-05-03-christian-decker-lightning-backups/
[decker vid]: https://www.youtube.com/watch?v=kGQF3wtzr04
[gibson xs]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-05-05-socratic-seminar-payjoins/
[gibson vid]: https://www.youtube.com/watch?v=hX86rKyNB8I
[gugger xs]: https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-05-16-oliver-gugger-lsat/
[gugger vid]: https://www.youtube.com/watch?v=IW08RJUpzw0
[sydney xs]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-05-19-socratic-seminar/
[london xs]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-05-19-socratic-seminar-vaults/
[revault xs]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-05-26-kevin-loaec-antoine-poinsot-revault/
[london vid]: https://www.youtube.com/watch?v=34jMGiCAmQM
[revault vid]: https://www.youtube.com/watch?v=7CE4aiFxh10
[common input ownership assumption]: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
[news98 bitcoin core 18877]: /en/newsletters/2020/05/20/#bitcoin-core-18877
