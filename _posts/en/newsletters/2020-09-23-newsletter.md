---
title: 'Bitcoin Optech Newsletter #116'
permalink: /en/newsletters/2020/09/23/
name: 2020-09-23-newsletter
slug: 2020-09-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed soft fork to enable a new
type of fee bumping and summarizes research into scripts that can never
be spent because they require satisfying both timelocks and heightlocks.
Also included are our regular sections with summaries of updates to
services and client software, a list of new releases and release
candidates, and changes to popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Transaction fee sponsorship:** Jeremy Rubin [posted][rubin sponsor
  bumping] a proposal to the Bitcoin-Dev mailing list for a soft fork to
  add a new fee bumping mechanism that could be less vulnerable to abuse
  than the current Replace-by-Fee ([RBF][topic rbf]) and
  Child-Pays-For-Parent ([CPFP][topic cpfp]) methods.  [Transacting
  pinning][topic transaction pinning] and other abuses
  against the existing system can be used to attack contract
  protocols.  These problems have led to partial solutions such as [anchor
  outputs][topic anchor outputs] that work with specific protocols (e.g.
  two-party LN channels) but aren't easy to generalize and so are
  somewhat unsatisfactory.

    At the consensus layer, Rubin proposes allowing transactions to
    optionally contain a special final output that commits to the txids
    of one or more other unconfirmed transactions.  The transaction with
    the special output, called a *sponsor transaction*, may only be included in
    a valid block if every one of the transactions it *sponsored* is
    also included in that same block.  This means a miner who wants the
    high feerate from a sponsor transaction will be incentivized to
    confirm low-feerate sponsored transactions.  Beyond their special
    sponsorship output, sponsor
    transactions are normal Bitcoin transactions.

    For the rules that control mempool acceptance and transaction relay
    (the *policy layer*), Rubin suggests a set of simple changes that allow anyone to
    sponsor any transaction currently in a mempool or to replace an
    existing sponsor transaction with a higher feerate alternative that
    makes the same commitment.  The goal is to ensure that, as long as a
    sponsor transaction follows the rules and pays a high enough
    feerate, it will propagate across the network without running afoul
    of pinning or other attacks.

    Rubin's proposal comes with a [reference implementation][rubin
    refimpl] and discussion of design tradeoffs and forward
    compatibility.  As of this writing, comments on the list have shown
    appreciation for Rubin's work but also describe two significant
    complications:

    - *Floating payments still pinnable:* Antoine Riard [notes][riard
      heavyweight tx] that, even with a [change][harding sponsor
      outpoints] to the proposal to allow sponsoring particular inputs,
      a malicious counterparty can pin a particular input signed with
      `SIGHASH_SINGLE` (e.g. HTLCs in the latest LN protocol or state
      transactions in [eltoo][topic eltoo]) by including that input in a
      maximum size transaction.

    - *Breaks reorg safety guarantee:* Suhas Daftuar [reminds][daftuar
      principle] readers of a founding principle of Bitcoin's design.  As
      Satoshi Nakamoto [wrote][nakamoto later block], "In the event of a
      block chain reorg [...], transactions need to be able to get into
      the chain in a later block."  This principle is broken by sponsor
      transactions which are only valid in the same block as the
      transactions they sponsor.

    The proposal was still being actively discussed just hours before
    publication of this newsletter.  We'll summarize any new notable
    discussion in future editions.

- **Research into conflicts between timelocks and heightlocks:** A
  [post][blockstream post] to the Blockstream engineering blog describes
  an interaction between different types of Bitcoin time locks
  (timelocks) and block-height locks (heightlocks).  All transactions
  since Bitcoin's initial release have had an `nLockTime` field.  A soft
  fork activating at block 31,000 (December 2009) began
  [comparing][time-height-lock fork] this field against a block header's
  explicit time field and its implicit height (number of blocks since
  the Genesis Block).  A block is only valid if
  every one of its transactions follows these two
  rules:[^final-sequence]

    - If a transaction's nLockTime is below 500 million, it must also be
      below the block's height.

    - If a transaction's nLockTime is equal to or above 500 million, it
      must be below the block header's time (in [epoch time][]).

    This overloading of the single nLockTime field for two different
    purposes is efficient but has the obvious implication that a
    transaction can only use either a heightlock or timelock---not both.

    Years later, the [BIP65][] soft fork activated in December 2015
    added the `OP_CHECKLOCKTIMEVERIFY` (CLTV) opcode that compares its
    argument against its spending transaction's nLockTime field in the
    same way the nLockTime field is compared to the containing
    block's height or time field.  This allows scripts to prevent money
    received to them from being spent until after a certain future
    height or time.  However, the Blockstream post explains that this
    also has the non-obvious implication that it's possible to create a
    script that's unspendable because it requires the simultaneous use
    of both heightlocks and timelocks.  For example, a payment to the
    following script can never be spent:

       1 OP_CLTV OP_DROP 500000001 OP_CLTV

    The first condition allows the spending transaction to be included
    in block 1 or later, so any block after early January 2009, and the
    second condition allows it to be included in any block after early
    November 1985.  Both conditions are true today---but they can't both
    be satisfied using a transaction's single nLockTime field.  The post
    notes that the same problem can apply when a transaction has
    multiple inputs each with their own script.  For example:

        Input 0:
          1 OP_CLTV

        Input 1:
          500000001 OP_CLTV

    The problem also applies to relative timelocks and relative
    heightlocks created using [BIP68][] sequence numbers and the
    [BIP112][] `OP_CHECKSEQUENCEVERIFY` opcode.

    The post notes that the [Miniscript][topic miniscript] compiler has been updated to
    deal with the possible conflicts as best as possible.  It will
    identify when one or more of the ways to satisfy a script contains
    conflicting locks and will return a warning.  Because of the
    conflict, it'll also not be able to provide a full analysis of the
    script.  Additionally, the compiler for the policy language will now
    deliberately fail on policies that mix timelocks and heightlocks,
    e.g.  `thresh(3,after(1),after(500000001),pk(A))`.  Note: as of this
    writing, this change is only a [pending PR][rust-miniscript #121] to
    the Rust version of the miniscript library and has not yet
    propagated to the online live demos for [miniscript][miniscript demo] or [minsc][].

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.11.1-beta.rc4][lnd 0.11.1-beta] is the release candidate for a
  minor version.  Its release notes summarize its changes as, "a number
  of reliability improvements, some macaroon [authentication token]
  upgrades, and a change to make our version of [anchor commitments][topic
  anchor outputs] spec compliant."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16378][] adds a new `send` RPC to the wallet. This new
  RPC is designed for maximum flexibility and includes options such as
  multiple outputs (allowing [payment batching][]), [coin selection][topic coin
  selection], manual or automatic feerates, and [PSBT format][topic psbt]. It is
  intended to unify the functionality of the `sendtoaddress` and `sendmany` RPCs,
  which may be deprecated in a future release. For the full list of
  options, see the [RPC help text][send rpc help].

- [Bitcoin Core #19643][] adds a new `-netinfo` option to the `bitcoin-cli`
  command to display a peer connection dashboard. This dashboard offers
  human node operators a bird's-eye view of peer connection details such as
  directionality, relay type, network family, and uptime.  An optional
  argument from `0` to `4` may be passed to display various levels of
  detail.

- [Bitcoin Core #15454][] no longer creates a new wallet when the
  program is started for the first time.  Instead, the user is prompted
  to either load an existing wallet or create a new named wallet.
  Wallets created by default in earlier versions of the software will
  still be loaded by default, and newly created wallets can still be
  added to the load-on-start list (see [Newsletter #111][news111
  load_on_startup]).  By removing the default wallet creation, users
  gain more exposure to the options for customizing their wallet
  options, such as enabling wallet encryption, creating a watch-only
  wallet, or creating a wallet that's ready to import [output script
  descriptors][topic descriptors] (e.g. for multisig).

- [Bitcoin Core #19940][] updates the `testmempoolaccept` RPC with
  additional result fields for the transaction's vsize and total transaction fee if the
  transaction can be added to the mempool.  In particular, the fee is
  information that some users need, which is guaranteed to be available
  for a mempool transaction, and which cannot be trustlessly obtained
  before broadcasting a non-wallet transaction unless several other RPCs
  are run in sequence (e.g. using `decoderawtransaction` and
  `getrawtransaction`).

- [LND #4440][] records the number of times the local node sees a peer
  going offline and then coming back online, known as flapping.  The
  node will limit the number of event records it'll store about peers
  who frequently flap to avoid filling its database with too much noise.
  The `listchannels` RPC is also updated to display each peer's flap
  rate.

- [LND #4567][] adds a new `--maxchansize` configuration parameter that
  allows setting the maximum amount of money that can be contained in a
  new channel.  Now that LND supports [large channels][topic large
  channels] (see [Newsletter #107][news107 lnd wumbo]), this setting
  allows users to set a limit on the maximum amount of money they could potentially
  lose in a single channel if something goes wrong.

- [LND #4606][] and [#4592][lnd #4592] improves LND's effectiveness at
  fee bumping [anchor outputs][topic anchor outputs].  The first PR
  calculates the feerate needed to confirm both the child anchor
  transaction and its parent commitment transaction.  The second PR
  enables automatic fee bumping when a commitment transaction needs to
  be confirmed within the next several blocks.  <!-- currently 6
  blocks, but discussion on #4592 says they want to make this dynamic in
  the future, so just being general by saying "several blocks" here -->

## Footnotes

[^final-sequence]:
    Timelocks and heightlocks based on a transaction's nLockTime are a
    bit more complicated than described here due to an interaction
    with a transaction's one or more nSequence fields.  If all nSequence
    fields are set to their maximum value (`0xffffffff`), then the
    transaction can be included in any block.  For details about the
    possible motivation for the interaction between nLockTime and
    nSequence (and signature hash flags), see an [email][hearn high
    frequency] with quotes attributed to Satoshi Nakamoto.

    Additionally, the [BIP113][] soft fork activated in July 2016 means
    nodes now compare timelock values to a block's computed [Median Time
    Past][mtp] (MTP) rather than its explicit header time.

{% include references.md %}
{% include linkers/issues.md issues="16378,19643,15454,19940,4440,4567,4606,4592" %}
[lnd 0.11.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.1-beta.rc3
[news107 lnd wumbo]: /en/newsletters/2020/07/22/#lnd-4429
[blockstream post]: https://medium.com/blockstream/dont-mix-your-timelocks-d9939b665094
[hearn high frequency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-April/002417.html
[time-height-lock fork]: https://bitcoin.stackexchange.com/a/99104/21052
[epoch time]: https://en.wikipedia.org/wiki/Unix_time
[rust-miniscript #121]: https://github.com/rust-bitcoin/rust-miniscript/pull/121
[minsc]: https://min.sc/
[rubin sponsor bumping]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018168.html
[rubin refimpl]: https://github.com/bitcoin/bitcoin/compare/master...JeremyRubin:subsidy-tx
[news111 load_on_startup]: /en/newsletters/2020/08/19/#bitcoin-core-15937
[mtp]: https://bitcoin.stackexchange.com/a/67622/21052
[miniscript demo]: http://bitcoin.sipa.be/miniscript/
[riard heavyweight tx]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018191.html
[harding sponsor outpoints]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018186.html
[daftuar principle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018195.html
[nakamoto later block]: https://bitcointalk.org/index.php?topic=1786.msg22119#msg22119
[payment batching]: https://github.com/bitcoinops/scaling-book/blob/master/x.payment_batching/payment_batching.md
[send rpc help]: https://github.com/bitcoin/bitcoin/blob/831b0ecea9156447a2b6a67d28858bc26d302c1c/src/wallet/rpcwallet.cpp#L3876-L3933
