---
title: Point Time Locked Contracts (PTLCs)

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: ptlc

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Lightning Network
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Point Time Locked Contracts (PTLCs)** are conditional payments that
  can replace the use of HTLCs in LN payment channels, same-chain
  coinswaps, some cross-chain atomic swaps, and other contract
  protocols.  Compared to HTLCs, they can be more private and use less
  block space.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  PTLCs differ from [HTLCs][topic htlc] in their primary locking and
  unlocking method:

  - **HTLC hash locks:** are locked using a hash digest and unlocked by
    providing the corresponding preimage.  The most commonly used hash function is
    SHA256, which produces a 256-bit (32-byte) digest commonly generated
    from a 32-byte preimage.

      When used to secure multiple payments (e.g. a routed LN payment or
      an atomic swap), all payments use the same preimage and hash lock.
      This creates a link between those payments if they're published
      onchain or if they're routed offchain though surveillance nodes.

  - **PTLC point locks:** are locked using a public key (a *point* on
    Bitcoin's elliptic curve) and unlocked by providing a corresponding
    signature from a satisfied [signature adaptor][topic adaptor
    signatures].  For a proposed [schnorr signature][topic schnorr
    signatures] construction, the key would be 32 bytes and the signature
    64 bytes.  However, using either multiparty ECDSA or schnorr key
    aggregation and signing, the keys and signature can be combined
    with other keys and signatures needed to authorize any spend,
    allowing point locks to use zero bytes of distinct block space.

      Each point lock can use different keys and signatures, so there is
      nothing about the point lock that correlates different payments
      either onchain or when routed offchain through surveillance nodes.

  Implementation of PTLCs in Bitcoin requires creating [signature
  adaptors][topic adaptor signatures] that will be easier to combine
  with digital signatures when [schnorr signatures][topic schnorr
  signatures] have been implemented on Bitcoin.  For that reason, the
  development of PTLCs in Bitcoin has mostly been a discussion topic
  rather than something actively worked on.  The unavailability of
  schnorr signatures in alternative cryptocurrencies may also prevent
  the use of PTLCs in some cross-chain contracts, though it is still
  technically possible to use PTLCs with just ECDSA pubkeys and
  signatures.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Multi-Hop Locks from Scriptless Scripts
      link: https://github.com/ElementsProject/scriptless-scripts/blob/master/md/multi-hop-locks.md

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Talk about implementing 2p-ECDSA for LN funding and PTLCs
    url: /en/newsletters/2018/10/09/#multiparty-ecdsa-for-scriptless-lightning-network-payment-channels

  - title: Simplified ECDSA adaptor signatures for PTLCs in LN channels
    url: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures

  - title: Using witness asymmetric payment channels for move from HTLCs to PTLCs
    url: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels

  - title: Updated witness asymmetric channels proposal for move from HTLCs to PTLCs
    url: /en/newsletters/2020/10/14/#updated-witness-asymmetric-payment-channel-proposal

  - title: "2020 year in review: switching LN from HTLCs to PTLCs"
    url: /en/newsletters/2020/12/23/#ptlcs

  - title: "Technique for implementing logical OR on LN using PTLCs"
    url: /en/newsletters/2021/02/17/#escrow-over-ln

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Hash Time Locked Contract (HTLC)
    link: topic htlc

  - title: Adaptor signatures
    link: topic adaptor signatures
---
