---
title: 'Bitcoin Optech Newsletter #251'
permalink: /en/newsletters/2023/05/17/
name: 2023-05-17-newsletter
slug: 2023-05-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to begin testing HTLC
endorsement, relays a request for feedback about proposed specifications
for Lightning Service Providers (LSPs), discusses challenges with
opening zero-conf channels when using dual funding, looks at a
suggestion for advanced applications of payjoin transactions, and links
to summaries of a recent in-person meeting of Bitcoin Core developers.
Also included in this week's newsletter is the first part of a new
series about policies for transaction relay and mempool inclusion, plus
our regular sections announcing new releases and release candidates (including
a security release of libsecp256k1) and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Testing HTLC endorsement:** several weeks ago, Carla Kirk-Cohen and
  Clara Shikhelman [posted][kcs endorsement] to the Lightning-Dev mailing list about
  the next steps they and others planned to take to test the idea of
  [HTLC][topic htlc] endorsement (see [Newsletter #239][news239
  endorsement]) as part of a mitigation for [channel jamming
  attacks][topic channel jamming attacks].  Most notably, they provided a
  short [proposed specification][bolts #1071] that could be deployed
  using an experimental flag, preventing deployments of it from having any effect on
  interactions with non-participating nodes.

  Once deployed by experimenters, it should become easier to answer
  one of the [constructive criticisms][decker endorsement] of this idea, which is how
  many forwarded payments would actually receive a boost from the
  scheme.  If the core users of LN are
  frequently sending payments to each other over many of the same
  routes, and if the reputation system works as planned, then that
  core network will be more likely to keep functioning during a
  channel jamming attack.  But if most spenders only send payments
  rarely (or only send their most critical types of payments rarely,
  such as high-value payments), then they won't have enough
  interactions to build a reputation, or the reputation data will lag
  far behind the current state of the network (making it less useful
  or even allowing reputation to be abused). {% assign timestamp="1:33" %}

- **Request for feedback on proposed specifications for LSPs:** Severin
  Bühler [posted][buhler lsp] to the Lightning-Dev mailing list a request for
  feedback on two specifications for interoperability between Lightning
  Service Providers (LSPs) and their clients (usually non-forwarding LN
  nodes).  The first specification describes an API for allowing a
  client to purchase a channel from an LSP.  The second describes an API
  for setting up and managing Just-In-Time (JIT) channels, which are
  channels that start their lives as virtual payment channels; when the
  first payment to the virtual channel is received, the LSP broadcasts a
  transaction that will anchor the channel onchain when it is confirmed
  (making it into a regular channel).

  In a [reply][zmnscpxj lsp], developer ZmnSCPxj wrote in favor of open specifications
  for LSPs.  He noted that they make it easy for a client to connect
  to multiple LSPs, which will prevent vendor lock-in and improve
  privacy. {% assign timestamp="14:52" %}

- **Challenges with zero-conf channels when dual funding:** Bastien
  Teinturier [posted][teinturier 0conf] to the Lightning-Dev mailing list about the
  challenges of allowing [zero-conf channels][topic zero-conf channels] when using the
  [dual-funding protocol][topic dual funding].   Zero-conf channels can be used even before the
  channel open transaction is confirmed; this is trustless in some
  cases.  Dual-funded channels are channels that were created using the
  dual-funding protocol, which may include channels where the open
  transaction contains inputs from both parties in the channel.

  Zero-conf is only trustless when one party controls all of the
  inputs to the open transaction.  For example, Alice creates the
  open transaction, gives Bob some funds in the channel, and Bob tries
  spending those funds through Alice to Carol.  Alice can safely forward
  the payment to Carol because Alice knows she's in control of the
  open transaction eventually becoming confirmed.  But if Bob also has
  an input in the open transaction, he can get a conflicting
  transaction confirmed that will prevent the open transaction from
  confirming---preventing Alice from being compensated for any money
  she forwarded to Carol.

  Several ideas for allowing zero-conf channel opens with dual funding
  were discussed, although none seemed satisfying to participants as
  of this writing. {% assign timestamp="20:59" %}

- **Advanced payjoin applications:** Dan Gould [posted][gould payjoin] to the
  Bitcoin-Dev mailing list several suggestions for using the
  [payjoin][topic payjoin] protocol to do more than just send or receive
  a simple payment.  Two of the suggestions we found most interesting
  were versions of [transaction cut-through][], an old idea for
  improving privacy, improving scalability, and reducing fee costs:

  - *Payment forwarding:* rather than Alice paying Bob, Alice instead
    pays Bob's vendor (Carol), reducing a debt he owes her (or
    pre-paying for an expected future bill).

  - *Batched payment forwarding:* rather than Alice paying Bob, Alice
    instead pays several people Bob owes money (or wants to establish
    a credit with).  Gould's example considers an exchange that has a
    steady stream of deposits and withdrawals; payjoin allows withdrawals
    to be paid for by new deposits when possible.

  Both of these techniques allow reducing what would be at least two
  transactions into a single transaction, saving a considerable amount
  of block space.  When [batching][topic payment batching] is used,
  the space savings may be even larger.  Even better from the
  perspective of the original receiver (e.g. Bob),
  the original spender (e.g. Alice) may pay all or some of the
  fees.  Beyond the space and fee savings, removing transactions from
  the block chain and combining operations like receiving and spending
  makes it significantly more difficult for block chain surveillance
  organizations to reliably trace the flow of funds.

  As of this writing, the post had not received any discussion on the
  mailing list. {% assign timestamp="24:51" %}

- **Summaries of Bitcoin Core developers in-person meeting:** several
  developers working on Bitcoin Core recently met to discuss aspects of
  the project.  Notes from several discussions during that meeting have
  been published.  Topics discussed included [fuzz testing][],
  [assumeUTXO][], [ASMap][], [silent payments][], [libbitcoinkernel][],
  [refactoring (or not)][], and [package relay][].  Also discussed were
  two other topics we think deserve special attention: {% assign timestamp="37:35" %}

  - [Mempool clustering][] summarizes a suggestion for a significant
    redesign of how transactions and their metadata are stored in
    Bitcoin Core's mempool.  The notes describe a number of problems
    with the current design, provide an overview of the new design,
    and suggest some of the challenges and tradeoffs involved.  A
    [description][bitcoin core #27677] of the design and a copy of the
    [slides][mempool slides] from the presentation were later published.

  - [Project meta discussion][] summarizes a varied discussion about
    the project's goals and how to achieve them despite many
    challenges, both internal and external.  Some of the discussion
    has already led to experimental changes in the project's
    management, such as a more project-focused approach for the next
    major release after version 25.

## Waiting for confirmation #1: why do we have a mempool?

_The first segment in a limited weekly series about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/01-why-mempool.md %} {% assign timestamp="51:07" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Libsecp256k1 0.3.2][] is a security release for applications that use
  libsecp for [ECDH][] and that may be compiled with GCC version 13 or
  higher.  As [described by the authors][secp ml], new versions of GCC
  attempt to optimize libsecp code that was designed to run in a fixed
  amount of time, making it possible to execute a [side-channel
  attack][topic side channels] under certain circumstances.  It's worth
  noting that Bitcoin Core does not use ECDH and is not affected.  There
  is ongoing work to try to detect when future changes to compilers
  might cause similar problems, allowing changes to be made in advance. {% assign timestamp="1:04:21" %}

- [Core Lightning 23.05rc2][] is a release candidate for the next
  version of this LN implementation. {% assign timestamp="1:05:07" %}

- [Bitcoin Core 23.2rc1][] is a release candidate for a maintenance
  release of the previous major version of Bitcoin Core. {% assign timestamp="1:05:20" %}

- [Bitcoin Core 24.1rc3][] is a release candidate for a maintenance
  release of the current version of Bitcoin Core. {% assign timestamp="1:05:20" %}

- [Bitcoin Core 25.0rc2][] is a release candidate for the next major
  version of Bitcoin Core. {% assign timestamp="1:05:20" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26076][] updates RPC methods that show derivation paths for
  public keys now use `h` instead of a single-quote `'` to indicate a
  hardened derivation step. Note that this changes the descriptor
  checksum. When handling descriptors with private keys, the same symbol
  is used as when the descriptor was generated or imported. For legacy
  wallets the `hdkeypath` field in `getaddressinfo` and the
  serialization format of wallet dumps remain unchanged. {% assign timestamp="1:06:10" %}

- [Bitcoin Core #27608][] will continue trying to download a block from
  a peer even if another peer provided the block.  Bitcoin Core will
  continue trying to download the block from peers that claim to have it
  until one of the received blocks has been written to disk. {% assign timestamp="1:07:20" %}

- [LDK #2286][] allows creating and signing [PSBTs][topic psbt] for
  outputs controlled by the local wallet. {% assign timestamp="1:08:27" %}

- [LDK #1794][] begins adding support for [dual funding][topic dual
  funding], starting with methods needed for the interactive funding
  protocol that is used for dual funding. {% assign timestamp="1:08:47" %}

- [Rust Bitcoin #1844][] makes the schema in a [BIP21][] URI lowercase,
  i.e. `bitcoin:`.  Although the specification for URI schema (RFC3986)
  says the schema is case insensitive, testing shows that some platforms
  are not opening the application assigned to handle `bitcoin:` URIs
  when an uppercase `BITCOIN:` is passed.  It would be preferable if
  uppercase was handled correctly, as it allows the creation of more efficient
  QR codes (see [Newsletter #46][news46 qr]). {% assign timestamp="1:09:08" %}

- [Rust Bitcoin #1837][] adds a function for generating a new private
  key, simplifying what previously required more code to accomplish. {% assign timestamp="1:11:33" %}

- [BOLTs #1075][] updates the specification so that nodes should no
  longer disconnect from a peer after receiving a warning message from
  it. {% assign timestamp="1:12:04" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="26076,27608,2286,1794,1844,1837,1075,1071,27677" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 23.2rc1]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1rc3]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[news239 endorsement]: /en/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring
[fuzz testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-fuzzing/
[assumeutxo]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-assumeutxo/
[asmap]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-asmap/
[silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-silent-payments/
[libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-libbitcoin-kernel/
[refactoring (or not)]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-refactors/
[package relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-package-relay-primer/
[mempool clustering]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-mempool-clustering/
[project meta discussion]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-meta-discussion/
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-April/003918.html
[decker endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003944.html
[buhler lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003926.html
[zmnscpxj lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003930.html
[teinturier 0conf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003920.html
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021653.html
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[news46 qr]: /en/newsletters/2019/05/14/#bech32-sending-support
[mempool slides]: https://github.com/bitcoin/bitcoin/files/11490409/Reinventing.the.Mempool.pdf
[secp ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021683.html
[libsecp256k1 0.3.2]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.2
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
