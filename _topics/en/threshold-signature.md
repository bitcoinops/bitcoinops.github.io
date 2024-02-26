---
title: Threshold signature

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements
  - Fee Management

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Talk summary: The quest for practical threshold Schnorr signatures"
    url: /en/newsletters/2019/10/16/#the-quest-for-practical-threshold-schnorr-signatures

  - title: Paper published about ECDSA threshold signatures
    url: /en/newsletters/2018/10/23/#two-papers-published-on-fast-multiparty-ecdsa

  - title: Pairing-based threshold signatures with signer auditability
    url: /en/newsletters/2018/10/09/#compact-multi-signatures-for-smaller-blockchains

  - title: Discussion about digital signatures schemes, including threshold signatures
    url: /en/newsletters/2020/07/01/#schnorr-signatures-and-multisignatures

  - title: "Talk summary: Secure Protocols on bip-taproot / threshold sigs with MuSig"
    url: /en/newsletters/2019/06/19/#secure-protocols-on-bip-taproot

  - title: Cryptographic Vulnerabilities in Threshold Wallets
    url: /en/newsletters/2019/06/19/#cryptographic-vulnerabilities-in-threshold-wallets

  - title: Transcripts of talks about the FROST and ROAST threshold signature schemes
    url: /en/newsletters/2022/10/26/#frost

  - title: "Experimental implementation of FROST announced"
    url: /en/newsletters/2023/08/23/#frost-software-frostsnap-announced

  - title: Idea for privacy enhanced transaction cosigning using FROST
    url: /en/newsletters/2023/09/06/#privacy-enhanced-co-signing

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Scriptless multisignature
    link: topic multisignature

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  A **threshold signature** is a digital signature that may have been
  created by an authorized subset of the private keys which were
  previously used to create the corresponding public key.  Threshold
  signatures can be verified using only a single public key and a single
  signature.

---
Different algorithms exist for creating threshold signatures, but
perhaps the simplest of these is a slight extension of a typical
algorithm for creating a [scriptless multisignature][topic multisignature].  This
is easiest explained with an example: participants A, B, and C want to receive
funds that can be spent by any three of them.  They cooperate to create
an ordinary multisignature public key for receiving the funds, then they
each take the extra step of deriving two [secret shares][vss] from their
private key---one share for each of the other two participants.  The
shares are created so that any two shares can reconstitute the private
key that created it.  Each participant gives a different one of their
secret shares to each other participant, so each participant ends up
having to store their own private key plus one share for each other
participant.  Each participant is then able to verify that the shares
they received were correctly derived (i.e. not fake) and are unique from
the shares received by the other participants.

Later, A and B decide they want to create a signature
without C.  A and B
share with each other the two shares they each have for C.  This
allows them to reconstitute C's private key.  A and B also
have their own private keys, giving them all three of the keys necessary
to create a multisignature.

The example above only covers the simplest of threshold signature
algorithms.  Other algorithms exist that reduce conceptual simplicity but provide
additional features, such as reducing the number of steps required or providing increased
resistance to communication problems.

### Comparison to multisig scripts

Bitcoin's Script language (including the proposed [tapscript][topic
tapscript] modified alternative) allows providing a threshold *k* of
signatures for a group of *n* keys, commonly called k-of-n multisig.
This requires providing *k* signatures and *n* public keys in any
onchain transactions.

By comparison, threshold signatures only require a single public key and
single signature, no matter how many participants are involved.
This can significantly reduce the
size of transactions, correspondingly reducing the cost of their
transaction fee.  It also increases their privacy: nobody can tell which
of the parties signed (or even that multiple parties needed to sign in
the first place).

Signer privacy does create a problem for schemes that want
third-party auditability of which parties signed.
Auditing can be implemented using an independent system (e.g. having all
communication between participants go through a logging server).  It can
also sometimes be implemented using clever constructions, such as for a
2-of-3 threshold scheme in [taproot][topic taproot] where the usual
signers (A and B) can use a 2-of-2 multisignature keypath spend and the
two alternatives (A and C, or B and C) can be their own 2-of-2
multisignatures in known positions in the merkle tree for scriptpath
spending.  By looking at the spend, the participants can determine
exactly which two parties signed.

### Terminology

The following table summarizes the differences between *threshold
signature* and related terms.

{% include snippets/msig-terms.md %}

{% include references.md %}
{% include linkers/issues.md issues="" %}
[vss]: https://en.wikipedia.org/wiki/Verifiable_secret_sharing
