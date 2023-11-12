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
  including determining what witness data must be generated in order to spend bitcoins
  protected by that script.  With miniscript telling the wallet what it needs to do,
  wallet developers don't need to write new code when they switch from
  one script template to another.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Interactive miniscript demo
      link: http://bitcoin.sipa.be/miniscript/

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Miniscript presentation
    url: /en/newsletters/2019/02/05/#miniscript

  - title: Final stack empty, insights from miniscript development
    url: /en/newsletters/2019/05/29/#final-stack-empty

  - title: Miniscript request for comments
    url: /en/newsletters/2019/08/28/#miniscript-request-for-comments

  - title: "2019 year-in-review: miniscript"
    url: /en/newsletters/2019/12/28/#miniscript

  - title: Question about a specification for miniscript
    url: /en/newsletters/2020/03/25/#where-can-i-find-the-miniscript-policy-language-specification

  - title: "Minsc: a new spending policy language based on miniscript"
    url: /en/newsletters/2020/08/05/#new-spending-policy-language

  - title: "PSBT specification updated to improve miniscript compatibility"
    url: /en/newsletters/2020/08/26/#bips-955

  - title: "Miniscript to warn or fail for safety when mixed time/height locks used"
    url: /en/newsletters/2020/09/23/#research-into-conflicts-between-timelocks-and-heightlocks

  - title: "Formal specification of miniscript"
    url: /en/newsletters/2020/12/02/#formal-specification-of-miniscript

  - title: Specter-DIY v1.5.0 adds support for miniscript
    url: /en/newsletters/2021/04/21/#specter-diy-v1-5-0

  - title: "Bitcoin Core #24147 adds backend support for miniscript"
    url: /en/newsletters/2022/04/13/#bitcoin-core-24147

  - title: "Adapting descriptors and miniscript for hardware signing devices"
    url: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices

  - title: "PR Review Club about miniscript support for descriptors"
    url: /en/newsletters/2022/06/08/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #24148 adds watch-only support for descriptors containing miniscript"
    url: /en/newsletters/2022/07/20/#bitcoin-core-24148

  - title: "2022 year-in-review: miniscript descriptors in Bitcoin Core"
    url: /en/newsletters/2022/12/21/#miniscript-descriptors

  - title: "Bitcoin Core #24149 adds signing support for P2WSH-based miniscript-based output descriptors"
    url: /en/newsletters/2023/02/22/#bitcoin-core-24149

  - title: "MyCitadel v1.3.0 adds more advanced support for miniscript"
    url: /en/newsletters/2023/05/24/#mycitadel-wallet-adds-enhanced-miniscript-support

  - title: "Bitcoin Core #26567 computes input weight for fee estimation using miniscript and descriptors"
    url: /en/newsletters/2023/09/13/#bitcoin-core-26567

  - title: "Bitcoin Core #27255 ports miniscript to tapscript, providing tapscript descriptors"
    url: /en/newsletters/2023/10/18/#bitcoin-core-27255

  - title: "Field Report: A Miniscript Journey"
    url: /en/wizardsardine-miniscript/
    date: 2023-11-15

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Miniscript: streamlined Bitcoin scripting"
    link: https://medium.com/blockstream/miniscript-bitcoin-scripting-3aeff3853620
---
The structured representation of Bitcoin scripts provided by
miniscript allows wallets to be much more dynamic about the scripts they use.
In support
of that dynamism, miniscripts can be created using an easily-written
policy language.  Policies are composable, allowing any valid
sub-expression to be replaced by another valid sub-expression (within
certain limits imposed by the Bitcoin system).

{% include references.md %}
