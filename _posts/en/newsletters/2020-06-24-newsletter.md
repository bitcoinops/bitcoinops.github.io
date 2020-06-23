---
title: 'Bitcoin Optech Newsletter #103'
permalink: /en/newsletters/2020/06/24/
name: 2020-06-24-newsletter
slug: 2020-06-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a newly published fee ransom attack against
LN users, links to continued discussion about the attack against LN
atomicity, and shares a reminder about collision attacks on
RIPEMD160-based addresses in multiparty protocols.  Also included are
our regular sections with popular questions and answers from the Bitcoin
StackExchange, a list of releases and release candidates published this
week, and notable changes to popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **LN fee ransom attack:** René Pickhardt [publicly
  disclosed][pickhardt post] a vulnerability to the Lightning-Dev
  mailing list that he had previously privately disclosed to LN
  implementation maintainers almost a year ago.  In the current LN
  protocol, each time the channel state is updated, the party who
  initiated opening the channel must commit to paying any onchain
  transaction fees for the unilateral close transaction.  The party
  paying the fees also gets to choose the feerate used---but the
  counterparty's security also depends on the feerate being appropriate.  That
  means the counterparty may close the channel at any time if they think
  the chosen feerate has become too low for current market conditions.
  To avoid such unnecessary closes, [BOLT2][] gives an example of the
  fee-paying party selecting fees five
  times higher than the minimum reasonable estimate---high enough that
  the counterparty should be satisfied even if they're using a
  different fee estimation algorithm.

    BOLT2 also allows channels to route up to 483 payments
    simultaneously, each of which requires a 43 vbyte P2WSH output, for
    a total of about 20,000 vbytes of data that needs to be added to the
    chain relatively quickly---meaning it may need to pay a high feerate.
    If that feerate is five times higher than strictly necessary, this
    can easily result in paying more than $100 USD in
    transaction fees at current bitcoin prices.  Additionally, if the commitment transaction is
    confirmed, the HTLCs then need to be settled (again using
    time-sensitive transactions that may need to pay a high feerate).
    If the victim was the party routing those payments outbound, they'll
    need to pay an additional transaction fee to recover each payment,
    which could make the attack two or three times more costly for them.

    Fees are paid to miners, so there's no direct motivation to perform
    this attack, but if the attacker has the means to quickly contact
    the victim, it's possible they can offer to settle the HTLCs
    offchain in return for a ransom, allowing the attacker to profit.

    Pickhardt concludes his email with several ideas for addressing the
    problem, none of which he finds completely satisfactory.  The
    mitigation originally implemented in Eclair and later implemented in
    C-Lightning (see [Newsletter #59][news59 cl30]) is for LN nodes to limit the
    number of pending payments, keeping transactions small and total
    fees low.  Another mitigation in development is [anchor
    outputs][topic anchor outputs], which allow feerates to be selected
    when the channel is closed---eliminating the need to overestimate
    fees in order to prevent premature channel closures.  Several other
    ideas are mentioned, but Pickhardt asks readers to contemplate the
    problem and suggest any other possible solutions.

- **Continued discussion about LN atomicity attack:** Bastien Teinturier
  [posted][teinturier post] to the Lightning-Dev mailing list with a
  link to a [detailed description][teinturier gist] of the LN commitment
  protocol, its weaknesses, and proposals to address those weaknesses.
  The document teaches readers everything they should need to know to
  understand the attack against LN atomicity described in [Newsletter
  #95][news95 ln attack] as well as several proposed mitigations.  The
  document's clear writing tied together several fragmented threads from
  previous discussions.  This led to a renewed evaluation of several
  previously proposed solutions, including concerns about the
  effectiveness of the "alternative anchor proposal" and a [suggested
  procedure][zmn procedure] to use the [pay-for-signature][] scriptless
  script to trustlessly pay a third party for the final signature needed
  to complete an adaptor signature.

- **Reminder about collision attack risks on two-party ECDSA:**
  cryptographer Jonas Nick [replied][nick collision] to the Bitcoin-Dev
  mailing list thread about a proposed CoinSwap implementation (see
  [Newsletter #100][news100 coinswap]) reminding developers that P2PKH,
  P2WPKH, and P2SH addresses which use the 160-bit RIPEMD160 hash are
  vulnerable to collision attacks that reduce its security to 80 bits
  when multiple parties collaborate to create an address using a naive
  protocol (see our [description of this weakness][address security]
  in legacy P2SH addresses).  Although this was previously only a
  concern for users of P2SH multisig, it applies in contexts, such as CoinSwap, where
  it's proposed that two users could share a P2PKH or P2WPKH address.
  It's possible to avoid this problem, but it requires that the
  two-party ECDSA protocol be designed to include an extra commitment
  procedure, which Nick notes some two-party ECDSA protocols and
  implementations already do.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why was the current formula that calculates 'target' from 'nBits' chosen?]({{bse}}96298)
  Ravi Patel asks why a simpler formula for calculating the difficulty target
  from `nBits` wasn’t chosen. Andrew Chow dives into some of the details around
  the formula, its history, and even sample code from Bitcoin’s 0.1.5 release.

- [Does Bitcoin really need timestamps?]({{bse}}96185)
  Pieter Wuille explains why limiting the block rate without reference to a
  clock time outside of the blockchain could make running full nodes more
  expensive while also struggling to keep the stale block rate low and
  preventing collusion attacks.

- [In a fee overpayment attack, why can't compromised software provide fake previous transactions corresponding to fake inputs?]({{bse}}96309)
  Regarding a [fee overpayment attack][news101 fee overpayment attack] on segwit
  transactions with multiple inputs, justinmoon asks why the remedy of the
  attack, requiring copies of previous transactions for the inputs, is not
  vulnerable to malicious software providing fake previous transactions. Since
  any provided previous transaction must have a hash that matches the spending input’s
  previous transaction hash, such an attack is not feasible.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.10.2-beta.rc2][lnd 0.10.2-beta] this release candidate for an
  LND maintenance release is now available for testing.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #19260][] p2p: disconnect peers that send filterclear + update existing filter msg disconnect logic FIXME:dongcarl

- [Bitcoin Core #19133][] adds a bitcoin-cli `-generate` parameter (note leading dash) to replace
  the functionality of the `generate` RPC, which was removed
  from Bitcoin Core in [version 0.19.0.1][core version]. The new
  implementation avoids unnecessary dependencies between the
  wallet and other components. Providing a client-side alias for the former RPC is useful for
  manual testing and makes it easier to update [broken documentation][broken docs].

- [Bitcoin Core #18027][] adds two options to the GUI's *File* menu for
  working with Partially Signed Bitcoin Transactions ([PSBTs][topic
  psbt]): *Load PSBT from file* and *Load PSBT from clipboard*.  When
  one of those options is clicked and a PSBT is loaded, a dialog is
  provided that allows the user to sign an incomplete PSBT if this
  wallet has its key, broadcast a complete PSBT, or copy or save the
  PSBT for processing with another tool such as [HWI][].  Combined with
  other recent PSBT-related GUI changes (see Newsletters [#74][news74
  psbtgui] and [#82][news82 psbtgui]) and [HWI's own GUI][hwi gui], this
  makes it possible to use a PSBT-based process with Bitcoin Core for
  the first time without using any RPCs.

    ![Screenshot of PSBT dialog in Bitcoin Core GUI](/img/posts/2020-06-psbt-dialog.png)

- [Bitcoin Core #16377][] updates the `walletcreatefundedpsbt` and
  `fundrawtransaction` RPCs.  These RPCs normally use the wallet to
  automatically choose which UTXOs to spend in an unsigned transaction,
  but they also allow the user to specify one or more UTXOs they want to
  spend in that transaction.  Previously, if the UTXOs selected by the
  user weren't enough to pay for all of the transaction's outputs, the
  wallet would automatically select more UTXOs to spend.  But, if a
  user is manually selecting UTXOs, they may have some reason they don't
  want to spend additional UTXOs, so the RPCs will now fail by default
  if the user manually selects any UTXOs.  This default may be overridden
  using the new `add_inputs` parameter to both RPCs.

- [Eclair #1461][] adds several API endpoints that forward to Bitcoin
  Core RPCs for relaying that program's wallet balances and other
  information.  The goal is to make it easier to integrate Eclair with
  the [Ride The Lightning][] node management dashboard.

- [Bitcoin Core #19071][] adds documentation describing how developers
  can contribute to the new and experimental [Bitcoin Core GUI
  repository][].  Pull requests related to the GUI should be made into
  this new repository, which will be bidirectionally synced with the
  [main repository][bitcoin/bitcoin] using
  the *monotree* development model used by the Linux Kernel Project.
  There are no direct user-visible changes from this split---users will
  still receive the GUI in the official packaged versions of Bitcoin Core or
  when building using `--with-gui` from the source code in the main
  repository.

    ![Illustration of monorepo versus monotree](/img/posts/2020-06-monorepo-vs-monotree.png)

    This split is an experiment designed to determine whether using
    different repositories for different subsystems will help people
    interested in a particular subsystem focus on that part of the
    project.  For example, someone using the GitHub *Watch Repository*
    feature will receive fewer issue and PR status updates each day when
    watching the Bitcoin Core GUI repository rather than the main
    repository, making it easier for them to monitor the project.
    Conversely, developers watching the main project, who may not all
    be interested in the GUI, will no longer need to receive
    notifications about it.  In the best case, it's hoped that this
    improved focus can speed up development, which may lead to
    discussion about creating monotree repositories for other subsystems.
    In the worst case, it's feared the split could slow down
    development---but, if that happens, the experiment can be easily
    terminated and development can return to using a single repository
    (*monorepo*).

{% include references.md %}
{% include linkers/issues.md issues="19260,19133,18027,16377,1461,19071" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta.rc2
[ride the lightning]: https://github.com/Ride-The-Lightning/RTL
[pickhardt post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002735.html
[bolt5 calc]: https://github.com/lightningnetwork/lightning-rfc/blob/master/05-onchain.md#penalty-transactions-weight-calculation
[news59 cl30]: /en/newsletters/2019/08/14/#c-lightning-2858
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002739.html
[teinturier gist]: https://gist.github.com/t-bast/22320336e0816ca5578fdca4ad824d12
[news95 ln attack]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[pay-for-signature]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002077.html
[zmn procedure]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-June/002744.html
[nick collision]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017986.html
[news100 coinswap]: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[address security]: /en/bech32-sending-support/#address-security
[news74 psbtgui]: /en/newsletters/2019/11/27/#bitcoin-core-16944
[news82 psbtgui]: /en/newsletters/2020/01/29/#bitcoin-core-17492
[hwi gui]: https://github.com/bitcoin-core/HWI/pull/291
[bitcoin core gui repository]: https://github.com/bitcoin-core/gui
[bitcoin/bitcoin]: https://github.com/bitcoin/bitcoin
[news101 fee overpayment attack]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[core version]: https://bitcoin.org/en/release/v0.19.0.1
[broken docs]: https://btcinformation.org/en/developer-examples#regtest-mode
