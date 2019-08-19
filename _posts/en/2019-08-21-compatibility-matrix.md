---
title: Announcing the Compatibility Matrix
permalink: /en/2019-compatibility-matrix/
name: 2019-08-21-compatibility-matrix
type: posts
layout: post
lang: en
slug: 2019-08-21-compatibility-matrix

excerpt: >
  Announcement of the addition of a new compatibility matrix to the Bitcoin Optech website.

auto_id: false
---
{% include references.md %}

Today we’re excited to announce the addition of a new [compatibility matrix][compatibility] to the Bitcoin Optech website. This compatibility matrix provides:

1. A summary table of wallets’ and services’ support for different scaling technologies.
1. Detailed descriptions and usability screenshots of each evaluated wallet and service.

For initial launch, we are including evaluations for [segwit address][compatibility segwit] and [RBF][compatibility rbf] adoption.

## Segwit Addresses

Analysis of bech32 adoption in the ecosystem was partially motivated by BRD’s [whensegwit.com][when segwit website] efforts and partially by a Bitcoin Core GitHub issue, [“When to make bech32 the default -addresstype?”][bitcoin github issue #15560], where developers discussed whether it was appropriate to default Bitcoin Core’s wallet to bech32 receive addresses based on broader Bitcoin wallet adoption of sending to bech32 addresses.

The information collected for segwit address testing includes:

- Receiving Support
  - Does the wallet allow the creation of P2SH-wrapped segwit addresses?
  - Does the wallet allow the creation of bech32 segwit addresses?
  - What is the default receiving address type?
- Sending Support
  - Can the wallet send to P2WPKH addresses?
  - Can the wallet send to P2WSH addresses?
  - Does the wallet use bech32 change addresses?

## RBF

The initial demand for analyzing RBF adoption in the ecosystem came from Optech member companies. These companies were hesitant to implement RBF because they were unsure how well it was supported by other wallets.

After putting together [a summary report of the RBF analyses][rbf report], we wanted to put together a more in depth source for sharing the underlying data and this motivated us to work on a website to showcase the information.

The information collected for RBF testing includes:

- Receiving Support
  - Are received transactions labeled replaceable in the transaction list?
  - Are received transactions labeled replaceable in the transaction details?
  - Do incoming transaction notifications show that a transaction has signaled RBF?
  - After a transaction is replaced, is the original or replacement shown in the transaction list?
- Sending Support
  - Does the wallet allow sending of BIP125 opt-in-RBF transactions?
  - Are sent transactions labeled replaceable in the transaction list?
  - Are sent transactions labeled replaceable in the transaction details?
  - After a sent transaction is replaced, is the original or replacement shown in the transaction list?

Our hope is that the summary data provides a good idea of what technologies are being adopted in the Bitcoin ecosystem. We also hope that the more detailed screenshots for each wallet or service help illustrate how the technologies are being rolled out from a usability perspective.

We plan to add several more wallets or services as well as additional evaluation metrics to the matrix in the future. We [welcome contributions][optech contributions] to add wallets or services, update tested versions, or add additional usability screenshots or videos.

If you have a suggestion of additional metrics that you think are valuable or Bitcoin services that you would like to see evaluated in the future, please reach out to [info@bitcoinops.org][optech email].

[compatibility]: /en/compatibility/
[compatibility segwit]: /en/compatibility/#segwit-addresses
[compatibility rbf]: /en/compatibility/#replace-by-fee-rbf
[when segwit website]: http://whensegwit.com
[bitcoin github issue #15560]: https://github.com/bitcoin/bitcoin/issues/15560
[rbf report]: /en/rbf-in-the-wild/
[optech contributions]: https://github.com/bitcoinops/bitcoinops.github.io/blob/master/CONTRIBUTING.md
