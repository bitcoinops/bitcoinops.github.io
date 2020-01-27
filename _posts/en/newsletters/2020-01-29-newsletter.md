---
title: 'Bitcoin Optech Newsletter #82'
permalink: /en/newsletters/2020/01/29/
name: 2020-01-29-newsletter
slug: 2020-01-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the release of LND 0.9.0-beta, asks for
help testing a release candidate for a Bitcoin Core maintenance release,
describes a proposal to break the linkability between UTXOs and
unannounced LN channels, and summarizes a modification to the proposed
`SIGHASH_ANYPREVOUTANYSCRIPT` signature hash that may simplify
management of payments in eltoo-based payment channels.  Also included
are our regular sections for popular Bitcoin StackExchange Q&A and
notable changes to popular Bitcoin infrastructure and documentation
projects.

## Action items

- **Upgrade to LND 0.9.0-beta:** this new major version [release][lnd
  0.9.0-beta] brings improvements to the access control list mechanism
  ("macaroons"), support for receiving [multipath payments][topic
  multipath payments], the ability to send additional data in an
  encrypted onion message (see [Newsletter #81][news81 lnd3900]), native
  rebalancing support (see [Newsletter #74][news74 lnd3739]), support
  for requesting channel close outputs pay a specified address (e.g.
  your hardware wallet; see [Newsletter #76][news76 lnd3655]), and many
  other features and bug fixes.

- **Help test Bitcoin Core 0.19.1rc1:** this upcoming maintenance
  [release][bitcoin core 0.19.1] includes several bug fixes.
  Experienced users are encouraged to help test for any regressions or
  other unexpected behavior.

## News

- **Breaking the link between UTXOs and unannounced channels:** Bastien
  Teinturier [posted][teinturier post] to the Lightning-Dev mailing list about changing
  what data is added to a [BOLT11][] invoice for payments sent to
  unannounced channels---channels that aren't advertised to the LN
  network and which usually don't route payments for other users.  The
  proposed change would remove information from an invoice that could be
  used to identify the channel's deposit UTXO, replacing it with a
  one-time per-invoice keypair and a secret that's derived from the keypair and routed as part of the
  onion-encrypted payment.  This would require special support from both the
  spender and the peer who's able to route to the unannounced channel,
  but other nodes along the routing path would not need to change their
  implementation.  Teinturier requested feedback on the proposal,
  including any suggestions for how to eliminate the need to include an
  encrypted secret in the payment.

- **Layered commitments with eltoo:** Anthony Towns [described][towns
  layered commitments] a potential modification to his previous
  [anyprevout proposal][bip-anyprevout] (a variation of
  [SIGHASH_NOINPUT][topic sighash_noinput]) that could simplify
  [eltoo][topic eltoo]-based LN channels.  As currently proposed,
  eltoo-based LN implementations would need to ensure they don't accept
  a payment whose refund timeout occurs before the payment's
  unilateral-close delay, otherwise a paying node will be able to
  reclaim its payment before the receiving node has a chance to use
  its adaptor signature ("point lock") to legitimately claim the
  payment.  This differs from current-style LN payments where the
  timeout and the delay may be chosen independently.

    To allow eltoo to achieve a similar independence of timeout and
    delay parameters, Towns proposes removing the [BIP341][] commitment
    to the value of the inputs (`sha_amounts`) from signatures created
    using the `SIGHASH_ANYPREVOUTANYSCRIPT` signature hash (sighash)
    flag.  This also requires changes to the script used in eltoo,
    including making use of [tapscript's][topic tapscript] variation of
    the `OP_CODESEPARATOR` opcode.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17492][] causes Bitcoin Core GUI to place a
  Partially-Signed Bitcoin Transaction ([PSBT][topic psbt]) in the
  clipboard if the user attempts to fee bump a transaction in a
  watch-only wallet.  The user can then paste the PSBT into another
  program (such as [HWI][topic hwi]) for signing.

- [C-Lightning #3376][] FIXME:moneyball

- [LND #3809][] adds a `force` parameter to the `BumpFee` RPC so that
  it can include uneconomical UTXOs in the transactions it creates,
  extending the change described in [Newsletter #79][news79 lnd3814].
  Uneconomical UTXOs are UTXOs that cost more to spend than they contain
  in value---it's important that LND be able to spend these if the
  proposed [anchor outputs][topic anchor outputs] fee bumping method is adopted
  into the LN protocol.

- [BIPs #875][] assigns [BIP119][] to the `OP_CHECKTEMPLATEVERIFY`
  proposal.  If the proposal is adopted, users will be able to create
  UTXOs that can only be spent by a specific transaction or set of
  transactions, providing a type of [covenant][topic covenants].  This is
  useful in protocols that temporarily keep payments offchain but
  which need to assure the ultimate receiver that there's no practical
  way to revoke or change the output paying them.

- [BIPs #876][] assigns three BIPs, one to each part of the schnorr-taproot-tapscript
  proposal:

    - [BIP340][] is assigned to "Schnorr Signatures for secp256k1,"
      which describes a signature scheme compatible with the secp256k1
      [elliptic curve][] used by Bitcoin.  The signatures are
      compatible with batch verification and with key and signature
      aggregation schemes such as [MuSig][topic musig].  Schnorr
      signatures are made available for use in the following two BIPs (341 and 342).
      For more information, see the BIP or [schnorr signatures][topic
      schnorr signatures].

    - [BIP341][] is assigned to "Taproot: SegWit version 1 spending
      rules," which describes part of a soft fork proposal for allowing
      users to pay schnorr-style public keys that can be spent either
      using a schnorr-style signature or proof that the key committed to
      a particular script via a merkle tree (along with proof that the
      script's conditions were fulfilled).  For details, see the BIP or
      [taproot][topic taproot].

    - [BIP342][] is assigned to "Validation of Taproot Scripts", which
      describes the rules for evaluating a script used in combination
      with taproot (a *tapscript*).  Almost all operations in tapscript
      are the same as legacy Bitcoin Script, but a few are different.
      For existing users upgrading to tapscript, the most significant
      change is that all signature-checking opcodes (e.g. `OP_CHECKSIG`)
      use schnorr public keys and signatures; also noteworthy is that
      `OP_CHECKMULTISIG` has been removed; script authors can instead
      use a new `OP_CHECKSIGADD` opcode or otherwise redesign their
      scripts.  A few other new rules affect users or rarely-used
      features.  Additionally, tapscript includes several new features
      designed to make future soft fork upgrades of its scripting
      language easier.  For details, see the BIP or [tapscript][topic
      tapscript].

    {% comment %}<!--
    $ git log --oneline --no-merges  802520e...9cf4038 | wc -l
    163

    $ git shortlog -s  802520e...9cf4038 | wc -l
    30  ## devrandom and Orfeas Litos each appear twice, so 28
    -->{% endcomment %}

    Many merges to the BIPs repository include contributions
    from several different people, but this merge had more contributors than
    any we've seen before: it included content and edits from 28
    different people in 163 commits and its credits thank several other
    named contributors, the authors of previous work it builds upon, and
    the many "participants of the [structured reviews]."

- [BOLTs #697][] modifies the sphinx packet construction described in
  [BOLT4][] to fix a privacy leak that may allow a destination node to
  discover the length of the path back to the source node.  See
  [Newsletter #72][news72 leak] for details about the leak.  All three
  implementations tracked by Optech have also updated their code to fix
  the leak: [C-Lightning][news72 cl3246],
  [Eclair][news81 eclair1247], and the [LND-Onion][] library.  <!-- LND
  onion PR mentioned in Newsletter #72 news item, which we already
  linked to, so linking to the PR directly above -->

- [BOLTs #705][] allocates [BOLT1][] message types 32768--65535 for
  experimental and application-specific messages.  It also suggests
  guidelines for implementers, including requesting that
  anyone allocating themselves a message type from that range post the
  numbers they're using to [BOLTs issue #716][bolts #716] to prevent conflicts.

{% include references.md %}
{% include linkers/issues.md issues="17492,3376,3809,875,876,697,705,716" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[structured reviews]: https://github.com/ajtowns/taproot-review
[news72 leak]: /en/newsletters/2019/11/13/#possible-privacy-leak-in-the-ln-onion-format
[news72 cl3246]: /en/newsletters/2019/11/13/#c-lightning-3246
[news81 eclair1247]: /en/newsletters/2020/01/22/#eclair-1247
[lnd-onion]: https://github.com/lightningnetwork/lightning-onion/pull/40
[news81 lnd3900]: /en/newsletters/2020/01/22/#lnd-3900
[news74 lnd3739]: /en/newsletters/2019/11/27/#lnd-3739
[news76 lnd3655]: /en/newsletters/2019/12/11/#lnd-3655
[news79 lnd3814]: /en/newsletters/2020/01/08/#lnd-3814
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002435.html
[towns layered commitments]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002448.html
[elliptic curve]: https://en.bitcoin.it/wiki/Secp256k1
