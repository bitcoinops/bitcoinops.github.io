---
title: 'Bitcoin Optech Newsletter #15'
permalink: /en/newsletters/2018/10/02/
name: 2018-10-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes a notice of Bitcoin Core 0.17's
impending release, links to the backport releases of Bitcoin Core 0.15
and 0.14 to fix the CVE-2018-17144 duplicate inputs bug for those users
unable to run more recent releases, a brief description of a chainsplit
on testnet, and links to notable merges in Bitcoin infrastructure
projects.

## Action items

- **Upgrade to Bitcoin Core 0.17:** the new release has been tagged and
  several people have begun reproducing builds of the software, so the
  binaries and formal release announcement are likely to become
  available Tuesday or Wednesday on [BitcoinCore.org][].  The
  announcement will include a copy of the release notes detailing major
  changes to the software since the 0.16.0 release.

## News

- **Bitcoin Core [0.15.2][] and [0.14.3][] released:** although source code has
  been available for these older branches since the public announcement
  of the [CVE-2018-17144][] duplicate inputs bug, getting enough people
  to certify a reproducible build took extra time before the
  [binaries][bcco /bin] could be made available.

- **CVE-2018-17144 duplicate inputs bug exploited on testnet:**
  last Thursday a block was created on testnet containing a transaction
  that spent the same input twice.  As expected, nodes believed to be
  vulnerable to the bug accepted the block and all other nodes rejected
  it, leading to a consensus failure (chainsplit) where the chain with
  the most proof of work contained the duplicate inputs and a weaker
  chain did not.

    Eventually, the chain without the duplicate inputs gained more proof
    of work and the vulnerable nodes attempted to switch to it.  This
    caused the vulnerable nodes to attempt to re-add the duplicate input
    to the UTXO database twice, triggering an assert and causing them to
    shutdown.  When restarted, operators of the vulnerable nodes needed
    to manually trigger a lengthy reindex procedure to fix their nodes'
    database inconsistencies.  (This side-effect of recovering from a
    duplicate inputs chainsplit was previously known to developers.)

    Nodes upgraded to Bitcoin Core 0.16.3, 0.17.0RC4, or running other
    software that wasn't vulnerable had no reported problems.  However,
    many block explorers with a testnet mode did accept the vulnerable
    block, providing a reminder that users should be careful about using
    third-parties to determine whether or not transactions are valid.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], and [C-lightning][cl commits].*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="920c090f63f4990bf0f3b3d1a6d3d8a8bcd14ba0"
  end="c9327306b580bb161d1732c0a0260b46c0df015c"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="f4305097e1638f6f8958dfa9eec941d8bf80246e"
  end="79ed4e8b600e4834f058cbf3cb8b93f5aa5ab3d4"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="3ce53ab9eddd397d57b6afc5faefe6703e56ac26"
  end="d6fcfe00c722f7e6f4b691cd47743ed593aeea0e"
%}

- [Bitcoin Core #14305][]: after the discovery of a few cases where
  Python-based tests were passing incorrectly as a result of using
  misnamed variables, a variable name whitelist was implemented using
  Python 3's `__slots__` feature for classes.

- [LND #1987][]: the `NewWitnessAddress` RPC has been removed and the
  `NewAddress` RPC now only supports generating addresses for
  P2SH-wrapped P2WKH and native P2WPKH.

- [C-Lightning #1982][]: The `invoice` RPC now implements [RouteBoost][]
  by including a [BOLT11][] `r` parameter in the invoice that provides
  routing information to the payer for an already-open channel that has
  the capacity to support paying the invoice.  This parameter was originally
  intended to help support private routes, but it can also be used this
  way to support nodes that no longer want to accept new incoming
  channels.  Alternatively, if no available channel can support
  payment of the invoice, C-Lightning will emit a warning.

{% include references.md %}
{% include linkers/issues.md issues="14305,1987,1982" %}

[0.16.3]: https://bitcoincore.org/en/2018/09/18/release-0.16.3/
[0.15.2]: https://github.com/bitcoin/bitcoin/releases/tag/v0.15.2
[0.14.3]: https://github.com/bitcoin/bitcoin/releases/tag/v0.14.3
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[bcco /bin]: https://bitcoincore.org/bin/
[routeboost]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-September/001417.html
