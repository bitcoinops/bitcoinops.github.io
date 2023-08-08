---
title: 'Bitcoin Optech Newsletter #263'
permalink: /en/newsletters/2023/08/09/
name: 2023-08-09-newsletter
slug: 2023-08-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter warns about a severe vulnerability in uses of
Libbitcoin's Bitcoin Explorer (bx) tool, summarizes a discussion about
the design of denial-of-service protection, announces a plan to begin
testing and collecting data about HTLC endorsement, and describes two
proposed changes to Bitcoin Core's transaction relay policy.  Also
included are our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## Action items

- **Severe Libbitcoin Bitcoin Explorer vulnerability:** if you used the
  `bx seed` command to create [BIP32][topic BIP32] seeds, [BIP39][]
  mnemonics, private keys, or any other secure material, consider
  immediately moving any funds to a different secure address.  See the
  News section below for details.

## News

- **Denial-of-Service (DoS) protection design philosophy:** Anthony
  Towns [posted][towns dos] to the Lightning-Dev mailing list in
  response to the [channel jamming][topic channel jamming attacks] part
  of the notes for the recent LN developers meeting (see [Newsletter
  #261][news261 jamming]).  The notes said "the cost that will deter an
  attacker is unreasonable for an honest user, and the cost that is
  reasonable for an honest user is too low [to deter] an attacker."

  Towns suggested an alternative to trying to price out attackers: make
  the costs paid by both attackers and honest users reflect the
  underlying costs paid by the node operators providing the service.
  That way, a node operator who is earning a reasonable return on
  providing services to honest users will continue earning reasonable
  returns if attackers begin using those services.  If the attackers try
  to deny services to honest users by consuming an excess amount of node
  resources, the nodes providing those resources have an
  incentive---greater income---to scale up the resources they provide.

  As a suggestion for how that scheme could work, Towns resurrected an
  idea from several years ago (see [Newsletter #86][news86 hold fees])
  about a combination of forward commitment fees and reverse hold fees
  that would be charged in addition to the usual fee for a successful
  payment.  As an HTLC propagated from spender Alice to forwarding node
  Bob, Alice would pay a small forward commitment fee; Bob's portion of that fee would
  correspond to his cost for processing the HTLC (such as bandwidth).
  At some point after he accepted the HTLC, Bob would be responsible for
  periodically paying a small reverse hold fee to Alice until the HTLC
  was settled; this would compensate her for the delay in either
  accepting it or canceling her payment.  If Bob immediately forwarded
  the payment to Carol after receiving it, he would pay her a slightly
  smaller forward commitment fee than he received from Alice (that
  difference being the actual amount he received in compensation) and
  Carol would provide him a slightly larger reverse hold fee (again, the
  difference being his compensation).  As long as none of the
  forwarding nodes or the receiver delayed the HTLC, the only extra
  costs over the normal success fee would be the small forward
  commitment fees.  But, if the receiver or any of the hops delayed the
  payment, they would ultimately be responsible for paying all the
  upstream node's reverse hold fees.

  Clara Shikhelman [replied][shikhelman dos] that reverse hold fees paid
  over the course of a period of time could easily exceed the amount a
  node would earn from success fees for the same amount of capital for
  the same amount of time.  That would make it tempting for a malicious
  node to abuse the mechanism to collect fees from its counterparties.
  She described some challenges that would be faced by a mechanism like
  the one Towns sketched and he [replied][towns dos2] with counterpoints
  and a summary: "I think monetary-based DoS deterrence is still likely
  to be a fruitful area for research if people are interested, even if
  the current implementation work is focused on reputation-based
  methods."

- **HTLC endorsement testing and data collection:** Carla Kirk-Cohen and
  Clara Shikhelman [posted][kcs endorsement] to the Lightning-Dev
  mailing list to announce that developers associated with Eclair, Core
  Lightning, and LND were implementing parts of the [HTLC
  endorsement][topic htlc endorsement] protocol in order to begin
  collecting data related to it.  The help this, they're proposing a set
  of data that will be useful for test nodes to collect for researchers.
  Many of the fields are intended to have their data randomized to
  prevent leaking information that could reduce the privacy of spenders
  and receivers.  They intend for there to be multiple phases of
  testing and outline how participating nodes will act during the
  different phases.

- **Proposed changes to Bitcoin Core default relay policy:** Peter Todd
  started two threads on the Bitcoin-Dev mailing list related to pull
  requests he's opened to change Bitcoin Core's default relay policy.

  - *Full RBF by default:* the [first thread][todd rbf] and [pull
    request][bitcoin core #28132] proposes making [full RBF][topic rbf]
    the default setting in a future version of Bitcoin Core.  By default,
    Bitcoin Core will currently only relay and accept into its mempool
    replacements of unconfirmed transactions if the transaction being
    replaced contains the [BIP125][] signal indicating opt-in
    replaceability (and if both the original transaction and the
    replacement transaction follow some other rules), called _opt-in RBF_.
    A configuration option, `-mempoolfullrbf`, allows node operators to
    instead choose to accept replacements of any unconfirmed transaction
    even if it didn't contain the BIP125 signal, called _full RBF_ (see
    [Newsletter #208][news208 rbf]).
    Peter Todd's proposal would make full RBF the default but allow node
    operators to change their settings to choose opt-in RBF instead.

      Peter Todd argues that the change is warranted because (according
      to his measurements, which have been [called into doubt][towns
      rbf]), a significant percentage of mining hash rate is apparently
      following full RBF rules and there are enough relay nodes that
      have enabled full RBF to allow non-signaled replacements to reach
      those miners.  He also says he is unaware of any active
      businesses that currently accept unconfirmed onchain transactions
      as final payment.

  - *Removing specific limits on `OP_RETURN` outputs:* the [second
    thread][todd opr] and [pull request][bitcoin core #28130] proposes
    removing Bitcoin Core's specific limits on transactions that have
    an output script that starts with the `OP_RETURN` opcode (an
    _OP_RETURN output_).  Currently, Bitcoin Core will not (by default)
    relay or accept into its mempool any transaction that has more than
    one `OP_RETURN` output or any `OP_RETURN` output that has an output
    script more than 83 bytes in size (which translates to 80 bytes of
    arbitrary data).

      Allowing relay and default mining of a small amount of data in
      `OP_RETURN` outputs was motivated by people previously storing
      data in other types of outputs that had to be stored in the UTXO
      set, often in perpetuity.  `OP_RETURN` outputs don't need to be
      stored in the UTXO set and so aren't as problematic.  Since then,
      some people have begun storing large amounts of data in
      transaction witnesses.

      The pull request would default to allowing any number of
      `OP_RETURN` outputs and any amount of data in an `OP_RETURN`
      output as long as the transactions otherwise obey Bitcoin Core's
      other relay policies (e.g., had a total transaction size of less than 100,000
      vbytes).  As of this writing, opinions on the pull request were
      mixed, with some developers arguing that the relaxed policy would
      increase the amount of non-financial data stored on the block
      chain and others arguing that there's no reason to prevent people
      from using `OP_RETURN` outputs when other methods of adding data
      to the block chain are being used.

- **Libbitcoin Bitcoin Explorer security disclosure:** several security
  researchers investigating a recent loss of bitcoins among users of
  Libbitcoin [discovered][milksad] that program's Bitcoin Explorer (bx)
  tool's `seed` command only generated about 4 billion different unique
  values.  An attacker who assumed the values were used to create
  private keys, or wallets with particular derivation paths (e.g.,
  following BIP39), could potentially search all possible wallets within
  a day using a single commodity computer, giving them the ability to
  steal any funds received to those keys or wallets.  A likely such
  theft occurred on 12 July 2023 with apparent losses of almost 30 BTC
  (approximately $850,000 USD at the time).

    Several processes similar to the one that likely led to the loss of
    funds have been found [described][mb milksad] in the book _Mastering
    Bitcoin_, the [documentation homepage][bx home] for Bitcoin
    Explorer, and many other places in Bitcoin Explorer's documentation
    (e.g. [1][bx1], [2][bx2], [3][bx3]).  None of that documentation
    clearly warned that it was unsafe, except for the [online
    documentation][seed doc] of the `seed` command.

    Optech's recommendation is for anyone who thinks they may have used
    `bx seed` to generate wallets or addresses is to review the
    [disclosure page][milksad] and potentially use the service they
    provide for testing hashes of vulnerable seeds.  If you used the same process
    discovered by the attacker, your bitcoins have likely already been
    stolen---but if you used a variation on the process, you might still
    have a chance to move your bitcoins to safety.  If you use a wallet
    or other software that you think might use Libbitcoin, please
    advise the developers about the vulnernability and ask them to
    investigate.

    We thank the researchers for their significant efforts in making a
    [responsible disclosure][topic responsible disclosures] of
    [CVE-2023-39910][].

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Silent Payments: Implement BIP352][review club 28122]
is a PR by josibake that takes the first step in adding
[silent payments][topic silent payments] to the Bitcoin Core wallet.
This PR implements only the [BIP352][] logic, and doesn't include wallet changes.

{% include functions/details-list.md
  q0="Why does the PR add a custom ECDH hash function, rather than
      using the default one provided by `secp256k1`?"
  a0="We actually _don't_ want to hash the ECDH result; the custom
      function prevents the default application of `sha256` on the
      result of the ECDH operation. This is needed when the creator
      of the transaction does not control all of the inputs.
      Not hashing the result during ECDH allows individual participants
      to do ECDH with just their private key, and then pass the partial
      ECDH along. The partial ECDH results can then be summed up, and
      the rest of the protocol performed (hashing with the counter, etc.)."
  a0link="https://bitcoincore.reviews/28122#l-126"

  q1="The PR adds functions for encoding and decoding silent payment
      addresses. Why can’t we just add silent payment addresses as a new
      `CTxDestination` variant and use the existing encoder class and
      decoder function?"
  a1="A silent payment address doesn't actually encode a specific output
      script; it's not a `scriptPubKey`. Rather, it encodes the public keys
      needed to _derive_ the actual output script, which is also dependent
      on the inputs of your silent payment transaction.
      That is, instead of giving you a `scriptPubKey` to send to
      (which is what a traditional address does), a silent payment address
      gives you pubkeys to do ECDH with, and then the protocol dictates how
      to turn that shared secret into a `scriptPubKey` that the receiver
      will be able to detect and later spend from."
  a1link="https://bitcoincore.reviews/28122#l-153"

  q2="[BIP352][] refers to versioning and forward compatibility.
      What is forward compatibility and why is it important?"
  a2="It allows (for example) a v0 wallet to decode and send to a v1 (and
      v2 and so on) silent payment address (even though the wallet will
      not be able to generate a v1 address).
      This is important so that wallets don't need to upgrade immediately
      (or else lose all functionality) when a new version is created."
  a2link="https://bitcoincore.reviews/28122#l-170"

  q3="What if a new version wants to intentionally break compatibility?"
  a3="v31 is reserved for an upgrade that would break compatibility."
  a3link="https://bitcoincore.reviews/28122#l-186"

  q4="Why is it okay to allocate only one compatibility-breaking version
      number (v31)?"
  a4="We can postpone defining new rules for how versions _after_ the
      breaking version should be treated until later, when needed."
  a4link="https://bitcoincore.reviews/28122#l-188"

  q5="In `DecodeSilentAddress` there is a check on the version and
      data size. What is this check doing and why is it important?"
  a5="If a new version adds more data to the address, we need a way of
      getting only the forward compatible parts, that is, we must restrict
      ourselves to parsing the first 66 bytes (v0 format). This is
      important for forward compatibility."
  a5link="https://bitcoincore.reviews/28122#l-194"

  q6="The new silent payments code is under the wallet directory in
      `src/wallet/silentpayments.cpp`. Is this a good place?
      Can you think of a use case where we would want to use silent
      payments code outside of a wallet context?"
  a6="It's not ideal if one wants to implement a wallet-less server
      that detects silent payments (or does related computation) on
      behalf of a lighter silent payment wallet. One can imagine a use
      case where a full node indexes the tweak data for transactions
      and stores it in an index for light clients to query, or serves
      that data via a [BIP158][]-like filter. However, until such
      use cases arise, leaving the code in `src/wallet` provides
      better code organization."
  a6link="https://bitcoincore.reviews/28122#l-205"

  q7="The `Recipient` class is initialized with two private keys in
      the PR, the spend and scan key. are both keys necessary for scanning?"
  a7="No, only the scan key is needed. The ability to scan for silent
      payments without the spend key may be implemented in the future."
  a7link="https://bitcoincore.reviews/28122#l-217"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test release candidates.*

- [BDK 0.28.1][] is a release of this popular library for building
  wallet applications.  It includes a bug fix and adds a template for
  using [BIP86][] derivation paths for [P2TR][topic taproot] in
  [descriptors][topic descriptors].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27746][] simplifies the relationship between block
  storage and the chainstate objects by moving the decision of whether
  to store a block on disk to validation logic that is independent of
  the current chainstate.
  The decision of whether to store a block on disk is related to
  validation rules that do not require any UTXO state. Previously,
  Bitcoin Core was using chainstate-specific heuristics for anti-DoS
  reasons, but with [assumeUTXO][topic assumeutxo] and the possibility
  of two coexisting chainstates, this has been reworked to achieve
  the proposed separation.

- [Core Lightning #6376][] and [#6475][core lightning #6475] implement a
  plugin called `renepay` that uses Pickhardt Payments to construct
  optimal [multipath payments][topic multipath payments] (see
  [Newsletter #192][news192 pp]). Pickhardt Payments assumes liquidity in
  each channel to be randomly distributed between 0 to full capacity in
  the direction of flow. Large payment amounts may cause a failure
  because a route may not provide sufficient liquidity along it, while
  splitting a payment into many parts may cause a failure since each
  separate route has a chance of failure. A payment is then modeled as
  flow in the Lightning Network aiming to find a middle ground between
  the count of payment parts and the amount per part. Using this
  approach, Pickhardt Payments finds the optimal flow that satisfies the
  capacity and balance constraints while maximizing the chance of
  success. Responses from incomplete payment attempts are used to update
  the assumed liquidity distributions for all involved channels reducing
  those that failed to forward, but also accounting for the amounts
  successfully staged. Since incorporating [BOLT7][] base fees in the flow
  calculation would be computationally difficult (see [Newsletter
  #163][news163 base]), nodes using `renepay`
  for payment planning will instead overestimate the relative fee for
  channels with non-zero base fees. The onion packages constructed for
  payment delivery use the actual fees.

- [Core Lightning #6466][] and [#6473][core lightning #6473] add
  support for backing up and restoring the wallet's [master
  secret][topic BIP32] in the [codex32][topic codex32] format specified
  in [BIP93][].

- [Core Lightning #6253][] and [#5675][core lightning #5675] add an
  experimental implementation of the [BOLTs #863][] draft specification
  for [splicing][topic splicing].  When both sides of a channel support
  splicing, they can splice-in funds into the channel using an onchain
  transaction or splice-out funds from the channel by spending them
  onchain.  Neither operation requires closing the channel and they can
  continue sending, receiving, or forwarding payments using whatever
  part of the original balance remains as they wait for the onchain
  splicing transaction to confirm to a safe depth, at which point any
  funds spliced into the channel also become available.  A key
  advantage of splicing is that LN-enabled wallets can keep the vast
  majority of their funds offchain and then create onchain spends from
  that balance when requested, allowing wallets to show users a single
  balance rather than a balance split between offchain and onchain
  funds.

- [Rust Bitcoin #1945][] modifies the project's policies for how much
  review a PR requires before it is merged if it's just a refactor.
  Other projects with challenges getting refactors or small changes
  reviewed to the same high standard they hold other PRs may want to
  investigate Rust Bitcoin's new policy.

- [BOLTs #759][] adds support for [onion messages][topic onion messages]
  to the LN specification.  Onion messages allow sending one-way
  messages across the network.  Like payments (HTLCs), the messages use
  onion encryption so that each forwarding node only knows what peer it
  received the message from and what peer should next receive the
  message.  Message payloads are also encrypted so that only the
  ultimate receiver can read it.  Unlike forwarded HTLCs, which are
  bidirectional---the commitment flows downstream towards the receiver
  and the preimage necessary to claim the payment flows upstream towards
  the spender---the one-way nature of onion messages means forwarding
  nodes don't need to store anything about them after the message has
  been forwarded, although some proposed denial-of-service protection
  mechanisms do depend on keeping a small amount of aggregate
  information on a per-peer basis (see [Newsletter #207][news207
  onion]).  Two-way messaging can be accomplished by the original sender
  including a return path in their message.  Onion messages use [blinded
  paths][topic rv routing], which was added to the LN specification a
  few months ago (see [Newsletter #245][news245 blinded]), and onion
  messages are themselves used by the under-development [offers
  protocol][topic offers].

{% include references.md %}
{% include linkers/issues.md v=2 issues="27746,6376,6475,6466,6473,6253,5675,863,1945,759,28132,28130" %}
[news245 blinded]: /en/newsletters/2023/04/05/#bolts-765
[towns dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004020.html
[news86 hold fees]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[shikhelman dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004033.html
[towns dos2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004035.html
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004034.html
[todd rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021823.html
[towns rbf]: https://github.com/bitcoin/bitcoin/pull/28132#issuecomment-1657669845
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[news261 jamming]: /en/newsletters/2023/07/26/#channel-jamming-mitigation-proposals
[todd opr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021840.html
[CVE-2023-39910]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-39910
[milksad]: https://milksad.info/
[mb milksad]: https://github.com/bitcoinbook/bitcoinbook/commit/76c5ba8000d6de20b4adaf802329b501a5d5d1db#diff-7a291d80bf434822f6a737f3e564be6a67432e2f3f12669cf0469aedf56849bbR126-R134
[bx home]: https://web.archive.org/web/20230319035342/https://github.com/libbitcoin/libbitcoin-explorer/wiki
[bx1]: https://web.archive.org/web/20210122102649/https://github.com/libbitcoin/libbitcoin-explorer/wiki/How-to-Receive-Bitcoin
[bx2]: https://web.archive.org/web/20210122102714/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-mnemonic-new
[bx3]: https://web.archive.org/web/20210506162634/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-hd-new
[seed doc]: https://web.archive.org/web/20210122102710/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-seed
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[bdk 0.28.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.1
[review club 28122]: https://bitcoincore.reviews/28122
[bip352]: https://github.com/bitcoin/bips/pull/1458
[bip158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news163 base]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
