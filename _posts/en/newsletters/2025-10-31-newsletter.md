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

{% include snippets/recap-ad.md when="2025-11-04 16:30" %}
{% include references.md %}
[poinsot disc]: https://groups.google.com/g/bitcoindev/c/sBpCgS_yGws
[disc pol]: https://bitcoincore.org/en/security-advisories/
[news306 disclosures]: /en/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[CVE-2025-54604]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54604/
[CVE-2025-54605]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54605/
[CVE-2025-46597]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46597/
[CVE-2025-46598]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46598/
