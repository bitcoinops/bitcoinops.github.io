---
title: 'Bitcoin Optech Newsletter #229'
permalink: /en/newsletters/2022/12/07/
name: 2022-12-07-newsletter
slug: 2022-12-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an implementation of ephemeral anchors
and includes our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Ephemeral anchors implementation:** Greg Sanders [posted][sanders
  ephemeral] to the Bitcoin-Dev mailing list that he's implemented his
  idea for ephemeral anchors (see [Newsletter #223][news223 anchors]).
  [Anchor outputs][topic anchor outputs] are an existing technique made
  available by Bitcoin Core [CPFP carve outs][topic cpfp carve out] and
  used in the LN protocol to ensure that both parties involved in a
  contract can [CPFP][topic cpfp] fee bump a transaction related to that
  contract.  Anchor outputs have several downsides---some of them
  fundamental (see [Newsletter #224][news224 anchors])---but others
  that can be addressed.

    Ephemeral anchors build on the [v3 transaction relay proposal][topic
    v3 transaction relay] to allow v3 transactions to include a
    zero-value output paying a script that is essentially `OP_TRUE`,
    which permits that transaction to be CPFP fee bumped by anyone on the
    network with a spendable UTXO.  The fee-bumping child transaction
    can itself be RBF fee bumped by anyone else with a spendable UTXO.
    In combination with other parts of the v3 transaction relay
    proposal, it is hoped that this will eliminate all policy-based
    concerns about [transaction pinning attacks][topic transaction
    pinning] against time-sensitive contract protocol transactions.

    Additionally, because anyone can fee bump a transaction containing
    an ephemeral output, it can be used for contract protocols involving
    more than two participants.  The existing Bitcoin Core carve out
    rule only reliably works for two participants and [previous
    attempts][bitcoin core #18725] to increase it required an
    arbitrary upper limit on participants.

    Sanders's [implementation][bitcoin core #26403] of ephemeral anchors
    makes it possible to begin testing the idea along with the other v3
    transaction relay behaviors previously implemented by that
    proposal's author.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:larryruane

{% include functions/details-list.md
  q0="FIMXE"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/26265#l-FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.7.1][] is the latest release of the most widely used
  self-hosted payment processing software for Bitcoin.

- [Core Lightning 22.11][] is the next major version of CLN.  It's also
  the first release to use a new version numbering scheme.[^semver]
  Included are several new features, including a new plugin manager,
  and multiple bug fixes.

- [LND 0.15.5-beta][] is a maintenance release of LND.  It contains
  only minor bug fixes according to its release notes.

- [BDK 0.25.0][] is a new release for this library for building wallets.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19762][] updates the RPC (and, by extension,
  `bitcoin-cli`) interface to allow named and positional arguments to be
used together. This change makes it more convenient to use named
parameter values without having to name every one.  The PR description
provides examples demonstrating the increased convenience of this
approach as well as a handy shell alias for frequent users of
`bitcoin-cli`.

- [Core Lightning #5722][] adds [documentation][grpc doc] about how to
  use the GRPC interface plugin.

- [Eclair #2513][] updates how it uses the Bitcoin Core wallet to ensure
  it always sends change to P2WPKH outputs.  This
  is the result of [Bitcoin Core #23789][] (see [Newsletter
  #181][news181 bcc23789]) where the project addressed a privacy
  concern for adopters of new output types (e.g. [taproot][topic
  taproot]).  Previously, a user who set their wallet default address
  type to taproot would also create taproot change outputs when they
  paid someone.  If they paid someone who didn't use taproot, it was
  easy for third parties to determine which output was the payment (the
  non-taproot output) and which was the change output (the taproot
  output).  After the change to Bitcoin Core, it would default to trying
  to use the same type of change output as the paid output, e.g. a
  payment to a native segwit output would also result in a native segwit
  change output.

    However, the LN protocol requires certain output types.  For
    example, a P2PKH output can't be used to open an LN channel.
    For that reason, users of Eclair with Bitcoin Core need to ensure
    they don't generate change outputs of an LN-incompatible type.

- [Rust Bitcoin #1415][] begins using the [Kani Rust Verifier][] to
  prove some properties of Rust Bitcoin's code.  This complements other
  continuous integration tests performed on the code, such as fuzzing.

- [BTCPay Server #4238][] adds an invoice refund endpoint to BTCPay's
  Greenfield API, a more recent API different from the original BitPay-inspired API.

## Footnotes

[^semver]:
    Previous editions of this newsletter claimed Core Lightning used the
    [semantic versioning][] scheme and new versions would continue using
    that scheme in the future.  Rusty Russell has [described][rusty
    semver] why CLN can't completely adhere to that scheme.  We thank
    Matt Whitlock for notifying us about our previous error.

{% include references.md %}
{% include linkers/issues.md v=2 issues="19762,5722,2513,1415,4238,18725,26403,23789" %}
[lnd 0.15.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta
[core lightning 22.11]: https://github.com/ElementsProject/lightning/releases/tag/v22.11
[btcpay server 1.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.1
[bdk 0.25.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.25.0
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[grpc doc]: https://github.com/cdecker/lightning/blob/20bc743840bf5d948efbf62d32a21a00ed233e31/plugins/grpc-plugin/README.md
[news181 bcc23789]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[kani rust verifier]: https://github.com/model-checking/kani
[news223 anchors]: /en/newsletters/2022/10/26/#ephemeral-anchors
[news224 anchors]: /en/newsletters/2022/11/02/#anchor-outputs-workaround
[news220 v3tx]: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021222.html
[rusty semver]: https://github.com/ElementsProject/lightning/issues/5716#issuecomment-1322745630
