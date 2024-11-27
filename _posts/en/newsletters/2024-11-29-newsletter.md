---
title: 'Bitcoin Optech Newsletter #331'
permalink: /en/newsletters/2024/11/29/
name: 2024-11-29-newsletter
slug: 2024-11-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes several recent discussions about a
Lisp dialect for Bitcoin scripting and includes our regular sections
with descriptions of popular questions and answers on the Bitcoin Stack
Exchange, announcements of new releases and release candidates, and
summaries of notable changes to popular Bitcoin infrastructure projects.

## News

- **Lisp dialect for Bitcoin scripting:** Anthony Towns made several
  posts about a continuation of his [work][topic bll] on creating a
  Lisp dialect for Bitcoin that could be added to Bitcoin in a soft
  fork.

  - *bll, symbll, bllsh:* Towns [notes][towns bllsh1] that he spent a
    long time thinking about advice from Chia Lisp developer Art Yerkes
    about ensuring a good mapping between high-level code (what
    programmers typically write) and low-level code (what actually gets
    run, typically created from high-level code by compilers).  He
    decided to take a [miniscript][topic miniscript]-like approach where
    "you treat the high-level language as a friendly variation of the
    low-level language (as miniscript does with script)".  The result is
    two languages and a tool:

    - *Basic Bitcoin Lisp language (bll)* is the low-level language
      that could be added to Bitcoin in a soft fork.  Towns says bll is
      similar to BTC Lisp as of his last update (see [Newsletter
      #294][news294 btclisp]).

    - *Symbolic bll (symbll)* is the high-level language that is
      converted into bll.  It should be relatively easy for anyone
      already familiar with functional programming.

    - *Bll shell (bllsh)* is a [REPL][] that allows a user to test
      scripts in bll and symbll, compile from symbll to bll, and execute
      code with debugging capabilities.

  - *Implementing quantum-safe signatures in symbll versus GSR:* Towns
    [links][towns wots] to a [Twitter post][nick wots] by Jonas Nick
    about implementing Winternitz One Time Signatures (WOTS+) using
    existing opcodes and the opcodes specified in Rusty Russell's
    _great script restoration_ (GSR) [proposal][russell gsr].  Towns
    then compares implementing WOTS using symbll in bllsh.  This reduces
    the amount of data that would need to be placed onchain by at least
    83% and potentially by more than 95%.  That could allow the use of
    [quantum-safe signatures][topic quantum resistance] at a cost only
    30x greater than P2WPKH outputs.

  - *Flexible coin earmarks:* Towns [describes][towns earmarks] a
    generic construction compatible with symbll (and probably
    [Simplicity][topic simplicity]) that allows partitioning a UTXO into
    specific amounts and spending conditions.  If a spending condition
    is fulfilled, the associated amount can be spent and the remaining
    value from the UTXO is returned to a new UTXO with the remaining
    conditions.  An alternative condition may also be satisfied to allow
    spending the entire UTXO; for example, this could allow all parties
    to agree to update some of the conditions.  This is a flexible type of
    [covenant][topic covenants] mechanism, similar to Towns's previous
    proposal for `OP_TAP_LEAF_UPDATE_VERIFY` (TLUV, see [Newsletter
    #166][news166 tluv]), but Towns has [written previously][towns
    badcov] that he thinks _covenants_ is "not an accurate or useful
    term".

    Several examples for how these _flexible coin earmarks_ can be used
    are provided, including improvements in the security and usability
    of LN channels (including [LN-Symmetry][topic eltoo]-based
    channels), an alternative to the [BIP345][] version of [vaults][topic
    vaults], and a [payment pool][topic joinpools] design similar to
    that contemplated for use with TLUV but that avoids the problems
    that proposal had with [x-only public keys][topic x-only public
    keys].

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 24.11rc2][] is a releases candidate for the next major
  version of this popular LN implementation.

- [BDK 0.30.0][] is a release of this library for building wallets and
  other Bitcoin-enabled applications.  It includes several minor bug
  fixes and prepares for the anticipated upgrade to the version 1.0 of
  the library.

- [LDK 0.18.4-beta.rc1][] is a release candidate for a minor version of
  this popular LN implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31122][] cluster mempool: Implement changeset interface for mempool

- [Core Lightning #7852][] pyln-client: restore backwards compatibility with CLN prior to 24.08

- [Core Lightning #7740][] askrene: add algorithm to compute feasible flow

- [Core Lightning #7719][] splice: Update funding pubkey on splice lock

- [Eclair #2935][] Add force-close notification

- [LDK #3137][] Implement accepting dual-funded channels without contributing

- [LND #8337][] [1/4] - protofsm: add new package for driving generic protocol FSMs

{% include references.md %}
{% include linkers/issues.md v=2 issues="31122,7852,7740,7719,2935,3137,8337" %}
[news294 btclisp]: /en/newsletters/2024/03/20/#overview-of-btc-lisp
[russell gsr]: https://github.com/rustyrussell/bips/pull/1
[towns bllsh1]: https://delvingbitcoin.org/t/debuggable-lisp-scripts/1224
[repl]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[towns wots]: https://delvingbitcoin.org/t/winternitz-one-time-signatures-contrasting-between-lisp-and-script/1255
[nick wots]: https://x.com/n1ckler/status/1854552545084977320
[towns earmarks]: https://delvingbitcoin.org/t/flexible-coin-earmarks/1275
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[towns badcov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[core lightning 24.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc2
[bdk 0.30.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.0
[ldk 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
