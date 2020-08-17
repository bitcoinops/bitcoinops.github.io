---
title: Output linking

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Address reuse
  - Dust attacks
  - Reuse avoidance

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements
  - Privacy Problems
  - Security Problems

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Output linking,** also called **address reuse,** occurs when a user
  receives two or more payments to the same public key or other unique
  script element.  This may happen because the user reuses an address
  out of ignorance or as the result of deliberate targeting, as in a
  **dust attack.**  Methods for limiting the loss of privacy from output
  linking fall under the category of **reuse avoidance.**

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  When you receive several payments to the same Bitcoin address, other
  users can reasonably assume that the same person received all of those
  payments even if the payments are later spent in separate
  transactions.  To prevent third parties from making such connections,
  users are encouraged to perform reuse avoidance by generating a new
  address for each payment they receive.

  Unfortunately users don't have complete control over the payments they
  receive.  In a dust attack, an attacker sends small amounts of bitcoin
  to addresses that have already appeared on the block chain, producing
  address reuse even for conscientiousness users who tried to avoid it.  Some
  wallets try to address this by implementing mandatory coin selection
  (coin control) that helps prevent users from spending dust in
  transactions where they want to protect their privacy.  Other wallets
  provide optional features that will spend all coins received to the
  same address at the same time---but not more than once---eliminating
  the privacy loss from address reuse at the risk of not being able to
  spend funds received to a previously-used address.

  Reusing addresses can also make users of broken software more
  vulnerable to attacks than they would be if they had not reused
  addresses, such as in cases where software reuses digital signature
  nonces.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Address reuse (Bitcoin Wiki)
      link: https://en.bitcoin.it/wiki/Address_reuse

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Bitcoin Core #12257: new `-avoidpartialspends` configuration option"
    url: /en/newsletters/2018/07/31/#bitcoin-core-12257

  - title: "Weak signature nonces discovered in reused addresses"
    url: /en/newsletters/2019/01/15/#weak-signature-nonces-discovered

  - title: "Esplora block explorer updated with privacy warning against address reuse"
    url: /en/newsletters/2019/03/19/#esplora-updated

  - title: "Bitcoin Core #13756 adds `avoid_reuse` wallet flag"
    url: /en/newsletters/2019/06/26/#bitcoin-core-13756

  - title: "Bitcoin Core 0.19 new feature: `avoid_reuse` wallet flag"
    url: /en/newsletters/2019/11/27/#optional-privacy-preserving-address-management

  - title: "Bitcoin Core #17621 fixes potential privacy leak in the `avoid_reuse` flag"
    url: /en/newsletters/2020/01/15/#bitcoin-core-17621

  - title: "Bitcoin Core #17843 fixes balance discrepancy related to `avoid_reuse` flag"
    url: /en/newsletters/2020/01/22/#bitcoin-core-17843

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
