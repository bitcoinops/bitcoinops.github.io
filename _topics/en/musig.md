---
title: MuSig

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **MuSig** is a protocol for aggregating public keys and signatures for
  the schnorr digital signature algorithm.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: MuSig paper
      link: https://eprint.iacr.org/2018/068

    - title: MuSig2 paper
      link: https://eprint.iacr.org/2020/1261

    - title: MuSig-DN paper
      link: https://eprint.iacr.org/2020/1057.pdf

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Optech executive briefing: the next soft fork"
    url: /en/2019-exec-briefing/#the-next-softfork
    date: 2019-06-14

  - title: Schnorr signatures and musig
    url: /en/schorr-taproot-workshop/#12-musig
    date: 2019-10-29

  - title: BLS signatures based on the MuSig construction
    url: /en/newsletters/2018/08/07/#library-announced-for-bls-signatures

  - title: "2018 year-in-review: publication of MuSig protocol"
    url: /en/newsletters/2018/12/28/#january

  - title: Libsecp256k1-zkp supports MuSig key and signature aggregation
    url: /en/newsletters/2019/02/26/#schnorr-ready-fork-of-libsecp256k1-available

  - title: Extensions to PSBTs to help make them compatible with advanced protocols
    url: /en/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts

  - title: "Breaking Bitcoin presentation: secure protocols on bip-taproot"
    url: /en/newsletters/2019/06/19/#secure-protocols-on-bip-taproot

  - title: LN gossip update proposal to use MuSig
    url: /en/newsletters/2019/07/17/#gossip-update-proposal

  - title: MuSig and attacks based on Wagner's algorithm
    url: /en/newsletters/2019/11/27/#schnorr-taproot-updates

  - title: Composable MuSig---concerns about safely using signer sub-groups
    url: /en/newsletters/2019/12/04/#composable-musig

  - title: Presentations and discussions about musig-style multiparty signatures
    url: /en/newsletters/2020/07/01/#schnorr-signatures-and-multisignatures

  - title: MuSig2 paper published
    url: /en/newsletters/2020/10/21/#musig2-paper-published

  - title: "2020 year in review: MuSig2"
    url: /en/newsletters/2020/12/23/#musig2

  - title: "Benchmark: 1 million signers with MuSig"
    url: /en/newsletters/2021/06/30/#possible-amount-of-signatures-with-musig

  - title: Overview of MuSig1, MuSig2, and MuSig-DN
    url: /en/newsletters/2021/08/04/#using-multisignatures

  - title: "Summary of LN developer conference, including discussion of MuSig2"
    url: /en/newsletters/2021/11/10/#ln-summit-2021-notes

  - title: "Proposal to use MuSig2 in the LN gossip protocol"
    url: /en/newsletters/2022/03/30/#minor-update

  - title: "Proposed BIP for MuSig2"
    url: /en/newsletters/2022/04/13/#musig2-proposed-bip

  - title: MuSig2 implementation notes
    url: /en/newsletters/2022/05/04/#musig2-implementation-notes

  - title: "LND #6361 adds support for MuSig2 signing"
    url: /en/newsletters/2022/05/04/#lnd-6361

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Multisignatures
    link: topic multisignature

  - title: Schnorr signatures
    link: topic schnorr signatures
---
MuSig allows multiple users each with their own private key to create a
combined public key that's indistinguishable from any other schnorr
pubkey, including being the same size as a single-user pubkey.  It
further describes how the users who created the pubkey can work
together to securely create a [multisignature][topic multisignature] corresponding to the pubkey.
Like the pubkey, the signature is indistinguishable from any
other schnorr signature.

Compared to traditional script-based multisig, MuSig uses less block
space and is more private, but it also requires more interactivity
between the participants.  As of August 2021, there are three protocols
in the MuSig family:

- **MuSig** (also called MuSig1), which should be simple to implement
  but which requires three rounds of communication during the signing
  process.

- **MuSig2**, also simple to implement.  It eliminates one round of
  communication and allows another round to be combined with key
  exchange.  That can allow using a somewhat similar signing
  process to what we use today with script-based multisig.  This does
  require storing extra data and being very careful about ensuring your signing software or
  hardware can't be tricked into unknowingly repeating part of the
  signing session.

- **MuSig-DN** (Deterministic Nonce), significantly more complex to
  implement.  Its communication between participants can't be combined
  with key exchange, but it has the advantage that it's not vulnerable to the repeated
  session attack.

{% include references.md %}
