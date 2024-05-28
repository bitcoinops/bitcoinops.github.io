---
title: Coinjoin

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Coinjoin** is a trustless protocol for mixing UTXOs from multiple
  owners in order to make it difficult for outside parties to use the
  block chain's transaction history to determine who owns which coin.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: "Coinjoin: Bitcoin privacy for the real world"
    link: https://bitcointalk.org/index.php?topic=279249.0

  - title: "TumbleBit: An Untrusted Bitcoin-Compatible Anonymous Payment Hub"
    link: https://eprint.iacr.org/2016/575.pdf

  - title: "Zerolink: the Bitcoin fungibility framework"
    link: https://github.com/nopara73/ZeroLink

  - title: "WabiSabi: Centrally Coordinated Coinjoins with Variable Amounts"
    link: https://github.com/zkSNACKs/WabiSabi


## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: CoinjoinXT presentation
    url: /en/newsletters/2018/07/10/#coinjoinxt-and-other-techniques-for-deniable-transfers

  - title: BLS signatures library possibly useful for non-interactive coinjoins
    url: /en/newsletters/2018/08/07/#library-announced-for-bls-signatures

  - title: Sighash updates that can help hardware wallets participate in coinjoins
    url: /en/newsletters/2018/09/04/#proposed-sighash-updates

  - title: Question about Wasabi coinjoin mixing and exchange blacklisting
    url: /en/newsletters/2018/09/25/#how-likely-are-you-to-get-blacklisted-by-an-exchange-if-you-use-wasabi-wallet-s-coinjoin-mixing

  - title: Fidelity bonds for imporoved sybil resistance in distributed coinjoin
    url: /en/newsletters/2019/07/31/#fidelity-bonds-for-improved-sybil-resistance

  - title: "Simple Non-Interactive Coinjoin with Keys for Encryption Reused (SNICKER)"
    url: /en/newsletters/2019/09/04/#snicker-proposed

  - title: "2019 year-in-review: SNICKER"
    url: /en/newsletters/2019/12/28/#snicker

  - title: Evaluation of coinjoins without equal value inputs or outputs
    url: /en/newsletters/2020/01/08/#coinjoins-without-equal-value-inputs-or-outputs

  - title: "Wormhole: a protocol for sending payments as part of a chaumian coinjoin"
    url: /en/newsletters/2020/01/22/#new-coinjoin-mixing-technique-proposed

  - title: "Allowing hardware wallets to safely sign automated coinjoin transactions"
    url: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment

  - title: "Comparison of coinjoin privacy to coinswap privacy"
    url: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation

  - title: "WabiSabi: a protocol for coordinated coinjoins with arbitrary output values"
    url: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values

  - title: Candidate set based block templates may help fee bumping large coinjoins
    url: /en/newsletters/2021/06/02/#candidate-set-based-csb-block-template-construction

  - title: "JoinMarket 0.9.0 released with implementation of fidelity bonds for coinjoin sybil resistance"
    url: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds

  - title: "Sparrow 1.5.0 adds coinjoin suport"
    url: /en/newsletters/2021/10/20/#sparrow-adds-coinjoin-support

  - title: "WabiSabi implemented in Wasabi 2.0"
    url: /en/newsletters/2022/04/06/#wabisabi-alternative-to-payjoin

  - title: "Discussion about risks for coinjoin-style protocols of relaying taproot annexes"
    url: /en/newsletters/2023/06/14/#discussion-about-the-taproot-annex

  - title: Preventing coinjoin pinning with v3 transaction relay
    url: /en/newsletters/2023/06/28/#preventing-coinjoin-pinning-with-v3-transaction-relay

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Payjoin
    link: topic payjoin
  - title: "Coinjoin (Bitcoin Wiki: Privacy)"
    link: https://en.bitcoin.it/Privacy#CoinJoin
  - title: "Privacy Wiki"
    link: https://en.bitcoin.it/wiki/Privacy
  - title: "Coinjoins.org - Learn about collaborative bitcoin transactions"
    link: https://coinjoins.org/

---

On July 2nd 2011, the Bitcointalk user [Hashcoin][hashcoin ref] first described the concept of a collaborative transaction to achieve privacy. Later in 2013, the concept was named coinjoin after a [proposal][gmaxwell coinjoin] by Gregory Maxwell. He laid out the ideas and set up a developer bounty to make them a reality.

It took only 4 days after Maxwell’s post for someone to try to claim the bounty with the [first coinjoin coordinator implementation][first cj implementation]. In the months that followed, more projects were released with the goal of correctly implementing the coinjoin protocol: Bitprivacy, Sharedcoin, Coinmux, Darkwallet, CoinJumble, and CoinShuffle. They all had one thing in common: they failed to provide guaranteed privacy to the user.

On January 9th 2015, Chris Belcher announced Joinmarket. It was the first non-broken implementation of a coinjoin protocol. The idea was simple: set the incentives right by creating a market of takers and makers, allowing the latter to earn a fee for providing liquidity.

In November 2016, an alternative to coinjoins was released with Tumblebit. Users could create two fixed-amount payment channels to a Tumbler (coordinator) who can't steal their coins or deanonymize them. The coins get sent back to a user from the payment channels of other users. It takes a total of 4 transactions to complete, but you get a very high anonymity rate. The wallets Breeze and Hidden Wallet (now Wasabi Wallet) were the main clients to use this privacy technique.

On August 14th 2017, the ZeroLink paper was introduced as The Bitcoin Fungibility Framework. It was a collaboration between the Hidden Wallet (now Wasabi Wallet) and Samourai Wallet teams. The research paper was authored by Adam Ficsor (Nopara73) with some support from TDev. It provided a framework not only for a coinjoin protocol, but for privacy wallets in general.

On October 31st, 2018, Wasabi Wallet 1.0 was officially released publicly. It provided an efficient alternative to Joinmarket for less technical users and a full zero-link coinjoin implementation. Like Tumblebit, there was no need to trust the central coordinator. Unlike Tumblebit, you could get anonymity very quickly and for a low fee.

On June 25th, 2019, the Samourai Wallet team launched a coinjoin feature called Whirlpool, which implements the Zerolink protocol with one major change. Instead of registering non-private UTXOs as inputs in a coinjoin transaction and getting the exceeding change as a non-private output, a premixing transaction takes place beforehand. In it, excess change is separated from UTXOs to mix and from the coordinator fee. Subsequently, UTXOs to mix would form a coinjoin transaction that produces no toxic change outputs. Toxic change is a non-private change output that has a deterministic link back to its transaction input. It is understood as "toxic" as it has no plausible deniability.

In February 2021, the WabiSabi paper was published following extensive public discussions aimed at developing a third-generation coinjoin protocol. This new protocol introduced cryptographic advancements that eliminated the fixed output limit characteristic of earlier versions. As a result, it became feasible to break down total bitcoin amounts into varying output sizes while still providing privacy against the coordinator. This innovation significantly diminished the amount of toxic change created while still being able to mix important amounts. On the other hand, WabiSabi requires an important amount of similarly-valued inputs to work efficiently, which makes it non-trivial to run a coordinator.

On June 15th, 2022, Wasabi Wallet 2.0 was launched with the new WabiSabi coinjoin protocol. It also improved the user experience by automating the coinjoin process.

{% include references.md %}
[gmaxwell coinjoin]: https://bitcointalk.org/index.php?topic=279249.0
[first cj implementation]: https://github.com/calafou/coinjoin
[hashcoin ref]:https://bitcointalk.org/index.php?topic=12751.msg315793#msg315793