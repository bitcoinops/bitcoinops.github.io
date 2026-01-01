---
title: 'Bitcoin Optech Newsletter #386'
permalink: /en/newsletters/2026/01/02/
name: 2026-01-02-newsletter
slug: 2026-01-02-newsletter
type: newsletter
layout: newsletter
lang: en
---

This week's newsletter summarizes a vault-like scheme using blinded MuSig2 and
describes a proposal for Bitcoin clients to announce and negotiate support for new
P2P features. Also included are our regular sections describing discussion
related to consensus changes, announcing new releases and release candidates,
and summarizing notable changes to popular Bitcoin infrastructure software.

## News

- **Building a vault using blinded co-signers:** Jonathan T. Halseth
  [posted][halseth post] to Delving Bitcoin a prototype of a
  [vault][topic vaults]-like scheme using blinded co-signers. Unlike traditional
  setups using co-signers, this scheme uses a [blinded version][blinded musig]
  of [MuSig2][topic musig] to ensure the signers know as little as possible about
  the funds they are involved in signing. To prevent signers from having to
  blindly sign what is given to them, this scheme attaches a zero-knowledge proof
  to the signing request proving that the transaction is valid according to a
  pre-determined policy, in this case a [timelock][topic timelocks].

  Halseth provided a graph of the scheme showing four transactions where the
  initial deposit, recovery, unvault, and the unvault recovery transactions will
  be pre-signed. At the time of unvaulting, the co-signers will require a
  zero-knowledge proof that the tx they are signing has the relative
  timelock set correctly. This gives assurance that the user
  or a watchtower will have time to sweep the funds in the case of an
  unauthorized unvault.

  Halseth also provided a [prototype implementation][halseth prototype]
  available for regtest and signet.

- **Peer feature negotiation**: Anthony Towns [posted][peer neg ml] to the
  Bitcoin-Dev mailing list about a proposal for a new [BIP][towns bip] to define
  a P2P message that would allow peers to announce and negotiate support for new
  features. The idea is similar to a [previous one][feature negotiation ml] from
  2020 and would benefit various proposed P2P use cases, including Towns' work
  on [template sharing][news366 template].

  Historically, changes to the P2P protocol have relied on version bumping to
  signal support for new features, ensuring peers negotiate only with compatible nodes.
  However, this approach creates unnecessary coordination across
  implementations, especially for features that don't need universal adoption.

  This BIP proposes generalizing [BIP339][]'s mechanism by introducing a single, reusable
  P2P message for announcing and negotiating future P2P upgrades during the
  [pre-verack][verack] phase. This would reduce coordination burdens, enable
  permissionless extensibility, prevent network partitioning, and maximize
  compatibility with diverse clients.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing Bitcoin's
consensus rules._

- **Year 2106 timestamp overflow uint64 migration**: Asher Haim [posted][ah ml
  uint64 ts] to the Bitcoin-Dev mailing list asking Bitcoin developers to act promptly to
  prepare for a migration from uint32 to uint64 block timestamps. Haim
  explains the reasons for prompt action in relationship to long term
  financial contracts which might begin to reference Bitcoin after 2106
  surprisingly soon. This is not yet a concrete proposal in BIP form and
  would require many additional details to be worked out as they relate to
  timelocks and other parts of the Bitcoin ecosystem. The [BitBlend][bb 2024]
  proposal from January 2024 is one possible concrete solution.

- **Relax [BIP54][] timestamp restriction for 2106 soft fork**: Josh Doman
  posted to the Bitcoin-Dev [mailing list][jd ml bip54 ts] and [Delving Bitcoin][jd delving bip54
  ts] asking whether it's might be worthwhile to modify the [consensus
  cleanup][topic consensus cleanup] proposal to be more
  permissive to odd block timestamp behavior to allow a potential soft fork
  solution to the 2106 block timestamp overflow issue. ZmnSCPxj previously
  [proposed][zman ml ts2106] something similar back in 2021. Discussions on
  both forums focused on the question of whether avoiding a hard fork is
  worthwhile when there are sound engineering reasons to pursue one. Greg
  Maxwell [wrote][gm delving bip54] that the risk of unfixing the [timewarp][topic time warp]
  attacks that [BIP54][] aims to resolve may be reason enough not to attempt
  to soften its restrictions in this way.

- **Understanding and mitigating a CTV footgun**: Chris Stewart
  [posted][cs delving ctv] to Delving Bitcoin a discussion of a
  "footgun" with [`OP_CHECKTEMPLATEVERIFY` (CTV)][topic op_checktemplateverify]. Specifically, if an amount
  less than the total of the output amounts specified in a 1-input CTV hash is
  sent to a `scriptPubKey` which unconditionally requires that CTV hash, the
  resulting output is permanently unspendable. He proposes that CTV users can
  mitigate this by making all of their CTV hashes commit to 2 or more inputs.
  In this way, an additional input can always be constructed which enables such
  outputs to be spent.

  Greg Sanders responded with some limitations of this approach and
  1440000bytes mentioned that this only applies when the next transaction template is
  unconditionally enforced. Greg Maxwell argued that this is a reason to avoid
  the entire class of transaction template [covenants][topic covenants]. Brandon Black suggested
  that the use of CTV on a receiving address is indeed a risky application
  design, and that another opcode such as [`OP_CHECKCONTRACTVERIFY`][topic matt]
  ([BIP443][]) in combination with CTV may enable safer applications.

- **CTV activation meeting**: Developer 1440000bytes [hosted][fd0 ml ctv] a
  CTV ([BIP119][]) activation [meeting][ctv notes1]. The meeting attendees
  agreed that a CTV activation client should use conservative parameters (i.e.
  long signaling and activation periods) and [BIP9][]. At the time of writing,
  other developers have not weighed in on the mailing list.

- **`OP_CHECKCONSOLIDATION` to enable cheaper consolidations**: billymcbip
  [proposed][bmb delving cc] an opcode specifically optimized for
  consolidations. `OP_CHECKCONSOLIDATION` (CC) would evaluate to 1 if and only
  if it's executed on an input with the same `scriptPubKey` as an earlier
  input in the same transaction. Much discussion revolved around the
  requirement to use the same `scriptPubKey` encouraging address reuse and
  harming privacy. Brandon Black proposed similar (but not as byte-efficient)
  functionality using `OP_CHECKCONTRACTVERIFY` ([BIP443][]). This proposal is
  similar to Tadge Dryja's [earlier work][news379 civ] on
  `OP_CHECKINPUTVERIFY`, but significantly more byte-efficient and less
  generalized.

- **Hash-based signatures for Bitcoin's post-quantum future**: Mikhail Kudinov
  and Jonas Nick [posted][mk ml hash] to the Bitcoin-Dev mailing list about their work on evaluating
  hash-based signatures for use in Bitcoin. Their work found significant
  opportunities for optimization of signature size compared to current
  standardized approaches, but did not find applicable alternatives to
  [BIP32][], [BIP327][], or [FROST][news315 frost]. Several developers weighed
  in, discussing this work and other [post-quantum signing][topic quantum resistance] mechanisms and
  potential paths for Bitcoin development.

  There was also discussion of whether it's most appropriate to compare new
  signature verification mechanisms based on their CPU cycles per-byte or
  their CPU cycles per-signature. Per-byte appears more applicable if the new
  signature verifications will be limited by the existing weight limit and
  multipliers, reducing payment throughput. Per-signature may be the better
  comparison if the new signatures would have a new limit of their own to
  enable closer-to-current-payment throughput in post-quantum Bitcoin.

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

{% include snippets/recap-ad.md when="2026-01-06 17:30" %}
[news315 frost]: /en/newsletters/2024/08/09/#proposed-bip-for-scriptless-threshold-signatures
[mk ml hash]: https://groups.google.com/g/bitcoindev/c/gOfL5ag_bDU/m/0YuwSQ29CgAJ
[fd0 ml ctv]: https://groups.google.com/d/msgid/bitcoindev/CALiT-Zr9JnLcohdUQRufM42OwROcOh76fA1xjtqUkY5%3Dotqfwg%40mail.gmail.com
[ctv notes1]: https://ctv-activation.github.io/meeting/18dec2025.html
[news379 civ]: /en/newsletters/2025/11/07/#post-quantum-signature-aggregation
[bmb delving cc]: https://delvingbitcoin.org/t/op-cc-a-simple-introspection-opcode-to-enable-cheaper-consolidations/2177
[cs delving ctv]: https://delvingbitcoin.org/t/understanding-and-mitigating-a-op-ctv-footgun-the-unsatisfiable-utxo/1809
[bb 2024]: https://bitblend2106.github.io/bitcoin/BitBlend2106.pdf
[ah ml uint64 ts]: https://groups.google.com/g/bitcoindev/c/PHZEIRb04RY/m/ryatIL5RCwAJ
[jd ml bip54 ts]: https://groups.google.com/g/bitcoindev/c/L4Eu9bA5iBw/m/jo9RzS-HAQAJ
[jd delving bip54 ts]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163
[zman ml ts2106]: https://gnusha.org/pi/bitcoindev/eAo_By_Oe44ra6anVBlZg2UbfKfzhZ1b1vtaF0NuIjdJcB_niagHBS-SoU2qcLzjDj8Kuo67O_FnBSuIgskAi2_fCsLE6_d4SwWq9skHuQI=@protonmail.com/
[gm delving bip54]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163/6
[halseth post]: https://delvingbitcoin.org/t/building-a-vault-using-blinded-co-signers/2141
[halseth prototype]: https://github.com/halseth/blind-vault
[blinded musig]: https://github.com/halseth/ephemeral-signing-service/blob/main/doc/general.md
[peer neg ml]: https://groups.google.com/g/bitcoindev/c/DFXtbUdCNZE
[news366 template]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[feature negotiation ml]: https://gnusha.org/pi/bitcoindev/CAFp6fsE=HPFUMFhyuZkroBO_QJ-dUWNJqCPg9=fMJ3Jqnu1hnw@mail.gmail.com/
[towns bip]: https://github.com/ajtowns/bips/blob/202512-p2p-feature/bip-peer-feature-negotiation.md
[verack]:https://developer.bitcoin.org/reference/p2p_networking.html#verack
