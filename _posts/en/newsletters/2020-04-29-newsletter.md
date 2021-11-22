---
title: 'Bitcoin Optech Newsletter #95'
permalink: /en/newsletters/2020/04/29/
name: 2020-04-29-newsletter
slug: 2020-04-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the disclosure of an issue affecting
the safety of routed LN payments and announces a new presigned vault
proposal.  Also included are our regular sections with
popular questions and answers from the Bitcoin Stack Exchange,
announcements of releases and release candidates, and descriptions of
notable code changes in popular Bitcoin infrastructure projects.

## Action items

- **Review the disclosure of a potential LN issue:** as explained in the
  *news* section below, a public disclosure this week describes a new
  method for stealing money from LN nodes.  The issue partly overlaps with an existing well-known
  fee management issue that has not been exploited (to our knowledge) because almost
  all onchain transactions relayed in the past two years confirmed
  relatively quickly even if they only paid the default minimum relay
  feerate.  If feerates increase significantly for an extended period of
  time, these issues will become more critical.  See our explanation in
  the *news* section for details and contact your LN software vendor if
  you have concerns about how the this issue might affect your channels.

## News

- **New attack against LN payment atomicity:** Matt Corallo started a
  thread across both the [Lightning-Dev][corallo thread ld] and
  [Bitcoin-Dev][corallo thread bd] mailing lists disclosing an attack
  discovered during a [discussion][BOLTs #688] about allowing LN
  commitment transactions to be [CPFP][topic cpfp] fee bumped via
  [anchor outputs][topic anchor outputs].  We'll describe the attack
  using an extended example: Alice uses an LN channel to send Bob a Hash
  Time Lock Contract (HTLC) which is designed to be settled in either of
  the following ways:

     - If Bob discloses the preimage for `<hash>`, he can spend 1 BTC of
       Alice's money

     - Otherwise, after 80 blocks, Alice can refund that 1 BTC back to
       herself

    Alice also told Bob that the goal of her payment is to pay Mallory, so Bob
    uses a channel he has with Mallory to send her a related HTLC:

     - If Mallory discloses the preimage for `<hash>`, she can spend 1
       BTC of Bob's money (we're ignoring routing fees in this example)

     - Otherwise, after 40 blocks, Bob can refund that 1 BTC back to
       himself

    Although the above HTLCs are usually created and settled offchain,
    each party also has a *commitment transaction* they can use to
    put the HTLC commitment onchain.  A separate onchain *settlement
    transaction* can fulfill either condition of the HTLC.

    For example, Mallory can publish the commitment transaction and then
    create a settlement transaction that provides the preimage and
    claims Bob's 1 BTC.  If Bob sees Mallory's preimage settlement
    transaction before the 80 block timeout from the Alice-Bob contract,
    Bob can extract that preimage and use it to claim the 1 BTC from
    Alice (either onchain or offchain).  Or, if Bob doesn't see a
    preimage settlement transaction, Bob can create his own refund
    settlement transaction after 40 blocks that takes back his 1 BTC,
    allowing him to also initiate the refund of Alice's 1 BTC (again, either onchain
    or offchain).  In either case, this leaves everyone in compliance
    with the intent of their contracts.

    Unfortunately, as disclosed this week, there appears to be a way for
    Mallory to circumvent the process by both preventing Bob from
    learning the preimage while also preventing him from sending his
    refund settlement transaction.

    - **Preimage denial:** Mallory can prevent Bob from learning the
      preimage by giving her preimage settlement transaction a low
      feerate that keeps it from being confirmed quickly.  If Bob is
      only looking for preimages in the block chain, he won't see
      Mallory's transaction while it remains unconfirmed.

    - **Refund denial:** Mallory's prior broadcast of the preimage
      settlement transaction can prevent miners and Bitcoin relay nodes
      from accepting Bob's later broadcast of the refund settlement
      transaction because the two transactions *conflict*, meaning they
      both spend the same input (a UTXO created in the commitment
      transaction).  In theory, Bob's refund settlement transaction will
      pay a higher feerate and so can [replace][topic rbf] Mallory's
      preimage settlement but, in practice, Mallory can use various
      [transaction pinning][topic transaction pinning] techniques to
      prevent that replacement from happening.

    Because Bob is prevented from either learning about the preimage
    settlement transaction or getting his refund settlement transaction
    confirmed, Alice is able to reclaim the 1 BTC she offered Bob in the
    Alice-Bob HTLC once its 80 block timeout expires.  When Mallory's
    preimage settlement transaction does eventually confirm, Mallory
    gets the 1 BTC that Bob offered her in the Bob-Mallory HTLC.  This
    leaves Bob 1 BTC poorer than when he started.

    Several solutions were considered in the thread, but all had
    problems or involved significant tradeoffs:

    - **Require a mempool:** Bob could use a Bitcoin full node to
      monitor the Bitcoin P2P relay network and learn about Mallory's
      settlement transaction.  Some LN nodes such as Eclair already do
      this and it seems like a [reasonable amount of extra
      burden][osuntokun reasonable] since the problem only directly affects
      routing nodes (like Bob).  Nodes that just send or receive
      payments on behalf of themselves are only indirectly affected,[^non-routing-issues] so everyday users
      could still run lightweight LN clients on mobile devices.
      Unfortunately, not all full nodes receive the same transactions as other nodes
      even when everything is working perfectly.  Worse, there are techniques
      attackers like Mallory can use to [send different conflicting
      transactions][corallo mempool not guaranteed] to different peers
      (for example, sending the pinned preimage settlement transaction
      to known miners but sending a different non-settlement transaction
      with at least one of the same inputs to non-miner relay nodes).

    - **Beg or pay for preimages:** The relay network could provide
      [information about conflicts][harding reject] to transaction
      submitters such as Bob so they wouldn't need to continuously
      monitor relay themselves.  This still suffers from the problem of
      bad actors such as Mallory using [targeted relay][corallo targeted
      relay] to send different transactions to miners and non-miners.
      Additionally Bob might be able to [pay][harding pay] miners or
      other third party nodes for the preimage he needs, although this
      requires some people run additional software and [might not be as
      easy][zmn ptlcs] to do after the deployment of some proposed
      upgrades to the LN protocol.

    - **Settlement transaction anchor outputs:** Onchain settlement
      transactions could be redesigned to spend their value to [anchor
      outputs][topic anchor outputs] that could be [CPFP fee
      bumped][topic cpfp] using [CPFP carve-out][topic cpfp carve out].
      This would require those transactions to be larger (increasing
      onchain fees) and presigned (reducing flexibility).  This would
      only directly affect channels which are unilaterally closed while payments
      are pending, which is already a situation that can
      significantly increase onchain costs and so is something users try
      to avoid.  However, raising the cost of onchain enforcement also
      raises the minimum practical value of payments that can be sent trustlessly
      through LN.  Despite these challenges,
      as of this writing, this appears to be the most preferred
      solution.

    Corallo labeled this a severe issue but noted its similar
    consequences to another known issue related to fee management in
    onchain LN transactions.  The existing issue (described in
    [Newsletter #78][news78 anchor outputs]) is that commitment
    transactions have their feerate set at the time the transaction is
    signed, which might be days or weeks before they're broadcast to
    Bitcoin relay nodes.  If the minimum feerate necessary to get a
    transaction included in the next few blocks has increased
    significantly since the transaction was last signed, then the
    commitment transaction might not confirm until after Alice is able
    to reclaim her funds from Bob, again creating the opportunity for
    Bob to end up both paying Mallory and giving a refund to Alice.
    (This existing issue is what developers were working on fixing when
    the new issue was discovered.[^package-relay])

    So far we're unaware of any real-world losses due to onchain fee
    management problems in LN, possibly in part because the past two
    years has seen few large fee spikes that lasted long enough to
    significantly delay the confirmation of transactions with
    previously acceptable feerates.  That good luck is unlikely to
    continue indefinitely, so this new problem gives LN developers an
    additional reason to prioritize the implementation of improved
    onchain fee management.  In the interim, node operators concerned
    about the attack may wish to increase their [cltv_expiry_delta][]
    to give preimage settlement transactions more time to confirm.
    Current defaults in popular LN nodes are [14][cl ced] for
    C-Lightning, [40][lnd ced] for LND, [72][rl ced] for Rust-Lightning,
    and [144][eclair ced] for Eclair.  Note that increasing the value
    will make your channels less desirable to spenders,
    as higher values increases the normal worst case
    amount of time a payment could be stuck waiting to be settled.

- **Multiparty vault architecture:** Antoine "Darosior" Poinsot
  [announced][darosior revault] a demo implementation of a vaults
  [covenant][topic covenants] prototype based on the same basic
  presigned transaction concept mentioned in [last week's
  newsletter][news94 bishop vault].  This new implementation, named
  *Revault*, focuses on storing funds shared between multiple parties
  with multisig security.  The protocol allows a subset of the parties
  to initiate a withdrawal process by getting a beacon transaction
  confirmed; if the other parties to the vault object to the withdrawal,
  they have the opportunity to broadcast a second transaction that
  returns the funds to an emergency address in the vault.  If there's no
  objection within a certain amount of time, another transaction can
  complete the withdrawal of the funds.  Poinsot is seeking feedback on
  the proposal.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are the potential attacks against ECDSA that would be possible if we used raw public keys as addresses?]({{bse}}95123)
  Pieter Wuille answers by summarizing the argument for using public key hashes
  over public keys in addresses, namely, that it slows an attacker with quantum
  computing capabilities. He goes on to list reasons why that purported argument
  could be overstated and give a false sense of security.

- [What is meant by DEFAULT_ANCESTOR_LIMIT in child pays for parent?]({{bse}}95473)
  User anu asks about Bitcoin Core's [DEFAULT_ANCESTOR_LIMIT][bitcoin core default ancestor limit]
  regarding the [Child-Pays-For-Parent (CPFP)][topic cpfp] fee bumping
  technique. Murch notes that this default policy helps prevent spam
  attacks and gives a couple examples of determining ancestor transaction counts.

- [How is Simplicity better suited for static analysis compared to script?]({{bse}}95332)
  Russell O'Connor, author of the [Simplicity whitepaper][simplicity], describes
  the challenges of statically analyzing a Bitcoin Script program in
  contrast with the Simplicity language.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] is a release candidate
  for the next major version of Bitcoin Core.

- [LND 0.10.0-beta.rc6][lnd 0.10.0-beta] allows testing the next major
  version of LND.

- [C-Lightning 0.8.2-rc3][c-lightning 0.8.2] is the newest release
  candidate for the next version of C-Lightning.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Rust-Lightning][rust-lightning repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until version 0.21, about six months after the release of the upcoming
version 0.20.*

- [Bitcoin Core #15761][] adds an `upgradewallet` RPC, doing away
  with the old method of upgrading upon startup, thereby
  allowing users to unlock and upgrade their wallets to
  [Hierarchical Deterministic (HD)][Hierarchical Deterministic ref]
  while it is loaded.  This addition is also compatible with
  [multi-wallet][multi-wallet] as it works on the individual wallet that
  is specified by the RPC.

- [Bitcoin Core #17509][] allows the wallet GUI to save a [Partially
  Signed Bitcoin Transactions][topic psbt] (PSBT) to a file, as well as
  load a PSBT from a file.  Saving is available in private-key-disabled
  wallets where Bitcoin Core previously automatically copied a PSBT to
  the clipboard (see the PRs described in Newsletters [#74][news74 core
  psbt] and [#82][news82 core psbt]).  Loading a PSBT will offer to
  finalize and broadcast the transaction if all signatures are
  available; otherwise, the PSBT will be copied to the clipboard for
  signing by a separate user action (for example using an RPC from the
  GUI console or using a separate tool such as [HWI][topic hwi]).  A
  follow-up PRs is expected to add the ability to sign PSBTs in the GUI.

## Special thanks

We thank Antoine Riard, ZmnSCPxj, and Matt Corallo for reviewing drafts of this
newsletter and helping us understand the details of the LN atomicity
issue.  Any remaining errors are the fault of the newsletter author.

## Footnotes
[^package-relay]:
    The ultimate solution to deal with arbitrary feerates in LN also
    depends on Bitcoin full nodes being able to perform [package
    relay][Bitcoin Core #14895], a feature that's long been discussed
    but never fully implemented.  For now, LN commitment
    transactions can usually just [pay slightly higher][corallo slightly
    higher] feerates than strictly necessary to avoid the need for
    package relay.

[^non-routing-issues]:
    Although the only known way to use this attack to steal money
    directly is by abusing a routing node (such as Bob in
    Alice→Bob→Mallory), when the same attack of delaying the preimage
    settlement and blocking the refund settlement is executed against a
    spender (such as Alice in Alice→Mallory), it may produce a "payment
    failed" error that causes the user to initiate a second payment
    without realizing the first payment hasn't been revoked.  This
    [indirect attack][corallo send twice] can perhaps be dealt with by warning the user that
    the payment is stuck---not failed---and that sending additional
    payments could result in losses.

{% include references.md %}
{% include linkers/issues.md issues="688,15761,17509,14895" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[Hierarchical Deterministic ref]: https://bitcoin.org/en/glossary/hd-protocol
[multi-wallet]: https://bitcoin.org/en/release/v0.15.0.1#multi-wallet-support
[lnd 0.10.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.0-beta.rc6
[c-lightning 0.8.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2rc3
[news78 anchor outputs]: /en/newsletters/2019/12/28/#anchor-outputs
[corallo thread bd]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017757.html
[corallo thread ld]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002639.html
[harding reject]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002650.html
[corallo targeted relay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002652.html
[harding pay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002664.html
[zmn ptlcs]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002667.html
[osuntokun reasonable]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002641.html
[corallo mempool not guaranteed]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-April/002648.html
[darosior revault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017793.html
[news94 bishop vault]: /en/newsletters/2020/04/22/#vaults-prototype
[cltv_expiry_delta]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md#cltv_expiry_delta-selection
[cl ced]: https://github.com/ElementsProject/lightning/blob/10f47b41fa3192638442ef04d816380950cc32c9/lightningd/options.c#L630
[eclair ced]: https://github.com/ACINQ/eclair/blob/19975d3d8128705b92811ce0bc7a3881ecaf99dd/eclair-core/src/main/resources/reference.conf#L61
[lnd ced]: https://github.com/lightningnetwork/lnd/blob/0cf63ae8981a1041dd7b9f217dcc2158a28247d3/chainregistry.go#L64
[rl ced]: https://github.com/rust-bitcoin/rust-lightning/blob/12e2a81e1daf635578e1cfdd7de55324ed04bd48/lightning/src/ln/channelmanager.rs#L430
[corallo slightly higher]: https://github.com/bitcoinops/bitcoinops.github.io/pull/394#discussion_r416014263
[corallo send twice]: https://github.com/bitcoinops/bitcoinops.github.io/pull/394#discussion_r416099907
[simplicity]: https://blockstream.com/simplicity.pdf
[bitcoin core default ancestor limit]: https://github.com/bitcoin/bitcoin/blob/9fac600ababd8edefbe053a7edcd0e178f069f84/src/validation.h#L56
[news74 core psbt]: /en/newsletters/2019/11/27/#bitcoin-core-16944
[news82 core psbt]: /en/newsletters/2020/01/29/#bitcoin-core-17492
