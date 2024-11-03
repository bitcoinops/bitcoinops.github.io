---
title: 'Bitcoin Optech Newsletter #290'
permalink: /en/newsletters/2024/02/21/
name: 2024-02-21-newsletter
slug: 2024-02-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for providing DNS-based
human-readable Bitcoin payment instructions, summarizes a post with
thoughts about mempool incentive compatibility, links to a thread
discussing the design of Cashu and other ecash systems, briefly looks at
continuing discussion about 64-bit arithmetic in Bitcoin scripts
(including a specification for a previously proposed opcode), and gives
an overview of an improved reproducible ASMap creation process.  Also
included are our regular sections describing updates to clients and
services, new releases and release candidates, and notable changes to
popular Bitcoin infrastructure software.

## News

- **DNS-based human-readable Bitcoin payment instructions:** following
  previous discussions (see [Newsletter #278][news278 dns]),  Matt
  Corallo [posted][corallo dns] to Delving Bitcoin a [draft BIP][dns
  bip] that will allow a string like `example@example.com` to resolve to
  DNS address such as `example.user._bitcoin-payment.example.com`, which
  will return a [DNSSEC][]-signed TXT record containing a [BIP21][] URI
  such as `bitcoin:bc1qexampleaddress0123456`.  BIP21 URIs can be
  extended to support multiple protocols (see the [BIP70 payment
  protocol][topic bip70 payment protocol]); for example, the following
  TXT record could indicate a [bech32m][topic bech32] address to use as
  a fallback by simple onchain wallets, a [silent payment][topic silent
  payments] address to use by onchain wallets that support that
  protocol, and an LN [offer][topic offers] to use by LN-enabled
  wallets:

  ```text
  bitcoin:bc1qexampleaddress0123456?sp=sp1qexampleaddressforsilentpayments0123456&b12=lno1qexampleblindedpathforanoffer...
  ```

  The specifics of the different supported payment protocols are not
  defined in the draft BIP.  Corallo has two other drafts, one a
  [BOLT][dns bolt] and one a [BLIP][dns BLIP] for describing details
  relevant for LN nodes.  The BOLT allows a domain owner to set a wildcard
  record such as `*.user._bitcoin-payment.example.com` that will resolve
  to a BIP21 URI containing the parameter of `omlookup` ([onion
  message][topic onion messages] lookup) and a [blinded path][topic
  rv routing] to a particular LN node.  A spender wanting to make an
  offer to `example@example.com` will then pass the receiver part
  (`example`) to that LN node to allow a multiuser node to correctly
  handle the payment.  The BLIP describes an option for allowing any LN
  node to securely resolve payment instructions for any other node over
  the LN communication protocol.

  At the time of writing, most discussion about the proposal could be
  found on the [PR to the BIPs repository][bips #1551].  One suggestion
  was to use an HTTPS solution which might be more accessible to many
  web developers but would require additional dependencies; Corallo said
  he will not change this part of the specification, but he did write a
  [small library][dnssec-prover] with a [demo website][dns demo] that
  does all the work for web developers.  Another suggestion was to use
  the existing [OpenAlias][] DNS-based payment address resolution system
  that is already supported by some Bitcoin software, such as Electrum.
  A third significantly discussed topic was how addresses should be
  displayed, e.g. `example@example.com`, `@example@example.com`,
  `example$example.com`, etc. {% assign timestamp="1:41" %}

- **Thinking about mempool incentive compatibility:** Suhas Daftuar
  [posted][daftuar incentive] to Delving Bitcoin several insights into
  the criteria full nodes can use to select which transactions to accept
  into their mempools, relay to other nodes, and mine for maximal
  revenue.  The post starts from first principles and proceeds to the
  cutting edge of current research with approachable descriptions that
  should be accessible to anyone interested in the design of Bitcoin
  Core's transaction relay policy.  Some of the insights we found most
  interesting included:

  - *Pure replace by feerate doesn't guarantee incentive compatibility:*
    it seems like [replacing][topic rbf] a transaction paying a lower
    feerate with a transaction paying a higher feerate ought to be a
    strict win for miners.  Daftuar provides a simple [illustrated
    example][daftuar feerate rule] of why that's not always the case.
    For previous discussion of pure replace by feerate, see [Newsletter
    #288][news288 rbfr].

  - *Miners with different hashrates have different priorities:* a miner
    with 1% of total network hashrate who forgoes including a particular
    transaction in their block templates and manages to find the next
    block will only have a 1% chance of mining an immediate successor
    block that could include that transaction.  This strongly
    encourages the small miner to collect as much fee as it can now,
    even if that means it significantly reduces the amount of fee
    available to miners of future blocks (including itself,
    potentially).

    By comparison, a miner with 25% of total network hashrate who
    forgoes including a transaction in the next block will have a 25%
    chance of mining an immediate successor block that could include
    that transaction.  This large miner is incentivized to avoid
    collecting some fees now if doing so is likely to significantly
    increase the available fees in the future.

    Daftuar gives an [example][daftuar incompatible] of two
    conflicting transactions.  The smaller transaction pays a higher
    feerate; the larger transaction pays more absolute fees.  If there
    aren't many transactions in the mempool near the feerate of the
    larger transaction, a block containing it would pay its miner more
    fees than a block containing the smaller (higher feerate)
    transaction.  However, if there are many transactions in the
    mempool with similar feerates to the large transaction, a miner
    with a small share of total network hashrate might be motivated to
    mine the smaller (higher feerate) version to get as much fee
    now---but a miner with a larger share of total hashrate might be
    motivated to wait until it's profitable to mine the larger (lower
    feerate) version (or until the spender becomes even more tired of
    waiting and creates an even higher feerate version).  The
    differing incentives of different miners may imply there's no
    universal policy for incentive compatibility.

  - *Finding incentive-compatible behaviors that can't resist DoS attacks would be useful:*
    Daftuar describes how the Bitcoin Core
    project tries to [implement][mempool series] policy rules that are
    both incentive compatible and resistant to denial-of-service (DoS)
    attacks.  However, he notes "an interesting and valuable area of
    research would be to determine if there are incentive-compatible
    behaviors that would not be DoS-resistant to deploy on the entire
    network (and characterize them, if they exist). If so, such
    behaviors could introduce an incentive for users to connect directly
    to miners, which might be mutually beneficial to those parties but
    harmful to the decentralization of mining on the network overall.
    [...] Understanding those scenarios may also be helpful to us as we
    try to design incentive-compatible protocols that are DoS-resistant,
    so that we know where the boundaries are of what is possible." {% assign timestamp="9:50" %}

- **Cashu and other ecash system design discussion:** several weeks ago, developer
  Thunderbiscuit [posted][thunderbiscuit ecash] to Delving Bitcoin a
  description of the [blind signature scheme][] behind the [Chaumian
  ecash][] system used in [Cashu][], which denominates balances in
  satoshis and allows sending and receiving money using Bitcoin and LN.
  Developers Moonsettler and Zmnscpxj replied this week to talk about
  some of the constraints of the simple version of blind signing and
  how alternative protocols might be able to provide additional
  benefits.  The discussion was entirely theoretical but we think it
  could be interesting to anyone curious about ecash-style systems. {% assign timestamp="29:15" %}

- **Continued discussion about 64-bit arithmetic and `OP_INOUT_AMOUNT` opcode:**
  several developers have [continued discussing][64bit discuss] a
  potential future soft fork that could add 64-bit arithmetic operations
  to Bitcoin (see [Newsletter #285][news285 64bit]).  Most discussion
  since our earlier mention has continued to focus on how to encode
  64-bit values in scripts, with the main difference being whether
  to use a format that minimizes onchain data or a format that's
  simplest to operate on programmatically.  Also discussed was whether to
  use signed integers or only allow unsigned integers (for those who
  don't know, which seems to include a self-proclaimed advanced Bitcoin
  innovator, signed integers indicate what _sign_ they use (positive
  sign or negative sign); unsigned integers only allow expressing zero
  and positive numbers).  Additionally considered was whether to allow
  operating on larger numbers, potentially up to 4,160 bits (which
  matches the current Bitcoin stack element size limit of 520 bytes).

  This week, Chris Stewart created a new [discussion thread][stewart
  inout] for a [draft BIP][bip inout] for an opcode originally proposed as part
  of `OP_TAPLEAF_UPDATE_VERIFY` (see [Newsletter #166][news166 tluv]).
  The opcode, `OP_INOUT_AMOUNT` pushes to the stack the value of the
  current input (which is the value of the output it is spending) and
  the value of output in the transaction that has the same index as
  this input.  For example, if the transaction's first input is worth
  4 million sats, the second input is 3 million sats, the first output
  pays 2 million sats, and the second output pays 1 million sats, then
  an `OP_INOUT_AMOUNT` executed as part of evaluating the second input
  would put on the stack `3_000_000 1_000_000` (encoded, if we
  understand the draft BIP correctly, as a 64-bit little-endian
  unsigned integer, e.g. `0xc0c62d0000000000 0x40420f0000000000`).  If
  the opcode were added to Bitcoin in a soft fork, it would make it
  much easier for contracts to verify that the input and output
  amounts were within the range expected by the contract, e.g. that a
  user only withdrew from a [joinpool][topic joinpools] the amount to
  which they were entitled. {% assign timestamp="39:52" %}

- **Improved reproducible ASMap creation process:** Fabian Jahr
  [posted][jahr asmap] to Delving Bitcoin about advancements in creating
  a map of [autonomous systems][] (ASMap) that each control the routing
  for large parts of the internet.  Bitcoin Core currently tries to
  maintain connections to peers from a diverse collection of subnets of
  the global namespace so that an attacker will need to obtain IP
  addresses on each subnet to perform the simplest type of [eclipse
  attack][topic eclipse attacks] against a node.  However, some ISPs and
  hosting services control IP addresses on multiple subnets, weakening
  this protection.  The ASMap project aims to provide approximate
  information about which ISPs control which IP addresses directly to
  Bitcoin Core (see Newsletters [#52][news52 asmap] and [#83][news83
  asmap]).  A major challenge faced by this project is allowing multiple
  contributors to create a map in a reproducible manner, allowing
  independent verification that its contents were accurate at the time
  it was created.

  In this week's post, Jahr describes the tooling and techniques that
  he says has "found that there is a good chance that within a group
  of 5 or more the majority of participants will have the same result.
  [...] This process can be initiated by anyone, very similar to a
  Core PR. Participants that have a matching result could be
  interpreted as ACKs. If anyone sees something weird in the result or
  they simply didn’t get a match, they can ask for the raw data to be
  shared to investigate further."

  If the process is eventually found acceptable (perhaps with
  additional refinements), it's possible future versions of Bitcoin
  Core could be shipped with ASMaps and the feature enabled by
  default, improving resistance to eclipse attacks. {% assign timestamp="49:17" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Multiparty coordination protocol NWC announced:**
  [Nostr Wallet Connect (NWC)][nwc blog] is a coordination protocol to
  facilitate communications in interactive use cases involving multiple parties.
  While the initial focus of NWC is Lightning, interactive protocols
  like [joinpools][topic joinpools], [Ark][topic ark], [DLCs][topic dlc], or
  [multisignature][topic multisignature] schemes could eventually benefit from
  the protocol. {% assign timestamp="1:11:00" %}

- **Mutiny Wallet v0.5.7 released:**
  The [Mutiny Wallet][mutiny github] release adds [payjoin][topic payjoin] support
  and makes improvements to NWC and LSP features. {% assign timestamp="1:19:07" %}

- **GroupHug transaction batching service:**
  [GroupHug][grouphug github] is a [batching][scaling payment batching] service
  using [PSBTs][topic psbt], with [limitations][grouphug blog]. {% assign timestamp="1:19:48" %}

- **Boltz announces taproot swaps:**
  Non-custodial swap exchange Boltz [announced][boltz blog] an upgrade
  to their atomic swap protocol to use [taproot][topic
  taproot], [schnorr signatures][topic schnorr signatures], and [MuSig2][topic musig]. {% assign timestamp="1:22:43" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.02rc1][] is a release candidate for the next major
  version of this popular LN node. {% assign timestamp="1:24:07" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #27877][] updates Bitcoin Core's wallet with a new [coin
  selection][topic coin selection] strategy, CoinGrinder (see
  [Newsletter #283][news283 coingrinder]).  This strategy is intended to
  be used when estimated feerates are high compared to their long-term
  baseline, allowing the wallet to create small transactions now (with
  the consequence that it may need to create larger transactions at a
  later time, hopefully when feerates are lower). {% assign timestamp="1:24:58" %}

- [BOLTs #851][] adds support for [dual funding][topic dual funding] to
  the LN specification along with support for the interactive
  transaction construction protocol.  Interactive construction allows
  two nodes to exchange preferences and UTXO details that allow them to
  construct a funding transaction together.  Dual funding allows a
  transaction to include inputs from either or both parties.  For
  example, Alice may want to open a channel with Bob.  Before this
  specification change, Alice had to provide all of the funding for the
  channel.  Now, when using an implementation that supports dual
  funding, Alice can open a channel with Bob where he provides all of
  the funding or where they each contribute funds to the initial channel
  state.  This can be combined with the experimental [liquidity
  advertisements protocol][topic liquidity advertisements], which has
  not yet been added to the specification. {% assign timestamp="1:29:00" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1551,27877,851" %}
[news283 coingrinder]: /en/newsletters/2024/01/03/#new-coin-selection-strategies
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[jahr asmap]: https://delvingbitcoin.org/t/asmap-creation-process/548
[autonomous systems]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[daftuar feerate rule]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#feerate-rule-9
[news288 rbfr]: /en/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[daftuar incompatible]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#using-feerate-diagrams-as-an-rbf-policy-tool-13
[daftuar incentive]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[news285 64bit]: /en/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork
[dnssec]: https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[corallo dns]: https://delvingbitcoin.org/t/human-readable-bitcoin-payment-instructions/542/
[dns bip]: https://github.com/TheBlueMatt/bips/blob/d46a29ff4b4ac27210bc81474ae18e4802141324/bip-XXXX.mediawiki
[dns bolt]: https://github.com/lightning/bolts/pull/1136
[dns blip]: https://github.com/lightning/blips/pull/32
[dnssec-prover]: https://github.com/TheBlueMatt/dnssec-prover
[dns demo]: http://http-dns-prover.as397444.net/
[news278 dns]: /en/newsletters/2023/11/22/#offers-compatible-ln-addresses
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[64bit discuss]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549
[thunderbiscuit ecash]: https://delvingbitcoin.org/t/building-intuition-for-the-cashu-blind-signature-scheme/506
[blind signature scheme]: https://en.wikipedia.org/wiki/Blind_signature
[chaumian ecash]: https://en.wikipedia.org/wiki/Ecash
[openalias]: https://openalias.org/
[cashu]: https://github.com/cashubtc/nuts
[bip inout]: https://github.com/Christewart/bips/blob/92c108136a0400b3a2fd66ea6c291ec317ee4a01/bip-op-inout-amount.mediawiki
[mempool series]: /en/blog/waiting-for-confirmation/
[Core Lightning 24.02rc1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02rc1
[nwc blog]: https://blog.getalby.com/scaling-bitcoin-apps/
[mutiny github]: https://github.com/MutinyWallet/mutiny-web
[grouphug blog]: https://peachbitcoin.com/blog/group-hug/
[grouphug github]: https://github.com/Peach2Peach/groupHug
[boltz blog]: https://blog.boltz.exchange/p/introducing-taproot-swaps-putting
