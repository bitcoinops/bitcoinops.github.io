---
title: 'Bitcoin Optech Newsletter #253'
permalink: /en/newsletters/2023/05/31/
name: 2023-05-31-newsletter
slug: 2023-05-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for a new managed joinpool
protocol and summarizes an idea for relaying transactions using the
Nostr protocol.  Also included is another entry in our limited weekly
series about mempool policy, plus our regular sections summarizing
notable questions and answers posted to the Bitcoin Stack Exchange,
listing new software releases and release candidates, and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Proposal for a managed joinpool protocol:** this week, Burak Keceli
  [posted][keceli ark] to the Bitcoin-Dev mailing list an idea for
  _Ark_, a new [joinpool][topic joinpools]-style protocol where owners
  of bitcoins opt-in to using a counterparty as a co-signer on all
  transactions within a certain time period.  The owners can either
  unilaterally withdraw their bitcoins onchain after the expiry of the
  timelock or instantly and trustlessly transfer them offchain to the
  counterparty before the timelock expires.

    Like any Bitcoin user, the counterparty can broadcast an onchain
    transaction at any time that spends only their own funds.  If an
    output from that transaction is used as an input to the offchain
    transaction that transfers funds from the owner to the counterparty,
    it makes the offchain transfer invalid unless the onchain
    transaction confirms within a reasonable amount of time.  In this
    case, the counterparty won't sign their onchain transaction until
    they receive the signed offchain transaction.  This provides a
    trustless single-hop, single-direction atomic transfer protocol from
    the owner to the counterparty.  Keceli describes three uses for this
    atomic transfer protocol:

    - *Mixing coins:* several users within the joinpool can all, with
      the cooperation of the counterparty, make atomic swaps of their
      current offchain values for an equivalent amount of new offchain
      values.  This can be performed quickly because a failure of the
      onchain component will simply unwind the swap, returning all funds
      to where they started.  A blinding protocol similar to those used
      by some existing [coinjoin][topic coinjoin] implementations can
      prevent any user or the counterparty from determining which user
      ended up with which bitcoins.

    - *Making internal transfers:* one user can transfer their offchain
      funds to another user with the same counterparty.  The atomicity
      assures that either the receiver will get their money or the
      spender receives a refund.  For a receiver that doesn't trust both
      the spender and the counterparty, they will need to wait for as
      many confirmations as they would for a regular onchain
      transaction.

        Keceli and a commentator [link][keceli reply0] to
        [previous][harding reply0] research describing how a zero-conf
        payment can be made uneconomical to double spend by pairing it
        with a fidelity bond that can be claimed by any miner who
        observed both versions of the double-spent transaction.  That
        might allow receivers to accept a payment within seconds even if
        they didn't trust any other individual parties.

    - *Paying LN invoices:* a user can quickly commit to paying
      their offchain funds to the counterparty if that counterparty
      knows a secret, allowing the user to pay LN-style [HTLC][topic
      HTLC] invoices through the counterparty.

        Similar to the problem with internal transfers, a user can't
        receive funds trustlessly, so they shouldn't reveal a secret
        before a payment has received a sufficient number of
        confirmations or it is secured by a fidelity bond that they find
        persuasive.

    Keceli says the base protocol can be implemented on Bitcoin today
    using frequent interaction between members of the joinpool.  If a
    [covenant][topic covenants] proposal like
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify],
    [SIGHASH_ANYPREVOUT][topic sighash_anyprevout], or [OP_CAT +
    OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] is implemented,
    members of the joinpool will only need to interact with the
    counterparty when participating in a coinjoin, making a payment, or
    refreshing the timelock on their offchain funds.

    Every coinjoin, payment, or refresh requires the publication of a
    commitment in an onchain transaction, although an essentially
    unlimited number of operations can all be bundled in the same
    small transaction.  To allow operations to complete quickly, Keceli
    suggests an onchain transaction be made approximately every five
    seconds so users don't need to wait longer than that amount of time.
    Each transaction is separate---it's not possible to combine the
    commitments from multiple transactions using [replace-by-fee][topic
    rbf] without breaking the commitments or requiring participation
    from all the users involved in previous rounds---so over 6.3 million
    transactions might need to be confirmed each year for one
    counterparty, although the individual transactions are fairly small.

    Comments about the protocol posted to the mailing list included:

    - *A request for more documentation:* at [least][stone reply] two
      [respondents][dryja reply] requested additional documentation
      about how the system worked, finding it hard to analyze given the
      high-level description provided to the mailing list.  Keceli has
      since begun publishing [draft specifications][arc specs].

    - *Concern that receiving is slow compared to LN:* [several][dryja
      reply] people [noted][harding reply1] that, in the initial design,
      it's not possible to trustlessly receive a payment from the
      joinpool (either offchain or onchain) without waiting for a
      sufficient number of confirmations.  That can take hours, whereas
      many LN payments currently complete in less than a second. Even
      with fidelity bonds, LN would be faster on average.

    - *Concern that the onchain footprint is high:* one [reply][jk_14]
      noted that, at one transaction every five seconds, about 200 such
      counterparties would consume the entire space of every block.
      Another [reply][harding reply0] assumed that each of the
      counterparty's onchain transactions will be roughly the size of an LN
      channel open or cooperative close transaction, so a counterparty
      with a million users that creates 6.3 million onchain
      transactions per year would use an equivalent amount of space to
      each of those users opening or closing an average of 6.3 channels
      each per year; thus, LN's onchain costs could be lower than using
      the counterparty until it had reached massive scale.

    - *Concern about a large hot wallet and the capital costs:* a
      [reply][harding reply0] considered that the counterparty would
      need to keep an amount of bitcoin on hand (probably in a hot
      wallet) equal to the amount the users might spend in the near
      future.  After a spend, the counterparty would not receive their
      bitcoins back for a period of up to 28 days under the current
      design proposal.  If the counterparty charged a low interest rate
      of 1.5% per year on their capital, that would be an equivalent
      charge of 0.125% on the amount of every transaction performed with
      the involvement of the counterparty (including coinjoins, internal
      transfers, and LN payments).  By comparison, [public
      statistics][1ml stats] available at the time of writing (collected
      by 1ML) indicate a median feerate per hop for LN transfers of 0.0026%,
      almost 50 times lower.

    Several comments on the list were also excited for the proposal and
    were looking forward to seeing Keceli and others explore the design
    space of managed joinpools.

- **Transaction relay over Nostr:** Joost Jager [posted][jager nostr] to
  the Bitcoin-Dev mailing list to request feedback on the idea by Ben
  Carman of using the [Nostr][] protocol for relaying transactions that
  might not propagate well on the P2P network of Bitcoin full nodes that
  provide relay services.

    In particular, Jager examines the possibility of using Nostr for the
    relay of transaction packages, such as relaying an ancestor
    transaction with a feerate below the minimum accepted value by
    bundling it with a descendant that pays a high enough fee to
    compensate for its ancestor's deficiency.  This makes [CPFP][topic
    cpfp] fee bumping more reliable and efficient, and it's a feature
    called [package relay][topic package relay] that Bitcoin Core
    developers have been working on implementing for the Bitcoin P2P
    network.  A challenge in reviewing the design and implementation of
    package relay is ensuring that the new relay methods don't create
    any new denial-of-service (DoS) vulnerabilities against individual
    nodes and miners (or the network in general).

    Jager notes that Nostr relays have the ability to easily use
    alternative types of DoS protection from the P2P relay network, such
    as requiring a small payment to relay a transaction.  He suggests that can make
    it practical to allow package relay, or relay of other alternative
    transactions, even if a malicious transaction or package could lead
    to wasting a small amount of node resources.

    Included in Jager's post was a link to a [video][jager video] of him
    demonstrating the feature.  His post had only received a few replies
    as of this writing, although they were all positive.

## Waiting for confirmation #3: Bidding for block space

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/03-bidding-for-block-space.md %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Testing pruning logic with bitcoind]({{bse}}118159)
  Lightlike points out the debug-only `-fastprune` configuration option that uses smaller
  block files and a smaller minimum prune height for testing purposes.

- [What's the governing motivation for the descendent size limit?]({{bse}}118160)
  Sdaftuar explains that since both the mining and eviction algorithms (see
  [Newsletter #252][news252 incentives]) take quadratic, O(n²) time as a factor
  of the number of ancestors or descendants, [conservative policy limits][morcos
  limits] were put in place.

- [How does it contribute to the Bitcoin network when I run a node with a bigger than default mempool?]({{bse}}118137)
  Andrew Chow and Murch note potential downsides to a larger-than-default
  mempool including harming transaction rebroadcasting propagation and
  non-signaling transaction replacement propagation.

- [What is the maximum number of inputs/outputs a transaction can have?]({{bse}}118452)
  Murch provides post-taproot activation input and output numbers showing a
  3223 (P2WPKH) output maximum or a 1738 (P2TR keypath) input maximum.

- [Can 2-of-3 multisig funds be recovered without one of the xpubs?]({{bse}}118201)
  Murch explains that for multisig setups that don't use bare multisig, unless
  the same multisig output script has been used previously, all public keys are
  required in order to spend. He indicates that "a backup strategy for a multisig
  wallet must both preserve the private keys as well as the condition scripts of
  the outputs" and recommends [descriptors][topic descriptors] as a method of
  backing up condition scripts.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 25.0][] is a release for the next major
  version of Bitcoin Core.  The release adds a new `scanblocks` RPC,
  simplifies the use of `bitcoin-cli`, adds [miniscript][topic
  miniscript] support to the `finalizepsbt` RPC, reduces default memory
  use with the `blocksonly` configuration option, and speeds up wallet
  rescans when [compact block filters][topic compact block filters] are
  enabled---among many other new features, performance improvements, and
  bug fixes.  See the [release notes][bcc rn] for details.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27469][] speeds up Initial Block Download (IBD) when
  one or more wallets are being used.  With this change, a block will
  only be scanned for transactions matching a particular wallet if it
  was mined after the wallet's birthdate---the date recorded in the
  wallet as when it was created.

- [Bitcoin Core #27626][] allows a peer who has requested our node
  provide [compact block relay][topic compact block relay] in
  high-bandwidth mode to make up to three requests for transactions from
  the latest block we advertised to them.  Our node will respond to the
  request even if we didn't initially provide them with a compact block.
  This allows a peer who receives a compact block from one of its other
  peers to request any missing transactions from us, which can help if
  that other peer has become unresponsive.  This can help our peer
  validate the block faster, which may also help them use it sooner in
  time-critical functions, such as mining.

- [Bitcoin Core #25796][] adds a new `descriptorprocesspsbt` that can be
  used to update a [PSBT][topic psbt] with information that will help it
  later be signed or finalized.  A [descriptor][topic descriptors]
  provided to the RPC will be used to retrieve information from the mempool
  and UTXO set (and, if available, complete confirmed transactions when
  the node was started with the `txindex` configuration option).  The
  retrieved information will then be used to fill in the PSBT.

- [Eclair #2668][] prevents Eclair from attempting to pay more in fees
  to claim an [HTLC][topic htlc] onchain than the value it will receive
  from successfully resolving that HTLC.

- [Eclair #2666][] allows a remote peer receiving an [HTLC][topic htlc]
  to accept it even if the transaction fee that would need to be paid to
  accept it will reduce the peer's balance below the minimum channel
  reserve.  The channel reserve exists to ensure that a peer will lose
  at least a small amount of money if they attempt to close a channel in
  an outdated state, discouraging them from attempting theft.  However,
  if the remote peer accepts an HTLC that will pay them if it's
  successful, they will have more at stake than the reserve anyway.  If
  it's not successful, their balance will return to the previous amount,
  which will have been above the reserve.

    This is a mitigation for a *stuck funds problem*, which occurs when
    a payment would cause the party responsible for paying the fees to
    need to pay more value than their current available balance, even
    when they might be the party receiving the payment.  For previous
    discussion of this problem, see [Newsletter #85][news85 stuck
    funds].

- [BTCPay Server 97e7e][] begins setting the [BIP78][] `minfeerate`
  (minimum feerate) parameter for [payjoin][topic payjoin] payments.
  See also the [bug report][btcpay server #4689] that lead to this
  commit.

- [BIPs #1446][] makes a small change and a number of additions to the
  [BIP340][] specification of [schnorr signatures][topic schnorr
  signatures] for Bitcoin-related protocols.  The change is allowing the
  message to be signed to be an arbitrary length; previous versions of
  the BIP required that the message be exactly 32 bytes.  See a related
  change to the Libsecp256k1 library described in [Newsletter
  #157][news157 libsecp].  The change has no effect on the use of BIP340
  in consensus applications as signatures used with both [taproot][topic
  taproot] and [tapscript][topic tapscript] (respectively, BIPs
  [341][bip341] and [342][bip342]) use 32-byte messages.

    The additions describe how to effectively use arbitrary length
    messages, recommends how to use a hashed tag prefix, and provides
    recommendations for increasing safety when using the same key in
    different domains (such as signing transactions or signing
    plain-text messages).

{% include references.md %}
{% include linkers/issues.md v=2 issues="27469,27626,25796,2668,2666,4689,1446" %}
[policy series]: /en/blog/waiting-for-confirmation/
[bitcoin core 25.0]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[1ml stats]: https://1ml.com/statistics
[arc specs]: https://github.com/ark-network/specs
[keceli ark]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021694.html
[keceli reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021720.html
[harding reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021721.html
[harding reply1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021714.html
[stone reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021708.html
[dryja reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021713.html
[jk_14]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021717.html
[jager nostr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021700.html
[jager video]: https://twitter.com/joostjgr/status/1658487013237211155
[news85 stuck funds]: /en/newsletters/2020/02/19/#c-lightning-3500
[btcpay server 97e7e]: https://github.com/btcpayserver/btcpayserver/commit/97e7e60ceae2b73d63054ee38ea54ed265cc5b8e
[news157 libsecp]: /en/newsletters/2021/07/14/#libsecp256k1-844
[bcc rn]: https://bitcoincore.org/en/releases/25.0/
[news252 incentives]: /en/newsletters/2023/05/24/#waiting-for-confirmation-2-incentives
[morcos limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-October/011401.html
