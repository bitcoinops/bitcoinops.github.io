---
title: "Bitcoin Optech Newsletter #24"
permalink: /en/newsletters/2018/12/04/
name: 2018-12-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to tweak Bitcoin Core's
relay policy for related transactions to help simplify onchain fees for
LN payments, mentions upcoming meetings about the LN protocol, and
briefly describes a new LND release and work towards a Bitcoin Core
maintenance release.

## Action items

- Bitcoin Core is preparing for upcoming [maintenance release][] 0.17.1.
  Maintenance releases include bugfixes and backports of minor features.
  Anyone intending to take this version is encouraged to review the list of
  [backported fixes][0.17.1 milestone] and help with testing when a release
  candidate is made available.

## News

- **CPFP carve-out:** in order to spend bitcoins, the transaction
  where you received those bitcoins must be added to the block chain
  somewhere before your spending transaction.  That addition can be in a
  previous block or it can be earlier in the same block as the spending
  transaction.  This protocol requirement means that a spending
  transaction with a high feerate can, through averaging, make it
  profitable to mine its unconfirmed parent transaction even if that
  parent has a low feerate.  This is called Child Pays For Parent
  (CPFP).

    CPFP even works for multiple descendant transactions, but the more
    relationships that need to be considered, the longer it takes the node
    to create the most profitable possible block template for
    miners to work on.  For this reason, Bitcoin Core
    limits[^fn-cpfp-limits] the maximum number and size of related
    transactions.  For users fee bumping their own transactions, the
    limits are high enough to rarely cause problems.  But for users of
    multiparty protocols, a malicious counterparty can exploit the
    limits to prevent an honest user from being able to fee bump a
    transaction.  This can be a major problem for protocols like LN that
    rely on timelocks---if a transaction isn't confirmed before the
    timelock expires, the counterparty can take back some or all of the
    funds they previously paid.

    To help solve this problem, Matt Corallo has [suggested][carve out
    thread] a change to the CPFP policy to carve-out (reserve) some
    space for a small transaction that only has one ancestor in the
    mempool (all of its other ancestors must already be in the block
    chain).  This accompanies a proposal for LN described in the *News*
    section of [last week's newsletter][] where LN would mostly ignore
    onchain fees (except for cooperative closes of channels) and use
    CPFP fee bumping to choose the fee when the channel was
    closed---reducing complexity and improving safety.  However, to make
    this safe for LN no matter how high fees get, nodes need to also
    support relaying packages of transactions that include both
    low-feerate ancestors plus high-feerate descendants in a way that
    doesn't cause nodes to automatically reject the earlier transactions
    as being too cheap and so not see the subsequent fee bumps.  Whereas
    the carve-out policy is probably easy to implement, package relay is
    something that's been discussed for a long time without yet being
    formally specificed or implemented.

- **Organization of LN 1.1 specification effort:** although LN protocol
  developers decided [which efforts][ln1.1 accepted proposals] they want
  to work on for the next major version of the common protocol, they're
  still working on developing and coming to agreement on the
  exact specifications for those protocols.  Rusty Russell is organizing
  meetings to help speed up the specification process and has started a
  [thread][ln spec meetings] asking for feedback about what medium to
  use for the meeting (Google Hangout, IRC meeting, something else) and
  how formal to make the meeting.  Anyone planning to participate in the
  process is recommended to at least monitor the thread.

- **Releases:** [LND 0.5.1][] is released as a new minor version with
  improvements particularly focused on its support for Neutrino, a
  lightweight wallet (SPV) mode that LND can work with to make LN
  payments without having to directly use a full node.  This release also
  fixes an accounting bug for users of the btcwallet backend where not
  all change payments to yourself may have been reflected in your
  displayed balance.  Upon upgrading, a rescan on the block chain will
  be performed so that the missing accounting information is recovered
  and your correct balance will be displayed.  No funds were at risk,
  they just weren't tracked correctly.

    The Bitcoin Core project is planning to start tagging release
    candidates for [maintenance version][maintenance release] 0.17.1 soon.
    This is expected to resolve some bugs with build system incompatibilities on
    recent Linux distributions as well as fix other [minor issues][0.17.1 milestone].

[LND 0.5.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.1-beta

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

- [LND #1937][] stores the most recent channel reestablishment message
  in the node's database so that it can be resent even after a channel
  has been closed.  This improves the node's chance of recovering from a
  connectivity problem combined with partial data loss.

- [Bitcoin Core #14477][] adds a new `desc` field to the
  `getaddressinfo`, `listunspent`, and `scantxoutset` RPCs with the
  [output script descriptor][output script descriptors] for each address
  when the wallet has enough information to consider that address
  *solvable*.  An address is solvable when a program knows enough about
  its scriptPubKey, optional redeemScript, and optional witnessScript in
  order for the program to generate an unsigned input spending funds
  sent to that address.  A new `solvable` field is added to the
  `getaddressinfo` RPC to independently indicate that the wallet knows
  how to solve for that address.

    The new `desc` fields are not expected to be particularly useful at
    the moment as they can currently only be used with the
    `scantxoutset` RPC, but they will provide a compact way of providing
    all the information necessary for making addresses solvable to
    future and upgraded RPCs for Bitcoin Core such as those used for interactions between
    offline/online (cold/hot) wallets, multisig wallets, coinjoin
    implementations, and other cases.

- [LND #2081][] adds RPCs that allow signing a transaction template
  where some inputs are controlled by LND.  Although this particular
  tool mirrors functionality already provided by the `lnwallet.Signer`
  service, the mechanism used to enable this new service makes it
  possible for developers to extend the RPCs (gRPCs) provided through
  LND with gRPCs provided by other code on the local machine or even a
  remote service.  Several additional new services using this mechanism
  are planned for the near future.

## Footnotes

[^fn-cpfp-limits]:
    Bitcoin Core's ancestor and descendant depth limits:

    ```text
    $ bitcoind -help-debug | grep -A3 -- -limit
      -limitancestorcount=<n>
           Do not accept transactions if number of in-mempool ancestors is <n> or
           more (default: 25)

      -limitancestorsize=<n>
           Do not accept transactions whose size with all in-mempool ancestors
           exceeds <n> kilobytes (default: 101)

      -limitdescendantcount=<n>
           Do not accept transactions if any ancestor would have <n> or more
           in-mempool descendants (default: 25)

      -limitdescendantsize=<n>
           Do not accept transactions if any ancestor would have more than <n>
           kilobytes of in-mempool descendants (default: 101).
    ```

{% include references.md %}
{% include linkers/issues.md issues="1937,14477,2081" %}
{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="a7dc03223e915d7afb30498fe5faa12b5402f7d8"
  end="ed12fd83ca7999a896350197533de5e9202bc2fe"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="8924d8fb20eb2abfd9cc93c6cc7eb6951184cb88"
  end="f4b6e0b7755982fc571e2763e0a2ec93c8e89900"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="95e47cdac298b8e534feb073c70da004c08b3e93"
  end="3ba751797bcc54e7e071518f680b08a3ae7f42fc"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="314a61d72474aa29ff4afba8472553ad91d88e9d"
  end="e34ceb333b1c0e6f4115ecbb80c632ac1042fa49"
%}


[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[last week's newsletter]: {{news23}}#news
[carve out thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[ln1.1 accepted proposals]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[ln spec meetings]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001673.html
[0.17.1 milestone]: https://github.com/bitcoin/bitcoin/milestone/39?closed=1
