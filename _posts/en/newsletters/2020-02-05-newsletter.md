---
title: 'Bitcoin Optech Newsletter #83'
permalink: /en/newsletters/2020/02/05/
name: 2020-02-05-newsletter
slug: 2020-02-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the release of Eclair 0.3.3, requests
help testing a Bitcoin Core maintenance release, links to a new tool for
experimenting with taproot and tapscript, summarizes discussion about
safely generating schnorr signatures with precomputed public keys, and
describes a proposal for interactive construction of LN funding
transactions.  Also included is our regular section about notable
changes to popular Bitcoin infrastructure projects.

## Action items

- **Upgrade to Eclair 0.3.3:** this new release includes support for
  [multipath payments][topic multipath payments], deterministic builds
  for eclair-core (see the [PR description][eclair1295] below), experimental support
  for [trampoline payments][topic trampoline payments], and various minor
  improvements and bug fixes.

- **Help test Bitcoin Core 0.19.1rc1:** this upcoming maintenance
  [release][bitcoin core 0.19.1] includes several bug fixes.
  Experienced users are encouraged to help test for any regressions or
  other unexpected behavior.

## News

- **Taproot and tapscript experimentation tool:** Karl-Johan Alm
  [posted][alm btcdeb] to the Bitcoin-Dev list about an experimental branch of his
  [btcdeb][] tool that supports creating and executing [taproot][topic
  taproot] and [tapscript][topic tapscript] outputs using a command line
  tool named `tap`.  For more information, see his detailed
  [tutorial][tap tutorial].

{% comment %}<!-- Timeline:
1/26 15:29 gmaxwell
https://github.com/bitcoin-core/secp258k1/pull/558#discussion_r371027220
"shouldn't this present an interface that takes the pubkey as an
argument,"

1/26 16:05 jonasnick
"Note that in that case we'll need to add the pubkey as extradata to the
deterministic nonce function, otherwise calling sign with the wrong
public key may leak the secret key through an (invalid) signature."

1/27 18:36 #secp256k1
[6:36:02 pm] <gmaxwell> but it's not really a problem in ed25519 because the only thing it does with the public key is stuffs it into the e hash, and presumably it stuffs the same data into the nonce hash?  (if it doesn't they're pants on head stupid and should be shot)
[...]
[6:37:49 pm] <gmaxwell> okay the ed25519 people should be shot, it's an input to e and not an input to their nonce function
[6:38:02 pm] <gmaxwell> (I just checked)

1/28 01:49 https://moderncrypto.org/mail-archive/curves/2020/001012.html
-->{% endcomment %}

- **Safety concerns related to precomputed public keys used with schnorr signatures:** [libsecp256k1 PR
  #558][libsecp256k1 #558] proposes adding [BIP340][]-compatible
  [schnorr signature][topic schnorr signatures] creation and
  verification to the libsecp256k1 library used by Bitcoin Core and
  several other Bitcoin programs.  Since BIP340 requires signatures
  to commit to the public key that will be used to validate the signature,
  the current proposed signature function uses the private key to derive
  the necessary public key.  Gregory Maxwell [noted][gmaxwell pubkey]
  that programs generating signatures will usually already know the
  appropriate public key, so the function can save CPU time by accepting
  the public key as a parameter.

  Jonas Nick [replied][nick nonce] that the approach was reasonable,
  but doing it safely would require including the public key in the
  data used to create a deterministic nonce.  Otherwise, if an attacker
  could obtain two signatures created by the same private key for two
  different public keys, and all of the other data remained the same,
  you would unknowingly be reusing a nonce and the attacker could
  derive your private key and steal your bitcoins.  Discussion about
  addressing problem would continue in a [separate issue][nonce
  issue].

  Additionally, as it became clear that implementations that accept
  public keys without verifying them could end up producing reused
  nonces, Gregory Maxwell [posted][curves post] to a mailing list
  dedicated to [ed25519][] implementations (which also use a variation
  of schnorr signatures) about the risk.  Ed25519 co-author Daniel
  Bernstein replied that "the standard defense against faults is for
  the signer to verify each signature."  This would detect that an
  invalid public key had been provided, and some wallets such as
  Bitcoin Core certainly do perform this check for any signatures they
  generate even for the currently-used ECDSA signature algorithm.
  However, the computational overhead of this approach may not be
  acceptable to many applications and there remains a risk that
  inexperienced developers will not know to
  perform this step, and so it seems preferable to use Jonas Nick's
  suggestion (relayed by Maxwell) of including the public key in the
  data used to produce a deterministic nonce.

  So far, no changes have been made to BIP340 as a direct result of
  this issue, but proposed changes such as including the public key in
  the deterministic nonce algorithm are being discussed.

- **Alternative x-only pubkey tiebreaker:** As the above issue was
  discussed, Pieter Wuille [proposed][pubkey pr] slightly speeding up
  derivation of the public key from the private key by changing the
  algorithm used to choose which variant of a public key to use when
  only the key's x-coordinate is known (see previous discussion about
  32-byte public keys in [Newsletter #59][news59 32bpk]).  Because this
  is a significant change, the proposal also changes the tagged hash
  used to generate part of the signature.

  This change hasn't yet been announced to the mailing list, probably
  because developers are evaluating what other changes they might want
  to make at the same time in order to address the safety of providing
  precomputed public keys to the signature function.

- **Interactive construction of LN funding transactions:** in the
  current LN protocol, the onchain transaction that opens a new channel
  is created entirely by a single party.  This has the advantage of
  being simple but the disadvantage that payments in the channel can
  initially only flow in one direction---from the party funding the
  channel to the other party.  Lisa Neigut has been working on a
  dual-funding [protocol][bolts #524] where both parties can contribute
  funds to opening the channel, which may be especially useful for
  creating channels where payments can initially flow in both
  directions, improving the liquidity of the network.

  However, the dual-funding proposal is complicated, so Neigut started
  a [thread][neigut thread] on the Lightning-Dev mailing list this
  week about splitting out one aspect of the new protocol: the ability
  for LN nodes to collaboratively construct a funding transaction.
  This has previously been described as improving security (see
  [Newsletter #78][news78 dual-funding]) and Neigut notes that the
  collaboration mechanism could also help support related work on
  batched closings (mutually closing multiple channels at the same
  time) and [splicing][topic splicing] (moving funds into or out of a
  channel without affecting the spendability of other funds already in
  the channel).  Replies to Neigut's proposal included:

  * A suggestion to set the nLockTime field's value to a recent or
    upcoming block height in order to implement anti-fee sniping which
    helps disincentivize block chain reorganizations and which will
    help funding transactions blend in with other wallets that have
    already implement anti-fee sniping (including LND's sweeping mode,
    see [Newsletter #18][news18 lnd afs]).

  * More broadly, a suggestion to implement a common set of values for
    free parameters in a transaction (such as nVersion, nSequence,
    nLockTime, input ordering, and output ordering) with other
    collaborative transaction creation systems (such as
    [coinjoin][topic coinjoin] software).  This would avoid producing
    any obvious indicators that an LN funding transaction is being
    created (especially if [taproot][topic taproot] is adopted, as
    mutual LN close transactions can look like single-sig spends).

  * {:#psbt-interaction} A suggestion to communicate proposed transaction details using
    [BIP174][] Partially-Signed Bitcoin Transactions ([PSBTs][topic
    psbt]).  Though Neigut replied that she thinks PSBT is "a bit
    overweight for transaction collaboration between two peers."

  * {:#podle} A sub-discussion about how to avoid probing where Mallory starts
    the process of opening a dual-funded channel with Bob but then
    aborts after she receives the identity of one of Bob's UTXOs.
    By aborting before the funding transaction is complete, Mallory
    can costlessly learn which network identity (node) owns which
    UTXOs.

    One proposal to fix this would require the person proposing to
    open the channel (e.g. Mallory) to provide their UTXO(s) in a
    ready-to-spend state so that probing would cost money (e.g.
    transaction fees).  A downside of this approach is that the
    construction proposed would be easily identifiable by block
    chain analysis, making it easy to determine when a dual-funded
    channel was opened.

    Another proposal was to use [PoDLE][], which was originally
    developed for JoinMarket based on a suggestion by Gregory
    Maxwell.  This protocol allows an initiating user such as
    Mallory to commit to a UTXO in a way that prevents anyone from
    identifying that UTXO.  The participating user, such as Bob,
    publishes the commitment across the network (e.g.  the
    JoinMarket network) so that nobody else will start a session
    with Mallory while she's using that particular UTXO.  Then Bob
    asks Mallory to identify her UTXO and, if it's a valid UTXO that
    matches her commitment, Bob discloses his UTXO to Mallory so
    that they can proceed with the protocol (e.g.  a coinjoin).  If
    Mallory aborts the protocol before completion, the commitment
    previously published across the network prevents her from being
    able to start a new session with any other user and so learn
    their UTXO.  Mallory's only option is to spend her coins from
    herself to herself in order to generate a new UTXO---a process
    that costs her money and so limits her ability to spy on users.
    (Note, though, that PoDLE as implemented in JoinMarket allows
    Mallory up to three retries by default so honest users aren't
    penalized for occasional accidental failures, such as a loss of
    network connectivity.)  The idea is to adapt this protocol for
    LN in order to prevent attackers from learning which available
    UTXOs are controlled by LN users.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16702][] allows Bitcoin Core to choose peers based
  on their _Autonomous System Number_ (ASN) instead of IP address prefix.
  Differentiating peers based on ASN may make it more difficult for an adversary to successfully
  execute certain [eclipse attacks][topic eclipse attacks] (such as the [Erebus
  attack][erebus]). This new feature is disabled by default---to use ASN-based
  peering, the user must provide an ASN table file, which can be generated using
  [asmap][]. Future releases may include an ASN table file generated and
  reviewed by the Bitcoin Core developers. See [our summary of an IRC discussion
  in #bitcoin-core-dev][asn peer selection] for more details of this approach.

- [Bitcoin Core #17951][] keeps a rolling bloom filter of the
  transactions confirmed in recent blocks.  When one of a node's peers
  advertises a transaction, the node checks the transaction's txid
  against the filter.  If there's a match, the node skips downloading
  the transaction (since it's already been confirmed).  This replaces a
  previous mechanism for determining whether or not to download a
  transaction; that method wasted bandwidth by redundantly downloading
  transactions which had already been confirmed if their outputs had
  already been spent.

- [C-Lightning #3315][] adds a `dev-sendcustommsg` RPC and `custommsg`
  plugin hook that allows sending custom network protocol messages from
  a node to any of its peers.  The feature can only be used for messages
  not already handled internally by the C-Lightning daemon, and also
  only for messages with an odd-numbered type (following the [it's ok to
  be odd][] rule).  Note: this feature should not be confused with
  applications like [WhatSat][] that send chat messages across a network
  route inside onion-encrypted payments; this merged PR only allows
  sending protocol messages to a node's direct peers.

- [Eclair #1295][] allows the eclair-core module to be deterministically
  built.  For details on building, see their [documentation][eclair
  deterministic doc].  ACINQ has also announced their intention to make
  it possible to reproducibly build their other software, such as
  Eclair Mobile and Phoenix.<!-- source:
  https://github.com/ACINQ/eclair/releases/tag/v0.3.3 -->

- [Eclair #1287][] adds fields to the database in order to improve the
  tracking of expenses related to [multipath payments][topic multipath
  payments] and [trampoline payments][topic trampoline payments].

- [Eclair #1278][] allows users to skip using SSL when connecting to an Electrum-style
  block chain data server if the server is running as a Tor hidden
  service, since Tor provides its own authentication and encryption.

## Acknowledgments and edits

We thank Adam Gibson for reviewing a draft of the section about PoDLE.
Any errors in the published text are the fault of the newsletter author.
Some text was added after publication by the suggestion of Pieter Wuille
to clarify the tradeoffs of verifying generated signatures before publishing them.

{% include references.md %}
{% include linkers/issues.md issues="558,524,16702,17951,3315,1295,1287,1278" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[it's ok to be odd]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#lightning-message-format
[whatsat]: https://github.com/joostjager/whatsat
[news59 32bpk]: /en/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[news78 dual-funding]: /en/newsletters/2019/12/28/#ln-cve
[news18 lnd afs]: /en/newsletters/2018/10/23/#lnd-1978
[eclair deterministic doc]: https://github.com/ACINQ/eclair/blob/master/BUILD.md#build
[eclair1295]: #eclair-1295
[alm btcdeb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017600.html
[btcdeb]: https://github.com/kallewoof/btcdeb/tree/taproot
[tap tutorial]: https://github.com/kallewoof/btcdeb/blob/taproot/doc/tapscript-example-with-tap.md
[gmaxwell pubkey]: https://github.com/bitcoin-core/secp256k1/pull/558#discussion_r371027220
[nick nonce]: https://github.com/bitcoin-core/secp256k1/pull/558#discussion_r371029200
[nonce issue]: https://github.com/sipa/bips/issues/190
[pubkey pr]: https://github.com/sipa/bips/pull/192
[curves post]: https://moderncrypto.org/mail-archive/curves/2020/001012.html
[ed25519]: https://en.wikipedia.org/wiki/EdDSA
[neigut thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002466.html
[podle]: https://joinmarket.me/blog/blog/poodle/
[asmap]: https://github.com/sipa/asmap
[asn peer selection]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[erebus]: https://erebus-attack.comp.nus.edu.sg/
