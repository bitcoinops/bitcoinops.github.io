---
title: 'Bitcoin Optech Newsletter #47'
permalink: /en/newsletters/2019/05/21/
name: 2019-05-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the bip-anyprevout soft fork proposal, summarizes
a few technical talks from the Magical Crypto Friends conference, and
includes our regular sections on bech32 sending support and notable
changes to popular Bitcoin infrastructure projects.

{% include references.md %}

## Action items

*None this week.*

## News

- **Proposed anyprevout sighash modes:** two weeks ago, Anthony Towns
  [posted][email bip-anyprevout] a proposed BIP to the Bitcoin-Dev and Lightning-Dev mailing
  lists for consideration.  The idea, [bip-anyprevout][], provides two
  new signature hashing (sighash) modes that allow a signature to commit
  to fewer details about the funds being spent than the default
  [bip-taproot][] and [bip-tapscript][] sighash mode.  This enables the
  functionality previously described by [BIP118][] with modification so
  that it works with Taproot and reduces the risk of accidental misuse.  One of
  the new sighash modes is
  directly compatible with the proposed [Eltoo][] layer for LN,
  requiring only modifications for Taproot and the addition of a
  *chaperone signature* (described later).  A second sighash mode
  commits to more data than necessary for Eltoo in a way that may make
  it useful for atypical commitments in Eltoo or for use in other protocols.

    A significant advantage of this proposal over BIP118 noinput is that
    it can make use of Taproot cooperative spends, allowing the two or
    more parties to an LN channel or other contract protocol to optionally spend
    their funds without revealing any of the contract terms (including
    that anyprevout was in use).

    For a quick look at anyprevout, we consider it in the context of a
    two-party Eltoo-based LN channel.  As a reminder, the key feature of
    Eltoo is that each balance change in a channel (state update) can be
    spent by *any* later state update, so there's no risk of publishing an
    old state to the block chain like there is with the current
    penalty-based LN channels.  Eltoo calls this capability *rebinding*
    and BIP118 proposed to make rebinding available by allowing
    signatures to skip committing to the input part of the spending
    transaction---allowing anyone to modify that part of the
    transaction to bind any later state they knew about.

    The `SIGHASH_ANYPREVOUTANYSCRIPT` mode (any previous output, any
    script) defined by bip-anyprevout works similarly to BIP118 noinput,
    with the following changes.  To use anyprevoutanyscript, the public
    key to which a signature is compared will need to use a special
    prefix (0x00 or 0x01; not to be confused with the pubkeys used for
    [bip-taproot's][bip-taproot] output key that uses the same prefix in
    a different context).  Additionally, the script being evaluated will
    need to contain at least one signature that doesn't use
    anyprevoutanyscript or the other new sighash mode described later.
    This non-anyprevout signature is called the *chaperone signature*
    because, under reasonable assumptions, it prevents an anyprevout
    signature from being misused.  (See [Newsletter #34][] for details
    about the replay problem.)  With the correct prefix and a chaperone
    signature, anyprevoutanyscript allows the signature to skip
    committing to the identifier for output being spent (the outpoint),
    that previous output's scriptPubKey, and the hash of the executed
    taproot leaf (tapleaf).  The transaction digest to which the signature commits still includes
    some details about the prevout, such as its bitcoin value.

    Additionally, bip-anyprevout also defines another sighash mode:
    `SIGHASH_ANYPREVOUT` that also requires the same special pubkey
    prefix and chaperone signature, but it includes the prevout's
    scriptPubKey and tapleaf hash in the signature.  Whereas
    anyprevoutanyscript can allow Eltoo-like rebinding where any later
    state can bind to any earlier state (but earlier states can't bind
    to later states), there may be alternative protocols (and times
    within the Eltoo protocol) where the participants want to ensure
    that state *n* can only bind to state *n-1* and not any other state.

    The proposal has begun receiving [feedback][anyprevout list] on the
    mailing lists, so we'll provide updates in subsequent newsletters
    summarizing any significant discussions.

- **Talks of technical interest at Magical Crypto Friends conference:**
  Bryan Bishop provided [transcripts][mcf transcripts] of about a dozen
  talks and panels from the MCF conference two weekends ago, and the
  conference organizers have uploaded most [videos][mcf vids].  Although
  only one of the talks described any specific new developments, several
  of them did discuss details and implications of technology such as
  confidential transactions, taproot, schnorr, and other ideas related
  to Bitcoin.  We found the following talks particularly interesting:

    - A [talk][mcf andytoshi] by Andrew Poelstra about the cryptography used in
      cryptocurrencies.  In particular, he focuses on the difficulty of
      building systems where *everything* needs to be done correctly in
      order to resist attack.

    - A [panel][mcf nonet] by Rodolfo Novak, Elaine Ou, Adam
      Back, and Richard Myers about using Bitcoin without direct access
      to the Internet.  Discussion topics included satellite-based block
      propagation, mesh networking, amateur radio, and physically
      carrying data (sneakernets) and how they can make Bitcoin more
      robust for current users and more accessible for users in areas
      with limited network access.  We found particularly interesting a
      side discussion about the security of relaying Bitcoin data---in
      short, the Bitcoin protocol is already designed to trustlessly
      accept data from random peers, so non-net relay doesn't
      necessarily change the trust model.

   - A [panel][mcf future ln] by Will O'Beirne, Lisa Neigut, Alex Bosworth with
     moderation by Leigh Cuen discussing the future of LN, mostly the
     short-term and medium-term conclusion of current development
     efforts surrounding the LN 1.1 specification.  There are no hyped
     claims in this discussion, but a simple description of how LN can be
     expected to improve in ways that make it easier for users and
     businesses to adopt.

## Bech32 sending support

*Week 10 of 24 in a [series][bech32 easy] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/10-snooze-lose.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15006][] extends the `createwallet` RPC with a new
  `passphrase` parameter that allows creating a new wallet that's
  encrypted by default.  Existing wallets can still be converted to
  encrypted with the `encryptwallet` RPC.

- [Bitcoin Core #15870][] changes how the `importwallet`,
  `importpubkey`, `importaddress`, and `importprivkey` RPCs interact
  with pruning.  Previously they failed if pruning was enabled.
  However, pruning can be configured for manual operation
  (`prune=1`) or be set to a value larger than the current size of the
  block chain (e.g. `prune=450000`), providing cases where pruning is
  enabled but all blocks may still be present.  With this merge, the
  calls only fail if blocks are actually missing because of pruning.
  Alternatively, users can call the `importmulti`
  RPC that will allowing importing any keys or other data even if blocks
  have been pruned as long as the data's creation time (timestamp) is
  within the range of blocks that haven't been pruned yet.

- [Bitcoin Core #14802][] speeds up the `getblockstats` RPC more than
  100x (as measured by Optech) by using chainstate undo data---the data
  that's used to rollback the ledger to a previous state during a block
  chain reorganization.  This also removes the RPC's dependency on the
  transaction index (txindex).

- [Bitcoin Core #14047][] and [Bitcoin Core #15512][] add functions
  required for the encrypted [v2 transport protocol][] described in
  [Newsletter #39][].  This is only a small subset of the overall
  changes required; see primary [PR #14032][Bitcoin Core #14032] for
  more details.

- [C-Lightning #2631][] extends the pylightning utility with three new
  methods: `autoclean` configures automatic deletion of expired invoices
  (by default one day after they expired).  `check` determines whether a
  command is valid without running it.  `setchannelfee` allows setting
  the fee for routed payments, either a base fee added to any routed
  payment or a percentage fee that is applied proportionally to the
  payment amount.

- [C-Lightning #2627][] extends pylightning with a `deleteinvoice`
  method that deletes all invoices that expired before the specified
  time.

{% include linkers/issues.md issues="15006,15870,14802,14047,2631,2627,15512,14032" %}
[mcf transcripts]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/
[v2 transport protocol]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016806.html
[anyprevout list]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-May/001992.html
[mcf vids]: https://www.youtube.com/playlist?list=PLWqtMh0tDnEGBHDS8CalOpkVZhlIgRlAC
[mcf andytoshi]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/crypto-in-cryptocurrency/
[mcf nonet]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/bitcoin-without-internet/
[mcf future ln]: https://diyhpl.us/wiki/transcripts/magicalcryptoconference/2019/ln-present-and-future-panel/
[email bip-anyprevout]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016929.html
