---
title: Cross-input signature aggregation (CISA)

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: cisa

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Half aggregation

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Cross-input signature aggregation research repository"
      link: https://github.com/BlockstreamResearch/cross-input-aggregation

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Taproot to not include cross-input signature aggregation"
    url: /en/newsletters/2019/05/14/#no-cross-input-signature-aggregation

  - title: "Question: why does signature aggregation interefer with signature adaptors?"
    url: /en/newsletters/2021/06/30/#why-does-blockwide-signature-aggregation-prevent-adaptor-signatures

  - title: Draft BIP about half aggregation of BIP340 schnorr signatures
    url: /en/newsletters/2022/07/13/#half-aggregation-of-bip340-signatures

  - title: Notes from Bitcoin developer discussion about CISA
    url: /en/newsletters/2024/05/01/#coredev-tech-berlin-event

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Schnorr signatures
    link: topic schnorr signatures

  - title: BLS signatures
    link: topic bls signatures

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Cross-input signature aggregation (CISA)** is a proposal to reduce the
  number of signatures a transaction requires.  In theory, every
  signature required to make a transaction valid could be combined into a
  single signature that covers the whole transaction.

---
For example, Alice controls two [P2TR][topic taproot] UTXOs.  Normally,
if she creates a transaction spending both UTXOs with a keypath spend,
she'll need to include one 16-vbyte signature in each output.  However,
any node could aggregate both public keys from the UTXOs and Alice could
produce a single 16-vbyte [MuSig][topic musig]-style [scriptless
multisigature][topic multisignature] that corresponded to the aggregate
public key, proving that she controlled the private key for both of the
original public keys.

Although inputs would still need to include a significant amount of
other data, such as the 36-vbyte outpoint that uniquely identifies the
UTXO being spent, CISA could provide a modest reduction in the size of
transactions with multiple inputs.  It could make the per-participant
transaction fees for a [coinjoin][topic coinjoin] moderately cheaper than each
participant creating a transaction on their own, which could lead to
more people using coinjoin-style privacy.

{% include references.md %}
{% include linkers/issues.md issues="" %}
