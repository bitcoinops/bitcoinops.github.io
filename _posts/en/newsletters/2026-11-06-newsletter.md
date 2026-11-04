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
{% include linkers/issues.md v=2 issues="" %}

[news406 holepunch]: /en/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[b10c holepunch recap]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/18
[b10c holepunch option6]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/22
[aj holepunch goals]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/25
[aj holepunch cves]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/35
[cosigner pols del]: https://delvingbitcoin.org/t/bip-draft-co-signer-spending-policies/2955
[news412 blinded cosigners]: /en/newsletters/2026/01/02/#building-a-vault-using-blinded-co-signers
[news364 delegation]: /en/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[cosigner pol draft]: https://github.com/lukecarriere/bip-cosigner-spending-policies/blob/468fdd1b75647432ed56c3a2b5579cbcfedaec74/bip-cosigner-spending-policies.md
