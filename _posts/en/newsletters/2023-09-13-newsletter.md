---
title: 'Bitcoin Optech Newsletter #268'
permalink: /en/newsletters/2023/09/13/
name: 2023-09-13-newsletter
slug: 2023-09-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to draft specifications related to taproot
assets and describes a summary of several alternative message protocols
for LN that can help enable the use of PTLCs.  Also included are our
regular sections with the summary of a Bitcoin Core PR Review Club
meeting, announcements of new software releases and release candidates,
and descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **Specifications for taproot assets:** Olaoluwa Osuntokun posted
  separately to the Bitcoin-Dev and Lightning-Dev mailing lists about
  the _Taproot Assets_ [client-side validation protocol][topic client-side
  validation].  To the Bitcoin-Dev mailing list, he [announced][osuntokun
  bips] seven draft BIPs---one more than in the initial announcement of
  the protocol, then under the name _Taro_ (see [Newsletter
  #195][news195 taro]).  To the Lightning-Dev mailing list, he
  [announced][osuntokun blip post] a [draft BLIP][osuntokun blip] for
  spending and receiving taproot assets using LN, with the protocol
  based on the experimental "simple taproot channels" feature planned to
  be released in LND 0.17.0-beta.

  Note that, despite its name, Taproot Assets is not part of the
  Bitcoin Protocol and does not change the consensus protocol in any
  way.  It uses existing capabilities to provide new features for
  users that opt-in to its client protocol.

  None of the specifications had received any discussion on the
  mailing list as of this writing. {% assign timestamp="1:10" %}

- **LN messaging changes for PTLCs:** as the first LN implementation
  with experimental support for channels using [P2TR][topic taproot]
  and [MuSig2][topic musig] is expected to be released soon, Greg
  Sanders [posted][sanders post] to the Lightning-Dev mailing list a
  [summary][sanders ptlc] of several different previously-discussed
  changes to LN messages to allow them to support sending payments with
  [PTLCs][topic ptlc] instead of [HTLCs][topic htlc].  For most
  approaches, the changes to messages do not seem large or invasive,
  but we note that most implementations will probably continue using one
  set of messages for handling legacy HTLC forwarding while also
  offering upgraded messages to support PTLC forwarding, creating two
  different paths that will need to be maintained concurrently until
  HTLCs are phased out.  If some implementations add experimental PTLCs
  support before the messages are standardized, then implementations
  might even be required to support three or more different protocols
  simultaneously, to the disadvantage of all.

  Sander's summary has not received any comments as of this writing. {% assign timestamp="53:22" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Transport abstraction][review club 28165] is a recently-merged PR by Pieter Wuille (sipa)
that introduces a _transport_ abstraction (interface class). Concrete
derivations of this class convert a (per-peer) connection's (already
serialized) send and receive messages to and from wire format. This
can be thought of as implementing a deeper level of serialization and
deserialization. These classes do not do the actual sending and receiving.

The PR derives two concrete classes from the `Transport` class,
`V1Transport` (what we have today) and `V2Transport` (encrypted on the
wire). This PR is part of the
[BIP324][topic v2 p2p transport]
_Version 2 P2P Encrypted Transport Protocol_ [project][v2 p2p tracking pr]. {% assign timestamp="28:31" %}

{% include functions/details-list.md
  q0="What is the distinction between [*net*][net] and
      [*net_processing*][net_processing]?"
  a0="*Net* is at the bottom of the networking stack and handles
       low-level communication between peers, while *net_processing*
       builds on top of the *net* layer and handles the processing
       and validation of messages from *net* layer."
  a0link="https://bitcoincore.reviews/28165#l-22"

  q1="More concretely, name examples of classes or functions that
      we'd associate with *net_processing*, and, in contrast,
      with *net*?"
  a1="*net_processing*: `PeerManager`, `ProcessMessage`.
      *net*: `CNode`, `ReceiveMsgBytes`, `CConnMan`."
  a1link="https://bitcoincore.reviews/28165#l-25"

  q2="Does BIP324 require changes to the *net* layer, the
      *net_processing* layer, or both? Does it affect policy
      or consensus?"
  a2="These changes are only at the *net* layer; they don't affect consensus."
  a2link="https://bitcoincore.reviews/28165#l-37"

  q3="What are examples of implementation bugs that could result in
      this PR being an (accidental) consensus change?"
  a3="A bug that restricts the maximum message size to less than
      4MB, which may cause the node to reject a block that other
      nodes consider valid; a bug in block
      deserialization that causes the node to reject a consensus-valid
      block."
  a3link="https://bitcoincore.reviews/28165#l-45"

  q4="`CNetMsgMaker` and `Transport` both “serialize” messages.
      What is the difference in what they do?"
  a4="`CNetMsgMaker` performs the serialization of data structures
      into bytes; `Transport` receives these bytes, adds
      (serializes) the header, and actually sends it."
  a4link="https://bitcoincore.reviews/28165#l-60"

  q5="In the process of turning an application object like a
      `CTransactionRef` (transaction) into bytes / network packets, what
      happens? Which data structures does it turn into in the process?"
  a5="`msgMaker.Make()` serializes the `CTransactionRef` message by
      calling `SerializeTransaction()`, then `PushMessage()` puts the
      serialized message into the `vSendMsg` queue, then `SocketSendData()`
      adds a header/checksum (after the changes from this PR) and asks the
      transport for the next packet to send, and finally calls `m_sock->Send()`."
  a5link="https://bitcoincore.reviews/28165#l-83"

  q6="How many bytes are sent over the wire for the `sendtxrcncl`message
      (taking that message, used in [Erlay][topic erlay], as a simple example)?"
  a6="36 bytes: 24 for the header (magic 4 bytes, command 12 bytes,
      message size 4 bytes, checksum 4 bytes), then 12 bytes for the
      payload (version 4 bytes, salt 8 bytes)."
  a6link="https://bitcoincore.reviews/28165#l-86"

  q7="After `PushMessage()` returns, have we sent the bytes corresponding
      to this message to the peer already (yes/no/maybe)? Why?"
  a7="All are possible. **Yes**: we (*net_processing*) don't have to do
      anything else to cause the message to be sent.
      **No**: it's extremely unlikely to have
      been received by the recipient by the time that function returns.
      **Maybe**: if all the queues are empty it will have made it to the
      kernel socket layer, but if some of the queues aren't, then it
      will still be waiting on those to drain further before getting
      to the OS."
  a7link="https://bitcoincore.reviews/28165#l-112"

  q8="Which threads access `CNode::vSendMsg`?"
  a8="`ThreadMessageHandler` if the message is sent synchronously
      (\"optimistically\"); `ThreadSocketHandler` if it gets queued
      and picked up and sent later."
  a8link="https://bitcoincore.reviews/28165#l-120"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.17.0-beta.rc2][] is a release candidate for the next major
  version of this popular LN node implementation.  A major new
  experimental feature planned for this release, which could likely
  benefit from testing, is support for "simple taproot channels". {% assign timestamp="1:18:22" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26567][] updates the wallet to estimate the weight of a
  signed input from the [descriptor][topic descriptors] instead of doing a signing dry-run.
  This approach will succeed even for more complex [miniscript][topic miniscript]
  descriptors, where the dry-run approach was insufficient. {% assign timestamp="1:20:52" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="26567" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[net]: https://github.com/bitcoin/bitcoin/blob/master/src/net.h
[net_processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.h
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[osuntokun bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021938.html
[osuntokun blip post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004089.html
[osuntokun blip]: https://github.com/lightning/blips/pull/29
[review club 28165]: https://bitcoincore.reviews/28165
[sanders post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004088.html
[sanders ptlc]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[v2 p2p tracking pr]: https://github.com/bitcoin/bitcoin/issues/27634
