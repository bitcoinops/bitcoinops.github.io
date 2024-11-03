---
title: 'Bitcoin Optech Newsletter #230'
permalink: /en/newsletters/2022/12/14/
name: 2022-12-14-newsletter
slug: 2022-12-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal for a modified version of
LN that may improve compatibility with channel factories, describes
software for mitigating some effects of channel jamming attacks without
changing the LN protocol, and links to a website for tracking unsignaled
transaction replacements.  Also included are our regular sections with
announcements of new client and service software, summaries of popular
questions and answers on the Bitcoin Stack Exchange, and descriptions of
notable changes to popular Bitcoin infrastructure software.

## News

- **Factory-optimized LN protocol proposal:** John Law [posted][law
  factory] to the Lightning-Dev mailing list the description of a
  protocol optimized for creating [channel factories][topic channel
  factories].  Channel factories allow multiple users to trustlessly
  open multiple channels between pairs of users with only a single
  transaction onchain.  For example, 20 users could cooperate to create
  an onchain transaction about 10 times larger than a normal two-party
  open but which opened a total of 190 channels<!-- n=20 ; n*(n - 1)/2
  -->.

  Law notes that the existing LN channel protocol (commonly called
  LN-penalty) creates two problems for channels opened from within a
  factory:

  - *Long required HTLC expiries:* trustlessness requires that any
    participant in a factory be able to exit it and regain exclusive
    control over their funds onchain.  This is accomplished by the
    participant publishing the current state of balances in the
    factory onchain.  However, a mechanism is needed to prevent the
    participant from publishing an earlier state, e.g. one where they
    controlled a greater amount of money.  The original factory
    proposal accomplishes this by using one or more timelocked
    transactions that ensure more recent states can be confirmed more
    quickly than outdated states.

    A consequence of this, described by Law, is that any LN payment
    ([HTLC][topic htlc]) that is routed through a channel in a
    channel factory needs to provide enough time for the latest
    state timelock to expire so the factory can be unilaterally
    closed.  Worse, this applies each time a payment is forwarded
    through a factory.  For example, if a payment is forwarded
    through 10 factories each with a 1-day expiry, it's possible that
    a payment could be [jammed][topic channel jamming attacks] by
    accident or on purpose for 10 days (or longer, depending on
    other HTLC settings).

  - *All or nothing:* for factories to truly achieve their best
    efficiencies, all of their channels also need to be cooperatively
    closed in a single onchain transaction.  Cooperative closes aren't
    possible if any of the original participants becomes
    unresponsive---and the chance of a participant becoming
    unresponsive approaches 100% as the number of participants
    increases, limiting the maximum benefit factories can provide.

    Law cites previous work in allowing factories to remain
    operational even if one participant wants to leave or,
    conversely, one participant becomes unresponsive, such as the
    proposals for `OP_TAPLEAF_UPDATE_VERIFY` and `OP_EVICT` (see
    Newsletters [#166][news166 tluv] and [#189][news189 evict]).

  Three proposed protocols are presented by Law to address the
  concerns.  All derive from a previous proposal by Law [posted][law
  tp] in October for *tunable penalties*---the ability to separate the
  management of the enforcement mechanism (penalties) from the
  management of other funds.  That previous proposal has not yet
  received any discussion on the Lightning-Dev mailing list.  As of
  this writing, Law's new proposal has also not received any
  discussion.  If the proposals are sound, they would have the
  advantage over other proposals of not requiring any changes to
  Bitcoin's consensus rules. {% assign timestamp="2:34" %}

- **Local jamming to prevent remote jamming:** Joost Jager
  [posted][jager jam] to the Lightning-Dev mailing list a link and
  explanation for his project, [CircuitBreaker][].  This program,
  designed to be compatible with LND, enforces limits on the number of
  pending payments ([HTLCs][topic htlc]) the local node will forward on
  behalf of each of its peers.  For example, consider the worst case
  HTLC jamming attack:

  ![Illustration of two different jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

  With the current LN protocol, Alice is fundamentally limited to
  concurrently forwarding a maximum of [483 pending HTLCs][].  If she
  instead uses CircuitBreaker to limit her channel with Mallory to
  10 concurrent pending HTLC forwards, her downstream channel with Bob
  (not visualized) and all other channels in this circuit will be
  protected from all but those first 10 HTLCs that Mallory keeps
  pending.  This may significantly reduce the effectiveness of
  Mallory's attack by requiring she open many more channels to block
  the same number of HTLC slots, which may increase the cost of the
  attack by requiring she pay more onchain fees.

  Although CircuitBreaker was originally implemented to simply refuse
  to accept any HTLCs in any channel which exceeded its limit, Jager
  notes that he recently implemented an optional additional mode which
  puts any HTLCs in a queue rather than immediately refusing or
  forwarding them.  When the number of concurrent pending HTLCs in a
  channel drops below the channel limit, CircuitBreaker forwards the
  oldest non-expired HTLC from the queue.  Jager describes two
  advantages of this approach:

  - *Backpressure:* if a node in the middle of a circuit refuses an
    HTLC, all nodes in the circuit (not just those further down the
    circuit) can use that HTLC's slot and funds to forward other
    payments.  That means there's limited incentive for Alice to
    refuse more than 10 HTLCs from Mallory---she can simply hope that
    some later node in the circuit will run CircuitBreaker or
    equivalent software.

    However, if a later node (say Bob) uses CircuitBreaker to queue
    excess HTLCs, then Alice could still have her HTLC slots or
    funds exhausted by Mallory even though Bob and later nodes in
    the circuit retain the same benefits as now (with the exception
    of possibly increased channel closing costs for Bob in some
    cases; see Jager's email or the CircuitBreaker documentation for
    details).  This gently pressures Alice into running
    CircuitBreaker or something similar.

  - *Failure attribution:* the current LN protocol allows (in many
    cases) a spender to identify which channel refused to forward an
    HTLC.  Some spender software tries to avoid using those channels
    in future HTLCs for a certain amount of time.  In the case of
    refusing HTLCs from malicious actors like Mallory, this obviously
    doesn't matter, but if a node running CircuitBreaker refuses HTLCs
    from honest spenders, this may not only reduce its income from
    those refused HTLCs but also the income it would've received from
    subsequent payment attempts.

    However, the LN protocol doesn't currently have a widely
    deployed way to determine which channel delayed an HTLC, so it's
    less consequential in this regard to delay forwarding an HTLC
    than it is to outright refuse to forward it.  Jager notes that
    this is changing due to many LN implementations working on
    supporting more detailed onion-routed error messages (see
    [Newsletters #224][news224 fat]), so this advantage may
    disappear some day.

  Jager calls CircuitBreaker, "a simple but imperfect way to deal with
  channel jamming and spamming".  Work continues on finding and
  deploying a protocol-level change that will more comprehensively
  mitigate concerns about jamming attacks, but CircuitBreaker stands
  out as a seemingly reasonable solution that's compatible with the
  current LN protocol and which any LND user can deploy immediately on
  their forwarding node.  CircuitBreaker is MIT licensed and
  conceptually simple, so it should be possible to adapt or port for
  other LN implementations. {% assign timestamp="9:28" %}

- **Monitoring of full-RBF replacements:** developer 0xB10C
  [posted][0xb10c rbf] to the Bitcoin-Dev mailing list that they've
  begun providing [publicly accessible][rbf mpo] monitoring of
  transaction replacements in the mempool of their Bitcoin Core node
  that don't contain the BIP125 signal.  Their node allows full-RBF
  replacement using the `mempoolfullrbf` configuration option (see
  [Newsletter #208][news208 rbf]).

  Users and services can use the website as an indicator for which
  large mining pools might be currently confirming unsignaled
  replacement transactions (if any are doing so).  However, we remind
  readers that payments received in unconfirmed transactions cannot be
  guaranteed even if miners don't currently seem to be mining
  unsignaled replacements. {% assign timestamp="29:17" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Lily Wallet adds coin selection:**
  Lily Wallet [v1.2.0][lily v1.2.0] adds [coin selection][topic coin selection] features. {% assign timestamp="38:57" %}

- **Vortex software creates LN channels from a coinjoin:**
  Using [taproot][topic taproot] and collaborative [coinjoin][topic coinjoin]
  transactions, users have [opened LN channels][vortex tweet] on Bitcoin mainnet using the
  [Vortex][vortex github] software. {% assign timestamp="41:42" %}

- **Mutiny demonstrates LN node in a browser PoC:**
  Using WASM and LDK, developers [demonstrated][mutiny tweet] a
  [proof-of-concept][mutiny github] implementation of an LN node running in a
  mobile phone browser. {% assign timestamp="49:31" %}

- **Coinkite launches BinaryWatch.org:**
  The [BinaryWatch.org][] website checks binaries from Bitcoin-related projects
  and monitors for any changes. The company also operates [bitcoinbinary.org][] a
  service that archives [reproducible builds][topic reproducible builds] for
  Bitcoin-related projects. {% assign timestamp="55:02" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why is connecting to the Bitcoin network exclusively over Tor considered a bad practice?]({{bse}}116146)
  Several answers explain that due to the lower cost of being able to generate many
  Tor addresses as compared to IPv4 and IPv6 addresses, a Bitcoin node operator
  exclusively using the Tor network could more easily be [eclipse attacked][topic eclipse
  attacks] when compared to operating only on clearnet or with a
  combination of [anonymity networks][topic anonymity networks]. {% assign timestamp="57:46" %}

- [Why aren't 3 party (or more) channels realistically possible in Lightning today?]({{bse}}116257)
  Murch explains that since LN channels currently use the LN penalty mechanism
  that allocates *all* channel funds to a single counterparty in the event of a
  breach, extending LN penalty to handle multiple recipients of a justice
  transaction may be overly complicated and involve excessive overhead to
  implement. He then explains [eltoo's][topic eltoo] mechanism and how it might
  handle multiparty channels. {% assign timestamp="1:01:38" %}

- [With legacy wallets deprecated, will Bitcoin Core be able to sign messages for an address?]({{bse}}116187)
  Pieter Wuille distinguishes between Bitcoin Core [deprecating legacy
  wallets][news125 legacy descriptor wallets] and the continued support for
  older address types like P2PKH addresses even in newer [descriptor][topic
  descriptors] wallets. While message signing is currently only possible for
  P2PKH addresses, efforts around [BIP322][topic generic signmessage] could
  allow for message signing across other address types. {% assign timestamp="1:06:14" %}

- [How do I set up a time-decay multisig?]({{bse}}116035)
  User Yoda asks how to set up a time-decaying multisig, a UTXO that is spendable
  with a broadening set of pubkeys over time. Michael Folkson provides an
  example using [policy][news74 policy miniscript] and [miniscript][topic
  miniscript], links to related resources, and notes the lack of user-friendly
  options currently. {% assign timestamp="1:09:07" %}

- [When is a miniscript solution malleable?]({{bse}}116275)
  Antoine Poinsot defines what malleability means in the context of
  miniscript, describes static analysis of malleability in miniscript, and walks
  through the original question's malleability example. {% assign timestamp="1:11:01" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 24.0.1][] is a major release of the mostly widely used
  full node software.  Its new features include an option for
  configuring the node's [Replace-By-Fee][topic rbf] (RBF) policy, a new
  `sendall` RPC for easily spending all of a wallet's funds in a single
  transaction (or for otherwise creating transactions with no change
  output), a `simulaterawtransaction` RPC that can be used to verify how
  a transaction will effect a wallet (e.g., for ensuring a coinjoin
  transaction only decreases the value of a wallet by fees), the ability
  to create watch-only [descriptors][topic descriptors] containing
  [miniscript][topic miniscript] expressions for improved forward
  compatibility with other software, and the automatic application of
  certain setting changes made in the GUI to RPC-based actions.  See the
  [release notes][bcc rn] for the full list of new features and bug
  fixes.

  Note: a version 24.0 was tagged and had its binaries released, but
  project maintainers never announced it and instead worked with other
  contributors to resolve [some last-minute issues][bcc milestone
  24.0.1], making this release of 24.0.1 the first announced release
  of the 24.x branch. {% assign timestamp="1:14:02" %}

- [libsecp256k1 0.2.0][] is the first tagged release of this widely-used
  library for Bitcoin-related cryptographic operations.  An
  [announcement][libsecp256k1 announce] of the release states, "for a
  long time, libsecp256k1's development only had a master branch,
  creating unclarity about API compatibility and stability. Going
  forward, we will be creating tagged releases when relevant
  improvements are merged, following a semantic versioning scheme. [...]
  We're skipping version 0.1.0 because this version number was set in
  our autotools build scripts for years, and does not uniquely identify
  a set of source files. We will not be creating binary releases, but
  will take expected ABI compatibility issues into account for release
  notes and versioning." {% assign timestamp="1:14:30" %}

- [Core Lightning 22.11.1][] is a minor release that temporarily
  reintroduces some features that were deprecated in 22.11, as requested
  by some downstream developers. {% assign timestamp="1:15:26" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25934][] adds an optional `label` argument to the
  `listsinceblock` RPC. Only transactions matching the label will be returned
  when a label is specified. {% assign timestamp="1:16:24" %}

- [LND #7159][] updates the `ListInvoiceRequest` and
  `ListPaymentsRequest` RPCs with new `creation_date_start` and
  `creation_date_end` fields that can be used to filter out invoices and
  payments before or after the indicated date and time. {% assign timestamp="1:17:10" %}

- [LDK #1835][] adds a fake Short Channel IDentifier (SCID) namespace for intercepted HTLCs, enabling
  Lightning Service Providers (LSPs) to create a [just-in-time][topic jit routing]
  (JIT) channel for end users to receive a lightning payment. This is done
  by including fake route hints in end-user invoices that signal to LDK
  that this is an intercept forward, similar to
  [phantom payments][LDK phantom payments] (see [Newsletter #188][news188 phantom]). LDK then generates an event,
  allowing the LSP the opportunity to open the JIT channel. The LSP can
  then forward the payment over the newly opened channel or fail it. {% assign timestamp="1:17:38" %}

- [BOLTs #1021][] allows onion-routing error messages to contain a
  [TLV][] stream, which may be used in the future to include additional
  information about the failure.  This is a first step towards
  implementing [fat errors][news224 fat] as proposed in [BOLTs #1044][]. {% assign timestamp="1:21:28" %}

## Happy holidays!

This is Bitcoin Optech's final regular newsletter of the year.  On
Wednesday, December 21st, we'll publish our fifth annual year-in-review
newsletter.  Regular publication will resume on Wednesday, January 4th.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25934,7159,1835,1021,1044" %}
[bitcoin core 24.0.1]: https://bitcoincore.org/bin/bitcoin-core-24.0.1/
[bcc rn]: https://bitcoincore.org/en/releases/24.0.1/
[bcc milestone 24.0.1]: https://github.com/bitcoin/bitcoin/milestone/59?closed=1
[libsecp256k1 0.2.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.2.0
[libsecp256k1 announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021271.html
[core lightning 22.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v22.11.1
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[law factory]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003782.html
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news189 evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[law tp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[jager jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003781.html
[circuitbreaker]: https://github.com/lightningequipment/circuitbreaker
[0xb10c rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021258.html
[rbf mpo]: https://fullrbf.mempool.observer/
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[tlv]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[483 pending htlcs]: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md#rationale-7
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[LDK phantom payments]: https://lightningdevkit.org/blog/introducing-phantom-node-payments/
[news125 legacy descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news74 policy miniscript]: /en/newsletters/2019/11/27/#what-is-the-difference-between-bitcoin-policy-language-and-miniscript
[lily v1.2.0]: https://github.com/Lily-Technologies/lily-wallet/releases/tag/v1.2.0
[vortex tweet]: https://twitter.com/benthecarman/status/1590886577940889600
[vortex github]: https://github.com/ln-vortex/ln-vortex
[mutiny tweet]: https://twitter.com/benthecarman/status/1595395624010190850
[mutiny github]: https://github.com/BitcoinDevShop/mutiny-web-poc
[BinaryWatch.org]: https://binarywatch.org/
[bitcoinbinary.org]: https://bitcoinbinary.org/
