---
title: 'Bitcoin Optech Newsletter #378'
permalink: /en/newsletters/2025/10/31/
name: 2025-10-31-newsletter
slug: 2025-10-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Disclosure of four low-severity vulnerabilities in Bitcoin Core:**
  Antoine Poinsot recently [posted][poinsot disc] to the Bitcoin-Dev mailing
  list four Bitcoin Core security advisories for low-severity vulnerabilities
  that were fixed in Bitcoin Core 30.0. According to the [disclosure
  policy][disc pol] (see [Newsletter #306][news306 disclosures]), a
  low-severity vulnerability is disclosed two weeks after the release of a major
  version containing the fix. The four disclosed vulnerabilities are the
  following:

  - [Disk filling from spoofed self connections][CVE-2025-54604]: This bug would
    allow an attacker to fill up the disk space of a victim node by faking
    self-connections. The vulnerability was [disclosed responsibly][topic
    responsible disclosures] by Niklas Gögge in March 2022. Eugene Siegel and
    Niklas Gögge merged a mitigation in July 2025.

  - [Disk filling from invalid blocks][CVE-2025-54605]: This bug would allow an
    attacker to fill up the disk space of a victim node by repeatedly sending
    invalid blocks. This bug was disclosed responsibly by Niklas Gögge in May
    2022 and also independently by Eugene Siegel in March 2025. Eugene Siegel
    and Niklas Gögge merged the mitigation in July 2025.

  - [Highly unlikely remote crash on 32-bit systems][CVE-2025-46597]: This bug may cause a
    node to crash when receiving a pathological block in a rare edge case. This
    bug was disclosed responsibly by Pieter Wuille in April 2025. Antoine
    Poinsot implemented and merged the mitigation in June 2025.

  - [CPU DoS from unconfirmed transaction processing][CVE-2025-46598]: This
    bug would cause resource exhaustion when processing an unconfirmed
    transaction. This bug was
    reported to the mailing list by Antoine Poinsot in April 2025. Pieter
    Wuille, Anthony Towns, and Antoine Poinsot implemented and merged the
    mitigation in August 2025.

  Patches for the first three vulnerabilities have also been
  included in Bitcoin Core 29.1 and later minor releases.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.20.0-beta.rc1][] is a release candidate for this popular LN node.  One
  improvement that would benefit from testing is the fix for premature wallet
  rescanning, described in the notable code changes section below. See the
  [release notes][LND notes] for more details.

- [Eclair 0.13.1][] is a minor release of this LN node implementation.  This
  release contains database changes to prepare for the removal of pre-[anchor
  output][topic anchor outputs] channels. You will need to run the v0.13.0
  release first to migrate your channel data to the latest internal encoding.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29640][] reinitializes `nSequenceId` values at startup for
  blocks on competing chains with the same amount of work: 0 for blocks
  belonging to the previously known best chain, and 1 for all other loaded
  blocks. This resolves an issue where Bitcoin Core couldn’t perform a tiebreak
  between two competing chains because the `nSequenceId` value didn't persist
  across restarts.

- [Core Lightning #8400][] introduces a new [BIP39][] mnemonic backup format for
  the `hsm_secret` with optional passphrase for all new nodes by default, while
  keeping support for legacy 32-byte `hsm_secrets` on existing nodes. `Hsmtool`
  is also updated to support both mnemonic-based and legacy secrets. A new
  standard [taproot][topic taproot] derivation format is introduced for wallets.

- [Eclair #3173][] removes support for legacy channels that don’t use [anchor
  outputs][topic anchor outputs] or [taproot][topic taproot], also known as
  `static_remotekey` or `default` channels. Users should close any remaining
  legacy channels before upgrading to version 0.13 or 0.13.1.

- [LND #10280][] now waits for the headers to sync before starting the chain
  notifier (see [Newsletter #31][news31 chain]) to rescan the chain for wallet
  transactions. This resolves an issue in which LND would trigger a premature
  rescan while the headers were still syncing when a new wallet was created.
  This primarily affected [Neutrino backends][topic compact block filters].

- [BIPs #2006][] updates [BIP3][]’s specification (see [Newsletter #344][news344
  bip3]) by adding guidance on originality and quality, particularly advising
  authors against generating content with AI/LLMs, and encouraging the proactive
  disclosure of AI/LLM usage.

- [BIPs #1975][] updates [BIP155][] which specifies [addr v2][topic addr v2], a
  new version of the `addr` message in the Bitcoin P2P network protocol, by
  adding a note that [Tor v2][topic anonymity networks] is no longer
  operational.

{% include snippets/recap-ad.md when="2025-11-04 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29640,8400,3173,10280,5516,2006,1975" %}

[poinsot disc]: https://groups.google.com/g/bitcoindev/c/sBpCgS_yGws
[disc pol]: https://bitcoincore.org/en/security-advisories/
[news306 disclosures]: /en/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[CVE-2025-54604]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54604/
[CVE-2025-54605]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54605/
[CVE-2025-46597]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46597/
[CVE-2025-46598]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46598/
[LND 0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc2
[LND notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Eclair 0.13.1]: https://github.com/ACINQ/eclair/releases/tag/v0.13.1
[news31 chain]: /en/newsletters/2019/01/29/#lnd-2314
[news344 bip3]: /en/newsletters/2025/03/07/#bips-1712
