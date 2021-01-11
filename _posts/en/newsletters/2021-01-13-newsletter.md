---
title: 'Bitcoin Optech Newsletter #131'
permalink: /en/newsletters/2021/01/13/
name: 2021-01-13-newsletter
slug: 2021-01-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new proposed Bitcoin P2P protocol
message, a BIP for the bech32 modified address format, and an idea for
preventing UTXO probing in proposed dual-funded LN channels.  Also
included are our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, a list of releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **Proposed `disabletx` message:** in 2012, [BIP37][] was published,
  giving lightweight clients the ability to request that peers not
  relay to the client any unconfirmed transactions until the client
  had loaded a [bloom filter][topic transaction bloom filtering].
  Bitcoin Core [later][bitcoin core #6993] reused this mechanism for its
  bandwidth-saving `-blocksonly` mode where a node requests that its
  peers don't send it any unconfirmed transactions at all.  Last year,
  Bitcoin Core with default settings began opening a few
  block-relay-only connections as an efficient way to improve [eclipse
  attack][topic eclipse attacks] resistance without significantly
  increasing bandwidth or reducing privacy (see [Newsletter #63][news63
  bcc15759]).  However, the BIP37 mechanism being used to suppress
  transaction relay allows the initiating node to request full
  transaction relay at any time.  Transaction relay consumes node
  resources such as memory and bandwidth, so nodes need to set their
  connection limits with the assumption that each
  BIP37-based low-bandwidth blocks-relay-only connection could suddenly
  become a full transaction relay connection.

    This week, Suhas Daftuar [posted][daftuar disabletx] to the
    Bitcoin-Dev mailing list a new proposed BIP for a `disabletx`
    message that could be sent during connection negotiation.  A peer
    that understands the message and which implements all of the BIP's
    recommendations won't send the node requesting
    `disabletx` any transaction announcements and won't request any
    transactions from the node.  It also won't send some other gossip
    messages such as `addr` messages used for IP address announcements.
    The `disabletx` negotiation persists for the lifetime of the
    connection, allowing peers to use different limits for disabled
    relay connections, such as accepting additional connections beyond
    the current 125 connection maximum.

- **Bech32m** Pieter Wuille [posted][wuille bech32m post] to the
  Bitcoin-Dev mailing list a [draft BIP][bech32m bip] for a modified
  version of the [bech32][topic bech32] address encoding that increases the
  chance that the accidental addition or removal of characters in one of
  these *bech32m* addresses will be detected.  If no problems are found
  with the proposal, it is expected that bech32m addresses will be used
  for [taproot][topic taproot] addresses and possibly future new script
  upgrades.  Wallets and services implementing support for paying
  bech32m addresses will automatically support paying all those future
  improvements (see [Newsletter #45][news45 bech32 upgrade] for
  details).

- **LN dual funding anti UTXO probing:** a long-term goal for LN has
  been dual funding, the ability to open a new channel with funds from
  both the node initiating the channel and the peer receiving their
  request.  This will allow payments to travel in either direction in
  the channel from the moment it's fully opened.  Before the initiator
  can sign the dual funding transaction, they need the identities
  (outpoints) of all of the UTXOs the other party wants to add to the
  transaction.  This creates a risk that an abuser will attempt to
  initiate dual-funded channels with many different users, learn their
  UTXOs, and then refuse to sign the funding transaction---harming those
  users' privacy at no cost to the abuser.

    This week, Lloyd Fournier [posted][fournier podle] to the Lightning-Dev
    mailing list an evaluation of two previous proposals to deal
    with this problem, [one][zmn podle] using Proofs of Discrete Log
    Equivalency (PoDLEs, see [Newsletter #83][news83 podle]) and the
    [other][darosior sighash] using dual funding transactions
    half-signed with `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`.  Fournier
    extended the previous half-signed proposal and then provided his own
    proposal that was equivalently effective but simpler.  The new
    proposal has the initiator create and sign (but not broadcast) a
    transaction that spends their UTXO back to themselves.  They give
    this to the other party as a proof of good faith---if the initiator
    later fails to sign the actual funding transaction, the respondent
    can broadcast the good-faith transaction, forcing the initiator to
    pay an onchain fee.  Fournier concludes his post with a summary of
    the tradeoffs between the different approaches.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Add unit testing of node eviction logic][review club
#20477] is a PR ([#20477][Bitcoin Core #20477]) by
pseudonymous contributor practicalswift to improve test coverage of Bitcoin Core's peer
eviction logic when a node's inbound connection slots are full. Care
must be taken to avoid exposing the node to attacker-triggered network
partitioning with this logic.

Most of the discussion focused on understanding Bitcoin Core's peer eviction
logic.

{% include functions/details-list.md
  q0="Inbound or outbound peer selection: which one is our primary defense
      against eclipse attacks?"
  a0="Outbound peer selection, as attackers have less influence over what outbound peers
      we select than the inbound connections we accept. Inbound peer eviction is a second-order
      protection---and not all nodes permit incoming connections."
  a0link="https://bitcoincore.reviews/20477#l-77"

  q1="Why does Bitcoin Core evict inbound connections?"
  a1="To make inbound slots available for honest peers in the network so that
      new nodes can establish good outbound connections to them. Otherwise,
      dishonest nodes could more easily attack new nodes by being available for
      their outbound connections and by occupying as many inbound slots as possible."
  a1link="https://bitcoincore.reviews/20477#l-66"

  q2="When it needs to free up a slot, how does Bitcoin Core decide which
      inbound peer to evict?"
  a2="Up to 28 peers are protected from eviction based on criteria that are
      difficult to forge, such as low latency, network group, providing novel
      valid transactions and blocks, and a few others. The longest-connected
      remaining half are protected, including some onion peers. Of those that
      remain, the youngest member of the network group with the most
      connections is selected for disconnection. An attacker would have to be
      simultaneously better than honest peers at all of these characteristics
      to partition a node."
  a2link="https://bitcoincore.reviews/20477#l-83"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0] is a Release Candidate (RC)
  for the next major version of this full node implementation and its
  associated wallet and other software.  Jarol Rodriguez has written an
  [RC testing guide][] that describes the major changes in the release
  and suggests how you can help test them.

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta] is the latest release candidate
  for the next major version of this LN node.  It makes [anchor
  outputs][topic anchor outputs] the default for commitment transactions
  and adds support for them in its [watchtower][topic watchtowers]
  implementation, reducing costs and increasing safety.  The release
  also adds generic support for creating and signing [PSBTs][topic psbt]
  and includes several bug fixes.

{% comment %}<!--
- Bitcoin Core 0.20.2rc1 and 0.19.2rc1 are expected to be
  [available][bitcoincore.org/bin] sometime after the publication of
  this newsletter.  They contain several bug fixes, such as an
  improvement described in [Newsletter #110][news110 bcc19620] that will
  prevent them from redownloading future taproot transactions that they
  don't understand.
-->{% endcomment %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18077][] introduces support for a common automatic port
  forwarding protocol, [NAT-PMP][rfc 6886] (Network Address Translation Port
  Mapping Protocol).  A listening Bitcoin client started with the `-natpmp`
  configuration parameter will automatically open the listening port on NAT-PMP-enabled routers.
  NAT-PMP support is added in parallel to the existing UPnP (Universal Plug and Play) support
  which had been disabled by default in Bitcoin Core 0.11.1 after multiple
  security issues. In contrast to UPnP, NAT-PMP uses fixed-size UDP packets
  instead of XML parsing and is therefore considered [less risky][laanwj
  natpmp]. This change also transitively adds support for [PCP][rfc 6887] (Port
  Control Protocol), the backward-compatible successor to NAT-PMP.

- [Bitcoin Core #19055][] adds the [MuHash algorithm][] so that future PRs
  can use it for planned features.  As covered in
  [newsletter 123][muhash review club], MuHash is a rolling hash algorithm
  that can be used to calculate the hash digest of a set of objects and
  efficiently update it when items are added to or removed.  This is a revival
  of the idea of using MuHash to calculate a digest of the complete UTXO set
  first suggested by [Pieter Wuille in 2017][muhash mailing list]
  and implemented in [Bitcoin Core #10434][].  For those interested in
  tracking the progress of creating an index for UTXO set statistics, making
  it easier to verify [assumeUTXO][topic assumeutxo] archives, meta PR
  [Bitcoin Core #18000][] documents the project's progress and future steps.

- [C-Lightning #4320][] adds a `cltv` parameter to the `invoice` RPC so that
  users and plugins can set the resulting invoice's `min_final_cltv_expiry`
  field.

- [C-Lightning #4303][] updates `hsmtool` to take its passphrase on
  standard input (stdin) and begins ignoring any passphrase provided on
  the command line.

{% include references.md %}
{% include linkers/issues.md issues="18077,19055,4320,4303,6993,20477,18000,10434" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc5
[news63 bcc15759]: /en/newsletters/2019/09/11/#bitcoin-core-15759
[daftuar disabletx]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018340.html
[rfc 6886]: https://tools.ietf.org/html/rfc6886
[rfc 6887]: https://tools.ietf.org/html/rfc6887
[laanwj natpmp]: https://github.com/bitcoin/bitcoin/issues/11902#issue-282227529
[wuille bech32m post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018338.html
[bech32m bip]: https://github.com/sipa/bips/blob/bip-bech32m/bip-bech32m.mediawiki
[news83 podle]: /en/newsletters/2020/02/05/#podle
[zmn podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002476.html
[darosior sighash]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002475.html
[fournier podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-January/002929.html
[news45 bech32 upgrade]: /en/bech32-sending-support/#automatic-bech32-support-for-future-soft-forks
[rc testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/0.21-Release-Candidate-Testing-Guide
[muhash review club]: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club
[muhash mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash algorithm]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
