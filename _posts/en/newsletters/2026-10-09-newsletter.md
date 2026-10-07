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

{% include snippets/recap-ad.md when="2026-10-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[towns set324alias]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes
[news392 bip324 ids]: /en/newsletters/2026/02/13/#bips-2092
[towns set324alias savings]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes/m/JHCPpVWaBAAJ
[jahr tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg
[news415 dahlias]: /en/newsletters/2026/07/24/#draft-bip-for-full-aggregation-of-bip340-signatures
[provoost tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg/m/OHPZw92DCQAJ
[shield del]: https://delvingbitcoin.org/t/shielded-bitcoin-private-transfers-on-the-bitcoin-l1/2912
[shield paper]: https://www.allocinit.xyz/uploads/shielded-bitcoin.pdf
[news393 pipes]: /en/newsletters/2026/02/20/#bitcoin-pipes-v2
