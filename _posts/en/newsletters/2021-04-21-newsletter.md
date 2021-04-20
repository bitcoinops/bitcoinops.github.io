---
title: 'Bitcoin Optech Newsletter #145'
permalink: /en/newsletters/2021/04/21/
name: 2021-04-21-newsletter
slug: 2021-04-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes progress on activating taproot,
summarizes an update to LN offers to partly address stuck payments, relays
a request for feedback on anchor outputs in LND, and announces the public
launch of the Sapio smart contract development toolkit.  Also included
are our regular sections with summaries of changes to popular clients
and services, new releases and release candidates, and notable changes
to popular Bitcoin infrastructure software.

## News

- **Taproot activation release candidate:** since our update on
  [taproot][topic taproot] activation in [last week's
  newsletter][news144 activation], the Bitcoin Core Project has merged a
  [pull request][Bitcoin Core #21377] implementing the [Speedy
  Trial][news139 speedy trial] activation mechanism and a [second
  PR][Bitcoin Core #21686] containing the activation parameters.  These
  PRs and a few others are currently part of the first Release Candidate
  (RC) for Bitcoin Core 0.21.1.  Testing and other quality assurance
  tasks are expected to continue for at least several days after the
  publication of this newsletter.  See the RC and merge summary sections
  below for more details.

- **Using LN offers to partly address stuck payments:** in some cases,
  an attempt to pay an LN invoice can result in the payment becoming
  stuck for an extended period of time.  Until the failure is resolved,
  requesting a second invoice to make a second payment attempt can
  result in paying twice.

    This week, Rusty Russell [posted][russell invoice cancel] to the
    Lightning-Dev mailing list a change to his proposed [offers][topic
    offers] specification that allows the receiver of a payment to
    commit to a new invoice which supplants the previous invoice.  If
    the spender pays the second invoice, there's still a risk that they
    will pay twice, but the receiver's signature on the offer combined
    with LN's inherent proof of payment will allow the spender to prove
    the receiver acted deceitfully if both payments were accepted.  When
    paying a receiver with an established reputation, such as a popular
    business, that may be enough to eliminate stuck payments as a major
    problem.

    The update to the offers specification also allows the receiver to
    indicate that they received the payment and the problem is with a
    downstream node.  In that case, the funds for both the spender and
    the receiver are fully secure and the only consequence is that the
    spender will need to wait a while before they can reuse that
    particular one of their payment slots ([HTLC][topic htlc] slots).
    This ability to communicate interactively is a clear advantage of
    offers over plain invoices.

- **Using anchor outputs by default in LND:** Olaoluwa Osuntokun
  [posted][osuntokun anchor] to the LND engineering mailing list about
  his desire for the next major version of LND to use [anchor
  outputs][topic anchor outputs] by default.  Anchor outputs will allow
  unconfirmed LN commitment transactions that close a channel to be
  [CPFP][topic cpfp] fee bumped.  Unfortunately, there are some
  challenges with CPFP fee bumping in the LN model:

    - *Not always optional:* for regular onchain transactions, many
      users can just wait longer for their transaction to confirm as an
      alternative to fee bumping.  For LN, sometimes waiting isn't an
      option---a fee bump will need to be submitted within a matter of
      hours or funds could be lost.

    - *Timelocked outputs:* for most regular onchain payments, a user
      who wants to CPFP bump can pay for a fee bump using the funds
      stored in their output from the transaction they want to bump.  In
      the case of LN, those funds aren't available until the channel
      close has been fully settled onchain.  That means the user needs
      to use a separate UTXO to pay the fees.

    To address the above two concerns, LND is requiring users of anchor
    outputs to retain at least one confirmed UTXO of reasonable value in
    their wallet any time a channel is open.  That ensures they can CPFP
    fee bump when necessary, but it has certain consequences, such as
    preventing spending the last of your onchain funds (even to open a
    new channel) while you still have at least one channel open.

    Osuntokun's request is for wallets or services built on LND to let
    the development team know if any of the above concerns, or any other
    concerns related to anchor outputs, will cause serious problems.
    Although the question is specific to LND, the answers may have
    implications for all LN nodes.

- **Sapio public launch:** Jeremy Rubin [posted][rubin sapio] to the
  Bitcoin-Dev mailing list an announcement that he has made available
  the Sapio smart contract development toolkit, a Rust-based library
  and associated tooling that can be used to create smart contracts
  expressible using Bitcoin Script.  The language was originally
  designed to make use of Rubin's proposed
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] opcode
  (`OP_CTV`), but it can simulate the existence of that opcode, and of
  other potential features for Bitcoin such as taproot, using a trusted
  signing oracle.  In addition to the Sapio library, the release also
  contains extensive documentation and an experimental frontend.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Specter v1.3.0 released:**
  [Specter v1.3.0][] includes additional RBF support, Bitcoin Core setup
  from within the application, HWI 2 support, and an option to use [mempool.space][news132
  mempool.space] as a [block explorer][topic block explorers] and for fee estimation.

- **Specter-DIY v1.5.0:**
  Hardware wallet firmware Specter-DIY [released][specter-diy github] v1.5.0 which adds custom SIGHASH
  flag support and full [descriptor][topic descriptors] support including [miniscript][topic miniscript].

- **BlueWallet v6.0.7 adds message signing:**
  [BlueWallet v6.0.7][bluewallet v6.0.7] allows users to sign and verify
  messages using Bitcoin addresses, among other features and fixes.

- **Azteco announces Lightning support:**
  Bitcoin voucher company Azteco [announced][azteco lightning blog] support for
  redeeming purchased bitcoins via Lightning Network.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1] is a release candidate
  for a version of Bitcoin Core that, if activated, will enforce the
  rules of the proposed [taproot][topic taproot] soft fork, which uses
  [schnorr signatures][topic schnorr signatures] and allows use of
  [tapscript][topic tapscript].  These are, respectively, specified by
  BIPs [341][BIP341], [340][BIP340], and [342][BIP342].  Also included
  is the ability to pay [bech32m][topic bech32] addresses specified by
  [BIP350][], although bitcoins spent to such addresses on mainnet will
  not be secure until activation of a soft fork using such addresses,
  such as taproot.  The
  release additionally includes bug fixes and minor improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #21377][] adds the activation mechanism and
  [#21686][Bitcoin Core #21686] adds the activation parameters for the
  taproot softfork. Starting with the first difficulty
  adjustment after April 24th, miners will be able to signal readiness
  for Taproot activation on bit 2. If 1815 (90%) of one difficulty
  period's 2016 blocks in the signaling window signal readiness, the
  softfork activation locks in. The signaling window ends with the first
  difficulty adjustment after August 11th. If locked in, taproot will be
  activated at block height 709632, which is expected to be reached
  around November 12th.

- [Bitcoin Core #21602][] updates the `listbanned` RPC with two
  additional fields: `ban_duration` and `time_remaining`.

- [C-Lightning #4444][] adds [lnprototest][] (LN Protocol Tests) to the
  default targets for C-Lightning's Continuous Integration (CI) tests
  and also makes it easier for developers to run the tests from
  C-Lightning's usual build system.  The LN protocol tests make it easy
  for an implementation to test that they're following the [LN protocol
  specification][].

- [LND #4588][] skips creating a change output in cases where the amount
  of change is so small that it's worth less than the amount it would
  cost to spend it.

- [LND #5193][] disables channel validation by default for LND instances
  using the Neutrino client (which implements the [compact block
  filters][topic compact block filters] protocol).  This option assumes
  that channel advertisements received from a peer are correct, saving
  the client from having to download old blocks necessary to verify
  those advertisements.  This has the downside that payment attempts
  made using falsely advertised channels will fail, wasting time but not
  causing the loss of money---a reasonable tradeoff for anyone already
  choosing to use a lightweight client. This new default behavior may be
  disabled by using the new configuration option
  `--neutrino.validatechannels=true`.

- [LND #5154][] adds basic support for using LND with a pruned full
  node, allowing LND to externally request from other Bitcoin nodes a
  block that has been deleted by the local node.  LND can then extract
  whatever information it needs from the block without going through the
  pruned node.  Because the user's own full node previously verified the
  block, this doesn't change the security model.

- [LND #5187][] adds new `channel-commit-interval` and
  `channel-commit-batch-size` parameters that can be used to configure
  how long LND will wait before sending a channel state update and the
  maximum number of changes it'll send in one update.  The higher these
  values are, the more efficient a busy LND node will be, although that
  efficiency comes at the cost of having a slightly higher latency.

- [Rust-Lightning #858][] adds internal support for interoperating with
  Electrum-style blockchain data sources.

- [Rust-Lightning #856][] updates how it handles funding transactions.
  Previously the wallet was asked to create the funding transaction that
  opened a new channel and to give Rust Lightning only that
  transaction's txid.  Now Rust Lightning accepts the full funding
  transaction.  Similar to a recent change to C-Lightning (see
  [Newsletter #141][news141 cl funding]), this allows the LN software to
  check the funding transaction before it is broadcast and ensure it is
  correct.

- [HWI #498][] adds support for signing arbitrary Bitcoin-style messages
  using the BitBox02 hardware wallet.

- [BTCPay Server #2425][] adds support for receiving [payjoin][topic
  payjoin] payments to the wallet even for addresses not associated with
  a BTCPay invoice.

{% include references.md %}
{% include linkers/issues.md issues="21377,21686,21602,4444,4588,5193,5154,5187,858,856,498,2425" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[news139 speedy trial]: /en/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[russell invoice cancel]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002992.html
[osuntokun anchor]: https://groups.google.com/a/lightning.engineering/g/lnd/c/OuC56qq6IaY
[rubin sapio]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018759.html
[lnprototest]: https://github.com/rustyrussell/lnprototest
[ln protocol specification]: https://github.com/lightningnetwork/lightning-rfc/
[news141 cl funding]: /en/newsletters/2021/03/24/#c-lightning-4428
[news144 activation]: /en/newsletters/2021/04/14/#taproot-activation-discussion
[specter v1.3.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.3.0
[news132 mempool.space]: /en/newsletters/2021/01/20/#mempool-v2-0-0-released
[specter-diy github]: https://github.com/cryptoadvance/specter-diy/releases
[bluewallet v6.0.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.0.7
[azteco lightning blog]: https://medium.com/@Azteco_/at-azteco-weve-been-experimenting-with-lightning-for-over-a-year-refining-our-thinking-and-user-b9d112cff13c
