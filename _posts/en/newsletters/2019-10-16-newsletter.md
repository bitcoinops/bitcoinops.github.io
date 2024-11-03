---
title: 'Bitcoin Optech Newsletter #68'
permalink: /en/newsletters/2019/10/16/
name: 2019-10-16-newsletter
slug: 2019-10-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the newest release of LND, requests
testing of release candidates for Bitcoin Core and C-Lightning,
relays an update on the taproot proposal, describes a proposed increase
in the default LN routing fees, and summarizes three talks from the recent
Cryptoeconomic Systems Summit.  Also included is our regular section on
notable changes to popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade LND to version 0.8.0-beta:** [LND's newest release][lnd
  0.8.0-beta] uses a more extensible packet format, improves backup
  safety, increases watchtower client integration, makes routing more
  likely to succeed, and includes many other new features and bug fixes.

- **Upgrade to Eclair 0.3.2:** [Eclair's newest release][eclair 0.3.2]
  improves backups, makes syncing gossip data more bandwidth efficient
  (especially for non-routing nodes, such as nodes on mobile devices),
  and includes many other new features and bug fixes.

- **Review RCs:** two popular Bitcoin infrastructure projects have
  issued Release Candidates (RCs) for the next version of their software.
  We encourage developers and experienced users to help test these RCs
  so that any problems can be found and fixed before their general
  public release:

  - [Bitcoin Core 0.19.0rc1][bitcoin core 0.19.0]
  - [C-Lightning 0.7.3-rc2][c-lightning 0.7.3]

## News

- **Taproot update:** Pieter Wuille sent an [email][taproot update] to
  the Bitcoin-Dev mailing list with a summary of recent changes to the
  proposal.  Changes include:

  * 32-byte public keys instead of 33-byte keys (mentioned in
    [Newsletter #59][32 byte pubkey]).

  * No support for P2SH-wrapped taproot addresses (mentioned in
    [#65][p2sh-wrapped taproot]).

  * 32-bit txin positions in the signature hash data rather than
    16-bit indexes.

  * Tagged hashes are now used in [bip-schnorr][].  They were
    previously only used in [bip-taproot][] and [bip-tapscript][].

  * The 10,000-byte and 201 non-push opcode limits have been dropped
    from [bip-tapscript][] (mentioned in [#65][tapscript resource
    limits]).

  * The maximum depth of the merkle tree has been increased from 32
    levels to 128 levels.

  Wuille's email and the updated BIPs provide rationales for each of
  these decisions as well as links to previous discussions about them.

- **Proposed default LN fee increase:** Rusty Russell proposed an
  increase in the default in-channel fees to be used by nodes, going
  from 1,000 millisatoshis (msat) plus 1 part-per-million (ppm) to 5,000
  msat plus 500 ppm.  He notes that the current defaults don't provide
  much room for allowing users to lower fees and the popularity of nodes
  currently charging higher fees indicates many users are currently not
  sensitive to fees.  His email provides a chart estimating the old and
  new costs of transferring various amounts of money in USD terms at
  $10,000 USD/BTC:

  | Amount |  Before     | After       |
  |--------|-------------|-------------|
  | 0.1c   |  0.0100001c |  0.05005c   |
  | 1c     |  0.010001c  |  0.0505c    |
  | 10c    |  0.01001c   |  0.055c     |
  | $1     |  0.0101c    |  0.1c       |
  | $10    |  0.011c     |  0.55c      |
  | $100   |  0.02c      |  5.05c      |
  | $1000  |  0.11c      |  50.05c     |

  Fellow C-Lightning maintainer ZmnSCPxj and Eclair maintainer
  Pierre-Marie Padiou indicated support for the proposal.  LND
  maintainer Olaoluwa Osuntokun believed the reasoning behind the
  proposal had several flaws and advocated instead to "educate
  prospective routing node operators on best practices, provide
  analysis tools [...], and leave it up to the market participants to
  converge on steady state economically rational fees."  As of this
  writing, discussion about the topic remains ongoing.

- **Conference summary: Cryptoeconomic Systems Summit:** this conference
  held last weekend on the MIT campus covered a variety of topics
  about ensuring cryptocurrencies are both useful and secure.  Videos
  are now available courtesy of [the DCI's YouTube channel][css vids]
  and [transcripts][css ts] for several of the talks have been provided
  by Bryan Bishop and others.  Out of the subset of talks that were
  [transcribed][css ts], we thought the following three topics might be
  of particular technical interest to the readers of this newsletter:

  - *Everything is broken* by Cory Fields ([transcript][fields ts], [video][fields vid]), a
    talk that describes how Bitcoin is at risk not just from its own
    software bugs but also from the bugs introduced into the
    libraries, operating systems, and even hardware that it depends
    upon.  Fields then looks back in time when a large number of
    certain classes of bugs were affecting another major open source
    project, Mozilla Firefox, and at that project's foresight for
    attempting to categorically eliminate some of those problems by
    starting the development ten years ago of a new programming
    language (Rust) that could provide stronger automatic guarantees.
    Finally, Fields asks the audience to contemplate initiates we
    could start now that would, over the course of the next ten years,
    help categorically eliminate some types of problems that Bitcoin
    users and developers currently need to worry about.

  - *Near misses: What could have gone wrong* by Ethan Heilman
    ([transcript][heilman ts], [video][heilman vid]), a survey of five problems in Bitcoin's
    past that could've lead to significant losses in user funds or
    user confidence.  Following the survey, Heilman asks the audience
    to consider what a worst-case software failure in Bitcoin would
    look like today, or what would've happened if one of the
    previously-encountered problems had been exploited by an attacker to
    its worst extent.  We recommend attempting this exercise: it can
    obviously emphasize the dangers that remain in Bitcoin---but it
    may also help highlight the ways in which Bitcoin is more secure
    than you initially expect.

  - *The quest for practical threshold Schnorr signatures* by Tim
    Ruffing ([transcript][ruffing ts], [video][ruffing vid]), a description of the research
    performed by the speaker and his colleagues into trying to find a
    secure, compact, practical, and flexible scheme for
    threshold-based schnorr signatures.  Ruffing first describes the
    difference between generalized threshold signatures and the
    specific case of multi-signatures.  A threshold signature allows a
    subset of a group to sign (e.g. k-of-n); multi-signatures are a
    special case of threshold signatures where the whole group signs
    (n-of-n).  Protocols like MuSig (see [Newsletter #35][musig
    libsecp256k1-zkp]) and [MSDL][] provide multi-signature signing
    compatible with [bip-schnorr][], but threshold signatures for a
    subset of signers have not been solved to the
    same degree.

    As an example of outstanding problems, Ruffing notes that the
    security proofs for existing Discrete Log Problem (DLP) based
    threshold signature schemes assume that the majority of
    potential signers are honest.  So a 2-of-3 arrangement is secure
    because the worst case you planned for would be one dishonest
    signer (which is less than a majority).  In a 6-of-9
    arrangement, you want the scheme to be secure against up to five
    dishonest signers---but five signers would constitute a majority
    and undermine the expectations in the security proof.

    Another potential problem is that previously-described protocols
    expect each participant has a secure and reliable method of
    communicating with all other participants.  Someone who can
    eavesdrop or manipulate the communication may be able to recover
    the ultimate private key that would allow them to sign any spend
    they want.  This seems solvable, but the proposed solution
    doesn't have a security proof yet.

    Ruffing concludes with a wishlist for what he'd like to see in a
    schnorr-based threshold signature scheme, including several
    stretch goals.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #15437][] removes support for [BIP61][] P2P protocol `reject`
  messages.  These were previously [announced][bip61 release note] as
  deprecated in Bitcoin Core 0.18.0 (May 2019) and will be disabled by
  default in the upcoming 0.19.0 release.  This change to remove them is
  part of the master development branch and is expected to be released
  in 0.20.0, more than a year after the initial announcement of
  deprecation covered in [Newsletter #13][pr14054] and followed up in
  Newsletters [#37][bip61 discussion] and [#38][bip61 decision].

- [Bitcoin Core #17056][] adds a `sortedmulti` [output script
  descriptor][] that sorts the pubkeys provided to it using the
  lexicographic order described in [BIP67][].  This makes it possible to
  import xpub-based descriptors for wallets that require using BIP67,
  such as the Coldcard hardware wallet in multisig mode.

- [LND #3561][] adds a new channel validation package that unifies the
  logic used to verify channels both when channel-open data is received
  from a third-party peer or when it's received from a first-party data
  source like the local Bitcoin node.  This helps address an underlying
  cause in LND of the recent vulnerabilities that affected multiple LN
  implementations (see [Newsletter #66][lnd vulns]).

- [C-Lightning #3129][] adds a new startup option `--encrypted-hsm` that
  will prompt the user to provide a passphrase that will be used to
  either encrypt the HD wallet's seed (if it's currently unencrypted) or
  decrypt it (if it's encrypted).

{% include linkers/issues.md issues="15437,17056,3561,1165,3129" %}
[lnd repo doc]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[lnd 0.8.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.0-beta
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3rc2
[32 byte pubkey]: /en/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[p2sh-wrapped taproot]: /en/newsletters/2019/09/25/#comment-if-you-expect-to-need-p2sh-wrapped-taproot-addresses
[tapscript resource limits]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[musig libsecp256k1-zkp]: /en/newsletters/2019/02/26/#musig
[MSDL]: https://eprint.iacr.org/2018/483.pdf
[pr14054]: /en/newsletters/2018/09/18/#bitcoin-core-14054
[bip61 release note]: https://bitcoincore.org/en/releases/0.18.0/#deprecated-p2p-messages
[bip61 discussion]: /en/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[bip61 decision]: /en/newsletters/2019/03/19/#bip61-reject-messages
[lnd vulns]: /en/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[taproot update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017378.html
[fields ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/everything-is-broken/
[fields vid]: https://www.youtube.com/watch?v=UDbl-2gk7n0
[heilman ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/near-misses/
[heilman vid]: https://www.youtube.com/watch?v=VAlq7vt0eIE
[ruffing ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/threshold-schnorr-signatures/
[ruffing vid]: https://www.youtube.com/watch?v=Wy5jpgmmqAg
[css ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/
[css vids]: https://www.youtube.com/channel/UCJkYmuzqAnIKn3NPg5lc0Wg/videos
[eclair 0.3.2]: https://github.com/ACINQ/eclair/releases/tag/v0.3.2
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
