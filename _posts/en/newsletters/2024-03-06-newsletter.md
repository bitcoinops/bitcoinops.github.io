---
title: 'Bitcoin Optech Newsletter #292'
permalink: /en/newsletters/2024/03/06/
name: 2024-03-06-newsletter
slug: 2024-03-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about updating the
specification for BIP21 `bitcoin:` URIs, describes a proposal to manage
multiple concurrent MuSig2 signing sessions with a minimum of state,
links to a thread about adding editors for the BIPs repository, and
discusses a set of tools that allow quickly porting the Bitcoin Core
GitHub project to a self-hosted GitLab project.  Also included are our
regular sections announcing new releases and release candidates and summarizing
recent changes to popular Bitcoin infrastructure software.

## News

- **Updating BIP21 `bitcoin:` URIs:** Josie Baker [posted][baker bip21]
  to Delving Bitcoin to discuss how [BIP21][] URIs are specified to be
  used, how they're used today, and how they can be used in the future.
  The specification requires the body immediately after the colon to be
  a legacy P2PKH Bitcoin address, e.g. `bitcoin:1BoB...`.  After the
  body, additional parameters can be passed using HTTP query encoding,
  including addresses for non-legacy address formats.  For example, a
  bech32m address could be `bitcoin:1Bob...?bech32m=bc1pbob...`.
  However, this is significantly different from how `bitcoin:` URIs are
  being used.  Non-P2PKH addresses are often used as the body and
  sometimes the body is left blank by software that only wants to
  receive payment through an alternative payment protocol.
  Additionally, Baker notes that `bitcoin:` URIs are increasingly being
  used to transmit privacy-respecting persistent identifiers, such as
  those for [silent payments][topic silent payments] and [offers][topic
  offers].

  As discussed on the thread, an improvement could be having the
  creator of the URI specify all of the payment methods they supported
  using bare parameters, for example: `bitcoin:?bc1q...&sp1q...`.  The
  spender (who is usually responsible for paying fees) could then
  choose their preferred payment method from the list.  Although some
  minor technical points were still being discussed at the time of
  writing, no major criticisms of this approach have been posted. {% assign timestamp="18:07" %}

- **PSBTs for multiple concurrent MuSig2 signing sessions:** Salvatore
  Ingala [posted][ingala musig2] to Delving Bitcoin about minimizing the
  amount of state needed to perform multiple [MuSig2][topic musig]
  signing sessions in parallel.  Using the signing algorithm described
  in [BIP327][], a group of co-signers will need to temporarily store a
  linearly increasing amount of data for each additional input they want
  to add to a transaction they create.  With many hardware signing
  devices limited in the amount of storage they have available, it would
  be very useful to minimize the amount of state required (without
  reducing security).

  Ingala proposes generating a single state object for an entire
  [PSBT][topic psbt] and then deterministically deriving the per-input
  state from it in a way that still makes the result indistinguishable
  from random.  That way the amount of state a signer needs to store is
  constant no matter how many inputs a transaction has.

  In a [reply][scott musig2], developer Christopher Scott noted that
  [BitEscrow][] already uses a similar mechanism. {% assign timestamp="46:30" %}

- **Discussion about adding more BIP editors:** Ava Chow [posted][chow
  bips] to the Bitcoin-Dev mailing list to suggest the addition of BIP
  editors to help the current editor.  The current editor, Luke Dashjr,
  [says][dashjr backlogged] he is backlogged and has requested help.
  Chow suggested two well-known expert contributors to become editors,
  which seemed to have support.  Also discussed was whether the
  additional editors should have the ability to assign BIP numbers.  No
  clear resolution has been reached as of this writing. {% assign timestamp="58:33" %}

- **GitLab backup for Bitcoin Core GitHub project:** Fabian Jahr
  [posted][jahr gitlab] to Delving Bitcoin about maintaining a backup of
  the Bitcoin Core project's GitHub account on a self-hosted GitLab
  instance.  In case the project ever needed to leave GitHub suddenly,
  this would make all existing issues and pull requests accessible on
  GitLab within a short amount of time, allowing work to continue with
  only a brief interruption.  Jahr provided a preview of the project on
  GitLab and plans to keep backups going forward to allow rapidly
  switching to GitLab if necessary.  His post has not received any
  comments as of this writing, but we thank him for making a potential
  transition as easy as possible. {% assign timestamp="1:11" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair v0.10.0][] is a new major release of this LN node
  implementation.  It "adds official support for the [dual-funding
  feature][topic dual funding], an up-to-date implementation of BOLT12
  [offers][topic offers], and a fully working [splicing][topic splicing]
  prototype" in addition to "various on-chain fee improvements, more
  configuration options, performance enhancements and various minor bug
  fixes". {% assign timestamp="1:03:24" %}

- [Bitcoin Core 26.1rc1][] is a release candidate for a maintenance release
  of this predominant full node implementation. {% assign timestamp="1:05:18" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #29412][] adds code that checks for every known way to
  take a valid block, mutate it, and produce an alternative block that
  is invalid but has the same block header hash.  Mutated blocks have
  caused multiple vulnerabilities in the past.  In 2012, and again in
  2017, Bitcoin Core's cached rejection of invalid blocks meant that an
  attacker could take a new valid block, mutate it into an invalid
  block, and submit it to a victim's node; that node would reject it as
  invalid and would not later accept the valid form of the block (until
  the node was next restarted), forking it off the best block chain and
  allowing the attacker to perform a type of [eclipse attack][topic
  eclipse attacks]; see [Newsletter #37][news37 invalid] for details.
  More recently, when Bitcoin Core would request a block from one peer,
  a different peer could send a mutated block that would lead Bitcoin
  Core to stop waiting for the block from the first peer; a fix for this
  was described in [Newsletter #251][news251 block].

  The code added in this PR allows quickly checking whether a
  newly-received block contains one of the known mutation types that
  makes it invalid.  If so, the mutated block can be rejected early
  on, hopefully preventing anything about it from being cached or used
  to prevent the correct processing of a valid version of the block that
  will be received later. {% assign timestamp="1:06:53" %}

- [Eclair #2829][] allows plugins to set a policy for contributing funds
  towards a [dual-funded channel open][topic dual funding].  By default,
  Eclair will not contribute funds towards opening a dual-funded
  channel.  This PR allows plugins to override that policy and decide
  how much of the node operator's funds should be contributed towards a
  new channel. {% assign timestamp="1:17:29" %}

- [LND #8378][] makes several improvements to LND's [coin
  selection][topic coin selection] features, including allowing users to
  choose their coin selection strategy and also allowing a user to
  specify some inputs that must be included in a transaction but
  allowing the coin selection strategy to find any additional needed
  inputs. {% assign timestamp="1:19:06" %}

- [BIPs #1421][] adds [BIP345][] for the `OP_VAULT` opcode and related
  consensus changes that, if activated in a soft fork, would add support
  for [vaults][topic vaults].  Unlike vaults possible today with
  presigned transactions, BIP345 vaults aren't vulnerable to last-minute
  transaction substitution attacks.  BIP345 vaults also allow
  [batched][topic payment batching] operations that make them more
  efficient than most proposed designs that only use more generic
  [covenant][topic covenants] mechanisms. {% assign timestamp="1:20:28" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29412,2829,8378,1421" %}
[jahr gitlab]: https://delvingbitcoin.org/t/gitlab-backups-for-bitcoin-core-repository/624
[ingala musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626
[scott musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626/2
[baker bip21]: https://delvingbitcoin.org/t/revisiting-bip21/630
[bitescrow]: https://github.com/BitEscrow/escrow-core
[chow bips]: https://gnusha.org/pi/bitcoindev/2092f7ff-4860-47f8-ba1a-c9d97927551e@achow101.com/
[dashjr backlogged]: https://twitter.com/LukeDashjr/status/1761127972302459000
[news37 invalid]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
[news251 block]: /en/newsletters/2023/05/17/#bitcoin-core-27608
[eclair v0.10.0]: https://github.com/ACINQ/eclair/releases/tag/v0.10.0
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
