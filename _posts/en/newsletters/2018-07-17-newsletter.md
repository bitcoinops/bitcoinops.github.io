---
title: 'Bitcoin Optech Newsletter #4'
permalink: /en/newsletters/2018/07/17/
name: 2018-07-17-newsletter
type: newsletter
layout: newsletter
lang: en
version: 1
---
This week's newsletter includes news and action items about a feature
freeze for the next major version of Bitcoin Core, increasing
transaction fees, a likely renaming of the proposed `SIGHASH_NOINPUT`
flag, and several notable recent Bitcoin Core merges.

## Action items

- Last chance to advocate for any almost-ready new features to be
  included in Bitcoin Core 0.17, expected to be released in August or
  September.  The feature-freeze date mentioned in [newsletter #3][] has
  been pushed back a week to July 23rd.

## Dashboard items

- **Transaction fees increasing:** for transactions targeting
  confirmation within 12 blocks or sooner, [recommended fees][] have risen
  up to 3x compared to this time last week.  Nodes with default settings
  still have plenty of room in their mempools, so the trend could quickly
  reverse itself.  It's recommended to be careful making cheap
  consolidation transactions until feerates drop again or unless you can
  wait potentially several weeks for the consolidation transaction to
  confirm.

## News

- **Coin selection groups discussion:** under discussion this week was
  Bitcoin Core PR [#12257][], which adds an option to the wallet that
  causes every output paid to the same address to be spent whenever any
  one of those outputs is spent.  A motivation for this PR is to enhance
  privacy, as otherwise spending multiple outputs received to the same
  address in different transactions will create a privacy-reducing link
  between those transactions.  But this option also automatically
  consolidates inputs which may be of special interest to Bitcoin
  businesses that frequently receive multiple payments to the same
  address.

- **Continuing discussion about Schnorr signatures:** no faults have
  been identified with the proposed BIP [described][schnorr feature] in
  last week's newsletter, but two developers have proposed
  optimizations, [one][multiparty signatures] of which has run afoul of
  security considerations and [another one][rearrange schnorr] of which
  will likely not be added as its minor optimization comes at the
  tradeoff of removing different minor optimization.

- **Naming of `SIGHASH_NOINPUT`:** [BIP118][] describes a new optional
  signature-hash (sighash) flag that doesn't identify which set of
  bitcoins it is spending.  The main thing used to determine whether the
  spend is valid is whether the signature script (witness) fulfills all
  the conditions of the pubkey script (encumbrance).

    For example, in the [Eltoo][] smart contract protocol aimed augmenting
    Lightning Network (LN), Alice and Bob sign each change of balance in
    a payment channel with this new sighash flag so that, when they want
    to close the channel, either one of them can use the transaction
    with the final balance to spend from the transaction with the
    initial balance.

    However, naive use of this new sighash flag can cause unexpected
    loss of funds.  For example, Alice receives some bitcoins to a
    particular address; she then spends those bitcoins to Bob using the
    new sighash flag.  Later, Alice receives more bitcoins to the same
    address---Bob can now steal those bitcoins by reusing the same
    signature Alice used before.  Note that this only affects people
    using the new sighash flag; it doesn't affect unrelated
    transactions.

    The [discussion][unsafe sighash] this week on the bitcoin-dev and
    lightning-dev mailing lists was about naming the sighash flag so
    that developers don't use it accidentally without realizing its
    dangers.  A rough consensus seems to have formed around
    the name `SIGHASH_NOINPUT_UNSAFE`.

## Notable Bitcoin Core merges

- **[#13072][]:** The `createmultisig` RPC can now create P2SH-wrapped
  segwit and native segwit addresses.

- **[#13543][]:** Support for the RISC-V CPU architecture added.

- **[#13386][]:** New specialized SHA256 functions that take advantage
  of CPU extensions and knowledge of specific data inputs used by Bitcoin
  Core (such as the very common case where the input data is exactly 64
  bytes, as used for every calculation in a Bitcoin merkle tree).  This
  can provide up to a 9x speed-up over Bitcoin Core 0.16.x for cases
  where the new code applies and is supported by the user's CPU.  The
  code mainly helps speed up validation of blocks, both historic blocks
  during initial sync and new blocks during normal operation.

- **[#13452][]:** The `verifytxoutproof` RPC is no longer vulnerable to
  a particular [expensive attack][tx-as-internal-node] against SPV
  proofs publicly disclosed in early June.  The attack was considered
  unlikely given that much cheaper attacks of roughly equal
  effectiveness are well known.  See also merged PR [#13451][] that adds
  extra information that can be used to defeat the attack to the
  `getblock` RPC.  None of this mitigates the attack for actual SPV
  clients.

- **[#13570][]:** New `getzmqnotifications` RPC that "returns
  information about all active ZMQ notification endpoints.  This is
  useful for software that layers on top of bitcoind."

- **[#13096][]:** Increase the maximum size of transactions that will be
  relayed by default from 99,999 vbytes to 100,000 vbytes.

[newsletter #3]: /en/newsletters/2018/07/10/
[recommended fees]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1&from=now-7d&to=now&var-source=bitcoind
[multiparty signatures]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016215.html
[rearrange schnorr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016211.html
[BIP118]: https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki
[eltoo]: https://blockstream.com/eltoo.pdf
[unsafe sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016187.html
[popular twitter thread]: https://twitter.com/orionwl/status/1014829318986436608
[schnorr feature]: en/newsletters/2018/07/10/#featured-news-schnorr-signature-proposed-bip
[#12257]: https://github.com/bitcoin/bitcoin/pull/12257
[#13072]: https://github.com/bitcoin/bitcoin/pull/13072
[#13543]: https://github.com/bitcoin/bitcoin/pull/13543
[#13386]: https://github.com/bitcoin/bitcoin/pull/13386
[#13452]: https://github.com/bitcoin/bitcoin/pull/13452
[#13451]: https://github.com/bitcoin/bitcoin/pull/13451
[#13570]: https://github.com/bitcoin/bitcoin/pull/13570
[#13096]: https://github.com/bitcoin/bitcoin/pull/13096
[tx-as-internal-node]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
