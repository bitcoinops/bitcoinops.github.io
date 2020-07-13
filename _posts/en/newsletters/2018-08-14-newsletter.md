---
title: 'Bitcoin Optech Newsletter #8'
permalink: /en/newsletters/2018/08/14/
name: 2018-08-14-newsletter
slug: 2018-08-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes the usual dashboard and action items,
news about the importance of allowing secure and anonymous responsible
disclosure of bugs, a potential new payment protocol that can improve
privacy on Bitcoin without any consensus rule changes, shaving one byte
off the size of every transaction signature, a new restriction on the P2P
network protocol, and lowering the minimum transaction relay fee---plus
a few notable commits from the Bitcoin Core, LND, and C-Lightning
projects.

## Action items

- **Check your responsible disclosure process:** it's especially
  important that researchers be able to report bugs securely (e.g. using
  PGP) and anonymously (e.g. using Tor).  See the News section below for
  links to details about a previous responsible disclosure of a consensus
  failure bug in the Bitcoin Cash cryptocurrency that could've been used
  to steal from exchanges---even those that required multiple
  confirmations for deposit transactions---as well suggested best
  practices for making disclosures easy.

- **Check software using the P2P protocol `getblocks` or `getheaders` messages:**
  if you use custom software that requests blocks using
  either of these messages, ensure they don't make their requests with
  more than 101 locators.  All popular open source software has already
  been tested, but if you have internal software that speaks the P2P
  protocol, you may need to test it.  See the News section for details.

## Dashboard items

{% assign img1_label = "Transactions per block, 25-block moving average, July 14, 2018 - August 13, 2018" %}

- Transaction [fees remain very low][fee metrics]: Anyone who can wait 10 or
more blocks for confirmation can reasonably pay the default minimum fee rate.
It’s a good time to [consolidate UTXOs][consolidate info].

- Estimated [BTC hash rate][btc hash rate] briefly touched 60 EH/s on August 10, and has a 7 day average of 48 EH/s.

- The number of transactions in each block. This metric is vaguely periodic in that it has peaks at around 13:00 to 17:00 UTC each
day. The graph below shows a 25-block moving average of the number of transactions. It was sourced from the
[Optech beta dashboard][periodic txn data] that we encourage people to try out and provide us feedback about.

![{{img1_label}}](/img/posts/transactions-spikes.png)
*{{img1_label}},
source: [Optech dashboard][periodic txn data]*

## News

- **How to help security researchers:** Bitcoin Core developer and Digital Currency Initiative (DCI) member Cory
  Fields [revealed][fields post] that he was the anonymous source behind
  the disclosure of a potentially consensus-breaking bug in the Bitcoin
  Cash cryptocurrency.  After a frustrating experience trying to report
  the bug, he requested cryptocurrency-related projects make it easier
  for security researchers to submit secure anonymous vulnerability
  reports to projects, and fellow DCI member Neha Narula followed this
  up with [some recommendations][narula recs] particularly targeted at
  cryptocurrency maintainers but possibly also useful for organizations
  using cryptocurrencies.


    Optech encourages our member companies (and any others reading this
    newsletter) to consider how easy it would be for an anonymous
    researcher to report a critical bug to your staff.  An easy way to
    test your process could be tasking one of your team members to
    install Tor and actually attempt to securely submit a report using
    no information about your operation other than what they can easily
    find on your website.  If you provide bug bounties, you may also
    wish to make clear that you will provide the same levels of reward
    to anyone who initially reports a PGP-signed disclosure, subject to
    you later collecting any information from them you may need for legal
    compliance.

- **Pay-to-End-Point (P2EP) idea proposed:** blog posts by [Adam
  Ficsor][nopara73 p2ep] (nopara73) of zkSNACKs and [Matthew
  Haywood][blockstream p2ep] of Blockstream describe a new idea for
  improving privacy for Bitcoin users without making any changes to the
  consensus protocol.  The basic idea is that spenders contact a server
  controlled by the receiver when attempting to make a payment (similar
  to the [BIP70][] payment protocol), provide a normal signed
  transaction as proof that they're willing to pay, and then receive the
  information necessary to perform multiple CoinJoin-style transactions
  with the receiver.  If one of the CoinJoin-style transactions is used,
  this can confuse block chain analysis companies into thinking an input
  added to the transaction by the receiver was an input that belonged to
  the spender, or (if P2EP is widely used) just making block chain
  analysis less reliable in general.

    If discussions continue positively and a specific proposal is agreed
    upon, several privacy focused wallets are considering adding support
    for P2EP spending and [BTCPay
    Server](https://github.com/btcpayserver/btcpayserver) is considering
    adding support for P2EP receiving.

- **Bitcoin Core wallet to begin only creating low-R signatures:**
  the DER format used to encode Bitcoin signatures
  requires adding an entire extra byte to a signature just to indicate
  when the signature's R value is on the top-half of
  the elliptical curve used for Bitcoin.  The R value is randomly
  derived, so half of all signatures have this extra byte.

    Merged this week, Bitcoin Core PR [#13666][Bitcoin Core #13666] generates multiple signatures for
    each transaction (if necessary) using an incremental nonce until a
    signature is found that has a low-R value that doesn't require this
    extra byte.  By doing so, Bitcoin Core transactions will save one
    byte per every two signatures (on average).  If all wallets did
    this, it could save up to several thousand bytes (or up to a couple
    thousand vbytes) per typical full block, increasing block chain
    capacity by up to a few thousand transactions a day.  The cost is
    that it will take Bitcoin Core twice as long to generate an average
    signature and that it reduces the entropy (randomness) of the
    generated signatures by 1 bit, neither of which is significant.  It
    may also make transactions created by Bitcoin Core somewhat easier
    to identify if no other wallets adopt this change.

    Note that this change does not affect other software in any way
    (except for other wallets being able to use the extra block chain
    capacity).  It's purely a feature built into the Bitcoin Core wallet
    and not something that will be enforced by the protocol.

- **Lowering minimum relay fees in two steps:** as mentioned in
  [Newsletter #3][news3 lower relay], Bitcoin Core developers are
  [considering][Bitcoin Core #13922] lowering the minimum relay fee for
  transactions.  Because this change affects wallets, relay nodes, and
  miners all at the same time---but because they don't all update on the
  same schedule---evaluating and testing the change has turned out to
  be harder than one might expect for just changing a few variables.

    The currently-discussed plan is to lower the default fee for relay
    nodes and miners first, wait to see if it receives sufficient
    adoption for what are currently sub-default fee transactions to
    get mined, and then lower the minimum fee the wallet uses in a later
    release.  We will post future updates in this newsletter about how
    your organization can help use and encourage the adoption of lower
    minimum relay fees.

- **P2P protocol change to restrict locators:** the [getblocks][p2p
  getblocks] and [getheaders][p2p getheaders] messages allow a node to
  request information about blocks it hasn't seen by sending a list of
  blocks it has seen to another node.  The receiving node uses the list
  to find the last block the two nodes have in common and sends
  information about subsequent blocks.

    According to an [email][bd locators] posted to the bitcoin-dev
    mailing list by Gregory Maxwell, Bitcoin Talk user Coinr8d was
    concerned that the requesting node could send up to 32 MiB of block
    hashes to the receiving node, causing the receiving node to spend a
    lot of I/O looking for blocks it didn't have.  However, Maxwell's
    tests didn't find this to be a significant problem.  Still, Maxwell
    proposed limiting the number of allowed locators in these messages.
    Libbitcoin developer Eric Voskuil said his software was already
    enforcing a limit and that he was aware of a program (BitcoinJ) that
    slightly exceeded the limit proposed by Maxwell.

    The subsequently merged PR [Bitcoin Core #13907][] by Maxwell set
    the limit to equal to the maximum requested by BitcoinJ.  If you are
    aware of software requesting more than 101 elements using the
    `getblocks` or `getheaders` P2P messages, please post to the
    bitcoin-dev mailing list or contact someone from Optech.

- **Schnorr BIP discussion:** a [discussion][schnorr discuss] between
  experts about the algorithm for generating Schnorr signatures last
  week on the bitcoin-dev mailing list was resolved without any need for
  changes to the proposed BIP.  This may increase confidence that the
  proposed BIP's parameters were wisely chosen.

## Notable commits

*Notable commits this week in [Bitcoin Core][core commits], [LND][lnd
commits], and [C-lightning][cl commits].  Does not include Bitcoin Core
#13907 or #13666 described above.  Note: the bulk of the changes to all three
projects this week seemed to be improvements to their automated testing
code; we aren't describing those in this newsletter, but we're sure
users and developers highly appreciate that work.*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="2b67354aa584c4aabae049a67767ac7b70e2d01a"
  end="1b04b55f2d22078ca79cd38fc1078e15fa9cbe94"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="f0f5e11b826e020c11c37343bcbaf9725627378b"
  end="6989316b11c51922b4c6ae3507ac06680ec530b9"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="80a8e57ede82292818032eeb3510da067fddfd5e"
  end="a97955845ff43d4780b33a7301695db33823c57c"
%}

- [Bitcoin Core #13925][]: increases the maximum number of file
  descriptors Bitcoin Core's internal database can use, which can
  allow more file descriptors to be used for network connections.  If
  you've modified Bitcoin Core to accept more than 117 incoming
  connections, you may see an additional increase in the number of
  connections after upgrading past this merge.  (Note: we don't
  recommend increasing the default unless you have a special need.)

- [LND #1644][]: fees entered by the user in satoshis per vbyte are now
  automatically converted to the use of satoshis per kiloweight (1,000
  vbytes) as defined in the [protocol][BOLT2].

- C-Lightning: a paying node will no longer send an HTLC commitment
  (payment) to another node unless it's heard from that node within the
  past 30 seconds.  If necessary, it'll ping the recipient node before
  sending the commitment.  This helps the paying node abort a payment
  earlier in the process if that payment was destined to fail anyway
  because of a network interruption.

- C-Lightning: various moderate improvements to the code for
  reconnecting to disconnected peers, including exponential backoff and
  reconnection time fuzzing.

{% include references.md %}
{% include linkers/issues.md issues="13922,13907,13925,1644,13666" %}

[news3 lower relay]: {{news3}}#news
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
[fields post]: https://medium.com/mit-media-lab-digital-currency-initiative/http-coryfields-com-cash-48a99b85aad4
[narula recs]: https://medium.com/mit-media-lab-digital-currency-initiative/reducing-the-risk-of-catastrophic-cryptocurrency-bugs-dcdd493c7569
[nopara73 p2ep]: https://medium.com/@nopara73/pay-to-endpoint-56eb05d3cac6
[blockstream p2ep]: https://blockstream.com/2018/08/08/improving-privacy-using-pay-to-endpoint.html
[p2p getblocks]: https://bitcoin.org/en/developer-reference#getblocks
[p2p getheaders]: https://bitcoin.org/en/developer-reference#getheaders
[bd locators]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016285.html
[schnorr discuss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016278.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[btc hash rate]: https://fork.lol/pow/hashrate
[periodic txn data]: https://dashboard.bitcoinops.org/d/K7C9p0vmz/btc-number-of-txns-total-fee-per-block-volume?panelId=4&fullscreen&orgId=1
