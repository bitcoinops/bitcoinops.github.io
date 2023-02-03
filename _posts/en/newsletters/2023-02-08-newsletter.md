---
title: 'Bitcoin Optech Newsletter #237'
permalink: /en/newsletters/2023/02/08/
name: 2023-02-08-newsletter
slug: 2023-02-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about storing data in
transaction witnesses and references a conversation about mitigating LN
jamming.  Also included are our regular sections with the summary of a
Bitcoin Core PR Review Club meeting, announcements of new releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

- **Discussion about storing data in the block chain:** users of a new
  project recently began storing large amounts of data in the witness
  data for segwit v1 ([taproot][topic taproot]) transactions.   Robert
  Dickinson [posted][dickinson ordinal] to the Bitcoin-Dev mailing list
  to inquire about whether a size limit should be imposed to discourage
  such data storage.

    Andrew Poelstra [replied][poelstra ordinal] that there is no
    effective way to prevent data storage.  Adding new restrictions to
    prevent unwanted data storage in witnesses would undermine
    advantages discussed during taproot's design (see [Newsletter
    #65][news65 tapscript]) and would likely only result in the data
    being stored in other ways.  Those other ways might raise costs for
    those generating the data---but probably not by enough to
    significantly discourage the behavior---and the alternative storage
    methods might create new problems for traditional Bitcoin users.

- **Summary of call about mitigating LN jamming:** Carla Kirk-Cohen and
  Clara Shikhelman [posted][ckccs jamming] to the Lightning-Dev mailing
  list a summary of a recent video conversation about attempts to
  address [channel jamming attacks][topic channel jamming attacks].
  Topics discussed included upgrade mechanism tradeoffs, a simple
  proposal for upfront fees derived from a recent paper (see [Newsletter
  #226][news226 jam]), the CircuitBreaker software (see [Newsletter
  #230][news230 jam]), an update on reputation credentials (see
  [Newsletter #228][news228 jam]), and related work from the Lightning
  Service Provider (LSP) specification working group.  See the mailing
  list post for extended summaries and a [transcript][jam xs].

    Future video meetings are planned for every two weeks; watch the
    Lightning-Dev mailing list for announcements of upcoming meetings.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Track AddrMan totals by network and table, improve precision of adding fixed seeds][review club 26847]
is a PR by Martin Zumsande, co-authored by Amiti Uttarwar, that
allows the Bitcoin Core client to more reliably find outbound peers
in certain situations.
It does this by enhancing `AddrMan`
(the peer address manager) to keep track of the number of address entries
separately by network and "tried" versus "new" type, which in turn allows
better use of fixed seeds. This is the first step in a larger effort to
improve outbound peer selection.

{% include functions/details-list.md
  q0="When is a network considered reachable?"
  a0="A network is assumed to be reachable unless we're sure we
      can't access it, or our configuration has specified one or
      more _other_ networks using the `-onlynet=` configuration option
      (only those are considered reachable, even if other network
      types are actually available).
  a0link="https://bitcoincore.reviews/26847#l-22"

  q1="How is an address received over the p2p network treated depending
      on whether the address's network is reachable vs. non-reachable --
      do we store it (add it to `AddrMan`) and/or forward it to peers?"
  a1="If its network is reachable, we relay the address to two
      randomly-chosen peers, else we relay it to 1 or 2 peers (whether
      1 or 2 is randomly-chosen).
      We only store the address if its network is reachable."
  a1link="https://bitcoincore.reviews/26847#l-51"

  q2="How can a node currently get stuck with only unreachable addresses
      in `AddrMan`, finding no outbound peers? How does this PR fix it?"
  a2="If the `-onlynet` configuration changes. For example, suppose the
      node has always been run with `-onlynet=ipv4` so its AddMan has
      no ipv6 addresses. Then the node is restarted with `-onlynet=onion`.
      The fixed seeds have some onion addresses, but without the PR, the node
      won't use them since the `AddrMan` isn't _completely_ empty (it has some
      ipv4 addresses from before). With the PR, the startup code will add
      some onion fixed seeds, since `AddrMan` doesn't contain any addresses
      of _that_ (now reachable) network type.
  a2link="https://bitcoincore.reviews/26847#l-98"

  q3="When an address we'd like to add to `AddrMan` collides with an existing
      address, what happens? Is the existing address always dropped in favor
      of the new address?"
  a3="No, generally the existing address is retained (not the new one),
      unless the existing address is deemed "terrible"
      (see `AddrInfo::IsTerrible()`).
  a3link="https://bitcoincore.reviews/26847#l-100"

  q4="Why would it be beneficial to have an outbound connection to each
      reachable network at all times?"
  a4="A selfish reason is that it's harder to eclipse-attack the node,
      since the attacker would need to run nodes on multiple networks.
      A non-selfish reason is that it helps keep the overall network
      together, avoiding chain splits caused by network partitions.
      If half the nodes, including miners, ran with `-onlynet=x` and
      the other half, including miners, ran `-onlynet=y`, then two
      chains could emerge."
  a4link="https://bitcoincore.reviews/26847#l-114"

  q5="Why is the current logic in `ThreadOpenConnections()`, even with
      the PR, insufficient to guarantee that the node has an outbound
      connection to each reachable network at all times?"
  a5="Nothing in the PR _guarantees_ any particular distribution of
      peers among the reachable networks. For example, if we had 10k
      clearnet addresses and only 50 I2P addresses in `AddrMan`, it's
      very likely that all our peers will be clearnet (ipv4 or ipv6)."
  a5link="https://bitcoincore.reviews/26847#l-123"

  q6="What would be the next steps towards this goal (see the previous
      question) after this PR?"
  a6="The next planned steps are to add logic to the connection-making
      process to attempt to have at least one connection to each
      reachable network. This PR prepares for that."
  a6link="https://bitcoincore.reviews/26847#l-144"
%}

<!-- FIXME:harding to add releases/rc if any on Tuesday -->

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25880][] p2p: Make stalling timeout adaptive during IBD FIXME:Xekyo

- [Core Lightning #5679][] sql plugin FIXME:adamjonas

- [Core Lightning #5821][] adds `preapproveinvoice` (pre-approve
  invoice) and `preapprovekeysend` (pre-approve keysend) RPCs that allow
  the caller to send either a [BOLT11][] invoice or a [keysend][topic
  spontaneous payments] payment details to Core Lightning's signing module
  (`hsmd`) to verify the module is willing to sign the payment.  For
  some applications, such as those where the amount of money which can
  be spent is rate limited, asking for pre-approval might produce fewer
  problems than simply attempting the payment and dealing with failure.

- [Core Lightning #5849][] makes backend changes that allow a node to
  handle over 100,000 peers each with one channel.  Although someone
  running such a node in production is not likely in the near
  future---it would take over a dozen entire blocks to just open that
  many channels---testing the behavior helped the developer make several
  performance improvements.

- [Core Lightning #5892][] updates CLN's implementation of the
  [offers][topic offers] protocol based on compatibility testing
  performed by a developer working on Eclair's implementation.

- [Eclair #2565][] now requests that funds from a closed channel be sent
  to a new onchain address, rather than an address which was generated
  when the channel was funded.  This may decrease [output linking][topic
  output linking], which helps improve user privacy.  An exception to
  this policy is when the user enables the LN protocol option
  `upfront-shutdown-script`, which is a request sent to the channel
  partner at funding time to only use the closing address specified at
  that time (see [Newsletter #158][news158 upfront] for details).

- [LND #7252][] adds support for using Sqlite as LND's database backend.
  This is currently only supported for new installs of LND as there is
  no code for migrating an existing database.

- [LND #6527][] adds the ability to encrypt the server's on-disk TLS
  key.  LND uses TLS for authenticating remote connections to its
  control channel, i.e. to run APIs.  The TLS key will be encrypted
  using data from the node's wallet, so unlocking the wallet will unlock
  the TLS key.  Unlocking the wallet is already required to send and
  accept payments.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25880,5679,5821,5849,5892,2565,7252,6527" %}
[news158 upfront]: /en/newsletters/2021/07/21/#eclair-1846
[dickinson ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021370.html
[poelstra ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021372.html
[news65 tapscript]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[ckccs jamming]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003834.html
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news230 jam]: /en/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming
[news228 jam]: /en/newsletters/2022/11/30/#reputation-credentials-proposal-to-mitigate-ln-jamming-attacks
[jam xs]: https://github.com/ClaraShk/LNJamming/blob/main/meeting-transcripts/23-01-23-transcript.md
[review club 26847]: https://bitcoincore.reviews/26847
