---
title: 'Bitcoin Optech Newsletter #265'
permalink: /en/newsletters/2023/08/23/
name: 2023-08-23-newsletter
slug: 2023-08-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes fraud proofs for outdated backup state
and includes our regular sections summarizing recent changes to services
and client software, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Fraud proofs for outdated backup state:** Thomas Voegtlin
  [posted][voegtlin backups] to the Lightning-Dev mailing list an idea
  for a service that could be penalized if it provided a user with any
  version of the user's backup state besides the most recent version.
  The basic mechanism is simple:

    - Alice has some data she wants to back up.  She includes a version
      number in the data, creates a signature for the data, and gives
      Bob both the data and her signature.

    - Immediately after receiving Alice's data, Bob sends her a
      signature that commits to both the version number of her data and
      the current time.

    - Later, Alice updates the data, increments the version number, and
      provides Bob with the updated data and her signature for it.  Bob
      returns a signature for a commitment to the new (higher) version
      number with the new (higher) current time.  They repeat this step
      many times.

    - Eventually, Alice requests her data in order to test Bob.  Bob
      sends her a version of the data and her signature for the data,
      allowing her to prove it actually is her data.  He also sends her
      another signature that commits to the version number in the data
      and the current time.

    - If Bob was dishonest and sent Alice old data with an old
      version number, Alice can generate a _fraud proof_: she can
      show that Bob previously signed a higher version number with
      an earlier time than the signature commitment he just provided
      her.

  As described so far, there's nothing Bitcoin-specific to this
  mechanism for generating latest-state fraud proofs.  However, Voegtlin
  noted that, if the [OP_CHECKSIGFROMSTACK (CSFS) and OP_CAT][topic
  op_checksigfromstack] opcodes were added to Bitcoin in a soft fork, it
  would be possible to use the fraud proof onchain.

  For example, Alice and Bob share an LN channel which includes an
  additional [taproot][topic taproot] condition that allows Alice to
  spend all of the channel funds if she can provide this type of fraud
  proof.  The normal operation of the channel would include just one
  extra step: after each update to the channel, Alice gives Bob a
  signature over the current state (which includes a state number).
  Then, each time Alice organically reconnects to Bob, she requests the
  latest backup and uses the mechanism above to verify its integrity.
  If Bob ever provides an outdated backup, Alice uses the fraud proof
  and the CSFS spend condition to spend the entire channel balance.

  This mechanism makes it safer for Alice to use a state provided by Bob
  as the latest channel state in cases where Alice actually has lost
  data.  In the current LN channel design (LN-Penalty), if Bob tricks
  Alice into using an old state, Bob will be able to steal her entire
  balance in that channel.  Even with proposed upgrades like
  [LN-Symmetry][topic eltoo], Alice using an old state might allow Bob to steal funds
  from her.  Making it possible to financially penalize Bob for
  misrepresenting the latest state likely decreases the chance he'll lie
  to Alice.

  The proposal received a significant amount of discussion:

  <!-- I've previously confirmed that "ghost43" (all lowercase) is how
  they'd like to be attributed -->

  - Peter Todd [noted][todd backups1] that the base mechanism is
    generic. It's not specific to LN and may be useful in a variety of
    protocols.  He [also notes][todd backups2] that a simpler mechanism
    is for Alice to just download the latest state from Bob each time she
    organically reconnects to him with no fraud proofs involved.  If he
    provides her with an old state, she closes the channel with him,
    denying him any further forwarding fees he would earn from her
    future payments.  This sounds very similar to the version of [peer
    storage][topic peer storage] described in [BOLTs #881][], the
    version experimentally implemented in Core Lightning earlier this
    year (see [Newsletter #238][news238 peer storage]), and (according
    to a [message][teinturier backups] from Bastien Teinturier) a version
    of the scheme implemented in the Phoenix wallet for LN.

  - A [reply][ghost43 backups] by ghost43 explained that fraud proofs
    leading to financial penalties is a powerful tool for a client
    storing data with anonymous peers.  A large popular service might
    care about its reputation enough to avoid lying to its clients, but
    anonymous peers don't have any reputation to lose.  Also suggested
    by ghost43 was a modification of the protocol to make it symmetric,
    so in addition to Alice storing her state with Bob (and Bob being
    penalized for lying), Bob could store his state with Alice and she
    could be penalized for lying.

      Voegtlin extended this idea to [warn][voegtlin backups2] that the
      providers of wallet software have a significant need for a good
      reputation and that they lose reputation when their users lose
      funds---even if the software functioned as best as possible.  As
      the developer of wallet software, it is thus very important to him
      to minimize the risk of an anonymous peer being able to steal from
      an Electrum user who uses a mechanism like peer backups.

  There was no clear resolution to the discussion.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test release candidates.*

- [Core Lightning 23.08rc3][] is a release candidate for the next major
  version of this popular LN node implementation.

- [HWI 2.3.1][] is a minor release of this toolkit for working with
  hardware signing devices.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27981][] fixes a bug that could have potentially caused
  two nodes to be unable to receive data from each other.  If Alice's
  node had a lot of data queued to send to Bob's node, she would try to send
  that data before accepting new data from Bob.  If Bob also had a lot
  of data queued to send to Alice's node, he also wouldn't accept new data
  from Alice.  This could lead to neither of them attempting to receive
  data from the other indefinitely.  The issue was originally discovered
  in the [Elements Project][].

- [BOLTs #919][] updates the LN specification to suggest that nodes stop
  accepting additional trimmed HTLCs beyond a certain value.  A trimmed
  HTLC is a forwardable payment that is not added as an output to the
  channel commitment transaction.  Instead, an amount equal to the value
  of the trimmed HTLC is allocated to transaction fees.  This makes it
  possible to use LN to forward payments that would be
  [uneconomical][topic uneconomical outputs] onchain.  However, if the
  channel needs to be closed while trimmed HTLCs are pending, a node has
  no way of reclaiming those funds, so it makes sense to limit the
  node's exposure to that type of loss.  See also our descriptions of
  various implementations adding this limit: LDK in [Newsletter
  #162][news162 trim], Eclair in [Newsletter #171][news171 trim], and
  Core Lightning in [Newsletter #173][news173 trim], plus
  [Newsletter #170][news170 trim] for a related security concern.

- [Rust Bitcoin #1990][] optionally allows `bitcoin_hashes` to be
  compiled with slower implementations of SHA256, SHA512, and RIPEMD160
  that are also about half the size, likely making them better for
  applications on embedded devices that don't need to perform frequent
  hashing.

- [Rust Bitcoin #1962][] adds the ability to use hardware-optimized
  SHA256 operations on compatible x86 architectures.

- [BIPs #1485][] makes several updates to the [BIP300][] specification
  of [drivechains][topic sidechains].  The main change appears to be a
  redefinition of `OP_NOP5` in certain contexts to `OP_DRIVECHAIN`.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,27981,919,1990,1962,1485,881" %}
[core lightning 23.08rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc3
[news238 peer storage]: /en/newsletters/2023/02/15/#core-lightning-5361
[news162 trim]: /en/newsletters/2021/08/18/#rust-lightning-1009
[news171 trim]: /en/newsletters/2021/10/20/#eclair-1985
[news173 trim]: /en/newsletters/2021/11/03/#c-lightning-4837
[news170 trim]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[elements project]: https://elementsproject.org/
[voegtlin backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004043.html
[todd backups1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004046.html
[todd backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004044.html
[teinturier backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004045.html
[ghost43 backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004052.html
[voegtlin backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004055.html
[hwi 2.3.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.1
