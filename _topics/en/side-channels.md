---
title: Side channels

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Security Problems
  - Security Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Presentation: Extracting Seeds from Hardware Wallets"
    url: /en/newsletters/2019/06/19/#extracting-seeds-from-hardware-wallets

  - title: "Presentation: Remote Side-Channel Attacks on Anonymous Transactions"
    url: /en/newsletters/2020/02/26/#remote-side-channel-attacks-on-anonymous-transactions

  - title: "New SafeGCD algorithm can speed up signing while remaining side-channel resistant"
    url: /en/newsletters/2021/02/17/#faster-signature-operations

  - title: "Libsecp256k1 #831 implements SafeGCD algorithm which speeds up side-channel resistant signing"
    url: /en/newsletters/2021/03/24/#libsecp256k1-831

  - title: "Libsecp256k1 #906 reduces iterations when using a constant-time signing algorithm"
    url: /en/newsletters/2021/04/28/#libsecp256k1-906

  - title: "Libsecp256k1 0.3.1 fixes a timing side-channel vulnerability"
    url: /en/newsletters/2023/04/12/#libsecp256k1-0-3-1

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Exfiltration resistant signing
    link: topic exfiltration resistant signing

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Side channels** are weaknesses in security protocols that arise from
  flaws in the hardware and software used to implement the protocol,
  rather than from flaws in the protocol's algorithms.

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
