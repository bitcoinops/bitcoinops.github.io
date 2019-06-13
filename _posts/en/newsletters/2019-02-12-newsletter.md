---
title: 'Bitcoin Optech Newsletter #33'
permalink: /en/newsletters/2019/02/12/
name: 2019-02-12-newsletter
slug: 2019-02-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the newest version of LND, briefly
describes a tool for generating bitcoin ownership proofs, and links to an
Optech study about the usability of Replace-by-Fee.  Also included are
summaries of notable code changes to popular Bitcoin infrastructure
projects.

## Action items

- **Upgrade to LND 0.5.2:** this minor-version [release][lnd release]
  fixes bugs related to stability and improves compatibility with other
  LN software.

## News

- **Tool released for generating and verifying bitcoin ownership
  proofs:** Blockstream has [released][reserve audit tool] a tool that
  helps bitcoin custodians, such as exchanges, prove that they control a
  certain number of bitcoins without creating an onchain transaction.
  The tool works by creating an almost-valid transaction that contains
  all of the same information a valid transaction would
  contain---proving that the transaction creator had access to all of
  the information necessary to create a spend (e.g. the private keys).
  The tool is written in the Rust programming language and uses the
  increasingly popular BIP174 Partially Signed Bitcoin Transaction
  (PSBT) format for interoperability with Bitcoin Core and other Bitcoin
  tools.  Future plans for the tool include privacy enhancements.

- **RBF usability study published:** with only about 6% of the
  transactions confirmed in 2018 signaling support for [BIP125][] opt-in
  Replace-by-Fee (RBF), Optech contributor Mike Schmidt undertook [an
  examination][rbf report] of almost two dozen popular Bitcoin wallets,
  block explorers, and other services to see how they handled either
  sending or receiving RBF transactions (including fee bumps).  His
  report provides visual examples, both good and bad, of how many systems handle RBF
  transactions.  The examples of problems are not made to criticize the pioneering developers of
  those systems, but to help all Bitcoin developers learn how to master
  the powerful fee-management capability that RBF provides.
  Based on the examples collected, the report
  concludes with a summary of recommendations for developers.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], and [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14897][] introduces a semi-random order biased towards
  outbound connections when requesting transactions, making it harder
  for attackers to abuse one of Bitcoin Core's bandwidth-reduction
  measures.  Previously, when your node received an announcement of a
  new transaction from one of its peers, it requested that transaction
  from that peer.  While it waited for the transaction to be sent, it
  might have received announcements of the same transaction from its
  other peers.  If the first peer hadn't sent the transaction within two
  minutes, your node would then request the transaction from the second
  peer who announced it, again waiting two minutes before requesting it
  from the next peer.  This allowed an attacker who opens a large number
  of connections to your node to potentially delay your receipt of a
  transaction by a large number of two-minute intervals.

    If such an attack was performed across the whole network, it might
    be able to prevent certain transactions from reaching miners,
    possibly breaking the security of protocols that rely on timely
    confirmation (e.g. LN payment channels).  A network-wide attack
    could also make it [easier][coinscope] to [map][txprobe] the network
    and redirect transaction traffic in order to learn which IP address
    originated a transaction.

    With this PR, your node will only immediately request the
    transaction from the first peer that announced it if your node
    initially chose to open a connection to that peer (i.e. an outbound
    peer).  If you first heard about the transaction from a peer that
    connected to you (an inbound peer), you'll wait two seconds before
    requesting the transaction to give an outbound peer a chance to tell
    you about it first.  If the first peer you request the transaction
    from has not sent it to you within a minute, you'll request it from
    another randomly-selected peer.  If that also doesn't work, you'll
    continue to randomly select peers to request the transaction from.
    This doesn't eliminate the problem, but it does mean that
    an attacker who wants to delay a transaction probably needs to
    operate a much larger number of nodes to achieve the same delay.
    It's possible that a set reconciliation technique based on something
    like [libminisketch][] could provide a complete solution for any
    node with at least one honest peer.

- [Bitcoin Core #14491][] allows the `importmulti` RPC to import keys
  specified using an [output script descriptor][output script
  descriptors].  Keys imported this way will be converted to the current
  wallet datastructure, but the eventual plan is for Bitcoin Core's
  wallet to use descriptors internally.

- [Bitcoin Core #14667][] adds a new `deriveaddress` RPC that takes a
  descriptor containing a key path plus an extended public key and
  returns the corresponding address.

- [Bitcoin Core #15226][] adds a `blank` parameter to the `createwallet`
  RPC that allows creating a wallet without an HD seed or any private
  keys.  The wallet can then have private or public key material added
  to it (e.g. an HD seed using `sethdseed` or a watching-only address
  using `importaddress`).  The wallet can also be encrypted while still
  blank using the `encryptwallet` RPC.  The term "blank" is used to
  distinguish a wallet without keys from an "empty" wallet whose keys
  don't control any bitcoins.

- [LND #2457][] adds a `cancelinvoice` RPC to cancel an invoice that
  hasn't been settled yet.  If a payment for a canceled invoice arrives
  at your node, it'll return the same error it would've used if that
  invoice never existed, preventing the payment from succeeding and
  returning all money to the spender.

- [LND #2572][] adds an `outgoing_chan_id` parameter to the `sendpayment`
  command.  You can use this parameter to specify which of your channels
  should be used for the first hop of the payment.

- [Eclair #736][] adds support for both connecting to Tor hidden
  services (.onion) and operating as a hidden service.
  [Documentation][eclair tor] is provided for users.

{% include references.md %}
{% include linkers/issues.md issues="736,2572,2457,15226,14491,14667,14897" %}
[lnd release]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.2-beta
[coinscope]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[txprobe]: https://arxiv.org/pdf/1812.00942.pdf
[reserve audit tool]: https://blockstream.com/2019/02/04/standardizing-bitcoin-proof-of-reserves/
[eclair tor]: https://github.com/ACINQ/eclair/blob/master/TOR.md
[rbf report]: /en/rbf-in-the-wild/
