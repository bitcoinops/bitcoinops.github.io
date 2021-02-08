---
title: 'Bitcoin Optech Newsletter #135'
permalink: /en/newsletters/2021/02/10/
name: 2021-02-10-newsletter
slug: 2021-02-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to the summary of last week's taproot
activation meeting and announces another scheduled meeting for next
week, plus it describes recent progress in discreet log contracts and a new
mailing list for discussing them.  Also included are our regular
sections with the summary of a Bitcoin Core PR Review Club meeting,
descriptions of releases and release candidates, and a list of notable
changes to popular Bitcoin infrastructure projects.

## News

- **Taproot activation meeting summary and follow-up:** Michael Folkson
  posted a [summary][folkson1] of the scheduled meeting to discuss taproot
  activation methods (see [Newsletter #133][news133 taproot meeting]).
  There appeared to be support among participants for using the [BIP8][]
  activation mechanism with the earliest allowed activation time about
  two months after the first release of Bitcoin Core containing the
  activation code and the latest allowed activation of that initial
  deployment about one year subsequently.

    More controversial was whether the `LockinOnTimeout` (LOT) parameter
    should default to *true* (requiring miners to either eventually signal
    in favor of the new rules or risk a chainsplit) or *false* (allowing
    miners to signal however they'd like without immediate consequences,
    though some users could choose to enable `LOT=true` later).  Folkson
    wrote a [second post][folkson2] to the mailing list summarizing the
    arguments he's seen for the two different options and announcing a
    follow-up meeting to discuss them (and some less controversial
    issues) in the Freenode ##taproot-activation channel on February
    16th at 19:00 UTC.

- **New mailing list for Discreet Log Contracts:** Nadav Kohen
  [announced][kohen post] the creation of a [new mailing list][dlc list]
  for discussion of topics related to Discreet Log Contracts (DLCs).
  He also summarized the current state of development on DLCs, including
  multiple compatible implementations, the use of ECDSA [signature
  adaptors][topic adaptor signatures], effective compression algorithms
  for DLCs contingent on numeric outcomes, and support for k-of-n
  threshold signing from oracles "even supporting numeric cases where
  some bounded difference is permitted between oracles".

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:jo(h)n

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/12345#l-77"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.12.1-beta.rc1][] is a release candidate for a maintenance
  release of LND.  It fixes an edge case that could lead to accidental
  channel closure and a bug that could cause some payments to fail
  unnecessarily, plus some other minor improvements and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [HWI #433][] trezor: Enable processing of OP_RETURN outputs FIXME:Xekyo

- [Bitcoin Core #19509][] Per-Peer Message Capture FIXME:adamjonas

- [Bitcoin Core #20764][] adds additional information to the output
  produced using `bitcoin-cli -netinfo`.  New details include the type
  of peer (e.g. full relay or blocks-only), number
  of manually added peers, peers using [BIP152][] "high bandwidth"
  (faster) block relay mode, and any peers using the [I2P][] anonymity
  network (being worked on in a [separate PR][bitcoin core #20685]).
- [BIPs #1021][] updates the [BIP8][] soft fork activation mechanism,
  changing its behavior for nodes that choose to enforce the *lockin on
  timeout* feature.  Previously, those nodes would reject any block that
  didn't signal for activation during the mandatory activation period.
  After this change, the nodes will tolerate up to the maximum number of
  non-signaling blocks possible that still guarantee activation.  This
  reduces the number of blocks that may be needlessly rejected and
  reduces the potential for miscommunication between miners and node
  operators.

- [BIPs #1020][] updates BIP8 to no longer require signaling during the
  *locked in* period now that activation can be assured using required
  signaling in the [recently added][BIPs #950] *must signal* period.

- [BIPs #1048][] rewrites most of the [BIP322][] proposal for [generic
  message signing][topic generic signmessage] as proposed a few weeks
  ago on the mailing list (see [Newsletter #130][news130 bip322]).  The
  changes allow wallets that don’t implement a complete set of checks to
  return an “inconclusive” state for signatures that use scripts they
  don’t understand.  It also clarifies the implementation instructions
  and removes unnecessary data from the signature serialization.

- [BIPs #1056][] adds [BIP350][] with a specification of bech32 modified
  (bech32m) as previously discussed on the mailing list (see [Newsletter
  #131][news131 bech32m]).  This modified version of [bech32][topic bech32] addresses from [BIP173][] will
  apply to planned taproot addresses and later improvements using segwit
  witness scripts.

- [BIPs #988][] updates the [BIP174][] specification for [PSBTs][topic
  psbt] to require programs operating in the *creator* role to
  initialize empty output fields, similar to an existing requirement to
  initialize empty input fields.  Existing PSBT creators such as Bitcoin
  Core were already doing this.

- [BIPs #1055][] updates [BIP174][] to clarify the format for proprietary
  extensions, extends the table of fields with rows indicating how they
  apply to different versions of PSBTs, and marks the BIP as final with
  regard to the original version 0 of PSBTs.

- [BIPs #1040][] updates the [BIP85][] specification for creating
  keys and keychains from a super [BIP32][] keychain.  The updates
  describe how to use the super keychain to create keys for RSA-based
  PGP signatures that can be loaded on to GPG-compatible smartcards.

- [BIPs #1054][] updates the [BIP141][] specification of segwit's
  consensus changes to clarify how the number of signature operations
  (sigops) is counted when `OP_CHECKMULTISIG` and
  `OP_CHECKMULTISIGVERIFY` are used.  The text previously noted that
  they were counted the same as when P2SH was used but the update describes
  the unintuitive particulars: "For 1 to 16 total public keys
  CHECKMULTISIG is counted as 1 to 16 sigops respectively, and for 17 to
  20 total public keys it is counted as 20 sigops."

- [BIPs #1047][] updates the [BIP39][] specification for
  deterministically generating [BIP32][] seeds from a phrase, adding a
  warning that the use of non-English word lists is not widely supported
  and so is not recommended for implementation.

- [Rust-Lightning #744][] Add lightning-block-sync package and library FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="433,19509,1021,1020,20764,1048,1056,988,1040,1054,1047,744,950,20685,1055" %}
[LND 0.12.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta.rc1
[folkson1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018379.html
[folkson2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018380.html
[news133 taproot meeting]: /en/newsletters/2021/01/27/#scheduled-meeting-to-discuss-taproot-activation
[kohen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018372.html
[dlc list]: https://mailmanlists.org/mailman/listinfo/dlc-dev
[i2p]: https://en.wikipedia.org/wiki/I2P
[news131 bech32m]: /en/newsletters/2021/01/13/#bech32m
[news130 bip322]: /en/newsletters/2021/01/06/#proposed-updates-to-generic-signmessage
