---
title: Simplicity

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Simplicity** is a work in progress low level programming language with
  greater flexibility and expressiveness than Bitcoin Script. It allows
  you to verify the safety, security and costs of a program. It also offers
  native merklized scripting, formal semantics and type checking. To use
  Simplicity on Bitcoin requires a soft fork and a proposal is unlikely to be
  formalized until at least 2022. Currently there is Simplicity support for
  test branches of Bitcoin and Elements.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Simplicity includes supports for Jets, pre-made building blocks that can be
  combined to construct Simplicity programs. They have efficient machine-code
  implementations for raw performance. At its core Simplicity consists of
  nine primitive operators called combinators where semantics are formally
  specified. However, implementing Bitcoin functionality at such a low level
  typically results in large, slow and expensive programs. So instead
  functionality like hash functions and signature verification are implemented
  in higher level languages like C which are then proved to be equivalent to
  the pure Simplicity programs. Assuming Simplicity is soft forked into Bitcoin
  with sufficient jets at some stage, proposed soft forks like
  [SIGHASH_ANYPREVOUT][topic sighash_noinput] could be utilized on Bitcoin
  without needing a separate soft fork. Although Simplicity provides certain
  proofs of correctness, care still needs to be applied in the design of any
  contract protocol.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Simplicity: High-Assurance Smart Contracting"
      link: https://blockstream.com/2018/11/28/en-simplicity-github/

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Question about Simplicity and static analysis
    url: /en/newsletters/2020/04/29/#how-is-simplicity-better-suited-for-static-analysis-compared-to-script
    date: 2020-04-29

  - title: Transcript on next generation smart contracting with Simplicity
    url: /en/newsletters/2020/05/06/#simplicity-next-generation-smart-contracting
    date: 2020-05-06

  - title: Question about implementing taproot with Simplicity
    url: /en/newsletters/2020/07/29/#could-we-skip-the-taproot-soft-fork-and-instead-use-simplicity-to-write-the-equivalent-of-taproot-scripts
    date: 2020-07-29

  - title: Transcript on implementing Simplicity as a taproot leaf version
    url: /en/newsletters/2020/08/05/#bip-taproot
    date: 2020-08-05

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Simplicity: A New Language for Blockchains"
    link: https://blockstream.com/simplicity.pdf
---

