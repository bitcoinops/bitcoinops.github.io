---
title: 'Bitcoin Optech Newsletter #324'
permalink: /en/newsletters/2024/10/11/
name: 2024-10-11-newsletter
slug: 2024-10-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

## News

- FIXME:harding btcd disclosure details set to be announced Thursday

## FIXME instagibbs article

FIXME:harding, see PR 1937

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[add getorphantxs][review club 30793] is a PR by [tdb3][gh tdb3] that
adds a new experimental RPC method named `getorphantxs`. Since it is
intended primarily for developers, it is hidden. This new method
provides the caller with a list of all current orphan transactions,
which can be helpful when checking orphan behavior/scenarios (e.g. in
functional tests like `p2p_orphan_handling.py`) or for providing
additional data for statistics/visualization.

{% include functions/details-list.md
  q0="What is an orphan transaction? At what point do transactions enter
  the orphanage?"
  a0="An orphan transaction is one whose inputs refer to unknown or
  missing parent transactions. Transactions enter the orphanage when
  they are received from a peer but they fail validation with
  `TX_MISSING_INPUTS` in `ProcessMessage`."
  a0link="https://bitcoincore.reviews/30793#l-16"
  q1="What command can you run to get a list of available RPCs"
  a1="`bitcoin-cli help` provides a list of available RPCs. Note: since
  `getorphantxs` is [marked as hidden][gh getorphantxs hidden] as a
  developer-only RPC, it will not show up in this list."
  a1link="https://bitcoincore.reviews/30793#l-26"
  q2="If an RPC has a non-string argument, does anything special need to
  be done to handle it?"
  a2="Non-string RPC arguments must be added to the `vRPCConvertParams`
  list in `src/rpc/client.cpp` to ensure proper type conversion."
  a2link="https://bitcoincore.reviews/30793#l-72"
  q3="What is the maximum size of the result from this RPC? Is there a
  limit to how many orphans are retained? Is there a limit to how much
  time orphans can stay in the orphanage?"
  a3="The maximum number of orphans is 100
  (`DEFAULT_MAX_ORPHAN_TRANSACTIONS`). At `verbosity=0`, each txid is a
  32-byte binary value, but when hex-encoded for the JSON-RPC result, it
  becomes a 64-character string (since each byte is represented by two
  hex characters). This means the maximum result size is approximately
  6.4 kB (100 txids * 64 bytes).

  At `verbosity=2`, the hex-encoded transaction is by far the largest
  field in the result, so for simplicity we'll ignore the other fields
  in this calculation. The maximum serialized size of a transaction can
  be up to 400 kB (in the extreme, impossible case that it consists only
  of witness data), or 800 kB when hex-encoded. Therefore, the maximum
  result size is roughly 80 MB (100 transactions * 800 kB).

  Orphans are time-limited and are removed after 20 minutes, as defined
  by `ORPHAN_TX_EXPIRE_TIME`."
  a3link="https://bitcoincore.reviews/30793#l-94"
  q4="Since when has there been a maximum orphanage size"
  a4="The `MAX_ORPHAN_TRANSACTIONS` variable was introduced back in 2012
  already, in commit [142e604][gh commit 142e604]."
  a4link="https://bitcoincore.reviews/30793#l-105"
  q5="Using the `getorphantxs` RPC, would we be able to tell how long a
  transaction has been in the orphanage? If yes, how would you do it?"
  a5="Yes, by using `verbosity=1`, you can get the expiration timestamp
  of each orphan transaction. Subtracting the `ORPHAN_TX_EXPIRE_TIME`
  (i.e. 20 minutes) gives the insertion time."
  a5link="https://bitcoincore.reviews/30793#l-128"
  q6="Using the `getorphantxs` RPC, would we be able to tell what the
  inputs of an orphan transaction are? If yes, how would you do it?"
  a6="Yes, with `verbosity=2`, the RPC returns the raw transaction hex,
  which can be decoded using `decoderawtransaction` to reveal its
  inputs."
  a6link="https://bitcoincore.reviews/30793#l-140"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default, updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

<!-- FIXME:harding to update Thursday -->

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #7494][] pay: Remember and update channel_hints across payments #7494

- [Core Lightning #7539][] Add getemergencyrecoverdata RPC Command to Fetch Data from emergency.recover File

- [LDK #3179][] Add the core functionality required to resolve Human Readable Names

- [LND #8960][] merge custom channel staging branch into master

- [Libsecp256k1 #1479][] Add module "musig" that implements MuSig2 multi-signatures (BIP 327)

- [Rust Bitcoin #2945][] Support Testnet4 Network

- [BIPs #1674][] reverts the changes to the [BIP85][] specification
  described in [Newsletter #323][news323 bip85].  The changes broke
  compatibility with deployed versions of the protocol.  Discussion on
  the PR supported creating a new BIP for the major changes.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7494,7539,3179,8960,1479,2945,1674" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[news323 bip85]: /en/newsletters/2024/10/04/#bips-1600
[review club 30793]: https://bitcoincore.reviews/30793
[gh tdb3]: https://github.com/tdb3
[gh getorphantxs hidden]: https://github.com/bitcoin/bitcoin/blob/a9f6a57b6918b2f92c7d6662e8f5892bf57cc127/src/rpc/mempool.cpp#L1131
[gh commit 142e604]: https://github.com/bitcoin/bitcoin/commit/142e604184e3ab6dcbe02cebcbe08e5623182b81
