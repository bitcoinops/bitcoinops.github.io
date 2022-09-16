---
title: Sidechains

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Sidechains** (also called **two-way pegged sidechains**) are block
  chains whose native unit of currency is the same as another block
  chain.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Enabling Blockchain Innovations with Pegged Sidechains
      link: https://www.blockstream.com/sidechains.pdf

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Elements Project bech32-like addresses
    url: /en/bech32-sending-support/#other-addresses-formats-based-on-bech32
    date: 2019-04-30

  - title: "Notable changes: BIP301"
    url: /en/newsletters/2019/07/31/#bips-643

  - title: "Opcodes enabling recursive covenants may also permit drivechains"
    url: /en/newsletters/2022/03/09/#enablement-of-drivechains

  - title: "Creating drivechains with APO and a trusted setup"
    url: /en/newsletters/2022/09/21/#creating-drivechains-with-apo-and-a-trusted-setup

## Optional.  Same format as "primary_sources" above
# see_also:
#  - title:
#    link:
---
In the context of Bitcoin, sidechains use a mechanism where bitcoins
are deposited into a contract on the Bitcoin block chain and an equal
number of bitcoins are created on the sidechain for spending.  Users
on the sidechain can then send sidechain bitcoins to a special
contract that destroys them and releases a corresponding amount of the
bitcoins previously deposited to the contract on the Bitcoin block
chain.

**Federated sidechains** have depositors send their mainnet bitcoins
to a multisig contract controlled by a federation of signatories who
also control the production of blocks on the sidechain.

**Drivechains** are a type of proposed decentralized sidechain where
depositors send their mainnet bitcoins into a contract controlled by
anonymous Bitcoin miners who also control the production of blocks on
the sidechain.

{% include references.md %}
