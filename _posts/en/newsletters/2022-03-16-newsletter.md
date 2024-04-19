---
title: 'Bitcoin Optech Newsletter #191'
permalink: /en/newsletters/2022/03/16/
name: 2022-03-16-newsletter
slug: 2022-03-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes proposals to extend or replace Bitcoin
Script with new opcodes, summarizes recent discussions about improving
RBF policy, and links to continued work on the `OP_CHECKTEMPLATEVERIFY`
opcode.  Also included is our regular section describing notable changes
to popular Bitcoin infrastructure projects.

## News

- **Extensions and alternatives to Bitcoin Script:** several developers
  discussed on the Bitcoin-Dev mailing list ideas for improving
  Bitcoin's Script and [tapscript][topic tapscript] languages, which
  those receiving bitcoins use to specify how they'll later prove they
  authorized any spending of those bitcoins.

  - *Looping (folding):* developer ZmnSCPxj [described][zmnscpxj fold]
    a proposed `OP_FOLD` opcode as a way to allow loop-like behavior
    in Bitcoin Script.  He described a series of constraints that
    could be placed on the looping to ensure they didn't use any more
    CPU or memory than Bitcoin Script and tapscript can currently
    use---but which would reduce bandwidth by eliminating the need to
    include repeated code in scripts.

  - *Using Chia Lisp:* Anthony Towns [posted][towns btc-lisp] about
    adding to Bitcoin a variation on [Chia Lisp][], which is a dialect
    of [Lisp][] designed for the Chia altcoin.  This
    would be a completely different alternative to traditional Bitcoin
    Script and tapscript, providing some of the same benefits of a
    fresh start as the previously proposed [Simplicity][topic
    simplicity] language.  Towns suggests that his
    alternative---"Binary Tree Coded Script" or "btc-script"---would be
    easier to understand and use than Simplicity, although perhaps it
    would be harder to formally validate.

- **Ideas for improving RBF policy:** Gloria Zhao [posted][zhao rbf] a
  summary of discussion about Replace-by-Fee ([RBF][topic rbf]) policy
  from the recent [CoreDev.Tech][] meeting in London as well as some
  related updates.  She reports that the main concept discussed was
  attempting to bound the maximum amount of resources used for relaying
  transactions and their replacements, such as by limiting the number of
  related transactions that get relayed within a certain amount of time.

  Zhao also summarized a separate [discussion][daftuar limits] on a
  gist which examined allowing transactions to suggest a descendant
  limit to use.  For example, a transaction could suggest limiting the
  maximum amount of space it and its descendants could consume in the
  mempool to 1,000 vbytes instead of the default 100,000 vbytes.  This
  would make the worst case [pinning attack][topic transaction pinning]
  less expensive for the honest party to overcome.

  Additionally, Zhao is seeking feedback on an algorithm for
  calculating the value to miners of a transaction given the current
  mempool.  This could facilitate more flexible decision making in node
  software about whether or not to accept a replacement transaction.

- **Continued CTV discussion:** as mentioned in [Newsletter
  #183][news183 ctv meeting], meetings to discuss the proposed
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) opcode
  have continued with summaries provided by Jeremy Rubin: [1][news183
  ctv meeting], [2][ctv2], [3][ctv3], [4][ctv4], and [5][ctv5].
  Additionally this past week, James O'Beirne [posted][obeirne vault]
  code and design documentation for a CTV-based [vault][topic vaults].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24198][] extends the `listsinceblock`, `listtransactions`
  and `gettransaction` RPCs with a new `wtxid` field containing each
  transaction's Witness Transaction Identifier as defined in [BIP141][].

- [Bitcoin Core #24043][] adds new `multi_a` and `sortedmulti_a`
  [descriptors][topic descriptors] for creating spending authorization
  policies that can work with [tapscript's][topic tapscript]
  `OP_CHECKSIGADD` opcode rather than older Script's `OP_CHECKMULTISIG`
  and `OP_CHECKMULTISIGVERIFY` opcodes.  See [Newsletter #46][news46
  csa] for more information about this aspect of tapscript.

- [Bitcoin Core #24304][] adds a new demo `bitcoin-chainstate`
  executable that can be passed a Bitcoin Core data directory and a
  block, which it will validate and add to the data directory.  This
  isn't expected to be directly useful, but creates a tool the
  [libbitcoinkernel][bitcoin core #24303] project will leverage to
  produce a library other projects can use to validate blocks and
  transactions using the exact same code Bitcoin Core uses.

- [C-Lightning #5068][] increases the minimum number of [BOLT7][]
  `node_announcement` messages C-Lightning will relay per node per day
  from one to two.  This may mitigate some problems related to nodes changing
  IP addresses or temporarily going offline for maintenance.

- [BIPs #1269][] assigns [BIP326][] to a recommendation that
  [taproot][topic taproot] transactions set an nSequence value even when
  it's not needed for a contract protocol in order to improve privacy
  when [BIP68][] consensus-enforced nSequence values are needed.  BIP326
  also describes how the use of nSequence can provide an alternative to
  [anti fee sniping][topic fee sniping] protection currently enabled
  through the transaction locktime field.  See [Newsletter #153][news153
  nseq] for a summary of the original mailing list proposal.

{% include references.md %}
{% include linkers/issues.md v=1 issues="24198,24043,24304,24303,5068,1269" %}
[news46 csa]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
[zmnscpxj fold]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/020021.html
[towns btc-lisp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020036.html
[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[chia lisp]: https://chialisp.com/
[zhao rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020095.html
[daftuar limits]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff?permalink_comment_id=4058140#gistcomment-4058140
[news183 ctv meeting]: /en/newsletters/2022/01/19/#irc-meeting
[ctv2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019855.html
[ctv3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019874.html
[ctv4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019974.html
[ctv5]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020086.html
[obeirne vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020067.html
[coredev.tech]: https://coredev.tech/
[news153 nseq]: /en/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions
