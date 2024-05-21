---
title: 'Bitcoin Optech Newsletter #301'
permalink: /en/newsletters/2024/05/08/
name: 2024-05-08-newsletter
slug: 2024-05-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an idea for securing transactions with
lamport signatures without requiring any consensus changes.
Also included are our regular sections with the summary of a Bitcoin Core
PR Review Club, announcements of new releases and release candidates,
and descriptions of changes to popular Bitcoin infrastructure software.

## News

- **Consensus-enforced lamport signatures on top of ECDSA signatures:**
  Ethan Heilman [posted][heilman lamport] to the Bitcoin-Dev mailing list a method
  for requiring that a transaction be signed by a [lamport signature][] in order
  to be valid.  This can make spends of P2SH and P2WSH outputs [quantum
  resistant][topic quantum resistance] and, [according][poelstra lamport1] to Andrew Poelstra,
  makes it so "that size limits are now the only reason that Bitcoin doesn't
  have covenants."  We'll summarize the protocol below, but to keep our
  description simple and clear, we will omit several security warnings,
  so please do not implement anything based on this summary.

  Lamport public keys consist of two lists of hash digests.  Lamport
  signatures consist of the preimages for selected hashes.  A program
  shared between the signer and the validator interprets which preimages
  are revealed as instructions.  For example, Bob wants to verify that
  Alice signed a number between 0 and 31 (in binary, 00000 to 11111).
  Alice creates a lamport private key from two lists of random
  numbers:

  ```text
  private_zeroes = [random(), random(), random(), random(), random()]
  private_ones   = [random(), random(), random(), random(), random()]
  ```

  She hashes each of those private numbers to create her lamport public
  key:

  ```text
  public_zeroes = [hash(private_zeroes[0]), ..., hash(private_zeroes[4])]
  public_ones   = [hash(private_ones[0]), ..., hash(private_ones[4])]
  ```

  She gives Bob her public key.  Later she wants to verifiably
  communicate the number 21 to him.  She sends the following preimages:

  ```text
  private_ones[0]
  private_zeroes[1]
  private_ones[2]
  private_zeroes[3]
  private_ones[4]
  ```

  In binary, that's 10101.  Bob verifies each of the
  preimages match the public keys he previously received, assuring him
  that only Alice with her knowledge of the preimages could have
  generated the message "21".

  For ECDSA signatures, Bitcoin uses the [DER encoding standard][der encoding],
  which omits leading zero (0x00) bytes from the signature's two
  components.  For random values, a 0x00 byte will occur 1/256th of the
  time, so Bitcoin signatures naturally vary in size.  This variation is
  exacerbated by the leading byte for R values being a 0x00 half the
  time (see [low-r grinding][topic low-r grinding]) but, in theory, the
  variation can be reduced to a transaction being one byte smaller 1/256th
  of the time.

  Even if a fast quantum computer allows an attacker to create
  signatures without prior knowledge of a private key, DER-encoded ECDSA signatures
  will still vary in length and will still need to commit to the transactions that contain them, and
  that transaction will still need to include any additional data
  necessary to make it valid, such as hash preimages.

  This allows the P2SH redeem script to contain an ECDSA signature
  check that will commit to the transaction and a lamport signature that
  commits to the actual size of the ECDSA signature.  For example:

  ```text
  OP_DUP <pubkey> OP_CHECKSIGVERIFY OP_SIZE <size> OP_EQUAL
  OP_IF
    # We now know the size is equal to <size> bytes
    OP_SHA256 <digest_x> OP_CHECKEQUALVERIFY
  OP_ELSE
    # We now know the size is greater than or less than <size> bytes
    OP_SHA256 <digest_y> OP_CHECKEQUALVERIFY
  OP_ENDIF
  ```

  To satisfy this script fragment, the spender provides an ECDSA
  signature.  The signature is duplicated and validated; the script
  fails if it's not a valid signature.  In a post-quantum world, an
  attacker may be able to pass this test, allowing validation to
  continue.  The size of the duplicate signature is measured.  If it's
  equal to `<size>` bytes, the spender must reveal the preimage for
  `<digest_x>`.  This `<size>` can be set to one byte smaller than the
  common case, which naturally happens once every 256 signatures.
  Otherwise, in the common case or with a size-inflated signature, the
  spender must reveal the preimage for `<digest_y>`.  If a valid
  preimage for the actual signature size isn't revealed, the script
  fails.

  Now even if ECDSA is completely broken, an attacker can't spend the
  bitcoins unless they also know the lamport
  private key.  By itself, this isn't very exciting: P2SH and P2WSH
  [already have][news141 key hiding] this fundamental property when their script preimages are
  kept secret.  However, after the lamport signature is published, an
  attacker who wants to reuse it with a forged ECDSA signature will have
  to ensure the ECDSA signature is the same length as the original ECDSA
  signature.  This may require the attacker to grind the signature,
  performing extra operations that an honest user wouldn't need to
  perform.

  The amount of grinding an attacker would need to perform can be
  increased exponentially by including additional pairs of ECDSA and
  lamport signatures.  Unfortunately, because ECDSA signatures only
  naturally vary in byte size one time out of every 256, the
  straightforward way to do this would require a very large number of
  signatures to be included to obtain practical security.
  Heilman [describes][heilman lamport2] a much more efficient mechanism.  That mechanism
  still exceeds the consensus limits for P2SH <!-- 520 byte redeem
  script size --> but we think it might just barely work with P2WSH's
  higher limits<!-- 10,000 byte max script size -->.

  Additionally, an individual attacker with a fast quantum computer or a
  sufficiently powerful classical computer could discover a short ECDSA
  nonce that would allow them to easily steal from anyone who didn't
  anticipate a nonce that short.  The minimal size of a nonce is known,
  so the attack is avoidable---however, the private form of that nonce
  is not known, so anyone trying to avoid this attack would be unable to
  spend their own bitcoins until a fast quantum computer was invented.

  This lamport signature verification is practically similar to the
  proposed [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] opcode.
  In both cases, the data to be verified, a public key, and a signature
  are placed on the stack and an operation only succeeds if the
  signature both corresponds to the public key and commits to the data on
  the stack.  Andrew Poelstra [described][poelstra lamport2] how this can
  be combined with [BitVM][topic acc]-style operations to create a
  [covenant][topic covenants], although he warns that would almost certainly violate at
  least one consensus size limit. {% assign timestamp="1:00" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Index TxOrphanage by wtxid, allow entries with same txid][review club
30000] is a PR by Gloria Zhao (GitHub glozow) that allows multiple
transactions with the same `txid` to exist in `TxOrphanage` at the same
time by indexing them on `wtxid` instead of `txid`.

This PR makes the opportunistic 1-parent-1-child (1p1c) [package
acceptance][topic package relay] introduced in [Bitcoin Core #28970][] more robust.

 {% assign timestamp="31:04" %}

{% include functions/details-list.md
  q0="Why would we want to allow multiple transactions with the same
      txid to exist in the TxOrphanage at the same time? What kind of
      situation does this prevent?"
  a0="By definition, the witness data of orphan transactions cannot be
      validated because the parent transaction is unknown. When multiple
      transactions (with different wtxids) of the same txid are
      received, it is thus impossible to know which version is the
      correct one. By allowing them to exist in parallel inside
      TxOrphanage, an attacker is prevented from sending an incorrect
      malleated version that prevents further acceptance of the correct
      version."
  a0link="https://bitcoincore.reviews/30000#l-11"

  q1="What are some examples of same-txid-different-witness orphans?"
  a1="A same-txid-different-witness transaction can have an invalid
      signature (and thus be invalid) or a larger witness (but same fee
      and thus lower feerate)."
  a1link="https://bitcoincore.reviews/30000#l-67"

  q2="Let’s consider the effects of only allowing 1 entry per txid. What
      happens if a malicious peer sends us a mutated version of the
      orphan transaction, where the parent is not low feerate? What
      needs to happen for us to end up accepting this child to mempool?
      (There are multiple answers)"
  a2="When a mutated child is in the orphanage and a valid
      not-low-feerate parent is received, the parent will be accepted
      into the mempool, and the mutated child invalidated and removed
      from the orphanage."
  a2link="https://bitcoincore.reviews/30000#l-52"

  q3="Let’s consider the effects if we have a 1-parent-1-child (1p1c)
      package (where the parent is low feerate and must be submitted
      with its child). What needs to happen for us to end up accepting
      the correct parent+child package to mempool?"
  a3="Since the parent is low feerate, it will not be accepted into the
      mempool by itself. However, since [Bitcoin Core #28970][], it can
      be opportunistically accepted as a 1p1c package if the child is in
      the orphanage. If the orphaned child is mutated, the parent is
      rejected from the mempool, and the orphan removed from the
      orphanage."
  a3link="https://bitcoincore.reviews/30000#l-60"

  q4="Instead of allowing multiple transactions with the same txid
      (where we are obviously wasting some space on a version we will
      not accept), should we allow a transaction to replace an existing
      entry in the TxOrphanage? What would be the requirements for
      replacement?"
  a4="It appears there is no good metric by which to judge whether a
      transaction should be allowed to replace an existing one. One
      potential avenue to explore is to replace duplicated transactions
      from the same peer only."
  a4link="https://bitcoincore.reviews/30000#l-80"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Libsecp256k1 v0.5.0][] is a release of this library for performing
  Bitcoin-related cryptographic operations.  It speeds up key generation
  and signing (see [last week's newsletter][news300 secp]) and reduces
  the compiled size "which we expect to benefit embedded users in
  particular."  It also adds a function for sorting public keys. {% assign timestamp="51:15" %}

- [LND v0.18.0-beta.rc1][] is a release candidate for the next major
  version of this popular LN node. {% assign timestamp="52:12" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #28970][] and [#30012][bitcoin core #30012] add support
  for a limited form of one-parent-one-child (1p1c) [package relay][topic package relay] that
  doesn't require any changes to the P2P protocol.  Imagine Alice has a
  parent transaction below any of her peer's [BIP133][] feefilter
  settings, discouraging her from relaying it out of the knowledge that
  none of her peers will accept it.  She also has a child transaction
  that pays enough feerate alongside its parent for both of them to be
  above the feefilter.  Alice and her peer perform the following
  process:

  - Alice relays the child transaction to her peer.

  - Her peer realizes it doesn't have the transaction's parent, so it
    puts the transaction into its _orphan pool_.  All versions of
    Bitcoin Core for over a decade have had an orphan pool where they
    temporarily store a limited number of transactions that were
    received before their parents.  This compensates for the fact that,
    on a P2P network, transactions can sometimes naturally be received
    out of order.

  - A few moments later, Alice relays the parent transaction to her
    peer.

  - Before this merged PR, the peer would notice that the parent's
    feerate was too low and refuse to accept it; now that it had
    evaluated the parent transaction, it would also remove
    the child transaction from the orphan pool.  After this PR, the peer
    notices that it has a child for the parent in its orphan pool and
    evaluates aggregate feerate of both transactions together, allowing
    them both into the mempool if that feerate is above its floor (and
    if they're both otherwise acceptable according to the node's local
    policy).

  It's known that this mechanism can be defeated by an attacker.
  Bitcoin Core's orphan pool is a circular buffer that can be added to
  by all of its peers, so an attacker who wants to prevent this type of
  package relay can spam peers with many orphan transactions,
  potentially leading to a fee-paying child transaction being evicted
  before it's parent is received.  A [follow-up PR][bitcoin core #27742]
  may give each peer exclusive access to part of the orphan pool to
  eliminate this concern.  See also this newsletter's _Bitcoin PR Review
  Club_ section for another related PR.
  Additional improvements requiring changes to the P2P protocol are
  described in [BIP331][]. {% assign timestamp="26:33" %}

- [Bitcoin Core #28016][] begins waiting for all seed nodes to be polled
  before polling DNS seeds.  Users can configure both seed nodes and DNS
  seeds.  A seed node is a regular Bitcoin full node; Bitcoin Core can
  open a TCP connection to the node, request a list of addresses for
  potential peers, and close the connection.  A DNS seed returns IP
  addresses for potential peers over DNS, allowing that information to
  travel and be cached across the DNS network so the owner of the DNS
  seed server doesn't learn the IP address of the client requesting the
  information.  By default, Bitcoin Core attempts to connect to peers
  whose IP addresses it has already learned about; if none of those
  connections are successful, it polls the DNS seeds; if none of the DNS
  seeds are reachable, it contacts a set of hardcoded seed nodes.  Users
  may optionally provide their own list of seed nodes to contact.

  Before this PR, if a user configured polling of seed nodes and kept
  the default configuration to also use DNS seeds, they would both be
  contacted in parallel and whichever was faster would dominate the peer
  addresses that the node would try.  Given the lower overhead of DNS
  and the fact that results might already be cached by a server
  physically near the user, DNS would usually win.  After this PR, seed
  nodes are given preference, due to the belief that a user who sets a
  non-default `seednode` option would prefer the results of that option over
  default results. {% assign timestamp="53:05" %}

- [Bitcoin Core #29623][] makes various improvements to warning users if
  their local time seems to be more than 10 minutes out of sync with the
  time of their connected peers.  A node with a bad clock might
  temporarily reject valid blocks, which can lead to several potentially
  severe security problems.  This is a follow up to the removal of
  network adjusted time from consensus code (see [Newsletter
  #288][news288 time]). {% assign timestamp="57:00" %}

## Corrections

The example script for lamport signing ECDSA signature verification
originally used `OP_CHECKSIG` but was updated after publication to use
`OP_CHECKSIGVERIFY`; we thank Antoine Poinsot for reporting our error.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30012,28016,29623,27742,28970" %}
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[libsecp256k1 v0.5.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.0
[heilman lamport]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+XyW8wNOekw13C5jDMzQ-dOJpQrBC+qR8-uDot25tM=XA@mail.gmail.com/
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[poelstra lamport1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZjD-dMMGxoGNgzIg@camus/
[der encoding]: https://en.wikipedia.org/wiki/X.690#DER_encoding
[heilman lamport2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+UnxB2vKQpJAa-z-qGZQfpR1ZeW3UyuFFZ6_WTWFYGfjw@mail.gmail.com/
[poelstra lamport2]: https://gnusha.org/pi/bitcoindev/Zjo72iTDYjwwsXW3@camus/T/#m9c4d5836e54ed241c887bcbf3892f800b9659ee2
[news300 secp]: /en/newsletters/2024/05/01/#libsecp256k1-1058
[news288 time]: /en/newsletters/2024/02/07/#bitcoin-core-28956
[news141 key hiding]: /en/newsletters/2021/03/24/#p2pkh-hides-keys
[review club 30000]: https://bitcoincore.reviews/30000
