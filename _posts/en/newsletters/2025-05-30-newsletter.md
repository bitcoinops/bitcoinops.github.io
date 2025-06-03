---
title: 'Bitcoin Optech Newsletter #356'
permalink: /en/newsletters/2025/05/30/
name: 2025-05-30-newsletter
slug: 2025-05-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about the possible
effects of attributable failures on LN privacy.  Also included are our
regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new releases and release candidates,
and descriptions of recent changes to popular Bitcoin infrastructure
software.

## News

- **Do attributable failures reduce LN privacy?** Carla Kirk-Cohen
  [posted][kirkcohen af] to Delving Bitcoin an analysis of the possible
  consequences for the privacy of LN spenders and receivers if the
  network adopts [attributable failures][topic attributable failures],
  particularly telling the spender the amount of time it took to forward
  a payment at each hop.  Citing several papers, she describes two types
  of deanonymization attacks:

  - An attacker operating one or more forwarding nodes uses timing
    data to determine the number of hops used by a payment ([HTLC][topic
    htlc]), which can be combined with knowledge of the topography of
    the public network to narrow the set of nodes that might have been
    the receiver.

  - An attacker uses an IP network traffic forwarder
    ([autonomous system][]) to passively monitor traffic and combines
    that with knowledge of the IP network latency between nodes (i.e.,
    their ping times) plus knowledge of the topography (and other
    characteristics) of the public Lightning Network.

  She then describes possible solutions, including:

  - Encouraging receivers to delay acceptance of an HTLC by a small
    random amount to prevent timing attacks that attempt to identify the
    receiver's node.

  - Encouraging spenders to delay resending failed payments (or
    [MPP][topic multipath payments] parts) by a small random amount and
    by using alternative paths to prevent timing and failure attacks
    attempting to identify the spender's node.

  - Increased payment splitting with MPP to make it harder to guess the
    amount being spent.

  - Allowing spenders to opt-in to having their payments forwarded less
    quickly, as previously proposed (see [Newsletter #208][news208
    slowln]).  This could be combined with HTLC batching, which is
    already implemented in LND (although the addition of a randomized
    delay could enhance privacy).

  - Reducing the precision of attributable failure timestamps to avoid
    penalizing forwarding nodes that add small random delays.

  Discussion from multiple participants evaluated the concerns and
  proposed solutions in more detail, as well as considering other
  possible attacks and mitigations. {% assign timestamp="0:57" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Which transactions get into blockreconstructionextratxn?]({{bse}}116519)
  Glozow explains how the extrapool data structure (see [Newsletter #339][news339
  extrapool]) caches rejected and replaced transactions seen by the node
  and lists the criteria for exclusion and eviction. {% assign timestamp="40:40" %}

- [Why would anyone use OP_RETURN over inscriptions, aside from fees?]({{bse}}126208)
  Sjors Provoost notes that in addition to sometimes being cheaper, `OP_RETURN`
  can also be used for protocols that need data to be available before a transaction
  is spent, as opposed to witness data that is revealed in the spending transaction. {% assign timestamp="46:47" %}

- [Why is my Bitcoin node not receiving incoming connections?]({{bse}}126338)
  Lightlike points out that a new node on the network can take time to have its
  address widely advertised on the P2P network and that nodes will not
  advertise their address until IBD has completed. {% assign timestamp="48:25" %}

- [How do I configure my node to filter out transactions larger than 400 bytes?]({{bse}}126347)
  Antoine Poinsot confirms there is no configuration option in Bitcoin Core to
  customize the maximum standard transaction size. He outlines that users
  wanting to customize that value can update their source code, but warns about
  potential downsides of both larger and smaller maximum values. {% assign timestamp="49:44" %}

- [What does "not publicly routable" node in Bitcoin Core P2P mean?]({{bse}}126225)
  Pieter Wuille and Vasil Dimov provide examples of P2P connections, such as
  [Tor][topic anonymity networks], that cannot be routed on the global internet
  and that appear in Bitcoin Core's `netinfo` output in the "npr" bucket. {% assign timestamp="52:21" %}

- [Why would a node would ever relay a transaction?]({{bse}}127391)
  Pieter Wuille lists benefits of relaying transactions for a node operator:
  privacy when relaying your own transactions from your node, faster block
  propagation if the user is mining, and improved network decentralization with
  minimal incremental costs beyond just relaying blocks. {% assign timestamp="52:46" %}

- [Is selfish mining still an option with compact blocks and FIBRE?]({{bse}}49515)
  Antoine Poinsot follows up to a 2016 question noting, "Yes, selfish mining is
  still a possible optimisation even with improved block propagation. It's not
  correct to conclude that selfish mining is now only a theoretical attack". He
  also points to a [mining simulation][miningsimulation github] he created. {% assign timestamp="55:00" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.05rc1][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="57:25" %}

- [LDK 0.1.3][] and [0.1.4][ldk 0.1.4] are releases of this popular
  library for building LN-enabled applications.  Version 0.1.3, tagged
  as a release on GitHub this week but dated last month, includes the
  fix for a denial-of-service attack.  Version 0.1.4, the latest
  release, "fixes a funds-theft vulnerability in exceeding rare cases".
  Both releases also include other bug fixes. {% assign timestamp="57:56" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31622][] adds a signature hash (sighash) type field to
  [PSBTs][topic psbt] when it is different from `SIGHASH_DEFAULT` or
  `SIGHASH_ALL`. [MuSig2][topic musig] support requires everyone to sign with
  the same sighash type, so this field must be present in the PSBT.
  Additionally, the `descriptorprocesspsbt` RPC command is updated to use the
  `SignPSBTInput` function, which ensures that the PSBT's sighash type matches
  the one provided in the CLI, if applicable. {% assign timestamp="1:00:32" %}

- [Eclair #3065][] adds support for attributable failures (see Newsletter
  [#224][news224 failures]) as specified in [BOLTs #1044][]. It’s disabled by
  default because the specification isn't finalized, but can be enabled with the
  setting `eclair.features.option_attributable_failure = optional`.
  Cross-compatibility with LDK has been successfully tested, see Newsletter
  [#349][news349 failures] for more information on LDK’s implementation and how
  this protocol works. {% assign timestamp="37:15" %}

- [LDK #3796][] tightens the channel balance checks so that funders have
  sufficient funds to cover the commitment transaction fee, the two 330 sat
  [anchor outputs][topic anchor outputs], and the channel reserve. Previously,
  funders could dip into the channel reserve funds to cover for the two anchors. {% assign timestamp="1:03:04" %}

- [BIPs #1760][] merges [BIP53][] which specifies a consensus soft-fork rule
  that disallows 64-byte transactions (measured without witness data) to prevent
  a type of [merkle tree vulnerability][topic merkle tree vulnerabilities]
  exploitable against SPV clients. This PR proposes a similar fix to one
  of the fixes included in the [consensus cleanup softfork][topic consensus cleanup]. {% assign timestamp="1:03:40" %}

- [BIPs #1850][] reverts an earlier update to [BIP48][] which reserved the
  script type value 3 for [taproot][topic taproot] (P2TR) derivations (see
  Newsletter [#353][news353 bip48]). This is because [tapscript][topic tapscript]
  lacks `OP_CHECKMULTISIG`, so the referenced output script in [BIP67][] (which
  [BIP48][] relies on) cannot be expressed in P2TR. This PR also marks
  [BIP48][]’s status as `Final`, reflecting that its purpose was to define the
  industry use of `m/48'` [HD wallet][topic bip32] derivation paths when the BIP
  was introduced, rather than prescribe new behavior. {% assign timestamp="1:06:13" %}

- [BIPs #1793][] merges [BIP443][] which proposes the
  [OP_CHECKCONTRACTVERIFY][topic matt] (OP_CCV) opcode that
  allows checking that a public key (of both the outputs and the inputs) commits
  to an arbitrary piece of data. See Newsletter [#348][news348 op_ccv] for more
  information on this proposed [covenant][topic covenants]. {% assign timestamp="1:09:05" %}

{% include snippets/recap-ad.md when="2025-06-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31622,3065,3796,1760,1850,1793,1044" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ldk 0.1.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.3
[ldk 0.1.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.4
[news208 slowln]: /en/newsletters/2022/07/13/#allowing-deliberately-slow-ln-payment-forwarding
[autonomous system]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[kirkcohen af]: https://delvingbitcoin.org/t/latency-and-privacy-in-lightning/1723
[news224 failures]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[news349 failures]: /en/newsletters/2025/04/11/#ldk-2256
[news353 bip48]: /en/newsletters/2025/05/09/#bips-1835
[news348 op_ccv]: /en/newsletters/2025/04/04/#op-checkcontractverify-semantics
[news339 extrapool]: /en/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[miningsimulation github]: https://github.com/darosior/miningsimulation
