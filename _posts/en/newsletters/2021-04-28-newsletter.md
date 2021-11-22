---
title: 'Bitcoin Optech Newsletter #146'
permalink: /en/newsletters/2021/04/28/
name: 2021-04-28-newsletter
slug: 2021-04-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a draft specification for LN splicing,
announces a workshop about transaction relay security, announces the
addition of ECDSA signature adaptor support to libsecp256k1-zkp, and
links to proposals to change the BIPs process.  Also included are our
regular sections with summaries of popular questions and answers from
the Bitcoin Stack Exchange, announcements of software releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

- **Draft specification for LN splicing:** Rusty Russell opened a
  [PR][bolts #863] to the Lightning Specifications repository
  ("BOLTs") proposing the protocol changes necessary to accommodate
  [splicing][topic splicing].   He also [posted][russell splicing post]
  a link for the PR to the Lightning-Dev mailing list.  Splicing will
  allow transferring funds from onchain outputs into an existing payment
  channel, or from an existing payment channel to independent onchain
  outputs, without the channel participants having to wait for a
  confirmation delay to spend the channel’s other funds.  This helps
  wallets hide from their users the technical details of managing
  balances. For example, Alice's wallet can automatically pay Bob
  offchain or onchain from the same payment channel---offchain using LN
  through that payment channel or onchain using a splice out
  (withdrawal) from that payment channel.

    Russell previously [proposed][russell old splice] a draft
    specification for splicing in 2018 (see [Newsletter #17][news17
    splice]) but this new draft has the advantage of being able to use
    the interactive funding protocol that's included as part of
    C-Lightning's experimental support for [dual funding][topic dual
    funding].

- **Call for topics in layer-crossing workshop:** Antoine Riard
  [posted][riard workshop] to both the Bitcoin-Dev and Lightning-Dev
  mailing lists about an upcoming IRC-based workshop he plans to host to
  discuss [challenges][riard zoology] with onchain transaction relay
  that affect layer-two protocols such as LN.  The goal is to build
  technical consensus among the participants about which proposals are
  especially worth perusing so that developers and reviewers can focus
  on those proposals in the short term.

    The post proposes an agenda that includes [package relay][topic
    package relay], fee sponsorship (see [Newsletter #116][news116
    sponsorship]), moving from [BIP125][] opt-in Replace By Fee
    ([RBF][topic rbf]) to full RBF, improving coordination of security
    response between primarily onchain projects such as full nodes and
    primarily offchain projects like LN nodes, and defining what mempool
    and relay policies can be reasonably depended upon by layer two
    protocols.  Riard also asks for additional topic suggestions from
    anyone planning to attend, with May 7th being the deadline for
    submissions.  The workshop will likely be held mid June.

- **Support for ECDSA signature adaptors added to libsecp256k1-zkp:**
  [signature adaptors][topic adaptor signatures] were originally
  described for Bitcoin by Andrew Poelstra using [schnorr][topic
  schnorr signatures]-based [multisignatures][topic multisignature].
  This allows a single signature to do up to three things at once: (1)
  prove its creator had access to a certain private key, (2) prove
  knowledge of an encryption key pre-selected by another party, (3)
  reveal a pre-selected encryption key to another party.  This allows a
  signature alone to do many of the things we currently do with Bitcoin
  scripts, suggesting adaptor signatures could be used to create "scriptless
  scripts".

    Accomplishing the same on ECDSA is not as easy.  However, Lloyd
    Fournier [suggested][fournier otves] it would be relatively simple
    if we separated goal #1 (proof of private key) from goals #2 and #3
    (proving and revealing encryption keys, AKA adaptors).  This
    requires using one signature object as just a signature and another
    signature object for the adaptors, so it uses `OP_CHECKMULTISIG` and
    is not quite as scriptless as before.  The separated construction also requires a [security
    warning][ecdh warning] related to reusing some of the involved keys
    with Elliptic Curve Diffie Hellman (ECDH) key exchange and ElGamal
    encryption.  Beyond that, this technique makes signature adaptors entirely
    usable on Bitcoin today, and it's what various [DLC][topic dlc]
    projects have been using.

    In April 2020, Jonas Nick implemented support for these simplified
    ECDSA signature adaptors in a draft PR (see [Newsletter #92][news92
    ecdsa adaptor]).  Jesse Posner [ported][libsecp256k1-zkp #117] and
    extended the PR to libsecp256k1-zkp, a fork of [libsecp256k1][] that
    supports more advanced cryptographic protocols.  This updated PR has
    now been merged after a detailed review process that involved
    several conversations that may be of interest to anyone seeking to
    better understand the security of signature adaptors.

- **Problems with the BIPs process:** after some drama on the BIPs
  repository (and perhaps some previous pent-up frustrations), several
  discussions were started on the mailing list about adding a [new BIPs
  editor][dashjr alm], using a [bot][corallo bot] to merge BIPs PRs, or
  abandoning the [centralized BIPs repository][corallo ignore repo]
  altogether.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are the different contexts where MTP is used in Bitcoin?]({{bse}}105522)
  David A. Harding defines Median Time Past (MTP) and outlines how MTP is used
  to:

    1. determine the validity of a block using its `nTime` field, controlling
       difficulty adjustment period times

    2. ensure that time only moves forward, simplifying [state transitions][bip9
       state] in BIP9

    3. eliminate the incentive for individual miners to confirm transactions
       with locktimes up to two hours in the future by lying about the
       current time, as fixed in [BIP113][bip113 spec]

- [Can Taproot be used to commit arbitrary data to chain without any additional footprint?]({{bse}}105346)
  Pieter Wuille answers by pointing out that while committing to data via
  `OP_RETURN` in a [tapleaf][news46 complex spending] is possible, techniques
  like [pay-to-contract][pay-to-contract se] and
  [sign-to-contract][sign-to-contract blog] are in use currently by Liquid and
  [OpenTimestamps][opentimestamps] and can be more efficient.

- [Why does the mined block differ so much from the block template?]({{bse}}105694)
  User Andy asks why block 680175 differs from what his `getblocktemplate` RPC
  had output around the same time that block was mined. Andrew Chow and Murch
  point out [Asicboost][asicboost se] as the reason the version field is
  different, while node-independent mempools and node uptime are considerations
  of the block's transaction discrepancies.

- [Isn't Bitcoin's hash target supposed to be a power of 2?]({{bse}}105618)
  Andrew Chow explains the 'leading zeros' explanation of difficulty
  targeting is an oversimplification and chytrik gives an example of
  a valid and invalid hash with the same number of leading zeros.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1] is a release candidate
  for a version of Bitcoin Core that contains activation logic for the
  proposed [taproot][topic taproot] soft fork.  Taproot uses
  [schnorr signatures][topic schnorr signatures] and allows the use of
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

- [Bitcoin Core #21595][] adds a new `addrinfo` command to the `bitcoin-cli`
  executable. Running `bitcoin-cli -addrinfo` returns a count of the network
  addresses of potential peers known to the node, split by network type. Sample
  output:

    ```
    $ bitcoin-cli -addrinfo
    {
      "addresses_known": {
        "ipv4": 14406,
        "ipv6": 2511,
        "torv2": 5563,
        "torv3": 2842,
        "i2p": 8,
        "total": 25330
      }
    }
    ```

- [Rust-Lightning #844][] adds support for message signing, signature
  verification, and public key recovery using a scheme compatible with those of
  [LND][LND #192], [C-Lightning][news69 signcheck rpc], and [Eclair][news110
  signmessage rpc].

- [BTCPay Server #2356][] adds support for multifactor authentication
  using the [WebAuthN/FIDO2][] protocols.  Existing multifactor
  authentication in BTCPay using [U2F][] continues to work.

- [Libsecp256k1 #906][] reduces the number of iterations needed to
  compute modular inverses from 724 to 590 when using a constant-time
  algorithm that should be more resistant to side-channel attacks than a
  variable-time algorithm.  The correctness of the algorithm was checked
  using the [Coq proof assistant][coq], with the most strict verification
  taking approximately 66 days of runtime.  See [Newsletter #136][news136
  safegcd] for more information about the algorithmic advance that led
  to this improvement.

{% include references.md %}
{% include linkers/issues.md issues="21595,844,2356,906,863,192" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[webauthn/fido2]: https://en.wikipedia.org/wiki/FIDO2_Project
[u2f]: https://en.wikipedia.org/wiki/Universal_2nd_Factor
[russell splicing post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002999.html
[russell old splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[riard workshop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/003002.html
[riard zoology]: https://github.com/ariard/L2-zoology
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[ecdh warning]: https://github.com/ElementsProject/secp256k1-zkp/pull/117/commits/6955af5ca8930aa674e5fdbc4343e722b25e0ca8#diff-0bc5e1a03ce026e8fea9bfb91a5334cc545fbd7ba78ad83ae5489b52e4e48856R14-R27
[news92 ecdsa adaptor]: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[libsecp256k1-zkp #117]: https://github.com/ElementsProject/secp256k1-zkp/pull/117
[dashjr alm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018835.html
[corallo bot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018849.html
[corallo ignore repo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018859.html
[news136 safegcd]: /en/newsletters/2021/02/17/#faster-signature-operations
[coq]: https://coq.inria.fr/
[news69 signcheck rpc]: /en/newsletters/2019/10/23/#c-lightning-3150
[news110 signmessage rpc]: /en/newsletters/2020/08/12/#eclair-1499
[bip9 state]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki#state-transitions
[bip113 spec]: https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki#specification
[news46 complex spending]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[opentimestamps]: https://opentimestamps.org/
[sign-to-contract blog]: https://blog.eternitywall.com/2018/04/13/sign-to-contract/
[pay-to-contract se]: https://bitcoin.stackexchange.com/a/37208/87121
[asicboost se]: https://bitcoin.stackexchange.com/a/56518/5406
