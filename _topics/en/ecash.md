---
title: Ecash

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Blind Signatures for Untraceable Payments
      link: http://www.hit.bme.hu/~buttyan/courses/BMEVIHIM219/2009/Chaum.BlindSigForPayment.1982.PDF

    - title: "Lucre: a pre-Bitcoin open source ecash implementation"
      link: https://github.com/benlaurie/lucre

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Blind signatures in scriptless scripts
    url: /en/newsletters/2018/07/10/#blind-signatures-in-sciptless-scripts

  - title: Discussion of ecash in the context of blind MuSig2 signing
    url: /en/newsletters/2023/08/02/#safety-of-blind-musig2-signing

  - title: Discussion of the design of Cashu and other ecash systems
    url: /en/newsletters/2024/02/21/#cashu-and-other-ecash-system-design-discussion

  - title: Sending and receiving ecash using LN and ZKCPs
    url: /en/newsletters/2024/02/28/#sending-and-receiving-ecash-using-ln-and-zkcps

  - title: Proposal to pay miners with ecash
    url: /en/newsletters/2024/05/24/#upgrading-existing-ln-channels

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Ecash** is a type of centralized digital currency that uses blind
  signatures to prevent the centralized controlling party (the mint) from
  knowing the balance of any particular user or from learning which
  users were involved in any transactions.

---
David Chaum invented [blind signatures][] in 1983 and used them to
describe the ideas behind ecash.  In a typical ecash system, a user
requests some number of tokens from a mint, usually after providing the
mint with collateral such as bitcoins.  The mint signs each token it
returns to the user in such a way that the user can manipulate the
signature to produce an equally valid signature that the mint can
recognize as its own but which doesn't identify which token it came from
(unless the user tries submitting two signatures for the same token).

This allows Alice to receive some tokens from the mint, send a copy of
those tokens to Bob, and Bob to redeem the tokens with the mint.  If
Alice deposited 1,000 sat with the mint for each token, a perfect mint
would give Bob 1,000 sat for each token he redeemed.  Later, if Alice
tried to redeem one of the tokens she previously gave Bob, the mint
would recognize the attempt to redeem the same token twice and reject
Alice's attempt.

Alice and Bob both need to trust the mint to store their money, provide
them with legitimately signed tokens, and accept honest redemptions of
tokens.

There are several implementations of ecash that focus on interoperability
with Bitcoin payments.

[blind signatures]: https://en.wikipedia.org/wiki/Blind_signature
{% include references.md %}
{% include linkers/issues.md issues="" %}
