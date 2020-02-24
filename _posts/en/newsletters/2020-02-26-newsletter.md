---
title: 'Bitcoin Optech Newsletter #86'
permalink: /en/newsletters/2020/02/26/
name: 2020-02-26-newsletter
slug: 2020-02-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the 2020 Chaincode
Residency program, describes two proposed routing improvements for
LN, summarizes three interesting talks from the Stanford Blockchain
Conference, links to popular questions and answers from the Bitcoin
StackExchange, and lists several notable changes to popular Bitcoin
infrastructure software.

## Action items

- **Apply to the Chaincode Residency:** Chaincode Labs [announced][residency announcement] its
  [fifth residency program][residency] to be held in New York this June.
  The program consists of two seminar and discussion series
  covering Bitcoin and Lightning protocol development.  Developers
  interested in contributing to open source projects may
  [apply][residency apply] for either the Bitcoin series, the LN series,
  or both.  Applicants from all backgrounds are welcomed, and Chaincode
  will cover travel and accommodation costs as needed.

*Note: the list of releases and release candidates has
been moved to its own [section][release rc section].*

## News

- **Reverse up-front payments:** as described in [Newsletter #72][news72
  upfront], LN developers have been looking for a way to charge a small
  fee for routing an LN payment (HTLC) even if the payment is rejected.
  This can discourage payments that are designed to consume bandwidth
  and liquidity before ultimately failing at no cost.
  This week, Joost Jager [proposed][jager up-front] a new scheme where
  up-front fees are paid from the receiver of an HTLC back towards the
  sender of the payment.  For example, if a payment is being sent from
  Alice to Bob to Carol, then Alice receives a small fee from Bob and
  Bob receives a small fee from Carol.  The fee would be proportional to
  the amount of time the HTLC remained pending, which would incentivize
  quickly routing or rejecting HTLCs and would ensure users of [hold
  invoices][topic hold invoices] (for example,  Carol) paid the routing
  nodes (such as Bob) for tying up their routing capital.

    Several responders seemed to like the idea and began discussing how
    it might be implemented as well as what technical challenges it
    would need to overcome.

- **LN direct messages:** Rusty Russell [proposed][russell dm] allowing
  LN nodes to route encrypted messages between peers without using the
  LN payments mechanism.  This could replace current uses of
  messages-over-payments, such as [Whatsat][], with a simpler protocol
  that might be easier to build upon (such as for the *offers* idea
  described in [Newsletter #72][news72 offers]).  Russell's proposal
  originally specified using the same there-and-back onion routing used
  for LN payments (HTLCs), but developer ZmnSCPxj [proposed][zmn circular] having the
  message sender specify the full path from their node to the message
  recipient and back to the sender.  For example, if Alice wants to
  communicate with Carol, she might choose the following path:

        Alice → Bob → Carol → Dan → Alice

    This type of circle routing would make surveillance more difficult
    and would eliminate the overhead for routing nodes of having to
    store the return path, making the protocol stateless for routing
    nodes.  Discussion remains ongoing as of this writing, with a focus
    on enhancing privacy and preventing the mechanism from being abused
    for spam.

## Notable talks from the 2020 Stanford Blockchain Conference

The Stanford Center for Blockchain Research hosted its annual
[Stanford Blockchain Conference][sbc] last week. The conference included
over 30 presentations across three days. We've summarized three talks
that we think will be of particular interest to Optech newsletter readers.

We thank the conference organizers for putting together the program and
making videos of the talks available online ([day 1][], [day 2][], [day 3][]),
and Bryan Bishop for providing [transcripts][].

- **An Axiomatic Approach to Block Rewards:** Tim Roughgarden
  presented his work with Xi Chen and Christos Papadimitriou analyzing
  Bitcoin's block reward allocation rule from a [mechanism design][] theory
  perspective. ([transcript][axiomatic txt], [video][axiomatic vid],
  [paper][axiomatic paper]).

    Roughgarden began his talk by introducing _mechanism design_ as the inverse
    of the better-known _game theory_. Game theory describes
    the rules of a game and then reasons about what equilibria and behavior are
    the result of those rules. By contrast, mechanism design starts with an intended
    outcome and tries to design game rules that will result in that desired outcome.
    Roughgarden asks "Wouldn't it be nice if we had a mathematical
    description of the space of block chain protocols [...] and we could [...
    pick our] favorite objective function and [...] find a protocol that is optimal?"
    Roughgarden then gives three 'axioms' for desired behavior when
    designing the reward mechanism for a block chain:

    1. _sybil resistance_:
       no miner should be able to increase their reward by splitting their
       public identity into multiple parts.

    2. _collusion resistance_:
       no group of miners should be able to increase their reward by joining their
       independent identities into a single joined identity.

    3. _anonymity_: the reward distribution should not depend
       on the miners' public identities, and if the miners' hashrates are
       permuted, then the reward should be permuted in the same ways.

    The paper then gives a formal proof that the unique reward mechanism that
    satisfies these axioms is a proportional mechanism (i.e. that each miner
    receives rewards proportional to their hashrate).
    The paper only deals with the theory around the creation of a single block,
    and so does not consider longer-term strategies like [selfish mining][].

    The result may appear to be self-evident to people familiar with
    Bitcoin, but the formal treatment seems novel and may be a good
    basis for
    exploring more complex behavior for miners (eg long-term strategies and
    pooling behavior).

- **Boomerang: Redundancy Improves Latency and Throughput in Payment-Channel Networks:**
  Joachim Neu presented his work with Vivek Bagaria and David Tse on reducing latency
  and preventing liquidity lock-up when using [atomic multipath payments][topic multipath
  payments] in payment channel networks such as Bitcoin's Lightning Network.
  ([transcript][boomerang txt], [video][boomerang vid], [paper][boomerang
  paper]).

    Multipath payments suffer from the "everyone-waits-for-the-last"
    _straggler problem_. This concept from distributed computing describes how, if a
    goal depends on n tasks, then the goal must wait for the slowest of all n of
    those tasks to complete. In the context of a multipath payment, this means that
    if a payer wants to pay 0.05 BTC split into five parts of 0.01 BTC, the
    payment will only complete when all of those constituent parts complete. This
    leads to high latency for payments and reduced routing liquidity, particularly if one or more
    of the parts fails and needs to be retried.

    A common approach to fixing the straggler problem is to introduce
    redundancy. In our example above, this would involve the payer making
    seven partial payments of 0.01 BTC, and the receiver claiming the first five
    of those payments that successfully route. The problem then becomes how to
    prevent the receiver from claiming all seven parts resulting in an
    overpayment of 0.02 BTC.

    Neu et al. present a novel scheme called a _boomerang_ contract. The receiver
    selects the pre-images for the payment parts as shares in a [publicly
    verifiable secret sharing][pvss] scheme. In our example above, the secret can
    be reconstructed from six of the seven payment pre-images. The payer then
    constructs the seven payment parts, but each payment part is associated
    with a reverse (boomerang) condition that pays the payer back the full amount
    if the payer knows the full secret. If the receiver claims five or fewer
    of the payment parts, the payer never learns the full secret, and the
    boomerang clause cannot be invoked, but if the receiver cheats and
    claims six or more of the parts, then the payer is able to invoke the
    boomerang clause of the contract and none of the payment parts can be
    redeemed by the receiver.

    The paper goes on to describe an implementation of boomerang contracts in
    Bitcoin using [adaptor signatures][] based on a schnorr signature scheme.
    Neu also noted that it is possible to create adaptor signatures
    over ECDSA, so boomerang contracts could theoretically be implemented in Bitcoin today.

- **Remote Side-Channel Attacks on Anonymous Transactions:** Florian Tramer
  presented his work with Dan Boneh and Kenneth G. Paterson on timing
  side-channel and traffic-analysis attacks on user privacy in Monero and Zcash.
  ([transcript][side-channel txt], [video][side-channel vid],
  [paper][side-channel paper]).

    Monero and Zcash are privacy-focused cryptocurrencies which use
    cryptographic techniques ([ring signatures][] and [bulletproofs][]
    for Monero and [zk-SNARKs][] for Zcash) to hide the sender's identity,
    receiver's identity, and amounts in a transaction from the public ledger.
    Tramer et al. show that even if these cryptographic constructions are
    correct, implementation details can allow information about the
    identities and amounts to be leaked to adversaries on the network.

    When a Monero or Zcash node receives a transaction from the peer-to-peer
    network, that transaction is passed to the node's wallet to determine
    if the transaction belongs to the wallet.
    If the
    transaction does belong to the wallet, then the wallet must do additional computation
    to decrypt the data and amounts from the transaction, and if the wallet pauses
    its node's peer-to-peer activity while it is doing this additional computational work,
    then an adversary can use a [timing attack][] to discover which transactions
    are associated with which node. The authors demonstrate that these timing attacks
    can be carried out remotely (across a WAN connection from London to Zurich)
    and that it may also be possible to use similar timing attacks to reveal
    the amounts in Zcash transactions.

    The attacks in the paper do not apply to Bitcoin Core, since the difference
    in computation that the Bitcoin Core wallet does for its own transactions
    and other transactions is minimal (no advanced cryptography is involved),
    and since v0.16, wallet operations have been processed asynchronously from peer-to-peer
    behavior (see [Bitcoin Core #10286][]). However, the observations
    in the paper are sufficiently general to be interesting to anyone implementing
    systems on Bitcoin, namely that allowing wallet or application processing to
    affect peer-to-peer behavior can leak information.

Related: the Optech newsletter summarized a selection of talks from last year's Stanford
Blockchain Conference in [Newsletter #32][news46 sbc].

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure.
Please consider upgrading to new releases or helping to test release
candidates.*

- [Bitcoin Core 0.19.1][] (release candidate)

- [LND 0.9.1][] (release candidate)

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #13339][] allows the wallet name to be passed as an argument to a user-provided
  `walletnotify` transaction notification script. Previously only the txid was
  passed to the `walletnotify` script, which made it difficult for users running
  in multi-wallet mode to determine which wallet received the incoming
  transaction. This change is part of an ongoing effort to enhance [multi-wallet
  support][].  The change is not currently supported on Windows.

- [Eclair #1325][] allows the `SendToRoute` endpoint to accept routing
  hints that can help the spending node find a path to the receiving
  node.

- [BOLTs #682][] allows the `init` message to include a `networks` field
  with the identifier (chain hash) for the networks the node is
  interested in, which may help prevent nodes on one network (e.g.
  testnet) from connecting to nodes on another network (e.g. mainnet).

- [BOLTs #596][] updates [BOLT2][] to allow LN nodes to advertise that
  they'll accept channel opens over the previous maximum value limit of
  about 0.17 BTC.  This is one of the features of the "wumbo" proposal,
  the other feature being the ability to send larger payments in a
  channel.  See [Newsletter #22][news22 wumbo] for details.

## Acknowledgements

We thank Joachim Neu and Tim Roughgarden for their review of a draft of this
newsletter's Stanford Blockchain Conference talk summaries. Any remaining
errors are the fault of the newsletter author.

{% include references.md %}
{% include linkers/issues.md issues="1325,886,682,596,13339,10286" %}
[residency]: https://residency.chaincode.com
[residency announcement]: https://medium.com/@ChaincodeLabs/chaincode-summer-residency-2020-e80811834fa8
[residency apply]: https://residency.chaincode.com/#apply
[side-channel txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/linking-anonymous-transactions/
[side-channel vid]: https://youtu.be/JhZUItnyQ0k?t=7706
[side-channel paper]: https://crypto.stanford.edu/timings/paper.pdf
[news46 sbc]: /en/newsletters/2019/02/05/#notable-talks-from-the-stanford-blockchain-conference
[axiomatic txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/block-rewards/
[axiomatic vid]: https://youtu.be/BXLcKQ6fLsU?t=8545
[axiomatic paper]: https://arxiv.org/pdf/1909.10645.pdf
[boomerang txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/boomerang/
[boomerang vid]: https://youtu.be/cNyB-MJdI20?t=6530
[boomerang paper]: https://arxiv.org/pdf/1910.01834.pdf
[sbc]: https://cbr.stanford.edu/sbc20/
[transcripts]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/
[day 1]: https://www.youtube.com/watch?v=JhZUItnyQ0k
[day 2]: https://www.youtube.com/watch?v=BXLcKQ6fLsU
[day 3]: https://www.youtube.com/watch?v=cNyB-MJdI20
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[sipa nonce updates]: https://github.com/sipa/bips/pull/198
[lnd 0.9.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.1-beta.rc1
[release rc section]: #releases-and-release-candidates
[news72 upfront]: /en/newsletters/2019/11/13/#ln-up-front-payments
[jager up-front]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002547.html
[russell dm]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002552.html
[whatsat]: https://github.com/joostjager/whatsat
[news72 offers]: /en/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[news83 nonce safety]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news22 wumbo]: /en/newsletters/2018/11/20/#wumbo
[multi-wallet support]: https://github.com/bitcoin/bitcoin/projects/2#card-31911994
[stack exchange harding target answer]: https://bitcoin.stackexchange.com/questions/23912/how-is-the-target-section-of-a-block-header-calculated/36228#36228
[mechanism design]: https://en.wikipedia.org/wiki/Mechanism_design
[selfish mining]: https://www.cs.cornell.edu/~ie53/publications/btcProcFC.pdf
[pvss]: https://en.wikipedia.org/wiki/Publicly_Verifiable_Secret_Sharing
[adaptor signatures]: https://download.wpsoftware.net/bitcoin/wizardry/mw-slides/2018-05-18-l2/slides.pdf
[ring signatures]: https://en.wikipedia.org/wiki/Ring_signature
[bulletproofs]: https://eprint.iacr.org/2017/1066.pdf
[zk-SNARKs]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[timing attack]: https://en.wikipedia.org/wiki/Timing_attack
[zmn circular]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002555.html
