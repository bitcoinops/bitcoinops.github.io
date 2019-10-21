---
title: "Bitcoin Optech Newsletter #26"
permalink: /en/newsletters/2018/12/18/
name: 2018-12-18-newsletter
slug: 2018-12-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the new libminisketch library for
bandwidth efficient set reconciliation, links to an email about
Schnorr/Taproot plans, and mentions an upcoming LN protocol
specification meeting.  Also included are a list of notable code changes
in the past week from popular Bitcoin infrastructure projects.

## Action items

- **Help test Bitcoin Core 0.17.1RC1:** the first release candidate for
  this [maintenance release][] has been [uploaded][V0.17.1rc1].  Testing
  by businesses and individual users of both the daemon and the GUI is
  greatly appreciated and helps ensure the highest-quality release.

## News

- **Minisketch library released:** Bitcoin developers Pieter Wuille,
  Gregory Maxwell, and Gleb Naumenko have been researching [optimized
  transaction relay][] as described in the News section of [Newsletter
  #9][].  One result of that research is a new standalone library they've
  released, [libminisketch][], that allows transferring the
  differences between two sets of information in roughly the byte size
  of the expected differences themselves.  That may not sound
  exciting---the `rsync` tool has done that for over two decades---but
  libminisketch allows transferring the differences *without knowing what
  they are ahead of time.*

    For example, Alice has elements 1, 2, and 3.  Bob has elements 1 and 3.
    Despite neither knowing which elements the other has, Alice can send
    Bob a *sketch* the size of a single element that contains enough
    information for him reconstruct element 2.  If Bob instead has
    elements 1 and 2 (not 3), the exact same sketch allows him to
    reconstruct element 3.  Alternatively, if Bob sends Alice a sketch
    based on his two-element set while Alice has her three-element
    set, she can determine which element Bob is missing and send it
    to him directly.

    These sketches can provide a powerful new way to optimize relay of
    unconfirmed transactions for the Bitcoin P2P network.  The current
    gossip-based mechanism has each node receiving or sending 32-byte
    identifiers for each transaction for each of their peers.  For
    example, if you have 100 peers, you send or receive 3,200 bytes of
    announcements, plus overhead, for what is (on average) just a 400
    byte transaction.  An early estimate using a [simulator][naumenko
    relay simulator] indicates combining sketches with shortened
    transaction identifiers (for relay only) could reduce total
    transaction propagation bandwidth by a factor of 44x.  Sketches also
    have the potential to provide other desirable features---for
    example, LN protocol developer Rusty Russel started a [thread][ln
    minisketch] on the Lightning-Dev mailing list about using them for
    sending LN routing table updates.

- **Description about what might be included in a Schnorr/Taproot soft fork:**
  Bitcoin protocol developer Anthony Towns has [posted][towns
  schnorr taproot] a well-written email describing what he thinks
  ought to be included in a soft fork that adds the Schnorr signature
  scheme plus Taproot-style MAST to Bitcoin.  This is not a formal
  proposal, but it's similar to opinions we've heard from other
  developers and so should provide a good overview of current thinking.

- **LN protocol IRC meeting:** protocol developers for LN have agreed to
  try converting their periodic meeting for developing the LN
  specification from a Google Hangout to an IRC meeting after receiving
  requests from several developers.  The [next meeting][ln irc meeting]
  will be Tuesday, January 8th, at 19:00 (UTC).

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

- [Bitcoin Core #14573][] moves various miscellaneous options that
  opened separate dialogues in the Bitcoin-Qt GUI to a new top-level
  menu item labeled *Window*, hopefully making those options easier to
  find and use.

- [LND #1984][] adds a new `listunspent` RPC that lists each of the
  wallet's unspent outputs.  It can take two parameters: (1) the minimum
  number of confirmations the unspent output must have or (2) the maximum
  it can have.  The minimum can be set to `0` to print unconfirmed
  outputs.

- [LND #2039][] adds the ability to get the status of the autopilot
  functionality as well as allowing enabling or disabling it while the
  program is running.  Autopilot is the ability of the software to
  automatically suggest new channels to open when a user is first
  connecting to LN or wants additional spending capacity.

- [C-Lightning #2155][] disables by default the
  `option_data_loss_protect` feature described in the notable commits of
  [newsletter #10][].  The feature wasn't working reliably, so it will
  only be enabled for users that opt-in to experimental features.

- [C-Lightning #2154][] now allows plugins to send log notifications
  that will be written to the lightningd's log files.

- [C-Lightning #2161][] adds a small Python library and framework that
  can be used for writing plugins.  It provides [function decorators][]
  similar to those used by the popular [flask][] library that can be
  used to tag functions as providing particular plugin interfaces, and
  this information is automatically used to generate a plugin manifest.
  The sample `helloworld.py` plugin has been updated to use this
  library, reducing its size by 75% (111 lines to 28).

## Holiday publication schedule

Due to the holidays, the Optech Newsletter will not be publishing
newsletters on December 25th or January 1st.  Instead, we will publish a
special year-in-review newsletter on Friday, December 28th, and will
return to our regular Tuesday publication schedule starting on January
8th.

{% include references.md %}
{% include linkers/issues.md issues="1984,2039,2324,14573,2155,2154,2132,2161" %}
{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="89cdcfedcac776fec6101654f98e87112ca0de5d"
  end="34241716852df6ea6a3543822f3bf6f886519d4b"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="5451211d1947de5b2376aff5eb39c6e9f969cbbb"
  end="0fafd5e2fd824f38ec6a03a56488de9c0798f34f"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="dc7b76e5e6a9cd8a28731a7634db50f33287619b"
  end="2c53572798f78ce2a66aced0627b7b3f2adb0514"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="e34ceb333b1c0e6f4115ecbb80c632ac1042fa49"
  end="e34ceb333b1c0e6f4115ecbb80c632ac1042fa49"
%}
[V0.17.1rc1]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[maxwell-todd por]: https://web.archive.org/web/20170928054354/https://iwilcox.me.uk/2014/proving-bitcoin-reserves
[boneh-et-al por]: http://www.jbonneau.com/doc/DBBCB15-CCS-provisions.pdf
[towns schnorr taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[ln irc meeting]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001737.html
[function decorators]: https://www.thecodeship.com/patterns/guide-to-python-function-decorators/
[flask]: http://flask.pocoo.org/
[ln minisketch]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001741.html
[optimized transaction relay]: http://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-efficient-p2p-transaction-relay/
[naumenko relay simulator]: https://github.com/naumenkogs/Bitcoin-Simulator
