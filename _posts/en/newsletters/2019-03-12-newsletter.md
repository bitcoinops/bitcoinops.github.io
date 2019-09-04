---
title: 'Bitcoin Optech Newsletter #37'
permalink: /en/newsletters/2019/03/12/
name: 2019-03-12-newsletter
slug: 2019-03-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter notes a vulnerability in Bitcoin Core versions
that are already past end-of-life, asks for help testing release
candidates of the next major version of Bitcoin Core, provides an update
on the Bitcoin-Dev mailing list, describes recent discussions from the
list, and links to a chapter about payment batching in Optech's
work-in-progress scaling techniques book.  Also included are
descriptions of several notable commits in popular Bitcoin
infrastructure projects.

## Action items

- **Ensure you aren't running old Bitcoin Core versions:** Suhas Daftuar
  disclosed a vulnerability affecting Bitcoin Core 0.13.0 to 0.13.2.
  (Note: those releases have been past [end-of-life][core eol] for
  several months.) The vulnerability would allow an attacker to convince
  your node that a valid block was invalid, forking you off the
  consensus block chain and making it possible to trick you into
  believing that you received confirmed bitcoins you wouldn't actually
  control.  In addition to checking for old versions of Bitcoin Core in
  your infrastructure, it's also recommended that you check for altcoins
  whose nodes are based on the affected Bitcoin Core versions.  See the
  disclosure details below for more information.

- **Help test Bitcoin Core 0.18.0 RC1:** The first Release Candidate
  (RC) for the next major version of Bitcoin Core has been released.
  Organizations and experienced users who depend upon Bitcoin Core are
  highly encouraged to [test it][0.18.0] for regressions and other
  problems that could affect your use of it in production.  Any testing
  is appreciated, but if you have some extra time after testing for your
  specific use cases, please consider helping test [0.18's changes][gui 0.18] to the GUI.  This
  interface is primarily used by less experienced users who are unlikely
  to test RCs themselves but who would be especially affected by any
  problems that slip through.

## News

- **Bitcoin-Dev mailing list status update:** the service outage
  reported in [last week's newsletter][Newsletter #36] has been resolved
  but list administrators are [planning][bishop list] to migrate to
  another solution.  Many posts sent in the past two weeks have been
  relayed to list subscribers, but some have been lost.  If you don't
  see your post in the [February][list feb] or [March][list mar]
  archives, please resend it.  Future Optech newsletters will mention
  any actions list subscribers need to take in order to continue to
  receive protocol discussion.

- **Bitcoin Core vulnerability disclosure:** Suhas Daftuar
  [disclosed][merkle disclosure] a novel method for tricking earlier
  Bitcoin Core versions into rejecting valid blocks.  If an attacker
  created a block with two transactions whose 32-byte hashes (txids),
  when concatenated together, appear to be a 64-byte transaction, it's
  possible to create two different interpretations of the merkle tree rooted in
  the block header---one where the tree points to a single invalid 64-byte
  transaction and one where it points to two valid transactions.
  (Similar conflicting versions can also be created with more than two
  transactions.)

    ![Diagram of two identical merkle roots derived from different block
    data](/img/posts/2019-03-merkle-ambiguity.svg)

    This can create a problem for Bitcoin Core as, normally, if it
    rejects a block as being invalid, it will add the header hash of
    that block to a cache so that it doesn't waste resources requesting
    or re-processing that block again.  This allowed an attacker to
    send your node the invalid form of the block to subsequently prevent
    your node from processing its valid form or any blocks that descend
    from it, forking you off the chain.

    A similar vulnerability was disclosed in 2012 as [CVE-2012-2459][]
    and Bitcoin Core was adapted then to not cache invalidity for blocks
    whose merkle tree contains ambiguities.  However, an
    [optimization][bitcoin core #7225] implemented in Bitcoin Core 0.13.0
    reintroduced this caching problem and necessitated a [fix][bitcoin
    core #9765], which was included in Bitcoin Core 0.14.0.  Daftuar's
    email includes a [very informative PDF][daftuar pdf] that not only
    describes this specific problem in detail and shows its cost to be a
    very small 30 bits of brute force work (although you also need to
    mine a custom block) but which also describes other known
    vulnerabilities possible with Bitcoin's merkle trees and calculates
    the average amount of brute force work to exploit them.  Daftuar did
    not find any instances of the attack to date in the current
    consensus block chain.

- **Cleanup soft fork proposal discussion:** this week saw discussion
  about the consensus cleanup soft fork [proposal][bip-cleanup]
  described in [last week's newsletter][newsletter #36].  Russell
  O'Connor [raised the concern][roconnor codesep] that invalidation of
  the `OP_CODESEPARATOR` opcode could prevent
  existing UTXOs using the opcode from being spent.  It's not possible to detect this
  because people could've paid money to a P2SH address whose
  not-yet-revealed redeemScript uses the discouraged opcode.  O'Connor
  proposes to mitigate the problem of `OP_CODESEPARATOR` being used to
  increase worse-case block verification time by instead increasing the
  weight (vbytes) of transactions whose evaluated scripts contain the
  opcode.  This would reduce the maximum number of code separators that
  could be contained within a block while also likely reducing the
  overall size and total number of operations in the block to the point
  where it could be verified reasonably quickly.

    O'Connor also raised a [similar concern][roconnor sighash] regarding
    the soft fork's proposal to invalidate the unallocated sighash type bytes.
    It's also not possible to entirely detect this because Bitcoin users
    may have created pre-signed locktimed transactions for which they've
    lost or destroyed the signing keys, preventing them from creating
    new signatures.  Instead of increasing the weight of the unallocated
    sighash bytes to restrict their use, he recommends use of a more
    complex sighash cache (as previously described as an option in the
    proposed BIP).

    Matt Corallo replied to both of O'Connor's concerns by pointing out
    that, although we can't detect usage of these features for spends
    that haven't been broadcast, we can detect them for any transactions
    in the existing chain---and that usage doesn't exist.  "I'm
    seriously skeptical that someone is using a highly esoteric scheme
    and has just been pouring money into it without ever having tested
    it or having withdrawn any money from it whatsoever," said Corallo
    before also discussing the amount of extra complexity for
    calculating fees and caching sighashes if these features aren't
    disabled.  His rebuttal also included a plea for anyone using
    transaction features that are not relayed or mined by default
    ("non-standard") to [contact][core contact] Bitcoin Core developers
    and let them know about the situation so that policies can be
    reconsidered.

- **Feedback requested on signet:** Karl-Johan Alm has been working on
  an [alternative][signet] to Bitcoin's testnet that uses
  centrally-signed blocks instead of proof of work.  Although this
  doesn't allow testing the decentralized nature of Bitcoin, it could
  make the testing network much more convenient for application
  developers by providing regular block production most of the time plus
  scheduled tests of adverse events such as block chain reorganizations
  or fee spikes.  It would also ensure the central signing authority
  always had test coins to distribute via their faucet.  By comparison,
  testnet block production is sometimes too fast for peers to keep up or
  so slow that it's useless for testing, faucets are often empty, and
  griefers can create reorg scenarios that would be extremely unlikely
  to exist on a network with actual value at stake.  Alm is seeking
  feedback and would like to eventually incorporate his code into
  Bitcoin Core (and, probably, have other node implementations support
  it too).

- **Removal of BIP61 P2P `reject` messages:** Marco Falke started a
  [thread][falke bip61] seeking feedback about his desire to remove
  [BIP61][] reject messages from Bitcoin Core.  When your node receives
  a message (such as a transaction) that has some problem, your node
  will return a `reject` message that contains a description of the
  problem.  BIP61 messages are not trustless (your node could lie) and
  the same information about problems can be extracted from the
  rejecting node's logs, which allows developers to investigate problems
  with messages sent to their own nodes.  See [Newsletter #13][] for
  our description of Falke's PR that disabled `reject` messages by
  default in Bitcoin Core.

    Andreas Schildbach, a wallet author and lead maintainer of the
    popular BitcoinJ library, requested keeping the messages and
    re-enabling them by default.  His users email him logfiles
    containing reject messages when their transactions don't go through,
    helping him to debug problems.  In response, Gregory Maxwell pointed
    out that even when an honest node accepts a transaction, that
    doesn't mean it'll be also accepted by that node's peers.  That
    means clients still need to monitor for transaction propagation
    without using BIP61, making BIP61 redundant for that purpose.
    Similarly, BIP61 can't reasonably be used to detect transactions
    with too-low feerates because an accepted transaction paying a
    minimum feerate may take weeks longer to confirm than the user
    desired when default-sized mempools are full.  Finally, verification
    nodes are designed to maximize performance, which often conflicts
    with the ability to provide maximally-useful debugging information
    to random untrusted peers.

- **Extension fields to Partially Signed Bitcoin Transactions (PSBTs):**
  Andrew Poelstra [proposed][psbt extension] the addition of several
  fields to PSBTs to help support several new features.  He also
  proposed making one currently-required field optional.  These new
  fields can help clients determine whether an `OP_CHECKSEQUENCEVERIFY`
  (CSV) condition is satisfied, support the full range of scripts it's
  possible to generate with [miniscript][], and include extra data for
  use with the [MuSig][], pay-to-contract, and sign-to-contract
  protocols.  [BIP174][] author Andrew Chow appeared receptive to most
  of the suggestions.

- **Review of Bitcoin privacy literature published:** Chris Belcher
  published an extended [summary][privacy summary] of various privacy
  concerns present in Bitcoin.  That page and the Wiki's related
  [Privacy category][] provides an excellent starting point for anyone
  researching Bitcoin privacy concerns.

- **Version 2 `addr` message proposed:** Wladimir van der Laan has
  [proposed][addrv2 proposal] creating a BIP for a new version of the
  P2P protocol `addr` message.  The existing message communicates the IP
  address or [OnionCat][] encoded Tor hidden service (.onion) name of a
  node, its port, and a bitmap of the services the node provides.
  However, since the release of the original Bitcoin codebase, Tor has
  upgraded their hidden service addresses to use 256 bits, preventing
  them from being used in Bitcoin's existing `addr` messages.  There are
  also other network overlay protocols, such as I2P, that also use
  longer addresses.  The proposed BIP, if implemented, will provide
  support for these protocols.

- **Optech publishes book chapter about payment batching:** paying
  multiple people in the same transaction can reduce the average
  transaction fee cost per payment by more than 70%.  The technique is
  especially convenient for high-frequency spenders such as exchanges.
  As part of Optech's ongoing work to create a guide to
  individually-deployable scaling techniques, we're publishing our [draft
  chapter][batching chapter] that describes this technique and its
  tradeoffs in detail.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].  Note that Bitcoin Core currently has work being
performed on both its master development branch and the branch for the
upcoming 0.18 release, so we've noted which branch each Bitcoin Core
merge affected.*

- [Bitcoin Core #15118][] generalizes how Bitcoin Core stores and
  retrieves data associated with blocks and UTXO changes in order to
  make it easier for new methods to store and retrieve other information
  in the same way.  This was done to allow reusing that mechanism for
  storing [BIP157][] compact block filters on disk.  This is currently
  part of the master development branch only.

- [Bitcoin Core #15492][] removes the deprecated `generate` RPC used for
  creating blocks in regtest mode.  This RPC was previously superseded by
  the `generatetoaddress` RPC which doesn't require the node to be built
  or run with wallet support.  This is part of the master development
  branch only.

- [Bitcoin Core #15497][] changes the use of [output script
  descriptors][] in multiple RPCs to use consistent range notation for
  deriving multiple addresses from a descriptor with a [BIP32][] HD
  wallet path.  This is part of the 0.18 branch and 0.18.0RC1 release.

- [LND #2690][] puts more gossip traffic in a queue (rather than sending
  it immediately) so that higher-priority information is more likely to
  be handled quickly.  Gossip traffic is used for communicating which
  peers are on the network and what channels they have available.

- [C-Lightning #2391][] deprecates the `address` field in the `newaddr`
  RPC, replacing it with either a `bech32` field or a `p2sh-segwit` field
  depending on the address type requested (or both fields if an optional
  `all` parameter is passed to the RPC).  The address type in each field
  is consistent with its name.

{% include references.md %}
{% include linkers/issues.md issues="7225,9765,15118,15492,15497,2690,2391" %}
[core eol]: https://bitcoincore.org/en/lifecycle/#schedule
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[bishop list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016700.html
[merkle disclosure]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016697.html
[list feb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/date.html
[list mar]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/date.html
[daftuar pdf]: http://lists.linuxfoundation.org/pipermail/bitcoin-dev/attachments/20190225/a27d8837/attachment-0001.pdf
[roconnor codesep]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016724.html
[roconnor sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016725.html
[core contact]: https://bitcoincore.org/en/contact/
[signet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016734.html
[falke bip61]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016701.html
[bip-cleanup]: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki
[psbt extension]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016713.html
[privacy summary]: https://en.bitcoin.it/wiki/Privacy
[privacy category]: https://en.bitcoin.it/wiki/Category:Privacy
[addrv2 proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016687.html
[onioncat]: https://web.archive.org/web/20121122003543/http://www.cypherpunk.at/onioncat/wiki/OnionCat
[batching chapter]: https://github.com/bitcoinops/scaling-book/blob/master/x.payment_batching/payment_batching.md
[gui 0.18]: https://github.com/bitcoin/bitcoin/pulls?utf8=%E2%9C%93&q=is%3Apr+label%3AGUI+milestone%3A0.18.0
