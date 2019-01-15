---
title: 'Bitcoin Optech Newsletter #11'
permalink: /en/newsletters/2018/09/04/
name: 2018-09-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes a reminder to please help test the
release candidate for Bitcoin Core's next version, information about the
development of Optech's new public dashboard, summaries of two
discussions on the Bitcoin-Dev mailing list, and notable commits from
Bitcoin infrastructure projects.

## Action items

- **Allocate time to test Bitcoin Core 0.17RC2:** Bitcoin Core has
  uploaded [binaries][bcc 0.17] for 0.17 Release Candidate (RC) 2.
  Testing is greatly appreciated and can help ensure the quality of the
  final release.

## Dashboard items

- **Optech dashboard:** a [blog post][dashboard post] by Marcin
  Jachymiak introduces the live dashboard he developed for Optech during
  his internship this summer, providing not only an overview of what
  information the dashboard makes available to you but a description of
  how he built it for anyone who wants to independently replicate the
  data or otherwise extend the dashboard using their own full node.

    The rest of the Optech team thanks Marcin for his dedicated work and
    keen insight, and we wish him all the best in the upcoming year.

## News

- **Discussion of resetting testnet:** Bitcoin's first public testnet was
  introduced in late 2010; a few months later it was reset to testnet2;
  and reset again to the current testnet3 in mid-2012.  Today testnet3
  has over 1.4 million blocks and consumes over 20 GB of disk space on
  archival nodes.  A [discussion][testnet reset] was started on the
  Bitcoin-Dev mailing list about resetting testnet again to provide a
  smaller chain for experimentation.  In addition to discussion about
  whether or not it's good to have a large test chain for
  experimentation, it was also [suggested][signed testnet] that a future
  testnet might want to use signed blocks instead of proof of work to
  allow the chain to operate more predictably than the current testnet3,
  which is prone to wild hash rate oscillations.  This would also allow
  the easy management of testnet disaster drills such as large chain
  reorganizations.

- **Proposed sighash updates:** before signing a transaction, a Bitcoin
  wallet creates a cryptographic hash of the the unsigned transaction
  and some other data.  Then, instead of signing the transaction
  directly, the wallet signs that hash.  Since the original 0.1 implementation
  of Bitcoin, wallets have been allowed to remove certain parts of the
  unsigned transaction from the hash before signing it, which allows those
  parts of the transaction to be changed by other people such as
  other participants in a multiparty contract.

    In [BIP143][], segwit preserved all of the original Bitcoin 0.1
    signature hash (sighash) flags but made some minor (but useful)
    changes to what data wallets include in the hash that made it harder
    for miners to DoS attack other miners and which made it easier for
    underpowered devices such as hardware wallets to protect users
    funds.  This week, BIP143 co-author Johnson Lau [posted][sighash
    changes] some suggested changes to sighash flags, including new
    flags, that could be implemented as a soft fork using the witness
    script update mechanism provided as part of segwit.

    {% comment %}<!-- for reference: numbers in following paragraph
    correspond to the numbered bullet points in Lau's email -->{%
    endcomment %}

    If the changes are adopted, some of the notable advantages include:
    making it easier for hardware wallets to securely participate in
    CoinJoin-style transactions <!--#1--> as well as other smart
    contracts<!--#2-->, potentially easier fee bumping by any individual
    party in a multiparty transaction<!--#6-->, and preventing counter
    parties and third parties to sophisticated smart contracts from
    bloating the size of multiparty transactions in a DoS attack that
    lowers a transaction's fee priority.<!--#8-->

## Notable commits

*Notable commits this week in [Bitcoin Core][core commits], [LND][lnd
commits], and [C-lightning][cl commits].  Reminder: new merges to
Bitcoin Core are made to its master development branch and are unlikely
to become part of the upcoming 0.17 release---you'll probably have to
wait until version 0.18 in about six months from now.*

{% comment %}<!-- LND only had three merges this week, none of them exciting IMO -harding -->{% endcomment %}

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="427253cf7e19ed9ef86b45457de41e345676c88e"
  end="68f3c7eb080e461cfeac37f8db7034fe507241d0"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="26f68da5b2883885fcf6a8e79b3fc9bb12cc9eef"
  end="2b448be048daf85cef4cbb37ceed4413fdb051e6"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="77d3ca3ea3ba607e0b08c7921c41bfc0a9658ed2"
  end="77d3ca3ea3ba607e0b08c7921c41bfc0a9658ed2"
%}

- [Bitcoin Core #12952][]: after being deprecated for several major
  release and disabled by default in the upcoming 0.17 release, the
  built-in accounts system in Bitcoin Core has been removed from the
  master development branch.  The accounts system was added in late 2010
  to allow an early Bitcoin exchange to manage their user accounts in
  Bitcoin Core, but it lacked many of the features desirable for true
  production systems (like atomic database updates) and it often
  confused users, so removing it gracefully has been a goal for several
  years.

- [Bitcoin Core #13987][]: when Bitcoin Core receives a transaction
  whose fee per vbyte is below its minimum feerate, it ignores that
  transaction.  [BIP133][] (implemented in Bitcoin Core 0.13.0) allows a
  node to tell its peers what its minimum feerate is so that those peers
  to don't waste bandwidth by sending transactions that will be ignored.
  This PR now provides that information for each peer in the
  [getpeerinfo][rpc getpeerinfo] RPC using the new `minfeefilter` value,
  allowing you to easily discover the minimum feerates being used by
  your peers.

- C-Lightning now allows you to ask lightningd to calculate a feerate
  target for your on-chain transactions by passing the either "urgent",
  "normal", or "slow" to the `feerate` parameter.  Alternatively, you
  may use this parameter to manually specify a particular feerate you
  want to use.

{% include references.md %}
{% include linkers/issues.md issues="12952,13987" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[dashboard post]: /en/dashboard-announcement/
[testnet reset]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016337.html
[signed testnet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016348.html
[sighash changes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016345.html
