---
title: MAST

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Soft Forks
  - Scripts and Addresses
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **MAST** is a method of using a merkle tree to store the various
  user-selected conditions that must be fulfilled in order for the
  encumbered bitcoins to be spent.  Using a merkle tree allows the
  spender to select which one of the conditions they'll fulfill without
  having to reveal the details of other conditions to the block chain.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP114
    - title: BIP116
    - title: BIP117
    - title: bip-taproot

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Taproot: an optimization for MAST"
    url: /en/newsletters/2018/12/28/#taproot

  - title: "Should `OP_CODESEPARATOR` be disabled in MAST scripts?"
    url: /en/newsletters/2019/01/08/#continued-sighash-discussion

  - title: It should be possible to upgrade miniscript for things like MAST
    url: /en/newsletters/2019/02/05/#miniscript

  - title: Overview of Taproot and it's MAST-based encumbrances
    url: /en/newsletters/2019/05/14/#overview-of-the-taproot--tapscript-proposed-bips

  - title: Discussion about taproot versus alternative MAST-enabling proposals
    url: /en/newsletters/2020/02/19/#discussion-about-taproot-versus-alternatives

  - title: "Discussion about the evolution of MAST (and other things) into taproot"
    url: /en/newsletters/2020/08/05/#bip-taproot

  - title: What are Merklized Alternative Script Trees?
    url: /en/newsletters/2020/10/28/#what-are-merklized-alternative-script-trees

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Taproot
    link: topic taproot
---
Users of MAST who are able to keep unused conditions off of the block
chain will enjoy lower fees, be able to create larger contracts than
currently possible, will have improved privacy, and will improve the
fungibility of their bitcoins.

MAST has been discussed generically in Bitcoin since 2013 and there
have been several concrete proposals to add it to Bitcoin:

- [BIP114][] `OP_MAST`
- [BIP116][] `OP_MERKLEBRANCHVERIFY` and [BIP117][] tail call execution semantics
- [bip-taproot][]'s merkle tree

{:#naming}
Note: the abbreviation MAST originally stood for *Merklized Abstract
Syntax Trees* as [proposed][mast original proposal] by Russell
O'Connor based on [merkle trees][] and [abstract syntax trees][].
Subsequent proposals no longer use anything like abstract syntax trees
but people continued to use the name "MAST" for them, leading Anthony
Towns to [propose][backronym mast] the backronym *Merklized
Alternative Script Trees*.

{% include references.md %}
[mast original proposal]: https://bitcointalk.org/index.php?topic=255145.msg2757327#msg2757327
[backronym mast]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016500.html
[merkle trees]: https://en.wikipedia.org/wiki/Merkle_tree
[abstract syntax trees]: https://en.wikipedia.org/wiki/Abstract_syntax_tree
