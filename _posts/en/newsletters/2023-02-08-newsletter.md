---
title: 'Bitcoin Optech Newsletter #237'
permalink: /en/newsletters/2023/02/08/
name: 2023-02-08-newsletter
slug: 2023-02-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about storing data in
transaction witnesses and references a conversation about mitigating LN
jamming.  Also included are our regular sections with the summary of a
Bitcoin Core PR Review Club meeting, announcements of new releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

- **Discussion about storing data in the block chain:** users of a new
  project recently began storing large amounts of data in the witness
  data for segwit v1 ([taproot][topic taproot]) transactions.   Robert
  Dickinson [posted][dickinson ordinal] to the Bitcoin-Dev mailing list
  to inquire about whether a size limit should be imposed to discourage
  such data storage.

    Andrew Poelstra [replied][poelstra ordinal] that there is no
    effective way to prevent data storage.  Adding new restrictions to
    prevent unwanted data storage in witnesses would undermine
    advantages discussed during taproot's design (see [Newsletter
    #65][news65 tapscript]) and would likely only result in the data
    being stored in other ways.  Those other ways might raise costs for
    those generating the data---but probably not by enough to
    significantly discourage the behavior---and the alternative storage
    methods might create new problems for traditional Bitcoin users.

- **Summary of call about mitigating LN jamming:** Carla Kirk-Cohen and
  Clara Shikhelman [posted][ckccs jamming] to the Lightning-Dev mailing
  list a summary of a recent video conversation about attempts to
  address [channel jamming attacks][topic channel jamming attacks].
  Topics discussed included upgrade mechanism tradeoffs, a simple
  proposal for upfront fees derived from a recent paper (see [Newsletter
  #226][news226 jam]), the CircuitBreaker software (see [Newsletter
  #230][news230 jam]), an update on reputation credentials (see
  [Newsletter #228][news228 jam]), and related work from the Lightning
  Service Provider (LSP) specification working group.  See the mailing
  list post for extended summaries and a [transcript][jam xs].

    Future video meetings are planned for every two weeks; watch the
    Lightning-Dev mailing list for announcements of upcoming meetings.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME is a PR by FIXME that FIXME:LarryRuane

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/FIXME#l-FIXME"
%}

<!-- FIXME:harding to add releases/rc if any on Tuesday -->

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25880][] p2p: Make stalling timeout adaptive during IBD FIXME:Xekyo

- [Core Lightning #5679][] sql plugin FIXME:adamjonas

- [Core Lightning #5821][] adds `preapproveinvoice` (pre-approve
  invoice) and `preapprovekeysend` (pre-approve keysend) RPCs that allow
  the caller to send either a [BOLT11][] invoice or a [keysend][topic
  spontaneous payments] payment details to Core Lightning's signing module
  (`hsmd`) to verify the module is willing to sign the payment.  For
  some applications, such as those where the amount of money which can
  be spent is rate limited, asking for pre-approval might produce fewer
  problems than simply attempting the payment and dealing with failure.

- [Core Lightning #5849][] makes backend changes that allow a node to
  handle over 100,000 peers each with one channel.  Although someone
  running such a node in production is not likely in the near
  future---it would take over a dozen entire blocks to just open that
  many channels---testing the behavior helped the developer make several
  performance improvements.

- [Core Lightning #5892][] updates CLN's implementation of the
  [offers][topic offers] protocol based on compatibility testing
  performed by a developer working on Eclair's implementation.

- [Eclair #2565][] now requests that funds from a closed channel be sent
  to a new onchain address, rather than an address which was generated
  when the channel was funded.  This may decrease [output linking][topic
  output linking], which helps improve user privacy.  An exception to
  this policy is when the user enables the LN protocol option
  `upfront-shutdown-script`, which is a request sent to the channel
  partner at funding time to only use the closing address specified at
  that time (see [Newsletter #158][news158 upfront] for details).

- [LND #7252][] adds support for using Sqlite as LND's database backend.
  This is currently only supported for new installs of LND as there is
  no code for migrating an existing database.

- [LND #6527][] adds the ability to encrypt the server's on-disk TLS
  key.  LND uses TLS for authenticating remote connections to its
  control channel, i.e. to run APIs.  The TLS key will be encrypted
  using data from the node's wallet, so unlocking the wallet will unlock
  the TLS key.  Unlocking the wallet is already required to send and
  accept payments.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25880,5679,5821,5849,5892,2565,7252,6527" %}
[news158 upfront]: /en/newsletters/2021/07/21/#eclair-1846
[dickinson ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021370.html
[poelstra ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021372.html
[news65 tapscript]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[ckccs jamming]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003834.html
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news230 jam]: /en/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming
[news228 jam]: /en/newsletters/2022/11/30/#reputation-credentials-proposal-to-mitigate-ln-jamming-attacks
[jam xs]: https://github.com/ClaraShk/LNJamming/blob/main/meeting-transcripts/23-01-23-transcript.md
