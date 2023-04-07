---
title: Multisignature

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - 2pECDSA
  - Two-Party ECDSA (2pECDSA)

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements
  - Fee Management

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Multisignatures** are digital signatures created using two or more
  private keys which can be verified using only a single public key
  and a single signature.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## ##################################################################### ##
## NOTE: don't include things specific to MuSig; put those in the MuSig  ##
## topic, which we link to in the see_also section                       ##
## ##################################################################### ##
## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Discussion of multisignatures and threshold signatures
    url: /en/newsletters/2020/07/01/#schnorr-signatures-and-multisignatures

  - title: Mitigating power analysis attacks, including against multisignature schemes
    url: /en/newsletters/2020/04/01/#mitigating-differential-power-analysis-in-schnorr-signatures

  - title: Discussion about nested and composable multisignature schemes
    url: /en/newsletters/2019/12/04/#continued-schnorr-taproot-discussion

  - title: "BIPs #876 assigns BIP340 to new multisignature compatible scheme"
    url: /en/newsletters/2020/01/29/#bip340

  - title: ECDSA multisignatures for scriptless Lightning Network payment channels
    url: /en/newsletters/2018/10/09/#multiparty-ecdsa-for-scriptless-lightning-network-payment-channels

  - title: Alternative to ECDSA multisignatures for signature adaptors
    url: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures

  - title: Warning about using 160-bit addresses for naive multiparty multisignatures
    url: /en/newsletters/2020/06/24/#reminder-about-collision-attack-risks-on-two-party-ecdsa

  - title: Implementing statechains for ECDSA using multisignatures
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo

  - title: Two papers published on fast ECDSA multisignatures
    url: /en/newsletters/2018/10/23/#two-papers-published-on-fast-multiparty-ecdsa

  - title: Work on schnorr multisignature schemes that require reduced interactivity
    url: /en/newsletters/2019/11/27/#schnorr-taproot-updates

  - title: Talk about how taproot enables scaling when used with multisignatures
    url: /en/newsletters/2019/09/18/#blockchain-design-patterns-layers-and-scaling-approaches

  - title: "Signature adaptors without requiring support for multisignatures"
    url: /en/newsletters/2021/04/28/#support-for-ecdsa-signature-adaptors-added-to-libsecp256k1-zkp

  - title: "Preparing for taproot: multisignature overview"
    url: /en/newsletters/2021/08/04/#preparing-for-taproot-7-multisignatures

  - title: "Preparing for taproot: challenges with multisignature nonces"
    url: /en/newsletters/2021/08/11/#preparing-for-taproot-8-multisignature-nonces

  - title: "Question about the largest multisig quorum possible with different script types"
    url: /en/newsletters/2022/06/29/#what-is-the-largest-multisig-quorum-currently-possible

  - title: "BIPs #1372 assigns BIP327 to the MuSig2 protocol for creating multisignatures"
    url: /en/newsletters/2023/04/12/#bips-1372

## Optional.  Same format as "primary_sources" above
see_also:
  - title: MuSig
    link: topic musig

  - title: Signature adaptors
    link: topic adaptor signatures

  - title: Threshold signature
    link: topic threshold signature
---
Multisignatures can be compared with *multisig*, the use of public
keys and signatures with Bitcoin's `OP_CHECKMULTISIG` and
`OP_CHECKMULTISIGVERIFY` opcodes (and the `OP_CHECKSIGADD` opcode
proposed for [tapscript][topic tapscript]).  Multisignatures have the
advantage that only a single key and a single signature are published
onchain when they are used in a Bitcoin transaction, allowing an
unlimited number of signers to pay the same amount of transaction fee
that a single signer would pay for an otherwise identical transaction.
Multisignature payments being indistinguishable from single-signature
payments also gives the creators of both types of payments greater privacy.

It's possible to create multisignatures for the ECDSA algorithm
supported by all versions of Bitcoin, although
it's easier to create multisignatures
for [schnorr signatures][topic schnorr signatures] and several
algorithms for that are known, with [MuSig][topic musig] having been
specifically created for the needs of Bitcoin users.

**Terminology:** the following table summarizes the differences
between *multisignature* and related terms.

{% include snippets/msig-terms.md %}

{% include references.md %}
