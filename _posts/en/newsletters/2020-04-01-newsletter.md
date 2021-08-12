---
title: 'Bitcoin Optech Newsletter #91'
permalink: /en/newsletters/2020/04/01/
name: 2020-04-01-newsletter
slug: 2020-04-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to make statechains
deployable on Bitcoin without consensus changes, summarizes a discussion
about a schnorr nonce generation function that helps protect against
differential power analysis, and links to a proposed update to BIP322
generic `signmessage`.  Also included is our regular section about
notable changes to popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Implementing statechains without schnorr or eltoo:** statechains are
  a [proposed][statechain overview] offchain system for allowing a user (such as Alice) to
  delegate the ability to spend a UTXO to another user (Bob), who can
  then further delegate the spending authority to a third user (Carol),
  etc.  The offchain delegation operations are all performed with the
  cooperation of a trusted third party who can only steal funds if they
  collude with a delegated signer (such as previous delegates Alice or
  Bob).  A delegated signer can always spend the UTXO onchain without
  needing permission from the trusted third party, arguably making
  statechains less trusted than federated [sidechains][topic sidechains].
  Because anyone who was ever a delegate can
  trigger an onchain spend, statechains are designed to use the
  [eltoo][topic eltoo] mechanism to ensure an onchain spend by the most
  recent delegate (Carol) can take precedence over spends by previous
  delegates (Alice and Bob), assuming the trusted third party hasn't
  colluded with a previous delegate to cheat.

    This week, Tom Trevethan [posted][trevethan statechains] to the
    Bitcoin-Dev mailing list about two modifications of the
    statechain design that could allow it to be used with the current
    Bitcoin protocol rather than waiting for proposed soft fork changes
    such as [schnorr signatures][topic schnorr signatures]
    and [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]:

    1. Replace the eltoo mechanism (which requires either [BIP116][]
       `SIGHASH_NOINPUT` or [bip-anyprevout][] `SIGHASH_ANYPREVOUT`)
       with a decrementing locktime similar to that proposed for
       [duplex micropayment channels][].  E.g., when Alice receives
       control over a statechain UTXO, a timelock would prevent her from
       being able to unilaterally spend it onchain for 30 days; when
       Alice transfers the UTXO to Bob, a timelock would restrict him
       for only 29 days---this gives a spend by Bob precedence over a
       spend by Alice.  The downside of this approach is that delegates
       might need to wait a long time before being able to spend their
       funds without permission from the trusted third party.

    2. Replace the 2-of-2 schnorr multisig between the trusted third
       party and the current delegate (using an [adaptor
       signature][scriptless scripts]) with a single-sig using [secure
       multiparty computation][mpc].  The main downside of this approach
       is an increased complexity that makes security review harder.

    Several people replied to the thread with comments and suggested
    alternatives.  Also [discussed][patent discussion] was a previous
    [patent application][trevethan application] by Trevethan related to
    offchain payments secured by a trusted third party using
    decrementing timelocks and multiparty ECDSA.

- **Mitigating differential power analysis in schnorr signatures:**
  Lloyd Fournier started a [discussion][fournier dpa] on the Bitcoin-Dev
  mailing list about the proposal described in [Newsletter #87][news87
  bip340 update] to update the [BIP340][] specification for schnorr
  signatures with a recommended nonce generation function that claims to
  be more resistant against [differential power analysis][dpa].  A power
  analysis attack involves monitoring the amount of electricity a hardware wallet
  uses when it generates different signatures in order to potentially
  learn what private key was used (or to reveal enough information about the key that effective brute
  forcing becomes possible).  Fournier questioned the utility of
  combining the private key plus the randomness using an xor
  operation rather than a more standard method of hashing the private
  key with the randomness.

    BIP340 co-author Pieter Wuille [replied][wuille dpa] with an
    explanation: in key and signature aggregation where
    a mathematical relationship is created between the private keys of
    cooperating users, the attacker---if he's one of the cooperating
    users---may be able to combine knowledge of his private key with
    information learned from power analysis of other users' signature generation in order to learn about the
    other users' private keys.  It is believed that this
    attack would be easier to execute when looking at the power
    consumption of a relatively complex hash function like SHA256
    compared to a relatively trivial function like xor (binary
    addition).  For more information, Wuille links to a
    [discussion][nonce function discussion] between himself and several
    other Bitcoin cryptographers.

- **Proposed update to BIP322 generic `signmessage`:** after starting a
  discussion a few weeks ago about the future of the [generic
  signmessage][topic generic signmessage] protocol (see [Newsletter
  #88][news88 bip320]), Karl-Johan Alm has [proposed][alm bip322 update] a
  simplification that removes the ability to bundle together several
  signed messages for different scripts and also removes an unused
  abstraction that could've made it easier to extend the protocol for
  something similar to [BIP127][] proof of reserves.  Anyone with
  feedback on the change is encouraged to either reply to the mailing
  list thread or to the [PR updating the draft BIP][BIPs #903].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #4078][] adds an `estimatemode` configuration setting (`CONSERVATIVE`
  or `ECONOMICAL`) which is used to tailor the fee estimation approach when
  retrieving fee estimates from an underlying `bitcoind` backend.

{% include references.md %}
{% include linkers/issues.md issues="903,4078,3865" %}
[trevethan statechains]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017714.html
[statechain overview]: https://medium.com/@RubenSomsen/statechains-non-custodial-off-chain-bitcoin-transfer-1ae4845a4a39
[duplex micropayment channels]: https://tik-old.ee.ethz.ch/file//716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[mpc]: https://en.wikipedia.org/wiki/Secure_multi-party_computation
[scriptless scripts]: https://github.com/ElementsProject/scriptless-scripts
[fournier dpa]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017709.html
[wuille dpa]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017711.html
[news87 bip340 update]: /en/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[dpa]: https://en.wikipedia.org/wiki/Power_analysis#Differential_power_analysis
[nonce function discussion]: https://github.com/sipa/bips/issues/195
[alm bip322 update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017712.html
[news88 bip320]: /en/newsletters/2020/03/11/#bip322-generic-signmessage-progress-or-perish
[patent note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017741.html
[patent discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017742.html
[trevethan application]: https://patents.google.com/patent/US20200074464A1
