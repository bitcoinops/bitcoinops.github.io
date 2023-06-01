---
title: 'Bitcoin Optech Newsletter #77'
permalink: /en/newsletters/2019/12/18/
name: 2019-12-18-newsletter
slug: 2019-12-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the release of LND 0.8.2-beta, requests
help testing the latest C-Lightning release candidate, discusses
widespread support for basic multipath payments in LN, provides an update on
bech32 error detection reliability, summarizes updates to the proposed
`OP_CHECKTEMPLATEVERIFY` opcode, and links to a discussion about the impact
of eclipse attacks on LN channels.  Also included are our regular
sections about notable changes to popular Bitcoin infrastructure
projects, changes to services and client software, and popular Bitcoin
Stack Exchange questions and answers.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade to LND 0.8.2-beta:** this [release][lnd 0.8.2-beta] contains
  several bug fixes and minor UX improvements, most notably for the
  recovery of static channel backups.

- **Help test C-Lightning 0.8.0 RC:** the [release candidate][cl 0.8.0]
  for the next version of C-Lightning switches the default network to
  mainnet instead of testnet (see [Newsletter #75][news75 cl mainnet])
  and adds support for basic multipath payments (described below) among
  many other features and bug fixes.

- **Review bech32 action plan:** as [described below][bech32 news],
  Pieter Wuille suggests restricting all bech32 addresses to 20 or 32
  byte witness programs in order to prevent a loss of funds from
  transcription errors involving addresses ending with a `p`.  This rule
  already applies to v0 segwit addresses used for P2WPKH and P2WSH, so
  the change would simply be extending it to v1+ addresses currently
  reserved for future upgrades (such as the proposed [taproot][topic
  taproot]).  This will require wallets and services that have already
  implemented bech32 sending support to upgrade their code, but it should
  be a tiny change; e.g. for the [Python reference
  implementation][bech32 python] it might look something like:

    ```diff
    --- a/ref/python/segwit_addr.py
    +++ b/ref/python/segwit_addr.py
    @@ -110,7 +110,7 @@ def decode(hrp, addr):
             return (None, None)
         if data[0] > 16:
             return (None, None)
    -    if data[0] == 0 and len(decoded) != 20 and len(decoded) != 32:
    +    if len(decoded) != 20 and len(decoded) != 32:
             return (None, None)
         return (data[0], decoded)
    ```

    If you have any questions or concerns about this suggested change,
    please reply to the mailing list post linked in the *news* section
    below.

## News

- **LN implementations add multipath payment support:** after a
  significant amount of discussion and development, all three LN
  implementations tracked by Optech have now added basic support for
  [multipath payments][topic multipath payments] (merges: [C-Lightning][mpp cl],
  [Eclair][mpp eclair], [LND][mpp lnd]).  A multipath payment
  consists of multiple LN payments routed over different paths which may
  all be claimed at the same time by the receiver.  This provides a
  major upgrade to the usability of LN by allowing users to spend or
  receive funds in several of their channels in the same overall
  payment.  This upgrade means that spenders in particular have much
  less need to worry about how much balance they have in any particular
  channel as they can send up to their full available balance across all
  their channels (subject to other LN limits).

- **Analysis of bech32 error detection:** Pieter Wuille sent an
  [email][wuille bech32 post] to the Bitcoin-Dev mailing list following
  up on the bech32 malleability concerns described in previous
  newsletters ([#72][news72 bech32], [#74][news74 bech32], and
  [#76][news76 bech32]) where it's possible to add or remove any number of `q`
  characters immediately before a `p` character at the end of a bech32
  string.  Wuille's [analysis][wuille bech32 analysis] shows that this
  is the only exception to bech32's expected error detection properties
  and that "changing one constant in bech32 would resolve this issue."

    Wuille plans to amend [BIP173][] to describe the weakness, propose a
    change to limit existing bech32 address uses to either 20 byte or 32
    byte witness program payloads, and define a modified version of
    bech32 with the alternative constant for non-Bitcoin uses and for a
    potential future where we want witness programs that are not 20
    bytes or 32 bytes.

- **Proposed changes to bip-ctv:** Jeremy Rubin [suggested][rubin ctv
  update] several changes to the proposed soft fork addition of an
  `OP_CHECKTEMPLATEVERIFY` (CTV) opcode.  Most
  notably, the changes will remove the restriction that templates
  used by CTV cannot be derived from other data via Bitcoin Script.
  This update simplifies the modification to the Script language discussed
  in [Newsletter #75][news75 ctv].  None of the
  updates modifies CTV's behavior in a way that would
  significantly affect previously described usecases as far as we're
  aware (but anyone who is aware of fundamental changes is encouraged to
  discuss them on-list).

- **Discussion of eclipse attacks on LN nodes:** Antoine Riard
  [posted][riard eclipse] to the Lightning-Dev mailing list a
  description of two attacks possible against LN users if they are
  eclipse attacked and the attacker delays the relay of blocks.  An
  eclipse attack occurs when all connections made by a full node or
  lightweight client are controlled by a single attacker, as might
  easily be the case when the attacker is an ISP or takes control of a user's
  router.  This gives the attacker full control over what data the node
  or client sends or receives.  In the first attack, the eclipse
  attacker can send a revoked commitment transaction without the
  honest user learning about it in time to submit the corresponding penalty
  transaction, allowing the attacker to steal from the honest user.
  In the second attack, the attacker prevents
  the honest user from realizing that they need to broadcast the latest
  commitment transaction because one or more of its HTLCs is about to
  expire---this allows the attacker to steal the funds in the HTLC after
  it does expire.

    Both Riard's post and replies from [Matt Corallo][corallo eclipse]
    and [[[ZmnSCPxj]]][zmn eclipse] discuss past and present work to make
    full nodes and lightweight clients more resistant to eclipse
    attacks.  Readers interested in learning more about eclipse attacks
    and their mitigations are also strongly encouraged to read the Bitcoin
    Core review club's [meeting notes and log][review club notes] for
    the past week, as they covered this topic in depth.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Bitfinex supports LN deposits and withdrawals:** In a [recent blog post][bitfinex ln blog],
  Bitfinex has announced support on their exchange for Lightning Network. Users
  of Bitfinex can now both deposit and withdraw funds using LN.

- **BitMEX Research launches an LN penalty transaction tracker:**
  In an [article posted by BitMEX Research][bitmex ln penalty blog],
  the open source ForkMonitor tool now [lists Lightning penalty transactions][fork monitor lightning].
  The tool also monitors chaintips across a variety of Bitcoin implementations
  and versions in order to detect forks.

- **BitMEX bech32 send support:** In a [recent blog post][bitmex bech32 blog],
  BitMEX has announced support on their exchange for sending to native bech32
  addresses. The post also outlines plans to migrate from P2SH to P2SH-wrapped
  segwit addresses for their own wallet.

- **Unchained Capital open sources Caravan, a multisig coordinator:**
  With a [blog post and demo video][unchained caravan blog], Unchained Capital
  has open sourced their [multisig coordinator named Caravan][unchained caravan
  github]. Caravan is a stateless web application for creating and spending from
  a multisig address using a variety of external keystores.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What is the rationale for the Lightning network's path length limit (20 hops)?]({{bse}}92073)
  Sergei Tikhomirov asks about BOLT4's 20 hop limit and the comparison of Tor's
  onion routing with LN's Sphinx. Rene Pickhardt outlines the differences in
  protocols and motivations for the current limit: keeping TCP/IP packages small
  and assumptions that LN be a small-diameter network.

- [Is there a way to allow use of unconfirmed RBF outputs in transaction building?]({{bse}}92164)
  G. Maxwell points out that Bitcoin Core treats outputs from
  transactions signaling opt-in Replace-by-Fee (RBF) the same way it
  treats outputs from transactions that don't signal RBF support.
  Differences in the way an output is handled by Bitcoin Core depend on
  whether the transaction containing the output is confirmed or not, and
  whether the transaction was created by the user's Bitcoin Core wallet or not.

- [What is the max allowed depth for BIP32 derivation paths?]({{bse}}92056)
  Andrew Chow explains that, since BIP32 allocates one byte for the depth field,
  there are a maximum of 256 possible elements in the derivation path.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17678][] adds support for compiling to the
  [S390X][] and 64-bit [POWER][] CPU architectures.

- [Bitcoin Core #12763][] adds an RPC whitelist feature that allows you
  to restrict which RPCs a particular user can run.  By default, any
  authenticated user can run any command, but the new configuration
  options `rpcwhitelist` and `rpcwhitelistdefault` may be used to
  configure which users can access which RPCs.

- [C-Lightning #3309][] adds support for multipath payments as
  [described][mpp deployed] in the *news* section above.

- [LND #3697][] sets the default minimum HTLC value to 1 millisatoshis
  (msat) for new channels, down from a previous default of 1,000 msat.
  The minimum HTLC value can't be changed once a channel is opened, so
  this change allows channels using this setting to accept sub-satoshi
  payments.  [Edit: a previous version of this paragraph incorrectly
  claimed the new minimum was 0 msat; the correct value is 1 msat.]

- [LND #3785][] mostly fixes the issue mentioned in [Newsletter
  #74][news74 c-lightning-3264] where C-Lightning and LND used different
  formats for the same message, leading to parsing errors and
  disconnects.

- [LND #3702][] extends the `closechannel` RPC with a `delivery_address`
  parameter that can be used to request a mutual close of a channel send
  funds to the specified address.  This won't work if the user previously
  activated the upfront shutdown script feature described in [last
  week's newsletter][news76 upfront shutdown].

- [LND #3415][] allows settling invoices via multipath payments, adding
  the final necessary code for basic multipath payment support in LND
  (see the [description][mpp deployed] of multipath payments in the
  *news* section above).

- [BOLTs #643][] adds basic multipath payment support as [described][mpp
  deployed] in the *news* section above.  This achieves one of the
  [major goals][news22 multipath] set during the Lightning Specification
  1.1 meeting a year ago to help [significantly improve LN wallet
  UX][news22 ux].

## Holiday publication schedule

We will not be publishing newsletters on December 25th or January 1st.
Instead, we'll publish our second annual year-in-review special report
on Saturday, December 28th. Regular newsletter publication will resume
on Wednesday, January 8th.

Happy holidays!

{% include linkers/issues.md issues="17678,12763,3309,3697,3785,3702,3415,643" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta
[wuille bech32 post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017521.html
[wuille bech32 analysis]: https://gist.github.com/sipa/a9845b37c1b298a7301c33a04090b2eb
[news75 cl mainnet]: /en/newsletters/2019/12/04/#c-lightning-3268
[news72 bech32]: /en/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
[news74 bech32]: /en/newsletters/2019/11/27/#how-does-the-bech32-length-extension-mutation-weakness-work
[news76 bech32]: /en/newsletters/2019/12/11/#lnd-3767
[news75 ctv]: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news22 multipath]: /en/newsletters/2018/11/20/#multi-path-payments
[news22 ux]: /en/newsletters/2018/11/20/#multipath-splicing-ux
[power]: https://en.wikipedia.org/wiki/IBM_POWER_instruction_set_architecture
[s390x]: https://en.wikipedia.org/wiki/Linux_on_IBM_Z
[cl 0.8.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.0rc2
[riard eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002369.html
[corallo eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002370.html
[zmn eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002372.html
[mpp deployed]: #ln-implementations-add-multipath-payment-support
[news74 c-lightning-3264]: /en/newsletters/2019/11/27/#c-lightning-3264
[news76 upfront shutdown]: /en/newsletters/2019/12/11/#lnd-3655
[rubin ctv update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017525.html
[bitfinex ln blog]: https://www.bitfinex.com/posts/440
[bitmex bech32 blog]: https://blog.bitmex.com/bitmex-enables-bech32-sending-support/
[bitmex ln penalty blog]: https://blog.bitmex.com/lightning-network-part-5-bitmex-research-launches-penalty-transaction-alert-system/
[fork monitor lightning]: https://forkmonitor.info/lightning
[unchained caravan blog]: https://www.unchained-capital.com/blog/the-caravan-arrives/
[unchained caravan github]: https://github.com/unchained-capital/caravan
[bech32 news]: #analysis-of-bech32-error-detection
[bech32 python]: https://github.com/sipa/bech32/tree/master/ref/python
[mpp cl]: #c-lightning-3309
[mpp eclair]: /en/newsletters/2019/11/20/#eclair-1153
[mpp lnd]: #lnd-3415
[review club notes]: https://bitcoincore.reviews/16702.html
