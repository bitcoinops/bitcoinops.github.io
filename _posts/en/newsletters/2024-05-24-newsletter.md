---
title: 'Bitcoin Optech Newsletter #304'
permalink: /en/newsletters/2024/05/24/
name: 2024-05-24-newsletter
slug: 2024-05-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an analysis of several proposals for
upgrading LN channels without closing and reopening them, discusses
challenges in ensuring pool miners are paid appropriately, links to a
discussion about safely using PSBTs for communicating information
related to silent payments, announces a proposed BIP for miniscript, and
summarizes a proposal for using frequent rebalancing of an LN channel to
simulate a price futures contract.  Also included are our regular
sections summarizing changes to services and client software, announcing
new releases and release candidates, and summarizing notable changes to
popular Bitcoin infrastructure software.

## News

- **Upgrading existing LN channels:** Carla Kirk-Cohen [posted][kc
  upchan] to Delving Bitcoin a summary and analysis of existing
  proposals for upgrading existing LN channels to support new features.
  She examines a variety of different cases, such as:

  - *Changing parameters:* currently, some channel settings are
    negotiated between parties and cannot be changed during the lifespan of the
    channel.  Parameter updates would allow renegotiation at subsequent
    times.  For example, nodes might want to change the number of satoshis
    at which they begin [trimming HTLCs][topic trimmed htlc] or the amount
    of channel reserve they expect their counterparty to maintain to
    disincentivize closing in an old state.

  - *Updating commitments:* LN _commitment transactions_ allow an
    individual to put the current channel state onchain.  [Commitment
    upgrades][topic channel commitment upgrades] can allow switching to [anchor outputs][topic anchor
    outputs] and [v3 transactions][topic v3 transaction relay] in
    P2WSH-based channels, and for [simple taproot channels][topic simple
    taproot channels] to switch to using [PTLCs][topic ptlc].

  - *Replacing funding:* LN channels are anchored onchain in a _funding
    transaction_, the output of which is spent offchain repeatedly as
    the commitment transaction.  Originally all LN funding transactions
    used a P2WSH output; however, newer features such as [PTLCs][topic
    ptlc] require funding transactions to use P2TR outputs.

  Kirk-Cohen compares three previously proposed ideas for upgrading
  channels:

  - *Dynamic commitments:* as described in a [draft specification][BOLTs
    #1117], this allows changing almost all channel parameters and also
    provides a generalized path for upgrading funding and commitment
    transactions using a new "kickoff" transaction.

  - *Splice to upgrade:* this idea allows a [splice transaction][topic
    splicing] that would already necessarily update a channel's onchain
    funding to change the type of funding used as well as, optionally,
    its commit transaction format.  It doesn't deal directly with
    changing channel parameters.

  - *Upgrade on re-establish:* also described in a [draft
    specification][bolts #868], this allows changing many channel
    parameters any time two nodes re-establish a data connection.
    It doesn't deal directly with funding and commitment transaction
    upgrades.

  With all the options presented, Kirk-Cohen compares them in a table
  listing their onchain costs, upsides, and downsides; she also compares
  them against the onchain costs of not making any upgrades.  She draws
  several conclusions, including: "I think that it makes sense to start
  work on [both] parameter [and] commitment upgrades via [dynamic
  commitments][bolts #1117], independently of how we choose to go about
  upgrading to taproot channels. This gives us the ability to upgrade to
  `option_zero_fee_htlc_tx` anchor channels, and provides a commitment
  format upgrade mechanism that can be used to get us to V3 channels
  (once specified)." {% assign timestamp="1:27" %}

- **Challenges in rewarding pool miners:** Ethan Tuttle [posted][tuttle
  poolcash] to Delving Bitcoin to suggest that [mining pools][topic
  pooled mining] could reward miners with [ecash][topic ecash] tokens
  proportionate to the number of shares they mined.  The miners could
  then immediately sell or transfer the tokens, or they could wait for
  the pool to mine a block, at which point the pool would exchange the
  tokens for satoshis.

  Both criticisms and suggestions of the idea were posted.  We found
  especially insightful a [reply][corallo pooldelay] by Matt Corallo
  where he describes an underlying problem: there are no standardized
  payment methods implemented by large pools that allow pool miners to
  calculate their payouts over short intervals.  Two commonly used
  payout types are:

  - *Pay per share (PPS):* this pays a miner proportionately to the amount
    of work they contributed even if a block isn't found.  Calculating
    the proportionate payout for the block subsidy is easy, but
    calculating it for transaction fees is more complicated.  Corallo
    notes that most pools appear to be using an average of the fees
    collected during the day the share was created, meaning the amount
    paid per share can't be calculated until a day after the share was
    mined.  Additionally, many pools may tweak the fee averages in a way
    that varies by pool.

  - *Pay per last n shares (PPLNS):* rewards miners for shares found
    near the time the pool finds a block.  However, a miner can only be
    sure that a pool found a block if the miner themselves found it.
    There's no way (in the short term) for a typical miner to know the
    pool is providing them with a correct payout.

  This lack of information means miners won't
  quickly switch to a different pool if their main pool begins cheating them
  of payments.  [Stratum v2][topic pooled mining] doesn't fix this, although
  candid pools can use a standardized message to tell miners that
  they're going to cease paying for new shares. Corallo links to a
  [proposal][corallo sv2 proposal] for Stratum v2 to allow miners to
  verify that all of their shares are accounted for in payouts, which
  may at least allow miners to detect if they aren't being paid
  correctly after a longer period (hours to days).

  Discussion was ongoing at the time of writing. {% assign timestamp="6:58" %}

- **Discussion about PSBTs for silent payments:** Josie Baker
  [started][baker psbtsp] a discussion on Delving Bitcoin about
  [PSBT][topic psbt] extensions for [silent payments][topic silent
  payments] (SPs), citing a [draft specification][toth psbtsp] by Andrew
  Toth.  PSBTs for SPs have two aspects:

  - **Spending to SP addresses:** the actual output script placed in a
    transaction depends on both the silent payment address and the
    inputs in the transaction.  Any change to the inputs in a PSBT can
    potentially make an SP output unspendable by standard wallet
    software, so extra PSBT validation is required.  Some input types
    can't be used with SPs, which also needs validation.

    For the input types that can be used, the SP-aware spending logic
    needs the private key for those inputs, which may not be available
    to a software wallet when the underlying key is stored in a hardware
    signing device.  Baker describes a scheme that may allow a spender
    to create an SP output script without the private key, but it has
    the potential to leak a private key, so it may not see
    implementation in hardware signing devices.

  - **Spending previously received SP outputs:** PSBTs will need to
    include the shared secret that is used as a tweak of the spending
    key.  This can be just an additional PSBT field.

  Discussion was ongoing at the time of writing.
  {% assign timestamp="12:40" %}

- **Proposed miniscript BIP:** Ava Chow [posted][chow miniscript] to
  the Bitcoin-Dev mailing list a [draft BIP][chow bip] for
  [miniscript][topic miniscript], a language that can be converted to
  Bitcoin Script but which allows composition, templating, and definitive
  analysis.  The draft BIP is derived from miniscript's long-standing
  website and should correspond with existing implementations of
  miniscript both for P2WSH witness script and P2TR [tapscript][topic
  tapscript]. {% assign timestamp="21:32" %}

- **Channel value pegging:** Tony Klausing [posted][klausing stable] to
  Delving Bitcoin a proposal, with working [code][klausing code], for
  _stable channels_.  Imagine Alice wants to keep an amount of bitcoin
  that equals $1,000 USD.  Bob is willing to guarantee that, either
  because he expects BTC to increase in value or because Alice is paying
  him a premium (or both).  They open an LN channel together and, every
  minute, they perform the following actions:

  - They both check the same BTC/USD price sources.

  - If the value of BTC goes up, Alice reduces her bitcoin balance until
    it's equal in value to $1,000 USD, transferring the excess to Bob.

  - If the value of BTC goes down, Bob sends enough BTC to Alice until
    her bitcoin balance is equal in value to $1,000 USD again.

  The goal is for the rebalancing to occur frequently enough that each
  price change is below the cost to the disadvantaged party of closing
  the channel, encouraging them to simply pay and continue the
  relationship.

  Klausing suggests that some traders could find this minimally trusted
  relationship preferable to custodial futures markets.  He also
  suggests that it could be used as the basis for a bank that issues
  dollar-denominated [ecash][topic ecash].  The scheme would work for
  any asset for which a market price could be determined. {% assign timestamp="31:42" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Silent payment resources:**
  Several [silent payment][topic silent payments] resources have been announced
  including a [silentpayments.xyz][sp website] informational website, [two][bi
  ts sp] TypeScript [libraries][bw ts sp], a [Go-based backend][gh blindbitd], a
  [web wallet][gh silentium], and [more][sp website devs]. Caution is advised as
  most of the software is new, beta, or a work in progress. {% assign timestamp="43:50" %}

- **Cake Wallet adds silent payments:**
  [Cake Wallet][cake wallet website] recently [announced][cake wallet
  announcement] their latest beta release supports silent payments. {% assign timestamp="46:14" %}

- **Coordinator-less coinjoin PoC:**
  [Emessbee][gh emessbee] is a proof-of-concept project to create [coinjoin][topic coinjoin]
  transactions without a central coordinator. {% assign timestamp="46:26" %}

- **OCEAN adds BOLT12 support:**
  The OCEAN mining pool uses a [signed message][topic generic signmessage] to associate
  a Bitcoin address to a [BOLT12 offer][topic offers] as part of their [Lightning
  payout][ocean docs] setup. {% assign timestamp="47:10" %}

- **Coinbase adds Lightning support:**
  Using Lightning infrastructure from [Lightspark][lightspark website], [Coinbase added
  Lightning][coinbase blog] deposit and withdrawal support. {% assign timestamp="48:57" %}

- **Bitcoin escrow tooling announced:**
  The [BitEscrow][bitescrow website] team announced a set of [developer tools][bitescrow docs] for
  implementing non-custodial Bitcoin escrow. {% assign timestamp="49:20" %}

- **Block's call for mining community feedback:**
  In an [update][block blog] to their 3nm chip progress, Block is seeking mining
  community feedback about mining hardware software features, maintenance, and
  other questions. {% assign timestamp="49:48" %}

- **Sentrum wallet tracker released:**
  [Sentrum][gh sentrum] is a watch-only wallet that supports a variety of notification channels. {% assign timestamp="50:34" %}

- **Stack Wallet adds FROST support:**
  [Stack Wallet v2.0.0][gh stack wallet] adds FROST [threshold][topic threshold
  signature] multisig support using the Modular FROST Rust library. {% assign timestamp="51:19" %}

- **Transaction broadcast tool announced:**
  [Pushtx][gh pushtx] is a simple Rust program that broadcasts transactions directly to the
  Bitcoin P2P network. {% assign timestamp="53:41" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Inquisition 27.0][] is the latest major release of this fork
  of Bitcoin Core designed for testing soft forks and other major
  protocol changes on [signet][topic signet].  New in this release is
  signet enforcement of [OP_CAT][] as specified in [BIN24-1][] and
  [BIP347][].  Also included is "a new `evalscript` subcommand for
  `bitcoin-util` that can be used to test script opcode behavior".
  Support has been dropped for `annexdatacarrier` and pseudo [ephemeral
  anchors][topic ephemeral anchors] (see Newsletters [#244][news244
  annex] and [#248][news248 ephemeral]). {% assign timestamp="56:30" %}

- [LND v0.18.0-beta.rc2][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="1:00:10" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #27101][] introduces support for
  JSON-RPC 2.0 requests and server responses. Notable changes are that the
  server always returns HTTP 200 "OK" unless there is an HTTP error or malformed
  request, it returns either error or result fields but never both, and single
  and batch requests result in the same error handling behavior. If version 2.0
  isn't specified in the request body, the legacy JSON-RPC 1.1 protocol is used. {% assign timestamp="1:00:30" %}

- [Bitcoin Core #30000][] allows multiple transactions with the same
  `txid` to coexist in `TxOrphanage` by indexing them by `wtxid` instead
  of `txid`. The orphanage is a limited-size staging area that Bitcoin Core
  uses to store transactions which reference the txids of parent
  transactions that Bitcoin Core can't currently access.
  If a parent transaction with the txid is received, the child
  can then be processed.  Opportunistic 1-parent-1-child (1p1c)
  [package acceptance][topic package relay] sends a child transaction
  first, expecting it to be stored in the orphanage, and then sends the
  parent---allowing their aggregate feerate to be considered.

  However, when opportunistic 1p1c was merged (see [Newsletter
  #301][news301 bcc28970]), it was known that an attacker could prevent
  an honest user from using the feature by preemptively submitting a version
  of a child transaction with invalid witness data.  That malformed
  child transaction would have the same txid as an honest child but
  would fail validation when its parent was received, preventing the
  child from contributing to the [CPFP][topic cpfp] package
  feerate necessary for package acceptance to work.

  Because transactions in the orphanage were indexed by txid before this
  PR, the first version of a transaction with a particular txid would be
  the one stored in the orphanage, so an attacker who could submit
  transactions faster and more frequently than an honest user could
  block the honest user indefinitely.  After this PR, multiple
  transactions with the same txid can be accepted, each one with
  different witness data (and, thus, a different wtxid).  When a parent
  transaction is received, the node will have enough information to drop
  any malformed child transactions and then perform the expected 1p1c
  package acceptance on a valid child.  This PR was previously discussed
  in the PR Review Club summary in [Newsletter #301][news301 prclub]. {% assign timestamp="1:01:27" %}

- [Bitcoin Core #28233][] builds on [#17487][bitcoin core #17487] to
  remove the periodic flush of the warm coins (UTXO) cache every 24
  hours.  Before #17487, frequent flushing to disk reduced the risk that
  a node or hardware crash would require a lengthy reindex procedure.
  After #17487, new UTXOs can be written to disk without emptying the
  memory cache---although the cache still needs to be emptied when it
  nears the maximum allocated memory space.  A warm cache almost doubles
  the block validation speed on a node with the default cache settings,
  with even more improved performance available on nodes that allocate
  additional memory to the cache. {% assign timestamp="1:02:42" %}

- [Core Lightning #7304][] adds a reply flow to [offers][topic offers]-style `invoice_requests` when it can’t
  find a path to the `reply_path` node.  CLN's `connectd` will open a transient TCP/IP
  connection to the requesting node to deliver an [onion message][topic onion
  messages] containing an invoice. This PR improves Core Lightning’s
  interoperability with LDK and also allows using onion messages even
  while only a few nodes support them (see [Newsletter #283][news283
  ldk2723]). {% assign timestamp="1:09:41" %}

- [Core Lightning #7063][] updates the feerate security margin
  multiplier to dynamically adjust for likely fee
  increases. The multiplier tries to ensure that channel transactions
  pay enough feerate that they will be confirmed, either directly (for
  transactions that can't be fee bumped) or through fee bumping.  The
  multiplier now starts at 2x current [feerate estimates][topic fee
  estimation] for low rates (1 sat/vbyte) and gradually decreases to 1.1x
  as feerates approach the daily high `maxfeerate`. {% assign timestamp="1:10:18" %}

- [Rust Bitcoin #2740][] adds a `from_next_work_required` method to the `pow`
  (proof of work) API that takes a `CompactTarget` (representing the previous
  difficulty target), a `timespan` (the time difference between the current and
  previous blocks), and a `Params` network parameters object. It returns a new
  `CompactTarget` representing the next difficulty target. The algorithm
  implemented in this function is based on the Bitcoin Core implementation found
  in the  `pow.cpp` file. {% assign timestamp="1:17:54" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-27 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27101,30000,28233,7304,7063,2740,1117,868,17487" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[kc upchan]: https://delvingbitcoin.org/t/upgrading-existing-lightning-channels/881
[tuttle poolcash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[corallo pooldelay]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/14
[corallo sv2 proposal]: https://github.com/stratum-mining/sv2-spec/discussions/76#discussioncomment-9472619
[baker psbtsp]: https://delvingbitcoin.org/t/bip352-psbt-support/877
[toth psbtsp]: https://gist.github.com/andrewtoth/dc26f683010cd53aca8e477504c49260
[chow miniscript]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0be34bd2-637b-44b1-a0d5-e0ad5812d505@achow101.com/
[chow bip]: https://github.com/achow101/bips/blob/miniscript/bip-miniscript.md
[klausing stable]: https://delvingbitcoin.org/t/stable-channels-peer-to-peer-dollar-balances-on-lightning/875
[klausing code]: https://github.com/toneloc/stable-channels/
[news244 annex]: /en/newsletters/2023/03/29/#bitcoin-inquisition-22
[news248 ephemeral]: /en/newsletters/2023/04/26/#bitcoin-inquisition-23
[Bitcoin Inquisition 27.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v27.0-inq
[news301 prclub]: /en/newsletters/2024/05/08/#bitcoin-core-pr-review-club
[news301 bcc28970]: /en/newsletters/2024/05/08/#bitcoin-core-28970
[news283 ldk2723]: /en/newsletters/2024/01/03/#ldk-2723
[sp website]: https://silentpayments.xyz/
[bi ts sp]: https://github.com/Bitshala-Incubator/silent-pay
[bw ts sp]: https://github.com/BlueWallet/SilentPayments
[gh blindbitd]: https://github.com/setavenger/blindbitd
[gh silentium]: https://github.com/louisinger/silentium
[sp website devs]: https://silentpayments.xyz/docs/developers/
[cake wallet website]: https://cakewallet.com/
[cake wallet announcement]: https://twitter.com/cakewallet/status/1791500775262437396
[gh emessbee]: https://github.com/supertestnet/coinjoin-workshop
[coinbase blog]: https://www.coinbase.com/blog/coinbase-integrates-bitcoins-lightning-network-in-partnership-with
[lightspark website]: https://www.lightspark.com/
[block blog]: https://www.mining.build/latest-updates-3nm-system/
[gh sentrum]: https://github.com/sommerfelddev/sentrum
[ocean docs]: https://ocean.xyz/docs/lightning
[bitescrow website]: https://www.bitescrow.app/
[bitescrow docs]: https://www.bitescrow.app/dev
[gh stack wallet]: https://github.com/cypherstack/stack_wallet/releases/tag/build_222
[gh pushtx]: https://github.com/alfred-hodler/pushtx
