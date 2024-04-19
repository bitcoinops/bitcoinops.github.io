---
title: 'Bitcoin Optech Newsletter #222'
permalink: /en/newsletters/2022/10/19/
name: 2022-10-19-newsletter
slug: 2022-10-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the block parsing bug affecting BTCD
and LND last week, summarizes discussion about a planned Bitcoin Core
feature change related to replace by fee, outlines research about
validity rollups on Bitcoin, shares an announcement about a
vulnerability in the draft BIP for MuSig2, examines a proposal to reduce
the minimum size of an unconfirmed transaction that Bitcoin Core will
relay, and links to an update of the BIP324 proposal for a version 2
encrypted transport protocol for Bitcoin.  Also included are our regular
sections with summaries of changes to services and client software,
announcements of new releases and release candidates, and descriptions
of notable merges to popular Bitcoin infrastructure projects.

## News

- **Block parsing bug affecting BTCD and LND:** on October 9th, a
  [user][brqgoo] created a [transaction][big msig] using [taproot][topic
  taproot] with a witness containing nearly a thousand signatures.  The
  consensus rules for taproot don't place any direct limits on the size
  of witness data.  This was a design element discussed during taproot's
  development (see [Newsletter #65][news65 tapscript limits]).

  Shortly after the large-witness transaction was confirmed, users
  began to report that the BTCD full node implementation and LND
  Lightning Network implementation were failing to provide data from
  the most recent blocks that were available to Bitcoin Core full
  nodes.  For BTCD nodes, this meant that transactions which had been
  recently confirmed were being reported as still unconfirmed.  For
  LND, it meant that new channels that had recently become ready to
  use weren't being reported as fully open.

  A developer for both BTCD and LND fixed the problem in BTCD's code,
  which LND uses as a library, and quickly released new versions for
  both [LND][lnd 0.15.2-beta] (as mentioned in [last week's
  newsletter][news221 lnd]) and [BTCD][btcd 0.23.2].  All users of
  BTCD and LND should upgrade.

  Until a user upgrades their software, they will suffer the
  lack-of-confirmation problems described above and may also be
  vulnerable to several attacks.  Some of those attacks require access
  to significant hash rate (making them expensive and, hopefully,
  impractical in this case).  Other attacks, particularly those
  against LND users, require the attacker to risk losing some of their
  funds in a channel, which is also hopefully a sufficient deterrent.
  We again recommend upgrade and, further, we recommend that anyone
  using any Bitcoin software sign up for security announcements from
  that software's development team.

  After the above disclosures, Loki Verloren [posted][verloren limits]
  to the Bitcoin-Dev mailing list to suggest that direct limits be
  added to taproot's witness size.  Greg Sanders [replied][sanders
  limits] to note that adding limits now would not only increase code
  complexity but could also lead to people losing their money if they
  already received bitcoins to a script which requires a large witness
  to spend. {% assign timestamp="0:10" %}

- **Transaction replacement option:** as reported in Newsletters
  [#205][news205 rbf] and [#208][news208 rbf], Bitcoin Core merged
  support for a `mempoolfullrbf` configuration option which defaults to
  the existing Bitcoin Core behavior of only allowing [RBF
  replacement][topic rbf] of transactions containing the [BIP125][]
  signal.  However, if a user sets the new option to true, their node
  will accept and relay replacements for transactions that don't contain the
  BIP125 signal, provided the replacement transactions follow all of
  Bitcoin Core's other rules for replacements.

  Dario Sneidermanis [posted][sne rbf] to the Bitcoin-Dev mailing list that
  this new option may create problems for services which currently accept
  unconfirmed transactions as final.  Although it's been possible for
  years for users to run non-Bitcoin Core software (or patched
  versions of Bitcoin Core) that allow unsignaled *full*[^full-rbf]
  transaction replacement, there's no evidence that software
  is widely used.  Sneidermanis believes an easily accessible
  option in Bitcoin Core might change that by allowing enough users
  and miners to enable full RBF and make unsignaled replacement
  reliable.  More reliable unsignaled replacement would also make it
  more reliable to steal from services that accept unconfirmed transactions
  as final, requiring those services to change their behavior.

  In addition to describing the problem and providing a detailed
  description of how services choose when to accept unconfirmed
  transactions,
  Sneidermanis also proposed an alternative approach: remove the configuration
  option from the upcoming Bitcoin Core release but also add code that
  will enable full RBF by default at a future moment.  Anthony Towns
  [posted][towns rbf] several options for consideration and opened a
  [pull request][bitcoin core #26323] that implements a slightly
  modified version of Sneidermanis's proposal.  If merged and released
  in its current state, Towns's PR will enable full RBF by default
  starting 1 May 2023.  Users objecting to full RBF will still be able
  to prevent their nodes from participating by setting the
  `mempoolfullrbf` option to false. {% assign timestamp="5:34" %}

- **Validity rollups research:** John Light [posted][light ml ru] to the
  Bitcoin-Dev mailing list a link to a [detailed research report][light
  ru] he prepared about validity rollups---a type of [sidechain][topic
  sidechains] where the current sidechain state is compactly stored on
  the mainchain.  A user of the
  sidechain can use the state stored on the mainchain to prove how
  many sidechain bitcoins they control.  By submitting a mainchain
   transaction with a validity proof, they can withdraw bitcoins they own from the
  sidechain even if the operators or miners of the
  sidechain try to prevent the withdrawal.

  Light's research describes validity rollups in depth, looks at how
  support for them could be added to Bitcoin, and examines various
  concerns with their implementation. {% assign timestamp="18:02" %}

- **MuSig2 security vulnerability:** Jonas Nick [posted][nick musig2] to
  the Bitcoin-Dev mailing list about a vulnerability he and several
  others discovered in the [MuSig2][topic musig] algorithm as documented
  in a [draft BIP][bips #1372].  In short, the protocol is vulnerable if
  an attacker knows a user's public key, a tweak to that public key that
  the user will sign for (such as with [BIP32][topic bip32] extended
  pubkeys), and can manipulate which version of the key the user will
  sign for.

  Jonas Nick believes the vulnerability "should only apply in
  relatively rare cases" and encourages anyone using (or soon planning
  to use) MuSig2 to reach out to him and his co-authors with
  questions.  The draft BIP for MuSig2 is expected to be updated soon
  to address the issue. {% assign timestamp="52:00" %}

- **Minimum relayable transaction size:** Greg Sanders [posted][sanders
  min] to the Bitcoin-Dev mailing list a request for Bitcoin Core to
  relax a policy added to make it harder to exploit the
  [CVE-2017-12842][] vulnerability.  This vulnerability allows an
  attacker who can get a specially-crafted 64 byte transaction confirmed
  into a block to trick lightweight clients into believing one or more
  different arbitrary transactions were confirmed.  E.g., innocent user
  Bob's Simplified Payment Verification (SPV) wallet might display that
  he'd received a million BTC payment with dozens of confirmations even
  though no such payment was ever confirmed.

  When the vulnerability was only privately known among a few
  developers, a limit was added to Bitcoin Core preventing relay of
  any transaction with fewer than 85 bytes (not counting witness
  bytes), which is about the smallest size that can be created using
  standard transaction templates.  This would require an attacker to
  get their transaction mined by software not based on Bitcoin Core.
  Later, the [consensus cleanup soft fork proposal][topic consensus
  cleanup] suggested permanently fixing the problem by disallowing any
  transactions less than 65 bytes in size from being included in new
  blocks.

  Sanders suggests lowering the transaction relay policy limit from 85
  bytes to the 65 byte limit suggested in consensus cleanup, which may
  allow additional experimentation and usage without changing the
  current risk profile.  Sanders has a [pull request][bitcoin core
  #26265] open to make this change.  See also [Newsletter #99][news99
  min] for prior discussion related to this proposed change. {% assign timestamp="55:55" %}

- **BIP324 update:** Dhruv M [posted][dhruv 324] to the Bitcoin-Dev
  mailing list a summary of several updates to the BIP324 proposal for a
  [version 2 encrypted P2P transport protocol][topic v2 p2p transport].
  This includes a rewrite of the [draft BIP][bips #1378] and the
  publication of a [variety of resources][bip324.com] to help reviewers
  evaluate the proposal, including an excellent [guide to the proposed
  code changes][bip324 changes] across multiple repositories.

  As described in the draft BIP's *motivation* section, a native
  encrypted transport protocol for Bitcoin nodes can improve privacy
  during transaction announcement, prevent tampering with connections
  (or at least make it easier to detect tampering), and also make P2P
  connection censorship and [eclipse attacks][topic eclipse attacks]
  more difficult. {% assign timestamp="1:01:52" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **btcd v0.23.2 released:**
  btcd v0.23.2 (and [v0.23.1][btcd 0.23.1]) adds [addr v2][topic addr v2] and additional
  support for [PSBTs][topic psbt], [taproot][topic taproot], and [MuSig2][topic
  musig] as well as other enhancements and fixes. {% assign timestamp="1:05:30" %}

- **ZEBEDEE announces hosted channel libraries:**
  In a recent [blog post][zbd nbd], ZEBEDEE announced an open source wallet (Open
  Bitcoin Wallet), Core Lightning plugin (Poncho), Lightning client (Cliché),
  and Lightning library (Immortan) which focus on support for [hosted channels][]. {% assign timestamp="1:06:30" %}

- **Cashu launches with Lightning support:**
  E-cash software [Cashu][cashu github] launches as a proof-of-concept wallet with
  Lightning receive support. {% assign timestamp="1:08:47" %}

- **Address explorer Spiral launches:**
  [Spiral][spiral explorer] is an open source public address [explorer][topic block explorers] that uses
  cryptography to provide privacy to users querying information about an address. {% assign timestamp="1:13:10" %}

- **BitGo announces Lightning support:**
  In a [blog post][bitgo lightning], BitGo describes its custodial Lightning
  service that runs nodes on behalf of its clients and maintains payment
  channel liquidity. {% assign timestamp="1:16:15" %}

- **ZeroSync project launches:**
  The [ZeroSync][zerosync github] project is using [Utreexo][topic utreexo] and
  STARK proofs to sync a Bitcoin node, as occurs in Initial Block Download (IBD). {% assign timestamp="1:17:42" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 24.0 RC2][] is a release candidate for the
  next version of the network's most widely used full node
  implementation.  A [guide to testing][bcc testing] is available. {% assign timestamp="1:20:16" %}

- [LND 0.15.3-beta][] is a minor release that fixes several bugs. {% assign timestamp="1:21:22" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23549][] adds the `scanblocks` RPC that identifies
  relevant blocks in a given range for a provided set of [descriptors][topic descriptors].
  The RPC is only available on nodes that maintain a [compact block
  filter][topic compact block filters] index (`-blockfilterindex=1`). {% assign timestamp="1:21:38" %}

- [Bitcoin Core #25412][] adds a new `/deploymentinfo` REST endpoint which
  contains information about soft fork deployments, similar to the
  existing `getdeploymentinfo` RPC. {% assign timestamp="1:23:29" %}

- [LND #6956][] allows configuring the minimum channel reserve enforced
  on payments received from a channel's partner.  A node won't accept a
  payment from its channel partner if that would lower the amount of the
  partner's funds in the channel below the reserve, which is 1% by
  default in LND.  This ensures the partner will need to pay at least
  the reserve amount as a penalty if it attempts to close a channel in a
  outdated state.  This merged PR allows lowering or raising the reserve
  amount. {% assign timestamp="1:23:49" %}

- [LND #7004][] updates the version of the BTCD library used by LND,
  fixing the security vulnerability previously described in this
  newsletter. {% assign timestamp="1:25:31" %}

- [LDK #1625][] begins tracking information about the liquidity of
  distant channels which the local node has attempted to route payments
  through.  The local node stores information about the size of payments
  which have either successfully been routed through the remote node or
  which failed due to apparent insufficient funds.  This information,
  adjusted for its age, is used as input for probabilistic pathfinding
  (see [Newsletter #163][news163 pr]). {% assign timestamp="1:25:54" %}

## Footnotes

<!-- TODO:harding is 95% sure the below is correct and will delete this
comment when he gets verification from the person he thinks first used
the "full RBF" term.  -->

[^full-rbf]:
    Transaction replacement was included in the first version of Bitcoin
    and has received much discussion over the years.  During that time,
    several terms used for describing aspects of it have changed,
    leading to potential confusion.  Perhaps the greatest source of
    confusion would be the term "full RBF", which has been used for two
    different concepts:

    - *Full replacement of any **part** of a transaction* as distinct
      from just adding additional inputs and outputs.  During a period
      when enabling RBF was controversial and before the idea of opt-in
      RBF was proposed, one [suggestion][superset rbf] was to allow a
      transaction to be replaced only if the replacement included all of
      the same outputs plus additional new inputs and outputs used to
      pay fees and collect change.  The requirement to keep the original
      outputs ensured the replacement would still pay the original
      receiver the same amount of money.  This idea, later called First
      Seen Safe (FSS) RBF, was a type of *partial* replacement.

      By comparison, *full* replacement at this time meant the
      replacement could fully change anything about the original
      transaction (provided it still conflicted with the original
      transaction by spending at least one of the same inputs).  It's
      this usage of full that's used in the title of [BIP125][],
      "Opt-in Full Replace-by-Fee Signaling".

    - *Full replacement of **any** transaction* as distinct from only
      replacing transactions that opt-in to allowing replacement via a
      BIP125 signal.  Opt-in RBF was proposed as a compromise between
      people who didn't want to allow RBF and those who believed it was
      either necessary or inevitable.  However, as of this writing,
      only a minority of transactions opt-in to RBF, which can be seen as
      partial adoption of RBF.

      By comparison, *full* adoption of RBF can be enabled by allowing
      any unconfirmed transaction to be replaced.  It's this usage of
      full that's used in the currently-discussed Bitcoin Core
      configuration option, `mempoolfullrbf`.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23549,25412,25667,2448,6956,6972,7004,1625,26323,1372,1378,26265" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[superset rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-March/002240.html
[brqgoo]: https://twitter.com/brqgoo/status/1579216353780957185
[big msig]: https://blockstream.info/tx/7393096d97bfee8660f4100ffd61874d62f9a65de9fb6acf740c4c386990ef73?expand
[news65 tapscript limits]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[lnd 0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[news221 lnd]: /en/newsletters/2022/10/12/#lnd-v0-15-2-beta
[btcd 0.23.2]: https://github.com/btcsuite/btcd/releases/tag/v0.23.2
[verloren limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020993.html
[sanders limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020996.html
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[sne rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020980.html
[towns rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021017.html
[light ml ru]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020998.html
[light ru]: https://bitcoinrollups.org/
[nick musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021000.html
[sanders min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020995.html
[cve-2017-12842]: /en/topics/cve/#CVE-2017-12842
[news99 min]: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion
[dhruv 324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020985.html
[bip324.com]: https://bip324.com
[bip324 changes]: https://bip324.com/sections/code-review/
[news163 pr]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[lnd 0.15.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.3-beta
[btcd 0.23.1]: https://github.com/btcsuite/btcd/releases/tag/v0.23.1
[zbd nbd]: https://blog.zebedee.io/announcing-nbd/
[hosted channels]: https://fanismichalakis.fr/posts/what-are-hosted-channels/
[cashu github]: https://github.com/callebtc/cashu
[spiral explorer]: https://btc.usespiral.com/
[bitgo lightning]: https://blog.bitgo.com/bitgo-unveils-custodial-lightning-898554d3b749
[zerosync github]: https://github.com/zerosync/zerosync
