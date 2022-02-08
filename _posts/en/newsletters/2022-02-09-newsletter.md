---
title: 'Bitcoin Optech Newsletter #186'
permalink: /en/newsletters/2022/02/09/
name: 2022-02-09-newsletter
slug: 2022-02-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a discussion about changing relay
policy for replace-by-fee transactions and includes our regular sections
with the summary of a Bitcoin Core PR Review Club meeting, announcements
of new releases and release candidates, and descriptions of notable
changes to popular Bitcoin infrastructure projects.

## News

- **Discussion about RBF policy:** Gloria Zhao started a
  [discussion][zhao rbf] on the Bitcoin-Dev mailing list about
  Replace-by-Fee ([RBF][topic rbf]) policy.  Her email provides
  background on the current policy, enumerates several problems
  discovered with it over the years (such as [pinning attacks][topic
  transaction pinning]), examines how the policy affects wallet user
  interfaces, and then describes several possible improvements.
  Significant attention is given to improvement ideas based on
  considering transactions within the context of the next block
  template---the proposed block a miner would create and then commit to
  when attempting to produce a proof of work.  By evaluating the impact
  of a replacement on the next block template, it's possible to
  determine for certain, without the use of heuristics, whether or not
  it will earn the miner of that next block more fee income.  Several
  developers replied with comments on Zhao's summary and her proposals,
  including additional or alternative proposals for changes that
  could be made.

    Discussion appeared to be ongoing as this summary was being written.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Add usage examples][reviews 748] is a PR by Elichai Turkel to add usage
examples for ECDSA signatures, [schnorr signatures][topic schnorr signatures], and ECDH key exchanges. This
was the first review club meeting for a libsecp256k1 PR. Participants discussed
the importance of good randomness sources, walked through the examples, and
asked general questions about libsecp256k1.

{% include functions/details-list.md
  q0="Why do the examples show how to obtain randomness?"
  a0="The security of many cryptographic schemes in this library rely on secret
keys, nonces, and salts being secret/random. If an attacker is able to guess or
influence the values returned by our randomness source, they may be able to
forge signatures, learn information we are trying to keep confidential, guess
keys, etc. As such, the challenge of implementing a cryptographic scheme often
lies in obtaining randomness. The usage examples highlight this fact."
  a0link="https://bitcoincore.reviews/libsecp256k1-748#l-99"

  q1="Is it a good idea to make recommendations for how to obtain randomness?"
  a1="The main user of libsecp256k1, Bitcoin Core, has its own algorithm for
randomness which incorporates the OS, messages received on the p2p network, and
other sources of entropy. For other users who have to 'bring your own entropy',
recommendations may be helpful to users since a good source of randomness is so
crucial and OS documentation is not always clear. A maintenance burden for these
recommendations exists, since they may become outdated depending on OS support
and vulnerabilities, but it is expected to be minimal since these APIs change
very infrequently."
  a1link="https://bitcoincore.reviews/libsecp256k1-748#l-120"

  q2="Can you follow the examples added in the PR? Is anything missing from them?"
  a2="Participants discussed their experience compiling and running the
examples, using debuggers, comparing the example code with Bitcoin Core usage,
and considering the UX for non-Bitcoin users.
One participant pointed out that not verifying the schnorr signature
after producing it was a deviation from the Bitcoin Core code and [BIP340][]
recommendation. Another participant suggested demonstrating the usage of
`secp256k1_sha256` before `secp256k1_ecdsa_sign`, as forgetting to
hash the message could be a potential user footgun."
  a2link="https://bitcoincore.reviews/libsecp256k1-748#l-193"

  q3="What can happen if a user forgets to do something like verify the
signature after signing, call `seckey_verify`, or randomize the context?"
  a3="In the worst case scenario, if there is a flaw in the implementation,
forgetting to verify the signature after signing could mean accidentally giving
out an invalid signature. Forgetting to call `seckey_verify` after randomly
generating a key means there is a (negligible) probability of having an invalid
key. Randomizing the context is intended to protect against side channel
attacks---it blinds the intermediary values which have no impact on the end
result but may be exploited to gain information about the operations performed."
  a3link="https://bitcoincore.reviews/libsecp256k1-748#l-226"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.14.2-beta][] is the release for a
  maintenance version that includes several bug fixes and a few minor
  improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23508][] Add getdeploymentinfo RPC FIXME:Xekyo

- [Bitcoin Core #21851][] adds support for building for arm64-apple-darwin
  (Apple M1).  With the changes now merged, the community can expect working
  M1 binaries in the next release.

- [Bitcoin Core #16795][] updates the `getrawtransaction`, `gettxout`,
  `decoderawtransaction`, and `decodescript` RPCs to return the inferred
  [output script descriptor][topic descriptors] for any scriptPubKeys
  that are decoded.

- [LND #6226][] sets 5% as the default fee for payments routed through
  LN when created using the legacy `SendPayment`, `SendPaymentSync`, and
  `QueryRoutes` RPCs.  Payments sent using the newer `SendPaymentV2` RPC
  default to zero fees, essentially requiring users to specify a value.
  An additional merged PR, [LND #6234][], defaults to 100% fees for
  payments of less than 1,000 satoshis made with the legacy RPCs.

- [LND #6177][] allows the users of the [HTLC][topic HTLC] interceptor
  to specify the reason an HTLC was failed, making the interceptor more
  useful for testing how failures affect software using LND.

- [LDK #1227][] improves the route-finding logic to account for known
  historical payment failures/successes. These failures/successes are used to
  determine the upper and lower bounds of channel balances, which gives the
  route-finding logic a more accurate success probability when evaluating
  routes. This is an implementation of some ideas previously described
  by René Pickhardt and others as mentioned in previous newsletters
  (including [#142][news142 pps], [#163][news163 pickhardt richter
  paper], and [#172][news172 cl4771]).

- [HWI #549][] adds support for [PSBT][topic psbt] version two as
  specified in [BIP370][].  When using a device that natively supports
  version zero PSBT, such as existing Coldcard hardware signing devices,
  v2 PSBTs are translated to v0 PSBTs.

- [HWI #544][] adds support for receiving and spending [taproot][topic
  taproot] payments with Trezor hardware signing devices.

{% include references.md %}
{% include linkers/issues.md v=1 issues="23508,21851,16795,6226,6234,6177,1227,549,544" %}
[lnd 0.14.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.2-beta
[zhao rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019817.html
[news163 pickhardt richter paper]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news142 pps]: /en/newsletters/2021/03/31/#paper-on-probabilistic-path-selection
[news172 cl4771]: /en/newsletters/2021/10/27/#c-lightning-4771
[reviews 748]: https://bitcoincore.reviews/libsecp256k1-748
