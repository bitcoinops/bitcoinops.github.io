---
title: 'Bitcoin Optech Newsletter #373'
permalink: /en/newsletters/2025/09/26/
name: 2025-09-26-newsletter
slug: 2025-09-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a vulnerability affecting old versions of
Eclair and summarizes research into full node feerate settings.  Also included
are our regular sections summarizing popular questions and answers on the
Bitcoin Stack Exchange, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Eclair vulnerability:** Matt Morehouse [posted][morehouse eclair] to
  Delving Bitcoin to announce the [responsible disclosure][topic
  responsible disclosures] of a vulnerability affecting older versions
  of Eclair.  All Eclair users are recommended to upgrade to version
  0.12 or greater.  The vulnerability allowed an attacker to broadcast
  an old commitment transaction to steal all current funds from a
  channel.  In addition to fixing the vulnerability, Eclair developers
  added a comprehensive testing suite designed to catch similar problems.

- **Research into feerate settings:** Daniela Brozzoni [posted][brozzoni
  feefilter] to Delving Bitcoin the results of a scan of almost 30,000
  full nodes that were accepting incoming connections.  Each node was
  queried for its [BIP133][] fee filter, which indicates the lowest
  feerate at which it will currently accept relayed unconfirmed
  transactions.  When node mempools aren't full, this is
  the node's [default minimum transaction relay feerate][topic default
  minimum transaction relay feerates].  Her results indicate most nodes
  used the default of 1 sat/vbyte (s/v), which has long been the default
  in Bitcoin Core.  About 4% of nodes used 0.1 s/v, the default for the
  upcoming 30.0 version of Bitcoin Core, and about 8% of nodes didn't
  respond to the query---indicating that they might be spy nodes.

  A small percentage of the nodes used a feefilter value of 9,170,997
  (10,000 s/v), which developer 0xB10C [noted][0xb10c feefilter] is the
  value Bitcoin Core sets, through rounding, when the node is more than
  100 blocks behind the tip of the chain and is focused on receiving
  block data rather than transactions that might be confirmed in later
  blocks.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

-  [Bitcoin Core 30.0rc1][] is a release candidate for the next major version of
   this full verification node software. Please see the [version 30 release
   candidate testing guide][bcc30 testing].

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33333][] emits a startup warning message if a node's `dbcache`
  setting exceeds a cap derived from the node's system RAM, to prevent
  out-of-memory errors or heavy swapping. For systems with less than 2GB of RAM,
  the `dbcache` warning threshold is 450MB; otherwise, the threshold is 75% of
  the total RAM. The `dbcache` 16GB limit was removed in September 2024 (see
  Newsletter [#321][news321 dbcache]).

- [Bitcoin Core #28592][] increases the per-peer transaction relay rate from 7
  to 14 for inbound peers due to an increased presence of smaller transactions on
  the network. The rate for outbound peers is 2.5 times higher, increasing to 35
  transactions per second. The transaction relay rate limits the number of
  transactions a node sends to its peers.

- [Eclair #3171][] removes `PaymentWeightRatios`, a pathfinding method that
  assumed uniformity in channel balances, and replaces it with a newly
  introduced probabilistic approach based on past payment attempt history (see
  Newsletter [#371][news371 path]).

- [Eclair #3175][] starts rejecting unpayable [BOLT12][] [offers][topic offers]
  where the fields `offer_chains`, `offer_paths`, `invoice_paths`, and
  `invoice_blindedpay` are present but empty.

- [LDK #4064][] updates its signature verification logic to ensure that if the
  `n` field (payee’s pubkey) is present, the signature is verified against it.
  Otherwise, the payee’s pubkey is extracted from the [BOLT11][] invoice with
  either a high-S or low-S signature. This PR aligns signature checks with the
  proposed [BOLTs #1284][] and with other implementations such as Eclair (See
  Newsletter [#371][news371 pubkey]).

- [LDK #4067][] adds support for spending [P2A ephemeral anchor][topic
  ephemeral anchors] outputs from [zero-fee commitment][topic v3 commitments] transactions, ensuring
  that channel peers can claim their funds back on-chain. See Newsletter
  [#371][news371 p2a] for LDK’s implementation of zero-fee commitment channels.

- [LDK #4046][] enables an often-offline sender to send [async payments][topic
  async payments] to an often-offline recipient. The sender sets a flag in the
  `update_add_htlc` message to indicate that the [HTLC][topic htlc] should be
  held by the LSP until the recipient comes back online and sends a
  `release_held_htlc` [onion message][topic onion messages] to claim the
  payment.

- [LDK #4083][] deprecates the `pay_for_offer_from_human_readable_name` endpoint
  to remove duplicate [BIP353][] HRN payment APIs. Wallets are encouraged to use
  the `bitcoin-payment-instructions` crate to parse and resolve payment
  instructions before calling `pay_for_offer_from_hrn` to pay an [offer][topic
  offers] from a [BIP353][] HRN (e.g. satoshi@nakamoto.com).

- [LND #10189][] updates its `sweeper` system (see Newsletter [#346][news346
  sweeper]) to properly recognize the `ErrMinRelayFeeNotMet` error code and
  retry failed transactions by [fee bumping][topic rbf] until the broadcast is
  successful. Previously, the error would be mismatched, and the transaction
  wouldn't be retried. This PR also improves weight estimation by accounting for
  a possible extra change output, which is relevant in [taproot][topic taproot]
  overlay channels used to enhance LND’s [Taproot Assets][topic client-side
  validation].

- [BIPs #1963][] updates the status of the BIPs that specify [compact block
  filters][topic compact block filters], [BIP157][] and [BIP158][], from `Draft`
  to `Final` as they’ve been deployed in Bitcoin Core and other software since
  2020.

{% include snippets/recap-ad.md when="2025-09-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33333,28592,3171,3175,4064,4067,4046,4083,10189,1963,1284" %}
[morehouse eclair]: https://delvingbitcoin.org/t/disclosure-eclair-preimage-extraction-exploit/2010
[brozzoni feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989
[0xb10c feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989/3
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[news321 dbcache]: /en/newsletters/2024/09/20/#bitcoin-core-28358
[news371 path]: /en/newsletters/2025/09/12/#eclair-2308
[news371 pubkey]: /en/newsletters/2025/09/12/#eclair-3163
[news371 p2a]: /en/newsletters/2025/09/12/#ldk-4053
[news346 sweeper]: /en/newsletters/2025/03/21/#discussion-of-lnd-s-dynamic-feerate-adjustment-system