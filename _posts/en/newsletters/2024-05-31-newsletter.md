---
title: 'Bitcoin Optech Newsletter #305'
permalink: /en/newsletters/2024/05/31/
name: 2024-05-31-newsletter
slug: 2024-05-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed light client protocol for
silent payments, summarizes two new proposed descriptors for taproot,
and links to a discussion about whether opcodes with overlapping
features should be added in a soft fork.  Also included are our regular
sections with popular questions and answers from the Bitcoin Stack
Exchange, announcements of new releases and release candidates, and
summaries of notable changes to popular Bitcoin infrastructure software.

## News

- **Light client protocol for silent payments:** Setor Blagogee
  [posted][blagogee lcsp] to Delving Bitcoin to describe a draft
  specification for a protocol to help lightweight clients receive
  [silent payments][topic silent payments] (SPs).  The addition of a few
  cryptographic primitives is sufficient to give any wallet software the
  ability to send SPs, but receiving silent payments requires not only
  those primitives but also the ability to access information about
  every SP-compatible onchain transaction.  This is easy for full nodes,
  such as Bitcoin Core, that already process every onchain transaction,
  but it requires additional features for lightweight clients that
  typically try to minimize the amount of transaction data they request.

  The basic protocol has a service provider build a per-block index of
  the public keys that can be used with SPs.  Clients download that
  index and a [compact block filter][topic compact block filters] for the
  same block.  Clients compute their local tweak for each key (or set of
  keys) and determine if the block filter contains a payment to their
  corresponding tweaked key.  If it does, they download additional
  block-level data that allows them to learn how much they've received
  and how to later spend the payment.

- **Raw taproot descriptors:** Oghenovo Usiwoma [posted][usiwoma descriptors] to
  Delving Bitcoin about two new proposed [descriptors][topic
  descriptors] for constructing [taproot][topic taproot] spend
  conditions:

  - `rawnode(<hash>)` takes the hash of a merkle tree node, whether for an
    internal node or for leaf node.  This allows a wallet or other scanning
    program to find particular output scripts without knowing exactly
    what tapscripts they use.  This is not safe for receiving money in
    most situations---an unknown script might be either unspendable or
    allow a third party to spend funds---but there can be protocols
    where it is safe.

    Anthony Towns gives an [example][towns descriptors] where Alice
    wants Bob to be able to inherit her money; for her spending paths,
    she only gives Bob the raw node hashes; for his inheritance path,
    she gives him a templated descriptor (perhaps including a timelock
    that prevents him from spending until a period of time has past).
    This is safe for Bob because the money isn't his and it's good for
    Alice's privacy because she doesn't need to reveal any of her other
    spend conditions to Bob upfront (although Bob may learn them from
    Alice's onchain transactions).

  - `rawleaf(<script>,[version])` is similar to the existing `raw`
    descriptor for including scripts that can't be expressed using a
    templated descriptor.  Its main difference is that it includes the
    ability to indicate a different tapleaf version than the
    [tapscript][topic tapscript] default specified in [BIP342][].

  Usiwoma's post provides an example and links to previous discussion
  and a [refrence implementation][usiwoma poc] he has created.

- **Should overlapping soft fork proposals be considered mutually exclusive?**
  Pierre Rochard [asks][rochard exclusive] if proposed soft forks that
  can provide much of the same features at a similar cost should be
  considered mutually exclusive, or whether it would make sense to
  activate multiple proposals and let developers use whichever
  alternative they prefer.

  Anthony Towns [replies][towns exclusive] to multiple points, including
  suggesting that overlapping features by themselves are not a problem
  but features that aren't used because everyone prefers an alternative
  may produce several problems.  He suggests anyone who favors a
  particular proposal test using its features in pre-production software
  to get a feel for them, especially in comparison to alternative ways
  the feature can be added to Bitcoin.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.18.0-beta][] is the latest major release of this popular LN
  node implementation.  According to its [release notes][lnd rn],
  experimental support is added for _inbound routing fees_ (see
  [Newsletter #297][news297 inbound]), pathfinding for [blinded
  paths][topic rv routing] is now available, [watchtowers][topic
  watchtowers] now support [simple taproot channels][topic simple
  taproot channels], and sending encrypted debugging information is now
  streamlined (see [Newsletter #285][news285 encdebug]), with many other features also
  added and many bugs fixed.

- [Core Lightning 24.05rc2][] is a release candidate for the next major
  version of this popular LN node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #29612][] rpc: Optimize serialization and enhance metadata of dumptxoutset output
    
- [Bitcoin Core #27064][] system: use %LOCALAPPDATA% as default datadir on windows
    
- [Bitcoin Core #29873][] policy: restrict all TRUC (v3) transactions to 10kvB; Note: we previously discussed this, I'm sure there's a link in the recent v3 tx relay topic entries -harding

- [Bitcoin Core #30062][] net: add ASMap info in `getrawaddrman` RPC
    
- [Bitcoin Core #26606][] wallet: Implement independent BDB parser
    
- [BOLTs #1092][] clean up; I'm sure we've mentioned this at least once before -harding
    
{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-06-04 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29612,27064,29873,30062,26606,1092" %}
[lnd v0.18.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta
[blagogee lcsp]: https://delvingbitcoin.org/t/silent-payments-light-client-protocol/891/
[usiwoma descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/
[towns descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/6
[usiwoma poc]: https://github.com/Eunovo/bitcoin/tree/wip-tr-raw-nodes
[rochard exclusive]:  https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[towns exclusive]: https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.18.0.md
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news297 inbound]: /en/newsletters/2024/04/10/#lnd-6703
[news285 encdebug]: /en/newsletters/2024/01/17/#lnd-8188
