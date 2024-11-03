---
title: 'Bitcoin Optech Newsletter #109'
permalink: /en/newsletters/2020/08/05/
name: 2020-08-05-newsletter
slug: 2020-08-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the new Minsc policy language and contains our regular sections with recently
transcribed talks and conversations, releases and release candidates,
and notable changes to popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **New spending policy language:** Nadav Ivgi [announced][ivgi minsc] a new
  language he's developed named Minsc which makes it easier for
  developers to specify a set of conditions that must be fulfilled in
  order for a UTXO to be spent.  The new language is based on the
  [miniscript][topic miniscript] policy language but adds the ability to
  use variables and functions along with several other features.  Minsc
  policies can be compiled to miniscript policies, which can be themselves
  be compiled into miniscript and used to produce regular Bitcoin Script.  Compatibility
  with miniscript means that policies developed using Minsc will be
  solvable using any miniscript-aware wallet in the future, allowing
  wallets to contribute signatures, preimages, or other data needed to
  spend bitcoins without their developers having to manually specify how
  to handle each specific script template the wallet supports.  This
  should allow faster upgrades to new language features and greatly
  simplify development of interoperable wallets for coinjoins, contract
  protocols, shared coin ownership, and other types of desirable
  collaborations.

  Ivgi has also created an outstanding [website][min.sc] for the language.
  It includes both a plethora of examples and a live compiler that allows
  linking to its input so that developers can easily play with the
  language and share their Minsc policies with other developers.  We
  recommend anyone interested in developing spending policies visit the
  website, but as an illustration of what Minsc can do, we offer the
  following example adapted from Ivgi's own examples.  Several years
  ago, before miniscript or Minsc, LN developers hand crafted the
  following [HTLC script][] specified in BOLT3:

  ```python
  # To remote node with revocation key
  OP_DUP OP_HASH160 <RIPEMD160(SHA256(revocationpubkey))> OP_EQUAL
  OP_IF
      OP_CHECKSIG
  OP_ELSE
      <remote_htlcpubkey> OP_SWAP OP_SIZE 32 OP_EQUAL
      OP_IF
          # To local node via HTLC-success transaction.
          OP_HASH160 <RIPEMD160(payment_hash)> OP_EQUALVERIFY
          2 OP_SWAP <local_htlcpubkey> 2 OP_CHECKMULTISIG
      OP_ELSE
          # To remote node after timeout.
          OP_DROP <cltv_expiry> OP_CHECKLOCKTIMEVERIFY OP_DROP
          OP_CHECKSIG
      OP_ENDIF
  OP_ENDIF
  ```

  The same encumbrance can be [specified][htlc minsc] using the following Minsc
  policy (setting the `cltv_expiry` to 3 hours):

  ```hack
  fn htlc_received($revocationpubkey, $local_htlcpubkey,
                   $remote_htlcpubkey, $payment_hash,
                   $cltv_expiry)
  {
    // To local node via HTLC-success transaction
    $success = pk($local_htlcpubkey) && hash160($payment_hash);

    // To remote node after timeout
    $timeout = older($cltv_expiry);

    // To remote node with revocation key, or use success/timeout
    pk($revocationpubkey) || (pk($remote_htlcpubkey) && ($success || $timeout))
  }

  htlc_received(A, B, C, H, 3 hours)
  ```

  The Minsc policy is significantly easier for most developers to
  analyze and it's able to take advantage of miniscript to transform the
  policy into a moderately smaller script than the original
  hand-crafted script.

## Recently transcribed talks and conversations

*[Bitcoin Transcripts][] is the home for transcripts of technical
Bitcoin presentations and discussions. In this monthly feature, we
highlight a selection of the transcripts from the previous month.*

- **RaspiBlitz full node:** Rootzoll and Openoms appeared on
  [Potzblitz][] to present the RaspiBlitz, a Bitcoin and Lightning
  Network full node built on a Raspberry Pi (but also compatible with
  other hardware). Openoms explored some of the apps and services you
  can install on your RaspiBlitz such as [ThunderHub][] and [Balance of
  Satoshis][]. Rootzoll explained how the IP2TOR subscription service
  addresses the challenge of connecting a mobile wallet to a RaspiBlitz
  full node running on a home network.  ([transcript][rb transcript], [video][rb video],
  [slides][rb slides])

- **Chicago meetup discussion:** Anonymized participants discussed
  various Lightning Network attacks including [flood and loot][], fee
  blackmail, [transaction pinning][topic transaction pinning], preimage denial (see [Newsletter
  #95][news95 LN payment atomicity]) and time dilation (see [Newsletter
  #101][news101 LN time dilation]). In light of these various attacks of
  varying severities it was debated what current users should do to
  protect themselves on the Lightning Network and longer term what
  sufficient mitigations would be. Some solutions such as [package relay][topic package relay],
  [anchor outputs][topic anchor outputs] and rearchitecting the Bitcoin Core mempool are being
  worked on---but more work will be required at both the onchain layer and the
  Lightning layer in the coming months and years.
  ([transcript][chicago transcript])

- **Sapio:** Jeremy Rubin presented Sapio at Reckless VR in virtual
  reality. Sapio is a new high level programming language designed for
  building stateful smart contracts with [OP_CHECKTEMPLATEVERIFY][topic
  OP_CHECKTEMPLATEVERIFY]. Rubin used the case study of the recent
  timelock [issue][timelock issue] with Blockstream’s Liquid sidechain to explain how
  Sapio and OP_CHECKTEMPLATEVERIFY could theoretically have been
  utilized to prevent funds unintentionally moving to the 2-of-3
  multisig emergency backup.  ([transcript][sapio transcript], [video][sapio video], [slides][sapio slides])

- **Sydney meetup discussion:** Anonymized participants discussed
  resolved bugs in the Bitcoin Core build system over the past months
  and the future challenges of building and distributing Bitcoin Core
  binaries on MacOS in light of notarization requirements and Apple
  transitioning from Intel to ARM processors. Other topics included
  updates to the [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
  proposal, generalized Bitcoin-compatible channels, and the latest thinking
  on taproot activation.  ([transcript][sydney transcript])

- **BIP-Taproot:** Pieter Wuille and Russell O’Connor participated in a
  joint event organized by London BitDevs and Bitcoin Munich exploring
  the history of how the original idea of [MAST][topic MAST] evolved
  into the final [taproot][topic Taproot] proposal. Wuille talked about
  how his personal motivation switched from seeking to enable cross
  input signature aggregation to bolstering the privacy and efficiency
  of more complex transactions. O’Connor also gave an update on
  development of the Simplicity language (see [Newsletter #96][news96
  simplicity]). He speculated how Simplicity could be
  implemented as a Tapleaf version in the coming years and used for
  delegation, [covenants][topic covenants], and other functionality not currently available using
  Bitcoin Script. The [PR][libsecp256k1 #558] for [schnorr signatures][topic schnorr signatures] in libsecp256k1 and
  the taproot [PR][Bitcoin Core #17977] in Bitcoin Core are seeking
  further review and O’Connor encouraged the community to consider what
  taproot might break in their own software well in advance of any
  possible deployment.  ([transcript][london/munich transcript], [video][london/munich video])

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.9.0][C-Lightning 0.9.0] is the newest major version of
  C-Lightning.  It adds support for the updated `pay` command and new
  `keysend` RPC, both described in [Newsletter #107][news107 notable].  It
  also includes several other notable changes and multiple bug fixes.

- [Bitcoin Core 0.20.1][Bitcoin Core 0.20.1] is a new maintenance
  release.  In addition to bug fixes and some RPC behavior changes
  resulting from those fixes, the planned release provides compatibility
  with recent versions of [HWI][topic HWI] and its support for hardware
  wallet firmware released for the [fee overpayment attack][].

- [LND 0.11.0-beta.rc1][LND 0.11.0-beta] is the first release candidate
  for a new major release.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19569][] allows Bitcoin Core to fetch the parents of _orphan_
  transactions from peers that relay transactions using wtxid. An orphan
  transaction is an unconfirmed transaction that we receive from a peer where we
  don't yet have the parent transactions, either as part of our best block
  chain, or in the mempool. More precisely, an orphan transaction has at least
  one transaction input whose associated output is not in the UTXO set or our
  mempool's outpoint map.

  When we receive an orphan transaction, we place it in a temporary data
  structure called the orphan set. We then ask the peer that sent us the
  orphan to also send us the parent transactions that we don't yet have. We can
  do that because the orphan transaction contains the txids of its parent
  transactions. We simply send a `getdata` message containing those txids to
  the peer to request the parent transactions.

  For [wtxid relay peers][news108 wtxid relay], transactions are announced
  and requested using the _wtxid_ of the transaction, not the _txid_. However,
  orphan transactions contain their parents' txids, not wtxids, so it's
  not possible to request the parent transaction using wtxid. [PR
  #18044][Bitcoin Core #18044], which introduced wtxid relay peers and was
  merged last week, did not permit fetching parent transactions from wtxid
  peers. This follow-up PR allows us to fetch those parents using the txid.

  Fetching parent transactions using txid may eventually be replaced
  by a [package relay][topic package relay] mechanism, where we can
  ask a peer for all the unconfirmed ancestors of a transaction directly.

- [Eclair #1491][] adds partial support for creating, using, and closing
  channels that use [anchor outputs][topic anchor outputs] to both reduce
  onchain transaction fees in normal cases and increase fees when
  necessary for security.  This implementation handles all the basics
  but does not yet support mutual channel closes or actual fee bumping;
  those will be added later.  Additionally, interoperability testing
  with LND's implementation revealed a case where the
  [specification][anchor spec discuss] should be clarified.

- [LND #4488][] updates the minimum CLTV expiry delta users may set to
  18 blocks in line with an [updated recommendation][BOLTs #785].  The
  default remains at 40 blocks.  When there are only this many blocks
  until an LN payment has to be settled, LND will unilaterally close the
  channel to ensure the latest state gets recorded onchain.  However,
  the higher the expiry is, the more time a payment could become
  temporarily stuck in a channel (either by accident or deliberately).
  This has led some LN implementations to use route-finding algorithms
  that optimize for routes with low CLTV expiry deltas, which has in
  turn led some users to set their deltas to values that are especially
  unsafe.  This new minimum should help prevent inexperienced users from
  naively setting an unsafe value.

- [BIPs #948][] updates the [BIP174][] specification of [PSBT][topic psbt] input
  records to explicitly allow for providing both a non-witness UTXO (the full
  transaction) and a witness UTXO for a single input. This is in line with the
  [current behavior][news105 fee overpayment] in Bitcoin Core and was motivated
  by the possibility of a fee overpayment attack on multi-input segwit PSBTs
  which did not include the non-witness UTXOs as detailed in [a previous
  newsletter][fee overpayment attack].

- [BIPs #947][] updates the [BIP325][] specification of [signet][topic
  signet] to change the block signature verification method.  Signets
  are test networks where valid blocks are signed by trusted signers,
  a change which eliminates some issues
  and makes certain types of testing easier.

  Previously, signet assumed the use of signatures compatible with
  legacy Bitcoin Script (e.g. DER-encoded ECDSA signatures).  After
  this change, signet instead uses a pair of virtual
  transactions---transactions that aren't valid on the block chain and
  aren't included inside the block but which can easily be constructed
  by Bitcoin software (directly or using a [PSBT][topic PSBT]).  The
  first transaction commits to paying the network's trusted signer
  script.  A second virtual transaction then spends the output of the
  first virtual transaction.  The signature or signatures from the
  second virtual transaction are included in the coinbase transaction
  of the block to prove the block is validly signed.

  The main advantage of this new approach is that it allows using
  segwit transactions.   The opcodes available in current segwit v0
  are almost all identical to legacy script, <!-- I think
  OP_CODESEPARATOR is the only change --> so this may seem
  irrelevant---but if segwit v1 ([taproot][topic taproot]) is made
  available on a signet, this will allow signing blocks with [schnorr
  signatures][topic schnorr signatures].  As future protocol changes
  will probably also use segwit, this will allow those features to be
  used as well.  A secondary advantage is that any software or
  hardware that can sign PSBTs for arbitrary inputs will now be able
  to operate as a trusted signer for a signet.

{% include references.md %}
{% include linkers/issues.md issues="19569,1491,4488,948,947,785,18044,558,17977" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0
[Bitcoin Core 0.20.1]: https://bitcoincore.org/bin/bitcoin-core-0.20.1/
[LND 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc1
[fee overpayment attack]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news105 fee overpayment]: /en/newsletters/2020/07/08/#bitcoin-core-19215
[news107 notable]: /en/newsletters/2020/07/22/#notable-code-and-documentation-changes
[anchor spec discuss]: https://github.com/lightningnetwork/lightning-rfc/pull/688#issuecomment-661669232
[ivgi minsc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018062.html
[min.sc]: https://min.sc
[htlc script]: https://github.com/lightningnetwork/lightning-rfc/blob/master/03-transactions.md#received-htlc-outputs
[htlc minsc]: https://min.sc/#c=fn%20htlc_received%28%24revocationpubkey%2C%20%24local_htlcpubkey%2C%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%24remote_htlcpubkey%2C%20%24payment_hash%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%24cltv_expiry%29%0A%7B%0A%20%20%2F%2F%20To%20local%20node%20via%20HTLC-success%20transaction%0A%20%20%24success%20%3D%20pk%28%24local_htlcpubkey%29%20%26%26%20hash160%28%24payment_hash%29%3B%0A%0A%20%20%2F%2F%20To%20remote%20node%20after%20timeout%0A%20%20%24timeout%20%3D%20older%28%24cltv_expiry%29%3B%0A%0A%20%20%2F%2F%20To%20remote%20node%20with%20revocation%20key%2C%20or%20use%20success%2Ftimeout%20with%20remote%20consent%0A%20%20pk%28%24revocationpubkey%29%20%7C%7C%20%28pk%28%24remote_htlcpubkey%29%20%26%26%20%28%24success%20%7C%7C%20%24timeout%29%29%0A%7D%0A%0Ahtlc_received%28A%2C%20B%2C%20C%2C%20H%2C%203%20hours%29
[news108 wtxid relay]: /en/newsletters/2020/07/29/#bitcoin-core-18044
[rb transcript]: https://diyhpl.us/wiki/transcripts/lightning-hack-day/2020-06-21-rootzoll-openoms-raspiblitz/
[rb video]: https://www.youtube.com/watch?v=1EqUi4xRbr0
[rb slides]: https://keybase.pub/oms/Potzblitz9-RaspiBlitz-slides.pdf
[chicago transcript]: https://diyhpl.us/wiki/transcripts/chicago-bitdevs/2020-07-08-socratic-seminar/
[news95 ln payment atomicity]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[news101 ln time dilation]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[sapio transcript]: https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-07-11-jeremy-rubin-sapio-101/
[sapio video]: https://www.youtube.com/watch?v=4vDuttlImPc
[sapio slides]: https://docs.google.com/presentation/d/1X4AGNXJ5yCeHRrf5sa9DarWfDyEkm6fFUlrcIRQtUw4/
[timelock issue]: https://medium.com/blockstream/patching-the-liquid-timelock-issue-b4b2f5f9a973
[sydney transcript]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-07-21-socratic-seminar/
[london/munich transcript]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-07-21-socratic-seminar-bip-taproot/
[london/munich video]: https://www.youtube.com/watch?v=bPcguc108QM
[news96 simplicity]: /en/newsletters/2020/05/06/#simplicity-next-generation-smart-contracting
[potzblitz]: https://www.youtube.com/channel/UCqUfpNS9-dzAvobqhviX39w
[flood and loot]: https://arxiv.org/abs/2006.08513
[thunderhub]: https://www.thunderhub.io/
[balance of satoshis]: https://github.com/alexbosworth/balanceofsatoshis
[hwi]: https://github.com/bitcoin-core/HWI
