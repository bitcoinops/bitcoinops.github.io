---
title: 'Bitcoin Optech Newsletter #3'
permalink: /en/newsletters/2018/07/10/
name: 2018-07-10-newsletter
type: newsletter
layout: page
lang: en
version: 1
---
This week's newsletter includes news and action items about minimum fees and
the upcoming Bitcoin Core release, a special feature on a Schnorr signature
proposal, and a write-up of the recent Building on Bitcoin conference in
Lisbon.

## Action items

- Bitcoin Core minimum relay fee may be reduced in the next major
  release.  Ensure your software doesn't make unsafe assumptions about 1
  satoshi per vbyte being the lowest possible floor.  See *News* section
  below for more information.

- Ensure your software for calculating transaction size for dynamic fees
  computes signature size accurately or, at least, uses a worst-case
  assumption of Bitcoin signatures being 72 bytes.  See *News* section
  below for more information.

- As previous newsletters announced would happen, the Bitcoin alert
  key was [released][alert released] along with a disclosure of
  vulnerabilities affecting Bitcoin Core 0.12.0 and earlier.  Altcoins
  may be affected.  If you have not yet checked your infrastructure for
  affected services, it is advised to do so now.  See [newsletter #1][]
  for more details

[alert released]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[newsletter #1]: https://bitcoinops.org/en/newsletters/2018/06/26/

## Dashboard items

- **Transaction fees remain very low:** as of this writing, fee
  estimates for confirmation 2 or more blocks in the future remain at
  roughly the level of the default minimum relay fee in Bitcoin Core.
  It's a good time to [consolidate inputs][].

[consolidate inputs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

- **Block production recovery:** following last week's news about
  flooding in China affecting miner operations, Bitcoin block production
  seems to have recovered to the expected level of about one block every
  10 minutes.

## Featured news: Schnorr signature proposed BIP

In a [post][schnorr post] to the bitcoin-dev mailing list, Pieter Wuille
submitted a [draft specification][schnorr draft] for a Schnorr-based
signature format.  The goal of the specification is to hopefully get
everyone in agreement about what Schnorr signatures will look like on
Bitcoin before work begins on an actual soft fork, so the BIP does not
propose specific new opcodes, segwit witness flags, soft fork activation
method, or anything else necessary to make this change part of the
Bitcoin consensus rules.  However, it is possible to say what this signature
format will provide if it becomes the form of Schnorr signature adopted by
Bitcoin.

[schnorr post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016203.html
[schnorr draft]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki

1. Full compatibility with existing Bitcoin private keys and public
   keys, meaning that existing HD wallets that upgrade won't need to
   generate new recovery seeds.

2. Roughly 10% smaller signatures, providing a slight increase to
   block chain capacity as Schnorr is adopted.

3. Batch verification of signatures providing a roughly 2x speedup
   over individual verification for a block full of Schnorr
   signatures.  This mainly affects nodes initially syncing or
   catching up after being offline.

4. Full compression and significantly improved privacy for multisig use
   cases, but with required interaction: an unlimited number of
   participants can create a single 33-byte public key and 64-byte
   signature from the combination of their individual public keys and
   signatures, using secure multisig with the same efficiency of
   single-sig and increasing their privacy by making multisig look like
   single-sig.  However, the scheme requires multistep interaction
   between the wallets participating in the multisig, both for creating
   the public key and the signature.

5. Additional privacy-focused usecases.  Examples include increased
   privacy for Lightning Network (LN), more private atomic swaps (either
   cross chain when both chains support Schnorr, or on the same chain as
   part of a coin mixing protocol), and fully [private signing oracles][dlc]
   (services that wait for something to happen in real life, like which
   team wins the world cup, and then provide a signature committing to
   that outcome, e.g. allowing Alice and Bob to settle a bet onchain or
   in a LN channel).  Many of these cases also improve efficiency
   compared to alternatives that use current Bitcoin script.

[dlc]: https://adiabat.github.io/dlc.pdf

One thing of note not in the BIP proposal is a method for signature
aggregation between multiple inputs in the same transaction.  This was a
desired feature that could allow consolidation transactions, coinjoins,
and other high-input transactions to be much more efficient than they
are now.  But, as the author of the proposal notes, "With the emergence of
so many ideas for improvements to Bitcoin's script execution (MAST,
Taproot, Graftroot, new sighash modes, multisignature schemes, ...)
there is simply too much to do everything at once. Since aggregation
really interacts with all other things, it seems like the better choice
to pursue later." ([source][pwuille comment])

[pwuille comment]: https://www.reddit.com/r/Bitcoin/comments/8wmj5b/pieter_wuille_submits_schnorr_signatures_bip/e1wwriq/

## News

- **[Discussion][min fee discussion] about minimum relay fee:** several
  years ago when the Bitcoin price was a fraction of its current value
  in USD terms, Bitcoin Core set the minimum relay fee to 1 satoshi per
  byte (now vbyte).  With the increase in prices and other network
  changes, several developers discussed lowering the minimum relay fee.
  Gregory Maxwell is planning to open a pull request to Bitcoin Core
  that may roughly halve the value (although the exact amount has not
  been determined yet).

    This may be included in the next major version of Bitcoin Core.  If
    so, it'll mean that you may be able to create cheaper consolidation
    transactions once the change has been well deployed.  However, it
    also means that if you don't upgrade any nodes you use for detecting
    unconfirmed transactions, they may not see unconfirmed transactions
    with low feerates unless you change the defaults.  This could affect
    the information you display to your users.  Those nodes will still
    see all confirmed transactions in valid blocks.

    Note that to lower the minimum relay fee in Bitcoin Core below its
    default, you need to change two settings.  Shown below are the two
    settings with their default values in Bitcoin Core 0.16.1; to lower
    the values, change both of them to the same value, but be aware that
    reducing them too far (perhaps to less than 1/10th the default)
    exposes you to bandwidth-wasting attacks and reduces BIP152 compact
    block efficiency for your node.

      minrelaytxfee=0.00001000
      incrementalrelayfee=0.00001000

    If your organization produces end-user software, you may wish to
    ensure that it works with transactions and fee estimations set below
    the value of 1 satoshi per byte.  Please contact Optech if you need
    more information about minimum relay fees.

[min fee discussion]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-07-05-19.22.log.html#l-24

- **Unrelayable transactions:** At least two major services were
  identified as creating transactions with feerates below the current
  minimum due to a misunderstanding about the maximum size of a Bitcoin
  signature, which is 72 bytes.  Bitcoin signatures vary in size, with
  half of all randomly-generated signatures being 72 bytes, slightly
  less than half being 71 bytes, and the small remainder being 70 bytes
  or smaller.

    At a guess, the developers of some software looked at a
    randomly-selected signature, saw that it was 71 bytes, and assumed
    all signatures would be 71 bytes.  However, when the software
    generates a 72-byte signature, this makes the actual size of the
    transaction one byte larger per signature than the estimated size,
    causing the fees paid per byte to be slightly lower than expected.

    This didn't cause significant problems when fee estimates were high,
    but now that fee estimates are near the default minimum relay fee of
    1 satoshi per byte, any transactions created with a fee slightly
    below that may not be relayed to miners and so remain unconfirmed
    indefinitely.

    It is recommended that organizations check their software to ensure
    it, at the least, makes a worst-case assumption of signatures being
    72 bytes.

- **Upcoming Bitcoin Core 0.17 feature freeze:** next week developers
  [plan][#12624] to stop merging new features for the next major
  version of Bitcoin Core.  The features already present will be further
  tested and documented, translations will be updated, and other parts
  of the release process followed.  If your organization will be
  depending on a feature in the next six months, now could be your last
  chance to ensure it's part of 0.17.  Features currently not yet merged
  but likely to be added to Bitcoin Core 0.17.0 include:

    - `scantxoutset` RPC that allows searching the unspent transaction
      output set for addresses or scripts.  Intended for use with
      address sweeping, e.g. finding funds that you own and bringing
      them into one of your current wallets.

    - [BIP174][] Partially-Signed Bitcoin Transactions (PSBTs) support,
      a protocol for exchanging information about Bitcoin transactions
      between wallets to facilitate better interoperability between
      multisig wallets, hot/cold wallets, coinjoins, and other
      cooperating wallets.

    - [Delayed transaction sending by network group][#13298], a proposal that is
      hoped will make it harder for spy nodes to determine which client
      first broadcast a transaction (indicating it may have been the
      spender).

[#12624]: https://github.com/bitcoin/bitcoin/issues/12624
[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[#13298]: https://github.com/bitcoin/bitcoin/issues/13298

- **Efficient reimplementation of Electrum Server:** in an announcement
  to the bitcoin-dev mailing list this week was a claim that a
  Rust-based reimplementation of Electrum server is much more efficient
  than the Python version.  Optech has not performed any testing on this
  and can't confirm, but Electrum server is known to be used by several
  Bitcoin businesses both internally and hosted on behalf of their
  customers, so some readers of this newsletter may wish to investigate.

## Building on Bitcoin

[**Building on Bitcoin**][bob website] was a Bitcoin technology conference that took
place in Lisbon last week. It was well attended by both Bitcoin protocol
developers and applications engineers.  A [video][bob video]
is available, as are several [transcripts][bob transcripts] by Bitcoin
developer Bryan Bishop (kanzure).

[bob website]: https://building-on-bitcoin.com/
[bob video]: https://www.youtube.com/watch?v=XORDEX-RrAI
[bob transcripts]: http://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/

The following talks may be of particular interest to Bitcoin Optech
companies:

- [**Merchant adoption**][bitrefill video] - [Sergej Kotliar][sergej], CEO of
  Bitrefill gave a personal account of the fee market spike at the end of last
  year, important UX considerations for Bitcoin and Lightning payments, and
  Bitrefill's experiences in integrating Lightning.  This talk was
  fascinating due to the real-world empirical data that Sergej shared and his
  first-hand experience of fees, scaling, and Lightning.

[bitrefill video]: https://www.youtube.com/watch?v=Cpid31c6HZc&feature=youtu.be&t=8m49s
[sergej]: https://twitter.com/ziggamon

- [**Designing Lighning Wallets for the Bitcoin Users**][lightning ux video] -
  [Patrícia Estevão][patricia] gave a talk about UX considerations when
  extending Bitcoin wallets to support Lightning payments.  An interesting
  talk for any business that is beginning to integrate Lightning payments into
  an existing Bitcoin product.

[lightning ux video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=6042
[patricia]: https://twitter.com/patestevao

- [**Blind Signatures in Sciptless Scripts**][blind signatures video] -
  [Jonas Nick][jonas] spoke about using Schnorr signatures as the basis
  of doing blind coinswaps (where a server cannot link coins) or exchanging
  'ecash tokens' on Bitcoin or Lightning, among other things.  This talk
  presents leading edge thinking about what's possible with scriptless
  scripts and the ideas presented are quite a long way from being implementable
  on Bitcoin.  However, it is interesting to see some of the new applications
  that will be unlocked by adopting Schnorr signatures into Bitcoin.

[blind signatures video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=25479
[jonas]: https://twitter.com/n1ckler

- [**LN story**][ln video] - [Fabrice Drouin][fabrice] presented a history
  of the development of the Lightning Network.  A lot of interesting background
  for anyone planning to integrate and use Lightning payments.

[ln video]: https://www.youtube.com/watch?time_continue=2881&v=Cpid31c6HZc
[fabrice]: https://twitter.com/acinq_co

- [**CoinJoinXT ... and other techniques for deniable transfers**][coinjoin video] -
  [Adam Gibson][adam] talked about CoinJoinXT, a method for improving privacy in
  Bitcoin by mixing payments and breaking transaction graph analysis.  Many wallets
  are planning to implement some form of CoinJoin, so Bitcoin engineers should be at
  least familiar with the high-level concepts.

[coinjoin video]: https://www.youtube.com/watch?v=XORDEX-RrAI&feature=youtu.be&t=23359
[adam]: https://twitter.com/waxwing__

