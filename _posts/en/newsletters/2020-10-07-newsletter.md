---
title: 'Bitcoin Optech Newsletter #118'
permalink: /en/newsletters/2020/10/07/
name: 2020-10-07-newsletter
slug: 2020-10-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a revised proposal for a generic
message signing protocol.  Also included are our
regular sections describing releases, release candidates, and notable
changes to popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Alternative to BIP322 generic signmessage:** the existing [BIP322][]
  proposes a [generic message signing protocol][topic generic
  signmessage] for Bitcoin that would allow signing messages for any
  Bitcoin address (script) even if it used multisig or advanced
  features.  This includes the ability to sign for all types of bech32
  addresses, a feature that has not yet been standardized even several years
  after the introduction of that type of address and its subsequent
  widespread adoption (see [Newsletter #54][news54 bech32 signing]).

    This week, BIP322 author Karl-Johan Alm [posted][alm signmessage] to
    the Bitcoin-Dev mailing list an alternative proposal for message
    signing that would use a technique called virtual transactions.  The
    first virtual transaction would be deliberately invalid by
    attempting to spend from a non-existent previous transaction (one
    whose txid is all zeroes).  This first transaction pays the address
    (script) the user wants to sign for and contains a hash commitment
    to the desired message.  A second transaction spends the output of
    the first transaction---if the signatures and other data for that
    spend could be a valid transaction, then the message is considered
    signed (although the second virtual transaction still can't be
    included onchain because it spends from an invalid previous
    transaction).

    The advantage of using virtual transactions, which were also adopted
    in the [BIP325][] specification for [signet][topic signet] (see
    [Newsletter #109][news109 signet bip]), is that they may work with
    existing software that's configured to sign arbitrary transactions,
    including those in [PSBT][topic psbt] format.  The revised
    specification also allows one of the virtual transactions to contain inputs
    that reference specific UTXOs, allowing users to (arguably) prove
    control over those funds, similar to [BIP127][] proof of reserves.

    Alm is seeking feedback on the alternative proposal, including
    whether or not it should replace BIP322 or be opened as a separate
    BIP.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.11.1-beta][lnd 0.11.1-beta] is the release for a new minor
  version.  Its release notes summarize the changes as "a number of
  reliability improvements, some macaroon [authentication token]
  upgrades, and a change to make our version of [anchor
  commitments][topic anchor outputs] spec compliant."

- [HWI 1.2.0-rc.1][HWI 1.2.0] is a release candidate that adds support
  for a new hardware device and contains multiple bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19898][] log: print unexpected version warning in validation log category FIXME:jonatack

- [Bitcoin Core #15367][] adds a `-startupnotify` configuration parameter that accepts
  a shell command to be executed after Bitcoin Core has finished its
  initialization and is ready to handle enabled interfaces (ZMQ,
  REST, JSON-RPC, etc). This can be used to directly start programs/daemons
  dependent on Bitcoin Core's interfaces, or to notify init systems (e.g.
  systemd) that dependent programs/daemons can be safely started.

- [Bitcoin Core #19723][] changes the way unknown P2P protocol messages
  are handled.  Previously the node penalized peers who sent unknown
  messages at any time; now the node ignores unknown messages during the
  brief window between when the remote peer establishes a new connection
  by sending a `version` message and when the remote node acknowledges
  receipt of the local peer's version with a `verack` message.  Peers
  who send unknown messages at any other time will still be penalized.

    By ignoring messages before `verack`, the local node makes it safe
    for a peer to send special messages identifying any features it
    supports.  If the node recognizes any special messages, it can
    enable its support for the corresponding features; otherwise, it can
    just ignore the message.  See [Newsletter #111][news111 pre-verack]
    for previous discussion about this proposed method for protocol
    feature negotiation.

- [Bitcoin Core #19725][] updates the `getpeerinfo` RPC.  Its results
  now return a new `connection_type` field that indicates the
  reason the node either opened that connection to an outbound peer or
  accepted an inbound connection from the peer.  The existing `addnode`
  field in the RPC output is deprecated (not returned by default);
  connections manually requested by the user now show up as
  `connection_type: manual`.

- [Bitcoin Core #18309][] allows each [ZeroMQ configuration parameter][zmq.md] to
  be specified multiple times.  If the same parameter is specified more
  than once, each listed IP address and port will receive notifications.
  Previously, only the first provided address/port would receive a
  notification.

- [Bitcoin Core #19501][] updates the `sendtoaddress` and `sendmany`
  RPCs with a new optional `verbose` parameter that returns what
  mechanism was used to select the transaction's feerate---such as
  whether the user manually selected the feerate, an appropriate feerate
  was automatically selected, or the configured fallback feerate was used.

- [Bitcoin Core #20003][] results in the program immediately exiting
  if the `-proxy` configuration parameter is specified without
  arguments.  Previously, the program would start without a proxy, which
  could lead to the user thinking they were using a proxy (e.g. for
  privacy) when they really weren't.

- [Bitcoin Core #19991][] makes it possible to track incoming
  connections to a local Tor onion service separately from other
  connections made by services or proxies run on the same computer.
  This is done by having Bitcoin Core listen on an additional port
  (8334), only on localhost, and associate any connections to that port
  with Tor.  The Tor listening port may be changed using the existing
  `-bind` configuration parameter and its new `=tor` flag.  This PR
  doesn't do anything special with the ability to identify which
  connections came from Tor (or those that are now more likely to have
  come from a local service), leaving that to future PRs.  Tor onion
  service operators who upgrade to this new code may want to update their
  settings as described in the [updated documentation][bcc19991 tor.md].

- [Eclair #1528][] allows plugins (see [Newsletter #43][news43
  eclair plugins]) to register new features and message types.  The
  features will be advertised to peers and potential peers, and any
  messages using registered message types will be routed to the appropriate
  plugin.  Plugins may now also send messages with arbitrary message types.

- [Eclair #1539][] implements a simple measure to try to prevent channel
  jamming attacks.  When a node has two or more open channels to the
  same peer and it receives a payment to that peer,
  it now routes the payment by whichever channel has the least
  amount of remaining bitcoin value.  This means attackers will end up
  jamming low-value channels before high-value channels.  This doesn't
  eliminate the attack, but it does mean an attacker will need more
  open channels in order to jam some high-value channels.  This PR
  shared discussion with [LND #4646][], which implements the
  same feature in LND.

- [Eclair #1540][] adds a configuration parameter for setting the name
  of the Bitcoin Core wallet to use.  If not set, Eclair will use
  Bitcoin Core's default wallet.  The [configuration documentation][eclair
  readme] warns that the wallet must not be changed while there are
  open channels.

- [LND #4389][] adds a new `psbt` wallet subcommand that allows users to
  create and sign [PSBTs][topic psbt].  This extends LND's previous
  PSBT support that was focused on allowing other wallets to fund a
  channel open (see [Newsletter #92][news92 lnd psbt]).  For details
  about the new `psbt` subcommand and examples of it in use, see LND's
  [updated documentation][lnd psbt.md].

{% include references.md %}
{% include linkers/issues.md issues="19898,15367,19723,19725,18309,19501,20003,19991,1528,1539,1540,4389,19953,18947,4646" %}
[lnd 0.11.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.1-beta
[hwi 1.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/1.2.0-rc.1
[news43 eclair plugins]: /en/newsletters/2019/04/23/#eclair-927
[bcc19991 tor.md]: https://github.com/bitcoin/bitcoin/blob/96571b3d4cb4cda0fd3d5a457ae4a12f615de82b/doc/tor.md
[eclair readme]: https://github.com/ACINQ/eclair/blob/2073537c310a6e23134eda8b8a7670a367091381/README.md#configure-bitcoin-core-wallet
[lnd psbt.md]: https://github.com/guggero/lnd/blob/84dfed3fe2d28ceda343944874ab47fb57b73515/docs/psbt.md
[news54 bech32 signing]: /en/bech32-sending-support/#message-signing-support
[news109 signet bip]: /en/newsletters/2020/08/05/#bips-947
[news111 pre-verack]: /en/newsletters/2020/08/19/#proposed-bip-for-p2p-protocol-feature-negotiation
[alm signmessage]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018218.html
[news92 lnd psbt]: /en/newsletters/2020/04/08/#lnd-4079
[zmq.md]: https://github.com/bitcoin/bitcoin/blob/master/doc/zmq.md
