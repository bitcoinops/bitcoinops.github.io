---
title: Miniscript

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Wallet Collaboration Tools
  - Developer Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Miniscript** allows software to automatically analyze a script,
  including determining what data is necessary to create a witness that
  fulfills the script and allows any bitcoins protected by the script to
  be spent.  With miniscript telling the wallet what it needs to do,
  wallet developers don't need to write new code when they switch from
  one script template to another.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  This automation for the large range of scripts supported by miniscript
  allows wallets to be much more dynamic about the scripts they use,
  possibly even allowing users to specify their own scripts.  In support
  of that dynamism, miniscripts can be created using an easily-written
  policy language.  Policies are composable, allowing any valid
  sub-expression to be replaced by another valid sub-expression (within
  certain limits imposed by the Bitcoin system).

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Interactive Miniscript Demo
      link: http://bitcoin.sipa.be/miniscript/

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Miniscript presentation
    url: /en/newsletters/2019/02/05/#miniscript
    date: 2019-02-05

  - title: Final stack empty, insights from Miniscript development
    url: /en/newsletters/2019/05/29/#final-stack-empty
    date: 2019-05-29

  - title: Miniscript request for comments
    url: /en/newsletters/2019/08/28/#miniscript-request-for-comments
    date: 2019-08-28

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Miniscript: streamlined Bitcoin scripting"
    link: https://medium.com/blockstream/miniscript-bitcoin-scripting-3aeff3853620
---
