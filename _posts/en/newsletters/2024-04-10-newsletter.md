---
title: 'Bitcoin Optech Newsletter #297'
permalink: /en/newsletters/2024/04/10/
name: 2024-04-10-newsletter
slug: 2024-04-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new domain-specific language for
experimenting with contract protocols, summarizes a discussion about
modifying BIP editor responsibilities, and describes proposals to reset
and modify testnet.  Also included are our regular sections with the
summary of a Bitcoin Core PR Review Club meeting, announcements of new
releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **DSL for experimenting with contracts:** Kulpreet Singh
  [posted][singh dsl] to Delving Bitcoin about a domain-specific
  language (DSL) he's working on for Bitcoin.  The language makes it
  easy to specify the operations that should be performed as part of a
  contract protocol.  This can make it easy to quickly execute the
  contract in a testing environment to ensure it behaves as expected,
  allowing fast iteration on new ideas for contracts and providing a
  baseline against which later full-fledged software can be developed.

  Robin Linus [replied][linus dsl] with a link to a somewhat similar
  project to allow a higher-level language to describe a contract
  protocol that will be compiled down to the necessary operations and
  low-level code to execute that protocol.  This work is being done as
  part of enhancing [BitVM][topic acc]. {% assign timestamp="1:24" %}

- **Updating BIP2:** Tim Ruffing [posted][ruffing bip2] to the
  Bitcoin-Dev mailing list about updating [BIP2][], which specifies the
  current process for adding new BIPs and updating
  existing BIPs.  Several problems with the current process mentioned by
  Ruffing and others included:

  - *Editorial evaluation and discretion:* how much effort should BIP
    editors be required to expend on ensuring new BIPs are high
    quality and focused on Bitcoin?  Separately, how much discretion
    should they have in being able to reject new BIPs?  Ruffing and
    several others mentioned that they'd prefer minimizing editorial
    requirements and privileges, perhaps depending on BIP editors
    only to prevent systemic abuse (e.g. mass spamming).  Of course,
    BIP editors---like any other community members---would be able to
    voluntarily suggest improvements to any BIP proposals they found
    interesting.

  - *Licensing:* some allowed licenses for BIPs are designed for
    software and may not make sense for documentation.

  - *Comments:* as a change from [BIP1][], BIP2 attempted to provide a
    place for community feedback on each BIP.  This has not been
    widely used and the results have been controversial.

  The idea of updating BIP2 was still being discussed at the time of
  writing.

  In a separate but related discussion, the nomination and advocacy for
  new BIP editors mentioned in [last week's newsletter][news296 editors]
  has been [extended][erhardt editors] to the UTC end of day on Friday,
  April 19th.  It is hoped that the new editors will receive merge
  access by the end of the day on the following Monday. {% assign timestamp="15:50" %}

- **Discussion about resetting and modifying testnet:** Jameson Lopp
  [posted][lopp testnet] to the Bitcoin-Dev mailing list about problems
  with the current public Bitcoin testnet (testnet3) and suggested
  restarting it, potentially with a different set of special-case
  consensus rules.

  Previous versions of testnet had to be restarted when some people
  began assigning economic value to testnet coins, resulting in them
  becoming hard to acquire for free for people who wanted to perform
  actual testing.  Lopp provided evidence of that happening again and
  also described the well-known problem of block flooding due to
  exploitation of testnet's custom difficulty adjustment algorithm.
  Multiple people discussed potential changes to testnet to address that
  and other problems, although at least one respondent [preferred][kim
  testnet] allowing problems to continue as it made for interesting
  testing. {% assign timestamp="21:00" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Implement 64 bit arithmetic op codes in the Script interpreter][review club 29221] is a PR by Chris Stewart (GitHub Christewart) that
introduces new opcodes allowing users to perform arithmetic operations
on larger (64-bit) operands in Bitcoin Script than is currently allowed
(32-bit).

This change, in combination with some existing soft fork proposals like [OP_TLUV][ml OP_TLUV] that enable transaction introspection, would allow
users to build scripting logic based on a transaction's
satoshi-denominated output values, which can easily overflow a 32-bit
integer.

Discussion on the approach, such as whether to upgrade existing opcodes
or introduce new ones (e.g., `OP_ADD64`), is still ongoing.

For more information, see the (WIP) [BIP][bip 64bit arithmetic], and the [discussion][delving 64bit arithmetic] on the Delving Bitcoin forum.

{% assign timestamp="37:19" %}

{% include functions/details-list.md q0="What does the `CScriptNum`
  `nMaxNumSize` parameter do?" a0="It represents the maximum size (in
  bytes) of the `CScriptNum` stack element being evaluated. By default,
  it is set to 4 bytes." a0link="https://bitcoincore.reviews/29221#l-34"

  q1="What 2 opcodes accept 5-byte numeric inputs?"
  a1="`OP_CHECKSEQUENCEVERIFY` and `OP_CHECKLOCKTIMEVERIFY` use signed
  integers to represent time stamps. Using 4 bytes, that would put the
  upper range of allowed dates in 2038. For that reason, a carve-out was
  made for these 2 time-based opcodes to accept 5-byte inputs. This is
  documented [in the code][docs 5byte carveout]."
  a1link="https://bitcoincore.reviews/29221#l-45"

  q2="Why was the `fRequireMinimal` flag introduced to `CScriptNum`?"
  a2="`CScriptNum` has a variable length encoding. As described in
  [BIP62][] (rule 4), this introduces opportunity for malleability. For
  example, zero can be encoded as `OP_0`, `0x00`, `0x0000`, ... [Bitcoin
  Core #5065][] fixed this in standard transactions [by requiring][doc SCRIPT_VERIFY_MINIMALDATA]
  a minimal representation for data pushes and stack elements that
  represent numbers." a2link="https://bitcoincore.reviews/29221#l-57"

  q3="Is the implementation in this PR malleability safe? Why?" a3="The
  current implementation requires a fixed-length 8-byte representation
  for the operands of a 64-bit opcode, making it safe against
zero-padding malleability. The rationale is to simplify implementation
logic, at the cost of increased blockspace usage. The author has also
explored using a `CScriptNum` variable encoding in [a different
branch][64bit arith cscriptnum]."
a3link="https://bitcoincore.reviews/29221#l-67" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 3.0.0][] is a release of the next version of this package
  providing a common interface to multiple different hardware signing
  devices.  The only significant change in this release is that emulated
  hardware wallets will no longer be automatically detected; see the
  description of [HWI #729][] below for details. {% assign timestamp="46:17" %}

- [Core Lightning 24.02.2][] is a maintenance release that fixes "a
  [small incompatibility][core lightning #7174]" between Core Lightning's
  and LDK's implementation of a particular part of the LN gossip
  protocol. {% assign timestamp="48:06" %}

- [Bitcoin Core 27.0rc1][] is a release candidate for the next major
  version of the network's predominant full node implementation.
  Testers are encouraged to review the list of [suggested testing
  topics][bcc testing]. {% assign timestamp="49:41" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until about six months after the release of the upcoming version 27.*

- [Bitcoin Core #29648][] removes libconsensus after it was previously
  deprecated (see [Newsletter #288][news288 libconsensus]).
  Libconsensus was an attempt to make Bitcoin Core's consensus logic
  usable in other software.  However, the library hasn't seen any
  significant adoption and it has become a burden on maintenance of
  Bitcoin Core. {% assign timestamp="50:25" %}

- [Bitcoin Core #29130][] adds two new RPCs.  The first will generate a
  [descriptor][topic descriptors] for a user based on the settings they want and then add
  that descriptor to their wallet.  For example, the following command
  will add support for [taproot][topic taproot] to an old wallet created
  without that support:

  ```
  bitcoin-cli --rpcwallet=mywallet createwalletdescriptor bech32m
  ```

  The second RPC is `gethdkeys` (get [HD][topic bip32] keys), which will
  return each xpub used by the wallet and (optionally) also each xpriv.
  When a wallet contains multiple xpubs, the particular one to use can
  be indicated when calling `createwalletdescriptor`. {% assign timestamp="53:18" %}

- [LND #8159][] and [#8160][lnd #8160] add experimental (disabled by
  default) support for sending payments to [blinded routes][topic rv
  routing].  A [follow-up PR][lnd #8485] is expected to add complete
  error handling for failed blinded payments. {% assign timestamp="56:44" %}

- [LND #8515][] updates multiple RPCs to accept the name of the [coin
  selection strategy][topic coin selection] to be used.  See [Newsletter
  #292][news292 lndcs] for the previous improvements to the flexibility
  of LND's coin selection that this PR builds upon. {% assign timestamp="59:08" %}

- [LND #6703][] and [#6934][lnd #6934] add support for inbound routing
  fees.  A node can already advertise the cost it will charge to forward
  a payment through a particular outbound channel.  For example, Carol
  might advertise that she will only forward payments to her channel
  peer Dan if the payments offer 0.1% of their value to her.  If that
  lowers the average number of satoshis (sats) per minute that Carol
  forwards to Dan below the average amount he forwards to her,
  eventually all of the channel balance will end up on Carol's side,
  preventing Dan from being able to forward more payments to her,
  reducing both of their revenue potentials.  To prevent that, Carol
  might lower her outbound forwarding fee to Dan to 0.05%.  Similarly,
  if Carol's lower outbound forwarding fee to Dan results in her
  forwarding more sats per minute to him than he forwards to her, all of
  the balance might end up on his side of the channel, also preventing
  additional forwarding and revenue earning; in that case, Carol can
  raise her outbound fees.

  However, outbound fees only apply to outbound channels.  Carol is
  offering to charge the same fee regardless of what channel she
  receives the payment over; for example, she charges the same rate
  whether she receives the payment from either of her channel peers
  Alice or Bob:

  ```
  Alice -> Carol -> Dan
  Bob -> Carol -> Dan
  ```

  This makes sense since the base LN protocol doesn't pay Carol for
  receiving a forwarding request from Alice or Bob.  Alice and Bob can
  set outbound fees for their channels to Carol, and it's up to them to
  set fees that help keep the channels liquid.  Similarly, Carol can
  adjust her fees for outbound payments to Alice and Bob (e.g. `Dan ->
  Carol -> Bob`) to help manage liquidity.

  However, Carol may want more control over policies that affect her.
  For example, if Alice's node is poorly managed, she might frequently
  forward payments to Carol without many people later wanting to forward
  payments from Carol to Alice.  That would eventually end with all the
  funds in their channel ending up on Carol's side, preventing further
  payments in that direction.  Before this PR, there was nothing Carol
  could do about that, except close her channel with Alice before it
  wasted too much of the value of Carol's capital.

  With this PR, Carol can now also charge an _inbound forwarding fee_
  that is specific to each channel.  For example, she might charge a
  high fee for payments arriving inbound from Alice's problematic node
  but a lower fee for payments arriving inbound from Bob's highly liquid
  node.  Initial inbound fees are expected to always be negative to make
  them backward compatible with older nodes that don't understand
  inbound fees; for example, Carol might give a 10% fee discount on
  payments forwarded by Bob and a 0% discount on payments forwarded by
  Alice.

  The fees are assessed simultaneously with the outbound fees.  For
  example, when Alice offers a payment to Carol for forwarding to Dan,
  Carol calculates the original `dan_outbound` fee, calculates the new
  `alice_inbound` fee, and ensures the forwarded payment offers her at
  least the sum of both.  Otherwise, she rejects the [HTLC][topic htlc].
  Since the initial inbound fees are always expected to be negative,
  Carol won't reject any payments that pay sufficient outbound fees, but
  any node that's now aware of inbound fees may be able to receive a
  discount.

  Inbound routing fees were first [proposed][bolts #835] about three
  years ago, [discussed][jager inbound] on the Lightning-Dev mailing
  list about two years ago, and documented in draft [BLIPs #18][]
  also about two years ago.  Since its initial proposal, several
  maintainers of LN implementations besides LND have opposed it.  Some
  have opposed it on [principle][teinturier bolts835]; others have
  opposed its design as being [overly specific to LND][corallo overly
  specific] rather than a local and generic upgrade that can immediately
  use positive inbound forwarding fees and doesn't require global
  advertisement of additional fee details for each channel.  An
  alternative approach is proposed in draft [BLIPs #22][].  We're only
  aware of one maintainer of a non-LND implementation
  [indicating][corallo free money] that they'll adopt LND's method---and
  only in cases where negative inbound forwarding fees are offered, as
  that's "free money for our users." {% assign timestamp="1:01:48" %}

- [Rust Bitcoin #2652][] changes what public key is returned by the API
  when signing a [taproot][topic taproot] input as part of processing a
  [PSBT][topic psbt].  Previously, the API returned the public key for
  the signing private key.  However, the PR notes that "it is common to
  think of the internal key as being the one that signs even though this
  is not technically true. We also have the internal key in the PSBT."
  With the merge of this PR, the now API returns the internal key. {% assign timestamp="1:16:52" %}

- [HWI #729][] stops automatically enumerating and using device
  emulators.  Emulators are mainly used by developers of HWI and
  hardware wallets, but attempting to automatically detect them may
  cause issues for regular users.  Developers who do want to work with
  emulators now need to pass an additional `--emulators` option. {% assign timestamp="46:29" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 16:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="729,29648,29130,8159,8160,8485,8515,6703,6934,835,18,22,2652,7174,5065" %}
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[HWI 3.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0
[Core Lightning 24.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.2
[news292 lndcs]: /en/newsletters/2024/03/06/#lnd-8378
[news288 libconsensus]: /en/newsletters/2024/02/07/#bitcoin-core-29189
[teinturier bolts835]: https://github.com/lightning/bolts/issues/835#issuecomment-764779287
[corallo free money]: https://github.com/lightning/blips/pull/18#issuecomment-1304319234
[corallo overly specific]: https://github.com/lightningnetwork/lnd/pull/6703#issuecomment-1374694283
[jager inbound]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-July/003643.html
[singh dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748
[linus dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748/4
[ruffing bip2]: https://gnusha.org/pi/bitcoindev/59fa94cea6f70e02b1ce0da07ae230670730171c.camel@timruffing.de/
[news296 editors]: /en/newsletters/2024/04/03/#choosing-new-bip-editors
[erhardt editors]: https://gnusha.org/pi/bitcoindev/c304a456-b15f-4544-8f86-d4a17fb0aa8c@murch.one/
[lopp testnet]: https://gnusha.org/pi/bitcoindev/CADL_X_eXjbRFROuJU0b336vPVy5Q2RJvhcx64NSNPH-3fDCUfw@mail.gmail.com/
[kim testnet]: https://gnusha.org/pi/bitcoindev/950b875a-e430-4bd8-870d-f9a9fab2493an@googlegroups.com/
[review club 29221]: https://bitcoincore.reviews/29221
[delving 64bit arithmetic]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[bip 64bit arithmetic]: https://github.com/bitcoin/bips/pull/1538
[64bit arith cscriptnum]: https://github.com/Christewart/bitcoin/tree/64bit-arith-cscriptnum
[docs 5byte carveout]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.cpp#L531-L544
[doc SCRIPT_VERIFY_MINIMALDATA]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.h#L69-L73
[ml OP_TLUV]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
