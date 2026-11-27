---
title: 'Bitcoin Optech Newsletter #434'
permalink: /en/newsletters/2026/12/04/
name: 2026-12-04-newsletter
slug: 2026-12-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **STARK proof of the UTXO set at block 972,500:** l-henri [posted][lh stark]
  to Delving Bitcoin about a 1.6 MB STARK proof of the UTXO set after block
  972,500 that a browser verifies in about half a second. A STARK is a
  succinct proof that a computation was performed correctly. According to
  l-henri, this one shows that a header chain from the genesis block has the
  stated chainwork and follows Bitcoin Core's header rules, except the rule
  against timestamps too far in the future, and that replaying blocks 935,001
  through 972,500 on top of the [assumeUTXO][topic assumeutxo] snapshot whose
  hash Bitcoin Core hardcodes for height 935,000 yields a UTXO set whose
  `hash_serialized` matches the one Bitcoin Core computes. Because the replay
  starts from that snapshot, the result relies on the same trust as loading
  it and is not a proof from genesis. ZeroSync previously demonstrated a STARK
  proof of the header chain (see [Newsletter #269][news269 zerosync]).

  As with Bitcoin Core's `assumevalid` setting, the proof does not check
  scripts or signatures. l-henri later [added][lh stark fix] that, unlike
  `assumevalid`, it also does not enforce [BIP68][] relative timelocks or
  count P2SH and witness signature operations toward the block limit.
  Machine-checked Lean 4 proofs show that its constraints enforce a Lean
  specification of the rules, but that specification was differentially
  fuzzed against Bitcoin Core's code rather than proven equivalent to it. The
  proof also assumes the soundness of the underlying proof system, including
  when it is used recursively (see [Newsletter #425][news425 snark]), and the
  work has had no external review.

  l-henri plans to try a patch that lets Bitcoin Core load a snapshot attested
  by such a proof and skip background validation, but expects that to be
  controversial and asked for opinions first. Anthony Towns [argued][towns
  stark] that proofs of UTXO set updates would stay useful longer than proofs
  of full block validation, since soft forks generally change only the latter.
  Towns also [asked][towns stark hash] whether Bitcoin Core should output a
  merklized hash of the UTXO set, which l-henri [replied][lh stark hash] would
  allow per-coin inclusion and exclusion proofs and checking a snapshot in
  chunks.

FIXME:bitschmidty

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-12-08 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[lh stark]: https://delvingbitcoin.org/t/a-stark-proof-of-bitcoins-utxo-set-at-block-972-500-with-circuits-proven-in-lean/3070
[news269 zerosync]: /en/newsletters/2023/09/20/#stark-header-chain-verifier-demo
[lh stark fix]: https://delvingbitcoin.org/t/a-stark-proof-of-bitcoins-utxo-set-at-block-972-500-with-circuits-proven-in-lean/3070/4
[news425 snark]: /en/newsletters/2026/10/02/#block-wide-signature-aggregation-via-snarks
[towns stark]: https://delvingbitcoin.org/t/a-stark-proof-of-bitcoins-utxo-set-at-block-972-500-with-circuits-proven-in-lean/3070/3
[towns stark hash]: https://delvingbitcoin.org/t/a-stark-proof-of-bitcoins-utxo-set-at-block-972-500-with-circuits-proven-in-lean/3070/5
[lh stark hash]: https://delvingbitcoin.org/t/a-stark-proof-of-bitcoins-utxo-set-at-block-972-500-with-circuits-proven-in-lean/3070/6
