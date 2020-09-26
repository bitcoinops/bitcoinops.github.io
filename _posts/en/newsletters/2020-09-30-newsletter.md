---
title: 'Bitcoin Optech Newsletter #117'
permalink: /en/newsletters/2020/09/30/
name: 2020-09-30-newsletter
slug: 2020-09-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a compiler bug that casts doubt on the
safety of secure systems and includes our regular sections with popular
questions and answers from the Bitcoin StackExchange, announcements of
releases and release candidates, and summaries of notable changes to
popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Discussion about compiler bugs:** a [test][oconnor test] written
  last week by Russell O'Connor for libsecp256k1 failed due to a
  [bug][gcc bug] in the GNU Compiler Collection's (GCC's) built-in version of the
  standard C library's `memcmp` (memory compare) function.  This function takes two
  regions of memory, interprets them as integer values, and returns
  whether the first region is less than, equal to, or greater than the
  second region.  This is a commonly used low-level function.
  Programs are almost never designed to verify such fundamental
  operations were performed correctly, so bugs of this type can easily
  result in a program producing incorrect results.  Those incorrect
  results are possible even if the program's code was well reviewed,
  strongly tested, formally verified, and otherwise built with the
  utmost care.  A single incorrect result in the execution of
  cryptographic or consensus code could result in serious consequences
  for the users of that code---or anyone who depends on remaining in
  consensus with users of that code.

    The potential issues affect not only software written in C and
    compiled with GCC, but any software or library that depends on
    software or libraries compiled with the affected versions of GCC.
    It also
    includes programs written in other languages whose compilers or
    interpreters were built using GCC. Although the full extent of
    the issue is still unknown, Russell O'Connor has run
    [an analysis][oconnor blog] of an entire Linux system and found only a
    handful of instances where this bug causes a miscompilation, suggesting
    that it's fairly rare for code to be miscompiled due to the bug.

    Issues were opened in both the [libsecp256k1][libsecp256k1 #823] and
    [Bitcoin Core][bitcoin core #20005] repositories to find and
    mitigate any effects of this bug.  The topic was also
    [discussed][irc memcmp] during the weekly Bitcoin Core Developers
    Meeting.

    As of this writing, developers have tested Bitcoin Core 0.20.1 and
    not found any direct problems.  If any noteworthy problems are found
    in other software, we'll provide an update in a future newsletter.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.11.1-beta.rc4][lnd 0.11.1-beta] is the release candidate for a
  minor version.  Its release notes summarize the changes as "a number
  of reliability improvements, some macaroon [authentication token]
  upgrades, and a change to make our version of [anchor commitments][topic
  anchor outputs] spec compliant."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18267][] and [#19993][Bitcoin Core #19993] add support
  for [signet][topic signet].  If Bitcoin Core is started with `-signet`
  (or `-chain=signet`), it'll connect to either the default signet or
  the signet defined by the `-signetchallenge` and `-signetseednode`
  parameters.

- [Bitcoin Core #19572][] ZMQ: Create "sequence" notifier, enabling client-side mempool tracking FIXME:dongcarl

- [C-Lightning #4068][] and [#4078][C-Lightning #4078] update
  C-Lightning's signet implementation to be compatible with the final
  parameters chosen in [BIP325][] and Bitcoin Core's default signet.

- [Eclair #1501][] adds support for unilateral closes of channels using
  [anchor outputs][topic anchor outputs], completing Eclair's basic
  implementation of this new LN protocol feature.  According to the PR,
  Eclair still needs to add the features necessary to fee bump
  commitment transactions and HTLCs, but this is coming next.

- [LND #4576][] is the first in a planned series of PRs adding support
  for anchor outputs to LND's [watchtower][topic watchtowers] implementation.  This PR, in
  particular, adds a flag indicating that anchor outputs were used in
  the channel being closed so that the watchtower can respond
  appropriately.  The PR notes, "[the] changes require no modification
  of the encrypted payload format.  The anchor payloads are equal size
  and contain exactly the same witness info as the legacy payloads, only
  requiring light modifications to the reconstruction logic."

- [BIPs #907][] updates the [BIP155][] specification of [version 2 `addr`
  messages][topic addr v2] to allow addresses up to 512 bytes and adds a new
  `sendaddrv2` message that nodes can use to signal that they want to
  receive `addrv2` messages.

{% include references.md %}
{% include linkers/issues.md issues="18267,19993,19572,4068,4078,1501,4576,907,823,20005" %}
[lnd 0.11.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.1-beta.rc4
[oconnor test]: https://github.com/bitcoin-core/secp256k1/pull/822#issuecomment-696790289
[gcc bug]: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=95189
[irc memcmp]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2020/bitcoin-core-dev.2020-09-24-19.02.log.html#l-18
[oconnor blog]: http://r6.ca/blog/20200929T023701Z.html
