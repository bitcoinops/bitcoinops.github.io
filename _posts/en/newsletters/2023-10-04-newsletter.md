---
title: 'Bitcoin Optech Newsletter #271'
permalink: /en/newsletters/2023/10/04/
name: 2023-10-04-newsletter
slug: 2023-10-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal for remotely controlling LN
nodes using a hardware signing device, describes privacy-focused
research and code for allowing LN forwarding nodes to dynamically split
LN payments, and looks at a proposal for improving LN liquidity by
allowing groups of forwarding nodes to pool funds separately from their
normal channels.  Also included are our regular sections announcing new
releases and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Secure remote control of LN nodes:** Bastien Teinturier
  [posted][teinturier remote post] to the Lightning-Dev mailing list
  about a [proposed BLIP][blips #28] that would specify how a user could
  send signed commands to their LN node from a hardware signing device
  (or any other wallet).  The signing device would only need to
  implement the BLIP plus [BOLT8][] peer communication and the LN node
  would only need to implement the BLIP.  This is similar to Core
  Lightning's _commando_ plugin (see [Newsletter #210][news210
  commando]), which allows almost complete remote control of an LN node,
  but Teinturier envisions his feature as primarily being for control of
  the most sensitive node actions, such as authorizing a payment---the
  type of actions where a user would reasonably be willing to go through
  the hassle of connecting and unlocking a hardware security device and
  then authorizing the action.  This would make it easier for an end
  user to secure their LN balance with the same hardware signing device
  security as their onchain balance. {% assign timestamp="1:48" %}

- **Payment splitting and switching:** Gijs van Dam [posted][van dam pss
  post] to the Lightning-Dev mailing list about a [plugin][pss plugin] he's
  written for Core Lightning and some [research][pss research] he's
  performed related to it.  The plugin allows forwarding nodes to tell
  their peers that they support _payment splitting and switching_ (PSS).
  If Alice and Bob share a channel and both of them support PSS, then when
  Alice receives a payment to be forwarded to Bob, the plugin may split
  that into two or more [payment parts][topic multipath payments].  One
  of those payments may be forwarded to Bob like normal, but the others
  may follow alternative paths (e.g., from Alice to Carol to Bob).  Bob
  waits to receive all parts and then continues forwarding the payment
  like normal to the next hop.

  The main advantage of this approach is that makes it harder to
  execute _balance discovery attacks_ (BDAs) where a third party
  repeatedly [probes][topic payment probes] a channel to track its
  balance.  If done frequently, a BDA can track the amount of a
  payment passing through a channel.  If done on many channels, it may
  be able to track that payment as it crosses the network.  When PSS
  is used, the attacker would need to track not just the balance of
  the Alice-and-Bob channel, but also the Alice-and-Carol and
  Carol-and-Bob channels in order to track the payment.  Even if the
  attacker did track the balance of all of those channels, the
  computational difficulty of tracking the payment increases, as does
  the chance that parts of other users' payments that simultaneously
  pass through those channels could be conflated with parts of the
  original payment being tracked.  A [paper][pss research] by van Dam
  showed a 62% reduction in the amount of information an attacker was
  able to gain when PSS is deployed.

  Two additional benefits are mentioned in van Dam's paper about PSS:
  increased LN throughput and as part of a mitigation against
  [channel jamming attacks][topic channel jamming attacks]. The idea
  of PSS had received a small amount of discussion on the mailing list
  as of this writing. {% assign timestamp="12:23" %}

- **Pooled liquidity for LN:** ZmnSCPxj [posted][zmnscpxj sidepools1] to
  the Lightning-Dev mailing list a suggestion for what he calls
  _sidepools_.  This would involve groups of forwarding nodes working
  together to deposit funds in a multiparty state contract---an offchain
  contract (that is anchored onchain similar to an LN channel) that
  would allow funds to be moved between the participants by updating the
  offchain contract state.  For example, an initial state that gives
  Alice, Bob, and Carol each 1 BTC could be updated to a new state that
  gives Alice 2 BTC, Bob 0 BTC, and Carol 1 BTC.

  The forwarding nodes would also continue to use and advertise
  ordinary LN channels between pairs of nodes; for example, the three
  users described previously could have three separate channels: Alice
  and Bob, Bob and Carol, and Alice and Carol.  They would forward
  payments across these channels exactly the same as they can today.

  If one or more of the ordinary channels became imbalanced---for
  example too much of the funds in the channel between Alice and Bob
  now belongs to Alice---the imbalance could be resolved by performing
  an offchain [peerswap][] in the state contract.  E.g., Carol could
  provide some funds to Alice in the state contract contingent on
  Alice forwarding the same amount of funds through Bob to Carol in
  the ordinary LN channel---restoring balance to the LN channel
  between Alice and Bob.

  One advantage of this approach is that nobody needs to know about the
  state contract except the participants in each particular contract.
  To all ordinary LN users, and all forwarding nodes not involved in a
  particular contract, LN continues to operate using the current
  protocol.  Another advantage, compared to existing channel
  rebalancing operations, is that the state contract approach allows a
  large number of forwarding nodes to maintain a direct peer
  relationship for a small amount of onchain space, likely eliminating
  any offchain rebalancing fees between those peers.  Keeping
  rebalancing fees minimal makes it much easier for forwarding nodes
  to keep their channels balanced, which improves their revenue
  potential and makes sending payments across LN more reliable.

  A downside to the approach is that it requires a multiparty state
  contract, which is something that has never been implemented in
  production before (to the best of our knowledge).  ZmnSCPxj mentions
  two contract protocols that might be useful to use as a basis,
  [LN-Symmetry][topic eltoo] and [duplex payment channels][].
  LN-Symmetry would require a consensus change, which seems unlikely
  to happen in the near future, so a [follow-up post][zmnscpxj
  sidepools2] by ZmnSCPxj appears to be focusing on duplex payment
  channels (which ZmnSCPxj calls "Decker--Wattenhofer" after the
  researchers who first proposed them).  A downside of duplex payment
  channels is that they can't be kept open indefinitely, although
  ZmnSCPxj's analysis indicates they can probably be kept open for
  long enough, and through enough state changes, to amortize their
  cost effectively.

  There were no public replies to the posts at the time of writing,
  although we learned from private correspondence with ZmnSCPxj that
  he is working on further developing the idea. {% assign timestamp="34:31" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.17.0-beta][] is the release for the next major version of this
  popular LN node implementation.  A major new experimental feature
  included in this release is support for "simple [taproot][topic
  taproot] channels", which allows using [unannounced channels][topic
  unannounced channels] funded onchain using a P2TR output.  This is the
  first step towards adding other features to LND's channels, such as
  support for [Taproot Assets][topic client-side validation] and
  [PTLCs][topic ptlc].  The release also includes a significant
  performance improvement for users of the Neutrino backend, which
  supports [compact block filters][topic compact block filters], as well
  as improvements to LND's built-in [watchtower][topic watchtowers]
  functionality.  For more information, please see the [release
  notes][lnd rn] and [release blog post][lnd 17 blog]. {% assign timestamp="55:26" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Eclair #2756][] introduces monitoring for [splicing][topic splicing] operations. The metrics
  collect the initiator of the operation and distinguish three types of splices:
  splice-in, splice-out, and splice-cpfp. {% assign timestamp="58:26" %}

- [LDK #2486][] adds support for funding multiple channels in a single
  transaction, ensuring atomicity with either all of the batched channels being funded
  and opened or all of them closed. {% assign timestamp="1:01:33" %}

- [LDK #2609][] allows requesting the [descriptors][topic descriptors]
  used for receiving payments in past transactions.  Previously, users
  had to store these themselves; with the updated API, the descriptors
  can be reconstructed from other stored data. {% assign timestamp="1:02:34" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="2756,2486,2609,28" %}
[LND v0.17.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta
[teinturier remote post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004084.html
[news210 commando]: /en/newsletters/2022/07/27/#core-lightning-5370
[van dam pss post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004114.html
[pss plugin]: https://github.com/gijswijs/plugins/tree/master/pss
[pss research]: https://eprint.iacr.org/2023/1360
[zmnscpxj sidepools1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004099.html
[peerswap]: https://github.com/ElementsProject/peerswap
[duplex payment channels]: https://www.tik.ee.ethz.ch/file/716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[zmnscpxj sidepools2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004108.html
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.17.0.md
[lnd 17 blog]: https://lightning.engineering/posts/2023-10-03-lnd-0.17-launch/
