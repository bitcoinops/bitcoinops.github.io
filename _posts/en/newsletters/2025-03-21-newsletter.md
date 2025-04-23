---
title: 'Bitcoin Optech Newsletter #346'
permalink: /en/newsletters/2025/03/21/
name: 2025-03-21-newsletter
slug: 2025-03-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about LND's updated
dynamic feerate adjustment system.  Also included are our regular
sections describing recent changes to services and client software,
announcing new releases and release candidates, and summarizing recent
merges to popular Bitcoin infrastructure software.

## News

- **Discussion of LND's dynamic feerate adjustment system:** Matt
  Morehouse [posted][morehouse sweep] to Delving Bitcoin a description
  of LND's recently-rewritten _sweeper_ system, which
  determines the feerates to use for onchain transactions (including
  [RBF][topic rbf] fee bumps).  He begins with a brief description
  of the safety critical aspects of fee management for an LN node, as
  well as the natural desire to avoid overpaying.  He then describes the
  two general strategies used by LND:

  - Querying external feerate estimators, such as a local Bitcoin Core
    node or a third party.  This is mainly used for choosing initial
    feerates and fee bumping non-urgent transactions.

  - Exponential fee bumping, used when a deadline is approaching to
    ensure that problems with a node's mempool or its [fee estimation][topic fee estimation]
    don't prevent timely confirmation.  For example, Eclair uses exponential fee
    bumping when deadlines are within six blocks.

  Morehouse then describes how these two strategies are combined in
  LND's new sweeper system: "[HTLC][topic htlc] claims with matching
  deadlines [are aggregated] into a single [batched transaction][topic
  payment batching]. The budget for the batched transaction is
  calculated as the sum of the budgets for the individual HTLCs in the
  transaction. Based on the transaction budget and deadline, a fee
  function is computed that determines how much of the budget is spent
  as the deadline approaches.  By default, a linear fee function is used,
  which starts at a low fee (determined by the minimum relay fee rate or
  an external estimator) and ends with the total budget being allocated
  to fees when the deadline is one block away."

  He additionally describes how the new logic helps protect against
  [replacement cycling][topic replacement cycling] attacks, concluding:
  "with LND’s default parameters an attacker must generally spend at
  least 20x the value of the HTLC to successfully carry out a
  replacement cycling attack."  He adds that the new system also
  improves LND's defense against [pinning attacks][topic transaction
  pinning].

  He concludes with a link-filled summary of several "LND-specific bug
  and vulnerability fixes" made through the improved logic.  Abubakar
  Sadiq Ismail [replied][ismail sweep] with some suggestions for how all
  LN implementations (in addition to other software) can more
  effectively use Bitcoin Core's fee estimation.  Several other
  developers also commented, adding both nuance to the description and
  praise for the new approach. {% assign timestamp="1:24" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Wally 1.4.0 released:**
  The [libwally-core 1.4.0 release][wally 1.4.0] adds [taproot][topic
  taproot] support, support for deriving [BIP85][] RSA keys, as well as additional
  [PSBT][topic psbt] and [descriptor][topic descriptors] features. {% assign timestamp="17:17" %}

- **Bitcoin Core Config Generator announced:**
  The [Bitcoin Core Config Generator][bccg github] project is a terminal interface
  for creating Bitcoin Core `bitcoin.conf` configuration files. {% assign timestamp="18:05" %}

- **A regtest development environment container:**
  The [regtest-in-a-pod][riap github] repository provides a [Podman][podman
  website] container configured with Bitcoin Core, Electrum, and Esplora, as outlined
  in the [Using Podman Containers for Regtest Bitcoin Development][podman
  bitcoin blog] blog post. {% assign timestamp="18:55" %}

- **Explora transaction visualization tool:**
  [Explora][explora github] is a web-based explorer for visualizing and
  navigating between transaction inputs and outputs. {% assign timestamp="20:17" %}

- **Hashpool v0.1 tagged:**
  [Hashpool][hashpool github] is a [mining pool][topic pooled mining] based on
  the [Stratum v2 reference implementation][news247 sri] where mining shares are
  represented as [ecash][topic ecash] tokens (see [Podcast #337][pod337 hashpool]). {% assign timestamp="21:35" %}

- **DMND launching pooled mining:**
  [DMND][dmnd website] is launching Stratum v2 pooled mining, building on their
  previous solo mining [announcement][news281 demand]. {% assign timestamp="24:36" %}

- **Krux adds taproot and miniscript:**
  [Krux][news273 krux] adds [miniscript][topic miniscript] and taproot support,
  leveraging the [embit][embit website] library. {% assign timestamp="22:21" %}

- **Source-available secure element announced:**
  The [TROPIC01][tropic01 website] is a secure element built on RISC-V with
  an [open architecture][tropicsquare github] for auditability. {% assign timestamp="23:01" %}

- **Nunchuk launches Group Wallet:**
  [Group Wallet][nunchuk blog] supports [multisignature][topic
  multisignature] signing, taproot, coin control, [Musig2][topic musig], and
  secure communication between participants by repurposing the output descriptors in the
  [BIP129][] Bitcoin Secure Multisig Setup (BSMS) file. {% assign timestamp="45:04" %}

- **FROSTR protocol announced:**
  [FROSTR][frostr github] uses the FROST [threshold signature scheme][topic
  threshold signature] to achieve k-of-n signing and key management for nostr. {% assign timestamp="46:03" %}

- **Bark launches on signet:**
  The [Bark][new325 bark] implementation of [Ark][topic ark] is now
  [available][second blog] on [signet][topic signet] with a faucet and demo
  store for testing. {% assign timestamp="46:57" %}

- **Cove Bitcoin wallet announced:**
  [Cove Wallet][cove wallet github] is an open source Bitcoin mobile wallet based on
  BDK that supports technologies like PSBTs, [wallet labels][topic wallet labels],
  hardware signing devices, and more. {% assign timestamp="48:43" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.0rc2][] is a release candidate for the next major
  version of the network's predominate full node. {% assign timestamp="50:38" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31649][] removes all checkpoint logic, which is no longer
  necessary following the headers presync step implemented years ago (see
  Newsletter [#216][news216 presync]) that enables a node during Initial Block
  Download (IBD) to determine if a chain of headers is valid by comparing its
  total proof of work (PoW) to a predefined threshold `nMinimumChainWork`. Only
  chains with a total proof of work exceeding this value are considered valid
  and stored, effectively preventing memory DoS attacks from low-work headers.
  This eliminates the need for checkpoints, which were often seen as a
  centralized element. {% assign timestamp="1:03:19" %}

- [Bitcoin Core #31283][] introduces a new `waitNext()` method to the
  `BlockTemplate` interface, which will only return a new template if the chain
  tip changes or the mempool fees increase above the `MAX_MONEY` threshold.
  Previously, miners would receive a new template with every request, resulting
  in unnecessary template generation. This change aligns with the [Stratum
  V2][topic pooled mining] protocol specification. {% assign timestamp="37:27" %}

- [Eclair #3037][] enhances the `listoffers` command (See Newsletter
  [#345][news345 offers]) to return all relevant [offer][topic offers] data,
  including the `createdAt` and `disabledAt` timestamps, instead of just raw
  Type-Length-Value (TLV) data. In addition, this PR fixes a bug that caused the
  node to crash when attempting to register the same offer twice. {% assign timestamp="1:15:29" %}

- [LND #9546][] adds an `ip_range` flag to the `lncli constrainmacaroon` (see
  Newsletter [#201][news201 constrain]) subcommand, allowing users to restrict
  access to a resource to a specific IP range when using a macaroon
  (authentication token). Previously, macaroons could only allow or deny access
  based on specific IP addresses, not ranges. {% assign timestamp="1:16:33" %}

- [LND #9458][] introduces restricted access slots for certain peers,
  configurable via the `--num-restricted-slots` flag, to manage initial access
  permissions on the server. Peers are assigned access levels based on their
  channel history: those with a confirmed channel receive protected access,
  those with an unconfirmed channel receive temporary access, and all others are
  given restricted access. {% assign timestamp="1:17:17" %}

- [BTCPay Server #6581][] adds [RBF][topic rbf] support, enabling fee bumping
  for transactions that have no descendants, where all inputs are from the
  store’s wallet, and which include one of the store’s change addresses. Users
  can now choose between [CPFP][topic cpfp] and RBF when choosing to fee bump a
  transaction. Fee bumping requires NBXplorer version 2.5.22 or higher. {% assign timestamp="1:18:10" %}

- [BDK #1839][] adds support for detecting and handling canceled (double-spent)
  transactions by introducing a new `TxUpdate::evicted_ats` field, which updates
  the `last_evicted` timestamps in `TxGraph`. Transactions are considered
  evicted if their `last_evicted` timestamp exceeds their `last_seen` timestamp.
  The canonicalization algorithm (see Newsletter [#335][news335 algorithm]) is
  updated to ignore evicted transactions except when a canonical descendant
  exists due to rules of transitivity. {% assign timestamp="1:20:59" %}

- [BOLTs #1233][] updates a node’s behavior to never fail an [HTLC][topic htlc]
  upstream if the node knows the preimage, ensuring that the HTLC can be
  properly settled. Previously, the recommendation was to fail an outstanding
  HTLC upstream if it was missing from a confirmed commitment, even if the
  preimage was known. A bug in LND versions before 0.18 caused nodes under DoS
  attack to fail HTLCs upstream after a restart, despite knowing the preimage,
  resulting in the loss of the HTLC’s value (see Newsletter [#344][news344
  lnd]). {% assign timestamp="15:39" %}

{% include snippets/recap-ad.md when="2025-03-25 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31649,31283,3037,9546,9458,6581,1839,1233" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[morehouse sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512
[ismail sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512/3
[news216 presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[news345 offers]: /en/newsletters/2025/03/14/#eclair-2976
[news201 constrain]: /en/newsletters/2022/05/25/#lnd-6529
[news344 lnd]: /en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[news335 algorithm]: /en/newsletters/2025/01/03/#bdk-1670
[wally 1.4.0]: https://github.com/ElementsProject/libwally-core/releases/tag/release_1.4.0
[bccg github]: https://github.com/jurraca/core-config-tui
[riap github]: https://github.com/thunderbiscuit/regtest-in-a-pod
[podman website]: https://podman.io/
[podman bitcoin blog]: https://thunderbiscuit.com/posts/podman-bitcoin/
[explora github]: https://github.com/lontivero/explora
[hashpool github]: https://github.com/vnprc/hashpool
[news247 sri]: /en/newsletters/2023/04/19/#stratum-v2-reference-implementation-update-announced
[pod337 hashpool]: /en/podcast/2025/01/21/#continued-discussion-about-rewarding-pool-miners-with-tradeable-ecash-shares-transcript
[news281 demand]: /en/newsletters/2023/12/13/#stratum-v2-mining-pool-launches
[dmnd website]: https://www.dmnd.work/
[embit website]: https://embit.rocks/
[news273 krux]: /en/newsletters/2023/10/18/#krux-signing-device-firmware
[tropic01 website]: https://tropicsquare.com/tropic01
[tropicsquare github]: https://github.com/tropicsquare
[nunchuk blog]: https://nunchuk.io/blog/group-wallet
[frostr github]: https://github.com/FROSTR-ORG
[new325 bark]: /en/newsletters/2024/10/18/#bark-ark-implementation-announced
[second blog]: https://blog.second.tech/try-ark-on-signet/
[cove wallet github]: https://github.com/bitcoinppl/cove
