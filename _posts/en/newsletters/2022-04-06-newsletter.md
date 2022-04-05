---
title: 'Bitcoin Optech Newsletter #194'
permalink: /en/newsletters/2022/04/06/
name: 2022-04-06-newsletter
slug: 2022-04-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for delinked reusable
addresses, summarizes how the WabiSabi protocol may be used as an
enhanced alternative to payjoin, examines a discussion about adding
communication standards to the DLC specification, and looks at renewed
discussion about updating LN commitment formats.  Also included are our
regular sections with summaries of new software releases and release
candidates plus descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Delinked reusable addresses:** Ruben Somsen posted a
  [proposal][somsen silpay] to the Bitcoin-Dev mailing list for allowing
  someone to pay a public identifier ("address") without using that
  identifier onchain.  For example, Alice creates an identifier in the
  form of a public key, which she posts on her website.  Bob is able to
  use one of his own private keys to transform Alice's public key into a
  new Bitcoin address which he uses to pay Alice.  Only Alice and Bob
  have the information necessary to determine that address pays
  Alice---and only Alice has the information necessary (her private key)
  to spend funds received to that address.  If Carol later goes to
  Alice's website and reuses Alice's public identifier, she would derive
  a different address to pay Alice, an address which neither Bob nor any
  other third party could directly determine belonged to Alice.

    Previous schemes for delinked reusable addresses, such as [BIP47][]
    reusable payment codes and the unpublished BIP63 stealth addresses,
    depend on either communication between spender and receiver outside
    of the block chain or for onchain transactions that contain extra
    data at increased expense over a regular payment.  By contrast,
    Somsen's *silent payments* proposal has no additional overhead
    compared to a regular transaction.

    The most significant downside of silent payments is that checking
    for newly-received transactions requires scanning every transaction
    in every new block.  This is something that full nodes already do,
    but the scheme also requires maintaining information about many
    transaction's parent transactions---something many full nodes today
    don't do, and which may require considerable extra I/O operations in
    addition to extra CPU.  Restoring a wallet from backup may also be
    onerous.  Although Somsen does describe some possible tradeoffs that
    could reduce the burdens, it seems unlikely that the scheme would be
    useful for most light wallets that want to receive payments.
    However, nearly all wallets would likely be able to add support for
    sending silent payments with just a few lines of code and no
    discernible increase in resource requirements.  This may allow the
    costs of the scheme to be borne chiefly by the users who most
    desire the enhanced privacy it offers to those unable or unwilling
    to use other mechanisms for preventing [address reuse][topic output
    linking].

    Somsen is seeking feedback on the proposal, including security
    analysis of its use of cryptography and any suggestions for making
    it less resource intensive for receivers (without significantly
    degrading its privacy advantages).

- **WabiSabi alternative to payjoin:** several weeks ago, developers of
  the Wasabi wallet and [coinjoin][topic coinjoin] implementation
  [announced][wasabi2] a new version on the Bitcoin-Dev mailing list
  with support for the WabiSabi protocol described in [Newsletter
  #102][news102 wabisabi].  The previously-used chaumian coinjoin
  protocol allowed arbitrary input amounts but only fixed-sized output
  amounts; the enhanced WabiSabi protocol allows both input and output
  amounts to be arbitrary values (subject to other constraints, such as
  limiting the maximum transaction size and obeying the [dust
  limit][topic uneconomical outputs]).

    This week, Max Hillebrand [posted][hillebrand wormhole] a
    description of how the WabiSabi protocol could be used as an
    alternative to the [payjoin][topic payjoin] protocol.  In standard
    payjoin, both the sender and the receiver contribute inputs to a
    transaction and receive outputs.  Although each party learns about
    the other's inputs and outputs, ownership information on the public
    block is discombobulated both for the users participating in the
    payjoin and for other multi-input transactions.  Hillebrand's
    proposed wormhole 2.0 protocol would use WabiSabi to ensure that
    neither the spender or receiver of a payment would learn each
    other's inputs or outputs (provided the WabiSabi coinjoin contained
    multiple other parties who respected confidentiality).  This would
    offer even more privacy, although it would require using software
    that implemented WabiSabi and waiting for a coordinated WabiSabi
    coinjoin transaction to occur.

- **DLC messaging and networking:** Thibaut Le Guilly [posted][leguilly
  dlcmsg] to the DLC-Dev mailing list about improving communication
  between different DLC implementations.  Today, separate
  implementations are using a variety of different methods to find and
  communicate with other DLC nodes.  These variations prevent nodes
  using one implementation from interoperating with nodes using a
  different implementation.  Le Guilly notes that the point of having a
  DLC standard is to allow interoperation, so he suggests adding relevant
  details to the standard.

    Several details were discussed.  In particular, Le Guilly would
    prefer to re-use elements of the LN specification (BOLTs) when
    possible.  This led to a mention that a recent proposal for
    upgrading LN channel announcements (see [Newsletter #193][news193
    major update]) that would allow the use of any UTXO for
    anti-flooding DoS protection (not just UTXOs that look like LN setup
    transactions) would allow DLCs and other second-layer protocols to
    use that same anti-DoS protection.

- **Updating LN commitments:** Olaoluwa Osuntokun [posted][osuntokun
  dyncom] to the Lightning-Dev mailing list this week with a follow-up
  to his previous proposal for [upgrading channel commitment
  formats][topic channel commitment upgrades]---or for upgrading any
  other setting that would affect commitment transactions.  See
  [Newsletter #108][news108 upcom] for a summary of his previous
  proposal.  The goal is to allow channels to remain open even when new
  features are added to a channel, such as the ability to [use taproot
  features][zmn post].

    Osuntokun's proposal contrasts with an alternative proposal
    described in [BOLTs #868][], implemented experimentally in
    C-Lightning, and mentioned in [Newsletter #152][news152 cl4532].  A
    noteworthy difference between the two proposals is that Osuntokun's
    proposal upgrades channels even while new payments ([HTLCs][topic
    htlc]) may be proposed, while the BOLTS #868 proposal defines a
    quiet period during which the upgrade can occur.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 23.0 RC2][] is a release candidate for the next major
  version of this predominant full node software.  The [draft release
  notes][bcc23 rn] list multiple improvements that advanced users and
  system administrators are encouraged to [test][test guide] before the final release.

- [LND 0.14.3-beta.rc1][] is a release candidate with several bug fixes
  for this popular LN node software.

- [C-Lightning 0.11.0rc1][] is a release candidate for the next major
  version of this popular LN node software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24118][] adds a new RPC, `sendall`, which empties a
  wallet to the benefit of a single recipient address. The call's
  options can be used specify additional recipients, specify a subset of
  the wallet's UTXO pool to be used as inputs, or to maximize the
  recipient amount by skipping dust rather than leaving no UTXOs behind.
  `sendall` therefore offers a convenient alternative to achieve some
  applications of the `fSubtractFeeAmount` argument to other `send*`
  RPCs, but `fSubtractFeeAmount` is still the best option for paying a
  recipient who is liable for
  transaction fees.

- [Bitcoin Core #23536][] sets validation rules to always enforce [taproot][topic taproot]
  whenever segwit is enforced, including validation of historical blocks
(except for block 692261 which included a transaction spending a v1 witness
output before taproot activated). This *buried deployment* has also been done for P2SH and
segwit soft forks (see [Newsletter #60][news60 buried]); it simplifies testing and code review, mitigates some
risk of potential bugs in deployment code, and offers belt-and-suspenders
protection for extreme scenarios in which a node downloads an alternative
most-work block chain where taproot has not activated.

- [Bitcoin Core #24555][] adds [documentation][cjdns.md] for running Bitcoin Core over the
  CJDNS [network][topic anonymity networks] (see [Newsletter #175][news175 cjdns]).

- [C-Lightning #5013][] adds the ability to administer a node using gRPC
  with mTLS authentication.

- [C-Lightning #5121][] updates the `invoice` RPC with a new `deschash`
  parameter that will include the hash of arbitrary data in the
  [BOLT11][] invoice rather than a short description string.  This is
  supported by schemes such as [LNURL][] that can send large
  descriptions (including data like images) through a separate
  communication channel without BOLT11's constraints.

- [Eclair #2196][] adds a `channelbalances` API that lists the balance
  of all the node's channels, including channels that have been
  disabled.

- [LND #6263][] adds support for [taproot][topic taproot] keypath spends
  to LND's wallet, which may now be tested using the default
  [signet][topic signet].

- [Libsecp256k1 #1089][] renames the `secp256k1_schnorrsig_sign()`
  function to `..._sign32()`, making it clearer that this function signs
  32-byte messages (e.g. a SHA256 hash digest).  This is in contrast
  to the `secp256k1_schnorrsig_sign_custom()` function which signs an
  arbitrary-length message (see [Newsletter #157][news157 schnorrsig]
  for additional discussion).

- [Rust Bitcoin #909][] adds support for creating optimal taproot
  scriptpath trees using [huffman coding][] by passing in the
  probability that a particular script path will be used.

- [LDK #1388][] adds default support for creating ECDSA signatures that
  are smaller than average by finding a value that can be encoded more
  compactly, a process previously implemented in the wallets for Bitcoin
  Core and C-Lightning (see [Newsletters #8][news8 lowr] and
  [#71][news71 lowr]).  This [low-r grinding][topic low-r grinding] will
  save roughly 0.125 vbytes per LDK peer in onchain transactions.

{% include references.md %}
{% include linkers/issues.md v=1 issues="868,24118,23536,24555,5013,5121,2196,6263,1089,909,1388" %}
[bitcoin core 23.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[C-Lightning 0.11.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc1
[news157 schnorrsig]: /en/newsletters/2021/07/14/#libsecp256k1-844
[news8 lowr]: /en/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures
[news71 lowr]: /en/newsletters/2019/11/06/#c-lightning-3220
[news108 upcom]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news152 cl4532]: /en/newsletters/2021/06/09/#c-lightning-4532
[zmn post]: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot
[osuntokun dyncom]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003531.html
[somsen silpay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020180.html
[wasabi2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020032.html
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[hillebrand wormhole]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020186.html
[leguilly dlcmsg]: https://mailmanlists.org/pipermail/dlc-dev/2022-March/000135.html
[news193 major update]: /en/newsletters/2022/03/30/#major-update
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[huffman coding]: https://en.wikipedia.org/wiki/Huffman_coding
[news60 buried]: /en/newsletters/2019/08/21/#hardcoded-previous-soft-fork-activation-blocks
[news175 cjdns]: /en/newsletters/2021/11/17/#bitcoin-core-23077
[cjdns.md]: https://github.com/jonatack/bitcoin/blob/f44efc3e2c5664825d7bd071f9dc38b5b9111ae1/doc/cjdns.md
