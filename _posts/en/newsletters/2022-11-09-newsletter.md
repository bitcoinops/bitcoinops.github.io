---
title: 'Bitcoin Optech Newsletter #225'
permalink: /en/newsletters/2022/11/09/
name: 2022-11-09-newsletter
slug: 2022-11-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about a configuration option for enabling
full-RBF in Bitcoin Core and describes a bug affecting BTCD, LND, and
other software.  Also included are our regular sections with the summary
of a Bitcoin Core PR Review Club meeting, descriptions of new releases
and release candidates, and overviews of notable changes to popular
Bitcoin infrastructure software.

## News

- **Continued discussion about enabling full-RBF:** as mentioned in
  newsletters for the past several weeks---users, service providers, and
  Bitcoin Core developers have been evaluating the inclusion of the
  `mempoolfullrbf` configuration option into Bitcoin Core's development
  branch and current release candidates for version 24.0.  Those
  previous newsletters have summarized many previous
  arguments for and against this [full RBF][topic rbf] option
  ([1][news222 rbf], [2][news223 rbf], [3][news224 rbf]).  This week,
  Suhas Daftuar [posted][daftuar rbf] to the Bitcoin-Dev mailing list to
  "argue that we should continue to maintain a relay policy where
  replacements are rejected for transactions that don't opt-in to RBF
  (as described in BIP 125), and moreover, that we should remove the
  `-mempoolfullrbf` flag from Bitcoin Core's latest release candidate
  and not plan to release software with that flag, unless (or until)
  circumstances change on the network."  He notes:

  - *Opt-in RBF already available:* anyone who wants the benefits of
    RBF should be able to opt-in to it using the mechanism described in
    [BIP125][].  Users would only be served by full RBF if there was
    some reason they couldn't use opt-in RBF.

  - *Full RBF doesn't fix anything that isn't broken in other ways:*
    a possible case where some users of a multiparty protocol could
    deny other users the ability to use opt-in RBF was previously
    [identified][riard funny games], but Daftuar notes that protocol
    is vulnerable to other cheap or free attacks which full RBF would
    not solve.

  - *Full RBF takes away options:* "absent any other examples [of
    problems fixed by fullrbf], it does not seem to me that fullrbf
    solves any problems for RBF users, who are already free to choose
    to subject their transactions to BIP 125's RBF policy.  From this
    perspective, "enabling fullrbf" is really just taking away user
    choice to opt a transaction into a non-replacement policy regime."

  - *Offering non-replacement doesn't introduce any issues for full nodes:*
    indeed, it simplifies the handling of long chains of transactions.

  - *Determining incentive compatibility isn't always straightforward:*
     Daftuar uses the proposal for v3 transaction relay (see
     [Newsletter #220][news220 v3tx]) as an example:

     > Suppose in a few years someone proposes that we add a
     > "-disable_v3_transaction_enforcement" flag to our software, to
     > let users decide to turn off those policy restrictions and
     > treat v3 transactions the same as v2, for all the same reasons
     > that could be argued today with fullrbf [...]
     >
     > [That] would be subversive to making the lightning use case for
     > v3 transactions work [...] we should not enable users to
     > disable this policy, because as long as that policy is just
     > optional and working for those who want it, it shouldn't harm
     > anyone that we offer a tighter set of rules for a particular
     > use case.  Adding a way to bypass those rules is just trying to
     > break someone else's use case, not trying to add a new one.  We
     > should not wield "incentive compatibility" as a bludgeon for
     > breaking things that appear to be working and not causing
     > others harm.
     >
     > I think this is exactly what is happening with fullrbf.

  Daftuar ends his email with three questions for those who still want
  the `mempoolfullrbf` option to be included in Bitcoin Core:

  1. "Does fullrbf offer any benefits other than breaking zeroconf
     business practices?  If so, what are they?"

  2. "Is it reasonable to enforce BIP 125's rbf rules on all
     transactions, if those rules themselves are not always incentive
     compatible?"

  3. "If someone were to propose a command line option that breaks v3
     transaction relay in the future, is there a logical basis for
     opposing that which is consistent with moving towards fullrbf
     now?"

  As of this writing, no one has answered Daftuar's questions on the
  mailing list, although two answers to the set of questions were
  posted to a Bitcoin Core [PR][bitcoin core #26438] that Daftuar
  opened to propose removing the `mempoolfullrbf` configuration
  option.  Daftuar later [closed][26438 close] the PR.

  It wasn't clear at the time of writing whether anyone would comment
  further on the topic. {% assign timestamp="0:54" %}

- **Block parsing bug affecting multiple software:** as reported in
  [Newsletter #222][news222 bug], it appeared that a serious bug
  affecting the BTCD full node and LND LN node was accidentally
  triggered, putting users of the software at risk.  Updated software
  was quickly released.  Shortly after that bug was triggered, Anthony
  Towns [discovered][towns find] a second related bug that could only be
  triggered by miners.  Towns reported the bug to BTCD and LND lead
  maintainer Olaoluwa Osuntokun, who prepared a patch to include in the
  next general update of the software.  Including the security fix
  alongside other changes could hide that a vulnerability was being
  fixed and reduce the chance of it being exploited.  Both Towns and
  Osuntokun responsibly kept the vulnerability private until its fix
  could be deployed.

  Unfortunately, the second related bug was independently rediscovered by
  someone who found a miner to trigger it.  This new bug
  affected BTCD and LND again, but it also affected at least [two
  other][liquid and rust bitcoin vulns] significant projects or
  services.  All users of affected systems should upgrade immediately.
  We repeat our advice from three weeks ago for anyone using any
  Bitcoin software to sign up for security announcements from that
  software’s development team.

  With the release of this newsletter, Optech has also added a special
  topic page where we list the names of [the amazing people who
  responsibly disclosed a vulnerability][topic responsible
  disclosures] that we've summarized in an Optech newsletter.
  There are likely several other disclosures not listed because they
  haven't been made public yet.
  We of course also thank all the reviewers of proposals and
  pull requests whose diligent effort prevented innumerable
  security bugs from making it into released software. {% assign timestamp="14:36" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Relax MIN_STANDARD_TX_NONWITNESS_SIZE to 65 non-witness bytes][review club 26265]
is a PR by instagibbs that relaxes the mempool policy's non-witness transaction size
constraints. It allows transactions to be as small as 65 bytes, replacing
the current policy that requires transactions to be at least 85 bytes (see
[Newsletter #222][news222 min relay size]).

Since this Review Club meeting, this PR has been closed in favor of
PR [#26398][bitcoin core #26398], which
relaxes policy even further by disallowing _only_ 64-byte transactions.
The relative merits of these two slightly-different policies were
discussed during the meeting. {% assign timestamp="19:32" %}

{% include functions/details-list.md
  q0="Why was the minimum transaction size 82 bytes?
  Can you describe the attack?"

  a0="The 82-byte minimum, which was introduced by PR [#11423][bitcoin core #11423] in 2018, is
  the size of the smallest standard payment transaction. This was
  presented as a cleanup of the standardness rules. But in reality,
  the change was to prevent a 64-byte transaction from being considered standard,
  because this size allowed a [spoof payment attack][]
  against SPV clients (making them think they've received a payment when they hadn't).
  The attack involves tricking an SPV client into thinking that a 64-byte
  transaction is an inner node of the transaction merkle tree, which is also
  64 bytes in length."

  a0link="https://bitcoincore.reviews/26265#l-35"

  q1="A participant asked, was it was necessary to fix this vulnerability
  covertly, given that it would be very expensive (on the order of USD$1M) to
  carry out this attack, combined with the fact that it seems unlikely
  people would use SPV clients for payments that large?"

  a1="There was some agreement, but one participant pointed out that our
  intuition about this could be wrong."

  a1link="https://bitcoincore.reviews/26265#l-66"

  q2="What does _non-witness size_ mean,
  and why do we care about the non-witness distinction?"

  a2="We care about the non-witness distinction because, as part of the
  segwit upgrade, witness data is excluded from the calculation of the merkle root.
  Since the attack requires the malicious transaction to be 64 bytes in the
  merkle root construction (so it looks like an inner node), we need to exclude
  witness data from it."

  a2link="https://bitcoincore.reviews/26265#l-62"

  q3="Why does setting this policy help to prevent the attack?"

  a3="Since inner merkle tree nodes can only be exactly 64 bytes, a transaction
  of a different size cannot be misinterpreted as an inner merkle node."

  a3link="https://bitcoincore.reviews/26265#l-84"

  q4="Does it eliminate the attack vector entirely?"

  a4="Changing the standardness rules only prevents 64-byte transactions
  from being accepted into mempools and relayed, but such transactions
  may still be consensus-valid and so can be mined into a block.
  For this reason, the attack is still possible, but only with the help of miners."

  a4link="https://bitcoincore.reviews/26265#l-84"

  q5="Why might we want to change the minimum transaction size to 65 bytes,
  apart from the fact that it's unnecessary to obfuscate the CVE?"

  a5="There are legitimate use cases for transactions that are less than 82 bytes.
  One example mentioned is a [Child Pays For Parent (CPFP)][topic cpfp] transaction that assigns
  an entire parent output to fees (such a transaction would have a single input
  and an empty `OP_RETURN` output)."

  a5link="https://bitcoincore.reviews/26265#l-100"

  q6="Between disallowing sizes less than 65 bytes and sizes equal to 64 bytes,
  which approach do you think is better and why?
  What are the implications of both approaches?"

  a6="After some byte-counting discussion, it was agreed that a valid
  but non-standard transaction can be as small as 60 bytes:
  a stripped (non-witness) with a single native segwit input is
  41 B + 10 B header + 8 B value + 1 B `OP_TRUE` or `OP_RETURN` = 60 B."

  a6link="https://bitcoincore.reviews/26265#l-124"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust Bitcoin 0.28.2][] is a minor release containing a fixes for bugs
  that could "cause some specific transactions and/or blocks to fail to
  deserialize. No known such transactions exist on any public
  blockchain." {% assign timestamp="28:41" %}

- [Bitcoin Core 24.0 RC3][] is a release candidate for the
  next version of the network's most widely used full node
  implementation.  A [guide to testing][bcc testing] is available.

  **Warning:** this release candidate includes the `mempoolfullrbf`
  configuration option which several protocol and application developers
  believe could lead to problems for merchant services as described in
  this newsletter and previous newsletters [#222][news222 rbf] and
  [#223][news223 rbf].  It could also cause problems for transaction
  relay as described in [Newsletter #224][news224 rbf].  Optech
  encourages any services that might be affected to evaluate the RC and
  participate in the public discussion. {% assign timestamp="29:40" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26419][] adds context to the validation interface logs
  detailing why a transaction is removed from the mempool. {% assign timestamp="30:22" %}

- [Eclair #2404][] adds support for Short Channel IDentifier (SCID)
  aliases and [zero-conf channels][topic zero-conf channels]
  even for channel state commitments that don't use [anchor
  outputs][topic anchor outputs]. {% assign timestamp="31:21" %}

- [Eclair #2468][] implements [BOLTs #1032][], allowing the ultimate receiver of a payment ([HTLC][topic
  HTLC]) to accept a greater amount than they requested and with a
  longer time before it expires than they requested.  Previously,
  Eclair-based receivers adhered to [BOLT4][]'s requirement that the
  amount and expiry delta equal exactly the amount they requested, but
  that exactitude meant a forwarding node could probe the next hop to
  see if it was the final receiver by changing either value by the
  slightest bit. {% assign timestamp="32:11" %}

- [Eclair #2469][] extends the amount of time it asks the last
  forwarding node to give the next hop to settle a payment.  The last
  forwarding node shouldn't know it's the last forwarding node---it
  shouldn't know that the next hop is the receiver of the payment.  The
  extra settlement time implies that the next hop may be a routing node
  rather than the receiver.  The PR description for this feature states
  that Core Lightning and LDK already implement this behavior.  See also
  the description for Eclair #2468 above. {% assign timestamp="34:31" %}

- [Eclair #2362][] adds support for the `dont_forward` flag for channel
  updates from [BOLTs #999][].  Channel updates change the parameters of
  a channel and are often gossiped to inform other nodes on the network
  about how to use the channel, but when a channel update contains this
  flag, it should not be forwarded to other nodes. {% assign timestamp="35:18" %}

- [Eclair #2441][] allows Eclair to begin receiving onion-wrapped error
  messages of any size.  [BOLT2][] currently recommends 256 byte errors,
  but doesn't forbid longer error messages and [BOLTs #1021][] is open to
  encourage use of 1024-byte error messages encoded using LN's modern
  Type-Length-Value (TLV) semantics. {% assign timestamp="36:40" %}

- [LND #7100][] updates LND to use the latest version of BTCD (as a
  library), fixing the block parsing bug described in the *news* section
  above. {% assign timestamp="38:29" %}

- [LDK #1761][] adds a `PaymentID` parameter to methods for sending
  payments which callers can use to prevent sending multiple identical
  payments.  Additionally, LDK may now continue trying to resend a
  payment indefinitely, rather than the previous behavior of ceasing
  retries after a few blocks of repeated failures; the `abandon_payment`
  method may be used to prevent further retrying. {% assign timestamp="38:44" %}

- [LDK #1743][] provides a new `ChannelReady` event when a channel
  becomes ready to use.  Notably, the event may be issued after a
  channel has received a suitable number of confirmations, or it may be
  issued immediately in the case of a [zero-conf channel][topic zero-conf channels]. {% assign timestamp="40:57" %}

- [BTCPay Server #4157][] adds opt-in support for a new version of the
  checkout interface.  See the PR for screenshots and video previews. {% assign timestamp="42:05" %}

- [BOLTs #1032][] allows the ultimate receiver of a payment
  ([HTLC][topic HTLC]) to accept a greater amount than they requested
  and with a longer time before it expires than they requested.  This
  makes it more difficult for a forwarding node to determine that the
  next hop is the receiver by slightly tweaking a payment's parameters.
  See the description of Eclair #2468 above for more information. {% assign timestamp="42:45" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="26438,26419,5674,2404,2468,2469,2362,2441,7100,1761,1743,4157,1032,1021,999,26398,11423" %}
[bitcoin core 24.0 rc3]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[rust bitcoin 0.28.2]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.28.2
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[daftuar rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021135.html
[riard funny games]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003033.html
[news220 v3tx]: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty
[news222 bug]: /en/newsletters/2022/10/19/#block-parsing-bug-affecting-btcd-and-lnd
[liquid and rust bitcoin vulns]: https://twitter.com/Liquid_BTC/status/1587499305664913413
[spoof payment attack]: /en/topics/cve/#CVE-2017-12842
[towns find]: https://twitter.com/roasbeef/status/1587481219981508608
[26438 close]: https://github.com/bitcoin/bitcoin/pull/26438#issuecomment-1307715677
[review club 26265]: https://bitcoincore.reviews/26265
[news222 min relay size]: /en/newsletters/2022/10/19/#minimum-relayable-transaction-size
