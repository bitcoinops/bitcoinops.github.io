---
title: 'Bitcoin Optech Newsletter #173'
permalink: /en/newsletters/2021/11/03/
name: 2021-11-03-newsletter
slug: 2021-11-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about submitting
transactions directly to miners, links to a set of recommended taproot test
vectors for wallet implementations, and includes our regular sections about
preparing for taproot, new releases and release candidates, and notable changes
to popular Bitcoin infrastructure projects.

## News

- **Submitting transactions directly to miners:** Lisa Neigut started a
  [thread][neigut relay] on the Bitcoin-Dev mailing list about the
  possibility of eliminating the P2P transaction relay network and
  having users submit transactions to miners directly.  Proposed
  benefits of this operating mode included reducing bandwidth
  requirements, improved privacy, and elimination of the complexity in
  [RBF][topic rbf] and [CPFP][topic cpfp] package rules, and better
  communication about next-block feerates.  However, several people
  disagreed:

  - **Bandwidth requirements:** several responses noted that
    [compact block relay][topic compact block relay], used since 2016,
    allows a node that received an unconfirmed transaction to skip
    receiving it again when it's included in a block, with minimal
    bandwidth overhead.  Future proposed improvements such as
    [erlay][topic erlay] will further minimize the bandwidth overhead
    from unconfirmed transaction relay.

  - **Improved privacy:** although submitting transactions only to
    miners hides those transactions from public view prior to
    confirmation, Pieter Wuille [argued][wuille relay] that it also
    gives miners a privileged view of the network.  Public transparency
    seems preferable.

  - **RBF, CPFP, and package complexity:** node operators are indeed
    more sensitive to resource-wasting attacks than miners, but Gloria
    Zhao [noted][zhao relay] that this is mainly a matter of degree.
    The same attacks executed at a larger scale would affect miners, and
    so miners still need the same types of defenses that nodes already
    employ.

  - **Feerate communication:** the current method Bitcoin Core uses for
    estimating feerates is based on receiving unconfirmed transactions and
    then seeing how long it takes them to appear in confirmed blocks.  This
    does lag behind real-time feerate information, but Pieter Wuille
    [suggests][wuille relay] that could be improved by using other
    previously-proposed methods such as having miners broadcast weak
    blocks---blocks that don't quite have enough proof of work to be
    added to the chain.  Weak blocks occur more often than PoW-valid
    blocks and so provide more recent information about what
    transactions miners are currently working on.

  In addition to direct counterpoints, several advantages of the current
  system were noted:

    - **Miner anonymity:** with 50,000 or more nodes currently all
      relaying transactions, it's easy for miners to receive all the
      information they need by quietly operating one of those nodes.
      Pseudonymous developer [[ZmnSCPxj]] [suggested][zmnscpxj relay] that
      forcing miners to maintain a persistent identity, even one on an
      anonymity network like Tor, would make it easier to
      identify miners and coerce them into censoring some transactions.

    - **Censorship resistance:** anyone today can start a node using
      basically any computer to receive relayed transactions, connect
      mining equipment, and begin mining.  Pieter Wuille [notes][wuille
      relay] that wouldn't be the case with direct miner submission.
      New miners would need to advertise their nodes in order to receive
      transactions, but there's no highly accessible way to do that
      which is resistant to both censorship and [sybil attacks][].  In
      particular, Wuille notes "ideas for a mechanism for miners to
      publish their [submission URL] on chain don't help; that [would
      be] dependent on other miners to not censor the publishing."

    - **Centralization resistance:** Wuille also notes that "the cost and
      complexity of an additional submission is independent of [each
      miner's] hashrate, but the benefit is directly proportional [to
      hashrate".  That would make it "far easier for most wallets to
      just submit [transactions] to the largest few pools", encouraging
      centralization.

- **Taproot test vectors:** Pieter Wuille [posted][wuille test] to the
  Bitcoin-Dev mailing list a set of [test vectors][bips #1225] he's
  proposing to add the [BIP341][] specification of [taproot][topic
  taproot].  They focus on "wallet implementations, covering Merkle root
  / tweak / scriptPubKey computation from key/scripts,
  sigmsg/sighash/signature computation for key path spending, and
  control block computation for script path spending."

    The test vectors should be especially useful to developers working
    on implementations which want to be ready to use taproot [shortly
    after activation][p4tr waiting].

## Preparing for taproot #20: what happens at activation?

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/20-activation.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.2][] is a maintenance release for a previous branch
  of Bitcoin Core [containing][bcc0.20.2 rn] minor features and
  bug fixes.

- [C-Lightning 0.10.2rc2][] is a release candidate that [includes][decker
  tweet] a fix for the [uneconomical outputs security issue][news170
  unec bug], a smaller database size, and an improvement in the
  effectiveness of the `pay` command (see the *notable changes* section
  below).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23306][] enables the Address Manager to support multiple ports per IP address.
  Historically, Bitcoin Core has used a fixed port, 8333, and strongly preferred addresses with this
  port when making automatic outbound connections. While it has been suggested that this behavior
  may help prevent utilization of the Bitcoin nodes to DoS non-Bitcoin services (by gossipping their
  addresses on the Bitcoin network), it also makes it easy to detect Bitcoin nodes by observing
  network traffic. Treating each (IP,port) combination as a distinct address allows for future work
  moving towards a more uniform treatment of addresses.

- [C-Lightning #4837][] adds a `--max-dust-htlc-exposure-msat` configuration
  option limiting the total balance of pending HTLCs whose amounts are below the
  dust limit. Please see our [previous coverage][news162 mdhemsat] of a similar
  option in Rust-Lightning for more details.

- [Eclair #1982][] introduces a new log file collecting important notifications
  that require the node operator to take action. The accompanying release notes
  indicate that the `notifications.log` should be monitored by the node
  operator.

- [LND #5803][] allows multiple [spontaneous payments][topic spontaneous
  payments] to the same [Atomic Multipath Payment (AMP)][topic multipath
  payments] invoice without requiring the spending user perform extra
  steps for repeat payments.  The ability to receive multiple payments
  to the same invoice is a feature of AMP that's not possible with
  existing [simplified multipath payment][topic multipath payments]
  implementations.

- [BTCPay Server #2897][] adds support for [LNURL-Pay][] as a payment
  method, also enabling support for [Lightning Addresses][news167 lightning addresses].

{% include references.md %}
{% include linkers/issues.md issues="23306,4837,1982,5803,2897,1225" %}
[c-lightning 0.10.2rc2]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2rc2
[neigut relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019572.html
[wuille relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019578.html
[zhao relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019579.html
[zmnscpxj relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019573.html
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[news170 unec bug]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[bitcoin core 0.20.2]: https://bitcoincore.org/bin/bitcoin-core-0.20.2/
[bcc0.20.2 rn]: https://bitcoincore.org/en/releases/0.20.2/
[wuille test]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019587.html
[p4tr waiting]: /en/preparing-for-taproot/#why-are-we-waiting
[LNURL-Pay]: https://github.com/fiatjaf/lnurl-rfc/blob/luds/06.md
[news167 lightning addresses]: /en/newsletters/2021/09/22/#lightning-address-identifiers-announced
[news162 mdhemsat]: /en/newsletters/2021/08/18/#rust-lightning-1009
