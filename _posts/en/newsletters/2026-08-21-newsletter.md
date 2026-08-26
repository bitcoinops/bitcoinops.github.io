---
title: 'Bitcoin Optech Newsletter #419'
permalink: /en/newsletters/2026/08/21/
name: 2026-08-21-newsletter
slug: 2026-08-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the disclosure of a fixed reorg vulnerability
in LND's channel closes and describes a draft BIP for the `rawtr()` output
script descriptor. Also included are our regular sections describing recent
changes to services and client software and notable changes to popular Bitcoin
infrastructure software.

## News

- **Reorg vulnerability in LND channel closes**: Bastien Teinturier [posted][lnd vuln del]
  to Delving Bitcoin the [responsible disclosure][topic responsible disclosures]
  of a vulnerability that affected LND versions before [0.20.0][lnd v20.0],
  which fixed it in February 2026. Operators running an older version should
  upgrade. To Teinturier's knowledge, no one was affected by the vulnerability.

  Before that version, an LND node would forget about a collaboratively closed
  channel immediately after the first onchain confirmation, losing the protection
  against chain reorgs. In case of a reorg, an attacker could publish an old, revoked
  commitment transaction for the channel and because the node had already
  forgotten the channel, it would not publish a penalty transaction,
  letting the attacker drain all of the channel's funds.

  The vulnerability was discovered in February 2025 and fixed in
  [LND #10331][] (see [Newsletter #389][news389 lnd10331]). The patch makes a node
  wait for more confirmations before considering a channel close final (at
  least six, following [BOLT5][]'s reorg-safety handling). Teinturier's post
  includes a regtest reproduction and a timeline of the disclosure.
  {% assign timestamp="1:13" %}

- **Draft BIP for `rawtr()` output script descriptor**: Jean Pablo [posted][rawtr ml]
  to the Bitcoin-Dev mailing list about a BIP proposal for the `rawtr()`
  [output script descriptor][topic descriptors].

  A `rawtr()` descriptor can be used to express a P2TR output directly by its output key,
  without needing an internal key or a script tree. The key is used as the
  [taproot][topic taproot] output key without applying the [BIP341][] tweak.
  This is useful, for example, when the internal structure isn't known, or the
  script tree hasn't been revealed by the owner.

  This descriptor has been available in Bitcoin Core since version 24.0,
  but had not yet been specified in a BIP. Several implementations route around
  the problem by either not supporting it, or quoting other BIPs.
  The proposal aims to close this gap. The BIP draft and test vectors are available
  and being discussed under [BIPs #2251][]. {% assign timestamp="1:14:36" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Payjoin Dev Kit (rust-payjoin) 1.0.0 released:**
  The Payjoin Dev Kit project [released][payjoin 1.0.0] the first stable version
  of rust-payjoin, supporting both synchronous BIP78 [payjoins][topic payjoin]
  and asynchronous BIP77 payjoins with resumable, persisted sessions.
  {% assign timestamp="55:33" %}

- **Silent payments sender plugin for Electrum:**
  Ali Sherief [released][sp electrum delving] a plugin that adds [silent
  payments][topic silent payments] (BIP352) sending (no receiving) to the
  Electrum desktop wallet for single-signature software wallets.
  {% assign timestamp="1:21:41" %}

- **Superscalar implementation announced:**
  8144225309 [announced][superscalar delving] an implementation of Superscalar,
  ZmnSCPxj's [channel factory][topic channel factories] design that puts many
  self-custodial Lightning clients behind a single onchain UTXO without a soft
  fork (see our [Superscalar deep dive podcast][superscalar deepdive]).
  {% assign timestamp="1:22:34" %}

- **Cofund multisig wallet announced:**
  Cofund [announced][cofund x] a self-custody [multisig][topic multisignature]
  wallet built on a policy-based [taproot][topic taproot] (P2TR) architecture
  with multi-vendor key registration and hierarchical multisig.
  {% assign timestamp="1:24:57" %}

- **Lexe adds human-readable addresses and LNURL-withdraw:**
  Lexe, a self-custodial Lightning wallet that runs each user's node in a
  trusted execution environment (TEE) so it stays online without the operator
  taking custody, [announced][lexe x] support for [BIP353][] human-readable
  bitcoin addresses (which also function as Lightning Addresses) and
  [LNURL-withdraw][topic lnurl]. {% assign timestamp="1:25:55" %}

- **Ledger Bitcoin app 2.5.0 adds human-readable policy descriptions:**
  Salvatore Ingala [announced][salvatoshi x] version 2.5.0 of the Ledger Bitcoin
  app, which displays a human-readable description for many [taproot][topic
  taproot] [miniscript][topic miniscript] and [multisig][topic multisignature]
  wallet policies during registration, instead of only the opaque
  [descriptor][topic descriptors] template. This makes it easier for a user to
  verify a policy and catch a malicious substitution (such as a 3-of-5 replaced
  with a 1-of-5) before registering it. {% assign timestamp="37:17" %}

- **Bark 0.5.0 released:**
  Second [released][second x] version 0.5.0 of Bark, its [Ark][topic ark]
  implementation, adding restoration of a wallet's full off-chain balance
  (VTXOs) from its mnemonic and support for Lightning receives to external Ark
  addresses, which enables non-custodial Lightning-address servers.
  {% assign timestamp="1:27:34" %}

- **Bitcoin-PIR for private UTXO queries:**
  Weikeng Chen [announced][bitcoinpir] Bitcoin-PIR, a private information
  retrieval (PIR) system that lets a light client check the UTXO set for its own
  addresses or scriptPubKeys without revealing to the server which ones it is
  interested in. It offers a choice of four PIR backends: DPF-PIR, HarmonyPIR,
  OnionPIRv2, and an ORAM scheme backed by a trusted execution environment
  (TEE). {% assign timestamp="1:28:16" %}

- **OP_TEMPLATEHASH Ark demonstration:**
  Steven Roose [launched][templatehash] a signet demonstration of Bark, Second's
  [Ark][topic ark] implementation, running against `OP_TEMPLATEHASH`, a
  taproot-native [CTV][topic op_checktemplateverify]-style [covenant][topic
  covenants] opcode. The demo is built from the `templatehash` branch of the
  Bark [repository][bark gitlab]. {% assign timestamp="1:29:44" %}

- **libshrincs formally verified hash-based signatures:**
  Jonas Nick [announced][libshrincs delving] libshrincs, a C implementation of
  [post-quantum][topic quantum resistance] hash-based signatures with a
  machine-checked security proof, written by remix7531.
  {% assign timestamp="1:34:00" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32784][] adds a `derivehdkey` wallet RPC command that derives
  an xpub and, optionally, an xprv from an [HD key][topic bip32] known to the
  wallet at a derivation path specified by the caller that contains at least
  one hardened step. This is useful for coordinating multisig wallets, in which
  each participant provides an xpub derived from a different path than the
  wallet's default single-signature [descriptors][topic descriptors]. Since
  hardened derivation requires private key material, the RPC is unavailable
  for watch-only wallets, and encrypted wallets must be unlocked.
  {% assign timestamp="1:38:08" %}

- [Bitcoin Core #35797][] allows [PSBT][topic psbt]v2 output metadata to be
  populated before any inputs are added when using the
  [`descriptorprocesspsbt`][topic descriptors] RPC (see [Newsletter
  #253][news253 descriptorpsbt]). Previously, `UpdatePSBTOutput` used the first
  input of the PSBT's unsigned transaction when traversing an output script,
  which could fail when a PSBTv2 contained outputs but no inputs. Now, it uses
  a temporary transaction containing a dummy input for metadata traversal
  without modifying the PSBT. {% assign timestamp="1:40:45" %}

- [Bitcoin Core #35531][] reduces the disk space used by `-txindex` option (see
  [Newsletter #161][news161 txindex]) by changing how transaction identifiers
  and positions are stored. Instead of storing each 32-byte txid and
  transaction disk position, the new format uses a five-byte prefix of a salted
  [SipHash][] of the txid and encodes the block sequence number and transaction
  offset in a compact six-byte suffix in the database key, with an empty value.
  Lookups scan all entries that share the prefix, determine each candidate's
  block location using the block index, and verify the full txid after reading
  the transaction from disk, safely handling collisions. In the PR author's
  mainnet tests, a fully rebuilt index shrank from about 66 GB to 26 GB, while
  indexing time fell from about 1 hour 50 minutes to 1 hour 19 minutes. While
  existing indexes remain readable, they must be rebuilt to reclaim space.
  After rebuilding, older Bitcoin Core releases cannot read the new entries
  and will also need to rebuild the index when downgrading.
  {% assign timestamp="1:44:14" %}

- [Bitcoin Core #35889][] improves the performance of the
  `gettxspendingprevout` RPC when checking large batches of outpoints.
  Previously, when a transaction that spent an outpoint was found in the
  mempool, the outpoint was erased from the middle of a vector while the
  mempool lock was held, forcing the remaining entries to shift. Now, the RPC
  scans each request once, stores the resolved results at their original
  indexes, and collects only the unresolved outpoints in a separate worklist
  for lookup through the optional `txospenderindex` (see [Newsletter
  #394][news394 txospender]). This makes the mempool pass linear instead of
  quadratic. According to the PR author's benchmarks, large mempool-only
  request batches completed about 9 times faster on a Ryzen 7 3700X and 31
  times faster on a Raspberry Pi 5. {% assign timestamp="1:48:44" %}

- [Bitcoin Core #35605][] deprecates the `removeprunedfunds` wallet RPC and
  disables it by default. Users who still require it must use the
  `-deprecatedrpc=removeprunedfunds` startup option. The RPC is scheduled for
  removal in the next major release. It is being removed because it exposes
  dangerous behavior without offering any known useful purpose: it can delete
  any transaction belonging to the wallet, including transactions that were
  not added through the related `importprunedfunds` RPC. It is also a
  maintenance burden; see [Newsletter #391][news391 removeprunedfunds] for
  coverage of a previous bug involving the RPC. {% assign timestamp="1:51:06" %}

- [Eclair #3352][] fixes missing [BOLT2][] channel-reserve checks when Eclair is
  the fundee of a single-funded channel, ensuring that neither party's dust
  limit exceeds the other party's channel reserve. Without these checks, a peer
  could spend its balance down to a reserve below the applicable dust limit,
  causing its output to be omitted from a commitment transaction and leaving
  it with no onchain funds at risk when publishing a revoked state. The PR also
  adds a configurable `eclair.channel.max-funding-satoshis` channel size limit,
  which defaults to 5 billion satoshis (50 BTC). This restores an upper bound
  after support for [wumbo channels][topic large channels] allowed channels
  above the previous protocol limit. {% assign timestamp="12:15" %}

- [Eclair #3351][] fixes several bugs in [on-the-fly funding][topic jit
  channels] (see [Newsletter #323][news323 fly]), a feature currently used by
  ACINQ's Lightning Service Provider (LSP) node in Phoenix Wallet. Specifically,
  after a restart, Eclair could fail to recognize that an [HTLC][topic htlc]
  had already been fully cross-signed because it only checked pending channel
  changes. This could potentially cause the same payment to be relayed twice.
  Eclair now also checks the current commitment states before relaying.
  Additionally, the PR resolves several timeout and on-chain failure paths to
  prevent Eclair from paying a downstream peer after failing the corresponding
  upstream HTLC. {% assign timestamp="20:31" %}

- [Eclair #3345][] limits the resources each peer can consume when requesting
  and synchronizing [channel announcements][topic channel announcements]
  through [BOLT7][] gossip queries. A configurable rate limit, set to 5 requests
  per second by default, applies per connection across `query_channel_range`
  and `query_short_channel_ids`. Eclair waits until a query's replies have been
  sent before accepting additional work to preserve transport backpressure.
  Eclair ignores duplicate short channel IDs (SCIDs) to prevent response
  amplification and rejects malformed or overlapping queries. It also limits
  memory usage during synchronization by capping each peer to 2,000 queued
  `query_short_channel_ids` requests. Similar resource management protections
  were previously added to LND (see Newsletters [#366][news366 lnd gossip] and
  [#417][news417 lnd gossip]). {% assign timestamp="23:16" %}

- [LND #8754][] implements an experimental outbound connection mode for the
  remote signer (see [Newsletter #172][news172 remote]), in which private-key
  operations are delegated to a separate signer server. The signer still does
  not independently validate the requests it receives, so it will sign any
  request the watch-only node sends. The new mode changes only how the two
  connect. Instead of the signer listening for an inbound connection, it
  initiates an outbound connection to a dedicated RPC listener on the watch-only
  node, allowing it to operate without accepting inbound connections. This setup
  was previously discussed in [Newsletter #326][news326 signer] in connection
  with deterministic macaroon generation. {% assign timestamp="1:54:23" %}

- [LND #11065][] adds an experimental `XCreateAccount` RPC and a corresponding
  `lncli wallet accounts create` command, to create a named, fully spendable
  account whose keys are derived from LND's wallet master key. This is different
  from the existing `ImportAccount` RPC (see [Newsletter #144][news144 lnd
  xpub]), which imports a watch-only xpub. [Coin selection][topic coin
  selection], balances, address derivation, and change can be scoped to the
  account, providing isolated pockets of funds within one wallet. The selected
  address type is permanent and defaults to [taproot][topic taproot].
  {% assign timestamp="1:55:47" %}

- [HWI #842][] adds a `registerdescriptor` command for registering a named
  [output script descriptor][topic descriptors] with supported hardware signing
  devices before signing transactions from that wallet. Implementations are
  added for BitBox02, Coldcard, Jade, and non-legacy Ledger devices. For devices
  that use [BIP388][] wallet policies (see [Newsletter #302][news302 bip388]),
  HWI converts the descriptor into a wallet descriptor template and key
  information vector, it also returns any device-specific registration data
  needed for later signing. {% assign timestamp="1:57:04" %}

{% include snippets/recap-ad.md when="2026-08-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="10331,2251,32784,35797,35531,35889,35605,3352,3351,3345,8754,11065,842" %}

[payjoin 1.0.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-1.0.0
[sp electrum delving]: https://delvingbitcoin.org/t/silent-payments-sender-bip352-plugin-for-electrum/2743
[superscalar delving]: https://delvingbitcoin.org/t/superscalar-an-implementation-report/2705
[superscalar deepdive]: /en/podcast/2024/10/31/
[cofund x]: https://x.com/getcofund/status/2085389177193972164
[lexe x]: https://x.com/lexeapp/status/2079245197817548964
[salvatoshi x]: https://x.com/salvatoshi/status/2086727660353261863
[second x]: https://x.com/secondhq/status/2084716752789991614
[bitcoinpir]: https://bitcoinpir.org
[templatehash]: https://templatehash.com
[bark gitlab]: https://gitlab.com/ark-bitcoin/bark
[libshrincs delving]: https://delvingbitcoin.org/t/libshrincs-a-c-implementation-with-a-machine-checked-security-proof/2795
[lnd vuln del]: https://delvingbitcoin.org/t/disclosure-lnd-doesnt-wait-for-enough-confirmations-when-closing-channels/2800
[lnd v20.0]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[rawtr ml]: https://groups.google.com/g/bitcoindev/c/CCZN_qQ5C1s
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[news389 lnd10331]: /en/newsletters/2026/01/23/#lnd-10331
[news253 descriptorpsbt]: /en/newsletters/2023/05/31/#bitcoin-core-25796
[news161 txindex]: /en/newsletters/2021/08/11/#bitcoin-core-pr-review-club
[news394 txospender]: /en/newsletters/2026/02/27/#bitcoin-core-24539
[news391 removeprunedfunds]: /en/newsletters/2026/02/06/#bitcoin-core-34358
[news323 fly]: /en/newsletters/2024/10/04/#eclair-2861
[news172 remote]: /en/newsletters/2021/10/27/#lnd-5689
[news326 signer]: /en/newsletters/2024/10/25/#lnd-9172
[news366 lnd gossip]: /en/newsletters/2025/08/08/#lnd-10097
[news417 lnd gossip]: /en/newsletters/2026/08/07/#lnd-10992
[news302 bip388]: /en/newsletters/2024/05/15/#bips-1389
[news144 lnd xpub]: /en/newsletters/2021/04/14/#lnd-5047
