---
title: 'Bitcoin Optech Newsletter #422'
permalink: /en/newsletters/2026/09/11/
name: 2026-09-11-newsletter
slug: 2026-09-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed protocol for probabilistic
coinjoins disguised as covert bets and summarizes benchmarks of a silent
payments indexing server against compact block filters for light clients.
Also included are our regular sections announcing new releases and release
candidates and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **A protocol for probabilistic coinjoin and covert betting**: Adam Gibson
  [posted][bab del] to Delving Bitcoin about Babilonia, a proposal for a
  new probabilistic [coinjoin][topic coinjoin] and covert betting protocol.
  The idea behind the proposal is to provide privacy-seeking behavior with
  plausible deniability. Instead of recognizable actions, which can be
  tracked, flagged, and criminalized, Gibson proposes a covert betting protocol,
  where users participate in order to break the common input ownership heuristic.
  The bet resembles an onchain coin flip where money changes hands,
  but to the outside looks like a normal payment.

  The protocol, described in a [paper][bab paper], works like this:
  - Alice and Bob provide their inputs to build a shared UTXO. They also sign
      a refund transaction, that gives the funds back to the owners in case of
      a long timeout, and a payout transaction, to settle the bet.

  - Alice generates two secret numbers `a_1` and `a_2`, picking one as her choice,
      and publishes the corresponding public keys `A_1` and `A_2`.

  - Bob picks one as his guess and constructs a public key `K` that can only be
      spent in case his and Alice's choices are the same.

  - The payout transaction sends the funds to an output spendable by `K`. Alice signs
      that transaction with a partial [adaptor signature][topic adaptor signatures].
      After Bob signs with his partial signature and the funding transaction confirms,
      Alice provides the adaptor's hidden secret out-of-band, letting Bob decrypt her
      chosen number. If he won, he completes and broadcasts the payout transaction
      to claim the funds.

  According to the author, multiple rounds of the protocol would statistically
  allow users to maintain their initial funds, minus fees, while improving their privacy.
  This is true on average, but may deviate for individual users.
  However, in the paper Gibson states that there is still no clear measure of the actual
  efficacy of the protocol. In a follow-up post, Gibson noted that a single bet
  leaks its size, since the winner's payout is an integer multiple of their
  contribution to the pot, and released a second version of the paper that
  splits each bet into several unequal sub-bets.

- **Update on silent payments light clients**: Rob Segers [posted][sp light ml]
  to the Bitcoin-Dev mailing list about updates to an older discussion on Delving
  Bitcoin (see [Newsletter #305][news305 sp light]). That discussion, that stalled
  in June 2024, was focused on providing specifications for
  [silent payments][topic silent payments] light clients and measuring performance
  of different ways to retrieve data from blocks.

  Segers ran an instance of [BlindBit Oracle v2][blindbit gh], an implementation of
  the [BIP352][] indexing server which drops filters completely and instead streams
  per-output data (txid, tweak, and 8-byte output prefix), and compared its performance
  against [BIP158 compact block filters][topic compact block filters] and
  [taproot][topic taproot]-only filters. The comparison was done on unsampled block data
  from taproot activation until block 965,089 (a total of 255,434 blocks).
  [Results][results gh] show that the BlindBit Oracle approach downloads about 2.1x
  as many bytes as a taproot-only filter plus the raw tweak data a filter client still
  needs, not counting the full block a filter client must fetch on each match,
  in exchange for no false positives and no per-match block fetches.

  Segers also noted that a light client currently cannot tell whether a server
  omitted a tweak for a block, which would silently lose the receiver money. His
  server publishes per-block commitments over the sorted tweak set and
  checkpoints them to nostr every six hours, making omissions attributable after
  the fact, although clients should still fetch the full block on a match.

  Finally, Segers noted that the new version of the BlindBit Oracle had drifted severely from
  the original specifications. Thus, the author provided a [convergence draft][sp light draft]
  which is up for discussion.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LDK v0.3-rc1][] is a release candidate for the next major version of this
  library for building LN-enabled wallets and applications. It adds [RBF][topic
  rbf] fee bumping for pending [splices][topic splicing] and support for adding
  and removing funds in the same splice. It also negotiates [anchor
  channels][topic anchor outputs] by default and requires applications to
  explicitly accept incoming channels. Upgrading invalidates previously issued
  [BOLT11][] invoices containing payment metadata. Developers should review the
  [API and backwards-compatibility changes][ldk 0.3 notes] before testing.

- [LDK v0.2.6][] is a security release of this library for building LN-enabled
  wallets and applications. It fixes a denial-of-service vulnerability in which
  an invalid payment, rejected after a second HTLC with the same payment hash
  was successfully forwarded, could leave the channel manager in a state that
  fails to deserialize. It also fixes a fee-inflation vulnerability that
  allowed a malicious counterparty to make a node over-allocate fees when
  contributing to a splice it initiated, with the excess going to the
  counterparty's output.

- [BTCPay Server 2.4.4][] is a security release of this self-hosted payment
  processor. It deletes legacy BitPay Basic-auth API keys and removes that
  authentication method, requiring affected integrations to migrate to
  supported authentication. Existing Greenfield API keys continue to work. The
  release also requires authorization to change invoice states, prevents
  restricted API keys from creating unrestricted keys, and includes the API-key
  storage changes described below. The accompanying Docker updates restrict
  host-management access, replace LND's shared default wallet password with
  unique passwords, and block LND's unauthenticated wallet-management routes at
  the reverse proxy. These LND changes address observed
  probing of LND's unauthenticated password-change endpoint on servers where
  operators had re-exposed the LND API after the 2.4.2 incident (see
  [Newsletter #418][news418 btcpay]). Operators who did so should remove that
  access. All server administrators are
  encouraged to upgrade and review the [breaking changes][btcpay 2.4.4
  announcement]. For the web-hosting billing plugin, migration requires
  upgrading to version 4.0.0 and replacing the legacy API key with a new
  Greenfield API key; see its [migration guide][btcpay billing migration].

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35949][] updates block template creation to follow [BIP54][]'s
  proposed mitigation for the Murch–Zawy [time warp][topic time warp] attack
  (see [Newsletter #316][news316 timewarp]). For the last block of each
  2,016-block difficulty period, the minimum timestamp must be at least that of
  the period's first block. Previously, if the node's clock was behind the
  period's first block, the proposed timestamp could also be earlier, provided
  it exceeded the median timestamp of the previous 11 blocks. The
  `getblocktemplate` RPC now adjusts both `mintime` and the proposed `curtime`
  when necessary, including when the node's clock is behind this minimum. This
  applies to all networks in preparation for the possible activation of the
  [consensus cleanup][topic consensus cleanup] soft fork, without changing
  consensus validation.

- [Bitcoin Core #34931][] fixes a bug where a UTXO database entry that could
  not be deserialized was treated as a missing coin. Consequently, a valid
  block spending the unreadable coin could be permanently marked as invalid,
  which would leave the affected node unable to follow the network's best
  chain. Bitcoin Core now distinguishes between these outcomes and aborts with
  a database error when deserialization fails. An additional coin serialization
  bug or memory corruption before storage would be required for this bug to
  occur, since LevelDB's checksums already detect ordinary disk corruption.

- [Bitcoin Core #36048][] fixes command injection through the `-walletnotify`
  configuration option (see [Newsletter #86][news86 walletnotify]) on
  non-Windows systems. An authenticated RPC caller could create a wallet with a
  crafted name using the `createwallet` command. If the operator configured the
  `-walletnotify` option with the wallet name placeholder, `%w`, subsequent
  transaction notifications for that wallet could execute commands embedded in
  the wallet name on the node's operating system. Although the wallet name was
  shell escaped, the substitution function interpreted the regular expression
  replacement characters within it, breaking the shell quoting. Placeholder
  substitution now treats wallet names literally, preserving the shell
  escaping. This behavior was introduced in Bitcoin Core 24.0.

- [Bitcoin Core #36123][] and [#36169][bitcoin core #36169] fix unbounded
  memory growth and Windows port sharing in the replacement HTTP server (see
  Newsletters [#411][news411 http] and [#420][news420 http]). The first
  prevents a client from growing the server's per-connection receive buffer
  indefinitely by sending requests faster than the server can process them.
  Socket reads now pause when
  buffered requests await processing, allowing TCP backpressure to slow the
  sender. The second PR reserves the address and port exclusively for Windows
  listening sockets. Previously, another local process could bind the same
  endpoint and potentially receive connections containing RPC credentials. In
  one reviewer's test, sixteen REST connections increased memory usage by 3.2
  GB before the buffering fix and only 3 MB afterward over 90 seconds.

- [Bitcoin Core #36176][] fixes an error that occurs when a wallet operation
  attempts to save its load-on-startup preference while the dynamic settings
  file is disabled with the `-nosettings` option. When creating, loading, or
  unloading a wallet, users can also specify whether it should be loaded
  automatically at the next startup (see [Newsletter #111][news111 load]).
  Previously, attempting to save this preference with settings disabled
  produced an RPC error or caused Bitcoin-Qt to crash with an uncaught
  exception after the wallet state had already changed. Now, the operation
  completes with a warning that the preference could not be saved.

- [Core Lightning #9434][] and [#9473][core lightning #9473] fix crashes
  involving persistent routing preferences in `askrene` (see [Newsletter
  #316][news316 askrene]). `askrene` stores routing information in layers,
  which can include biases favoring or discouraging particular nodes or
  channels (see [Newsletter #381][news381 biases]). The first PR fixes a
  startup crash when restoring a node bias with a description from a persistent
  layer. Restoring the incoming and outgoing bias values reused the description
  buffer after it had been freed, causing `askrene` to crash and `lightningd`
  to shut down because it treats `askrene` as an important plugin. The second
  fixes a crash when removing channel or node biases by resetting them to zero.
  Previously, the zero-valued bias record was removed from memory before being
  saved, causing a null pointer dereference. Now, the zero value is saved
  before the record is removed from memory, preventing the previous bias from
  being restored after a restart.

- [LND #11061][] continues the implementation of [BOLT12 offers][topic offers]
  by adding support for signing and verifying invoice requests and invoices
  using [BIP340][] [Schnorr signatures][topic schnorr signatures]. The
  signatures commit to a Merkle root constructed from the messages' signed TLV
  records. Read validators now reject invalid signatures rather than only
  checking that a signature is present. This builds on the invoice request
  codec described in [Newsletter #413][news413 bolt12].

- [LND #11125][] allows callers to reserve wallet UTXOs until the transaction
  spending them reaches a chosen number of confirmations. Previously,
  reservations either expired after a specified time or were removed at the
  first confirmation of the spending transaction. Slow confirmations could
  therefore outlast the reservation, while a reorg could leave the inputs
  unreserved. Now, the `LeaseOutput` (see [Newsletter #182][news182
  leaseoutput]) and `FundPsbt` RPCs accept a confirmation count, allowing
  reservations to remain active across reorgs and ignore time-based expiration.
  Callers can still release reservations explicitly, which is required if a
  transaction is abandoned. Existing timed reservations remain the default.

- [LND #11064][] makes channel opening messages explicitly specify the channel
  type, as required by [BOLT2][]. LND now includes `channel_type` in
  `open_channel`, echoes it in `accept_channel`, and rejects incoming
  `open_channel` messages that omit it. RPC callers can still omit a type, in
  which case LND chooses one based on both peers' supported channel types.

- [BTCPay Server #7561][] and [#7542][btcpay server #7542] update how API keys
  are stored and handled. The first PR stores hashes and derived key IDs
  instead of storing plaintext credentials in the database indefinitely. A
  cleanup job clears newly created plaintext secrets once they are more than
  five minutes old. After migration, existing Greenfield keys continue to
  authenticate, but their secrets can no longer be retrieved from the server.
  The upgrade also deletes legacy BitPay-like Basic-auth API keys and removes
  that authentication method. Revoking a specified API key now requires its ID
  instead of its secret and key responses include an `id` field. The second PR
  removes the newly generated API key from the redirect URL to the API key
  management page, preventing the URL from exposing credentials through browser
  history or request logs.

- [BTCPay Server #7559][] extends Lightning payment monitoring beyond a BTCPay
  invoice's payment deadline, through its configured monitoring period.
  Previously, a customer could pay a Lightning invoice after the BTCPay invoice
  expired, but BTCPay would not record the payment. Now, the listener uses the
  existing monitoring period, allowing late payments received during that
  period to be recorded. This does not change the payment deadline for either
  invoice or detect payments indefinitely.

{% include snippets/recap-ad.md when="2026-09-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35949,34931,36048,36123,36169,36176,9434,9473,11061,11125,11064,7561,7542,7559" %}

[bab del]: https://delvingbitcoin.org/t/babilonia-probabilistic-coinjoin-and-covert-betting/2704
[bab paper]: https://github.com/AdamISZ/babilonia-paper
[sp light ml]: https://groups.google.com/g/bitcoindev/c/qqDYHnnoM7k
[news305 sp light]: /en/newsletters/2024/05/31/#light-client-protocol-for-silent-payments
[blindbit gh]: https://github.com/setavenger/blindbit-oracle
[results gh]: https://github.com/bitsagarob/silentpayments-measurements
[sp light draft]: https://github.com/bitsagarob/silentpayments-measurements/blob/master/LIGHT-CLIENT-PROTOCOL-DRAFT.md

[LDK v0.3-rc1]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc1
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc1/CHANGELOG.md
[LDK v0.2.6]: https://github.com/lightningdevkit/rust-lightning/blob/v0.2.6/CHANGELOG.md
[BTCPay Server 2.4.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.4
[btcpay 2.4.4 announcement]: https://blog.btcpayserver.org/btcpay-server-2-4-4/
[btcpay billing migration]: https://github.com/btcpayserver/whmcs-plugin/blob/master/GUIDE.md#upgrade-from-v3x-to-v4x
[news418 btcpay]: /en/newsletters/2026/08/14/#btcpay-server-2-4-2
[news316 timewarp]: /en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[news86 walletnotify]: /en/newsletters/2020/02/26/#bitcoin-core-13339
[news411 http]: /en/newsletters/2026/06/26/#bitcoin-core-35182
[news420 http]: /en/newsletters/2026/08/28/#bitcoin-core-35730
[news111 load]: /en/newsletters/2020/08/19/#bitcoin-core-15937
[news316 askrene]: /en/newsletters/2024/08/16/#core-lightning-7517
[news381 biases]: /en/newsletters/2025/11/21/#core-lightning-8608
[news413 bolt12]: /en/newsletters/2026/07/10/#lnd-10832
[news182 leaseoutput]: /en/newsletters/2022/01/12/#lnd-5964
