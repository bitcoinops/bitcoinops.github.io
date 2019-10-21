---
title: 'Bitcoin Optech Newsletter #36'
permalink: /en/newsletters/2019/03/05/
name: 2019-03-05-newsletter
slug: 2019-03-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to the announcement of the C-Lightning 0.7
upgrade, notes a service outage for the Bitcoin-Dev mailing list, and
describes a proposed soft fork to eliminate several old problems in the
Bitcoin consensus protocol.  Also included are summaries of notable
commits in popular Bitcoin infrastructure projects.

## Action items

- **Upgrade to C-Lightning 0.7:** the most notable feature of the new
  major release is a plugin system that allows your code to provide
  custom RPCs or run on internal lightningd events.  The release also
  implements protocol enhancements and several bug fixes.  See the
  [release announcement][cl 0.7] for details and consider [upgrading][cl
  upgrade].

## News

- **Bitcoin-Dev mailing list outage:** emails sent to the Bitcoin-Dev
  mailing list are not being relayed to readers.  List administrators
  are attempting to resolve the issue and are also investigating
  alternative list providers.  Other Bitcoin-related lists hosted by
  the Linux Foundation (such as the Lightning-Dev list) don't appear to
  be suffering the same problem.  Future Optech newsletters will mention
  any actions list subscribers need to take in order to continue to
  receive protocol discussion.

- **Cleanup soft fork proposal:** Matt Corallo opened a [Bitcoin Core
  pull request][Bitcoin Core #15482] and attempted to send a [proposed
  BIP][BIP-cleanup] to the Bitcoin-Dev mailing list for a potential
  soft fork to eliminate several edge cases that could allow someone to
  attack the Bitcoin network or its users.  The vulnerabilities have
  been publicly known for years and it's believed that any actual
  attacks would've either been too expensive to be profitable or
  could've been dealt with quickly enough to prevent threatening
  Bitcoin's viability.  Still, it would be best to fix the
  vulnerabilities proactively rather than reactively.

    Optech summarizes the proposal in the following bullet points, but
    we recognize that many readers will be unfamiliar with the details
    of concepts such as `OP_CODESEPARATOR`, `FindAndDelete()`, time warp
    attacks, and merkle tree vulnerabilities, so we've also included an
    appendix to this newsletter that provides additional background on
    these subjects.

    - **Prevent use of `OP_CODESEPARATOR` and `FindAndDelete()` in legacy transactions:**
      nobody is known to be using these two
      features of Bitcoin in legacy (non-segwit) Bitcoin transactions,
      but an attacker can abuse them to significantly increase the
      amount of computational work necessary to verify a non-standard
      transaction, creating blocks that could take half an hour or
      longer to verify.  Most readers will probably never have heard
      about either of these features because neither one of them enables
      any known useful behavior that can't be accomplished in some other
      way, but anyone who does still need `OP_CODESEPARATOR` can use
      the [BIP143][] segwit version of it, which was implemented in a
      way that avoids the computational blowup.  Transactions making use
      of these features have not been mined or relayed by default since
      Bitcoin Core 0.16.1, released in June 2018.

{% comment %}<!--
      ## How long until all bitcoins are released by a timewarp
      ## There are 26 retarget periods per year, about 100 years of subsidy left: 2600
      ## Calculate in days
      In [7]: x = 0
         ...: for i in range(2600):
         ...:     x += 14*(0.25**i)
         ...: print(x)
         ...:
         18.666666666666668 -->{% endcomment %}

    - **Fix the time warp attack:** this attack allows miners controlling
      a majority of hashrate to maintain or decrease mining difficulty even when
      total network hashrate is steady or increasing, allowing them to
      produce blocks faster than targeted by the protocol.  The increase
      in block production would accelerate release of Bitcoin's block
      subsidy, potentially releasing all remaining bitcoins within three
      weeks of the attack starting.  However, the setup for the attack
      would be publicly visible for at least a week before it had any
      effect, so fixing it has not had a high priority in the absence of
      a cartel of miners attempting it.  The proposed soft fork fixes
      the problem by requiring the first block in a new difficulty
      period have a timestamp no earlier than 600 seconds before the
      last block in the previous period.  See also [Newsletter #10][]
      where we mention a mailing list discussion about the topic.

    - **Forbid use of non-push opcodes in scriptSig:** since the July
      2010 [fix][1opreturn fix] for a critical security vulnerability,
      each sciptSig is evaluated down to only data elements before it is
      combined with a coin's scriptPubKey for script verification.  This
      eliminated almost any reason to ever use a non-data-pushing opcode
      in scriptSig (the exception being that it could be slightly more
      efficient for putting duplicate or permutated data elements on the
      stack).  However,
      because Bitcoin still technically allows non-push opcodes in
      scriptSig, this could be abused by an attacker to increase the
      amount of work it takes to verify a transaction included in a
      block.  Forbidding use of non-push opcodes in scriptSig has been
      the default relay and mining policy since 2011 and was forbidden
      by design for payments sent to [BIP16][] P2SH and [BIP141][]
      segwit.

   - **Limit legacy and BIP143 sighashes to the currently defined set:**
     you prove that a transaction is an authorized spend of your
     bitcoins by generating a digital signature that commits to a hash
     of the spending transaction.  However, to enable extra flexibility,
     Bitcoin allows you to use a one-byte *signature hash type* to
     indicate exactly what parts of the transaction (and related data)
     get included in the hash.  Only 6 of the possible 256 values for
     the byte have a defined meaning so far---if you use any other
     value, your signature commits to almost exactly the same data as
     used for `SIGHASH_ALL`.  The one difference is that the signature
     hash must commit to its own sighash flag, which will be different
     for the otherwise-equivalent data and which complicates caching.
     Since the adoption of [BIP141][] segwit, any new sighash types are
     expected to be introduced using new witness versions, so removing the
     ability to specify undefined sighash types allows improved caching
     for reduced node overhead.

   - **Forbid transactions 64 bytes or smaller:** derived elements
     (nodes) in Bitcoin's merkle trees are formed by combining two
     32-byte hash digests into a single 64-byte binary blob and then
     hashing it.  However, the transaction identifier (txid) for a
     64-byte transaction is also produced by hashing a 64-byte binary
     blob in exactly the same way.  This can allow a transaction to
     masquerade as a pair of hashes, or a pair of hashes to masquerade
     as a transaction, creating vulnerabilities for Bitcoin merkle
     proofs and SPV proofs.  As there is no known way to spend bitcoins
     securely with a transaction 64 bytes or smaller, the proposed soft
     fork would forbid such transactions from being included in blocks.

   The proposal plans to use the [BIP9][] activation mechanism, with
   signaling starting on 1 August 2019 and ending a year later if the
   proposal isn't activated.  As this is still a proposal, it will
   need to be evaluated by protocol experts, implemented in a full node
   (see Corallo's [PR][Bitcoin Core #15482]), and willingly adopted by
   users in order to be enforced.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15471][] removes the warning displayed in the GUI and
  via RPC about "Unknown block versions being mined".  This warning was
  meant to inform users that miners and users might be coordinating a
  soft fork activation using [BIP9][] versionbits, allowing the user
  seeing the warning to upgrade their node to understand and enforce the
  new consensus rules when it activated.  However, miners have
  increasingly been using overt ASICBoost that involves using some of
  the version bits as a nonce, as proposed in [BIP320][], causing this
  message to be triggered spuriously.  This merge simply removes the
  warning that was no longer helping users.  Whether the project will
  adopt BIP320, implement a more sophisticated warning system, or
  attempt to use an entirely different solution for signaling of future
  soft forks (such as signaling via the generation (coinbase)
  transaction) has not been decided.

- [C-Lightning #2382][] renames the `listpayments` RPC to
  `listsendpays`.  The command lists the status of all payments you've
  sent, but the previous name confused people who expected it to also
  list received payments.  A new RPC `listpays` is also provided.  At
  present, it provides basically the same information as `listsendpays`,
  but when multipath payments are implemented, it'll collect all
  payment parts into a single JSON object.

  The same PR also allows the `sendpay` RPC to take a `bolt11`
  field that will be saved and returned back to the user if they later
  run the `listpay`, `listsendpays`, or `waitsendpay` RPCs.

## Appendix: consensus cleanup background

The following subsections attempt to provide some background on the
current operation of the Bitcoin Protocol as related to the cleanup soft
fork.

### The time warp attack

{% comment %}<!--
#!/bin/bash

_median() {
  if [ $# -ne 11 ]
  then
    echo ERROR: wrong number of timestamps specified
    exit
  fi
  echo "$@" | sed 's/ /\n/g' | sort -n | numaverage -M
}
## Basic idea
_median 1 2 3 4 5 6 7 8 9 10 11

## Initial state
_median 1 1 1 1 1 1 2 2 2 2 2

## Immediately after a stamp of 12
_median 1 1 1 1 1 2 2 2 2 2 12

## Point before next num needs to be 4
_median 1 2 2 2 2 2 12 3 3 3 3

## Point before the next num needs to 5
_median 2 12 3 3 3 3 3 4 4 4 4

## End of this 11-block set beginning with "12"
_median 12 3 3 3 3 3 4 4 4 4 5

-->{% endcomment %}

The consensus rules implemented in Bitcoin 0.1 and all later versions
require that a block must have a timestamp greater than the median of
the previous 11 blocks.  So if the previous blocks had timestamps of {1,
2, 3, 4, 5, 6, 7, 8, 9, 10, 11}, the next block must contain a time
stamp of 7 or greater (but 12 would be a natural fit).

However, what if miners created timestamps of {1, 1, 1, 1, 1, 1, 2,
2, 2, 2, 2}?  Then the next block could contain a time stamp of 2 or
greater.  But what if you put in a time stamp of 12 anyway?  Then the
next sequence of blocks with minimally-increasing timestamps would look
like: {12, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5}.  From the perspective of
someone looking at this sequence, it would look like you time warped
into the past.  You could repeat this trick for as long as you wanted to
occasionally insert a block with a high timestamp into a sequence of
blocks that otherwise minimized timestamp increments.

This is notable because the Bitcoin 0.1 consensus rules we continue to
use also adjust difficulty by looking at the timestamps in just the
first and last blocks in a 2,016-block retarget period---not any of the
intervening blocks.  So if miners use the above technique to prepare a
sequence of low-timestamp blocks, they can give the first block in the
period a low timestamp (say 8 weeks ago) and the last block in the
period a current timestamp so that the consensus algorithm thinks those
two blocks were mined 8 weeks apart---causing the algorithm to reduce
difficulty to 1/4 the current value (the maximum reduction allowed
in a single difficulty adjustment).

By repeating this trick over and over, miners could eventually reduce
difficulty to its absolute minimum value---although it's easy to believe
Bitcoin would become useless before they finished as thousands of blocks
were produced per second and the remainder of its 21 million BTC subsidy
was drained.  Part of what prevents this attack now is that miners would
need to publish blocks with minimally-increasing timestamps for a large
part of a regular-length two-week retarget period before they could
start creating shorter-duration retarget periods.  This would hopefully
give Bitcoin developers time to create a simple patch (like the one
proposed) and users time to implement it through emergency upgrades of
their nodes.

The proposed soft fork works by requiring the first block in a new
retarget period have a timestamp no earlier than 600 seconds before
its previous block (the last block in the previous period).  This means
miners can only set an artificially-low timestamp for the first block in
a retarget period if they also set an artificially-low timestamp for the
last block in the previous period---but putting a low timestamp in the
previous period would've *raised* difficulty then by as much as they'll
be able to lower it at the end of the current period, making any such
attempt worse than useless.

However, if it actually did take a long time to mine all the blocks in a
retarget period due to a natural loss of hashrate, the retarget formula
will still work as expected for lowering difficulty.

Most miners using current software will probably follow this rule
automatically, but upgrading will be recommended to ensure that they do.
Lightweight clients may also wish to enforce the rule in case miners
fail to enforce it themselves (as [happened in 2015][4 july fork],
causing a temporary fork of 6 blocks followed by several shorter forks).

More information:

- [Article about Bitcoin timestamp reliability][lopp timestamp] by
  Jameson Lopp

- [Proposal to use timewarp to eliminate the need for hard forks][Friedenbach proposal]
  by Mark Friedenbach; see also our summary
  in [Newsletter #16][] - the proposed cleanup soft fork eliminates the
  ability to use this controversial idea

### Merkle tree attacks

Bitcoin uses a *merkle tree* to connect all the transactions in a block
to a 32-byte hash, called the *merkle root*, that's included in the
block header.  The merkle tree allows someone with a full block to
prove to someone with just a transaction that the transaction was
included in a block by producing a series of 32-byte hashes connecting
the transaction to the merkle root.

However, the 32-byte hashes are used in pairs (64 bytes of data), and a
carefully-constructed Bitcoin transaction can also be 64 bytes, making
it possible to convince the user that a particular pair of hashes is a
transaction or vice versa.  In either case, the user can be tricked into
accepting what looks like a transaction that's part of the most
Proof-of-Work (PoW) chain but which is not actually part of the chain
and which has never been verified by a full node.

{% comment %}<!--
A minimal transaction:

4 version
1 number of inputs
36 outpoint
1 size of scriptSig
_ scriptSig
4 sequence
1 number of outputs
8 amount
1 size of scriptPubKey
_ scriptPubKey
4 nLockTime
====
60 bytes

-->{% endcomment %}

The proposed soft fork solves the problem by simply invaliding any
transaction 64 bytes or smaller.  This is reasonable because the
required fields for a transaction consume a
minimum of 60 bytes.  In a 64-byte transaction, that leaves only 4 bytes
free in the scriptPubKey field to secure the funds for the recipient.
There is no known way to do that securely in so few bytes, so 64 byte or
smaller transactions can't have any security
and there's no reason anyone would use them other than for an attack.
Such transactions have not been relayed or mined by Bitcoin Core defaults since 2010,
so miners don't need to change their transaction selection software as
long as they haven't changed the hardcoded defaults.

The rule only applies to the *stripped size* of the transaction, which
is the transaction without any of the segwit parts.  Because the minimum
stripped size of a segwit transaction is the same as it is for legacy
transactions, and because scriptPubKey is not a segwit discounted field,
the above logic also shows that there's no secure way to use segwit
transactions smaller than 64 bytes.  Bitcoin Core RPCs that return
decoded data about a transaction, such as `getrawtransaction`, print the
stripped size in the `strippedsize` field.

Miner generation (coinbase) transactions must include extra data beyond
what's required for normal transactions, so their minimum size has been
64 bytes since the 2012 activation of [BIP34][].  The proposed cleanup
soft fork requires them to be only one byte larger than this minimum
size.  Any generation transaction for blocks containing segwit inputs---which
has been almost all blocks for over a year now--- has a minimum size
over 100 bytes, so any miner creating segwit blocks is guaranteed to
pass this rule.

More information:

- [CVE-2017-12842 description][cve-2017-12842 description] by Sergio Demian
  Lerner

- [Mailing list discussion][bitcoin-dev merkle tree] by various authors

### Legacy transaction verification

In 2015 a block was mined containing a transaction almost 1 MB in size,
taking about 25 seconds to verify on a contemporary desktop.  Besides
its large size, the transaction was ordinary in every way, but it still
took about 10 times longer to verify than an equivalent-size block full
of smaller transactions.  The reason is that verifying each
signature-containing input in a legacy transaction requires generating a
hash over part of the transaction's data.  The almost 1 MB transaction
contained 5,570 inputs, requiring hashing slight variations on the same
data 5,570 times.

Unfortunately, the Bitcoin Protocol also provides rarely-used features
that can be exploited to require the same tweaking and re-hashing for
each different signature-checking operation (sigop) executed within each
input.  As each input could require dozens or even hundreds of sigops,
this significantly magnifies the effect of this attack.

Specifically, the `OP_CODESEPARATOR` opcode requires changes to how a
signature commits to its executed script but does so inefficiently by
committing to a separate copy of large parts of the entire transaction
(e.g. almost 1.00 MB in the worst case each time a sigop is run).  The
[BIP143][] segwit reimplementation of this feature fixes the problem for
segwit users by committing directly to the executed script, which can be
no more than 10,000 bytes (0.01 MB).

Even more work can be required if signatures (or things that pretend
to be signatures) are included directly in a scriptPubKey as this will
cause an internal `FindAndReplace()` operation to modify the
executed script and again cause sigops to commit to a separate copy of
almost the entire transaction.  Because a secure signature in Bitcoin
commits to the scriptPubKey it spends, and because a signature in a
scriptPubKey can't commit to itself, there's no legitimate reason to
check a signature included in a scriptPubKey.  [BIP143][] segwit
addresses this problem for its spends by simply specifying that
`FindAndReplace()` shall not be used.

Finally, the original Bitcoin Protocol also allows an attacker to add
non-push opcodes to scriptSig to use up to an additional 20,000 sigops
in a block as well as perform other operations (such as using `OP_DUP`
(duplicate)) to increase the amount of verification work that needs to
be done.

Combining all of these problems together makes it possible for a
well-prepared attacker to create blocks that take a long time to verify
even on fast hardware.  Optech doesn't know how long the worst case is,
as researchers keep their example scripts private to avoid arming
attackers.  We've confidently heard that blocks can be created that take
more than half an hour to verify on fast modern hardware.  (Before the
correction of other known problems with the above mechanisms, tests show
that it was possible to create blocks that took [several hours to
verify][sdl findanddelete].)  An attacking miner could use these
problems to denial-of-service attack verification nodes and other
miners, possibly finding ways to profit from the situation.  However,
because the attacks involve rarely-used Bitcoin features, any actual
attack would probably be met by a soft fork to immediately disable the
features---ensuring Bitcoin would return to normal as soon as the fork
activated.

We have no way to solve the problem of each legacy input requiring the
hashing of a slightly different set of transaction data without
forbidding the use of legacy transaction signatures altogether, but the consensus
cleanup soft fork proposes to prevent the magnifications of the problem
by forbidding use of `OP_CODESEPARATOR` in legacy inputs, the behavior
that triggers `FindAndReplace()`, and the ability to use non-data
pushing opcodes in scriptSig.  Many developers believe this is
acceptable because there are no known productive uses of the behavior,
there's no onchain activity visible of anyone using them, and because
people who want to play with `OP_CODESEPARATOR` can still do so using
the non-problematic version available in segwit.  Together with
improvements in caching, this could put worst-case block verification
into the range of seconds rather than minutes.

More information:

- [The Megatransaction][megatransaction] by Rusty Russell - a block that
  took 25 seconds to verify

- [CVE-2013-2292 description][] by Sergio Demian Lerner - a theoretical
  block that was hypothesized to take three minutes to verify

- [Speculations on `OP_CODESEPARATOR`][todd codesep] by Peter Todd -
  information about how `OP_CODESEPARATOR` was used before the soft fork
  to fix the `1 OP_RETURN` bug and whether Nakamoto had thought to use
  it to enable signature delegation (the ability for the authorized
  signers of an output to give someone else permission to spend it
  without creating an onchain transaction)

- [`1 OP_RETURN` bug description][1return] - a fixed bug that allowed
  anyone to spend anyone else's bitcoins.  Called "by far the worst
  security problem Bitcoin ever had".  Satoshi Nakamoto's
  [fix][1opreturn fix] for this bug involved separating the
  evaluation of scriptSig from each spend's corresponding scriptPubKey,
  practically eliminating any use for `OP_CODESEPARATOR` and
  `FindAndDelete()`

## Corrections

An earlier version of this newsletter incorrectly reported that an
undefined sighash flag allowed a signature to commit to any hash.
Instead it must commit to the same data as the default `SIGHASH_ALL`
flag's algorithm.  We thank Russell O'Connor and Pieter Wuille for
independently reporting this error.

{% include references.md %}
{% include linkers/issues.md issues="15482,2382,15471" %}
[bip-cleanup]: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki
[1return]: https://bitcoin.stackexchange.com/questions/38037/what-is-the-1-return-bug
[todd codesep]: https://bitcointalk.org/index.php?topic=255145.msg2773654#msg2773654
[megatransaction]: https://rusty.ozlabs.org/?p=522
[sdl findanddelete]: https://bitslog.wordpress.com/2017/01/08/a-bitcoin-transaction-that-takes-5-hours-to-verify/
[cl 0.7]: https://blockstream.com/2019/03/01/clightning-07-now-with-more-plugins/
[cl upgrade]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.0
[lopp timestamp]: https://medium.com/@lopp/bitcoin-timestamp-security-8dcfc3914da6
[friedenbach proposal]: http://freico.in/forward-blocks-scalingbitcoin-paper.pdf
[bitcoin-dev merkle tree]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016091.html
[CVE-2013-2292 description]: https://bitcointalk.org/?topic=140078
[4 july fork]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[CVE-2017-12842 description]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[1opreturn fix]: https://github.com/bitcoin/bitcoin/commit/73aa262647ff9948eaf95e83236ec323347e95d0#diff-8458adcedc17d046942185cb709ff5c3R1114
