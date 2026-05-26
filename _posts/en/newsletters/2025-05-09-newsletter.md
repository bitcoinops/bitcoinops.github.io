---
title: 'Bitcoin Optech Newsletter #353'
permalink: /en/newsletters/2025/05/09/
name: 2025-05-09-newsletter
slug: 2025-05-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a recently discovered theoretical
consensus failure vulnerability and links to a proposal to avoid reuse
of BIP32 wallet paths.  Also included are our regular sections summarizing
a Bitcoin Core PR Review Club meeting, announcing new releases and
release candidates, and describing notable code changes to popular
Bitcoin infrastructure software.

## News

- **BIP30 consensus failure vulnerability:** Ruben Somsen [posted][somsen
  bip30] to the Bitcoin-Dev mailing list about a theoretical consensus
  failure that could occur now that checkpoints have been removed from
  Bitcoin Core (see [Newsletter #346][news346 checkpoints]).  In short,
  the coinbase transactions of blocks 91722 and 91812 are [duplicated][topic duplicate transactions] in
  blocks 91880 and 91842.  [BIP30][] specifies that those second two
  blocks should be handled the way the historic version of Bitcoin Core
  handled them in 2010, which is by overwriting the earlier coinbase
  entries in the UTXO set with the later duplicates.  However, Somsen
  notes that a reorg of either or both later blocks would result in the
  duplicate entry (or entries) being removed from the UTXO set, leaving
  it devoid also of the earlier entries due to the overwriting.
  But, a newly started node that never saw the duplicate
  transactions would still have the earlier transactions, giving it a
  different UTXO set that could result in a consensus failure if either
  transaction is ever spent.

  This wasn't an issue when Bitcoin Core had checkpoints as they
  required all four blocks mentioned above to be part of the best
  blockchain.  It's not really an issue now, except in a theoretical
  case where Bitcoin's proof-of-work security mechanism breaks.  Several
  possible solutions were discussed, such as hardcoding additional
  special case logic for these two exceptions. {% assign timestamp="0:52" %}

- **Avoiding BIP32 path reuse:** Kevin Loaec [posted][loaec bip32reuse]
  to Delving Bitcoin to discuss options for preventing the same
  [BIP32][topic bip32] wallet path from being used with different
  wallets, which could lead to a loss of privacy due to [output
  linking][topic output linking] and a theoretical loss of security
  (e.g., due to [quantum computing][topic quantum resistance]).  He
  suggested three possible approaches: use a randomized path, use a path
  based on the wallet birthday, and use a path based on an incrementing
  counter.  He recommended the birthday-based approach.

  He also recommended dropping most of the [BIP48][] path elements as
  unnecessary due to the increasingly widespread use of [descriptor][topic descriptors]
  wallets, especially for multisig and complex script wallets.  However,
  Salvatore Ingala [replied][ingala bip48] to suggest keeping the _coin
  type_ part of the BIP48 path as it helps ensure keys for use with
  different cryptocurrencies are kept segregated, which is enforced by
  some hardware signing devices. {% assign timestamp="28:33" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Add bitcoin wrapper executable][review club 31375] is a PR by
[ryanofsky][gh ryanofsky] that introduces a new `bitcoin` binary which
can be used to discover and launch the various Bitcoin Core binaries.

Bitcoin Core v29 shipped with 7 binaries (e.g. `bitcoind`, `bitcoin-qt`
and `bitcoin-cli`), but that number is set to [increase][Bitcoin Core
#30983] in the future when [multiprocess][multiprocess design] binaries
are shipped as well. The new `bitcoin` wrapper maps commands (e.g.
`gui`) to the correct monolithic (`bitcoin-qt`) or multiprocess
(`bitcoin-gui`) binary. In addition to discoverability, the wrapper also
provides forward compatibility so binaries can be reorganized without
the user interface changing.

With this PR, a user can launch Bitcoin Core with `bitcoin daemon` or
`bitcoin gui`. Directly launching the `bitcoind` or `bitcoin-qt`
binaries is still possible and not affected by this PR.

{% include functions/details-list.md
  q0="From issue #30983, four packaging strategies were listed. Which
  specific drawbacks of the “side‑binaries” approach does this PR
  address?"
  a0="The side-binaries approach assumed by this PR involves releasing
  the new multiprocess binaries alongside the existing monolithic
  binaries. With this many binaries, it can be confusing for users to
  find and figure out the binary they need for their purpose. This PR
  takes a lot of the confusion away by providing a single entry point,
  with an overview of options and a help string. One reviewer suggested
  the addition of fuzzy search to facilitate this even further."
  a0link="https://bitcoincore.reviews/31375#l-40"
  q1="`GetExePath()` does not use `readlink(\"/proc/self/exe\")` on
  Linux even though it would be more direct. What advantages does the
  current implementation have? What corner cases might it miss?"
  a1="There may be other non-Windows platforms that do not have the proc
  filesystem. Other than that, neither the author nor guests could
  identify any drawbacks of using procfs."
  a1link="https://bitcoincore.reviews/31375#l-71"
  q2="In `ExecCommand`, explain the purpose of the `fallback_os_search`
  Boolean. Under what circumstances is it better to avoid letting the OS
  search for the binary on the `PATH`?"
  a2="If it looks like the wrapper executable was invoked by path (e.g.
  \"/build/bin/bitcoin\") rather than by search (e.g. \"bitcoin\"), it
  is assumed the user is using a local build and `fallback_os_search` is
  set to `false`. This boolean is introduced to unintentionally mix
  binaries from different sources. For example, if the user didn't
  locally build `gui`, then `/build/bin/bitcoin gui` should not fall
  back to the system installed `bitcoin-gui`. The author is considering
  removing the `PATH` search entirely, and user feedback would be
  helpful."
  a2link="https://bitcoincore.reviews/31375#l-75"
  q3="The wrapper searches `${prefix}/libexec` only when it detects that
  it is running from an installed `bin/` directory. Why not always
  search `libexec`?"
  a3="The wrapper should be conservative about what paths it tries to
  execute, and encourage standard `PREFIX/{bin,libexec}` layouts, not
  encourage packagers to create nonstandard layouts or work when
  binaries are arranged in unexpected ways."
  a3link="https://bitcoincore.reviews/31375#l-75"
  q4="The PR adds an exemption in `security-check.py` because the
  wrapper contains no fortified `glibc` calls. Why does it not contain
  them, and would adding a trivial `printf` to `bitcoin.cpp` break
  reproducible builds under the current rules?"
  a4="The wrapper binary is so simple it does not contain any calls that
  can be fortified. If it does in the future, the exemption in
  security-check.py can be removed."
  a4link="https://bitcoincore.reviews/31375#l-117"
%}

{% assign timestamp="16:38" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta.rc4][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes. {% assign timestamp="45:01" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #8227][] adds Rust-based `lsps-client` and `lsps-service`
  plugins that implement a communication protocol between LSP nodes and their
  clients, using a JSON-RPC format over [BOLT8][] peer-to-peer messages, as
  specified in [BLIP50][] (see Newsletter [#335][news335 blip50]). This lays
  the foundation for implementing incoming liquidity requests as specified in
  [BLIP51][], and [JIT channels][topic jit channels] as specified in [BLIP52][]. {% assign timestamp="45:18" %}

- [Core Lightning #8162][] updates the handling of peer-initiated pending
  channel opens by retaining them indefinitely, up to a limit of the 100 most
  recent. Previously, unconfirmed channel opens were forgotten after 2016
  blocks. In addition, closed channels are now held in memory to allow a node to
  respond to a peer’s `channel_reestablish` message. {% assign timestamp="46:43" %}

- [Core Lightning #8166][] enhances the `wait` RPC command by replacing its
  single `details` object with subsystem-specific objects: `invoices`,
  `forwards`,`sendpays`, and [`htlcs`][topic htlc]. In addition, the `listhtlcs`
  RPC now supports pagination via new `created_index` and `updated_index` fields
  and the `index`, `start`, and `end` parameters. {% assign timestamp="47:44" %}

- [Core Lightning #8237][] adds a `short_channel_id` parameter to the
  `listpeerchannels` RPC command to return only a specific channel, if provided. {% assign timestamp="48:49" %}

- [LDK #3700][] adds a new `failure_reason` field to the `HTLCHandlingFailed`
  event to provide additional information about why the [HTLC][topic htlc]
  failed, and whether the cause was local or downstream. The
  `failed_next_destination` field is renamed to `failure_type` and the
  `UnknownNextHop` variant is deprecated, and replaced by the more general
  `InvalidForward`. {% assign timestamp="49:28" %}

- [Rust Bitcoin #4387][] refactors [BIP32][topic bip32] error handling by
  replacing the single `bip32::Error` with separate enums for derivation, child
  number/path parsing, and extended key parsing. This PR also introduces a new
  `DerivationError::MaximumDepthExceeded` variant for paths exceeding 256
  levels. These API changes break the backwards compatibility. {% assign timestamp="49:55" %}

- [BIPs #1835][] updates [BIP48][] (see Newsletter [#135][news135 bip48]) to
  reserve the script type value 3 for [taproot][topic taproot] (P2TR)
  derivations in deterministic multisig wallets with the m/48' prefix, in
  addition to the existing P2SH-P2WSH (1′) and P2WSH (2′) script types. {% assign timestamp="50:15" %}

- [BIPs #1800][] merges [BIP54][], which specifies the [consensus cleanup soft
  fork][topic consensus cleanup] proposal to fix a number of long-standing
  vulnerabilities in the Bitcoin protocol. See Newsletter [#348][news348
  cleanup] for a detailed description of this BIP. {% assign timestamp="55:03" %}

- [BOLTs #1245][] tightens [BOLT11][] by disallowing non-minimal length
  encodings in invoices: the expiry (x), the [CLTV expiry delta][topic cltv
  expiry delta] for the last hop (c), and feature bits (9) fields must be
  serialized in minimal length without leading zeros, and readers should reject
  any invoice that contains leading zeros. This change was motivated by fuzz
  testing that detected that when LDK reserialize non-minimal invoices to
  minimal (stripping out the extra zeros), it causes the invoice’s ECDSA
  signature to fail validation. {% assign timestamp="56:37" %}

{% include snippets/recap-ad.md when="2025-05-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8227,8162,8166,8237,3700,4387,1835,1800,1245,50,51,52,30983" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[somsen bip30]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjZTWhgzzdps3vb0YoU3EYJwThDFhNLkf4XmmdfhbORTaw@mail.gmail.com/
[loaec bip32reuse]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644
[ingala bip48]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644/3
[news346 checkpoints]: /en/newsletters/2025/03/21/#bitcoin-core-31649
[news335 blip50]: /en/newsletters/2025/01/03/#blips-52
[news135 bip48]: /en/newsletters/2021/07/28/#bips-1072
[news348 cleanup]: /en/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[review club 31375]: https://bitcoincore.reviews/31375
[gh ryanofsky]: https://github.com/ryanofsky
[multiprocess design]: https://github.com/bitcoin/bitcoin/blob/master/doc/design/multiprocess.md
