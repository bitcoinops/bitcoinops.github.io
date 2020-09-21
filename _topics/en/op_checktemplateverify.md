---
title: OP_CHECKTEMPLATEVERIFY

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - OP_CHECKOUTPUTSHASHVERIFY

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks
  - Fee Management

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **OP_CHECKTEMPLATEVERIFY (CTV)** is a proposed new opcode that takes a
  commitment hash as a parameter and requires any transaction executing
  the opcode include a set of outputs that match the commitment.  This
  makes it possible to create an address that specifies how any funds
  received to that address may be spent---a design known in Bitcoin as a
  *covenant*.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Originally introduced under the name **OP_CHECKOUTPUTSHASHVERIFY**
  (COSHV), the proposal initially focused on the ability to create
  *congestion control transactions* where a spender pays a single
  address using CTV which, when confirmed to a suitable depth, then
  assures several receivers that they can each be paid.  This two-step
  process can probably be used anywhere payment batching is an option
  but it can likely reduce fees even further than payment batching.

  Later versions of the proposal placed greater emphasis on other
  contracts and [covenants][topic covenants] that could be created using
  the new opcode, such as the ability to create [channel
  factories][topic channel factories], [vaults][topic vaults], and
  [coinjoin transactions][topic coinjoin] in new ways that might
  simplify construction or reduce fees.  Other authors have mentioned
  that the new opcode could possibly be used to allow users to
  trustlessly [pool their funds][joinpool] together into a single UTXO
  in a way that would increase privacy.

  Criticisms of the proposal have focused on it being [too
  specific][maxwell-attributed specific] to the congestion control
  use case rather than providing a
  [generic][oconnor generic] covenant capability.

  [maxwell-attributed specific]: https://bitcointalk.org/index.php?topic=5220520.msg53710072#msg53710072
  [oconnor generic]:  https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016946.html
  [joinpool]: https://gist.github.com/harding/a30864d0315a0cebd7de3732f5bd88f0

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP119

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Proposed new opcode for transaction output commitments
    url: /en/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments

  - title: "Detailed summary: proposed transaction output commitments"
    url: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
    feature: true

  - title: COSHV proposal replaced
    url: /en/newsletters/2019/06/05/#coshv-proposal-replaced

  - title: Potential script changes, including new COSHV opcode
    url: /en/newsletters/2019/06/12/#potential-script-changes

  - title: "OP_CHECKTEMPLATEVERIFY (CTV) replaces COSHV proposal; concerns restated"
    url: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv

  - title: "2019 year-in-review: OP_CHECKTEMPLATEVERIFY"
    url: /en/newsletters/2019/12/28/#ctv

  - title: "BIPs #875 assigns BIP119 to the OP_CHECKTEMPLATEVERIFY proposal"
    url: /en/newsletters/2020/01/29/#bips-875

  - title: OP_CHECKTEMPLATEVERIFY workshop summary
    url: /en/newsletters/2020/02/12/#op-checktemplateverify-ctv-workshop

  - title: Vault prototype with sample implementation using OP_CHECKTEMPLATEVERIFY
    url: /en/newsletters/2020/04/22/#vaults-prototype

  - title: "Sapio: a new language for building contracts with OP_CHECKTEMPLATEVERIFY"
    url: /en/newsletters/2020/08/05/#sapio

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Covenants
    link: topic covenants
---
