---
title: Trimmed HTLC

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLT3: trimmed outputs"
      link: BOLT3

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "BOLTs #919 suggests nodes stop accepting additional trimmed HTLCs beyond a certain value"
    url: /en/newsletters/2023/08/23/#bolts-919

  - title: Discussion about placing trimmed HTLC value in ephemeral anchor outputs and consequences for MEV
    url: /en/newsletters/2024/01/17/#discussion-of-miner-extractable-value-mev-in-non-zero-ephemeral-anchors

  - title: Continued discussion about placing trimmed HTLC value in ephemeral anchor outputs
    url: /en/newsletters/2024/01/24/#trimming-redirect

## Optional.  Same format as "primary_sources" above
see_also:
  - title: HTLCs
    link: topic htlc

  - title: Uneconomical outputs
    link: topic uneconomical outputs

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Trimmed HTLCs** are forwardable LN payments that are below a
  channel's economic limit for being resolved onchain.  Instead,
  a commitment transaction that goes onchain pays the value of all
  trimmed HTLCs to transaction fees.
---
Different channels may have different limits for [uneconomical
outputs][topic uneconomical outputs], so a trimmed HTLC in one channel may
be a regular HTLC in another channel.  That means trimmed HTLCs are
constructed, used, and resolved the same way as regular HTLCs for most
purposes.

If trimmed HTLCs weren't allowed, the minimum value a channel could
send, accept, or forward would be the amount it considered to be
economic onchain, which can easily be thousands of sats.  Trimmed HTLCs
allow channels to forward very small payments.

Unfortunately, trimmed HTLCs come with risks and can create incentive
problems.  A malicious party can destroy part of a channel's value using
trimmed HTLCs or use trimmed HTLCs they have no intention of resolving
to get their counterparty to pay part of a channel's transaction fees.
Suggested alternatives have included [destroying][sanders burn] trimmed
HTLC value by [paying it to an `OP_RETURN` output or [using][dryja pp] a
probabilistic payment when trimming is necessary.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[sanders burn]: /en/newsletters/2024/01/17/#burn-trimmed-value
[dryja pp]: https://docs.google.com/presentation/d/1G4xchDGcO37DJ2lPC_XYyZIUkJc2khnLrCaZXgvDN0U/mobilepresent?pli=1&slide=id.g85f425098_0_195
