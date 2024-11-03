---
title: Exfiltration-resistant signing

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Security Enhancements
  - Wallet Collaboration Tools

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Overview of anti-covert-channel signing techniques
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017667.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Proposal to standardize an exfiltration-resistant nonce protocol
    url: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol

  - title: Overview of anti-covert-channel signing techniques
    url: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols

  - title: Description of anti-exfiltration technique being used in BitBox02 and Jade hardware wallets
    url: /en/newsletters/2021/02/17/#anti-exfiltration

  - title: "Dark Skippy: faster exfiltration of HD wallet seeds"
    url: /en/newsletters/2024/08/09/#faster-seed-exfiltration-attack

  - title: "Discussion of a simple (but imperfect) anti-exfiltration protocol"
    url: /en/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Exfiltration-resistant signing** is the process of creating
  signatures for Bitcoin transactions using a protocol that can be
  audited to ensure the signature doesn't contain any biased or
  otherwise manipulated elements that could be used to compromise the
  signer's private keys.
---
{% include references.md %}
{% include linkers/issues.md issues="" %}
