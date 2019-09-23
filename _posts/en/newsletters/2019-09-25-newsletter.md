---
title: 'Bitcoin Optech Newsletter #65'
permalink: /en/newsletters/2019/09/25/
name: 2019-09-25-newsletter
slug: 2019-09-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests feedback on not allowing P2SH-wrapped
addresses for taproot, describes proposed changes to script resource
limits in tapscript, and mentions a discussion about watchtower storage
costs.  Also included are a selection of popular questions and answers
from the Bitcoin StackExchange and a short list of notable changes to
popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Comment if you expect to need P2SH-wrapped taproot addresses:**
  recent [discussion][p2sh taproot] on the Bitcoin-Dev mailing list
  indicates that the [bip-taproot][] proposal may be amended to disallow
  creating taproot inputs by paying P2SH outputs (the way you can
  currently use P2WPKH and P2WSH inputs created from P2SH outputs).
  Anyone who expects to need P2SH-wrapped taproot should describe their
  planned use case on the mailing list or by contacting the bip-taproot
  author privately.

## News

- **Tapscript resource limits:** the [bip-tapscript][] proposal limits
  transactions to one signature-checking operation (sigop) for every 12.5 vbytes
  the witness data adds to the size of the transaction (plus one free
  sigop per input).  Because signatures are expected to be 16.0 vbytes,
  this limit prevents abuse without affecting normal users.  Compared to
  earlier abuse-prevention solutions, it means any valid taproot
  transaction can be included in a block regardless of how many sigops
  it contains---keeping miner transaction code simple and fast.

    In a mailing list [post][tapscript limits], bip-tapscript author
    Pieter Wuille notes that he and Andrew Poelstra examined other
    resource limits on scripts that were put in place to prevent nodes
    from using an excessive amount of CPU or memory during verification.
    He describes some of their findings and advocates the following rule
    changes:

    > * Replace the separate sigops counter with a "executed sigops must
    >   not exceed (witness size / [12.5 vbytes]) + 1" rule (already in the BIP).
    > * Drop the 10,000 byte limit for script size (and 3,600 byte
    >   standardness limit)
    > * Drop the 201 non-push ops limit per script.
    > * Drop the 100 input stack elements standardness limit and
    >   replace with a (consensus) 1,000 limit.

    The removal of unneeded rules would simplify the construction of
    advanced Bitcoin scripts and the tools necessary to work with them.

- **Watchtower storage costs:** a [discussion][watchtower discussion] on
  the Lightning-Dev mailing list examined the storage requirements for
  current watchtowers as well as watchtowers for proposed
  [eltoo-based][eltoo] payment channels.  In the thread, Christian
  Decker notes that both current watchtowers (as implemented by LND) and
  future watchtowers for eltoo can have essentially O(1) costs (fixed
  costs) per user by having each person use a session key to update
  their latest state information on the watchtower.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why does this coinbase transaction have two OP_RETURN outputs?]({{bse}}90127)
Murch outlines that while there are some restrictions regarding the witness
commitment output, there are no additional script or quantity restrictions
regarding other coinbase transaction outputs.

- [What happens to transactions included in invalid blocks?]({{bse}}90026)
RedGrittyBrick and Murch explain that a transaction's inclusion in an invalid block
does not have any impact on the validity of that transaction or its ability to
be confirmed in subsequent blocks.

- [Why was 550 (MiB) chosen as a minimum storage size for prune mode?]({{bse}}90140)
Behrad Khodayar answers his own question about why 550 (MiB) was chosen
as a minimum storage size for pruned nodes. The storage amount was originally chosen
(pre-segwit) to keep 288 blocks worth of state transition data, about two days worth,
on disk.

- [How do orphan blocks affect the network?]({{bse}}90577) Pieter Wuille
clarifies that since 0.10.0, Bitcoin Core uses [headers-first][] IBD
(initial block download) which eliminates the possibility of orphan blocks
(as defined by the questioner).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16400][] refactors part of the mempool transaction
  acceptance code.  We don't usually cover refactors, but this one has a
  tantalizing comment: "this is in preparation for re-using these
  validation components for a new version of `AcceptToMemoryPool()` that
  can operate on multiple transactions ('package relay')."  Package
  relay could allow nodes to accept a transaction below the node's
  minimum feerate if the transaction came bundled with a child
  transaction whose fee was high enough to pay the minimum feerate for
  both it and its parent.  If widely deployed, package relay would allow
  users who create transactions a long time before broadcasting them
  (e.g. timelocked transactions or LN commitment transactions) to safely
  pay the minimum possible fee.  When it came time to broadcast the
  transaction, they could use Child-Pays-For-Parent (CPFP) fee bumping
  to set an appropriate fee for the current network conditions.

- [BOLTs #557][] updates [BOLT7][] to allow for "extended queries"
  which allow nodes to request that they only receive gossip updates
  that are newer than a specified date or which differ from a specified
  hash.

{% include linkers/issues.md issues="16400,557" %}
[p2sh taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017307.html
[tapscript limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017306.html
[watchtower discussion]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002156.html
[headers-first]: https://bitcoin.org/en/p2p-network-guide#headers-first
