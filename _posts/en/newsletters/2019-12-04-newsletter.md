---
title: 'Bitcoin Optech Newsletter #75'
permalink: /en/newsletters/2019/12/04/
name: 2019-12-04-newsletter
slug: 2019-12-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes some recent discussion about the
schnorr and taproot proposals, notes the recent update of the
proposal formerly known as `OP_CHECKOUTPUTSHASHVERIFY` and
`OP_SECURETHEBAG`, links to a proposal to standardize LN watchtowers,
and summarizes notable changes to popular Bitcoin
infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## News

- **Continued schnorr/taproot discussion:** this week, Russell O'Connor
  started a [thread][oconnor checksig pos] on the Bitcoin-Dev mailing list continuing a
  [previous discussion][wuille safer sighashes] about having signatures commit to the position
  of the opcode that's expected to evaluate that signature (e.g.
  the opcodes `OP_CHECKSIG`, `OP_CHECKSIGVERIFY`, or [tapscript's][topic tapscript] new
  `OP_CHECKSIGADD`).  O'Connor argues that this commitment provides additional
  protection for people who use scripts with multiple branches that
  allow the script to be satisfied in several different ways using
  signatures from more than one user.  Without this protection, it might
  be possible for Mallory to ask Bob to sign for branch *A*
  when Mallory is really going to use that signature in branch *B*.  An
  existing opcode, `OP_CODESEPARATOR`, helps deal with such situations,
  but it's not well known and so addressing the concern directly
  could improve safety and possibly eliminate the need to include
  `OP_CODESEPARATOR` in tapscript.

    Following some [IRC discussion][irc checksig pos] by several
    participants, Anthony Towns [replied][towns checksig pos] with a
    suggested alternative: scripts that are susceptible to this problem
    should have their branches separated into multiple taproot leaves
    each with just one code branch.  Tapscript signatures already commit
    to the script being executed, so a signature that's valid for one
    script can't be used in another script.  Towns also described why
    committing only to the position might not guarantee protection against
    repositioned signatures.  Although he did describe a method that he
    thinks could provide superior protection, he believes it's not
    particularly useful compared to just keeping `OP_CODESEPARATOR` in
    tapscript.

    {:#composable-musig}
    In a separate schnorr-related topic, [[ZmnSCPxj]] wrote a [post][zmn
    composable musig] about the challenges of safely using the [MuSig][]
    signature aggregation protocol with sub-groups.  For example,
    ZmnSCPxj's [nodelets proposal][] suggests Alice and Bob
    could jointly control funds through a single LN node using the
    aggregation of their keys, (A, B).  Their joint node could then open
    a channel to Charlie's node, using MuSig aggregation there too, ((A,
    B), C).  However, ZmnSCPxj describes why this might be unsafe given
    Wagner's algorithm as described in [last week's newsletter][news74
    taproot updates].  Also described are several alternative schemes
    that attempt to work around the problem.

- **`OP_CHECKTEMPLATEVERIFY` (CTV):** the successor to
  `OP_CHECKOUTPUTSHASHVERIFY` (COSHV) described in [Newsletter
  #48][news48 coshv] and `OP_SECURETHEBAG` mentioned in [Newsletter
  #49][news49 stb], this new opcode [proposed][ctv post] by Jeremy Rubin
  would allow a script to ensure its funds could only be spent by a
  specified set of child transactions.  In addition to the name change,
  Rubin has also added additional details to the [proposed BIP][bip-ctv]
  and he plans to hold a review workshop in the first few months of 2020
  (fill out [this form][ctv workshop] if you're interested in
  attending).

    On-list, Russell O'Connor [restated][oconnor state variable] a
    [previous concern][oconnor suggested amendments] of his about CTV
    pulling data off the stack in an abnormal order for Bitcoin Script.
    This was added by Rubin in order to prevent the creation of
    recursive [covenants][topic covenants]---script conditions that
    apply not just to a finite set of descendant transactions but which
    will apply to all spends descended from a particular script in
    perpetuity.  For example, a spender could restrict the future
    receivers of a set of coins to just three addresses---any payment to
    any other address would be forbidden.  O'Connor's concerns seemed to
    focus on this odd behavior of CTV making it harder to model the
    semantics of Bitcoin
    Script, something which O'Connor has previously worked on and which
    is related to his continuing work on the [Simplicity][] scripting
    language.

    On IRC, Gregory Maxwell and Jeremy Rubin [discussed][irc ctv]
    several aspects of CTV, especially focusing on making the proposed
    opcode easier to use with advanced designs without making it harder
    to use with the simple [congestion controlled transactions][] and
    [payment pools][] already proposed.  They also discussed whether it
    was really necessary to prevent people from creating recursive
    covenants, with a possible [allusion][covenant allusion] in the conversation to a [2013
    thread][coincovenants] started by Maxwell about awful ways misguided
    people might use recursive covenants.

- **Proposed watchtower BOLT:** Sergi Delgado Segura [posted][watchtower
  protocol] to the Lightning-Dev mailing list a draft BOLT he and
  Patrick McCorry have been working on.  [Watchtowers][topic
  watchtowers] are services that broadcast penalty transactions on
  behalf of LN nodes that may be offline, recovering any funds that
  would otherwise have been lost due to an old channel state being
  confirmed onchain.  The goal of the proposed specification is to allow
  all LN implementations to interoperate with any watchtower rather than
  there being a different watchtower implementation for every LN
  implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #3259][] adds experimental support for payment secrets,
  which are proposed in [BOLTs #643][] as part of enabling [multipath
  payments][topic multipath payments].  The payment secret is generated
  by the receiver and included in their [BOLT11][] invoice.  The spender
  includes this secret in the part of their payment that's encrypted to
  the receiver's key.  The receiver only accepts an incoming payment for
  the invoice if it contains the secret, preventing any other nodes from
  probing the receiver to see whether it's expecting additional payments
  to a previously-used payment hash.

- [C-Lightning #3268][] changes the default network from Bitcoin testnet
  to Bitcoin mainnet.  It also adds a new configuration option,
  `include`, that includes any configuration directives provided in the
  indicated file.

{% include linkers/issues.md issues="3259,643,3268" %}
[news48 coshv]: /en/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
[news49 stb]: /en/newsletters/2019/06/05/#coshv-proposal-replaced
[oconnor checksig pos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017495.html
[wuille safer sighashes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016508.html
[irc checksig pos]: http://www.erisian.com.au/taproot-bip-review/log-2019-11-28.html#l-65
[towns checksig pos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017497.html
[zmn composable musig]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017493.html
[nodelets proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002236.html
[news74 taproot updates]: /en/newsletters/2019/11/27/#schnorr-taproot-updates
[ctv post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017494.html
[bip-ctv]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki
[ctv workshop]: https://forms.gle/pkevHNj2pXH9MGee9
[oconnor state variable]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017496.html
[oconnor suggested amendments]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016973.html
[irc ctv]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861123;
[congestion controlled transactions]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki#Congestion_Controlled_Transactions
[payment pools]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-21#1558427254-1558427441;
[watchtower protocol]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002350.html
[coincovenants]: https://bitcointalk.org/index.php?topic=278122.0
[simplicity]: https://blockstream.com/simplicity.pdf
[covenant allusion]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861296
