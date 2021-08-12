---
title: Simplicity

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Simplicity** is a work-in-progress low-level programming language with
  greater flexibility and expressiveness than Bitcoin Script. It allows
  you to verify the safety, security and costs of a program. It also offers
  native merklized scripting, formal semantics and type checking. To use
  Simplicity on Bitcoin will require a soft fork and such a proposal has
  not yet been made.  Currently there is Simplicity support for test
  branches of the ElementsProject.org and Bitcoin Core codebases.

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
At its core, Simplicity consists of nine primitive operators called
combinators whose semantics are formally specified. However,
implementing Bitcoin functionality at such a low level results in
large, slow and expensive programs.  Pre-written Simplicity programs
that implement basic functions can be added to Bitcoin consensus so
that other Simplicity programs can inline those functions using a
short identifier, eliminating their size penalty.  The functionality
of the inlined Simplicity code can then be reimplemented in more
efficient languages, such as C, which can be proved to be equivalent
to the pure Simplicity program---eliminating speed or memory
penalties.  These substitutions (called *jets*) allow an entire
program to be specified in the Simplicity language, including
operations like hash functions and signature verification, and yet
be executed using code from other languages to achieve performance
similar to today's Bitcoin Script.

Assuming Simplicity is soft forked into Bitcoin with sufficient jets
at some stage, new features such as [SIGHASH_ANYPREVOUT][topic
sighash_anyprevout]---which currently requires a soft fork to
implement---could be used on Bitcoin without needing separate
consensus rule changes.  Although Simplicity provides certain proofs of
correctness, care will still need to be applied in the design of any
contract protocol that relies on more than just bitcoin encumbrances.

{% include references.md %}
