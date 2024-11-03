---
title: 'Bitcoin Optech Newsletter #101'
permalink: /en/newsletters/2020/06/10/
name: 2020-06-10-newsletter
slug: 2020-06-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a blog post and paper about using
eclipse attacks against Bitcoin software in order to steal from LN
channels and describes the history and impact of a fee overpayment
attack that affects hardware wallets.  Also included are our regular
sections with the summary of a Bitcoin Core PR Review Club meeting,
descriptions of recent software releases, and summaries of recent
changes to popular Bitcoin infrastructure projects.

## Action items

- **Check hardware wallet compatibility:** if your software or your
  processes allow using hardware wallets to spend segwit inputs, check
  whether your system remains compatible with your wallet's latest
  firmware update.  For example, [Trezor's latest firmware][trezor
  update] requires software interfacing with it to be upgraded to
  continue handling segwit inputs; [Ledger's latest firmware][ledger update] will
  print a warning when processing segwit inputs received from
  non-updated software.  Other hardware wallets may release similar
  updates in the future; contact the manufacturers for more information
  about their plans.  See the *News* item below about the fee
  overpayment attack for the motivation for this change.

## News

- **Time dilation attacks against LN:** Gleb Naumenko and Antoine Riard
  [posted][naumenko td] to the Bitcoin-Dev mailing list a summary of a
  [blog post][td blog] they wrote that itself summarizes a [paper][td
  paper] they authored about using [eclipse attacks][topic eclipse attacks]
  to steal money from LN channels.  This extends the analysis by Riard
  described in [Newsletter #77][news77 eclipse].  In short, an attacker
  gains control over all of an LN node's connections to the Bitcoin P2P
  network and delays the relay of new block announcements to the victim.
  After the victim's view of the block chain is far enough behind the
  public consensus view, the attacker closes their channels with the
  victim in an outdated state that pays the attacker more than the
  latest state would.  The eclipse attack is used to prevent the victim
  from seeing the close transactions until after the dispute period is
  over and the attacker has withdrawn their illicit gains to an address
  entirely under the attacker's control.

  The paper describes an attack that can steal from lightweight
  clients in as little as two hours.  With there currently being so
  few servers and nodes providing data to lightweight LN clients, it
  may be fairly easy for an attacker to create enough sybils to
  execute the attack.  Attacks against LN nodes backed by a local
  Bitcoin full verification node take longer---still only a matter of
  hours---and may require creating many more sybils.
  The authors note that the attacks probably also apply to other
  time-sensitive contract protocols.  The general solution to the
  problem is to improve eclipse attack resistance, with one specific
  proposed improvement being to allow nodes to opt-in to [alternative
  transport protocols][Bitcoin Core #18988].

- **Fee overpayment attack on multi-input segwit transactions:** The
  fee paid by a Bitcoin transaction is the difference between
  the amounts of the UTXOs the transaction spends and the amounts
  of the UTXOs it creates.  Transactions explicitly state the amounts
  of the UTXOs they create, but the amounts of the UTXOs they spend can
  only be found by looking at the previous transactions that created
  those UTXOs.  The spending transaction simply commits to the txid and
  position of the UTXOs it wants to spend, requiring other software that
  wants to calculate the fee to either look up each UTXO's previous
  transaction or to maintain a database of verified UTXO data.

  Hardware wallets don't maintain a UTXO set, so the only trustless
  way for them to determine the amount of fee paid by a transaction
  with legacy UTXOs is to get a copy of each legacy UTXO's previous
  transaction, hash the previous transaction to ensure its txid
  matches the UTXO reference, and use the now-verified amount of the
  UTXO to perform the fee calculation.  In the worst case, legacy transactions can
  be almost as large as one megabyte and it's possible for a spending
  transaction to reference thousands of previous transactions, so amount
  verification can require the processing of gigabytes of data by
  resource-constrained hardware wallets.

  One of the several improvements made in [BIP143][] segwit v0 was an
  attempt to eliminate this burden by having [signatures commit to the
  amount][bip143 motivation] of the UTXO they were spending.  This
  meant that any signatures that committed to an incorrect amount
  would be invalid, which developers of both [Bitcoin Core][towns
  benefits] and [hardware wallets][palatinus inpatient] believed would
  allow signers to safely accept amounts from untrusted software.

  Unfortunately, signing a single UTXO's amount turned out to be
  insufficient.  In 2017, Greg Sanders [described][sanders attack] an
  attack that can be used to trick a user into significantly
  overpaying their transaction fee.  To start, an attacker takes
  control of the desktop or mobile software that interfaces with a
  hardware wallet and waits for the user to initiate a payment.  The
  compromised software creates two variations of the requested
  transaction that each spend the same two segwit UTXOs controlled by
  the user's attached hardware wallet.  In the first transaction, the
  compromised software understates the amount of one of the UTXOs
  being spent.  This will cause the hardware wallet to under-calculate
  the transaction fee by that same understated amount.  In the second
  transaction, the compromised software understates the amount of the
  second UTXO.  That will cause the hardware wallet to also
  under-calculate the second transaction's fee.

  The compromised software sends the first transaction to the hardware
  wallet.  The user checks the amount, receiver address, and calculated
  transaction fee.  The user authorizes signing and the signed
  transaction is returned to the compromised software.  This first
  transaction is invalid under BIP143 because one of its signatures
  commits to an incorrect UTXO amount.  The compromised software then
  claims that there was some minor problem that prevented the
  transaction from being broadcast and tells the user they need to
  re-sign the transaction, but the software doesn't re-send the first
  transaction---it instead sends the second transaction.  Based on the
  information displayed by the hardware wallet (amount, receiver, and
  fee), the second transaction looks identical to the first
  transaction, so it's likely the user will authorize signing it.
  This second transaction is also BIP143 invalid because one of its
  signatures commits to an incorrect amount.  However, each of the two
  transactions also had one valid signature and the compromised
  software is able to use those two valid signatures to synthesize a
  valid transaction that overpays its fees.

  ![Fee overpayment attack illustration](/img/posts/2020-06-fee-overpayment-attack.dot.png)

  The worst case is an attack that prompts the user to sign *n* times
  for a wallet that controls *n* UTXOs and which results in spending
  all of the wallet's funds to fees except for the legitimate payment
  amount.

  Similar to the other attack described in Sander's 2017 email (see
  [Newsletter #97][news97 spk commit]), this attack only affects
  *stateless signers*, such as hardware wallets, which depend on an
  external system to tell them about the UTXOs they control.
  Networked wallets which track the amounts of their received UTXOs
  won't sign for incorrect UTXO amounts and so aren't affected by this
  attack.  Of course, networked wallets are vulnerable to other
  attacks, which is why hardware wallets can enhance user security.

  This past week, Trezor [announced][trezor post] that Saleem Rashid
  rediscovered this vulnerability about three months ago.  In
  response, Trezor has updated its firmware to require copies of
  previous transactions for segwit UTXOs the same way it requires them
  for legacy UTXOs.  This has broken compatibility with several
  wallets that interface with Trezor devices, either directly or
  through [HWI][topic hwi] (see [HWI #340][]).  In cases where wallets have full copies
  of the previous transactions or are able to obtain them, restoring
  compatibility should just be a matter of updating the wallet code.
  In other cases where wallets may not store full copies of previous
  transactions that paid the wallet, this may require redesigning the
  wallet to store that data plus require rescanning the block chain
  for past wallet transactions.  Software that creates or updates
  [Partially Signed Bitcoin Transactions][topic psbt] (PSBTs) will
  need to be [upgraded][Bitcoin Core #19215] to include the full copies
  of previous transactions into the PSBTs.  For cases where PSBTs are
  stored in size-constrained
  media (e.g., QR codes, see [Newsletter #96][news96 qr]), the
  potentially significant increase in data size may require abandoning
  the protocol or switching to higher-capacity media.

  Ledger has made a similar change, but their [support
  article][ledger update] says they only display a warning when
  spending segwit UTXOs without full copies of their previous
  transactions.  Although requiring previous transactions does
  maximize user safety against this attack, there are also arguments
  for allowing hardware wallets to optionally continue to use segwit's
  signed UTXO values rather than breaking existing software and
  expending additional resources on legacy-style value verification:

  - **Attack already well-known for three years:** Sanders publicly
    described the attack almost three years ago and it's been
    mentioned or alluded to by others on the [mailing list][lau
    sighash2], in [BIPs][bip341 all amounts], and in Newsletters
    [#11][news11 sighash] and [#46][news46 digest changes], among
    other discussions.  It was [believed][wuille minimal impact] that
    "everyone thought it was too hard to deal with, and only of
    minimal impact".
    Any attacker who gains access to the software controller for
    a hardware wallet is perhaps more likely to perform a different
    attack---such as an [address substitution attack][hw
    security]---that pays the attacker directly rather than overpaying
    transaction fees.

  - **Double signing can also lead to spending twice:** the attack
    depends on using compromised software to get a hardware wallet
    user to authorize two slightly different transactions (each with
    two inputs) that look identical to the user.  Yet the same
    compromised software could show the user two completely different
    transactions (each spending a different input) that look
    identical, resulting in paying the same recipient twice.  Both
    attacks are indistinguishable from the user's perspective, but the
    fix for the fee overpayment attack doesn't fix the [spending twice
    attack][maxwell spend twice].

  - **Multisig setups may require multiple compromises:** to perform
    the attack against funds secured by multisig with multiple
    hardware wallets, each signer that is needed to meet the minimal
    threshold (e.g., "2" in a "2-of-3" multisig) would need to be
    tricked into signing the same two transaction variations.  For
    thresholds that include an online wallet which knows the value of
    the UTXO it's signing for (e.g., a policy-based remote signer), the
    attack only works if that online wallet is also compromised.

  A long-term solution to the attack is to change the transaction
  digest so that each signature commits to the value of all UTXOs
  being spent in that transaction.  That will make the signature
  invalid if compromised software lies about the amount of any UTXO.  This was
  [proposed][lau sighash2] by Johnson Lau in 2018 (see [Newsletter
  #11][news11 sighash]) and has been included in the [BIP341][]
  specification of [taproot][topic taproot] since its earliest public
  drafts (see [Newsletter #46][news46 digest changes]).  If taproot is
  adopted, then it should become safer for stateless signers
  like hardware wallets to sign for taproot UTXOs without evaluating
  previous transactions.  Unfortunately, that still doesn't fix the
  spending twice attack, which is an issue with the [stateless design][wuille stateless]
  of most hardware wallets that prevents them from internally tracking
  their own transaction history.

## Bitcoin Core PR Review Club

_In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting._

[Connection eviction logic tests][review club #16756] is a PR ([#16756][Bitcoin
Core #16756]) by Martin Zumsande that adds missing test coverage for part of the
Bitcoin network peer eviction logic. The test verifies that the inbound peers
which relay transactions and blocks, and which respond quickly, are protected from
eviction.

The discussion centered on eviction logic and the protection of inbound peer
connections in Bitcoin Core:

{% include functions/details-list.md
  q0="What does a Bitcoin Core node do when the number of inbound connections
      reaches the limit?"
  a0="When the node connections are full, the node reacts to the connection of a
      new inbound peer by terminating the connection with an existing inbound
      peer. This is referred to as “eviction.”"

  q1="Why does Bitcoin Core evict peers instead of no longer
      accepting new inbound connections?"
  a1="The goal is to continuously select for well-behaved peers, from a variety
      of networks, that relay blocks quickly---and to prevent a malicious party
      from monopolizing the connection slots. The first connections to arrive aren't
      necessarily the best ones, so an eviction mechanism is needed."
  a1link="https://bitcoincore.reviews/16756#l-41"

  q2="Why does Bitcoin Core protect selected peers from eviction?"
  a2="We want to keep connections that have proven to be useful and increase
      the difficulty for a malicious party to evict and occupy all the inbound
      connections. Therefore, a small number of peers are protected for each of
      several distinct characteristics which are difficult to forge. In order to
      partition a node, the attacker must simultaneously be better at all of
      them than honest peers."
  a2link="https://github.com/bitcoin-core-review-club/bitcoin/blob/pr16756/src/net.cpp#L846"

  q3="Describe the algorithm for inbound peer eviction in Bitcoin Core."
  a3="Select all inbound peers except those on the `NO BAN` list or already
      scheduled for disconnection. Then, remove (protect) the best peers
      according to costly, difficult-to-forge attributes, which each apply
      separately: network group, lowest minimum ping time, recently sent transactions
      and blocks, desirable service flags, and long-lasting connections. Of the
      remaining peers, choose one to evict from the network group with the most
      connections."
  a3link="https://github.com/bitcoin-core-review-club/bitcoin/blob/pr16756/src/net.cpp#L851"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0][] is the newest major release from the original
  Bitcoin project.  This release's most notable user-visible improvements
  include default [bech32][topic bech32] addresses for RPC users (the GUI began
  defaulting to bech32 in 0.19), the ability to configure RPC
  permissions for different users and applications (see [Newsletter
  #77][news77 rpcwhitelist]), some basic support for generating PSBTs in
  the GUI ([#74][news74 psbtgui] & [#82][news82 psbtgui]), and a
  `sortedmulti` addition to the [output script descriptor][topic
  descriptors] language that can make it easier to watch multisig
  addresses generated from lexicographically sorted keys, such as those
  used with Coldcard's native multisig support ([#68][news68
  sortedmulti]).

  Many less visible improvements have also been made to the code in
  order to eliminate bugs, enhance security, and prepare for future
  changes.  One forward-looking change that's attracted some attention
  is the addition of an `asmap` configuration setting that allows
  using a separately downloaded database to improve Bitcoin Core's
  ability to diversify its connections among networks
  controlled by many different groups, increasing its resistance to
  [eclipse attacks][topic eclipse attacks] such as the [Erebus
  attack][] (see [Newsletter #83][news83 asmap]).  However, one of the
  authors of the feature
  [notes][wuille asmap], "it's highly experimental for now, and
  unclear how to progress from that.  Gathering and compiling the
  ASN [Autonomous Service Number] data is very nontrivial, and poses
  trust questions."

  For more information about all the changes as well as a list of over
  100 people who contributed to this new version, see the project's
  [release notes][core20 rn].

- [LND 0.10.1-beta][] is a new minor release of this popular LN node
  software.  The release notes announce no major new features but
  do mention several bug fixes, a "new dry run migration mode to test
  out migrations before they're applied permanently, and an enhancement
  to the channel selection/restrictions in the router sub-server."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Eclair #1440][] makes it possible to use the API to update multiple channels at once. Proposed
  initially to help node operators adjust to the dynamic on-chain fee market
  by batch updating their channels' relay fees, this addition enables batch
  closing and force-closing as well.

- [Eclair #1141][] adds support for `option_static_remotekey` channels.
  In the case of data loss by an LN node, this feature allows the channel
  counterparty to pay the current balance to an untweaked key agreed upon during the initial
  channel open, closing the channel and allowing the node's wallet to
  spend its funds normally. See [Newsletter #67][news67 static_remotekey] for
  more details on this feature.

- [LND #4251][] brings its REST interface's list of supported non-streaming
  messages to parity with that of its gRPC interface. Previously, only a subset
  of these messages (specifically those of the `Lightning` subserver) were
  available via the REST interface. This PR will be followed by [LND
  #4141][], which brings the REST interface to full parity with the gRPC
  interface by adding support for streaming responses with WebSockets.

- [BIPs #920][] updates the [BIP341][] specification of [taproot][topic
  taproot] to require signatures to directly commit to the scriptPubKeys
  of all the UTXOs being spent.  This makes it easier for hardware
  wallets to safely participate in [coinjoins][topic coinjoin] and other collaboratively
  generated transactions.  For details, see the description in
  [Newsletter #97][news97 spk commit].

## Special thanks

We thank Pieter Wuille for assistance researching the history of the fee
overpayment attack.  We thank Antoine Riard for additional information
about the time dilation attack paper.  Any errors or omissions are the fault of the
newsletter author.

{% include references.md %}
{% include linkers/issues.md issues="1440,4251,920,1141,18988,19215,4141,16756" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta
[news97 spk commit]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[news77 eclipse]: /en/newsletters/2019/12/18/#discussion-of-eclipse-attacks-on-ln-nodes
[hw security]: https://en.bitcoin.it/wiki/Hardware_wallet#Security_risks
[towns benefits]: https://bitcoincore.org/en/2016/01/26/segwit-benefits/#signing-of-input-values
[palatinus inpatient]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-October/013248.html
[news11 sighash]: /en/newsletters/2018/09/04/#proposed-sighash-updates
[naumenko td]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017920.html
[td blog]: https://discrete-blog.github.io/time-dilation/
[td paper]: https://arxiv.org/abs/2006.01418
[lau sighash2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016345.html
[maxwell spend twice]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-05.html#l-352
[bip143 motivation]: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki#motivation
[sanders attack]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-August/014843.html
[news97 spk commit]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[trezor post]: https://blog.trezor.io/details-of-firmware-updates-for-trezor-one-version-1-9-1-and-trezor-model-t-version-2-3-1-1eba8f60f2dd
[bip341 all amounts]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-17
[news96 qr]: /en/newsletters/2020/05/06/#qr-codes-for-large-transactions
[news46 digest changes]: /en/newsletters/2019/05/14/#digest-changes
[wuille asmap]: https://twitter.com/pwuille/status/1268296477584965634
[news77 rpcwhitelist]: /en/newsletters/2019/12/18/#bitcoin-core-12763
[news74 psbtgui]: /en/newsletters/2019/11/27/#bitcoin-core-16944
[news82 psbtgui]: /en/newsletters/2020/01/29/#bitcoin-core-17492
[news68 sortedmulti]: /en/newsletters/2019/10/16/#bitcoin-core-17056
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[core20 rn]: https://bitcoincore.org/en/releases/0.20.0/
[news67 static_remotekey]: /en/newsletters/2019/10/09/#bolts-642
[trezor update]: https://blog.trezor.io/latest-firmware-updates-correct-possible-segwit-transaction-vulnerability-266df0d2860
[ledger update]: https://support.ledger.com/hc/en-us/articles/360014191540
[erebus attack]: https://erebus-attack.comp.nus.edu.sg/
[wuille minimal impact]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-04.html#l-613
[wuille stateless]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-05.html#l-395
[hwi #340]: https://github.com/bitcoin-core/HWI/pull/340
