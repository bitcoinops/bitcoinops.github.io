---
title: 'Bitcoin Optech Newsletter #48'
permalink: /en/newsletters/2019/05/29/
name: 2019-05-29-newsletter
slug: 2019-05-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the new proposed
`OP_CHECKOUTPUTSHASHVERIFY` opcode, covers continued discussion of
Taproot, and links to a video presentation about handling increasing
Bitcoin transaction fees.  Also included are our regular sections on bech32 sending
support, top-voted Bitcoin Stack Exchange questions and answers, and
notable changes in popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}
{% include specials/2019-exec-briefing/fees.md %}

## Action items

*None this week.*

## News

- **Proposed new opcode for transaction output commitments:** Jeremy
  Rubin posted to the Bitcoin-Dev mailing list a proposal to soft fork
  in an `OP_CHECKOUTPUTSHASHVERIFY` opcode that allows a Bitcoin address
  to require the transaction spending it include a certain set of
  outputs.  This enables a restricted form of Bitcoin covenants which
  can be used to reduce the amount of data that needs to be placed
  onchain in certain situations, potentially reducing costs or improving privacy in
  those cases.  For details, please see this newsletter's [special section about the
  proposal][].

- **Continued discussion about bip-taproot and bip-tapscript:**
  two comments this week from the Bitcoin-Dev mailing list discussion
  seemed particularly noteworthy:

    - *Final stack empty:* in legacy, segwit, and proposed
      [bip-tapscript][] scripts, a script evaluates successfully if it
      contains exactly[^legacy-cleanstack] one element that is *true*.
      Russell O'Connor [raised][emptystack1] a point he's [raised
      before][emptystack0] and requested that this opportunity be taken
      to require tapscript only evaluate successfully if it ends with an
      empty stack.  Pieter Wuille [replied][emptystack reply] that his
      work on [miniscript][] (see [Newsletter #32][]) showed that, for
      the subset of scripts miniscript will create, this change in
      semantics will at most save 0.25 vbytes per tapscript.  Also,
      although the change may simplify development for anyone
      writing scripts by hand, it's a bit risky as every development
      guide to Script written to date teaches that scripts must
      terminate with a *true* value on the stack.  Wuille summarized,
      "so overall this feels like something with marginal costs, but
      also at most marginal benefits."

    - *Move the oddness byte:* Bitcoin public keys are most naturally
      specified using an X,Y coordinate pair, as was done in the early
      days of Bitcoin with [uncompressed public keys][].  However,
      because a valid pubkey must be on the elliptic curve, it’s
      possible to find both valid Y coordinates (one odd, one even) for
      any given X coordinate given the curve formula. In compressed key
      format, the first byte contains a single bit to specify whether
      the Y coordinate is odd or even, followed by 32 bytes to encode
      the X coordinate. The proposed bip-taproot followed this
      convention and used 33 bytes to encode the taproot output key.

        This week, John Newbery [suggested][smaller v1 spk] that we use some method to
        avoid placing this byte in the scriptPubKey.  Wuille agreed that
        this could be useful and will attempt implementing a variation
        where the bit will be included as part of the taproot witness
        data.  This will reduce the cost create a taproot output by one
        vbyte (making it the same as P2WSH currently). {% comment %}<!-- with either zero
        or 0.25 vbytes additional cost to spend a taproot output.  (harding note: I'm confused by where the bit is being placed, so moving this clause into a comment) -->{% endcomment %}

- **Presentation: A Return to Fees:** During Blockchain Week NYC earlier this
  month, Bitcoin Optech contributor Mike Schmidt gave a presentation about
Bitcoin transaction fees at Optech's first executive-focused briefing.  The
[video for his presentation][vid return to fees] is now available. {{return-to-fees}}

## Proposed transaction output commitments

The [proposed][bip-coshv] opcode `OP_CHECKOUTPUTSHASHVERIFY` allows a
Taproot address to commit to one or more tapscripts that require the
transaction spending them to include a certain set of outputs, a
technique that contract protocol researchers call a *covenant*.
The primary described benefit of this proposed opcode is allowing a
small transaction to be confirmed now (when fees might be high) and have that transaction
trustlessly guarantee that a set of people will receive their actual
payments later when fees might be lower.  This can make it much more
economical for organizations that already implement techniques such as
[payment batching][topic payment batching] to handle sudden fee spikes.

Before we look at the new opcode itself, let's take a moment to look at
how you might accomplish something similar using current Bitcoin
transaction features.

Alice wants to pay a set of ten people but transaction fees are
currently high so that she doesn't want to send ten separate
transactions or even use payment batching to send one transaction
that includes an output for each of the receivers.  Instead, she wants
to trustlessly commit to paying them in the future without having to pay
onchain fees for ten outputs now.  So Alice asks each of the receivers
for one of their public keys and creates an unsigned and unbroadcast *setup* transaction
that pays those keys using a 10-of-10 multisig script.  Then she creates
a child transaction that spends from the multisig output to the
10 outputs she originally wanted to create.  We'll call this child
transaction the *distribution* transaction.  She asks all the receivers
to sign this distribution transaction and she ensures each person
receives everyone else's signatures, then she signs and broadcasts the
setup transaction.

![A setup transaction paying a pre-signed distribution transaction](/img/posts/2019-05-tx-tree-1.png)

When the setup transaction receives a reasonable number of
confirmations, there's no way for Alice to take back her payment to the
10 receivers.  As long as each of the receivers has a copy of the
distribution transaction and all the others' signatures, there's also no
way for any receivers to cheat any other receiver out of a payment.  So
even though the distribution transaction that actually pays the
receivers hasn't been broadcast or confirmed, the payments are
secured by the confirmed setup transaction.  At any time, any
of the receivers who wants to spend their money can broadcast
the distribution transaction and wait for it to confirm.

This technique allows spenders and receivers to lock in a set of
payments during high fees and then only distribute the actual payments when
fees are lower.  According to Bitcoin Core fee estimates at the time of
writing, anyone patient enough to wait a week for a transaction to
confirm (like the distribution transaction above) can save significantly on fees.
Let's look at the example above in that context.  To make later
comparisons to Taproot more fair, we'll assume some form of key and
signature aggregation is being used, such as [MuSig][] or (in theory)
multiparty ECDSA (see [Newsletter #18][]).

{% assign p2wpkh = "A transaction spending one P2WPKH input to two P2WPKH outputs" %}
{% assign batched11 = "A transaction spending one P2WPKH input to eleven P2WPKH outputs, or 9*(8+1+22) more bytes than the two-output P2WPKH transaction" %}
{% assign batched10 = "A transaction spending one P2WPKH input to ten P2WPKH outputs, or 8*(8+1+22) more bytes than the two-output P2WPKH transaction" %}

| | Individual Payments | Batched Payment | Commit now, distribute later |
|-|-|-|-|
| Immediate (high fee) transactions | 10x<abbr title="{{p2wpkh}}">141 vbytes</abbr> | 1x<abbr title="{{batched11}}">420 vbytes</abbr> | 1x<abbr title="{{p2wpkh}}">141 vbytes</abbr> |
| Cost at 0.00142112 BTC/KvB | 0.00204641 | 0.00059687 | 0.00020037 |
| Delayed (low fee) transactions | --- | --- | 1x<abbr title="{{batched10}}">389 vbytes</abbr> |
| Cost at 0.00001014 BTC/KvB | --- | --- | 0.00000394 |
| Total vbytes | 1,410 | 420 | 530 |
| Total cost | 0.00204641 | 0.00059687 | 0.00020431 |
| **Savings compared to previous column** | --- | **71%** | **66%** |

We see that this type of trustlessly delayed payment can save 66% over
payment batching and 90% over sending separate payments.  Note that the
savings could be even larger during periods of greater fee
stratification or with more than ten receivers.

### CheckOutputsHashVerify

The proposed soft fork would add a new opcode,
`OP_CHECKOUTPUTSHASHVERIFY` (abbreviated by its author as `OP_COSHV`
with an extra *S*).  This opcode and a hash digest could be included in
tapleaf scripts, allowing it to be one of the conditions in a Taproot
address.  When that address was spent, if COSHV was executed, the
spending transaction would only be valid if the hash digest of its
outputs matched the hash digest read from the script by COSHV.

Comparing this to our example above, Alice would again ask each of the
participants for a public key (such as a Taproot
address[^taproot-pubkeys]).  Similar to before, she'd create 10 outputs
which each paid one of the receivers---but she wouldn't need to form
this into a specific distribution transaction.  Instead, she'd just hash
the ten outputs together and use the resultant digest to create a
tapleaf script containing COSHV.  That would be the only tapleaf in this
Taproot commitment.  Alice could also use the participants' public keys
to form the taproot internal key to allow them to cooperatively spend
the money without revealing the Taproot script path.

![A setup transaction paying a COSHV output that expands into a distribution transaction](/img/posts/2019-05-tx-tree-2.png)

Alice would then give each of the receivers a copy of all ten outputs to
allow each of them to verify that Alice's setup transaction,
when suitably confirmed, guaranteed them payment.  When they later
wanted to spend that payment, any of them could then create a distribution
transaction containing the committed outputs.  Unlike the example from
the previous subsection, they don't need to pre-sign anything so they would never need to interact with each
other.  Even better, the information Alice needs to send them in order
to allow them to verify the setup transaction and ultimately spend their
money could be sent through existing asynchronous communication methods
such as email or a cloud drive.  That means the receivers wouldn't need
to be online at the time Alice created and sent her setup transaction.

This elimination of the need to interact is a particular highlight of
the proposal.  If we imagine the example above with Alice being an
exchange, the interactive form of the protocol would require her to keep
the ten participants online and connected to her service from the moment
each of them submitted their withdrawal request until the interaction
was done---and they'd all need to use wallets compatible with such a
child transaction signing protocol.  The non-interactive form with COSHV
would only require them to submit a Bitcoin address and an email address
(or some other protocol address for delivery of the committed outputs).

### Feedback and activation

The proposal received over 30 replies on the Bitcoin-Dev mailing list as
of this writing.  The concerns raised included:

- **Not flexible enough:** Matt Corallo [says][coshv flex], "we need to
  have a flexible solution that provides more features than just this,
  or we risk adding it only to go through all the effort again when
  people ask for a better solution."

- **Not generic enough:** Russell O'Connor suggests both COSHV and
  `SIGHASH_ANYPREVOUT` (described in [last week's newsletter][Newsletter
  #47]) could be replaced using an `OP_CAT` opcode and an `OP_CHECKSIGFROMSTACK`
  opcode.  Both opcodes are currently implemented in
  [ElementsProject.org][] sidechains such as [Liquid][blockstream
  liquid].  The `OP_CAT` opcode [catenates][] two strings into one string
  and the `OP_CHECKSIGFROMSTACK` opcode compares a signature on the
  stack to other data on the stack rather than to the transaction that
  contains the signature.  Catenation allows a script to include various
  parts of a message that are combined with witness elements at spend
  time in order to form a complete message that can be verified using
  `OP_CHECKSIGFROMSTACK`.

    Because the message that gets verified can be a Bitcoin
    transaction---including a partial copy of the transaction the
    spender is attempting to send---these operations allow a script to
    evaluate transaction data without having to directly read the
    transaction being evaluated.  Compare this to COSHV which looks at
    the hash of the outputs and anyprevout which looks at all the other
    signatures in the transaction.

    A potentially major downside of the cat/checksigfromstack approach
    is that it requires larger witnesses to hold the larger script and
    all of its witness elements.  O'Connor noted that he doesn't mind
    switching to more concise implementations (like COSHV and
    anyprevout) once it's clear a significant number of users are making
    use of those functions via generic templates.

- **Not safe enough:** Johnson Lau pointed out that COSHV allows
  signature replay similar to [BIP118][] noinput, a perceived risk that
  [bip-anyprevout][] takes pains to eliminate.

Rubin and others provided at least preliminary responses to each of
these concerns.  We expect discussion will be ongoing, so we'll report
back with any significant developments in future weeks.

The [proposed BIP for COSHV][bip-coshv] suggests it could be activated
along with bip-taproot (if users desire it).  As bip-taproot is itself
still under discussion, we don't recommend anyone come to expect dual
activation.  Future discussion and implementation testing will reveal
whether each proposal is mature enough, desirable enough, and enough
supported by users to warrant being added to Bitcoin.

Overall, COSHV appears to provide a simple (but clever) method for
allowing outputs to commit to where their funds can ultimately be sent.
In next week's newsletter, we'll look at some other ways COSHV could be
used to improve efficiency, privacy, or both.

## Bech32 sending support

*Week 11 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/11-only-bech32.md %}

**Correction to Newsletter #46:** our section about bech32 QR codes
incorrectly claimed that bech32 addresses used in BIP21 URIs with
additional parameters couldn't use the QR uppercase alphanumeric mode.
Nadav Ivgi kindly [informed us][ivgi tweet] that QR codes could mix
modes.  We've updated [that paragraph][updated qr paragraph] with the
correct information, some additional details, and an additional set of
QR code examples.

*If you notice any errors in an Optech newsletter or any of our other
documentation, please send us an [email][optech email], a [tweet][optech
twitter], or otherwise contact one of our [contributors][optech
contributors].*

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are the limitations for amortizing the interactive session setup of MuSig?]({{bse}}87605)
  Richard Myers is attempting to optimize
  interactive setup for a low bandwidth system, but user nickler
  emphasizes that nonces must not be reused or private keys could
  be leaked. Nickler goes on to provide suggestions to achieve
  Myers's goal.

- [On chain cost of Segwit version 1 versus version 0?]({{bse}}87697)
  User Wapac asks for a comparison of transaction weight between segwit
  v0 and v1, specifically for relatively simple single key transactions.
  Andrew Chow provides byte-level details and concludes that v1
  is always cheaper to spend, while v0 can be cheaper to create an
  output. However, Andrew points out that the sender generally doesn’t
  have much choice in choosing which output type they send to, so users
  are likely to prefer v1 even for single key transactions. Wapac also
  provides an answer that shows a summary table.

- [Does v1 Segwit include v0?]({{bse}}87612) Pieter Wuille states that
  no, you cannot use [v0 scripts][BIP141] inside a [v1 spend][bip-tapscript]. He elaborates that the
  reason behind this is in order to meet some of the goals behind v1
  leads to incompatibility with aspects of v0 script.

- [Fee negotiations in Lightning.]({{bse}}87586) Mark H describes how, in
  an example four-hop LN payment, fees are negotiated.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [LND #3098][] increases the maximum number of blocks the daemon will
  wait for confirmation of a channel funding transaction initiated by
  a remote peer, raising it from 288 blocks (two days) to 2,016 (two
  weeks).  This allows patient users to pay lower transaction fees.

- [C-Lightning #2647][] specifies a default plugin directory from which
  plugins will be automatically loaded even if the `--plugin` or
  `--plugin-dir` configuration parameters are not specified.  Currently this
  is the `plugins` directory in the lightning daemon configuration
  directory.

- [C-Lightning #2650][] adds a new plugin hook for when a remote peer
  tries to open a channel with the local node.  This allows the plugin to
  reject the channel open or perform other actions before the channel is
  opened.

- [Eclair #952][] adds a `sendtoroute` method that allows the users to
  manually select the channel through which a payment is initially
  routed.  This can allow them to choose which channels get drained of
  funds.

- [Eclair #965][] allows the user to specify the preimage when creating
  an invoice.  This can be used for systems that securely generate
  unguessable invoice identifiers, such as an [atomic swap][] or a set
  of contract terms combined with a nonce in the [pay-to-contract
  format][p2c].

## New publication schedule

Starting this week, the Optech newsletter will be published every
Wednesday instead of every Tuesday.  This will give us an extra weekday
to review and edit newsletter drafts before we publish.

## Special thanks

We thank Jeremy Rubin and Anthony Towns for their reviews of a draft of
this newsletter, including describing to us the tree of outputs idea.
We additionally thank Pieter Wuille for helping us better understand where
interaction is required in aggregating keys and signatures with MuSig.
Any errors in the published version of this newsletter are the fault of
the author.

## Footnotes

[^legacy-cleanstack]:
    Segwit v0 (P2WSH) and the Tapscript proposal require the final stack
    contain only a single *true* element in order to succeed.  This is
    called the *cleanstack* rule.  Legacy script for bare outputs and
    P2SH outputs allows the stack to contain multiple items and succeed
    as long as the item at the top of the stack at its termination is
    *true*.  However, legacy transactions that don't have a clean stack
    will not be relayed or mined by Bitcoin Core's default mempool
    policy.  The cleanstack rule helps reduce transaction malleability
    as any addition or removal of extraneous elements to a scriptSig
    or witness will change a transaction's feerate and (for legacy
    transactions) its txid.

[^taproot-pubkeys]:
    The proposed Taproot addresses format (v1 segwit addresses) includes
    a public key directly in the address, so anyone with a set of
    Taproot addresses can use them to create an aggregated pubkey.
    However, some users may create Taproot addresses using public keys
    for which no one has (or can plausibly generate) the corresponding
    private key.  For that reason, anyone creating aggregated pubkeys
    should probably not assume that Taproot addresses are pubkeys
    themselves and should collect separate pubkeys.  Additionally, it's
    probably a good idea not to reuse the same pubkey in more than one
    place within Bitcoin.  We omit the extra steps of collecting pubkeys
    in this newsletter's examples in order to simplify the descriptions
    of COSHV.  Please consider consulting with a Bitcoin expert before
    you implement the protocols you read about in the pages of
    this newsletter or anywhere else on the Internet.

{% include linkers/issues.md issues="3098,2647,2650,952,965" %}
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf
[p2c]: https://arxiv.org/abs/1212.3257
[atomic swap]: https://en.bitcoin.it/wiki/Atomic_swap
[emptystack1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016935.html
[emptystack0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016558.html
[emptystack reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016947.html
[elliptic curve]: https://en.wikipedia.org/wiki/Elliptic_curve
[smaller v1 spk]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016943.html
[vid return to fees]: https://www.youtube.com/watch?v=ihUQ4C42KUk
[coshv flex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016936.html
[elementsproject.org]: https://elementsproject.org/
[blockstream liquid]: https://blockstream.com/liquid/
[catenates]: https://en.wiktionary.org/wiki/catenate
[uncompressed public keys]: https://btcinformation.org/en/developer-guide#public-key-formats
[ivgi tweet]: https://twitter.com/shesek/status/1131733590235131905
[updated qr paragraph]: /en/bech32-sending-support/#qrcode-edit
[optech twitter]: https://twitter.com/bitcoinoptech
[optech contributors]: /about/#contributors
[special section about the proposal]: #proposed-transaction-output-commitments
[bech32 series]: /en/bech32-sending-support/
