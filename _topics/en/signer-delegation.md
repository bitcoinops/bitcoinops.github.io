---
title: Signer delegation

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Delegation

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Scripts and Addresses

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Graftroot
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Continued discussion over graftroot delegation safety
    url: /en/newsletters/2018/07/03/#continued-discussion-over-graftroot-safety

  - title: Implementing statechain delegation without schnorr or eltoo
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo

  - title: Signing delegation under existing consensus rules
    url: /en/newsletters/2021/03/24/#signing-delegation-under-existing-consensus-rules

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Statechains
    link: topic statechains

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Signer delegation** is the ability for authorized spender Alice to
  allow third-party Bob to spend her UTXO without
  Alice giving away her private key, creating an onchain transaction, or
  knowing Bob's public key in advance.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
