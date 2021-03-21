---
title: 'Bitcoin Optech Newsletter #141'
permalink: /en/newsletters/2021/03/24/
name: 2021-03-24-newsletter
slug: 2021-03-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a technique for signature delegation
under Bitcoin's existing consensus rules, summarizes a discussion about
taproot's effect on Bitcoin's resistance to quantum cryptography, and
announces a series of weekly meetings to help activate taproot.
Also included are our regular sections describing notable changes to
services and client software, new releases and release candidates, and
notable changes to popular Bitcoin infrastructure software.

## News

- **Signing delegation under existing consensus rules:** Imagine Alice
  wants to give Bob the ability to spend one of her UTXOs without
  immediately creating an onchain transaction or giving him her private
  key.  This is called *delegation* and it's been discussed for years,
  perhaps most notably in recent times as part of the [graftroot
  proposal][].  Last week, Jeremy Rubin [posted][rubin delegation] to
  the Bitcoin-Dev mailing list a description of a technique to
  accomplish delegation using Bitcoin today.

    Let's say Alice has `UTXO_A` and Bob has `UTXO_B`.  Alice creates a
    partially signed transaction spending both `UTXO_A` and `UTXO_B`.
    Alice signs for her UTXO using the sighash flag [SIGHASH_NONE][],
    which prevents the signature from committing to any of the
    transaction's outputs.  This gives the owner of the other input in
    the transaction---Bob---unilateral control over the choice of
    outputs, using his signature with the normal `SIGHASH_ALL` flag to
    commit to those outputs and prevent anyone else from modifying the
    transaction.  By using this dual-input `SIGHASH_NONE` trick, Alice
    delegates to Bob the ability to sign for her UTXO.

    This technique appears to be mainly of theoretical interest.  There
    are other proposed delegation techniques---including graftroot,
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify], and
    [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]---that would
    likely be superior in several ways, but only this technique is
    currently usable on mainnet for anyone who wants to experiment with
    it.

- **Discussion of quantum computer attacks on taproot:**
  the original Bitcoin software provided two ways to receive bitcoin:

  - *Pay-to-Public-Key (P2PK)* implemented the simple and clear method
    described in the [original Bitcoin paper][] of receiving bitcoins to
    a public key and allowing those coins to be spent by a signature.  The
    Bitcoin software used this by default when the public key material
    could be handled entirely by software.

  - *Pay-to-Public-Key-Hash (P2PKH)* added a layer of indirection,
    receiving bitcoins to a hash digest that committed to the public key
    to be used.  To spend the coins, the public key would need to be
    published alongside the signature, making the 20 bytes dedicated to
    the hash digest an overhead cost.  This was used by default when the
    payment information might need to be handled by a person, e.g. an
    address that could be copied and pasted.

  Nakamoto never described why he implemented both methods, but it's
  widely believed that he added the hash indirection in order to make
  Bitcoin addresses smaller so that they could be communicated more
  easily.  Public keys in the original Bitcoin implementation were 65
  bytes, but address hashes were only 20 bytes.

  In the decade since, there have been a number of developments.  To
  make certain multisig protocols [simple and secure by default][bech32
  address security], it was determined that scripts for multiparty
  protocols should probably use a 32-byte commitment.  Bitcoin developers also
  learned about previously known techniques that could compress a public
  key down to 33 bytes---later describing how to [optimize][news48 oddness] that to 32 bytes.
  Finally, [taproot's primary innovation][news27 taproot] showed that a
  32-byte public key could commit to a script with [security][news87
  fournier proof] similar to that of a 32-byte hash.  All of this means
  that it no longer changes the amount of address data people have to
  communicate whether they use a hash or a public key---it's 32 bytes
  either way if they want a universally applicable address format.
  However, directly using public keys still eliminates the extra
  bandwidth and storage resulting from hash indirection.  If every
  payment went to a public key instead of a 32-byte hash, it  would save
  about 13 gigabytes of block chain space per year.  <!-- 32 bytes *
  8000 inputs per block * 52416 blocks per year --> The [BIP341][]
  specification of taproot describes space savings as the reason it
  accepts payments to public keys in the P2PK style instead of hashes in
  the P2PKH style.

  But P2PKH hash indirection does have one advantage: it can hide keys
  from public view until they're needed to authorize a spend.  This
  means an adversary who has the ability to compromise the security of a public key
  might not be able to start using that ability until a transaction is
  broadcast, and they may lose the ability to steal funds controlled by
  that key once the transaction is confirmed to a certain depth.  This
  limits the amount of time available for their attack and means a slow
  attack might not work.  Although this has previously been discussed at
  length in the context of taproot's choice to directly use public keys
  in the P2PK style (see [1][tap qc1], [2][tap qc2], and newsletters
  [#70][news70 qc] and [#86][news86 qc]), it was the subject of [renewed
  discussion][dashjr quantum] this week on the Bitcoin-Dev mailing list
  after the publication of an [email][friedenbach post] opposing taproot
  out of fear that we could see a quantum computer powerful enough to
  attack Bitcoin-style public keys "as soon as the end of the decade."

  None of the participants in the mailing list discussion said they also
  opposed taproot, but they did examine the argument's premises, discuss
  alternatives, and evaluate what tradeoffs would be implied by those
  alternatives.  A selection of those conversations are summarized below:

    - *Hashes not currently doing a good job at QC resistance:*
      as of a [2019 survey][wuille stealable], an attacker with a
      powerful QC and nothing else besides a copy of the Bitcoin block
      chain could steal over 1/3 of all bitcoins.  Most of those would
      be the result of users [reusing addresses][topic output linking],
      a discouraged practice---but one that seems unlikely to go away
      soon.

        Additionally, discussion participants pointed out that anyone
        who shares their individual public keys or [BIP32][] extended
        public keys (xpubs) with third parties would also be at risk
        from a powerful QC if their public keys leaked.  This would
        likely include most bitcoins stored with a hardware wallet or in
        an LN payment channel.  In short, it's possible that even though
        we almost universally use P2PKH-style hashed public keys today,
        nearly all bitcoins could be stolen by a powerful QC with access
        to public or third-party data.  That implies that the choice to
        use P2PK-style non-hashed public keys with taproot doesn't
        significantly change Bitcoin's current security model.

    - *Taproot improvement in post-QC recovery at no onchain cost:*
      if Bitcoiners learn that a powerful QC has manifested, or
      soon will, they can reject any taproot key-path spends---the type
      of spend where only a single signature is used.  However, a user
      who prepares ahead when creating their taproot address can also
      spend bitcoins received to that address using a script-path spend.
      In that case, the taproot address commits to a hash of the
      [tapscripts][topic tapscript] the user wants to use.  That hash
      commitment can be used as part of a [scheme][ruffing scheme] to
      transition to a new cryptographic algorithm that's safe against
      QCs, or---if such an algorithm is standardized for Bitcoin before
      QCs become a threat---it can allow the owner of the bitcoins to
      immediately transition to the new scheme.  This does only work if
      individual users create backup tapscript spending paths, if they
      don't share any public keys (including BIP32 xpubs) involved in
      those backup paths, and if we learn about a powerful QC before it
      does too much damage to Bitcoin.

    - *Is the attack realistic?*  One respondent thought a fast QC by the
      end of the decade [was][fournier progress] "on the wildly
      optimistic side of projected rate of progress."  Another
      [noted][towns parallelization] it was a "fairly straightforward
      engineering challenge" to turn the design for a single slow QC
      into a farm of QCs that could work in parallel, achieving results
      in a fraction of the time---making any protection from P2PKH-style
      hash indirection irrelevant.  A third respondent
      [proposed][harding bounty] constructing special Bitcoin addresses
      that could only be spent from by someone making progress on fast
      QCs; users could voluntarily donate bitcoins to the addresses to
      create an incentivized early warning system.

    - *We could add a hash-style address after taproot is activated:* if
      a significant number of users really do think the sudden
      appearance of a powerful QC is a threat, we could use a follow-up
      soft fork to [add][dashjr quantum] an alternative P2PKH-style taproot
      address type that uses hashes.  However, this has consequences
      that caused several respondents to oppose it:

        - It'll create confusion

        - It'll use more block space

        - It [reduces][poelstra anon] the size of taproot's anonymity
          set, both directly and when protocols such as [ring signature
          membership proofs][nick ring] or [Provisions][] are being used

    - *Bandwidth/storage costs versus CPU costs:* it's [possible][rubin
      recovery] to eliminate the extra 32-byte storage overhead from
      hash indirection by deriving the public key from a signature and
      the transaction data it signs, a technique called *key recovery*.
      Again, this was opposed.  Key recovery requires a [significant amount of CPU][corallo
      recovery overhead] that would slow down nodes and also prevents
      the use of schnorr batch validation that can make historic block
      verification up to three times faster.  It also [makes][poelstra
      slowdowns] anonymous membership proofs and related techniques both
      harder to develop and much more CPU intensive.  There
      [may][poelstra patent story] also be a [patent][US7215773B1] issue.

  As of this writing, it appears the mailing list discussion has
  concluded without any obvious loss of community support for taproot.
  As researchers and businesses continue improving the state of the art
  in quantum computing, we expect to see future discussions about how to
  best keep Bitcoin secure.

- **Weekly taproot activation meetings:** ten weekly meetings to discuss
  details related to activating [taproot][topic taproot] have been
  scheduled for each Tuesday at 19:00 UTC in the
  [##taproot-activation][] IRC channel, with the first
  [meeting][activation meeting log] occurring yesterday (March 23rd).

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.10.0-rc1][C-Lightning 0.10.0] is a release candidate
  for the next major version of this LN node software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #20861][] BIP 350: Implement Bech32m and use it for v1+ segwit addresses FIXME:Xekyo

- [Bitcoin Core #21141][] updates the `-walletnotify` configuration
  setting that calls a user-specified command each time a transaction is
  seen that affects a loaded wallet.  Two new placeholders are added to
  the arguments that can be passed to the command, `%b` for the hash of
  a block containing the transaction and `%h` for the height of the
  block.  Both are set to defined values for unconfirmed
  transactions.

- [C-Lightning #4428][] deprecates the `fundchannel_complete` RPC's
  acceptance of txids, requesting instead that a [PSBT][topic psbt] be
  passed.  The PSBT can be checked to ensure it contains the funding
  output, eliminating a [problem][c-lightning #4416] where a user who
  passes incorrect data can lose the ability to recover their funds.

- [C-Lightning #4421][] Experimental option option_shutdown_wrong_funding: help me, I screwed up! FIXME:dongcarl (suggestion: link to last week's newsletter about this topic)

- [LND #5068][] makes available a number of new configuration options
  for limiting how much network gossip information LND processes.  This
  can help on systems with limited resources.

- [Libsecp256k1 #831][] implements an algorithm that can speed up
  signature verification by 15%. It can also reduce by 25% the amount of
  time it takes to generate signatures while still using a constant-time
  algorithm that maximizes side-channel resistance.  It additionally removes some of
  Libsecp256k1's dependencies on other libraries.  See [Newsletter
  #136][news136 safegcd] for more information about this optimization.

- [BIPs #1059][] adds [BIP370][] specifying version 2 PSBTs as
  previously discussed on the mailing list (see [Newsletter
  #128][news128 psbtv2]).

<!-- FIXME:harding add topic links -->
{% include references.md %}
{% include linkers/issues.md issues="20861,21141,4428,4416,4421,1059,5064,5068,831" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0rc1
[news136 safegcd]: /en/newsletters/2021/02/17/#faster-signature-operations
[graftroot proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[original bitcoin paper]: https://bitcoin.org/bitcoin.pdf
[bech32 address security]: /en/bech32-sending-support/#address-security
[news48 oddness]: /en/newsletters/2019/05/29/#move-the-oddness-byte
[news27 taproot]: /en/newsletters/2018/12/28/#taproot
[news87 fournier proof]: /en/newsletters/2020/03/04/#taproot-in-the-generic-group-model
[dashjr quantum]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018641.html
[friedenbach post]: https://freicoin.substack.com/p/why-im-against-taproot
[wuille stealable]: https://twitter.com/pwuille/status/1108097835365339136
[ruffing scheme]: https://gist.github.com/harding/bfd094ab488fd3932df59452e5ec753f
[fournier progress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018658.html
[harding bounty]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018648.html
[provisions]: https://eprint.iacr.org/2015/1008
[nick ring]: https://twitter.com/n1ckler/status/1334240709814136833
[poelstra anon]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018667.html
[rubin recovery]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018643.html
[corallo recovery overhead]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018644.html
[towns parallelization]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018649.html
[poelstra slowdowns]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018667.html
[poelstra patent story]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018646.html
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[activation meeting log]: http://gnusha.org/taproot-activation/2021-03-23.log
[news128 psbtv2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[news70 qc]: /en/newsletters/2019/10/30/#why-does-hashing-public-keys-not-actually-provide-any-quantum-resistance
[news86 qc]: /en/newsletters/2020/02/26/#could-taproot-create-larger-security-risks-or-hinder-future-protocol-adjustments-re-quantum-threats
[tap qc1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015620.html
[tap qc2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[rubin delegation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018615.html
[sighash_none]: https://btcinformation.org/en/developer-guide#term-sighash-none
[US7215773B1]: https://patents.google.com/patent/US7215773B1/en
