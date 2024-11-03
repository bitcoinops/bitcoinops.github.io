---
title: MATT

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - OP_CHECKCONTRACTVERIFY

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Merkleize All The Things
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021182.html

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Proposal for general smart contracts in Bitcoin via covenants
    url: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants

  - title: MATT-based vaults
    url: /en/newsletters/2023/05/03/#matt-based-vaults

  - title: Using MATT to replicate CTV and manage joinpools
    url: /en/newsletters/2023/06/07/#using-matt-to-replicate-ctv-and-manage-joinpools

  - title: What opcodes are part of the MATT proposal?
    url: /en/newsletters/2023/08/30/#what-opcodes-are-part-of-the-matt-proposal

  - title: Verification of arbitrary programs using proposed opcode from MATT
    url: /en/newsletters/2024/01/03/#verification-of-arbitrary-programs-using-proposed-opcode-from-matt

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Covenants
    link: topic covenants

  - title: OP_CHECKTEMPLATEVERIFY
    link: topic op_checktemplateverify

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **MATT** is a soft fork proposal that would add an `OP_CHECKCONTRACTVERIFY`
  opcode to Bitcoin's script language and make some other changes that
  would allow limited transaction introspection.  This could allow
  verification of arbitrary programs in contract protocols plus
  support the implementation of several covenant-based features.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
