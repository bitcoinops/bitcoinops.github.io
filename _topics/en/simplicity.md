---
title: Simplicity

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Simplicity** is a work in progress low level programming language designed
  to offer greater flexibility and expressiveness than Bitcoin Script whilst
  allowing you to verify the safety, security and costs of your program. It
  offers native Merklized scripting, formal semantics and type checking.
  It is not Turing complete but it can verify the execution of Turing complete
  programs. Although Simplicity provides certain proofs of correctness,
  sufficient care will need to be applied in the writing of Simplicity programs
  to ensure they perform as intended. To use Simplicity directly on the
  Bitcoin blockchain requires a soft fork and any such proposal is unlikely to
  be formalized until at least 2022-23. Currently there is Simplicity support
  for test branches of Bitcoin and Elements and a collection of jets are in
  development.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Jets are pre-made building blocks that can be combined to construct
  Simplicity programs. They have efficient machine-code implementations for raw
  performance. At its core Simplicity consists of nine primitive operators
  called combinators where semantics are formally specified. However,
  implementing Bitcoin functionality at such a low level typically results in
  large, slow and expensive programs. So instead functionality like hash
  functions and signature verification are implemented in higher level languages
  like C which are then proved to be equivalent to the pure Simplicity programs.
  Assuming Simplicity is soft forked into Bitcoin with sufficient jets at some
  stage, proposed soft forks like [SIGHASH_ANYPREVOUT][topic SIGHASH_ANYPREVOUT]
  could be utilized on Bitcoin without needing a separate soft fork.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Simplicity: High-Assurance Smart Contracting"
      link: https://blockstream.com/2018/11/28/en-simplicity-github/

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: OP_CHECKTEMPLATEVERIFY
    url: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
    date: 2019-12-04

  - title: Question about Simplicity and static analysis
    url: /en/newsletters/2020/04/29/#how-is-simplicity-better-suited-for-static-analysis-compared-to-script
    date: 2020-04-29

  - title: Simplicity - Next Generation Smart Contracting
    url: /en/newsletters/2020/05/06/#simplicity-next-generation-smart-contracting
    date: 2020-05-06

  - title: Question about implementing Taproot with Simplicity
    url: /en/newsletters/2020/07/29/#could-we-skip-the-taproot-soft-fork-and-instead-use-simplicity-to-write-the-equivalent-of-taproot-scripts
    date: 2020-07-29

  - title: BIP-Taproot
    url: /en/newsletters/2020/08/05/#bip-taproot
    date: 2020-08-05

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Simplicity: A New Language for Blockchains"
    link: https://blockstream.com/simplicity.pdf
---

