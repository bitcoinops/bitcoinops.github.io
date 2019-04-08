---
title: 'Bitcoin Optech Newsletter #41'
permalink: /en/newsletters/2019/04/09/
name: 2019-04-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests testing for release candidates of
Bitcoin Core and LND, describes a discussion about UTXO snapshots for
fast initial syncing of nodes, and provides regular coverage of bech32
sending support and notable merges in popular Bitcoin infrastructure
projects.

## Action items

- **Help test Bitcoin Core 0.18.0 RC3:** The third Release Candidate
  (RC) for the next major version of Bitcoin Core has been [released][0.18.0].
  This may be the final test version, so we encourage organizations and
  expert users to test it promptly if they want to ensure any
  possible regressions are caught before release.  Please use [this
  issue][Bitcoin Core #15555] for reporting feedback.

- **Help test LND 0.6-beta RC3:** the first, second, and third RCs for
  the next major version of LND were [released][lnd releases] this week.
  Testing by organizations and experienced LN users is encouraged to
  catch any regressions or serious problems that could affect users of
  the final release.  [Open a new issue][lnd issue] if you discover any
  problems.

## News

- **Discussion about an assumed-valid mechanism for UTXO snapshots:**
  When Bitcoin Core developers are preparing a new major release,
  one developer selects the hash of a recent block on the best block
  chain.  Other well-known contributors check their personal nodes and
  ensure that hash is indeed part of the best block chain, and then add
  that hash to the software as the "assumed valid" block.  When new
  users start Bitcoin Core for the first time, the program then defaults
  to skipping verification of signatures on all transactions included
  in blocks before the assumed valid block.  The program still keeps
  track of the bitcoin ownership changes produced by each transaction in
  a index called the Unspent Transaction Output (UTXO) set.  Although
  reviewing each historic ownership change still takes time, simply
  skipping signature checking reduces initial sync time by about 80%
  according to [tests][0.14 tests].  Gregory Maxwell, who [implemented
  the assumed valid feature][Bitcoin Core #9484], has argued that,
  "Because the validity of a chain history is a simple objective fact,
  it is [easy] to review this setting."

    This week James O'Beirne started a [thread][assumeutxo thread] on
    the Bitcoin-Dev mailing list about taking a hash of the UTXO set at
    a particular block, having multiple well-known contributors verify
    they get the same hash, and then having freshly installed Bitcoin
    Core nodes default to using that hash to download the exact same
    UTXO set.  This would allow a newly-started node to skip not only
    signatures but all block chain data before the assumed valid block,
    perhaps reducing the bandwidth and time requirements to start a node
    today by 95% or more (and certainly more as the block chain
    continues to grow).  This is an old idea, is currently implemented
    in some software that uses Bitcoin Core, and is part of the
    motivation for research into other techniques such as [fast
    updatable UTXO commitments][] and [automatic levelDB backups][].

    Discussion mainly revolved around whether or not this is a good
    idea.  Arguments in favor of it include it making starting a new
    node much easier and that it doesn't seem to change the trust model
    for anyone who already trusts the peer review of their development
    team or who is willing to disable the default option to have their
    node review the chainstate for validity itself.  Arguments against
    it include a fear that fast initial syncs with an assumed valid UTXO
    set would disguise the fact that block size increases make complete
    initial syncing from scratch much more expensive; if block sizes
    increased too much, it could become impossible for anyone of modest
    means to ever trustlessly verify Bitcoin's UTXO state, forcing new
    users to trust existing users.

## Bech32 sending support

*Week 4 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 easy] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

<div class="hide-on-web" markdown="1">

**Note:** we're unable to correctly format multi-line code examples in
the email edition of the newsletter.  Please visit the [web
edition][Newsletter #41] for better formatting.  We apologize for the
inconvenience.

</div>

In [last week's newsletter][Newsletter #40], we used the Python
reference library for bech32 to decode an address into a scriptPubKey
that you could pay.  However, sometimes the user provides an address
containing a typo.  The code we suggested would detect the typo and
ensure you didn't pay a wrong address, but bech32 is also able to help
detect the location of typos for your users.  This week, we'll
demonstrate this capability using the [Javascript sample code][].

The code is written using Node.js-style module inclusion syntax, so the
first step is to compile it into code we can use in the browser.  For
that, we install a [browserify][] tool:

```bash
sudo apt install node-browserify-lite
```

Then we compile it into a standalone file:

```bash
browserify-lite ./segwit_addr_ecc.js --outfile bech32-demo.js --standalone segwit_addr_ecc
```

Followed by including it in our HTML:

```html
<script src="bech32-demo.js"></script>
```

For convenience, we've included that file on the [web
version][Newsletter #41] of this newsletter, so you can follow along
with the rest of this example by simply opening the developer console in
your web browser.  Let's start by checking a valid address.  Recall from
last week that we provide the network identifier when checking an
address (`bc` for Bitcoin mainnet):

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4', 'bc')
error: null
program: Array(20) [ 117, 30, 118, … ]
version: 0
```

We see above that, just like last week, we get back the witness version
and the witness program.  The presence of the version field, plus the
lack of an error, indicate that this program decoded without any
checksum failure.

Now we replace one character in the above address with a typo and try
checking that:

```text
segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r4zarvary0c5xw7kv8f3t4', 'bc')
error: "Invalid"
pos: Array [ 21 ]
```

This time we get back the description of the error (the address is
invalid because it doesn't match its checksum) and a position.  If we
place the addresses above each other with each position marked, we see
that this "21" identifies the location of the specific error:

```text
                   1x        2x
         0123456789012345678901
>> good='bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
>> typo='bc1qw508d6qejxtdg4y5r4zarvary0c5xw7kv8f3t4'
                              ^
```

What if we make an additional replacement to the typo address and try
again?

```text
>> segwit_addr_ecc.check('bc1qw508d6qejxtdg4y5r4zarvary0c5yw7kv8f3t4', 'bc')
error: "Invalid"
pos: Array [ 32, 21 ]
```

We get two locations.  Once again, when we compare the addresses to
each other, we see this has identified both incorrect characters:

```text
                   1x        2x        3x
         012345678901234567890123456789012
>> good='bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
>> typo='bc1qw508d6qejxtdg4y5r4zarvary0c5yw7kv8f3t4'
                              ^          ^
```

Pieter Wuille's [interactive demo][] of this Javascript code includes
a few lines of additional code (view source on that page to see the
function) that uses the position of the typo characters to emphasize
them in red:

![Screenshot of the bech32 interactive demo with the typo address above](/img/posts/2019-04-bech32-demo.png)

There's a limit to how many errors the `check()` function can specifically identify.
After that it can still tell that an address contains an error, but it
can't identify where to look in the address for the error.  In that
case, it'll still return the address as invalid but it won't return the
position details:

```text
>> segwit_addr_ecc.check('bc1qw508z6qejxtdg4y5r4zarvary0c5yw7kv8f3t4', 'bc')
error: "Invalid"
pos: null
```

In the case where there are other problems with the address, the `error`
field will be set to a more descriptive message that may or may not
include a position of the error.  For example:

```text
>> segwit_addr_ecc.check('bc1zw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4yolo', 'bc')
error: "Invalid character"
pos: Array [ 43 ]
```

You can review the [source][bech32 errors] for a complete list of
errors.

Although we spent a lot of time looking at errors in this mini tutorial,
we've hopefully shown how easy it is to provide nice interactive
feedback to users entering bech32 addresses on a web-based platform.  We
encourage you to play around with the [interactive demo][] to get an
idea of what your users might see if you make use of this bech32 address
feature.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].  Note: all merges described for Bitcoin Core and LND
are to their master development branches; some may also be backported to
their pending releases.*

- [Bitcoin Core #15596][] updates the `sendmany` RPC to remove the
  `minconf` parameter.  For outputs received to your wallet, this
  parameter allowed you to specify how many confirmations they must have
  before you attempted to spend them.  Now the wallet defaults are
  always used.  Those defaults are not to spend outputs received from
  other people until they are confirmed and to optionally allow spending
  unconfirmed change outputs from yourself depending on the
  `spendzeroconfchange` configuration setting.  This is the same way the
  more commonly used `sendtoaddress` RPC has always worked.

- [LND #2885][] changes how LND attempts to reconnect to all of its
  peers when coming back online.  Previously it attempted to open
  connections to all its persistent peers at once.  Now it spreads the
  connections over a 30 second window to reduce peak memory usage by
  about 20% and to also reduce the number of concurrent events later due
  to the events occurring on a regular interval, such as pings.

- [LND #2740][] implements a new gossiper subsystem which puts its peers
  into two buckets, active gossiper or passive gossiper.  Active
  gossipers are peers communicating in the currently normal way of
  sharing all of their state with your node; passive gossipers are peers
  from which you will only request specific updates.  Because most
  active gossipers will be sending you the same updates as all other
  gossipers, having more than a few of them is a waste of your
  bandwidth, so this code will ensure that you get a default of 3
  active gossipers and then put any other gossipers into the passive
  category.  Furthermore, the new code will try to only request updates
  from one active gossiper at a time in [round-robin][] fashion to avoid
  syncing the same updates from different nodes.  In one test described
  on the PR, this change reduced the amount of gossip data requested by
  97.5%.

- [LND #2313][] implements code and RPCs that allow LND nodes to use
  static channel backups.  This is based on the Data Loss Protection
  (DLP) protocol implemented in [LND #2370][] to allow backing up a
  single file containing all of your current channel state at any point
  and then enabling restoring from that file at any later point to get
  your remote peer to help you to close any of those channels in their
  latest state (excluding unfinalized routed payments (HTLCs)).  Note:
  despite the "static" in this feature's name, this is not like an HD
  wallet one-time backup.  It's a backup that needs to be done at least
  as often as each time you open a new channel---but that's much better
  than the current state where you may not be able to recover any funds
  from any of your channels if you lose data.  Further improvements to
  backup robustness are mentioned in the PR's description.  See the
  description of LND #2370 in [Newsletter #31][] for more details on how
  DLP-based backup and recovery works.  Getting this major improvement
  to backups merged was one of the major goals for upcoming LND version
  0.6-beta.

- [BIPs #772][] withdraws [BIP151][] at the request of its author, who
  has proposed an alternative scheme for [P2P protocol
  encryption][].

- [BIPs #756][] assigns [BIP127][] to a specification for the proof of
  reserves tool described in [Newsletter #33][].  Draft text for the BIP
  is merged.

<script src="/misc/bech32-demo.js"></script>

{% include references.md %}
{% include linkers/issues.md issues="15555,9484,772,756,2313,15596,2885,2740,2370" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[bech32 easy]: {{news38}}#bech32-sending-support
[0.14 tests]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#ibd
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[browserify]: http://browserify.org/
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[assumeutxo thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
[fast updatable UTXO commitments]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[automatic leveldb backups]: https://github.com/bitcoin/bitcoin/issues/8037
[javascript sample code]: https://github.com/sipa/bech32/tree/master/ecc/javascript
[interactive demo]: http://bitcoin.sipa.be/bech32/demo/demo.html
[bech32 errors]: https://github.com/sipa/bech32/blob/master/ecc/javascript/segwit_addr_ecc.js#L54
[round-robin]: https://en.wikipedia.org/wiki/Round-robin_scheduling
