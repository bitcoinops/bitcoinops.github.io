---
title: Swap-in Potentiam (SIP)

## Optional. test Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: swap-in potentiam

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Swap-in-Potentiam (SIP)** is a protocol that facilitates the immediate transfer of confirmed
  on-chain Bitcoin to the Lightning Network. It reduces trust requirements compared to other
  instant channel opening methods like 0-conf channels by temporarily committing to co-ownership with a Lightning Service
  Provider (LSP) and delaying unilateral access per a timeout.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: Moving Onchain Funds "Instantly" To Lightning (Jesse Posner, ZmnSCPxj)
    link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003810.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Swap-in Potentiam Announced"
    url: /en/newsletters/2023/12/20/#swap-in-potentiam

  - title: Non-interactive LN channel open commitments
    url: /en/newsletters/2023/01/11/#non-interactive-ln-channel-open-commitments

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Hash Time Locked Contracts from Bitcoin Wiki
    link: https://en.bitcoin.it/wiki/Hash_Time_Locked_Contracts

  - title: Swap-in potentiam for Phoenix
    link: https://gist.github.com/t-bast/5fd89979a8088b99d0b95c124902aa56
  - title: Swaproot
    link: https://acinq.co/blog/phoenix-swaproot

  - title: Payjoin-in-Potentiam
    link: https://delvingbitcoin.org/t/payjoin-in-potentiam-externally-fund-an-lsp-channel-open-with-one-transaction/749

---
Swap-in potentiam (SIP) differs from typical HTLC-based swaps by
allowing for a pre-commital stage. This allows for; reusable swap addresses,
immediate transfers to lightning, and reduced trust requirements compared to
0-conf channels.

In this scheme, the reusable swap address is a contract between Alice and Bob
that allows for two spend paths; Alice and Bob cosign, or Alice
can spend unilaterally after a timeout.

Once the swap address is funded and confirmed, Alice can choose one of the
following options; swap the funds into a new or existing lightning network
channel with the help of Bob, or send the funds to a new onchain address with
the help of Bob. Alice also has the third option of waiting for the recovery
timeout if Bob is offline or uncooperative.

SIP is primarily geared towards mobile users who may go offline for extended
periods, and a variation called swaproot has been implemented in Phoenix wallet.

{% include references.md %}
