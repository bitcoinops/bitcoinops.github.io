---
title: 'Bitcoin Optech Newsletter #426'
permalink: /en/newsletters/2026/10/09/
name: 2026-10-09-newsletter
slug: 2026-10-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a draft BIP for letting peers choose their own
one-byte message type IDs over the version 2 P2P transport, summarizes a
discussion about whether BIPs should include their number in tagged hash
tags, and describes a proposed metaprotocol for private onchain transfers
that requires no consensus changes. Also included are our regular sections
announcing new releases and release candidates and describing notable changes
to popular Bitcoin infrastructure software.

## News

- **Dynamic one-byte message type IDs for BIP324:** Anthony Towns [posted][towns
  set324alias] to the Bitcoin-Dev mailing list a draft BIP that lets each peer
  choose its own one-byte message type IDs for the messages it sends over the
  [v2 P2P transport][topic v2 p2p transport]. [BIP324][] assigns one-byte IDs
  from a fixed table, so any new message needs a globally coordinated entry (see
  [Newsletter #392][news392 bip324 ids]) or must use its full 12-byte name. With
  a new `set324alias` message, a node announces its own aliases at connection
  time, so new messages can be deployed and experimented with at the P2P layer
  without that coordination. Towns also [noted][towns set324alias savings] that
  the space saving ranges from up to 66% on a connection carrying only pings to
  about 5% on a typical connection, and is zero until new messages without an
  existing one-byte ID are deployed.

- **Discussion of conventions for tagged hash tags in BIPs:** Fabian Jahr
  [posted][jahr tagged hash] to the Bitcoin-Dev mailing list asking whether
  BIPs that use [BIP340][] tagged hashes should include the BIP number in the
  tag. BIPs 324, 340, 352, 374, and 445 do, while BIP327 and BIP341 use
  descriptive names such as "TapLeaf". A number guarantees uniqueness, but
  changing a draft's tags when a number is assigned breaks existing
  implementations and test vectors, which Jahr found after switching his
  [DahLIAS][news415 dahlias] draft (BIP459) to the numbered form. Sjors
  Provoost [replied][provoost tagged hash] that BIP138 included its number
  and regenerating its test vectors was a minor cost.

- **Proposal for onchain, private bitcoin transfers with no consensus changes**:
  Misha Komarov [posted][shield del] to Delving Bitcoin about a proposal for a
  new metaprotocol built on top of Bitcoin, called Shielded Bitcoin, that would
  enable private transfers while requiring no changes in consensus. Komarov,
  together with Clara Shikhelman and Aleksei Moskvin, has recently published a
  full [paper][shield paper] describing the protocol.

  The goal of the proposed metaprotocol is to transfer bitcoin privately,
  revealing neither the amount transferred nor the counterparties involved in
  the transaction. It aims to do so without requiring trusted operators,
  interactivity, or liveness dependencies. Shielded Bitcoin requires a way to
  peg in and out of the metaprotocol. The process will be detailed in a
  companion paper that should be released soon, but Komarov noted that it will
  be based on a witness encryption scheme called PIPEs (see [Newsletter
  #393][news393 pipes]).

  Shielded Bitcoin transfers are based on an ownership object called a note,
  which plays a similar role as a Bitcoin UTXO. Notes are encrypted records that
  store information such as amount and recipient's key material. When a transfer
  is made, Alice publishes a Bitcoin transaction containing the new encrypted
  notes, a unique number, called a nullifier, for each note being spent, and a
  proof that states that the notes exist, she is allowed to spend them, and the
  amounts in input are equal to the ones in output. These proofs are verified by
  an external program, called an indexer, that makes sure that none of the notes
  have been spent before. If the proof stands, the new notes are added to the
  list and the nullifiers are recorded as used. Anyone can run an indexer, thus
  there is no need to rely on a centralized service to validate proofs.

  The metaprotocol is non-custodial. A wallet derives different keys from a
  single seed, each with its own specific task, such as a spending key, a
  read-only key for incoming transfers, and one for the outgoing ones. Only a
  valid spending key grants the authority to transfer a note and no third party,
  such as miners, indexers, or an outside observer, can steal the funds.

  Komarov also provided an overview of what an external observer can see, such
  as how many notes were created, fees, size and timing of the data posted, and
  that a shielded transfer happened. Komarov described limitations and
  trade-offs, such as the need for a one-time setup ceremony, which makes
  security claims valid when at least one honest party is involved, and the fact
  that entering and exiting the protocol leaves a visible trace. Komarov also
  compared the design with other proposed onchain privacy protocols, such as
  [coinjoins][topic coinjoin] and [payjoins][topic payjoin], Shielded CSV (now
  Glass Coins), which uses an approach based on [client-side validation][topic
  client-side validation], and Zcash, the closest design, which uses its own
  chain.

  In the discussion that followed, ZmnSCPxj noted that an external service could
  reduce the data a resource-constrained device must scan to recover funds, at
  the cost of Electrum-like privacy loss if the service is given a viewing key.
  He also asked whether unilateral peg-outs require an SPV proof expressed as a
  condition of the witness encryption scheme. Co-author Clara Shikhelman replied
  that peg-outs use fixed denominations and that all the information about
  peg-outs will be detailed in the upcoming paper.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 32.0rc3][] is a release candidate for the next major version of
  the predominant full node implementation. A [testing guide][bcc32 testing] is
  available.

- [Core Lightning 26.06.9][] is a security release of this popular LN node
  implementation. It fixes vulnerabilities in channel reestablishment,
  [splicing][topic splicing], [HTLC][topic htlc] handling, and access controls,
  among others. It also fixes a regression in 26.06.8 that could delay channel
  traffic by incorrectly throttling peers for ordinary [gossip][topic channel
  announcements], pings, and [onion messages][topic onion messages]. Although
  tests for the security fixes are temporarily withheld to make it harder to
  turn them into working exploits, the source code is available immediately. The
  project strongly recommends upgrading.

- [LDK v0.3-rc3][] is the third release candidate for the next major version of
  this library for building LN-enabled wallets and applications. It adds
  [RBF][topic rbf] fee bumping for pending [splices][topic splicing] and
  support for adding and removing funds in the same splice. It also negotiates
  [anchor channels][topic anchor outputs] by default and requires applications
  to explicitly accept incoming channels. Upgrading invalidates previously
  issued [BOLT11][] invoices containing payment metadata. Developers should
  review the [API and backwards-compatibility changes][ldk 0.3 notes] before
  testing.

- [LDK v0.2.7][] and [v0.1.13][ldk v0.1.13] are security releases for the 0.2
  and 0.1 branches of this library for building LN-enabled wallets and
  applications. Both include the channel reestablishment funds-theft fix
  described below and a DoS fix for Electrum-based synchronization. Version
  0.2.7 additionally includes the [LSPS2][BLIP52] amount validation and stale
  channel state fixes described below. Version 0.1.13 also fixes a channel
  manager deserialization failure triggered by invalid [HTLCs][topic htlc],
  previously fixed in 0.2.6.

- [BTCPay Server 2.4.5][] is a security release of this self-hosted payment
  processor. It blocks private-network destinations by default for outbound
  HTTP requests used by Lightning connections, [LNURL][topic lnurl], invoice
  notifications, and webhooks to prevent server-side request forgery. It also
  tightens invoice and refund permissions and speeds up invoice creation.
  Accompanying Docker changes make Tor opt-in, including for existing
  deployments, and remove several unmaintained integrations. Administrators are
  encouraged to upgrade and review the [deployment changes][btcpay 2.4.5
  announcement].

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #36277][] fixes a potential [transaction origin privacy][topic
  transaction origin privacy] leak in the experimental, opt-in private
  broadcasting feature (see Newsletters [#388][news388 private broadcast] and
  [#425][news425 private broadcast]). Previously, receiving a transaction back
  through the network canceled the remaining initial private broadcast
  attempts. An attacker controlling one of the private-broadcast peers could
  exploit this behavior by delaying its request on that connection while
  relaying the transaction back to the suspected
  originating node through a separate connection. If the node then closed the
  pending private connection instead of responding to the request, the attacker
  could infer that the node had originated the transaction. Bitcoin Core now
  completes all three initial private broadcast attempts over Tor or I2P even
  if the transaction has already propagated, while allowing subsequent retries
  to stop as appropriate.

- [Bitcoin Core #36365][] fixes two issues with the [mempool-based fee
  estimator][topic fee estimation] (see [Newsletter #420][news420 fee
  estimation]). Previously, the combined estimator returned an error if the
  mempool estimator was unavailable, even if the existing confirmation-based
  estimator had a valid estimate. Now, it falls back to that estimate while
  still selecting the lower of the two when both are available. The PR also
  prevents the mempool-based estimator from being used immediately after a
  restart if the mempool fails to load. Previously, saved health statistics
  could cause an empty mempool to be considered healthy, resulting in
  artificially low fee estimates. It also renames the `estimatesmartfee` RPC's
  default `fee_rate_estimator` value from `none` to `auto` and rejects
  unrecognized values.

- [Bitcoin Core #36338][] fixes a bug in its [BIP352][] [silent payments][topic
  silent payments] implementation that could cause a wallet to miss payments
  when a transaction contains a modified, yet consensus-valid P2PKH input (see
  [Newsletter #425][news425 silent payments]). An attacker could insert an
  invalid signature and a conditional branch containing a different public key
  into the input's `scriptSig` without invalidating the transaction.
  Previously, Bitcoin Core evaluated `scriptSig` using a dummy signature
  checker that accepted the invalid signature, executed the branch, and
  extracted the wrong public key, potentially causing the scanner to miss a
  payment. The fix now searches `scriptSig` for a valid compressed public key
  whose HASH160 matches the hash committed to in the spent output. This
  implementation is not yet integrated into the wallet.

- [Bitcoin Core #32895][] prepares the wallet for future automatic upgrades by
  recording the version and supported features of the last client that opened
  it. Without this tracking, upgrading a wallet, reopening it with an older
  version of Bitcoin Core, and then upgrading again could result in a
  combination of old and new wallet records. For example, the older version
  might create new records in the old format, but a newer version would assume
  that the wallet had already been upgraded and skip the migration. The new
  metadata will enable future versions to identify these
  upgrade-downgrade-upgrade scenarios and perform the necessary migrations. It
  separately records the features of the last client to decrypt the wallet,
  since some upgrades require access to private keys.

- [Core Lightning #9582][] ports 77 commits containing security and reliability
  fixes from v26.06.8 (see [Newsletter #424][news424 cln release]) to the
  master branch. One fix prevents force closes after a completed [splice][topic
  splicing] from broadcasting an outdated commitment transaction that may have
  been revoked by subsequent channel updates, allowing the counterparty to
  claim funds as a [penalty][topic ln-penalty]. Another fixes onchain
  [HTLC][topic htlc] resolution by matching outputs based on both script and
  amount. Previously, HTLCs with the same payment hash and expiry but different
  amounts could be confused, which could cause CLN to fail an incoming HTLC
  while the corresponding outgoing HTLC remained claimable onchain. The PR also
  fixes a privilege escalation vulnerability in which a caller authorized to
  use the `makesecret` RPC could derive the master rune's cryptographic secret
  and forge unrestricted RPC authorization tokens. CLN now blocks the
  derivation of this reserved secret. Additional fixes address [gossip][topic
  channel announcements] related DoS risks, [dual-funding][topic dual funding]
  and splice-[RBF][topic rbf] handling, [anchor][topic anchor outputs] fee
  calculations, [multipart-payment][topic multipath payments] processing, rune
  validation and blacklisting, [BOLT11][] and [BOLT12][topic offers] message
  handling, onion routing, and REST API resource-exhaustion vulnerabilities.

- [Eclair #3390][] and [#3388][eclair #3388] close gaps in the protections
  against excessive mining fees during [dual funding][topic dual funding] and
  [splicing][topic splicing] (see [Newsletter #423][news423 eclair fees]). The
  first protects against a compromised Bitcoin Core backend, which builds
  transactions while Eclair holds the keys, that could misreport fees or
  manipulate transaction outputs, causing Eclair to sign transactions that pay
  more than intended. Eclair now independently verifies actual fees and ensures
  that reconstructed funding transactions respect the expected amounts. The
  second prevents a malicious channel peer from imposing an excessively high
  [RBF][topic rbf] feerate when Eclair contributes funds to a replacement
  dual-funding or splice transaction. Eclair now rejects proposals above its
  locally calculated maximum, except when the peer pays the fees through a
  [liquidity purchase][topic liquidity advertisements].

- [LDK #5057][] fixes a vulnerability that could allow a malicious channel peer
  to steal the value of a forwarded [HTLC][topic htlc]. During reconnection, a
  peer could falsely claim in a `channel_reestablish` message that it had
  missed a commitment that it had already acknowledged with `revoke_and_ack`.
  LDK could then incorrectly accept this claim and sign a new, valid commitment
  transaction without recording it in its `ChannelMonitor`. The peer could then
  publish the transaction onchain. If LDK subsequently settled the forwarded
  payment, it could fail to claim the corresponding incoming HTLC, even though
  it knew the preimage. This would allow the malicious peer to reclaim those
  funds after the HTLC expired. LDK now only permits commitment retransmission
  when the peer's acknowledgment is still outstanding; otherwise, it
  force-closes the channel.

- [LDK #5042][] fixes a bug that could cause an LSP to lose funds when handling
  an [LSPS2][BLIP52] [just-in-time channel][topic jit channels] payment.
  Previously, the LSP trusted the forwarding amount specified in the payer's
  onion payload without verifying the amount of the incoming HTLC. A malicious
  payer could request a larger outgoing payment while sending less, causing the
  LSP to cover the difference with its own funds. Now, the LSPS2
  `htlc_intercepted` handlers verify that the requested outgoing amount does
  not exceed the actual incoming HTLC amount. If this condition isn't met, LDK
  fails back the HTLC before opening a channel or forwarding funds.

- [LDK #5046][] fixes a bug that could cause a forwarding node to lose funds
  when restarting with an older `ChannelManager` state than its
  `ChannelMonitor`. While LDK correctly force-closes channels in this
  situation, it may incorrectly treat an outgoing [HTLC][topic htlc] as never
  committed downstream and fail the corresponding incoming HTLC back to the
  upstream peer. The downstream peer could then claim the outgoing HTLC
  onchain, leaving LDK to cover the loss. LDK now checks which previously
  blocked monitor updates have already been applied before force-closing,
  ensuring that HTLCs committed downstream are left for the monitor to resolve
  instead of being incorrectly failed upstream.

- [LDK #5028][] makes SCID alias-only forwarding the default when opening new
  [unannounced channels][topic unannounced channels] with peers that support
  it. This avoids revealing the channel's funding output through invoices or
  forwarding probes using its real SCID. Previously, applications had to enable
  the `negotiate_scid_privacy` setting, which is now removed. Negotiation still
  falls back to a channel without this protection if the peer does not support
  or accept it. Existing channels keep their negotiated behavior.

- [LND #11290][] fixes an overflow bug when constructing [BOLT11][] invoices
  containing [blinded payment paths][topic rv routing] (see [Newsletter
  #315][news315 lnd blinded]). Previously, LND used 32-bit arithmetic to
  aggregate the forwarding fees of hidden hops, which could overflow at
  relatively low fees (around 4,295 msat or 4,295 ppm). This caused invoices to
  advertise lower fees than the hidden hops actually charged, potentially
  causing payments to fail because the receiver would receive less than the
  invoiced amount. LND now uses 64-bit checked arithmetic to calculate the
  aggregate fees and excludes paths whose fees exceed the invoice format's
  limits.

{% include snippets/recap-ad.md when="2026-10-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="36277,36365,36338,32895,9582,3390,3388,5057,5042,5046,5028,11290" %}

[towns set324alias]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes
[news392 bip324 ids]: /en/newsletters/2026/02/13/#bips-2092
[towns set324alias savings]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes/m/JHCPpVWaBAAJ
[jahr tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg
[news415 dahlias]: /en/newsletters/2026/07/24/#draft-bip-for-full-aggregation-of-bip340-signatures
[provoost tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg/m/OHPZw92DCQAJ
[shield del]: https://delvingbitcoin.org/t/shielded-bitcoin-private-transfers-on-the-bitcoin-l1/2912
[shield paper]: https://www.allocinit.xyz/uploads/shielded-bitcoin.pdf
[news393 pipes]: /en/newsletters/2026/02/20/#bitcoin-pipes-v2
[Bitcoin Core 32.0rc3]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc3/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[Core Lightning 26.06.9]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.9
[LDK v0.3-rc3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.3-rc3
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc3/CHANGELOG.md
[LDK v0.2.7]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.7
[LDK v0.1.13]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.13
[BTCPay Server 2.4.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.5
[btcpay 2.4.5 announcement]: https://blog.btcpayserver.org/btcpay-server-2-4-5/
[ldk #5057]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5057
[ldk #5042]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5042
[ldk #5046]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5046
[ldk #5028]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5028
[BLIP52]: https://github.com/lightning/blips/blob/master/blip-0052.md
[news388 private broadcast]: /en/newsletters/2026/01/16/#bitcoin-core-29415
[news425 private broadcast]: /en/newsletters/2026/10/02/#bitcoin-core-36312
[news420 fee estimation]: /en/newsletters/2026/08/28/#bitcoin-core-34075
[news425 silent payments]: /en/newsletters/2026/10/02/#bitcoin-core-35301
[news424 cln release]: /en/newsletters/2026/09/25/#core-lightning-26-06-8
[news423 eclair fees]: /en/newsletters/2026/09/18/#eclair-3376
[news315 lnd blinded]: /en/newsletters/2024/08/09/#lnd-8735