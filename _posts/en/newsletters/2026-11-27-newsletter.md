---
title: 'Bitcoin Optech Newsletter #433'
permalink: /en/newsletters/2026/11/27/
name: 2026-11-27-newsletter
slug: 2026-11-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability affecting older versions of
Bitcoin Core, summarizes the disclosure of a denial-of-service vulnerability in
Core Lightning, and relays discussion about refreshing the BIP editor team.
Also included are our regular sections with selected questions and answers
from the Bitcoin Stack Exchange, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Disclosure of a medium-severity vulnerability in Bitcoin Core:** Greg
  Sanders [posted][sanders adv ml] to the Bitcoin-Dev mailing list a Bitcoin
  Core [security advisory][core orphan inv stall] for a vulnerability that
  allowed a peer to temporarily stop a node from processing blocks and
  transactions. It affects all 29.x releases, 30.x before [30.5][core 30.5],
  and 31.x before [31.3][core 31.3]. Version 32.1 already includes the fix.
  The 29.x series has reached end of life and will not receive a fix, so its
  users should upgrade to a maintained release.

  Bitcoin Core stores transactions whose parents it has not yet seen, called
  orphans. Since 29.0, each time a peer announced the wtxid of a stored
  orphan, the node checked every parent of that orphan against its mempool
  and its filters of recently seen transactions. An `inv` message can contain
  up to 50,000 announcements, and duplicates were not skipped. An attacker
  could send an orphan with thousands of missing parents, followed by `inv`
  messages repeating its wtxid 50,000 times. According to the advisory, each
  such message stalled the node for over a dozen seconds, during which it
  processed no messages from other peers, including blocks. [Bitcoin Core
  #35878][] now processes each announced transaction only once per `inv`
  message.

  The vulnerability was discovered in July by Project Loupe, [responsibly
  disclosed][topic responsible disclosures] by Sanders, and independently
  reported by stutxo in August. Because it was classified as easily
  discoverable (see [Newsletter #429][news429 policy]), the advisory was
  published alongside 30.5 and 31.3.

- **Disclosure of a DoS vulnerability in CLN:** Nishant Bansal [posted][cln
  vuln del] to Delving Bitcoin the [responsible disclosure][topic responsible
  disclosures] of a denial-of-service (DoS) vulnerability in Core Lightning
  (CLN) affecting versions [0.12.0][cln 0.12.0] (August 2022) through
  [26.06.7][cln 26.06.7] (August 2026), which allowed an attacker to repeatedly
  crash a victim's node. The bug gave an attacker no direct access to funds,
  but continuously crashing a node could put its channel funds at risk. Users
  are recommended to upgrade to the latest version immediately. The
  vulnerability was fixed in CLN version 26.06.8 (see [Newsletter #424][news424
  cln rel]).

  The vulnerability was related to more than one v1 channel sharing the same
  `channel_id`. A malicious peer could open a channel by providing another
  channel's funding outpoint. Since `channel_id` is derived from that outpoint,
  according to [BOLT2][], two channels would thus have matching IDs. CLN runs a
  `channeld` subdaemon for each channel, while `connectd` routes messages to
  the correct subdaemon based on their `channel_id`. Since CLN assumes the
  uniqueness of `channel_id`, collisions led the node to crash.

  There were two ways a malicious peer could crash the node, one during
  reconnection, detected using [smite][gh smite], a snapshot fuzzing framework
  for Lightning Network implementations, and the other on channel closure,
  found by developer Eugene Siegel:

  - When a peer reconnects, the main daemon, `lightningd`, starts the
    `channeld` subdaemons and hands them to `connectd`. On the first
    `channel_id` lookup everything would work fine. However, on the second
    request an `assert` proving that the connection was not already active
    would abort `connectd`, taking down the node. Since both channels were
    still present in the database after a restart, a new reconnection attempt
    would crash the node again.

  - CLN keeps in memory previously closed channels in a hash table keyed by
    `channel_id`. An attacker closing a channel with the same `channel_id` as
    one already closed would trigger the failure of an assertion checking that
    no duplicates were added to the map. Unlike the first variant, the node
    then crashes on every restart without further action from the attacker,
    until it is upgraded. This specific attack vector affected only versions
    [25.05][cln 25.05] and higher.

- **Discussion on refreshing BIP editors:** Mark "Murch" Erhardt
  [posted][erhardt bip editors] to the Bitcoin-Dev mailing list to resurface
  his April proposal to refresh the BIP editor team (see Newsletters
  [#299][news299 bip editors] and [#418][news418 bip editors] for previous
  coverage of the editor set), citing a backlog of submissions awaiting
  editor review in the [BIPs repository][bips repo]. He described two
  options, adding active editors or lowering standards so that editors check
  only the format of new submissions, and strongly preferred refreshing the
  team to three editors who all contribute regularly. He added that
  volunteers wary of an open-ended commitment could offer to serve a limited
  term, such as 12 to 24 months. Following the post, several people
  volunteered, and current editor Olaoluwa Osuntokun indicated he plans to
  step down at the end of the year. Discussion was ongoing at the time of
  writing.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why does a policy that is valid with rust-miniscript throw a compile error on the sipa site?]({{bse}}131089)
  Pieter Wuille explains that his [miniscript][topic miniscript] policy
  compiler site accepts symbolic names only for keys, not hash preimages, and
  does not allow malleable scripts (see
  [Newsletter #230][news230 malleable]). One branch of the asker's policy
  could be satisfied by just revealing a preimage after 144 blocks, which is
  inherently malleable because it involves no signatures.

- [How can I repair corrupted undo data (rev*.dat checksum mismatch) without a full reindex?]({{bse}}131107)
  P22 describes rebuilding damaged undo records on a node with `-txindex`. A
  block's undo data is the list of outputs its inputs spent, so each record
  can be reconstructed byte for byte and written back in place.
  `-reindex-chainstate` does not help because Bitcoin Core only writes undo
  data for a block that has no undo position yet.

- [Why does no Bitcoin opcode push data about the spending transaction onto the stack?]({{bse}}131130)
  LearnBitcoin answers that a soft fork redefining an `OP_NOP` opcode can
  only make scripts fail, since leaving a value on the stack would cause old
  and new nodes to disagree about validity. That is why the proposed
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] only verifies.
  [Tapscript][topic tapscript] added `OP_SUCCESSx` opcodes that may also
  write to the stack (see [Newsletter #416][news416 success]), and the
  [covenant][topic covenants] proposals `OP_TXHASH` and `OP_TEMPLATEHASH` are
  defined on them.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 31.3][] and [30.5][Bitcoin Core 30.5] are maintenance releases
  of the predominant full node implementation. Both fix the DoS vulnerability
  described above.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #36387][] deprecates the `encryptwallet` RPC, which encrypts an
  existing unencrypted wallet. The RPC now requires Bitcoin Core to be started
  with the `-deprecatedrpc=encryptwallet` flag and is scheduled for removal in
  a future major release. Encrypting an existing wallet cannot guarantee
  removal of unencrypted private-key material from disk. It can also generate a
  new [seed][topic bip32], so earlier backups may not be able to recover funds
  sent to newly generated addresses. Users who want to encrypt their wallet
  should instead create an encrypted wallet by supplying the `passphrase`
  argument to `createwallet` (see [Newsletter #47][news47 createwallet]).
  Existing encrypted wallets remain supported.

- [BIPs #2301][] adds draft [BIP333][], which allows peers using [v2 P2P
  transport][topic v2 p2p transport] to choose their own one-byte message type
  IDs for outgoing messages (see [Newsletter #426][news426 aliases]).
  [BIP324][] currently assigns one-byte IDs through a fixed table, requiring
  coordination to add new entries. The proposed `set324alias` message enables
  each peer to announce its own aliases after the other peer advertises support
  through [BIP434][].

- [Core Lightning #9718][] fixes a bug where a failed Bitcoin Core `gettxout`
  RPC call could be misinterpreted as an output being spent or absent. This
  could occur when Bitcoin Core was unreachable or still starting up. During
  externally funded channel opening (see [Newsletter #51][news51 external
  funding]), the `fundchannel_cancel` RPC could forget a channel whose funding
  transaction had already been broadcast. The `bcli` plugin now retries
  temporary connection and startup failures, and reports unsuccessful calls as
  errors. Only a successful response indicating no unspent output at the
  requested outpoint is considered evidence that an output is unavailable.

- [LDK #5663][] fixes a potential loss of forwarded funds when saving channel
  recovery state asynchronously. After an incoming channel peer force closes,
  an update can record an [HTLC][topic htlc] preimage in memory but return an
  error when attempting to change the closed channel's commitment state. LDK
  also broadcasts a claim transaction for the incoming HTLC. Previously, LDK
  began persisting this information to disk, but it did not track the write as
  pending due to the error. A separate write recording the channel closure
  could finish first, causing LDK to incorrectly consider the preimage as
  safely saved and allow the outgoing channel to discard its copy. If the node
  crashed before the preimage was saved and if the claim transaction failed to
  confirm before expiry, it could lose the incoming payment after paying the
  outgoing HTLC. LDK now persists and tracks these updates until their writes
  complete.

- [LDK #5678][] fixes the [fee target][topic fee estimation] used for [penalty
  transactions][topic ln-penalty] when a peer broadcasts a revoked commitment
  transaction. Previously, LDK would only select an urgent target if the latest
  commitments contained pending [HTLCs][topic htlc] (see [Newsletter
  #319][news319 targets]), without separately checking whether the onchain
  commitment was revoked. Under sustained fee pressure, the penalty could
  remain unconfirmed despite [fee bumps][topic rbf] until the peer's
  [timelock][topic timelocks] expired, enabling the peer to spend the revoked
  funds. LDK now uses its urgent onchain sweep target whenever it identifies an
  onchain counterparty commitment as revoked.

- [LND #11607][] fixes weight estimates for [penalty transactions][topic
  ln-penalty] spending [HTLC][topic htlc] outputs from revoked counterparty
  commitments. Previously, LND correctly built the penalty witness but
  estimated its size as if it was spending an HTLC from its own commitment
  transaction. The penalty actually spent an output from the peer's commitment,
  whose HTLC script could be larger, causing the weight to be underestimated.
  When targeting the [minimum relay feerate][topic default minimum transaction
  relay feerates], this could produce insufficient fees and mempool rejection.
  LND now matches estimates to the scripts being spent, including the
  additional script bytes used by [anchor channels][topic anchor outputs].

- [LND #11247][] fixes historical chain scans that could miss confirmations or
  spends, leaving channels stuck opening or closing. LND shares scans between
  requests watching the same transaction or output. Previously, if the first
  request began scanning too late, a later request specifying an earlier
  starting block height could reuse that scan without checking for earlier
  missing blocks. Cached starting heights could preserve this omission across
  restarts. LND now scans missing ranges and records their starting heights
  alongside cached progress. This complements the cache-key fix in [Newsletter
  #431][news431 hints]. Channels that remain stuck after upgrading may require
  restarting LND once with the `--height-hint-cache-query-disable` option and
  then removing it after recovery.

- [LND #11268][] fixes a persistence bug that could cause an unnecessary force
  close after a disconnection. This could occur when the local initiator node
  sent a fee update on a channel where it had not yet revoked a commitment and
  received the peer's acknowledgment without saving the change to disk. If the
  connection then drops before LND receives the peer's next commitment
  signature, it may reconstruct the commitment with the old fee and reject the
  valid signature. The fix removes an early return in the database update that
  skipped saving the acknowledged local updates.

- [Rust Bitcoin #7160][] adds [testnet5][topic testnet] ([BIP95][]) support,
  including the `TestnetVersion::V5` value, genesis block, chain identifier,
  proof-of-work parameters, and network message magic. It also updates network
  parsing and address handling to recognize testnet5. The genesis parameters
  were covered in [Newsletter #432][news432 testnet5].

- [BTCPay Server #7846][] adds support for connecting to Core Lightning 24.11
  or later through its built-in `clnrest` service (see [Newsletter
  #262][news262 clnrest]) using runes, credentials that restrict permitted
  commands. This allows a connection to create and monitor invoices without
  permission to send payments. Existing direct connections to Core Lightning's
  RPC interface remain supported. The dependency update also changes
  certificate handling: the `allowinsecure`, `certthumbprint`, and
  `certfilepath` connection-string options are now ignored. Operators using
  external Lightning nodes with self-signed certificates must configure trust
  in the environment running BTCPay Server.

- [BTCPay Server #7850][] and [#7851][btcpay server #7851] fix incorrect
  Lightning payout states. The first updates the LNDhub adapter to preserve
  payment errors returned in HTTP 200 responses. Previously, these could be
  discarded and a failed payout reported as paid. Known errors proving that the
  current call sent nothing are now reported as failures; ambiguous outcomes
  remain unknown. The second marks a payout complete when a payment lookup
  confirms success after the send operation returned an error, preserving the
  [payment proof][topic proof of payment].

{% include snippets/recap-ad.md when="2026-12-01 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35878,36387,2301,9718,5663,5678,11607,11247,11268,7160,7846,7850,7851" %}
[sanders adv ml]: https://groups.google.com/g/bitcoindev/c/lFzWO5W9pBE
[core orphan inv stall]: https://bitcoincore.org/en/2026/11/20/disclose-orphan-inv-stall/
[core 31.3]: https://bitcoincore.org/en/2026/11/20/release-31.3/
[core 30.5]: https://bitcoincore.org/en/2026/11/20/release-30.5/
[news429 policy]: /en/newsletters/2026/10/30/#bitcoin-core-security-policy-update
[cln vuln del]: https://delvingbitcoin.org/t/disclosure-dos-vulnerability-fixed-in-core-lightning-v26-06-8/3072
[cln 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[cln 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[news424 cln rel]: /en/newsletters/2026/09/25/#core-lightning-26-06-8
[gh smite]: https://github.com/lnfuzz/smite
[cln 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[erhardt bip editors]: https://groups.google.com/g/bitcoindev/c/zCmHEGbCADQ/m/0nXgyto-AQAJ
[news299 bip editors]: /en/newsletters/2024/04/24/#bip-editors-update
[news418 bip editors]: /en/newsletters/2026/08/14/#bips-2248
[news230 malleable]: /en/newsletters/2022/12/14/#when-is-a-miniscript-solution-malleable
[news416 success]: /en/newsletters/2026/07/31/#was-the-op-successx-reservation-in-bip342-designed-with-specific-opcode-families-in-mind
[Bitcoin Core 31.3]: https://bitcoincore.org/bin/bitcoin-core-31.3/
[Bitcoin Core 30.5]: https://bitcoincore.org/bin/bitcoin-core-30.5/
[LDK #5663]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5663
[LDK #5678]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5678
[news47 createwallet]: /en/newsletters/2019/05/21/#bitcoin-core-15006
[news426 aliases]: /en/newsletters/2026/10/09/#dynamic-one-byte-message-type-ids-for-bip324
[news51 external funding]: /en/newsletters/2019/06/19/#c-lightning-2672
[news319 targets]: /en/newsletters/2024/09/06/#ldk-3268
[news431 hints]: /en/newsletters/2026/11/13/#lnd-11481
[news432 testnet5]: /en/newsletters/2026/11/20/#bips-2356
[news262 clnrest]: /en/newsletters/2023/08/02/#core-lightning-6389
