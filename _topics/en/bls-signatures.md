---
title: BLS signatures

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Library announced for BLS signatures
    url: /en/newsletters/2018/08/07/#library-announced-for-bls-signatures

  - title: "Presentation: compact multisignatures for smaller blockchains"
    url: /en/newsletters/2018/10/09/#compact-multi-signatures-for-smaller-blockchains

  - title: "Using Bitcoin-compatible BLS signatures for Discree Log Contracts (DLCs)"
    url: /en/newsletters/2022/08/17/#using-bitcoin-compatible-bls-signatures-for-dlcs

  - title: "Question about schnorr signatures versus BLS signatures"
    url: /en/newsletters/2023/01/25/#bls-signatures-vs-schnorr

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Scriptless multisignatures
    link: topic multisignature

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  Boneh--Lynn--Shacham signatures (**BLS signatures**) are digital
  signatures that provide a different set of tradeoffs compared to the
  ECDSA and schnorr signatures currently used in Bitcoin.
---
Probably the most interesting property of BLS signatures is that they
allow non-interactive signature aggregation.  For example, if Alice and
Bob both independently sign the same transaction, a third party can
combine their signatures into a single signature that proves both of
them signed.  By comparison, using a Bitcoin's existing [schnorr
signatures][topic schnorr signatures], a single signature proving both
of them signed can only be produce through an interactive protocol like
[MuSig2][topic musig] where at least one of them receives the other's
partial signature before producing their own partial signature and
producing the complete signature.

In theory, if other changes to Bitcoin were made and if support for BLS
signatures was added, miners could aggregate all signatures together
before producing a block, allowing blocks to contain only a single
signature, which would moderately improve onchain capacity and might
speed block verification when cached verification was unavailable (e.g.
during initial block download).

BLS signatures are not directly compatible with the elliptic curve used
by Bitcoin and are not as well studied as [schnorr signatures][topic
schnorr signatures].  It would not be possible to use [signature
adaptors][topic adaptor signatures] and technology based on them (such
as [PTLCs][topic ptlc]) with BLS signatures.

{% include references.md %}
{% include linkers/issues.md issues="" %}
