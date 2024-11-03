---
title: 'Bitcoin Optech Newsletter #291'
permalink: /en/newsletters/2024/02/28/
name: 2024-02-28-newsletter
slug: 2024-02-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed contract for trustless miner
feerate futures, links to a coin selection algorithm for LN nodes
providing dual funding liquidity, details a prototype for a vault using
`OP_CAT`, and discusses sending and receiving ecash using LN and ZKCPs.
Also included are our regular sections summarizing popular questions and
answers from the Bitcoin Stack Exchange, announcing new releases and
release candidates, and describing recent changes to popular Bitcoin
infrastructure projects.

## News

- **Trustless contract for miner feerate futures:** ZmnSCPxj
  [posted][zmnscpxj futures] to Delving Bitcoin a set of scripts that
  will allow two parties to conditionally pay each other based on the
  marginal feerate to include a transaction in a future block.  For
  example, Alice is a user who expects to include a transaction in block
  1,000,000 (or a block shortly thereafter).  Bob is a miner who has
  some chance of mining a block around that time.  They each deposit
  some of their money into a _funding transaction_ that can be spent one
  of three ways:

  1. Bob receives back his deposit plus claims Alice's deposit by
     spending the funding transaction's output in block 1,000,000 (or a
     block shortly thereafter).  The script they use requires Bob's
     unilateral spend to be a certain minimum size, such as larger than two
     typical spends.

  2. Alternatively, Alice receives back her deposit plus claims Bob's
     deposit spending the funding transaction's output sometime after
     block 1,000,000 (for example, a day later in block 1,000,144).
     Alice's transaction is relatively small.

  3. A further alternative is that Alice and Bob can cooperatively spend
     the funding transaction's output however they would like.  This
     uses a [taproot][topic taproot] keypath spend for maximum
     efficiency.

  If feerates at block 1,000,000 are lower than expected, Bob can
  include his large spend in that block (or another block shortly
  thereafter) and profit.  Profiting at this moment of network-wide low
  feerates is especially advantageous for Bob as a miner because low
  feerates mean that he doesn't earn as much reward from any blocks he
  produces.

  If feerates at block 1,000,000 are higher than expected, Bob won't
  want to include his large spend in a block---it'll cost more in fees
  than it earns him in profit.  This allows Alice to profit by including
  her smaller spend in block 1,000,144 (or later).  Profiting at this
  moment of network-wide high feerates is especially advantageous to
  Alice as it offsets the high fee cost of including the regular
  transaction she planned to include in block 1,000,000.

  Additionally, if both Alice and Bob realize that it'll be profitable
  for Bob to include his spend in block 1,000,000, they can
  cooperatively spend to Bob to create a smaller transaction than Bob's
  unilateral version.  This benefits Bob by saving him fees and benefits
  Alice by reducing the amount of data in block 1,000,000, which means
  Alice may need to pay less in fees for the transaction she planned to
  include in that block.

  There were several replies to the topic.  One reply [noted][harding
  futures] that the contract has the interesting property of not only
  being trustless (a common reason to prefer consensus-enforced
  contracts) but also avoids corrupting the counterparty.  For example,
  if there was a centralized futures market for feerates, Bob and other
  miners could [accept fees out of band][topic out-of-band fees] or use
  other tricks to manipulate the apparent feerate; but, with ZmnSCPxj's
  construction, that's not a risk: Bob's choice about whether or not to
  use the large-size spend is purely informed by his perspective on
  current mining and mempool conditions.  That reply also contemplated
  whether larger miners might have an advantage over smaller miners,
  with Anthony Towns [providing][towns futures] a payoff table showing
  that an attempt to game the contract would result in greater profits
  for miners using the default transaction selection algorithm. {% assign timestamp="1:31" %}

- **Coin selection for liquidity providers:** Richard Myers
  [posted][myers cs] to Delving Bitcoin about creating a [coin
  selection][topic coin selection] algorithm that is optimized for LN
  nodes offering liquidity via [liquidity advertisements][topic
  liquidity advertisements].  His post describes an algorithm that he
  implemented in a Bitcoin Core [draft PR][bitcoin core #29442].
  Testing the algorithm, he found "a 15% reduction in on-chain fees
  compared to [Bitcoin Core's] default coin selection".  Myers is
  seeking criticism of the approach and suggestions for improvement. {% assign timestamp="7:20" %}

- **Simple vault prototype using `OP_CAT`:** developer Rijndael
  [posted][rijndael vault] to Delving Bitcoin about a Rust-language
  proof-of-concept implementation he's written for a [vault][topic
  vaults] that only depends on the current consensus rules plus the
  proposed [OP_CAT][topic op_cat] opcode.  A brief example of how the
  vault could be used: Alice generates an address with a script created
  by the vault software and receives a payment to the address.  Then a
  spend is triggered either by her or by someone attempting to steal her
  funds.

  - *Legitimate spend:* Alice triggers the spend by creating a
    trigger transaction with two inputs and two outputs; the inputs are
    the spend of the vaulted amount and an input that adds fees; the
    outputs are a staging output for the exact amount of the first input
    and a small output that pays the eventual withdrawal address.  After
    a certain number of blocks passes, Alice completes the withdrawal
    by creating a transaction with two inputs and one output; the inputs
    are the first trigger output from before plus another fee-paying
    input; the output is the withdrawal address.

    In the first spend, `OP_CAT` plus a previously described trick using
    [schnorr signatures][topic schnorr signatures] (see [Newsletter
    #134][news134 cat]) verifies that the output being spent has the
    same script and amount as the corresponding output being created,
    ensuring no funds are withdrawn from the vault by the trigger
    transaction.  The second transaction verifies that its first input
    has a [BIP68][] relative [timelock][topic timelocks] for a certain
    number of blocks (e.g. 20 blocks), that the output pays the exact
    amount of the first input, and that the output pays the same address
    as the second address of the trigger transaction.  The relative
    timelock provides a contest period (see below); the exact amount
    verification ensures no funds are withdrawn without permission; and
    the address verification ensures a thief can't change a legitimate
    withdrawal address into their own address at the last moment (a
    problem with all presigned vaults we're aware of, see [Newsletter
    #59][news59 vaults]).

  - *Illegitimate spend:* Mallory triggers a spend by creating a trigger
    transaction as described above.  Alice's [watchtower][topic
    watchtowers] realizes that the spend is illegitimate during the
    contest period (e.g., the 20 block delay) and creates a re-vaulting
    transaction with two inputs and one output; the inputs are the
    trigger transaction's first output and a fee-paying input; the
    output is a return to the vault.  Because the re-vaulting
    transaction only has one output but the withdrawal conditions of the
    script require spending from a trigger transaction with two outputs,
    Mallory is unable to complete stealing Alice's funds.

    Because the money is returned to the same vault script it
    started in, Mallory can still create another trigger
    transaction and force Alice to go through the same cycle over and
    over, resulting in fee costs for both Mallory and Alice.  Rijndael's
    [extended documentation][cat vault readme] for the project notes
    that you'd probably want to allow Alice to spend the money to a
    different script in that case, and that the ideas behind his
    construction allow for that but it isn't currently implemented for
    simplicity.

  These CAT-based vaults can be compared against the types of presigned
  vaults we can create today without consensus changes and the
  [BIP345][]-style `OP_VAULT` vaults that would provide the best-known
  set of vault features if support for them was added in a soft fork.

  <table>
  <tr>
    <th></th>
    <th>Presigned</th>
    <th markdown="span">

    BIP345 `OP_VAULT`

    </th>
    <th markdown="span">

    `OP_CAT` with schnorr

    </th>
  </tr>

  <tr>
    <th>Availability</th>
    <td markdown="span">

    **Now**

    </td>
    <td markdown="span">

    Requires soft fork of `OP_VAULT` and [OP_CTV][topic op_checktemplateverify]

    </td>
    <td markdown="span">

    Requires soft fork of `OP_CAT`

    </td>
  </tr>

  <tr>
    <th markdown="span">Last-minute address replacement attack</th>
    <td markdown="span">Vulnerable</td>
    <td markdown="span">

    **Not vulnerable**

    </td>
    <td markdown="span">

    **Not vulnerable**

    </td>
  </tr>

  <tr>
    <th markdown="span">Partial amount withdrawals</th>
    <td markdown="span">Only if prearranged</td>
    <td markdown="span">

    **Yes**

    </td>
    <td markdown="span">No</td>
  </tr>

  <tr>
    <th markdown="span">Static and non-interactive computable deposit addresses</th>
    <td markdown="span">No</td>
    <td markdown="span">

    **Yes**

    </td>
    <td markdown="span">

    **Yes**

    </td>
  </tr>

  <tr>
    <th markdown="span">Batched re-vaulting/quarantining for fee savings</th>
    <td markdown="span">No</td>
    <td markdown="span">

    **Yes**

    </td>
    <td markdown="span">No</td>
  </tr>

  <tr>
    <th markdown="span">

    Operational efficiency in best case, i.e. only legitimate spends<br>*(only very roughly estimated by Optech)*

    </th>
    <td markdown="span">

    **2x size of regular single-sig**

    </td>
    <td markdown="span">3x size of regular single-sig</td>
    <td markdown="span">4x size of regular single-sig</td>
  </tr>
  </table>

  The prototype has received a small amount of discussion and analysis
  on the forum as of this writing. {% assign timestamp="21:15" %}

- **Sending and receiving ecash using LN and ZKCPs:** Anthony Towns
  [posted][towns lnecash] to Delving Bitcoin about linking
  "[ecash][topic ecash] mints to the lightning network without losing
  ecash’s anonymity or adding any additional trust".  His proposal for
  achieving that goal uses a zero-knowledge contingent payment
  ([ZKCP][topic acc]) for sending payments to the user of an ecash mint
  and a process of committing to a hash preimage for withdrawing ecash
  funds to LN.

  Calle, the lead developer of the [Cashu][] ecash implementation,
  [replied][calle lnecash] with some concerns but also support for the idea, a reference
  to a zero-knowledge proof system already implemented for Cashu, and
  a note that he's actively researching and writing code to support
  atomic ecash-to-LN transfers. {% assign timestamp="44:44" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why can't nodes have the relay option to disallow certain transaction types?]({{bse}}121734)
  Ava Chow outlines thoughts about the purpose of [mempool and relay policy][policy series],
  benefits of more-homogeneous mempools including [fee estimation][topic fee
  estimation] and [compact block relay][topic compact block relay], and touches
  on policy workarounds such as miners accepting [fees out-of-band][topic
  out-of-band fees]. {% assign timestamp="49:41" %}

- [What is the circular dependency in signing a chain of unconfirmed transactions?]({{bse}}121959)
  Ava Chow explains the concern of [circular dependencies][mastering 06 cds]
  when using unconfirmed legacy Bitcoin transactions. {% assign timestamp="53:28" %}

- [How does Ocean’s TIDES payout scheme work?]({{bse}}120719)
  User Lagrang3 explains the Transparent Index of Distinct Extended Shares
  (TIDES) miner payout scheme used by the Ocean mining pool. {% assign timestamp="34:02" %}

- [What data does the Bitcoin Core wallet search for during a blockchain rescan?]({{bse}}121563)
  Pieter Wuille and Ava Chow summarize how the Bitcoin Core wallet software
  identifies relevant transactions to a particular legacy or [descriptor][topic descriptors] wallet. {% assign timestamp="57:57" %}

- [How does transaction rebroadcasting for watch-only wallets work?]({{bse}}121899)
  Ava Chow notes that the transaction rebroadcasting logic is the same
  regardless of wallet type. However, for a watch-only-originated
  transaction to be eligible for rebroadcasting by the node, the transaction
  must have made it to the node's mempool at some point. {% assign timestamp="59:37" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.02][] is a release of the next major version of
  this popular LN node.  It includes improvements to the `recover`
  plugin that "make emergency recoveries less stressful", improvements
  to [anchor channels][topic anchor outputs], 50% faster block chain
  syncing, and a bug fix for the parsing of a large
  transaction found on testnet. {% assign timestamp="1:02:20" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [LDK #2770][] begins preparing to later add support for [dual-funded
  channels][topic dual funding]. {% assign timestamp="1:04:20" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2770,29442" %}
[Core Lightning 24.02]: https://github.com/ElementsProject/lightning/releases/tag/v24.02
[myers csliq]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[news134 cat]: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat
[news59 vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[cashu]: https://github.com/cashubtc/nuts
[zmnscpxj futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547
[harding futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/2
[myers cs]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[rijndael vault]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576
[cat vault readme]: https://github.com/taproot-wizards/purrfect_vault
[towns lnecash]: https://delvingbitcoin.org/t/ecash-and-lightning-via-zkcp/586
[towns futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/6?u=harding
[calle lnecash]: https://delvingbitcoin.org/t/ecash-and-lightning-via-zkcp/586/2
[policy series]: /en/blog/waiting-for-confirmation/
[mastering 06 cds]: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch06_transactions.adoc#circular-dependencies
