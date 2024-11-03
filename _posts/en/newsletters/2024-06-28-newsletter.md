---
title: 'Bitcoin Optech Newsletter #309'
permalink: /en/newsletters/2024/06/28/
name: 2024-06-28-newsletter
slug: 2024-06-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes research into estimating the
likelihood that an LN payment is feasible.  Also included are our regular
sections with descriptions of popular questions and answers from the
Bitcoin Stack Exchange, announcements of new releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Estimating the likelihood that an LN payment is feasible:** René
  Pickhardt [posted][pickhardt feasible1] to Delving Bitcoin about
  estimating the likelihood that an LN payment is feasible given the
  public knowledge of a channel's maximum capacity but no knowledge
  about its current balance distribution.  For example, Alice has a
  channel with Bob and Bob has a channel with Carol.  Alice knows the
  capacity of the Bob-Carol channel but not how much of
  that balance is controlled by Bob and how much is controlled by Carol.

  Pickhardt notes that some wealth distributions are impossible in a
  payment network.  For example, Carol can't receive more money in her
  channel with Bob than the capacity of that channel.  When all the
  impossible distributions are excluded, it can be useful to consider
  all the remaining wealth distributions as equally likely to occur.
  That can be used to produce a metric for the likelihood that a payment
  is feasible.

  For example, if Alice wants to send a 1 BTC payment to Carol, and the
  only channels it can pass through are Alice-Bob and Bob-Carol, then
  we can look at what percentages of wealth distributions in the
  Alice-Bob channel and the Bob-Carol channel would allow that payment
  to succeed.  If the Alice-Bob channel has a capacity of several BTC,
  most possible wealth distributions would allow the payment to succeed.
  If the Bob-Carol channel has a capacity of just barely over 1 BTC, then
  most possible wealth distributions would prevent the payment from
  succeeding.  This can be used to calculate the overall likelihood
  of the feasibility of a payment of 1 BTC from Alice to Carol.

  The likelihood of feasibility makes it clear that many LN payments
  that naively seem possible will not succeed in practice.  It also
  provides a useful basis for making comparisons.
  In a [reply][pickhardt feasible2], Pickhardt describes how the
  likelihood metric could be used by wallets and business software to
  automatically make some intelligent decisions on behalf of its users. {% assign timestamp="1:04" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How is the progress of Initial Block Download (IBD) calculated?]({{bse}}123350)
  Pieter Wuille points to Bitcoin Core's `GuessVerificationProgress` function
  and explains that the estimated total transactions in the chain uses hardcoded
  statistics that are updated as part of each major release. {% assign timestamp="31:25" %}

- [What is `progress increase per hour` during synchronization?]({{bse}}123279)
  Pieter Wuille clarifies that progress increase per hour is the percentage of
  the blockchain synchronized per hour and not an increase in progress rate. He goes on
  to note reasons why progress is not constant and can vary. {% assign timestamp="33:50" %}

- [Should an even Y coordinate be enforced after every key-tweak operation, or only at the end?]({{bse}}119485)
  Pieter Wuille agrees that when to perform a key negation to enforce [x-only
  public keys][topic X-only public keys] is largely a matter
  of opinion while pointing out pros and cons within different protocols. {% assign timestamp="34:45" %}

- [Signet mobile phone wallets?]({{bse}}123045)
  Murch lists four [signet][topic signet]-compatible mobile wallet apps:
  Nunchuk, Lava, Envoy, and Xverse. {% assign timestamp="37:28" %}

- [What block had the most transaction fees? Why?]({{bse}}7582)
  Murch uncovers block 409,008 with the most bitcoin-denominated fees (291.533
  BTC caused by a missing change output) and block 818,087 with the most
  USD-denominated fees ($3,189,221.5 USD, also presumed to be caused by a missing
  change output). {% assign timestamp="39:01" %}

- [bitcoin-cli listtransactions fee amount is way off, why?]({{bse}}123391)
  Ava Chow notes this discrepancy occurs when Bitcoin Core's wallet is unaware of
  one of the inputs to a transaction, but knows others, as in the example given
  in the question of a [payjoin][topic payjoin] transaction. She goes on to note
  "The wallet really shouldn't be returning the fee here since it can't
  accurately determine it." {% assign timestamp="41:48" %}

- [Did uncompressed public keys use the `04` prefix before compressed public keys were used?]({{bse}}123252)
  Pieter Wuille explains that historically signature verification was done by the
  OpenSSL library that allows uncompressed (`04` prefix), compressed (`02` and
  `03` prefixes), and hybrid (`06` and `07` prefixes) public keys. {% assign timestamp="44:57" %}

- [What happens if an HTLC's value is below the dust limit?]({{bse}}123393)
  Antoine Poinsot points out that any output in a LN commitment transaction
  could have a value below the [dust limit][topic uneconomical outputs] which
  results in the satoshis in those outputs being used instead for fees (see
  [trimmed HTLCs][topic trimmed htlc]). {% assign timestamp="46:34" %}

- [How does subtractfeefrom work?]({{bse}}123262)
  Murch provides an overview of how [coin selection][topic coin selection] in
  Bitcoin Core works when the optional `subtractfeefrom` is used. He also notes
  using `subtractfeefromoutput` causes several bugs when finding changeless transactions. {% assign timestamp="47:11" %}

- [What's the difference between the 3 index directories "blocks/index/", "bitcoin/indexes" and "chainstate"?]({{bse}}123364)
  Ava Chow lists some data directories in Bitcoin Core:

  - `blocks/index` which contains the LevelDB database for the block index
  - `chainstate/` which contains LevelDB database for the UTXO set
  - `indexes/` which contains the txindex, coinstatsindex, and blockfilterindex optional indexes

  {% assign timestamp="51:19" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.18.1-beta][] is a minor release with a fix for "an [issue][lnd
  #8862] that arises when handling an error after attempting to
  broadcast transactions if a btcd backend with an older version
  (pre-v0.24.2) is used." {% assign timestamp="52:18" %}

- [Bitcoin Core 26.2rc1][] is a release candidate for a maintenance
  version of Bitcoin Core's older release series. {% assign timestamp="53:02" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29575][] simplifies the peer misbehavior scoring system to only
  use two increments: 100 points (results in immediate disconnection and
  discouragement) and 0 points (allowed behavior). Most types of misbehaviors
  are avoidable and have been bumped to a score of 100, while two
  behaviors that honest and correctly functioning nodes might perform
  under certain circumstances have been reduced to 0. This PR also
  removes the heuristic that only considers P2P `headers` messages
  containing a maximum of eight block headers as a possible [BIP130][]
  announcement of a new block. Bitcoin Core now treats all `headers`
  messages that don't connect to a block tree known by the node as
  potential new block announcements and requests any missing blocks. {% assign timestamp="53:29" %}

- [Bitcoin Core #28984][] adds support for a limited version of
  [replace-by-fee][topic rbf] for [packages][topic package relay]
  with clusters of size two (one parent, one child), including
  Topologically Restricted Until Confirmation ([TRUC][topic v3 transaction
  relay]) transactions (aka v3 transactions). These clusters can only replace an
  existing cluster of the same size or smaller. See [Newsletter #296][news296
  packagerbf] for related context. {% assign timestamp="56:38" %}

- [Core Lightning #7388][] removes the ability to create non-zero-fee
  [anchor-style][topic anchor outputs] channels to conform to changes in
  the BOLT specification made in 2021 (see [Newsletter #165][news165
  anchors]), while maintaining support for existing channels. Core
  Lightning was the only implementation to fully add this, and only in
  experimental mode, before it was discovered to be insecure (see
  [Newsletter #115][news115 anchors]) and replaced with zero-fee anchor
  channels. Other updates include rejecting `encrypted_recipient_data`
  containing both `scid` and `node`, parsing LaTeX formatting added to
  the onion specification,
  and other BOLT specification changes mentioned in Newsletters [#259][news259
  bolts] and [#305][news305 bolts]. {% assign timestamp="1:00:28" %}

- [LND #8734][] improves the payment route estimation abort process when a user
  interrupts the `lncli estimateroutefee` RPC command by making the payment loop
  aware of the client's streaming context. Previously, interrupting this command
  would cause the server to continue [payment probing][topic payment probes]
  routes unnecessarily. See Newsletter [#293][news293 routefee] for a previous
  reference to this command. {% assign timestamp="1:03:24" %}

- [LDK #3127][] implements non-strict forwarding to improve payment reliability,
  as specified in [BOLT4][], allowing [HTLCs][topic htlc] to be forwarded to a
  peer through channels other than the one specified by `short_channel_id` in
  the onion message. Channels with the least amount of outbound liquidity that
  can pass the HTLC are selected to maximize the probability of success for
  subsequent HTLCs. {% assign timestamp="1:03:59" %}

- [Rust Bitcoin #2794][] implements the enforcement of the redeem script size
  limit of 520 bytes for P2SH and of the witness script size limit of 10,000
  bytes for P2WSH by adding fallible constructors to `ScriptHash` and
  `WScriptHash`. {% assign timestamp="1:05:39" %}

- [BDK #1395][] removes the `rand` dependency in both explicit and implicit
  usage, replacing it with `rand-core` to simplify dependencies, avoid the added
  complexity of `thread_rng` and `getrandom`, and provide greater flexibility by
  allowing users to pass their own Random Number Generators (RNGs). {% assign timestamp="1:07:05" %}

- [BIPs #1620][] and [BIPs #1622][] add changes to [BIP352][]
  specification of [silent payments][topic silent payments].
  Discussions in the PR implementing silent payments in the `secp256k1` library
  recommend adding corner-case handling to [BIP352][], specifically to handle
  invalid private/public key sums for sending and scanning: fail if private key
  sum is zero (for sender), and fail if public key sum is point at infinity (for
  receiver). In #1622, BIP352 is changed to calculate `input_hash`
  after key aggregation, not before, to reduce redundancy and make the process
  clearer for both sender and receiver. {% assign timestamp="1:08:55" %}

- [BOLTs #869][] introduces a new channel quiescence protocol on BOLT2, which
  aims to make [protocol upgrades][topic channel commitment upgrades]
  and major changes to payment channels safer and
  more efficient by ensuring a stable channel state during the process. The
  protocol introduces a new message type, `stfu` (SomeThing Fundamental is
  Underway), which can only be sent if the `option_quiesce` has been negotiated.
  Upon sending `stfu`, the sender stops all update messages. The receiver should
  then stop sending updates and respond with `stfu` if possible, so that the
  channel becomes completely quiescent. See Newsletters [#152][news152
  quiescence] and [#262][news262 quiescence]. {% assign timestamp="1:11:57" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29575,28984,7388,8734,3127,2794,1395,1620,1622,869,8862" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[pickhardt feasible1]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973
[pickhardt feasible2]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973/4
[lnd v0.18.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.1-beta
[news296 packagerbf]: /en/newsletters/2024/04/03/#bitcoin-core-29242
[news259 bolts]: /en/newsletters/2024/05/31/#bolts-1092
[news305 bolts]:/en/newsletters/2023/07/12/#ln-specification-clean-up-proposed
[news293 routefee]: /en/newsletters/2024/03/13/#lnd-8136
[news152 quiescence]: /en/newsletters/2021/06/09/#c-lightning-4532
[news262 quiescence]:/en/newsletters/2023/08/02/#eclair-2680
[news115 anchors]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news165 anchors]: /en/newsletters/2021/09/08/#bolts-824
