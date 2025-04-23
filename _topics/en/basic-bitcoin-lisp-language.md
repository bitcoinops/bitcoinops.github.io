---
title: "Basic Bitcoin Lisp Language (bll)"

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: bll

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - symbll
  - bllsh
  - BTC Lisp

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: bllsh repo
      link: https://github.com/ajtowns/bllsh

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Suggestion to add a variation of Chia Lisp to Bitcoin as a new scripting language"
    url: /en/newsletters/2022/03/16/#using-chia-lisp

  - title: "Hypothetical comparison of a Lisp-based scripting language to an upgraded Bitcoin Script language"
    url: /en/newsletters/2023/11/01/#covenants-research

  - title: "Overview of Chia Lisp for Bitcoiners"
    url: /en/newsletters/2024/03/13/#overview-of-chia-lisp-for-bitcoiners

  - title: "Overview of BTC Lisp: an enhanced scripting language for Bitcoin"
    url: /en/newsletters/2024/03/20/#overview-of-btc-lisp

  - title: "Introduction of Lisp-like Bitcoin scripting languages and tools: bll, symbll, bllsh"
    url: /en/newsletters/2024/11/29/#bll-symbll-bllsh

  - title: "Implementing quantum-safe signatures in symbll versus GSR"
    url: /en/newsletters/2024/11/29/#implementing-quantum-safe-signatures-in-symbll-versus-gsr

  - title: "Flexible coin earmarks compatible with symbll"
    url: /en/newsletters/2024/11/29/#flexible-coin-earmarks

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Simplicity
    link: topic simplicity

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Basic Bitcoin Lisp language (bll)** is a proposed scripting language
  that could be added to Bitcoin in a soft fork.  Formerly called **BTC
  Lisp** and conceptually based on Chia Lisp, it's part of a set of
  tools that includes **symbll** (a miniscript-like compiler of
  higher-level Lisp to lower-level bll) and **bllsh** (a REPL for
  trying and debugging symbll and bll).

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
