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
categories:
  - Contract Protocols
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Swap-in-Potentiam (SIP)** is a protocol designed to enable the immediate transfer
  of already-confirmed onchain Bitcoin funds to the Lightning Network, lowering
  trust requirements by precommitting to an LSP and incorporating a timeout
  mechanism for unilateral access.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: Moving Onchain Funds "Instantly" To Lightning (Jesse Posner, ZmnSCPxj)
    link: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003810.html

  - title: LSPS C= Extension, Swap-in-Potentiam
    link: https://github.com/ZmnSCPxj-jr/swap-in-potentiam/blob/master/doc/swap-in-potentiam.md

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

---
SIP is a [submarine swap][topic submarine swaps]
mechanism that differs from typical purely HTLC based submarine swaps by
allowing for a pre-commital stage. This allows for reusable swap addresses and
more flexibility with onchain funds.

In this scheme, the reusable swap address is a contract between Alice and Bob
that allows for two spend paths; Alice and Bob cosign, or timeout before Alice
can spend unilaterally.

Once the swap address is funded and confirmed, Alice can choose one of the
following options; swap the funds into a new or existing lightning network
channel with the help of Bob, or send the funds to a new onchain address with
the help of Bob. Alice also has the third option of waiting for the recovery
timeout if Bob is offline or uncooperative.

SIP is primarily geared towards mobile users who may go offline for extended
periods of time. The main trick of SIP is splitting the confirmation
requirements between a pre-commital address and a commited address, allowing
for the immediate usage of funds when the mobile user comes online.