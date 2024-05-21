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
  (once specified)."

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

  Discussion was ongoing at the time of writing.

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

- **Proposed miniscript BIP:** Ava Chow [posted][chow miniscript] to
  the Bitcoin-Dev mailing list a [draft BIP][chow bip] for
  [miniscript][topic miniscript], a language that can be converted to
  Bitcoin Script but which allows composition, templating, and definitive
  analysis.  The draft BIP is derived from miniscript's long-standing
  website and should correspond with existing implementations of
  miniscript both for P2WSH witness script and P2TR [tapscript][topic
  tapscript].

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
  any asset for which a market price could be determined.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

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
  annex] and [#248][news248 ephemeral]).

- [LND v0.18.0-beta.rc2][] is a release candidate for the next major
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

FIXME:Gustavojfe to add summaries

- [Bitcoin Core #27101][] Support JSON-RPC 2.0 when requested by client

- [Bitcoin Core #30000][] p2p: index TxOrphanage by wtxid, allow entries
  with same txid (maybe link back to PR review club summary in
  2024-05-08 newsletter -harding)

- [Bitcoin Core #28233][] validation: don't clear cache on periodic flush: >2x block connection speed

- [Core Lightning #7304][] make explicit connection to node if necessary
  (the interesting part of this PR isn't the LDK interop but that CLN
  will use its routing table to open a TCP/IP connection to a node
  just to deliver an onion message.  I'm not sure we've previously
  discussed that this is allowed with onion messages -harding)

- [Core Lightning #7063][] channeld: Adjust the feerate security margin profile

- [Rust Bitcoin #2740][] Add difficulty adjustment calculation

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-27 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27101,30000,28233,7304,7063,2740,1117,868" %}
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
