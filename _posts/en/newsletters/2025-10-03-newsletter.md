---
title: 'Bitcoin Optech Newsletter #374'
permalink: /en/newsletters/2025/10/03/
name: 2025-10-03-newsletter
slug: 2025-10-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:schmidty

## News

FIXME:harding

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Draft BIPs for Script Restoration:** Rusty Russell posted to the Bitcoin-Dev mailing list a [summary][rr0]
  and four BIPs ([1][rr1], [2][rr2], [3][rr3], [4][rr4]) in various stages of
  draft relating to a proposal to restore Script's capabilities in a new
  [tapscript][topic tapscript] version. Russell has previously [spoken][rr atx] and [written][rr
  blog] about these ideas. Briefly, this proposal aims to restore enhanced programmability
  (including [covenant][topic covenants] functionality) to Bitcoin while avoiding some
  of the trade-offs required in more narrowly scoped proposals.

  - _Varops budget for script runtime constraint:_ The [first BIP][rr1] is
    fairly complete and proposes assigning a cost metric to nearly all Script
    operations, similar to the SegWit sigops budget. For most operations in
    Script the cost is based on the number of bytes written to the node's RAM
    during execution of the opcode by a naive implementation. Unlike the sigops
    budget, the cost for each opcode depends on the size of its inputs - hence
    the name "varops". With this unified cost model, many limits currently used
    to protect nodes from excessive Script validation cost can be raised to the
    point that they are impossible or nearly impossible to hit in practical
    scripts.

  - _Restoration of disabled script functionality (tapscript v2):_ The [second BIP][rr2]
    is also fairly complete (aside from a reference implementation) and
    details the restoration of opcodes [removed][misc changes] from Script back
    in 2010, as required to protect the Bitcoin network from excessive Script
    validation cost. With the varops budget in place, all of these opcodes (or
    updated versions of them) can be restored, limits can be raised, and numbers
    can be made arbitrary length.

  - _OP_TX:_ The [third BIP][rr3] is a proposal for a new general
    introspection opcode. `OP_TX` allows the caller to get nearly any item or
    items from the transaction into the script stack. By providing direct access to the
    spending transaction, this opcode enables any covenant
    functionality possible with opcodes such as `OP_TEMPLATEHASH` or
    [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify].

  - _New opcodes for tapscript v2:_ The [final BIP][rr4] proposes new
    opcodes which round out the functionality that was either missing or not
    needed when Bitcoin was first launched. For example, adding the ability to
    manipulate taptrees and taproot outputs was not necessary at Bitcoin's
    introduction, but in a world with restored Script it makes sense to have
    these capabilities as well. Brandon Black [noted][bb1] an omission in the
    specified opcodes needed to fully construct taproot outputs. Two of the
    proposed opcodes seem likely to require their own full BIPs: `OP_MULTI` and
    `OP_SEGMENT`.

  `OP_MULTI` modifies the subsequent opcode to operate on more than its standard
  number of stack items, enabling (for example) a script to add up a variable
  number of items. This avoids the need for a looping construct in Script or for
  an `OP_VAULT` style deferred check while enabling value flow control and
  similar logic.

  `OP_SEGMENT` (if present) modifies the behavior of `OP_SUCCESS` such that
  instead of the whole script succeeding if an `OP_SUCCESS` is present, only the
  segment succeeds (bounded by script start, `OP_SEGMENT`, ..., and script end).
  This enables the possibility of scripts with a required prefix, including
  `OP_SEGMENT`, and an untrusted suffix.

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

{% include snippets/recap-ad.md when="2025-10-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[rr0]: https://gnusha.org/pi/bitcoindev/877bxknwk6.fsf@rustcorp.com.au/
[rr1]: https://gnusha.org/pi/bitcoindev/874isonniq.fsf@rustcorp.com.au/
[rr2]: https://gnusha.org/pi/bitcoindev/871pnsnnhh.fsf@rustcorp.com.au/
[rr3]: https://gnusha.org/pi/bitcoindev/87y0q0m8vz.fsf@rustcorp.com.au/
[rr4]: https://gnusha.org/pi/bitcoindev/87tt0om8uz.fsf@rustcorp.com.au/
[rr atx]: https://www.youtube.com/watch?v=rSp8918HLnA
[rr blog]: https://rusty.ozlabs.org/2024/01/19/the-great-opcode-restoration.html
[bb1]: https://gnusha.org/pi/bitcoindev/aNsORZGVc-1_-z1W@console/
[misc changes]: https://github.com/bitcoin/bitcoin/commit/6ac7f9f144757f5f1a049c059351b978f83d1476
