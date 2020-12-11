---
title: Hash Time Locked Contract (HTLC)

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: htlc

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
  **Hash Time Locked Contracts (HTLCs)** are conditional payments used
  in LN payment channels, cross-chain atomic swaps, same-chain
  coinswaps, zero-knowledge contingent payments, and other contract
  protocols.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  HTLCs have two fundamental clauses: a payment clause secured with a
  *hash lock* and a refund clause secured with a *time lock*.  To open a
  hash lock and claim a payment, the receiver needs to reveal the
  preimage to a hash digest encoded in the contract.  To open a time
  lock and receive a refund, the spender needs to wait until after a
  certain time encoded in the contract.

  Because revealed preimages and past times don't uniquely identify the
  person who should receive either the payment, HTLCs are only secure if
  they also require a unique signature matching the public key of either
  the spender (refundee) or the intended receiver.  That makes the
  minimal HTLC look something [like this][htlc in minsc] in the
  [Minsc][] scripting language:

  ```hack
  (pk(Receiver) && sha256(H)) || (pk(Refundee) && older(10))
  ```

  ### History

  Hash locks and time locks as independent features were clearly
  designed into the original version of Bitcoin.  As far as we're aware,
  the earliest description combining the two to create a conditional
  payment---what'd we now call an HTLC---is a set of posts ([1][maxwell
  hashlock], [2][maxwell timelock]) from July 2012. However, it's
  possible that a [December 2010 post][nakamoto risk free trade] was
  alluding to the same basic idea when mentioning a "cryptographically
  [...] risk free trade".

  ### Future

  [Point Time Lock Contracts][topic ptlc] (PTLCs) perform the same
  function as HTLCs but can provide better privacy, use less block
  space, and prevent routing interception.  As a downside, they depend
  on [signature adaptors][topic adaptor signatures] which can only
  implemented using Bitcoin's existing ECDSA signatures either with
  particularly slow algorithms, by making additional security
  assumptions, or by using an `OP_CHECKMULTISIG`
  construction that doesn't save as much block space as is possible with
  the extra security assumptions.  This conflict between security and
  space savings will be resolved if [schnorr signatures][topic schnorr
  signatures] are added to Bitcoin.  If that happens, it's expected that
  protocols which only require Bitcoin support may migrate from using
  HTLCs to PTLCs.  Other protocols that bridge Bitcoin and other
  cryptocurrencies will likely continue using HTLCs due to widespread
  support for standardized hash functions such as SHA256.

  [htlc in minsc]: https://min.sc/#c=%28pk%28Receiver%29%20%26%26%20sha256%28H%29%29%20%7C%7C%20%28pk%28Refundee%29%20%26%26%20older%2810%29%29
  [minsc]: https://min.sc/
  [maxwell hashlock]: https://bitcointalk.org/index.php?topic=91843.msg1011956#msg1011956
  [maxwell timelock]: https://bitcointalk.org/index.php?topic=91843.msg1011980#msg1011980
  [nakamoto risk free trade]: https://bitcointalk.org/index.php?topic=1790.msg28917#msg28917
  [nolan swaps]: https://bitcointalk.org/index.php?topic=193281.msg2224949#msg2224949

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Lightning Loop: new tool using HTLCs for onchain/offchain swaps"
    url: /en/newsletters/2019/03/26/#loop-announced

  - title: Question about whether HTLCs are cost effective for micropayments
    url: /en/newsletters/2019/04/30/#do-htlcs-work-for-micropayments

  - title: Example of using taproot/tapscript with HTLCs
    url: /en/newsletters/2019/05/14/#complex-spending-with-taproot

  - title: "Stuckless Payments: idea for HTLCs that can be revoked prior to acceptance"
    url: /en/newsletters/2019/07/03/#stuckless-payments

  - title: "C-Lightning #2858 limits the maximum number of pending HTLCs to limit costs"
    url: /en/newsletters/2019/08/14/#c-lightning-2858

  - title: "Using eclipse attacks against nodes to prevent correct HTLC processing"
    url: /en/newsletters/2019/12/18/#discussion-of-eclipse-attacks-on-ln-nodes

  - title: "Using inconsistencies in node mempools to attack HTLC atomicity"
    url: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity

  - title: "LN fee ransom attack against channels that accept too many HTLCs"
    url: /en/newsletters/2020/06/24/#ln-fee-ransom-attack

  - title: "Discussion about the incentives to mine HTLCs"
    url: /en/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives

  - title: "LND #4527 allows users to limit the maximum number of pending HTLCs"
    url: /en/newsletters/2020/09/02/#lnd-4527

  - title: "Stealing fees included in HTLCs created using `SIGHASH_SINGLE`"
    url: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs

  - title: "CVE-2020-26896: premature preimage revelation in LND"
    url: /en/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation

  - title: "2020 year in review: switching LN from HTLCs to PTLCs"
    url: /en/newsletters/2020/12/23/#ptlcs

  - title: "2020 year in review: HTLC mining incentives"
    url: /en/newsletters/2020/12/23/#concern-about-htlc-mining-incentives

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Hash Time Locked Contracts from Bitcoin Wiki
    link: https://en.bitcoin.it/wiki/Hash_Time_Locked_Contracts

  - title: BIP199

  - title: Point Time Locked Contract (PTLC)
    link: topic ptlc
---
