---
title: Accountable Computing Contracts

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: ACC

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - BitVM
  - Zero-Knowledge Contingent Payments (ZKCP)

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: ZKCP versus standardized atomic data delivery following LN payments
    url: /en/newsletters/2019/07/03/#standardized-atomic-data-delivery-following-ln-payments

  - title: "BitVM: payments contingent on arbitrary computation without consensus changes"
    url: /en/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation

  - title: "Publication of two BitVM proof of concepts"
    url: /en/newsletters/2023/11/22/#bitvm-proof-of-concepts

  - title: Proposal for general smart contracts in Bitcoin via covenants
    url: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants

  - title: Verification of arbitrary programs using proposed opcode from MATT
    url: /en/newsletters/2024/01/03/#verification-of-arbitrary-programs-using-proposed-opcode-from-matt

  - title: Sending and receiving ecash using LN and ZKCPs
    url: /en/newsletters/2024/02/28/#sending-and-receiving-ecash-using-ln-and-zkcps

  - title: "Development of domain-specific languages for smart contracting, including with BitVM"
    url: /en/newsletters/2024/04/10/#dsl-for-experimenting-with-contracts

  - title: "BitVMX: an alternative to BitVM for verification of program execution"
    url: /en/newsletters/2024/05/17/#alternative-to-bitvm

  - title: "Optimistic verification of zero-knowledge proofs using CAT, MATT, and Elftrace"
    url: /en/newsletters/2024/08/09/#optimistic-verification-of-zero-knowledge-proofs-using-cat-matt-and-elftrace

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Merklize All The Things (MATT)"
    link: topic matt

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Accountable Computing Contracts (ACC)** are payments
  that the receiving party can spend if they verifiably run a specified
  function on a specified set of inputs.  If the receiving party doesn't
  run the function or doesn't run it correctly, the paying party can
  reclaim the payment after a period of time.

---
For example, Alice claims she has a solution to a puzzle.  Bob wants to
buy the solution to the puzzle, but Alice is unwilling to give him a
solution until she's guaranteed to receive a payment.  Bob is similarly
unwilling to pay Alice until he's sure the solution is correct.  They
decide to write a program that will return true if it verifies the
solution is correct. Then Bob pays money to a transaction output that
will allow Alice to claim the money if she provides a solution that was
verified by the program.  If the solution is incorrect, either Alice's
spend will be invalid or she will need to pay a penalty that is equal to
or greater than the amount of the payment.

There have been several proposals and implementations of this idea for
Bitcoin:

- [Zero-Knowledge Contingent Payments][zkcp] (ZKCPs) allow Alice to
  prove that she ran the program on her puzzle solution and that the
  solution has a particular hash digest.  Bob can then create an
  [HTLC][topic HTLC] that pays Alice if she discloses the preimage for
  that hash digest.  If Alice doesn't disclose it, Bob can reclaim his
  funds after the HTLC timelock expires.

- [BitVM][] allows Bob to deposit money into a contract that
  compactly references the program they're using for verification.
  Alice can then provide the solution.  If Bob is satisfied, he releases
  the money to Alice.  If he fails to take action, Alice can claim the
  money after a period of time.  If he isn't satisfied, he can challenge
  Alice to prove that their program returns true when run on her
  solution, breaking the challenge into multiple steps that each require
  an onchain transaction.  BitVM is available on Bitcoin today.

- [MATT][topic matt] works similar to BitVM, although it requires a soft
  fork.  As a tradeoff, it can be much more efficient than BitVM due to
  changing the consensus rules to make this type of proving
  efficient.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[zkcp]: https://bitcoincore.org/en/2016/02/26/zero-knowledge-contingent-payments-announcement/
[bitvm]: /en/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
