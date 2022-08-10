---
title: 'Bitcoin Optech Newsletter #212'
permalink: /en/newsletters/2022/08/10/
name: 2022-08-10-newsletter
slug: 2022-08-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about lowering the
default minimum transaction relay feerate in Bitcoin Core and other
nodes.  Also included are our regular sections with the summary of a
Bitcoin Core PR Review Club, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Lowering the default minimum transaction relay feerate:** Bitcoin
  Core only relays individual unconfirmed transactions that pay a
  [feerate of at least one satoshi per vbyte][topic default minimum
  transaction relay feerates] (1 sat/vbyte).  If a node's mempool fills
  with transactions paying at least 1 sat/vbyte, then a higher feerate
  will need to be paid.  Transactions paying a lower feerate can still
  be included in blocks by miners and those blocks will be relayed.
  Other node software implements similar policies.

    Lowering the default minimum feerate has been discussed in the past
    (see [Newsletter #3][news3 min]) but [hasn't been merged][bitcoin
    core #13922] into Bitcoin Core.  The topic saw renewed
    [discussion][chauhan min] in the past couple weeks:

    - *Individual change effectiveness:* it was [debated][todd min] by
      [several][vjudeu min] people how effective it was for individual
      node operators to change their policies.

    - *Past failures:* it was [mentioned][harding min] that the previous
      attempt to lower the default feerate was hampered by the lower
      rate also reducing the cost of several minor denial-of-service
      (DoS) attacks.

    - *Alternative relay criteria:* it was [suggested][todd min2] that
      transactions violating certain default criteria (such as the
      default minimum feerate) could instead fulfill some separate
      criteria that make DoS attacks costly---for example, if a modest amount
      of hashcash-style proof of work committed to the transaction to
      relay.

    The discussion did not reach a clear conclusion as of this writing.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Decouple validation cache initialization from ArgsManager][review club 25527]
is a PR by Carl Dong that separates node configuration logic from the
initialization of signature and script caches.
It is part of the [libbitcoinkernel project][libbitcoinkernel project].

{% include functions/details-list.md
  q0="What does the `ArgsManager` do?  Why or why not should it belong
in `src/kernel` versus `src/node`?"
  a0="ArgsManager is a global data structure for handling
configuration options (`bitcoin.conf` and command line arguments).
While the consensus engine may contain parameterizable values (namely,
the sizes of caches), a node does not need this data structure to stay
in consensus. Rather, as Bitcoin Core-specific functionality, code
handling these configuration options belongs in `src/node`."
  a0link="https://bitcoincore.reviews/25527#l-35"

  q1="What are the validation caches? Why would they belong in
`src/kernel` versus `src/node`?"
  a1="When a new block arrives, the most computationally expensive part of
validation is script (i.e. signature) validation for its transactions.
Since nodes keeping a mempool will have usually seen and validated
these transactions already, block validation performance is
significantly increased by caching (successful) script and signature
verifications. These caches are logically
part of the consensus engine because consensus-critical block
validation code needs them. As such, these caches belong in
`src/kernel`."
  a1link="https://bitcoincore.reviews/25527#l-45"

  q2="What does it mean for something to be consensus-critical if it
isn't a consensus rule? Does `src/consensus` contain all the
consensus-critical code?"
  a2="Participants agreed that signature verification enforces
consensus rules, while caching doesn't. However, if the caching code
contains a bug that results in storing invalid signatures, the node
would no longer be enforcing consensus rules. As such, signature
caching is considered consensus-critical. Consensus code doesn't
actually live in `src/kernel` or `src/consensus` yet; much of
the consensus rules and consensus-critical code lives in
`validation.cpp`."
  a2link="https://bitcoincore.reviews/25527#l-61"

  q3="What tools do you use for “code archeology” to understand the
background of why a value exists?"
  a3="Participants listed several commands and tools including `git
blame`, `git log`, entering the commit hash into the pull requests
page, using the Github `Blame` button when viewing a file, and using
the Github search bar."
  a3link="https://bitcoincore.reviews/25527#l-132"

  q4="This PR changes the type of `signature_cache_bytes` and
`script_execution_cache_bytes` from `int64_t` to `size_t`.
What is the difference between `int64_t`, `uint64_t`, and `size_t`,
and why should a `size_t` hold these values?"
  a4="The `int64_t` and `uint64_t` types are 64-bits (signed and
unsigned, respectively) across all platforms and compilers. The
`size_t` type is an unsigned integer guaranteed to be able to
hold the length (in bytes) of any object in memory; its size depends
on the system. As such, `size_t` is exactly suited for these variables
holding the cache sizes as a number of bytes."
  a4link="https://bitcoincore.reviews/25527#l-163"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 0.12.0rc1][] is a release candidate for the next major
  version of this popular LN node implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25610][] sets by default the startup option `-walletrbf` and uses
  by default the `replaceable` option for the RPCs `createrawtransaction` and `createpsbt`.
  Transactions created via the GUI were already opt-in [RBF][topic rbf]
  by default. This follows the update mentioned in
  [Newsletter #208][news208 core RBF], enabling node operators to
  switch their node's transaction replacement behavior from the
  default opt-in RBF (BIP125) to full RBF. RPC opt-in by default was
  proposed in 2017 in [Bitcoin Core #9527][] when the primary
  objections were the novelty at the time, the inability to bump
  transactions and the GUI not having functionality to disable RBF---all
  of which have since been addressed.

- [Bitcoin Core #24584][] amends [coin selection][topic coin selection] to prefer input sets
  composed of a single output type. This addresses scenarios in which
  mixed-type input sets reveal the change output of preceding
  transactions. This follows a related privacy improvement to [always
  match the change type][#23789] to a recipient output (see
  [Newsletter #181][news181 change matching]).

- [Core Lightning #5071][] adds a bookkeeper plugin that provides an
  accounting record of movements of bitcoins by the node running the
  plugin, including the ability to track the amount spent on fees.  The
  merged PR includes several new RPC commands.

- [BDK #645][] adds a way to specify which [taproot][topic taproot] spend paths to sign
  for.  Previously, BDK would sign for the keypath spend if it was able,
  plus sign for any scriptpath leaves it had the keys for.

- [BOLTs #911][] adds the ability for an LN node to announce a DNS
  hostname that resolves to its IP address.  Previous discussion about
  this idea was mentioned in [Newsletter #167][news167 ln dns].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25610,24584,5071,645,911,13922,9527" %}
[core lightning 0.12.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc1
[news208 core RBF]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news167 ln dns]: /en/newsletters/2021/09/22/#dns-records-for-ln-nodes
[news181 change matching]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[chauhan min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020784.html
[todd min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020800.html
[vjudeu min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020821.html
[harding min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020808.html
[todd min2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020815.html
[news3 min]: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee
[#23789]: https://github.com/bitcoin/bitcoin/issues/23789
[review club 25527]: https://bitcoincore.reviews/25527
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[`ArgsManager`]: https://github.com/bitcoin/bitcoin/blob/5871b5b5ab57a0caf9b7514eb162c491c83281d5/src/util/system.h#L172
