---
title: 'Bitcoin Optech Newsletter #430'
permalink: /en/newsletters/2026/11/06/
name: 2026-11-06-newsletter
slug: 2026-11-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about using TCP hole
punching to make nodes behind home routers reachable and describes a draft
BIP for standardizing the spending policies that co-signers enforce when
emulating covenants. Also included are our regular sections summarizing
proposals and discussion about changing Bitcoin's consensus rules, announcing
new releases and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Continued discussion of TCP hole punching for home nodes:** Following
  our May [summary][news406 holepunch] of 0xB10C's Delving Bitcoin thread on
  using hole punching to let nodes behind home routers accept connections
  from each other, 0xB10C [posted][b10c holepunch recap] that work has
  resumed on a specification and an experimental Bitcoin Core implementation.
  Home nodes can usually only make outbound connections, and turning on
  NAT-PMP port mapping by default in Bitcoin Core 30.0 did not make many more
  of them reachable as hoped. Hole punching, in which two home nodes open
  connections to each other at the same moment so that each router lets the
  other's traffic through, would be a best-effort supplement to port
  forwarding. More reachable honest nodes would make it harder for attackers,
  whose nodes are easier to reach, to fill a node's outbound connection
  slots.

  0xB10C recapped the four designs discussed so far and
  [proposed][b10c holepunch option6] a new option that needs no coordinator: a
  node announces its punchable address and a temporary public key in a new
  [addr v2][topic addr v2] type, and each pair of nodes derives the same
  candidate list and punch timing from their shared secret and each new
  block. In response to Anthony Towns's objection that an attacker could
  flood the scheme with real addresses, and after later finding that
  unreachable nodes receive such announcements far
  less reliably than listening nodes, he sketched a "message board"
  alternative in which listening nodes hold the verified addresses of home
  nodes looking for a peer.

  Towns questioned whether random inbound connections help home
  nodes at all and [argued][aj holepunch goals] that hole punching makes it
  easier for an attacker to reach honest nodes directly while doing little to
  guarantee a connection to an honest one. He estimated that an attacker
  advertising about 10,000 addresses would be an early match for most honest
  nodes and suggested short-lived connections to random peers as a lower-risk
  alternative. Jonathan Harvey-Buschel cited data showing honest nodes are
  less reachable than attacker-controlled ones and favored coordinating
  through a node's own [Tor][topic anonymity networks] service. Towns later
  [asked][aj holepunch cves] whether recent TCP and protocol vulnerabilities
  make not accepting inbound connections the safer default for home users.
  Discussion is ongoing.

- **BIP draft for standardized co-signer spending policies:** Luke Carriere
  [posted][cosigner pols del] to Delving Bitcoin about his proposal for
  standardizing the spending policies enforced by co-signers when emulating
  [covenants][topic covenants]. Several recent designs, including Johan
  Halseth's [blinded co-signers][news412 blinded cosigners] and [chain code
  delegation][news364 delegation], each define their own policy, so a wallet
  built for one cannot use a co-signer or oracle built for another. Carriere
  is not requesting a BIP number for the [draft][cosigner pol draft] and
  asked whether this is the right layer to standardize.

  The draft follows several design principles:

  - Anything that can be enforced by Bitcoin script must be enforced there,
    with co-signer policies only defining what script cannot.

  - At least one spending path that needs no co-signer must always be
    available.

  - How a co-signer verifies a spend, and what backs its honesty, are
    pluggable profiles chosen per policy.

  - Co-signers must accept oracle attestations in the
    [DLC][topic dlc] format so that already-available oracles can be reused
    with no modifications.

  A policy has five parts. The output defines the
  [taproot][topic taproot] descriptor that holds the funds, the co-signer
  group tells which co-signers take part and how many must sign, templates
  list the transactions the co-signers may sign with their exact outputs,
  conditions state what must be true before each template can be signed, and
  profiles name the verification mode, evidence formats, and any
  accountability scheme. Some points
  remain open, such as whether to use JSON or TLV for serialization, whether
  blinded verification should be specified now or wait for more implementation
  experience, whether to specify statement attestation format in the proposal
  or in the DLC specifications, and whether the fallback path must be timelocked.

  In the discussion that followed, PREDGE pointed out that one of the evidence
  profiles, called `statement-v0`, lacks a finality flag, meaning that a co-signer
  could act on a provisional attestation later corrected. Moreover, tehiyadu stated
  that the policy hash should commit to the exact verifier semantics to prevent
  different implementations from accepting the same bytes while enforcing different
  conditions. Carriere agreed with both points and said he would add a finality
  flag and pin down the verifier rules.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Continued discussion of BIP54**: Antoine Riard [posted][ar ml bip54] to
  the Bitcoin-Dev mailing list about his perspective on the state of the
  [consensus cleanup][topic consensus cleanup] soft fork ([BIP54][]).
  Forbidding transactions whose witness-stripped size is exactly 64 bytes is
  still the most contested rule. A Bitcoin Core implementation is under review
  and testing and is the reference implementation linked from the BIP
  ([Bitcoin Core #35793][]). The PR enables the new rules on regtest with no
  mainnet activation. He also pointed to interoperability work in btcd
  ([btcd #2537][]) and said he knows of no libbitcoin implementation. In his
  view what remains is more review and testing, documentation so wallets know
  about the proposed limit of 2,500 signature operations in pre-segwit script
  and about the 64-byte rule, and, only later, activation logic. Speaking only
  for himself, he thought it could be realistic to start considering
  activation in the second half of 2027 if the community agrees by then.

  Pieter Wuille [updated][pw delving timewarp lean] his Delving Bitcoin thread
  on how the two BIP54 timestamp rules bound chain length (see [Newsletter
  #425][news425 timewarp]). The top post now includes the accurate formula for
  the lower bound on work, and both that formula and the decimal approximation
  are now proven in the linked Lean code.

  Riard [followed up][ar ml forwardblocks] on an objection raised during the
  design of BIP54: that fixing the [time warp][topic time warp] bug would make
  a consensus change in the style of Mark Friedenbach's
  [forward blocks][news16 forward]
  impossible for the rest of Bitcoin's future history. Because the fix
  constrains timestamp manipulation rather than removing it, a much more
  limited forward blocks proposal could still be implemented. He estimated
  that the 7,200-second window still allowed by the fix could lower difficulty
  by roughly 0.60% per retarget period, and raise the block rate by about as
  much, far short of the capacity increase of the original
  proposal. Riard also argued the idea is unsound even with the old rules:
  validators would process transactions once on the forward chain and again
  when they are synchronized onto the compatibility chain, for the same fees
  unless users paid twice, and nodes that had not upgraded would still have to
  download the extra data. Riard will propose a short BIP54 footnote making
  that case, and ask Friedenbach for counter-arguments.

- **Opt-in replay protection prototype**: Sjors Provoost
  [followed up][sj delving replay] on the Delving Bitcoin thread about opt-in
  replay protection for a chain split (see [Newsletter #420][news420 replay])
  with a prototype that uses a new witness version. An [annex][topic annex]
  whose payload starts with the byte 0x01 names a block by a 4-byte height,
  and every signature on that input commits to the block's hash on the desired
  chain. The hash itself is not present in the transaction. He put the extra
  cost at 1.75 vbytes. The named block must be at least 100 blocks old, the
  same horizon as coinbase maturity. He said that if hashrate were split
  evenly, the wait before coins could be split would be two days at worst,
  because the rule only has to hold on one side. He suggested shipping the
  witness version together with another proposal that needs one, such as
  [CISA][topic cisa] (BIP460), [BIP360][], or a [P2TRv2][news403 pqout]-style
  output with a keypath that can later be disabled.

  Anthony Towns [replied][aj delving replay] that a new witness version is
  unnecessary, and that a new public-key encoding for a taproot signature
  check, in the style of [BIP118][], would be enough. Provoost
  [answered][sj delving replay keypath] that he had considered that encoding
  and thought it a hack, and that as he understood it, it would not work for
  a keypath spend.

  Moonsettler [questioned][ms delving replay] whether requiring 100 blocks is
  desirable in the split where the feature would matter most, and suggested
  keeping that delay as a policy rule that could be relaxed. Provoost
  [replied][sj delving replay maturity] that after coins move on the faster
  side and gather confirmations, the slower side no longer needs the
  protection. Provoost also wrote that he expects the rule to be deployed
  before a contentious hard fork, so both sides inherit it, and that neither
  side can easily drop it: the block hash is only in the signature message, so
  removing the rule means changing transaction serialization to carry the hash.

- **QSAVE for unmigrated coins**: James Tagg [posted][jt ml qsave] to the
  Bitcoin-Dev mailing list [five draft BIPs][qsave drafts] for QSAVE (Quantum
  Secure Asset Verification and Escrow), a
  [post-quantum][topic quantum resistance] transition that does not burn
  coins. He described these as an alternative to [BIP361][] and to
  [Hourglass][news395 hourglass]. From an enforcement height, which could be
  activated as a soft fork at any time, any input that is not on a registry of
  known post-quantum types would be treated as unmigrated, including
  unknown and future script types. An unmigrated input would still need
  to satisfy its locking script, and also a second factor: either a
  zero-knowledge proof that one seed derives both the spent script and a
  post-quantum key, or a post-quantum binding committed before a cutoff. If
  any unmigrated input in a transaction lacks that second factor, every
  spendable output must be a recovery output. In QSAVE, there is no sunset, so
  a missing second factor does not destroy the coin. An onchain proof can
  always spend it directly, with no third party. Otherwise he described an
  offchain lost-property process, whose legal and economic treatment he
  placed outside consensus, in which a set of decentralized custodians would
  hold the recovery outputs, with a backup custodian and a veto controller,
  and the funds could earn a conservative 0.5% return directed to charity. The
  drafts also specify pre-cutoff watermarks, an optional ML-DSA-87 key he
  called QD5, and a zk-STARK spend leaf for [BIP360][] ([P2MR][news393 p2mr])
  outputs.

- **Proof-of-decay for unmigrated outputs**: bitKingAE
  [posted][bk delving decay] to Delving Bitcoin a sketch for shrinking
  [post-quantum][topic quantum resistance]-exposed outputs, such as early P2PK
  coins, that are not moved within a grace period. After the grace period
  expires, the output's value would fall on a schedule with block height.
  The lost satoshis would be burned or paid out as mining rewards rather than
  the coins being frozen or left for whoever can produce a signature. The
  post's example was a small percentage of the balance every 50,000 blocks.
  Vinicius Cestari [replied][vc delving decay] with three objections: a
  quantum attacker can wait until the grace period ends and sweep exposed
  outputs before the decay has done much; a sudden improvement in quantum
  attacks can drain them even earlier; and the schedule reduces the balance of
  a passive owner, including one whose keys were already stolen.

- **BIP300 bundle censorship**: Ori Newman [argued][on ml bip300] on the
  Bitcoin-Dev mailing list that a miner with 26% of hashrate can censor a
  valid withdrawal bundle in the [drivechains][topic sidechains] proposal
  ([BIP300][]) indefinitely. He wrote that if the 26% miner sends an ALARM in
  every block it mines, each of those blocks lowers the score of every
  pending bundle by 1. If the other 74% of hashrate upvotes a bundle in every
  block, its expected score would be 12,624 at the end of the 26,300-block
  window, short of the 13,150 required. He suggested forbidding ALARM and any
  other downvote, which would restore an honest majority assumption: a bundle
  supported by 51% of hashrate would almost certainly pass, and one supported
  by 49% would almost certainly fail. If the current rule is intentional, he
  asked that the BIP instead state a 75% honest majority assumption. He called
  that a strong departure from Bitcoin's security model, and said one argument
  for it is that stealing funds would be harder for an attacker with less than
  75% of hashrate.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-11-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35793" %}

[news406 holepunch]: /en/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[b10c holepunch recap]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/18
[b10c holepunch option6]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/22
[aj holepunch goals]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/25
[aj holepunch cves]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/35
[cosigner pols del]: https://delvingbitcoin.org/t/bip-draft-co-signer-spending-policies/2955
[news412 blinded cosigners]: /en/newsletters/2026/01/02/#building-a-vault-using-blinded-co-signers
[news364 delegation]: /en/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[cosigner pol draft]: https://github.com/lukecarriere/bip-cosigner-spending-policies/blob/468fdd1b75647432ed56c3a2b5579cbcfedaec74/bip-cosigner-spending-policies.md
[ar ml bip54]: https://groups.google.com/g/bitcoindev/c/TBBakeBK8_E
[btcd #2537]: https://github.com/btcsuite/btcd/pull/2537
[pw delving timewarp lean]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899/29
[news425 timewarp]: /en/newsletters/2026/10/02/#bounds-on-chain-length-with-bip54-time-warp-fixes
[ar ml forwardblocks]: https://groups.google.com/g/bitcoindev/c/T9s8nflvlK0
[news16 forward]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[sj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/11
[news403 pqout]: /en/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news420 replay]: /en/newsletters/2026/08/28/#discussion-on-universal-opt-in-replay-protection
[aj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/12
[sj delving replay keypath]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/13
[ms delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/14
[sj delving replay maturity]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/15
[jt ml qsave]: https://groups.google.com/g/bitcoindev/c/5G38b3JL9fA
[qsave drafts]: https://www.qsave.org/legal/bip-suite
[news395 hourglass]: /en/newsletters/2026/03/06/#hourglass-v2-update
[news393 p2mr]: /en/newsletters/2026/02/20/#bips-1670
[on ml bip300]: https://groups.google.com/g/bitcoindev/c/7P0_BHRAYQI
[bk delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970
[vc delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970/2
