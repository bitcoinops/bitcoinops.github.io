---
title: 'Bitcoin Optech Newsletter #184'
permalink: /en/newsletters/2022/01/26/
name: 2022-01-26-newsletter
slug: 2022-01-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to extend PSBTs with fields
for spending outputs constructed using a pay-to-contract protocol and
includes our regular sections with summaries of top posts from the
Bitcoin Stack Exchange and notable changes to popular Bitcoin
infrastructure projects.

## News

- **PSBT extension for P2C fields:** Maxim Orlovsky [proposed][orlovsky
  p2c] a new BIP to add optional fields to [PSBTs][topic psbt] for
  spending from an output created using a [Pay-to-Contract][topic p2c]
  (P2C) protocol, as previously mentioned in [Newsletter #37][news37
  psbt p2c].  P2C allows a spender and a receiver to agree on the text
  of a contract (or anything else) and then create a public key that
  commits to that text.  The spender can then later demonstrate that the
  payment committed to that text and that it would've been
  computationally infeasible for that commitment to have been made
  without the cooperation of the receiver.  In short, the spender can
  prove to a court or the public what they paid for.

  However, in order for the receiver to subsequently construct a
  signature spending their received funds, they need the hash of the
  contract in addition to the key they used (that key usually being
  part of an [HD keychain][topic bip32]).  Orlovsky's proposal allows
  that hash to be added to a PSBT so that a signing wallet or hardware
  device can produce a valid signature.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is it possible to convert a taproot address into a v0 native segwit address?]({{bse}}111440)
  After an exchange changed a user's P2TR (native segwit v1) taproot withdrawal address
  into a P2WSH (native segwit v0) address due to lack of taproot support,
  the user asks if there is a way to claim the bitcoins in the resulting v0
  output. Pieter Wuille notes that those bitcoins are not retrievable since the
  user would need to find a script that hashes to the public key in the P2TR
  address, a computationally infeasible operation.

- [Was Bitcoin 0.3.7 actually a hard fork?]({{bse}}111673)
  User BA20D731B5806B1D wonders what about Bitcoin's 0.3.7 release caused it to
  be classified as a hard fork. Antoine Poinsot gives example `scriptPubKey`
  and `scriptSig` values to illustrate that a previously invalid signature could
  be valid after [0.3.7][bitcoin 0.3.7 github]'s bugfix to separate `scriptSig` +
  `scriptPubKey` evaluations.

- [What is signature grinding?]({{bse}}111660)
  Murch explains that ECDSA signature grinding is the process of repeatedly
  signing until you get a signature whose r-value is in the lower half of the
  range, resulting in a signature that is 1 byte smaller (32 bytes vs 33 bytes)
  based on the serialization format Bitcoin uses for ECSDA. This smaller signature results in lower
  fees and the fact that the signature is a known 32 byte size helps with more
  accurate fee estimation.

- [How is network conflict avoided between chains?]({{bse}}111967)
  Murch explains how nodes use magic numbers, as specified in the P2P [message
  structure][wiki message structure], in order to identify if they are
  connected to a peer that is on the same network (mainnet, testnet, signet).

- [How many BIPs were adopted in the standard client in 2021?]({{bse}}111901)
  Pieter Wuille links to Bitcoin Core's [BIPs documentation][bitcoin bips doc]
  that keeps track of BIPs that are implemented in Bitcoin Core.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #2134][] enables [anchor outputs][topic anchor outputs] by default,
  allowing a commitment transaction to be fee bumped should its feerate be too
  low at broadcast time. Since anchor outputs-style fee bumping works via
  [CPFP][topic cpfp], users will need to keep UTXOs available in their
  `bitcoind` wallet.

- [Eclair #2113][] adds automatic management of fee bumping.  This
  includes classifying transactions by the importance of confirming them
  on time, re-evaluating transactions after each block to determine
  whether it's appropriate to fee bump them, also re-evaluating current
  network feerates in case the transaction's feerate needs to be
  increased, and adding additional inputs to transactions if necessary
  to increase the transaction's feerate.  The PR description also makes
  an appeal for [improvements][Bitcoin Core #23201] to Bitcoin Core's
  wallet API that could reduce the amount of add-on wallet management
  required by external programs like Eclair.

- [Eclair #2133][] begins relaying [onion messages][topic onion
  messages] by default.  The rate limits mentioned in [Newsletter
  #181][news181 onion] are used to prevent problems from any abuse of
  this experimental part of the LN protocol.

- [BTCPay Server #3083][] allows administrators to log into a BTCPay
  instance using [LNURL authentication][] (which can also be
  implemented in non-LN software).

- [BIPs #1270][] clarifies the [PSBT][topic psbt] specification in regard to
  acceptable values for signature fields. After a recent update to Rust
  Bitcoin [introduced stricter parsing][news183 rust-btc psbt] of
  signature fields, a discussion ensued whether a signature field in a
  PSBT may hold a placeholder, or only valid signatures were
  permissible. It was determined that PSBTs should only ever contain
  valid signatures.

- [BOLTs #917][] extends the `init` message defined by [BOLT1][] with
  the ability for a node to tell a connecting peer what IPv4 or IPv6
  address that peer is using.  Since peers behind [NAT][] can't see
  their own IP address, this allows the peer to update the IP address it
  announces to the network when that address changes.

{% include references.md %}
{% include linkers/issues.md issues="2134,2113,23201,2133,3083,1270,917" %}
[orlovsky p2c]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019761.html
[news181 onion]: /en/newsletters/2022/01/05/#eclair-2099
[lnurl authentication]: https://github.com/fiatjaf/lnurl-rfc/blob/legacy/lnurl-auth.md
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[news37 psbt p2c]: /en/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts
[bitcoin 0.3.7 github]: https://github.com/bitcoin/bitcoin/commit/6ff5f718b6a67797b2b3bab8905d607ad216ee21#diff-8458adcedc17d046942185cb709ff5c3L1135
[wiki message structure]: https://en.bitcoin.it/wiki/Protocol_documentation#Message_structure
[bitcoin bips doc]: https://github.com/bitcoin/bitcoin/blob/master/doc/bips.md
[news183 rust-btc psbt]:/en/newsletters/2022/01/19/#rust-bitcoin-669
