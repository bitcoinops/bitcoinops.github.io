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
  and how to later spend the payment. {% assign timestamp="1:52" %}

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
  and a [reference implementation][usiwoma poc] he has created. {% assign timestamp="14:56" %}

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
  the feature can be added to Bitcoin. {% assign timestamp="28:02" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What's the smallest possible coinbase transaction / block size?]({{bse}}122951)
  Antoine Poinsot explains minimum restrictions around the coinbase transaction
  and concludes the smallest possible valid Bitcoin block at current block heights is 145 bytes. {% assign timestamp="1:13:32" %}

- [Understanding Script's number encoding, CScriptNum]({{bse}}122939)
  Antoine Poinsot describes how CScriptNum represents integers in Bitcoin's
  Script, provides some example encodings, and links to two serialization
  implementations. {% assign timestamp="1:14:18" %}

- [Is there a way to make a BTC wallet address public but hide how many BTC it contains?]({{bse}}122786)
  Vojtěch Strnad points out that [silent payment][topic silent payments] reusable
  payment addresses allow a public payment identifier to be posted without
  observers being able to associate transactions paying to it. {% assign timestamp="1:16:04" %}

- [Testing increased feerates in regtest]({{bse}}122837)
  In regtest, Ava Chow recommends using Bitcoin Core's test framework and
  setting `-maxmempool` to a low value and `-datacarriersize` to a high value in
  order to help simulate high feerate environments. {% assign timestamp="1:18:05" %}

- [Why is my P2P_V2 peer connected over a v1 connection?]({{bse}}122774)
  Pieter Wuille hypothesizes that outdated peer addr information was what caused
  a user to see a peer that supported BIP324 [encrypted transport][topic v2 p2p
  transport] that was connected with a v1 non-encrypted connection. {% assign timestamp="1:20:41" %}

- [Does a P2PKH transaction send to the hash of the uncompressed key or the compressed key?]({{bse}}122875)
  Pieter Wuille notes that both compressed and uncompressed public keys can be
  used resulting in distinct P2PKH addresses, adding that P2WPKH only allows
  compressed public keys by policy and P2TR uses [x-only public keys][topic
  X-only public keys]. {% assign timestamp="1:21:58" %}

- [What are different ways to broadcast a block to the Bitcoin network?]({{bse}}122953)
  Pieter Wuille outlines 4 ways to announce blocks on the P2P network: using
  [BIP130][], using [BIP152][], sending [unsolicited `block` messages][], and the older
  `inv` / `getdata` / `block` message flow. {% assign timestamp="1:23:20" %}

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
  added and many bugs fixed. {% assign timestamp="43:23" %}

- [Core Lightning 24.05rc2][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="1:12:21" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #29612][] updates the serialization format of the UTXO set dump
  output through the `dumptxoutset` RPC. This results in a 17.4% space
  optimization. The `loadtxoutset` RPC now expects the new format when loading
  the UTXO set dump file; the old format is no longer supported. See Newsletters
  [#178][news178 txoutset] and [#72][news72 txoutset] for previous references to
  `dumptxoutset`. {% assign timestamp="1:27:11" %}

- [Bitcoin Core #27064][] changes the default data directory on Windows from
  `C:\Users\Username\AppData\Roaming\Bitcoin` to
  `C:\Users\Username\AppData\Local\Bitcoin` on fresh installs only. {% assign timestamp="1:29:59" %}

- [Bitcoin Core #29873][] introduces a 10 kvB data weight limit for
  [Topologically Restricted Until Confirmation (TRUC)][topic v3 transaction
  relay] transactions (v3 transactions) to reduce the potential cost of mitigation against
  [transaction pinning][topic transaction pinning] attacks, improve block template
  construction efficiency, and impose tighter memory limits on certain data
  structures. V3 transactions are a subset of standard transactions with
  additional rules designed to allow transaction replacement while minimizing
  the cost of overcoming transaction-pinning attacks.  See Newsletter
  [#289][news289 v3] and [#296][news296 v3] for more on v3 transactions. {% assign timestamp="1:30:55" %}

- [Bitcoin Core #30062][] adds two new fields, `mapped_as` and
  `source_mapped_as`, to the `getrawaddrman` RPC, a command that returns
  information about the network addresses of peer nodes. The new fields return
  the Autonomous System Number (ASN) mapped to the peer and its source, to
  provide approximate information about which ISPs control which IP addresses
  and increase Bitcoin Core's resistance to [eclipse attacks][topic eclipse
  attacks]. See Newsletter [#52][news52 asmap], [#83][news83 asmap],
  [#101][news101 asmap], [#290][news290 asmap]. {% assign timestamp="1:34:15" %}

- [Bitcoin Core #26606][] introduces `BerkeleyRODatabase`, an independent
  implementation of a Berkeley Database (BDB) file parser that provides
  read-only access to BDB files. Legacy wallet data can now be extracted without
  the need for the heavy BDB library, to ease the migration to
  [descriptor][topic descriptors] wallets. The `wallettool`'s `dump` command is
  changed to use `BerkeleyRODatabase`. {% assign timestamp="1:38:17" %}

- [BOLTs #1092][] cleans up the Lightning Network (LN) specification by removing
  the unused and no longer supported features `initial_routing_sync` and
  `option_anchor_outputs`. Three features are now assumed to be present in all
  nodes: `var_onion_optin` for variable-sized [onion messages][topic onion
  messages] to relay arbitrary data to specific hops, `option_data_loss_protect`
  for nodes to send information about their latest channel state when they
  reconnect, and `option_static_remotekey` to allow a node to request that every
  channel update commit to sending the node's non-[HTLC][topic htlc] funds to
  the same address. The `gossip_queries` feature for specific gossip requests is
  changed so that a node that doesn't support it won't be queried by other
  nodes. See Newsletter [#259][news259 cleanup]. {% assign timestamp="1:41:41" %}

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
[unsolicited `block` messages]: https://developer.bitcoin.org/devguide/p2p_network.html#block-broadcasting
[news72 txoutset]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news178 txoutset]: /en/newsletters/2021/12/08/#bitcoin-core-23155
[news289 v3]: /en/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /en/newsletters/2024/04/03/#bitcoin-core-29242
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[news101 asmap]: /en/newsletters/2020/06/10/#bitcoin-core-0-20-0
[news290 asmap]: /en/newsletters/2024/02/21/#improved-reproducible-asmap-creation-process
[news259 cleanup]: /en/newsletters/2023/07/12/#ln-specification-clean-up-proposed
