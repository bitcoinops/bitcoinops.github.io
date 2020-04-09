---
title: 'Bitcoin Optech Newsletter #14'
permalink: /en/newsletters/2018/09/25/
name: 2018-09-25-newsletter
slug: 2018-09-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes action items and news related to last week's
security release of Bitcoin Core 0.16.3 and Bitcoin Core 0.17RC4, popular
questions and answers from the Bitcoin StackExchange over the past
month, and short descriptions of notable merges made to popular Bitcoin
infrastructure projects.

- **Upgrade to Bitcoin Core 0.16.3 to fix CVE-2018-17144:** as widely
  reported early Friday (UTC), the denial-of-service vulnerability
  described in last week's Optech newsletter is now known to allow
  miners to trick affected systems into accepting invalid bitcoins.

    As of this writing, it's believed that a majority of large Bitcoin
    services and miners have upgraded, likely ensuring that any blocks
    exploiting the bug will be quickly reorganized out of the most
    proof-of-work chain---reducing the risk for SPV clients and
    non-upgraded nodes.

    If you don't plan to upgrade or if you use an SPV client, you should
    consider waiting for more confirmations than you usually do (30
    confirmations---about 5 hours worth---is a normal
    [recommendation][reorg risk recommendation] in these sort of
    situations, as that's enough time for people to notice a problem and
    get warnings published).  Otherwise, upgrading to one of the
    following versions remains highly recommended for any system,
    especially those systems handling money:

    * [0.16.3][] (current stable)

    * [0.17.0RC4][bcc 0.17] (release candidate for next major version)

    * [0.15.2][] (backport to old version, may have other issues)

    * [0.14.3][] (backport to old version, may have other issues)

- **Allocate time to test Bitcoin Core 0.17RC4:** Bitcoin Core has
  uploaded [binaries][bcc 0.17] for 0.17 Release Candidate (RC) 4.
  Testing is greatly appreciated and can help ensure the quality of the
  final release.

## News

- **CVE-2018-17144:** the initial and subsequent disclosures of
  information about this bug were the only significant news this week.
  For more information, we suggest reading the following sources:

    - [Bitcoin Core full disclosure][]

    - [Original confidential report][], now public

    - [Additional technical information][bse 79484] by Andrew Chow (also described below)

    - [CVE-2018-17144 entry][cve-2018-17144], National Vulnerability Database (NVE) entry
      being updated by Luke Dashjr

    We're aware of several very insightful people currently reflecting
    upon the bug, its ultimate causes, and possible methods for reducing
    the risk of future serious bugs.  An especially good venue for
    Bitcoin Core internal discussion will be during the October 8th
    though 10th [CoreDev.tech][] meetings following the Tokyo Scaling
    Bitcoin conference.  We plan to follow up with links to any
    significant conclusions that are published.

    Optech thanks the original reporter, Awemany, for his responsible
    disclosure as well as the following developers who unhesitatingly
    made the time to quickly confirm the issue, address it, and quietly
    provide round-the-clock monitoring for attempts to exploit the
    then-undisclosed inflation risk: Pieter Wuille, Gregory Maxwell,
    Wladimir van der Laan, Cory Fields, Suhas Daftuar, Alex Morcos, and
    Matt Corallo.

## Selected Q&A from Bitcoin StackExchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help answer other people's questions.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

- [How does CVE-2018-17144 work?][bse 79484] Andrew Chow provides a
  detailed explanation of how Bitcoin Core can be crashed or tricked
  into accepting multiple spends of the same input in versions
  vulnerable to this bug.

- [Why doesn't Bitcoin use UDP instead of TCP?][bse 79175] Gregory
  Maxwell describes a case where important Bitcoin software does already
  use UDP and then details the reasons why UDP support isn't implemented
  in popular full node software.  He concludes with a description of
  some potential benefits that might be available if UDP support was
  implemented.

- [How likely are you to get blacklisted by an exchange if you use Wasabi wallet's CoinJoin mixing?][bse 78654]
  Wasabi Wallet author
  Adam Ficsor explains that nothing stops exchanges from refusing funds
  mixed through Wasabi, but that several features of Wasabi (such as a
  required anonymity set of 100) can help make blocking users bad for
  business.  Alternatively, he links to a tool that may allow users to
  circumvent an address blacklist.

- [What's the minimum number for a Bitcoin private key?][bse 79472]
  Answers from Mark Erhardt and Gregory Maxwell were provided within a
  minute of each other, but a humorous rephrasing of Maxwell's answer by
  Nate Eldredge has more upvotes than either answer as of this writing.

## Notable commits

*Notable commits this week in [Bitcoin Core][core commits], [LND][lnd
commits], and [C-lightning][cl commits].  Reminder: new merges to
Bitcoin Core are made to its master development branch and are unlikely
to become part of the upcoming 0.17 release---you'll probably have to
wait until version 0.18 in about six months from now.*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="c53e083a49291b611d278a8db24ff235c1202e43"
  end="920c090f63f4990bf0f3b3d1a6d3d8a8bcd14ba0"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="3b2c807288b1b7f40d609533c1e96a510ac5fa6d"
  end="f4305097e1638f6f8958dfa9eec941d8bf80246e"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="36eab5de26e203311ceeb65c94ec5beb9c94ff5d"
  end="3ce53ab9eddd397d57b6afc5faefe6703e56ac26"
%}

- [Bitcoin Core #13152][]: when connected to the peer-to-peer network,
  nodes share the IP addresses of other nodes they've heard about and
  these addresses are stored in a database that Bitcoin Core queries
  when it wants to open a new connection.  This PR adds a new RPC command,
  `getnodeaddresses`, that returns one or more of these addresses.  This
  can be useful in conjunction with tools like [bitcoin-submittx][].

- [LND #1738][]: the logic for validating channel updates has been
  moved to the routing package so that it's available both in routing
  (to handle failed payment sessions) and the gossiper (where it was
  handled before).  This fixes issue [#1707][LND #1707] (and implements
  a test case for it) that may have allowed a node to trick one of its
  peers into believing a different peer had a routing failure, thus
  possibly redirecting traffic to the malicious node.

- C-Lightning now provides a `gossipwith` tool that allows you to
  receive gossip from a node independently of lightningd or even to send
  the remote node a message.  This tool is used for additional testing
  of lightningd's gossip component.

- C-Lightning now complies with updates to [BOLT7][bolt7] by
  splitting the previous `flags` field for the `listchannels` RPC into
  two new fields: `message_flags` and `channel_flags`.  Also code
  comments and references to [BOLT2][] and [BOLT11][] have been updated.

- C-Lightning has significantly expanded the in-code documentation of
  its secrets module.  The documentation is remarkably good (and, at
  times, quite humorous).  See [hsmd.c][].  The code comments even
  document other code comments:

    ```c
    /*~ You'll find FIXMEs like this scattered through the code.{% comment %}skip-test{% endcomment %}
     * Sometimes they suggest simple improvements which someone like
     * yourself should go ahead an implement.  Sometimes they're deceptive
     * quagmires which will cause you nothing but grief.  You decide! */

     /* FIXME: We should cache these. */{% comment %}skip-test{% endcomment %}
     get_channel_seed(&c->id, c->dbid, &channel_seed);
     derive_funding_key(&channel_seed, &funding_pubkey, &funding_privkey);
    ```

- C-Lightning can now make multiple requests in parallel to bitcoind,
  speeding up operations on slow systems or on nodes performing long-running
  operations.

{% include references.md %}
{% include linkers/issues.md issues="13152,1738,1707" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 79484]: {{bse}}79484
[bse 79175]: {{bse}}79175
[bse 78654]: {{bse}}78654
[bse 79472]: {{bse}}79472
[0.16.3]: https://bitcoincore.org/en/2018/09/18/release-0.16.3/
[0.15.2]: https://github.com/bitcoin/bitcoin/releases/tag/v0.15.2
[0.14.3]: https://github.com/bitcoin/bitcoin/releases/tag/v0.14.3
[reorg risk recommendation]: https://btcinformation.org/en/you-need-to-know#instant
[bitcoin core full disclosure]: https://bitcoincore.org/en/2018/09/20/notice/
[original confidential report]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016424.html
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[coredev.tech]: https://coredev.tech/
[hsmd.c]: https://github.com/ElementsProject/lightning/blob/master/hsmd/hsmd.c
[bitcoin-submittx]: https://github.com/laanwj/bitcoin-submittx
