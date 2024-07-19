---
title: 'Bitcoin Optech Newsletter #306'
permalink: /en/newsletters/2024/06/07/
name: 2024-06-07-newsletter
slug: 2024-06-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces an upcoming disclosure of
vulnerabilities affecting older versions of Bitcoin Core, describes a
draft BIP for a new version of testnet, summarizes a proposal for
covenants based on functional encryption, examines an update to the
proposal for performing 64-bit arithmetic in Bitcoin Script, links to a
script for validating proof-of-work on signet with the `OP_CAT` opcode, and
looks at a proposed update to the BIP21 specification of `bitcoin:`
URIs.  Also included are our regular sections announcing new releases
and release candidates, plus summaries of notable changes to popular
Bitcoin infrastructure software.

## News

- **Upcoming disclosure of vulnerabilities affecting old versions of Bitcoin Core:**
  several members of the Bitcoin Core project [discussed][irc disclose]
  on IRC a [proposed policy][disclosure policy] for disclosing
  vulnerabilities that affected older versions of Bitcoin Core.  For
  low-severity vulnerabilities, the details will be disclosed about two
  weeks after the first release of a version of Bitcoin Core that
  eliminates (or satisfactorily mitigates) the vulnerability.  For most
  other vulnerabilities, the details will be disclosed after the last
  version of Bitcoin Core affected by the vulnerability reaches
  end-of-life (which is about a year and a half after it was released).
  For rare critical vulnerabilities, members of the Bitcoin Core
  security team will privately discuss the most appropriate disclosure
  timeline to use.

  After this policy has a chance to be further discussed, it is the
  intention of the project to begin disclosing vulnerabilities affecting
  Bitcoin Core 24.x and below.  It is **strongly recommended** that all
  users and administrators upgrade to Bitcoin Core 25.0 or above within
  the next two weeks.  It is always ideal to use the latest version when
  possible, either the absolute latest version (27.0 as of writing) or
  the latest version in a particular release series (e.g. 25.2 for the
  25.x release series or 26.1 for the 26.x release series).

  As has always been our policy, Optech will provide summaries of all
  significant security disclosures affecting any of the infrastructure
  projects we monitor (which includes Bitcoin Core). {% assign timestamp="1:02" %}

- **BIP and experimental implementation of testnet4:** Fabian Jahr
  [posted][jahr testnet4] to the Bitcoin-Dev mailing list to announce a
  [draft BIP][bips #1601] for testnet4, a new version of [testnet][topic
  testnet] designed to eliminate some problems with the existing
  testnet3 (see [Newsletter #297][news297 testnet]).  Jahr also links to
  a Bitcoin Core [pull request][bitcoin Core #29775] with a proposed
  implementation.  Testnet4 has two notable differences from testnet3:

  - *Fewer reversions to difficulty-1:* it was easy (accidentally or
    deliberately) to reduce an entire period of 2,016 blocks to the
    minimum difficulty (difficulty-1) by mining the ultimate block in a
    period with a timestamp more than 20 minutes after the penultimate
    block.  Now period difficulty can only adjust downward in the normal
    way used on mainnet---although it is still possible to mine all
    individual blocks, except the first block in a new period, at
    difficulty-1 if they have a timestamp more than 20 minutes after the
    previous block.[^testnet-fixup]

  - *Time warp fixed:* it was possible on testnet3 (and also mainnet) to
    produce blocks significantly faster than once every 10 minutes
    without raising difficulty by exploiting the [time warp
    attack][topic time warp].  Testnet4 now implements the solution for
    time warp that was proposed as part of the [consensus cleanup][topic
    consensus cleanup] soft fork for mainnet.

  The draft BIP also mentions some additional and alternative ideas for
  testnet4 that were discussed but not used. {% assign timestamp="10:17" %}

- **Functional encryption covenants:** Jeremy Rubin [posted][rubin
  fe post] to Delving Bitcoin his [paper][rubin fe paper]
  about theoretically using [functional encryption][] to add a full range
  of [covenant][topic covenants] behavior to Bitcoin with no required
  consensus changes.  Fundamentally, this would require users of the
  covenants to trust a third party, although that trust could be
  distributed across multiple parties where only one of them would need
  to have acted honestly at a particular time.

  In essence, functional encryption would allow the creation of a public
  key that would correspond to a particular program.  A party who could
  satisfy the program would be able to create a signature that
  corresponded to the public key (without ever learning a corresponding
  private key).

  Rubin notes that this has an advantage over existing covenant
  proposals in that all operations (except verifying the resultant
  signature) occurs offchain and no data (except the public key and
  signature) needs to be published onchain.  This is always more private
  and will often save space.  Multiple covenant programs can be used in
  the same script by performing multiple signature checks.

  Besides the need for trusted setup, Rubin describes the other major
  downside of functional encryption as "under-developed cryptography that makes it
  impractical to use presently". {% assign timestamp="24:58" %}

- **Updates to proposed soft fork for 64-bit arithmetic:** Chris
  Stewart [posted][stewart 64bit] to Delving Bitcoin to announce an
  update to his earlier proposal to add the ability to work with 64-bit
  numbers in Bitcoin Script (see Newsletters [#285][news285 64bit] and
  [#290][news290 64bit]).  The main changes are:

  - *Updating existing opcodes:* instead of adding new opcodes such as
    `OP_ADD64`, the existing opcodes (e.g. `OP_ADD`) are updated to
    operate on 64-bit numbers.  Because the encoding for large numbers
    is different than currently used for small numbers, script
    fragments that are upgraded to use large numbers may need to be
    revised; Stewart gives the example of `OP_CHECKLOCKTIMEVERIFY` now
    needing to take an 8-byte parameter rather than a 5-byte parameter.

  - *Result includes a bool:* a successful operation not only places the
    result on the stack but also places a bool on the stack that
    indicates that the operation was successful.  One common reason an
    operation might fail is because the result is larger than 64 bits,
    overflowing the field size.  Code can use `OP_VERIFY` to ensure the
    operation completed successfully.

  Anthony Towns [replied][towns 64bit] arguing for an alternative
  approach where the default opcodes fail if an overflow occurs,
  rather than requiring scripts additionally verify that operations were successful.
  For cases where it could be useful to test whether an operation would
  result in an overflow, new opcodes such as `ADD_OF` would be made
  available. {% assign timestamp="31:27" %}

- **`OP_CAT` script to validate proof of work:** Anthony Towns
  [posted][towns powcat] to Delving Bitcoin about a script for
  [signet][topic signet] that uses [OP_CAT][topic op_cat] to allow
  anyone to spend coins sent to the script using proof of work (PoW).
  This can be used as a decentralized signet-bitcoin faucet: when a
  miner or a user obtains excess signet bitcoins, they send them to the
  script.  When a user wants more signet bitcoins, they search the UTXO
  set for payments to the script, generate PoW, and create a transaction
  that uses their PoW to claim the coins.

  Towns's post describes the script and the motivation for several
  design choices. {% assign timestamp="33:32" %}

- **Proposed update to BIP21:** Matt Corallo [posted][corallo bip21] to
  the Bitcoin-Dev mailing list about updating the [BIP21][]
  specification for the `bitcoin:` URI.  As previously discussed (see
  [Newsletter #292][news292 bip21]), almost all Bitcoin wallets are
  using the URI scheme differently than specified, and additional
  changes to invoice protocols will likely lead to additional changes in
  the use of BIP21.  The major changes in the [proposal][bips #1555]
  include:

  - *More than base58check:* BIP21 expects every Bitcoin address to use
    base58check encoding, but that is only used for legacy addresses for
    P2PKH and P2SH outputs.  Modern outputs use [bech32][topic bech32]
    and bech32m.  Future payments will be received to [silent
    payment][topic silent payments] addresses and the LN [offers][topic
    offers] protocol, which will almost certainly be used as BIP21
    payloads.

  - *Empty body:* BIP21 currently requires a Bitcoin address to be provided in
    the body part of the payload, with query parameters providing
    additional information (such as an amount to pay).  Previous new
    payment protocols, such as the [BIP70 payment protocol][topic bip70
    payment protocol], specified new query parameters to use (see
    [BIP72][]), but clients that didn't understand the parameter would
    fall back to using the address in the body.  In some cases,
    receivers may not want to fall back to one of the base address types
    (base58check, bech32, or bech32m), such as privacy-minded users of
    silent payments.  The proposed update allows the body field to be
    empty.

  - *New query parameters:* the update describes three new keys:
    `lightning` for [BOLT11][] invoices (currently in use), `lno` for LN
    offers (proposed), and `sp` for silent payments (proposed).  It also
    describes how the keys for future parameters should be named.

  Corallo notes in his post that the changes are safe for all known
  deployed software as wallets will ignore or reject any `bitcoin:` URIs
  that they cannot successfully parse. {% assign timestamp="42:12" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.05rc2][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="54:53" %}

- [Bitcoin Core 27.1rc1][] is a release candidate for a maintenance
  version of the predominant full node implementation. {% assign timestamp="55:51" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #7252][] changes the behavior of `lightningd` to ignore the
  `ignore_fee_limits` setting during a cooperative channel closure. This fixes
  an issue where a Core Lightning (CLN) channel opener node overpays fees when
  the counterparty is an LDK node. In this scenario, when the LDK non-opener node
  (Alice) initiates a cooperative channel closure and begins fee negotiation,
  the CLN opener node (Bob) responds that the fee can be anything between
  `min_sats` and `max_channel_size` due to the `ignore_fee_limits`
  setting. LDK [will][ldk #1101] "always select the highest
  allowed amount" (contrary to the BOLTs specification), so Bob picks
  the upper bound, and Alice
  accepts, resulting in Alice broadcasting a transaction with considerably
  overpaid fees. {% assign timestamp="56:50" %}

- [LDK #2931][] enhances the logging during pathfinding to include additional
  data about direct channels such as whether they’re missing, their minimum
  [HTLC][topic htlc] amount, and their maximum HTLC amount. The added logging
  aims to better troubleshoot routing issues by providing visibility into the
  available liquidity and limitations on each channel. {% assign timestamp="1:02:19" %}

- [Rust Bitcoin #2644][] adds HKDF (HMAC (Hash-based Message Authentication
  Code) Extract-and-Expand Key Derivation Function) to the `bitcoin_hashes`
  component to implement [BIP324][] in Rust Bitcoin. HKDF is used to derive
  cryptographic keys from a source of keying material in a secure and
  standardized way. BIP324 (also known as [v2 P2P transport][topic v2
  p2p transport]) is a method for allowing Bitcoin nodes to communicate
  with each other
  over encrypted connections (enabled by default in Bitcoin Core). {% assign timestamp="1:04:11" %}

- [BIPs #1541][] adds [BIP431][] with a specification of Topologically Restricted Until
  Confirmation ([TRUC][topic v3 transaction relay]) transactions (v3 transactions) which are a
  subset of standard transactions with additional rules designed to allow
  [transaction replacement][topic rbf] while minimizing the cost of overcoming
  [transaction-pinning][topic transaction pinning] attacks. {% assign timestamp="1:05:19" %}

- [BIPs #1556][] adds [BIP337][] with a specification of _compressed transactions_, a
  serialization protocol to compress bitcoin transactions to reduce their size
  by up to 50%. They are practical for low-bandwidth transmission such as by
  satellite, HAM radio, or through steganography. Two RPC commands are proposed:
  `compressrawtransaction` and `decompressrawtransaction`. See Newsletter
  [#267][news267 bip337] for a more detailed explanation of BIP337. {% assign timestamp="1:07:34" %}

- [BLIPs #32][] adds [BLIP32][] describing how proposed DNS-based
  human-readable Bitcoin payment instructions (see [Newsletter
  #290][news290 omdns]) can be used with [onion messages][topic onion
  messages] to allow payments to be sent to an address like
  `bob@example.com`.  For example, Alice instructs her LN client to pay
  Bob.  Her client may not be able to securely resolve DNS addresses
  directly, but it can use an onion message to contact one of its peers
  that advertises a DNS resolution service.  The peer retrieves the DNS TXT
  record for the `bob` entry at `example.com` and places the results
  along with a [DNSSEC][] signature into an onion message reply to
  Alice.  Alice verifies the information and uses it to request an
  invoice from Bob using the [offers][topic offers] protocol. {% assign timestamp="1:09:28" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}

## Footnotes

[^testnet-fixup]:
    This paragraph was edited after publication.  We thank Mark "Murch"
    Erhardt for the [correction][murch correction].

{% include references.md %}
{% include linkers/issues.md v=2 issues="7252,2931,2644,1541,1556,32,1601,29775,1555,1101" %}
[rubin fe paper]: https://rubin.io/public/pdfs/fedcov.pdf
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news290 omdns]: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions
[dnssec]: https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[jahr testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a6e3VPsXJf9p3gt_FmNF_Up-wrFuNMKTN30-xCSDHBKXzXnSpVflIZIj2NQ8Wos4PhQCzI2mWEMvIms_FAEs7rQdL15MpC_Phmu_fnR9iTg=@protonmail.com/
[news297 testnet]: /en/newsletters/2024/04/10/#discussion-about-resetting-and-modifying-testnet
[rubin fe post]: https://delvingbitcoin.org/t/fed-up-covenants/929
[functional encryption]: https://en.wikipedia.org/wiki/Functional_encryption
[stewart 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/49
[towns 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/50
[news285 64bit]: /en/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork
[news290 64bit]: /en/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode
[towns powcat]: https://delvingbitcoin.org/t/proof-of-work-based-signet-faucet/937
[corallo bip21]: https://mailing-list.bitcoindevs.xyz/bitcoindev/93c14d4f-10f3-48af-9756-7e39d61ba3d4@mattcorallo.com/
[news292 bip21]: /en/newsletters/2024/03/06/#updating-bip21-bitcoin-uris
[irc disclose]: https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2024-06-06#1031717;
[disclosure policy]: https://gist.github.com/darosior/eb71638f20968f0dc896c4261a127be6
[Bitcoin Core 27.1rc1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news289 v3]: /en/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /en/newsletters/2024/04/03/#bitcoin-core-29242
[news305 v3]: /en/newsletters/2024/05/31/#bitcoin-core-29873
[news267 bip337]: /en/newsletters/2023/09/06/#bitcoin-transaction-compression
[murch correction]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1714#discussion_r1630230324
