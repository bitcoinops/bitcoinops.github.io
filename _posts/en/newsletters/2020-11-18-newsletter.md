---
title: 'Bitcoin Optech Newsletter #124'
permalink: /en/newsletters/2020/11/18/
name: 2020-11-18-newsletter
slug: 2020-11-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter contains a warning about backdoored VM images.
Also included are our regular sections with summaries of notable
improvements to clients and services, announcements of releases and
release candidates, and changes to popular Bitcoin infrastructure
software.

## Action items

- **Backdoored VM images:** a user on Reddit [posted][reddit vm post]
  about losing funds after using an AWS image that came with a Bitcoin
  full node already installed and synced to a recent block.  Although
  the source of the loss was not fully determined in the thread, it was
  suggested that virtual machine images or other curated collections of
  software, especially those designed for Bitcoin or other
  cryptocurrencies, provide an effective mechanism for delivering
  backdoored software to valuable servers.  This is a reminder that you
  should only install software from trustworthy sources.  Additionally,
  please remember that your VM provider and their support staff can
  likely access any private keys on your server even if you perfect
  every other aspect of your security.  In short, please consider
  performing extra diligence on any software or service to which you
  will entrust the creation of non-reversible Bitcoin transactions.

## News

*No significant Bitcoin technical news this week.*

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Sparrow Wallet adds payment batching and payjoin:**
  Sparrow's recent [0.9.6][sparrow 0.9.6] and [0.9.7][sparrow 0.9.7] releases
  added payment batching and [payjoin][topic payjoin] capabilities respectively.

- **Nunchuk open sources Bitcoin Core backed multisig library:**
  The team that developed the [Nunchuk desktop application][nunchuk website] has
  [announced `libnunchuk`][libnunchuk blog], a C++ multisig library that leverages
  Bitcoin Core's existing codebase.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.9.2rc1][C-Lightning 0.9.2] is a release candidate for
  the next maintenance version of C-Lightning.  It contains new
  features, updated options, and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #4168][] adds the ability for a plugin to specify that a hook be
  run before or after that of another plugin. Plugin authors wishing to ensure
  their plugin's relative load ordering in this way should amend their
  `getmanifest` method's response as shown [here][C-Lightning getmanifest].

- [C-Lightning #4171][] updates the `hsmtool` command with a new
  `dumponchaindescriptors` parameter that prints the [output script
  descriptors][topic descriptors] for the keys and scripts used by
  C-Lightning's onchain wallet.  These descriptors may then be imported
  into a watch-only wallet to track any onchain transactions made
  by the LN node.  This feature was [requested][c-lightning
  #4110] to help improve integration between [BTCPay
  Server's][] default hot wallet and the optional LN server.

- [Eclair #1599][] makes spending more intelligent when considering
  sending a [multipath payment][topic multipath payments] to a channel
  counterparty.  When the receiver shares a direct channel with the
  spender, the spender knows exactly how much money is available to be
  sent in that channel.  With this change, up to that amount can be
  allocated to the initial part of the payment instead of splitting it
  across multiple paths.  Any remainder that still needs to be sent can
  still use other paths.

- [LND #4715][] adds a `--reset-wallet-transactions` configuration
  parameter that will remove all onchain transactions from LND's wallet
  and then start a rescan of the block chain to repopulate the wallet.

- [BOLTs #808][] adds a warning that nodes must not release their own
  HTLC preimages unless they're the final receiver of a payment.  This
  warning may help new implementations avoid the premature release of preimages which caused
  CVE-2020-26896 (see [Newsletter #121][news121 cve-2020-26895]).

{% include references.md %}
{% include linkers/issues.md issues="4168,4171,1599,4715,808,4110" %}
[C-Lightning 0.9.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.2rc1
[reddit vm post]: https://www.reddit.com/r/Bitcoin/comments/jrxgj8/bitcoin_core_node_hacked/
[btcpay server's]: https://github.com/btcpayserver/btcpayserver
[news121 cve-2020-26895]: /en/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation
[sparrow 0.9.7]: https://github.com/sparrowwallet/sparrow/releases/tag/0.9.7
[sparrow 0.9.6]: https://github.com/sparrowwallet/sparrow/releases/tag/0.9.6
[nunchuk website]: https://nunchuk.io/
[libnunchuk blog]: https://nunchuk.medium.com/announcing-libnunchuk-a-lean-cross-platform-multisig-library-powered-by-bitcoin-core-a2f6e26c54df
[C-Lightning getmanifest]: https://github.com/ElementsProject/lightning/blob/cd7d5cdff9e5efc0dcfb5fdc91e8c80a11daebed/doc/PLUGINS.md#the-getmanifest-method
