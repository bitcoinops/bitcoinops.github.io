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

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Side channels** are weaknesses in security protocols that arise from
  flaws inherent in the hardware and software used to implement the protocol, rather than from flaws in the protocol's algorithms.

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

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
Side channel attacks can be generally categorized as
- timing attacks
- power-monitoring attacks
- acoustic cryptanalysis
- electromagnetic attacks
- cache attacks

Statistical methods and machine learning algorithms are often used in combination with physical access to a hardware signer in order to carry out attacks. For example, an attacker can take a factory hardware signer, gather a dataset that measures changes in power consumption during critical calculations on this signer, then use this dataset on a new signer, measure this new signer's power consumption during its critical calculations, and exfiltrate the passcode by comparing the power consumption of the new signer with the statistical analysis done on the factory signer.

Some side channel attack surfaces in the Bitcoin ecosystem have been mitigated or precluded entirely. For example, the libsecp256k1 library has merged the SafeGCD algorithm into its codebase. The SafeGCD algorithm is a way to calculate modular inverse operations in constant time. A modular inverse operation is a logical operation used when verifying ECDSA signatures.

TROPIC01 is an auditable RISCV secure chip under development, with the intention to release it as part of a hardware signer. Using secure chips may mitigate some side channel attacks that hardware signers are currently vulnerable to.

{% include references.md %}
{% include linkers/issues.md issues="" %}
