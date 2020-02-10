---
title: Covenants

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Covenants** are a category of proposed changes to Bitcoin's
  consensus rules that would allow a script to prevent an authorized
  spender from spending to certain other scripts.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  For example, a covenant may normally only allow spending to a
  whitelisted set of scripts, such as returning bitcoins to the user's own
  balance or spending to a staging address that only allows spending to
  any arbitrary address after a period of time.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: Enhancing Bitcoin transactions with covenants
    link: https://fc17.ifca.ai/bitcoin/papers/bitcoin17-final28.pdf

  - title: BIP119 OP_CHECKTEMPLATEVERIFY proposal
    link: https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Scaling Bitcoin Tokyo 2018, Script Roundtable: OP_CHECKSIGFROMSTACK"
    url: /en/newsletters/2018/10/09/#discussion-the-evolution-of-bitcoin-script
    date: 2018-10-09

  - title: "New proposed opcode: OP_CHECKOUTPUTSHASHVERIFY"
    url: /en/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
    date: 2019-05-29

  - title: "CoreDev.tech discussion: potential script changes"
    url: /en/newsletters/2019/06/12/#potential-script-changes
    date: 2019-06-12

  - title: Bitcoin vaults without covenants
    url: /en/newsletters/2019/08/14#bitcoin-vaults-without-covenants
    date: 2019-08-14

  - title: OP_CHECKOUTPUTSHASHVERIFY renamed OP_CHECKTEMPLATEVERIFY and updated
    url: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
    date: 2019-12-04

  - title: Suggested changes to OP_CHECKTEMPLATEVERIFY proposal
    url: /en/newsletters/2019/12/18/#proposed-changes-to-bip-ctv
    date: 2019-12-18

  - title: "2019 year-in-review: OP_CHECKTEMPLATEVERIFY"
    url: /en/newsletters/2019/12/28/#ctv
    date: 2019-12-28

## Optional.  Same format as "primary_sources" above
see_also:
  - title: An early description of covenants in Bitcoin
    link: https://bitcointalk.org/index.php?topic=278122.0
---
