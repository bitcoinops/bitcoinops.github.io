---
title: 'Bitcoin Optech Newsletter #241'
permalink: /en/newsletters/2023/03/08/
name: 2023-03-08-newsletter
slug: 2023-03-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for an alternative design
for `OP_VAULT` with several benefits and announces a new weekly Optech
podcast.  Also included are our regular sections with the summary of a
Bitcoin Core PR Review Club meeting, announcements of new software
releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Alternative design for OP_VAULT:** Greg Sanders [posted][sanders
  vault] to the Bitcoin-Dev mailing list an alternative design for
  providing the features of the `OP_VAULT`/`OP_UNVAULT` proposal (see
  [Newsletter #234][news234 vault]).  His alternative would add three
  opcodes instead of two.  To provide an example:

    - *Alice deposits funds in a vault* by paying a [P2TR output][topic
      taproot] with a script tree that contains at least two [leafscripts][topic
      tapscript], one which can trigger the time-delayed unvaulting
      process and one which can instantly freeze her funds, e.g.
      `tr(key,{trigger,freeze})`.

      - The *trigger leafscript* contains her less-trusted authorization
        conditions (such as requiring a signature from her hot wallet)
        and an `OP_TRIGGER_FORWARD` opcode.  At the time she creates
        this leafscript, she provides the opcode a *spend delay*
        parameter, e.g. a relative timelock of 1,000 blocks (about 1
        week).

      - The *freeze leafscript* contains any authorization conditions
        Alice wants to specify (including none at all) and
        an `OP_FORWARD_DESTINATION` opcode.  At the time she creates
        this leafscript, she also chooses her more-trusted authorization
        conditions (such as requiring multiple signatures from multiple
        cold wallets and hardware signing devices).  She provides the
        opcode a commitment to those conditions in the form of a hash
        digest.

    - *Alice triggers an unvaulting* by spending the output received to
      the above script tree (using it as an input) and choosing the
      trigger leafscript.  At this time, she provides two additional
      parameters to the `OP_TRIGGER_FORWARD` opcode, the index of the
      output which will receive this input's funds and a hash-based
      commitment to how she wants to be able to spend the funds later.
      The opcode verifies that the indicated output of this transaction
      pays a P2TR output with a script tree similar to the one being spent except that the
      trigger leafscript is replaced with a script using an
      `OP_CHECKSEQUENCEVERIFY` (CSV) relative delay equal to the delay
      specified previously (e.g., 1000 blocks) and an
      `OP_FORWARD_OUTPUTS` opcode which includes Alice's commitment
      hash.  The method of reconstructing the script tree is similar to
      an earlier [covenant][topic covenants] proposal,
      `OP_TAPLEAF_UPDATE_VERIFY` (see [Newsletter #166][news166 tluv]).

    - *Alice completes the unvaulting* by waiting until the relative
      timelock has expired and then spending the unvaulting output,
      choosing the tapleaf with the `OP_FORWARD_OUTPUTS` opcode.  The
      opcode verifies that the spending transaction's output amounts and
      script’s hash to the same commitment Alice made in the previous
      transaction.  In this case, Alice has successfully deposited funds
      to a vault, begun an unvaulting, been forced to wait at least
      1,000 blocks to allow her monitoring programs to verify she really
      did want to spend the funds to the specified outputs, and
      completed the spend.

    - If something goes wrong, *Alice freezes the funds*.  She can do
      this at any time from the moment she deposits funds in the vault
      up until an unvaulting is completed.  To freeze funds, she simply
      chooses to spend the freeze leafscript from the output of
      either the vaulting or trigger transactions.  Recall
      that Alice explicitly placed the freeze leafscript in the vaulting
      transaction, and note that it was implicitly carried over by the
      trigger transaction which initiated the unvaulting.

  One of the advantages to users of this approach over the original
  `OP_VAULT` design is that the freeze leafscript can contain any
  authorization conditions Alice wants to specify.  In the `OP_VAULT`
  proposal, anyone knowing the parameters chosen by Alice could spend
  her funds to the freeze script.  That wasn't a security problem but it
  could be annoying.  In Sanders's design, Alice could (for example)
  require a signature from a very lightly protected wallet in order to
  initiate a freeze---this would perhaps be enough of a burden to
  prevent most griefing attacks but not enough of a barrier to prevent
  Alice from quickly freezing her funds in an emergency.

  Several other advantages are aimed at making the consensus-enforced
  [vaulting protocol][topic vaults] easier to understand and verify as
  safe.  Subsequent to our writing the above, the author of the
  `OP_VAULT` proposal, James O'Beirne, replied favorably to Sanders's
  ideas.  O'Beirne also had ideas for additional changes which we'll
  describe in a future newsletter. {% assign timestamp="0:41" %}

- **New Optech Podcast:** the weekly Optech Audio Recap hosted on
  Twitter Spaces is now available as a podcast.  Each episode will be
  available on all popular podcast platforms and on the Optech website
  as a transcript.  For more details, including why we think this is a
  major step forward in Optech's mission to improve Bitcoin technical
  communication, please see our [blog post][podcast post]. {% assign timestamp="23:29" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Bitcoin-inquisition: Activation logic for testing consensus changes][review club bi-16]
is a PR by Anthony Towns that adds a new method for activating and deactivating
soft forks in the [Bitcoin Inquisition][] project, designed to be run on [signet][topic signet]
and used for testing.
This project was covered in [Newsletter #219][newsletter #219 bi].

Specifically, this PR replaces [BIP9][] block version bit semantics with what
are called [Heretical Deployments][].
In contrast to consensus and relay changes on mainnet -- which are difficult
and time-consuming to activate, requiring the careful building of (human)
consensus and an elaborate [soft fork activation][topic soft fork activation]
mechanism -- on a test network activating these changes can be streamlined.
The PR also implements a way to deactivate changes that turn out to be buggy
or undesired, which is a major departure from mainnet. {% assign timestamp="24:33" %}

{% include functions/details-list.md
  q0="Why do we want to deploy consensus changes that aren’t merged
      into Bitcoin Core? What problems (if any) are there with merging the
      code into Bitcoin Core, and then testing it on signet afterward?"
  a0="Several reasons were discussed. We can't require mainnet users to upgrade
      the version of Core they're
      running, so even after a bug has been fixed, some users may continue
      running the buggy version. Depending only on regtest makes
      integration testing third-party software more difficult.
      Merging consensus changes to a separate repository is much less risky than merging to Core;
      adding soft fork logic, even if not activated, may introduce bugs that affect existing behavior."
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-37"

  q1="Heretical Deployments move through a sequence of finite-state
      machine states similar to the BIP9 states
      (`DEFINED`, `STARTED`, `LOCKED_IN`, `ACTIVE`, and `FAILED`),
      but with one additional state after `ACTIVE` called `DEACTIVATING`
      (following which is the final state, `ABANDONED`).
      What is the purpose of the `DEACTIVATING` state?"
  a1="It gives users a chance to withdraw funds they might have locked
      into the soft fork. Once the fork is deactivated or replaced, they
      might not be able to spend the funds at all -- even if they're
      anyone-can-spend; that doesn't work if your tx is rejected for
      being non-standard.
      The concern isn't so much the permanent
      loss of the limited signet funds, but rather that the UTXO set
      may become bloated."
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-92"

  q2="Why does the PR remove `min_activation_height`?"
  a2="We don't need a configurable interval between lock-in and activation
      in the new state model -- with Heretical Deployments, it activates
      automatically at the start of the next 432-block (3 days) state
      machine period (this period is fixed for Heretical Deployments)."
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-126"

  q3="Why is Taproot buried in this PR?"
  a3="If you didn't bury it, you'd have to make it a Heretical Deployment,
      which requires some coding effort; also that would mean that it
      would timeout eventually, but we want Taproot never to timeout."
  a3link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-147"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.02][] is a release for a new
  version of this popular LN implementation.  It includes experimental
  support for peer storage of backup data (see [Newsletter
  #238][news238 peer storage]) and updates experimental support for [dual
  funding][topic dual funding] and [offers][topic offers].  Also
  included are several other improvements and bug fixes. {% assign timestamp="38:01" %}

- [LDK v0.0.114][] is a release for a new version of this library for
  building LN-enabled wallets and applications.  It fixes several
  security-related bugs and includes the ability to parse [offers][topic
  offers]. {% assign timestamp="40:00" %}

- [BTCPay 1.8.2][] is the latest release for this popular self-hosted
  payment processing software for Bitcoin.  The release notes for
  version 1.8.0 say, "this version brings custom checkout forms, store
  branding options, a redesigned Point of Sale keypad view, new
  notification icons and address labeling." {% assign timestamp="40:52" %}

- [LND v0.16.0-beta.rc2][] is a release candidate for a new major
  version of this popular LN implementation. {% assign timestamp="41:40" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #7462][] allows the creation of watch-only wallets with remote
  signing and the use of the stateless init feature. {% assign timestamp="42:48" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="7462" %}
[core lightning 23.02]: https://github.com/ElementsProject/lightning/releases/tag/v23.02
[lnd v0.16.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc2
[LDK v0.0.114]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.114
[BTCPay 1.8.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.8.2
[podcast post]: /en/podcast-announcement/
[sanders vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021510.html
[news234 vault]: /en/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news238 peer storage]: /en/newsletters/2023/02/15/#core-lightning-5361
[newsletter #219 bi]: /en/newsletters/2022/09/28/#bitcoin-implementation-designed-for-testing-soft-forks-on-signet
[review club bi-16]: https://bitcoincore.reviews/bitcoin-inquisition-16
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[heretical deployments]: https://github.com/bitcoin-inquisition/bitcoin/wiki/Heretical-Deployments
[bip9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
