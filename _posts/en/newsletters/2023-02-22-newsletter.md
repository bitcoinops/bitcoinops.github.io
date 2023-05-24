---
title: 'Bitcoin Optech Newsletter #239'
permalink: /en/newsletters/2023/02/22/
name: 2023-02-22-newsletter
slug: 2023-02-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a draft BIP for the proposed `OP_VAULT`
opcode, summarizes a discussion about allowing LN nodes to set a
quality-of-service flag on their channels, relays a request for feedback
on LN neighbor-node evaluation criteria, and describes a draft BIP for a
seed backup and recovery scheme that can be reliably performed without
electronics.  Also included are our regular sections with summaries of
popular questions and answers from the Bitcoin StackExchange,
announcements of new releases and release candidates, and descriptions
of notable changes to popular Bitcoin infrastructure software.

## News

- **Draft BIP for OP_VAULT:** James O'Beirne [posted][obeirne op_vault] to the
  Bitcoin-Dev mailing list a link to a [draft BIP][bip op_vault] for the
  `OP_VAULT` opcode he previously proposed (see [Newsletter
  #234][news234 vault]).  He also announced that he'll be attempting to
  get the code merged into Bitcoin Inquisition, a project for testing
  major proposed changes to Bitcoin's consensus and network protocol
  rules. {% assign timestamp="1:18" %}

- **LN quality of service flag:** Joost Jager [posted][jager qos] to the
  Lightning-Dev mailing list a proposal to allow nodes to signal that a
  channel is "highly available", indicating that its operator believes
  it'll be able to forward payments without failure.  If it does fail to
  forward a payment, the spender may choose not to use that node for
  future payments for a very long time---a much longer duration than the
  spender may use for nodes that did not advertise high availability.
  Spenders maximizing payment speed (rather than low fees) would
  preferentially choose payment paths consisting of self-identified
  highly available nodes.

    Christian Decker [replied][decker qos] with an excellent summary of
    problems in reputation systems, including cases of self-proclaimed
    reputation.  One of his concerns was that typical spenders won't
    send anywhere near enough payments to frequently encounter the same
    nodes in a large network of payment channels.  If repeat business is
    rare anyway, then the threat of temporarily not providing repeat
    business may not be effective.

    Antoine Riard [reminded][riard boomerang] participants about an
    alternative approach to speeding up payments---overpayment with
    recovery.  Previously described as boomerang payments (see
    [Newsletter #86][news86 boomerang]) and refundable overpayments (see
    [Newsletter #192][news192 pp]), a spender would take their
    payment amount plus some extra money, split it into several
    [parts][topic multipath payments], and send the parts by a variety
    of routes.  When a sufficient number of parts has arrived to pay the
    invoice, the receiver claims just those parts and rejects any
    additional parts (with additional funds) that arrive later.  This
    requires spenders wanting fast payments to have some additional funds
    in their channel but it works even if some of the paths selected by the
    spender fail.  This reduces the need for spenders to be able to
    easily find highly available channels.  The challenge of this
    approach is building a mechanism that prevents receivers from
    keeping any overpayment that arrives. {% assign timestamp="4:15" %}

- **Feedback requested on LN good neighbor scoring:** [[Carla Kirk-Cohen]]
  and [[Clara Shikhelman]] [posted][ckc-cs reputation] to the Lightning-Dev
  mailing list to request feedback on the recommend parameters for how a
  node should judge whether its channel counterparties are a good source of
  forwarded payments.  They suggest several criteria to judge by and
  recommended default parameters for each criterion, but are seeking
  feedback about the choices made.

    If a node determines that one of its peers is a good neighbor and
    that neighbor tags a forwarded payment as being endorsed by it, the
    node can give that payment access to more of its resources than it
    gives unqualified payments.  The node may also endorse the payment when
    forwarding it to the next channel.  As described in a prior paper
    co-authored by Shikhelman (see
    [Newsletter #226][news226 jam]), this is part of a proposal to
    mitigate [channel jamming attacks][topic channel jamming attacks]. {% assign timestamp="13:58" %}

- **Proposed BIP for Codex32 seed encoding scheme:** Russell O'Connor
  and Andrew Poelstra (using anagrams of their names) [proposed][op codex32] a BIP for
  a new scheme backing up and restoring [BIP32][] seeds.  Similar to
  [SLIP39][], it optionally allows creating several shares using
  [Shamir's Secret Sharing Scheme][] (SSSS), requiring that a configurable
  number of the shares to be used together to recover the seed.  An
  attacker who obtains less than the threshold number of shares will
  learn nothing about the seed.  Unlike BIP39, Electrum, Aezeed, and
  SLIP39 recovery codes that use a wordlist, Codex32 instead uses the
  same alphabet as [bech32][topic bech32] addresses.  An example share
  from the draft BIP:

    ```text
    ms12namea320zyxwvutsrqpnmlkjhgfedcaxrpp870hkkqrm
    ```

    The main advantage of Codex32 over all existing schemes is that all
    operations can be performed using just pen, paper, instructions, and
    paper cutouts.  That includes generating an encoded seed (dice can
    be used here), protecting the seed with a checksum, generating
    checksummed shares, verifying checksums, and recovering the seed.
    We found the idea of being able to manually verify checksums on
    backups of seeds or shares to be an especially powerful concept.
    The only current method users have to verify an individual seed
    backup is to enter it into a trusted computing device and see if it
    derives the expected public keys---but determining whether a device
    should be trusted is often not a trivial procedure.  Worse, in order
    to verify the integrity of existing SSSS shares (e.g. in SLIP39),
    the user must bring together each share they want to verify with enough
    other shares to reach the threshold and then enter them into a trusted
    computing device.  That means verifying share integrity negates a
    large benefit of having shares in the first place---the ability to
    keep information safe and secure by distributing it across multiple
    places or people.  With Codex32, users can verify the integrity of
    each share individually on a regular basis using just paper, pen,
    some printed materials, and a few minutes of time.

    Discussion on the mailing list mainly focused on the differences
    between Codex32 and SLIP39, which has been used in production for a
    couple of years now.  We recommend anyone interested in Codex32
    investigate its [website][codex32 website] or watch a
    [video][codex32 video] by one of its authors.  With the draft BIP,
    the authors hope to see wallets begin to add support for using
    Codex32-encoded seeds. {% assign timestamp="20:27" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why is witness data downloaded during IBD in prune mode?]({{bse}}117057)
  Pieter Wuille notes that for nodes running in [prune mode], "the witness data
  that is both (a) before the assumevalid point and (b) sufficiently buried to
  be past the prune point, there is indeed little to gain from having it". There
  is currently a [draft PR][Bitcoin Core #27050] open to address this and [a PR
  Review Club][pr review 27050] covering the proposed change. {% assign timestamp="36:40" %}

- [Can Bitcoin's P2P network relay compressed data?]({{bse}}116999)
  Pieter Wuille links to two mailing list discussions about compression (one about
  [specialized compression for headers sync][] and one about [general LZO-based
  compression][]) and points out that Blockstream Satellite uses a custom
  transaction compression scheme. {% assign timestamp="40:39" %}

- [How does one become a DNS seed for Bitcoin Core?]({{bse}}116931)
  User Paro explains the requirements for someone wanting to become a [DNS
  seed][news66 dns seed] to provide new nodes with initial peers. {% assign timestamp="41:18" %}

- [Where can I learn about open research topics in Bitcoin?]({{bse}}116898)
  Michael Folkson provides a variety of resources including [Chaincode Labs
  Research][] and [Bitcoin Problems][], among others. {% assign timestamp="44:00" %}

- [What is the maximum size transaction that will be relayed by bitcoin nodes using the default configuration?]({{bse}}117277)
  Pieter Wuille points out Bitcoin Core's 400,000 [weight unit][] standardness
  policy rule, notes that it is not currently configurable, and explains the
  intended benefits of that limit including DoS protections. {% assign timestamp="47:55" %}

- [Understanding how ordinals work with in Bitcoin. What is exactly stored on the blockchain?]({{bse}}117018)
  Vojtěch Strnad clarifies that Ordinals Inscriptions do not use `OP_RETURN`,
  but instead embed data into an unexecuted script branch using the
  `OP_PUSHDATAx` opcodes similar to:

    ```
    OP_0
    OP_IF
    <data pushes>
    OP_ENDIF
    ```
    {% assign timestamp="50:07" %}

- [Why doesn't the protocol allow unconfirmed transactions to expire at a given height?]({{bse}}116926)
  Larry Ruane references Satoshi on why it wouldn't be prudent for
  transactions to have the seemingly useful ability to specify an
  expiration height, that is, a height after which the transaction,
  if not yet mined, is no longer valid (and therefore can't be mined). {% assign timestamp="51:00" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.27.1][] is a security update to fix a vulnerability that
  "sometimes [...] allows an array-bounds overflow when large string
  were input into SQLite's printf function".  Only software using BDK's
  optional SQLite's database feature needs to be updated.  See the
  [vulnerability report][RUSTSEC-2022-0090] for additional details. {% assign timestamp="52:44" %}

- [Core Lightning 23.02rc3][] is a release candidate for a new
  maintenance version of this popular LN implementation. {% assign timestamp="53:16" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24149][] adds signing support for P2WSH-based
  [miniscript][topic miniscript]-based [output descriptors][topic
  descriptors]. Bitcoin Core will be able to sign any miniscript
  descriptor input if all the necessary preimages and keys are
  available and timelocks are satisfied. Some features are still
  missing for full Miniscript support in the Bitcoin Core wallet: the
  wallet cannot yet estimate the input weight for some descriptors
  before signing and cannot yet sign [PSBTs][topic PSBT] in some
  edge-cases. Miniscript support for P2TR outputs is also still
  pending. assign timestamp="53:57"

- [Bitcoin Core #25344][] updates the `bumpfee` and `psbtbumpfee` RPCs
  for creating [Replace By Fee][topic rbf] (RBF) fee bumps.  The update
  allows specifying outputs for the replacement tranaction.  The
  replacement may contain a
  different set of outputs than the transaction being replaced.  This
  can be used to add new outputs (e.g. for iterative [payment
  batching][topic payment batching]) or to remove outputs (e.g. for
  attempting to cancel an unconfirmed payment). {% assign timestamp="56:10" %}

- [Eclair #2596][] limits the number of times a peer attempting to open
  a [dual funded][topic dual funding] channel can [RBF][topic rbf] fee
  bump the channel open transaction before the node won't accept any
  further attempted updates.  This is motivated by the node needing to
  store data about all possible versions of the channel open
  transaction, so allowing unlimited fee bumps could be a problem.
  Normally, the number of fee bumps that can be created is bounded in
  practice by the need for each replacement to pay additional transaction
  fees.  However, the dual funding protocol expects a node to store
  even those fee bumps it can't fully validate, meaning an attacker
  could create an unlimited number of invalid fee bump transactions that
  will never confirm and never cost it any transaction fees. {% assign timestamp="58:09" %}

- [Eclair #2595][] continues the project's work on adding support for
  [splicing][topic splicing], in this case with updates to the functions
  used for constructing transactions. {% assign timestamp="59:31" %}

- [Eclair #2479][] adds support for paying [offers][topic offers] in the following flow: a
  user receives an offer, tells Eclair to pay it, Eclair uses the offer
  to fetch an invoice from the receiver, verifies the invoice contains
  the expected parameters, and pays the invoice. {% assign timestamp="59:45" %}

- [LND #5988][] adds a new optional probability estimator for finding
  payment paths.  It is partly based on previous pathfinding research
  (see [Newsletter #192][news192 pp]) with additional input from other
  approaches. {% assign timestamp="1:00:09" %}

- [Rust Bitcoin #1636][] adds a `predict_weight()` function.  Input to
  the function is a template for the transaction to construct; output is the expected
  weight of the transaction.  This is especially useful for fee
  management: to determine which inputs need to be added to a
  transaction, the fee amount needs to be known, but to determine
  the fee amount, the size of the transaction needs to be known.
  The function can provide a reasonable size estimate without actually
  having to construct a candidate transaction. {% assign timestamp="1:00:42" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="24149,25344,2596,2595,2479,5988,1636,27050" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news92 overpayments]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[codex32 website]: https://secretcodex32.com/
[codex32 video]: https://www.youtube.com/watch?v=kf48oPoiHX0
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021465.html
[bip op_vault]: https://github.com/jamesob/bips/blob/jamesob-23-02-opvault/bip-vaults.mediawiki
[news234 vault]: /en/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes
[jager qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003842.html
[decker qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003844.html
[riard boomerang]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003852.html
[ckc-cs reputation]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003857.html
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[shamir's secret sharing scheme]: https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing
[op codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021469.html
[RUSTSEC-2022-0090]: https://rustsec.org/advisories/RUSTSEC-2022-0090
[bdk 0.27.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.1
[prune mode]: https://bitcoin.org/en/full-node#reduce-storage
[pr review 27050]: https://bitcoincore.reviews/27050
[specialized compression for headers sync]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015851.html
[general LZO-based compression]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-November/011837.html
[news66 dns seed]: /en/newsletters/2019/10/02/#bitcoin-core-15558
[Chaincode Labs Research]: https://research.chaincode.com/research-intro/
[Bitcoin Problems]: https://bitcoinproblems.org/
[weight unit]: https://en.bitcoin.it/wiki/Weight_units
