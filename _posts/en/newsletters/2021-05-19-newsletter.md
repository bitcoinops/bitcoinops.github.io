---
title: 'Bitcoin Optech Newsletter #149'
permalink: /en/newsletters/2021/05/19/
name: 2021-05-19-newsletter
slug: 2021-05-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter provides updates on the previously proposed
transaction relay reliability workshop and CVE-2021-31876.  Also
included are our regular sections describing updates to services and
client software, new releases and release candidates, and notable
changes to popular Bitcoin infrastructure software.

## News

- **Relay reliability workshop scheduled:** as mentioned in [Newsletter
  #146][news146 workshop], Antoine Riard will be hosting IRC-based
  meetings to discuss how to make unconfirmed transaction relay more
  reliable for contract protocols such as LN, coinswaps, and DLCs.  The
  schedule is:

  - Jun 15th, 19:00--20:30 UTC: guidelines about L2 protocols onchain
    security design; coordination of cross-layer security disclosures;
    full-RBF proposal

  - June 22nd (same time): generic layer two fee bumping primitive
    (such as package relay)

  - June 29th (same time): reserved for additional discussion

- **CVE-2021-31876 BIP125 implementation discrepancy follow up:**
  after the publication of [last week's newsletter][news148 cve], there was
  additional discussion about the discrepancy between [BIP125][] opt-in
  Replace-by-Fee ([RBF][topic rbf]) and Bitcoin Core's implementation.
  Olaoluwa Osuntokun [confirmed][btcd #1719] that the `btcd` full node
  implements BIP125 as specified, meaning it does allow child
  transactions to be replaced based on inherited signaling.  Ruben
  Somsen [noted][somsen note] that a hypothetical variation of spacechains, a type of
  one-way pegged [sidechain][topic sidechains], would be affected by the
  problem.  On the other hand, Antoine “Darosior” Poinsot [mentioned][poinsot mention] that the
  Revault [vault][topic vaults] architecture wouldn't be affected.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Blockchain.com supports segwit:**
  [v4.49.1][blockchain v4.49.1] of Blockchain.com's wallet adds the ability to
  create a wallet with native segwit send and receive support.

- **Sparrow 1.4.0 released:**
  [Sparrow 1.4.0][sparrow 1.4.0] adds the ability to create a [child pays for parent
  (CPFP)][topic cpfp] transaction from the transaction list screen, user-defined
  fee amounts during coin selection, and various other improvements.

- **Electrum 4.1.0 enhances Lightning features:**
  [Electrum 4.1.0][electrum 4.1.0] adds [trampoline payments][topic trampoline payments], [multipath
  payments][topic multipath payments], channel
  backups, and other Lightning features. Additionally, this version of Electrum
  supports [bech32m][topic bech32].

- **BlueWallet v6.1.0 released:**
  BlueWallet's [v6.1.0 release][bluewallet v6.1.0] adds Tor support,
  [SLIP39][news86 slip39] support, and functionality for using [PSBTs][topic psbt]
  with HD watch-only wallets.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.13.0-beta.rc2][LND 0.13.0-beta] is a release candidate that
  adds support for using a pruned Bitcoin full node, allows receiving
  and sending payments using Atomic MultiPath ([AMP][topic multipath payments]),
  and increases its [PSBT][topic psbt] capabilities, among other improvements
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #21462][] adds tooling for attesting to outputs of Guix builds
  and verifying these attestations against those of others. After this change,
  Windows and macOS code signing remain the only missing piece before Guix
  builds reach feature-parity with Gitian builds.

- [Bitcoin Core GUI #280][] prevents displaying invalid Bitcoin
  addresses in an error dialog, eliminating the ability to display an
  arbitrary message in an official-looking dialog.  A simple "invalid
  address" error is now displayed instead.  (See the PR for illustrative
  before and after screenshots.)

- [Bitcoin Core #21359][] updates the `fundrawtransaction`, `send` and
  `walletcreatefundedpsbt` RPCs with a new `include_unsafe` parameter
  that can be used to spend unconfirmed UTXOs created by other users in
  the transaction.  This allows fee bumping a transaction using
  [CPFP][topic cpfp] and was added for that reason by a developer
  working on implementing [anchor outputs][topic anchor outputs] in the
  Eclair LN node.  The option should only be used when necessary, as
  unconfirmed transactions created by other users can be replaced, which
  may prevent any child transactions from being confirmed.

- [LND #5291][] improves the way LND ensures that [PSBTs][topic psbt] for
  funding transactions only spend segwit UTXOs.  LN requires segwit UTXOs
  in order to prevent txid malleability from making refund
  transactions unspendable.  LND previously checked this by looking for
  the `WitnessUtxo` field in the PSBT, but this field is technically
  optional for segwit UTXOs and so some PSBT creators don't provide it.
  The updated code will use the provided value if present or, if it's
  not present, scan the UTXO set for the necessary information.

- [LND #5274][] limits the maximum amount of funds the node reserves to
  allow [CPFP][topic cpfp] fee bumping for [anchor outputs][topic anchor
  outputs] to ten times the per-channel amount.  For nodes with large
  numbers of channels, this limits their capital requirements.  If they
  need to close more than 10 channels, they can use the funds received
  from closing one channel to close the next channel in a domino effect.

- [LND #5256][] allows reading the wallet passphrase from a file.  This
  is mainly meant for container-based setups where the passphrase is
  already stored in a file, so using that file directly doesn't create
  any additional security problems.

- [LND #5253][] adds support for [Atomic Multipath Payment (AMP)][topic
  multipath payments] invoices across high-level LND RPC commands such as
  `SendPayment`, `AddInvoice`, and `SubscribeInvoice`. AMP invoices are
  currently an LND-only feature and only accept HTLCs that have the AMP
  feature bits set as well as an AMP payload. This extends [prior
  work][news147 lndamp] that enabled use of AMP by providing manually
  specfied payment parameters to the `SendPayment` RPC.

- [Libsecp256k1 #850][] adds a `secp256k1_ec_pubkey_cmp` method that
  compares two public keys and returns which one of them sorts earlier
  than the other (or returns that they're equal).  This was proposed for
  use with [BIP67][] key sorting, in particular as used with the
  `sortedmulti` [output script descriptor][topic descriptors].

{% include references.md %}
{% include linkers/issues.md issues="21462,280,21359,5291,5274,5256,5253,850" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc2
[news146 workshop]: /en/newsletters/2021/04/28/#call-for-topics-in-layer-crossing-workshop
[news147 lndamp]: /en/newsletters/2021/05/05/#lnd-5159
[news148 cve]: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation
[btcd #1719]: https://github.com/btcsuite/btcd/pull/1719
[somsen note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018921.html
[poinsot mention]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018906.html
[blockchain v4.49.1]: https://github.com/blockchain/blockchain-wallet-v4-frontend/releases/tag/v4.49.1
[sparrow 1.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.4.0
[bluewallet v6.1.0]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.1.0
[news86 slip39]: /en/newsletters/2020/02/26/#what-s-the-relationship-between-slip39-and-bip39
[electrum 4.1.0]: https://github.com/spesmilo/electrum/blob/4.1.0/RELEASE-NOTES
