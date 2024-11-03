---
title: 'Bitcoin Optech Newsletter #283'
permalink: /en/newsletters/2024/01/03/
name: 2024-01-03-newsletter
slug: 2024-01-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares the disclosure of past vulnerabilities in
LND, summarizes a proposal for fee-dependent timelocks, describes an
idea for improving fee estimation using transaction clusters, discusses
how to specify unspendable keys in descriptors, examines the cost of
pinning in the v3 transaction relay proposal, mentions a proposed BIP to
allow descriptors to be included in PSBTs, announces a tool that can be
used with the MATT proposal to prove a program executed correctly, looks
at a proposal for allowing highly efficient group exits from a pooled
UTXO, and points to new coin selection strategies being proposed for
Bitcoin Core.  Also included are our regular sections announcing new
software releases and describing notable changes to popular Bitcoin
infrastructure.

## News

- **Disclosure of past LND vulnerabilities:** Niklas Gögge [posted][gogge
  lndvuln] to Delving Bitcoin about two vulnerabilities he had previously
  [responsibly disclosed][topic responsible disclosures], which led
  to fixed versions of LND being released.  Anyone using LND 0.15.0 or
  later is not vulnerable; anyone using an earlier version of LND should
  consider upgrading immediately due to these vulnerabilities and other
  known vulnerabilities affecting older releases.  In brief, the two
  disclosed vulnerabilities were:

  - A DoS vulnerability that could have led to LND running out of
    memory and crashing.  If LND is not running, it can't broadcast
    time-sensitive transactions, which can lead to loss of funds.

  - A censorship vulnerability that could allow an attacker to prevent
    an LND node from learning about updates to targeted channels
    across the network.  An attacker could use this to bias a node
    towards selecting certain routes for payments it sent, giving the
    attacker more forwarding fees and more information about the
    payments the node sent.

  Gögge made his initial disclosure to the LND developers over two years
  ago and versions of LND containing fixes for both vulnerabilities have
  been available for over 18 months.  Optech is unaware of any users who
  were affected by either vulnerability. {% assign timestamp="2:07" %}

- **Fee-dependent timelocks:** John Law [posted][law fdt] to the
  Bitcoin-Dev and Lightning-Dev mailing lists with a rough proposal for
  a soft fork that could allow transaction [timelocks][topic timelocks] to optionally only
  unlock (expire) when median block feerates are below a user-chosen
  level.  For example, Alice wants to deposit money into a payment
  channel with Bob, but she also wants to be able to receive a refund if
  Bob becomes unavailable, so she gives him the option to claim any
  funds she pays him at any time but also gives herself the option to
  claim a refund of her deposit after a timelock expires.  As the time
  lock expiration approaches, Bob attempts to claim his funds but
  current feerates are much higher than he and Alice expected when they
  started using their contract.  Bob is unable to get the transaction
  claiming his funds confirmed, either because he doesn't have access to
  enough bitcoins to spend on fees or because it would be cost
  prohibitive to create a claim transaction given the high feerates.  In
  the current Bitcoin protocol, Bob being unable to act would allow
  Alice to claim her refund.  With Law's proposal, the expiration of the
  timelock that prevents Alice from claiming her refund would be delayed
  until there had been a series of blocks with median feerates below
  an amount specified by Alice and Bob when they negotiated their
  contract.  This would ensure Bob has a chance to get his transaction
  confirmed at an acceptable feerate.

  Law notes that this addresses one of the longstanding concerns noted
  in the [original Lightning Network paper][] about [forced expiration
  floods][topic expiration floods] where too many channels all closing simultaneously may
  result in insufficient block space for all of them to be
  confirmed before their timelocks expire, potentially resulting in
  some users losing money.  With fee-dependent timelocks in place,
  users of the closed channels will simply bid up the feerates until
  they exceed the fee-dependent lock, after which expiry of the
  timelocks will be delayed until fees have come down to an amount low
  enough that all of the transactions paying that feerate have been
  confirmed.  LN channels currently only involve two users each, but
  proposals such as [channel factories][topic channel factories] and
  [joinpools][topic joinpools] where more than two users share a UTXO
  are even more vulnerable to forced expiration floods, so this
  solution significantly bolsters their security.  Law also notes
  that, in at least some of those constructions, the party that holds
  the refund condition (e.g. Alice in our earlier example) is the one
  most disadvantaged by fees increasing, given their capital is locked
  up in the contract until fees decrease. Fee-dependent locks give
  that party an extra incentive to act in a way that keeps feerates low,
  e.g. not close many channels within a short period of time.

  The implementation details for fee-dependent timelocks are chosen to
  make them easy for contract participants to optionally use and to
  minimize the amount of extra information full nodes need to store in
  order to validate them.

  The proposal received a moderate amount of discussion with
  respondents suggesting [storing][riard fdt] fee-dependent timelock
  parameters in the [taproot][topic taproot] annex, having blocks
  [commit][boris fdt] to their median feerate to support lightweight
  clients, and [details][harding pruned] about how upgraded pruned
  nodes could support the fork.  There was additional debate between
  Law and [others][evo fdt] about the effect of miners accepting
  out-of-band fees---fees to confirm a transaction that are paid
  separately from the normal transaction fee mechanism (e.g. by paying
  a particular miner directly). {% assign timestamp="25:09" %}

- **Cluster fee estimation:** Abubakar Sadiq Ismail [posted][ismail
  cluster] to Delving Bitcoin about using some of the tools and insights
  from the design of [cluster mempool][topic cluster mempool] to improve
  [fee estimation][topic fee estimation] in Bitcoin Core.  The current fee estimation algorithm
  in Bitcoin Core tracks the number of blocks it takes for transactions
  entering the local node's mempool to become confirmed.  When
  confirmation happens, the transaction's feerate is used to update a
  prediction of how long it will take transactions with similar feerates
  to become confirmed.

  In that approach, some transactions are ignored by Bitcoin Core for
  feerate purposes, while others are potentially miscounted.  This is
  a result of [CPFP][topic cpfp], where child transactions (and other
  descendants) incentivize miners to confirm their parents (and other
  ancestors).  Child transactions may have a high feerate by
  themselves, but when their fee and their ancestors' fees are
  considered together, the feerate might be significantly lower,
  leading them to take longer to confirm than expected.  To prevent
  that from causing overestimation of reasonable fees, Bitcoin Core
  does not update its fee estimations using any transaction that
  enters the mempool when its parent is unconfirmed.  Correspondingly,
  a parent transaction may have a low feerate by themselves, but when
  its descendants' fees are also considered, the feerate might be
  significantly higher, leading them to confirm faster than expected.
  Bitcoin Core's fee estimations don't compensate for this situation.

  Cluster mempool will keep related transactions together and support
  dividing them into chunks that will be profitable to mine together.
  Ismail suggests tracking the feerates of chunks rather than
  individual transactions (though a chunk can be a single transaction)
  and then attempting to find those same chunks in blocks.  If a chunk
  is confirmed, then fee estimations are updated using its chunk
  feerate rather than the feerates of individual transactions.

  The proposal was well received, with developers discussing the
  details an updated algorithm would need to consider. {% assign timestamp="8:32" %}

- **How to specify unspendable keys in descriptors:** Salvatore Ingala
  started a [discussion][ingala undesc] on Delving Bitcoin about how to allow
  [descriptors][topic descriptors], particularly those for [taproot][topic
  taproot], to specify a key for which no private key is known
  (preventing spending from that key).  One important context for this
  is sending money to a taproot output that can only be spent via a
  scriptpath spend.  To do this, the key that allows keypath spending
  must be set to an unspendable key.

  Ingala described several challenges to using unspendable keys in
  descriptors and several proposed solutions with different tradeoffs.
  Pieter Wuille summarized several recent in-person discussions about
  descriptors, including a [particular][wuille undesc2] idea about
  unspendable keys.  Josie Baker asked for details about why the
  unspendable key can't be a constant value (such as the
  nothing-up-my-sleeve (NUMS) point in BIP341), which would allow
  everyone to immediately know that an unspendable key was used---a
  possible advantage to some protocols, such as [silent
  payments][topic silent payments].  Ingala replied to Baker that "it
  is a form of fingerprinting. You can always reveal this information
  yourself if you want/need it, but it’s great if the standards don’t
  force you to do so."  Wuille further replied with an algorithm for
  generating the proof.  In the last post in the thread at the time of
  writing, Ingala noted that some of the work of specifying policies
  related to unspendable keys can be split between descriptors and
  [BIP388][] wallet policies. {% assign timestamp="17:48" %}

- **V3 transaction pinning costs:** Peter Todd [posted][todd v3] to the
  Bitcoin-Dev mailing list an analysis of the proposed [v3 transaction
  relay][topic v3 transaction relay] policy on [transaction pinning][topic
  transaction pinning] for contract protocols such as LN.  For example,
  Bob and Mallory may share an LN channel.  Bob wants to close the
  channel, so he broadcasts his current commitment transaction plus a
  small child transaction that contributes fees through [CPFP][topic
  cpfp], with a total size of 500 vbytes.  Mallory detects Bob's
  transactions on the P2P network before they have reached any miners
  and sends her own commitment transaction plus a very large child
  transaction, giving her two transactions a combined size of 100,000
  vbytes with a combined feerate lower than Bob's original version.
  Using Bitcoin Core's current default relay policy and the current
  proposal for [package relay][topic package relay], Bob can attempt to
  [replace][topic rbf] Mallory's two transactions but he'll need to pay
  for the bandwidth used by Mallory's transaction according to
  [BIP125][] rule #3.  If Bob originally used a feerate of 10 sat/vbyte
  (5,000 sats total) and Mallory's alternative used a feerate of 5
  sat/vbyte (500,000 sats total), Bob will need to pay 100 times more in
  his replacement than he originally paid.  If that's more than Bob is
  willing to pay, Mallory's large and low-feerate transaction may not
  confirm before a critical timelock expires and allows Mallory to steal
  money from Bob.

  In the v3 transaction relay proposal, the rules allow a
  transaction opting into the v3 policy to only have a maximum of one
  unconfirmed child transaction that will be relayed, stored in
  mempools, and mined by nodes that agree to follow the v3 policy.  As
  Peter Todd shows in his post, that would still allow Mallory to
  increase Bob's costs by about 1.5 times what he wanted to pay.
  Respondents largely agreed that there was a risk that Bob might need
  to pay more in the case of a malicious
  counterparty, but they noted that a small multiple is much better than the 100x
  or more that Bob might need to pay under the current relay rules.

  Additional discussion in the conversation discussed specifics of the
  v3 relay rules, [ephemeral anchors][topic ephemeral anchors], and
  how they compare to currently-available [CPFP carve-out][topic cpfp
  carve out] and [anchor outputs][topic anchor outputs]. {% assign timestamp="34:14" %}

- **Descriptors in PSBT draft BIP:** the SeedHammer team
  [posted][seedhammer descpsbt] a draft BIP to the Bitcoin-Dev mailing
  list for including [descriptors][topic descriptors] in [PSBTs][topic
  psbt].  The main intended use seems to be encapsulating descriptors in
  the PSBT format for transfer between wallets, as the proposed standard
  allows PSBTs to omit transaction data when a descriptor is enclosed.
  This could be useful for a software wallet to transfer output
  information to a hardware signing device or for multiple wallets in a
  multisig federation to transfer information about the outputs they
  want to create.  As of this writing, the draft BIP has not received
  any replies on the mailing list, although an earlier [post][seedhammer
  descpsbt2] in November about a precursor proposal did receive
  [feedback][black descpsbt]. {% assign timestamp="48:19" %}

- **Verification of arbitrary programs using proposed opcode from MATT:**
  Johan Torås Halseth [posted][halseth ccv] to Delving Bitcoin about
  [elftrace][], a proof of concept program that can use the
  `OP_CHECKCONTRACTVERIFY` opcode from the [MATT][topic matt] soft fork proposal
  to allow a party in a contract protocol to [claim money][topic acc] if an arbitrary
  program executed successfully.  It is similar in concept to [BitVM][topic acc] but simpler in its Bitcoin
  implementation due to using an opcode specifically designed for
  program execution verification.  Elftrace works with programs compiled
  for the RISC-V architecture using Linux's [ELF][] format; almost any
  programmer can easily create programs for that target, making using
  elftrace highly accessible.  The forum post hasn't received any
  replies as of this writing. {% assign timestamp="57:52" %}

- **Pool exit payment batching with delegation using fraud proofs:**
  Salvatore Ingala [posted][ingala exit] to Delving Bitcoin a proposal
  that can improve multiparty contracts where several users share a
  UTXO, such as a [joinpool][topic joinpools] or [channel factory][topic
  channel factories], and some of the users want to exit the contract at
  a time when other users are unresponsive (whether unintentionally or
  deliberately).  The typical way to construct such protocols is by
  giving each user an offchain transaction that the user can broadcast
  in case they want to exit.  That means, even in the best case, if five
  users want to exit, they each need to broadcast a separate
  transaction, and each of those transactions will have at least one
  input and one output---a total of five inputs and five outputs.
  Ingala suggests a way those users could work together to exit with a
  single transaction that could have a single input and five outputs,
  giving them the typical [payment batching][topic payment batching]
  reduction in transaction size by about 50%.

  In complex multiparty contracts with very large numbers of users, the
  reduction in onchain size can easily be significantly larger than 50%.
  Even better, if the five active users simply wanted to move their
  funds to a new shared UTXO involving just them, they could use a
  single-input and single-output transaction, saving about 80% in the
  case of five users or about 99% in the case of a hundred users.  That
  huge savings for large groups of users moving their funds from one
  contract to another may be critical when transaction feerates are high
  and many users have relatively small balances in the contract. For
  example, 100 users each have a balance of 10,000 sats ($4 USD at the
  time of writing); if they each individually had to pay transaction
  fees to exit the contract and enter a new contract, then even with an
  improbably small spending transaction size of 100 vbytes, a
  transaction fee of 100 sats/vbyte would consume their entire balance.
  If they can move their combined funds of 1 million sats in a
  single 200 vbyte transaction at 100 sats/vbyte, then each
  user will pay only 200 sats (2% of their balance).

  The payment batching is accomplished by having one of the
  participants in the multiparty contract protocol construct a spend
  of the shared funds to the outputs agreed upon by the other active
  participants.  The contract allows this---but only if the
  constructing party funds a bond that they will forfeit if anyone can
  prove that they spent the contract protocol's funds incorrectly; the
  bond amount should be considerably more than the constructing party
  can gain from attempting an incorrect transfer of funds.  If no one
  generates a fraud proof showing the constructing party acted
  inappropriately within a period of time, the bond is refunded to the
  constructing party.  Ingala roughly describes how this feature could
  be added to a multiparty contract protocol using [OP_CAT][],
  `OP_CHECKCONTRACTVERIFY`, and amount introspection from the proposed
  [MATT][topic matt] soft fork, with him noting that it would be easier with the
  addition also of [OP_CSFS][topic op_checksigfromstack] and 64-bit
  arithmetic operators in [tapscript][topic tapscript].

  The idea has received a small amount of discussion as of this
  writing. {% assign timestamp="1:04:59" %}

- **New coin selection strategies:** Mark Erhardt [posted][erhardt coin]
  to Delving Bitcoin about edge-cases users may have experienced with
  Bitcoin Core's [coin selection][topic coin selection] strategy and
  proposes two new strategies that address the edge cases by attempting
  to reduce the number of inputs used in wallet transactions at high
  feerates.  He also summarizes the benefits
  and drawbacks of all the strategies for Bitcoin Core, both those
  implemented and those he has proposed, and then provides multiple
  results from simulations he performed using the different algorithms.
  The ultimate goal is for Bitcoin Core to generally select the set of
  inputs that will minimize the percentage of UTXO value that is spent
  on fees over the long term, while also not creating unnecessarily
  large transactions when feerates are high. {% assign timestamp="1:14:36" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.11.2][] is a bug fix release that helps ensure LND
  nodes can pay invoices created by Core Lightning users.  See the
  description of Core Lightning #6957 in the _notable changes_ section
  below for more details. {% assign timestamp="1:17:57" %}

- [Libsecp256k1 0.4.1][] is a minor release that "lightly increases the
  speed of the ECDH operation and significantly enhances the performance
  of many library functions when using the default configuration on
  x86_64." {% assign timestamp="1:18:14" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28349][] begins requiring the use of C++20-compatible
  compilers, allowing future PRs to begin using C++20 features.  As the
  PR description states, "C++20 allows to write safer code, because it
  allows to enforce more stuff at compile time". {% assign timestamp="1:19:06" %}

- [Core Lightning #6957][] fixes an unintentional incompatibility that
  prevented LND users from being able to pay invoices generated by Core
  Lightning with the default settings.  The issue is the
  `min_final_cltv_expiry`, which specifies the maximum number of blocks
  a receiver has to claim a payment.  [BOLT2][] suggests setting this
  value to a default of 18 but LND is using a value of 9, which is lower
  than Core Lightning will accept by default.  The problem is addressed
  by Core Lightning now including a field in its invoices that requests
  a value of 18. {% assign timestamp="1:20:21" %}

- [Core Lightning #6869][] updates the `listchannels` RPC to no longer
  list [unannounced channels][topic unannounced channels].  Users who need that information can use the
  `listpeerchannels` RPC. {% assign timestamp="1:21:15" %}

- [Eclair #2796][] updates its dependency on [logback-classic][] to fix
  a vulnerability.  Eclair doesn't use the feature affected by the
  vulnerability directly, but the upgrade ensures that any plugins or
  other related software that use the feature won't be vulnerable. {% assign timestamp="1:21:47" %}

- [Eclair #2787][] upgrades its support of header retrieval from
  BitcoinHeaders.net to the latest API.  Header retrieval over DNS helps
  protect nodes from [eclipse attacks][topic eclipse attacks].  See
  [Newsletter #123][news123 headers] for the description of Eclair
  originally supporting DNS-based header retrieval.  Other software
  using BitcoinHeaders.net may need to upgrade to the new API soon. {% assign timestamp="1:22:23" %}

- [LDK #2781][] and [#2688][ldk #2688] update support for sending and
  receiving [blinded payments][topic rv routing], particularly multi-hop
  blinded paths, as well as complying with the requirement that
  [offers][topic offers] always include at least one blinded hop. {% assign timestamp="1:23:14" %}

- [LDK #2723][] adds support for sending [onion messages][topic onion
  messages] using _direct connections_.  In the case where a sender
  can't find a path to the receiver but knows the receiver's network
  address (e.g. because the receiver is a public node that has
  gossiped their IP address), the sender can simply open a direct peer
  connection to the receiver, send the message, and then optionally
  close the connection.  This allows onion messages to work well even if
  only a small number of nodes on the network support them (which is the
  case now). {% assign timestamp="1:24:16" %}

- [BIPs #1504][] updates BIP2 to allow any BIP to be written in
  Markdown.  Previously all BIPs had to be written in Mediawiki markup. {% assign timestamp="1:25:00" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28349,6957,6869,2796,2787,2781,2723,1504,2688" %}
[gogge lndvuln]: https://delvingbitcoin.org/t/denial-of-service-bugs-in-lnds-channel-update-gossip-handling/314/1
[law fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004254.html
[original lightning network paper]: https://lightning.network/lightning-network-paper.pdf
[riard fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[boris fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[harding pruned]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[evo fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004260.html
[ismail cluster]: https://delvingbitcoin.org/t/package-aware-fee-estimator-post-cluster-mempool/312/1
[ingala undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/1
[wuille undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/2
[wuille undesc2]: https://gist.github.com/sipa/06c5c844df155d4e5044c2c8cac9c05e#unspendable-keys
[todd v3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022211.html
[seedhammer descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022200.html
[seedhammer descpsbt2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022184.html
[black descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022186.html
[halseth ccv]: https://delvingbitcoin.org/t/verification-of-risc-v-execution-using-op-ccv/313
[elftrace]: https://github.com/halseth/elftrace
[news273 bitvm]: /en/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[elf]: https://en.m.wikipedia.org/wiki/Executable_and_Linkable_Format
[ingala exit]: https://delvingbitcoin.org/t/aggregate-delegated-exit-for-l2-pools/297
[erhardt coin]: https://delvingbitcoin.org/t/gutterguard-and-coingrinder-simulation-results/279/1
[logback-classic]: https://logback.qos.ch/
[news123 headers]: /en/newsletters/2020/11/11/#eclair-1545
[bip388]: https://github.com/bitcoin/bips/pull/1389
[core lightning 23.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.11.2
[libsecp256k1 0.4.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.1
