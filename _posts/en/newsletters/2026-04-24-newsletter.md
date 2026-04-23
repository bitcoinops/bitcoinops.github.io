---
title: 'Bitcoin Optech Newsletter #402'
permalink: /en/newsletters/2026/04/24/
name: 2026-04-24-newsletter
slug: 2026-04-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes Hornet Node's work on a declarative executable
specification of consensus rules and summarizes a discussion about onion message
jamming in the Lightning Network. Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange, announcements of
new releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Hornet Node's declarative executable specification of Bitcoin consensus rules**:
  Toby Sharp [posted][topic hornet update] to Delving Bitcoin and the Bitcoin-Dev [mailing
  list][hornet ml post] an update on the Hornet node project. Sharp had
  [previously][topic hornet] described a new node implementation Hornet that
  reduced initial block download times from 167 minutes down to 15 minutes. In
  this update, he reports completing a declarative specification of non-script
  block validation rules, consisting of 34 semantic invariants composed using a
  simple algebra.

  Sharp also outlines future work, including extending the specification to
  script validation, and discusses potential comparisons with other
  implementations such as libbitcoin in response to feedback from Eric Voskuil.

- **Onion message jamming in the Lightning Network**: Erick Cestari [posted][onion del] to
  Delving Bitcoin about the [onion message][topic onion messages] jamming problem affecting
  the Lightning Network. BOLT4 acknowledges onion messages to be unreliable, recommending
  to apply rate limiting techniques. According to Cestari, these techniques are what makes message jamming possible. Attackers
  may spin up malicious nodes and flood the network with spam messages triggering rate limits
  of peers, forcing them to drop legitimate messages. Moreover, BOLT4 does not enforce a
  maximum message length, allowing attackers to maximize the reach of a single message.

  Cestari reviewed several mitigations to onion message jamming and provided a
  comprehensive overview of the techniques he deemed more suitable:

  - *Upfront fees*: This technique was first proposed by Carla Kirk-Cohen in [BOLTs #1052][]
    as a solution for channel jamming, but can be easily extended. Nodes would advertise a per-message
    flat fee, to be included in the onion payload and deducted at each hop. In case the fee is not
    paid, the message would be just dropped by the node. This method presents some limitations, such
    as being able to only forward messages to channel peers and increased p2p overhead.

  - *Hop limit and proof-of-stake based on channel balances*: This technique was [proposed][mitig2 onion]
    by Bashiri and Khabbazian at the University of Alberta and has two different components:

    - Leashing hop count: Either setting a hard-cap on the maximum number of hops that a message could do
      (e.g. 3 hops), or having the sender solve a proof-of-work puzzle, whose difficulty increases
      exponentially with the number of hops.

    - Proof-of-stake forwarding rule: Each node sets per-peer rate limits according to the peer's aggregate
      channel balance, granting well-funded nodes more forwarding power.

    The trade-offs of this approach are related to centralization pressure, due to larger nodes being at
    an advantage, while the 3-hops hard-cap could reduce anonymity set.

  - *Bandwidth metered payment*: [Proposed][mitig3 onion] by Olaoluwa Osuntokun, this technique is
    similar in scope as upfront fees, but adds per-session state and settles through
    [AMP payments][topic amp]. A sender would first send the AMP payment, dropping fees
    at each intermediate step and delivering an ID for the session. The sender would then include the
    ID in the onion message. Known limitations of the approach are related to the ability to only forward
    messages to channel peers and the possibility to link all the messages belonging to the same session.

  - *Backpropagation-based rate limiting*: This approach, [proposed][mitig4 onion] by Bastien Teinturier,
    uses a backpressure mechanism that is statistically able to trace back spam to its source.
    When the per-peer rate limiting is hit, the node sends a drop message back to the sender, which in turn
    relays it to the last peer that forwarded the original message halving its rate limit. While the correct
    sender is statistically identified, the wrong peer could be penalized. Moreover, an attacker could fake
    the drop message, lowering rate limits of honest nodes.

  Finally, Cestari invited LN developers to join the discussion, stating that a window is still available to
  mitigate the issue before prolonged DDoS attacks hit the network, as [happened to Tor][tor issue] recently.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why did BIP342 replace CHECKMULTISIG with a new opcode, instead of just removing FindAndDelete from it?]({{bse}}130665)
  Pieter Wuille explains that the replacement of `OP_CHECKMULTISIG` with
  `OP_CHECKSIGADD` in [tapscript][topic tapscript] was necessary to enable batch
  verification of [schnorr][topic schnorr signatures] signatures (see
  [Newsletter #46][news46 batch]) in a potential future protocol change.

- [Does SIGHASH_ANYPREVOUT commit to the tapleaf hash or the full taproot merkle path?]({{bse}}130637)
  Antoine Poinsot confirms that [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
  signatures currently commit only to the tapleaf hash, not the full merkle path
  in the [taproot][topic taproot] tree. However, this design is under discussion
  as one BIP co-author has suggested committing to the full merkle path instead.

- [What does the BIP86 tweak guarantee in a MuSig2 Lightning channel, beyond address format?]({{bse}}130652)
  Ava Chow points out that the tweak prevents the use of hidden script paths
  because [MuSig2's][topic musig] signing protocol requires all participants to
  apply the same [BIP86][] tweak for signature aggregation to succeed. If one
  party attempts to use a different tweak, such as one derived from a hidden
  script tree, their partial signature won't aggregate into a valid final
  signature.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 31.0][] is the latest major version release of the network’s
  predominant full node implementation. The [release notes][notes31] describe
  several significant improvements, including the implementation of the [cluster
  mempool][topic cluster mempool] design, a new `-privatebroadcast` option for
  `sendrawtransaction` (see [Newsletter #388][news388 private]), `asmap` data
  optionally embedded into the binary for [eclipse attack][topic eclipse
  attacks] protection, and an increase in the default `-dbcache` to 1024 MiB on
  systems with at least 4096 MiB of RAM, among many other updates.

- [Core Lightning 26.04][] is a major release of this popular LN node
  implementation. It enables [splicing][topic splicing] by default, adds new
  `splicein` and `spliceout` commands including a `cross-splice` mode that
  targets a second channel as the destination of a splice-out, redesigns
  `bkpr-report` for income summaries, adds parallel pathfinding and multiple bug
  fixes in `askrene`, adds a `fronting_nodes` option on the `offer` RPC and a
  `payment-fronting-node` config, and removes support for the legacy onion
  format. See the [release notes][notes cln] for additional details.

- [LND 0.21.0-beta.rc1][] is the first release candidate for the next major
  version of this popular LN node. Users running nodes with the
  `--db.use-native-sql` flag against an SQLite or PostgreSQL backend should note that
  this version migrates the payment store from the key-value (KV) format to
  native SQL, with an opt-out via `--db.skip-native-sql-migration`. See the
  [release notes][notes lnd].

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33477][] updates how the `dumptxoutset` RPC’s `rollback` mode
  (see [Newsletter #72][news72 dump]) builds historical UTXO set dumps used for
  [assumeUTXO][topic assumeutxo] snapshots. Instead of rolling back the main
  chainstate by invalidating blocks, Bitcoin Core creates a temporary UTXO
  database, rolls it back to the requested height, and writes the snapshot from
  the temporary database. This preserves the main chainstate, eliminating the
  need to suspend network activity and the risk of fork-related interference
  with the rollback, at the cost of additional temporary disk space and slower
  dumps. A new `in_memory` option keeps the temporary UTXO database entirely in
  RAM, enabling faster rollbacks but requiring over 10 GB of free memory on
  mainnet. For deep rollbacks, it is recommended to use no RPC timeout (`bitcoin-cli
  -rpcclienttimeout=0`) as it may take several minutes.

- [Bitcoin Core #35006][] adds a `-rpcid` option to `bitcoin-cli` to set a
  custom string as the JSON-RPC request `id` instead of the default hardcoded
  value of `1`. This allows requests and responses to be correlated when
  multiple clients make concurrent calls. The identifier is also included in the
  server-side RPC debug log.

- [BIPs #1895][] publishes [BIP361][], an abstract proposal for
  [post-quantum][topic quantum resistance] migration and legacy signature
  sunset. Assuming a separate post-quantum (PQ) signature scheme is standardized
  and deployed, it outlines a phased migration away from ECDSA/[schnorr][topic
  schnorr signatures] signature schemes. The current version of the proposal is
  divided into two phases. Phase A prohibits sending funds to quantum-vulnerable
  addresses, thereby accelerating the adoption of PQ address types. Phase B
  restricts ECDSA/schnorr spending and includes a quantum-safe rescue protocol
  to prevent theft of quantum-vulnerable UTXOs.

- [BIPs #2142][] updates [BIP352][], the [silent payments][topic silent
  payments] BIP proposal, by adding a send/receive test vector for an edge case
  where the running sum of input keys hits zero after two inputs but the final
  sum over all inputs is non-zero. This catches implementations that reject
  early during incremental summation instead of summing all inputs first.

- [LDK #4555][] fixes how forwarding nodes enforce [`max_cltv_expiry`][topic
  cltv expiry delta] for [blinded payment paths][topic rv routing]. The field is
  meant to ensure an expired blinded route is rejected at the introduction hop
  rather than being forwarded through the blinded segment and failing closer to
  the receiver. Previously, LDK compared the constraint against the hop's
  outgoing CLTV value; it now checks the inbound CLTV expiry as intended.

- [LND #10713][] adds per-peer and global token-bucket rate limits for incoming
  [onion messages][topic onion messages], dropping excess traffic at ingress
  before it reaches the onion handler. This hardens LND's recently added onion
  message forwarding support (see [Newsletter #396][news396 lnd onion]) against
  high-volume abuse from fast peers. The per-peer and global split mirrors LND's
  earlier gossip bandwidth limits (see [Newsletter #370][news370 lnd gossip]).

- [LND #10754][] stops forwarding an [onion message][topic onion messages] when
  the chosen next hop is the same peer that delivered it, avoiding an immediate
  bounce on the same connection.

{% include snippets/recap-ad.md when="2026-04-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1052,33477,35006,4555,10713,10754,1895,2142" %}
[news46 batch]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
[topic hornet update]: https://delvingbitcoin.org/t/hornet-update-a-declarative-executable-specification-of-consensus-rules/2420
[hornet ml post]: https://groups.google.com/g/bitcoindev/c/M7jyQzHr2g4
[topic hornet]: /en/newsletters/2026/02/06/#a-constant-time-parallelized-utxo-database
[onion del]: https://delvingbitcoin.org/t/onion-message-jamming-in-the-lightning-network/2414
[mitig2 onion]: https://ualberta.scholaris.ca/items/245a6a68-e1a6-481d-b219-ba8d0e640b5d
[mitig3 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-February/003498.txt
[mitig4 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-June/003623.txt
[tor issue]: https://blog.torproject.org/tor-network-ddos-attack/
[Bitcoin Core 31.0]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[notes31]: https://bitcoincore.org/en/releases/31.0/
[news388 private]: /en/newsletters/2026/01/16/#bitcoin-core-29415
[Core Lightning 26.04]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[notes cln]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[LND 0.21.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta.rc1
[notes lnd]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.21.0.md
[news72 dump]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news396 lnd onion]: /en/newsletters/2026/03/13/#lnd-10089
[news370 lnd gossip]: /en/newsletters/2025/09/05/#lnd-10103
