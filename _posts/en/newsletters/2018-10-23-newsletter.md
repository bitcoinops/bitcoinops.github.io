---
title: "Bitcoin Optech Newsletter #18"
permalink: /en/newsletters/2018/10/23/
name: 2018-10-23-newsletter
slug: 2018-10-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter contains a warning about communicating with
Bitcoin nodes using RPC over unencrypted connections, links to two new papers
about creating fast multiparty ECDSA keys and signatures that could reduce
transaction fees for multisig users, and lists some notable merges from
popular Bitcoin infrastructure projects.

## Action items

- **Close open RPC ports on nodes:** about 13% of Bitcoin
  nodes appear to have their RPC ports open on unencrypted public
  connections, putting users of those nodes at risk.  See the full news
  item below for additional details about the risk and recommended
  solutions.

## News

- **Over 1,100 listening nodes have open RPC ports:** It was recently
  mentioned in the #bitcoin-core-dev IRC chatroom that many Bitcoin
  nodes on the network had their RPC port open.  Optech
  [investigated][port scan summary] and found that about 1,100 of the
  8,400 listening nodes with an IPv4 address did indeed have port 8332
  open (13.2%).

  This may indicate that many node operators are unaware that RPC
  communication over the Internet is completely insecure by default
  and exposes your node to multiple attacks that could cost you money
  even if you've disabled the wallet on your node.  RPC communication
  is not encrypted, so any eavesdropper observing even a single request
  to your server can steal your authentication credentials and use them
  to run commands that empty your wallet (if you have one), trick your
  node into using a fork of the block chain with almost no
  proof-of-work security, overwrite arbitrary files on your
  filesystem, or do other damage.  Even if you never connect to your
  node over the Internet, having an open RPC port carries a risk that
  an attacker will guess your login credentials.

  By default, nodes do not accept connections to RPC from any other
  computer---you have to enable a configuration option to allow RPC
  connections.  To determine whether you've enabled this feature,
  check your Bitcoin configuration file and startup parameters for the
  `rpcallowip` parameter.  If this option is present, you should
  remove it and restart your node unless you have a good reason to
  believe all RPC connections to your node are encrypted or are
  exclusive to a trusted private network.  If you want to test your
  node remotely for an open RPC port, you can run the following
  [nmap][] command after replacing *ADDRESS* with the IP address of
  your node:

  ```
  nmap -Pn -p 8332 ADDRESS
  ```

  If the result in the *state* field is "open", you should follow the
  instructions above to remove the `rpcallowip` parameter.  If the
  result is either "closed" or "filtered", your node is safe unless
  you've set a custom RPC port or otherwise have enabled a customized
  configuration.

  A [PR][Bitcoin Core #14532] has been opened to Bitcoin Core to make
  it harder for users to configure their node this way and to print
  additional warnings about enabling such behavior.

- **Two papers published on fast multiparty ECDSA:** in multiparty
  ECDSA, two or more parties can cooperatively (but trustlessly) create
  a single public key that requires the parties also cooperate to create
  a single valid signature for that pubkey.  If the parties agree before
  creating the pubkey, they may also make it possible for fewer than all
  of them to sign, e.g. 2-of-3 of them must cooperate to sign.  This can
  be much more efficient than Bitcoin's current multisig, which requires
  placing *k* signatures and *n* pubkeys into transactions for k-of-n
  security, whereas multiparty ECDSA would always require only one
  signature and one pubkey for any *k* or *n*.  The techniques
  underlying multiparty ECDSA may also be used with scriptless scripts
  as described in [Newsletter #16][news16 mpecdsa].

  Best of all, these advantages are available immediately to anyone
  who implements them because the Bitcoin protocol's current support
  for ECDSA means it also supports pure ECDSA multiparty schemes as
  well.  No changes are required to the consensus rules, the P2P
  protocol, address formats, or any other shared resource.  All you
  need are two or more wallets that implement multiparty ECDSA key
  generation and signing.  This can make the scheme appealing to
  existing services that gain from the additional security of Bitcoin
  multisig but lose from having to pay additional transaction fees for
  the extra pubkeys and signatures.

  It will likely take time for experts to review these papers,
  evaluate their security properties, and consider implementing
  them---and some experts are already busy working on implementing a
  consensus change proposal to enable a Schnorr signature
  scheme that can simplify generation of multiparty pubkeys and signatures
  and also provide multiple other benefits.

  - [Fast Multiparty Threshold ECDSA with Fast Trustless Setup][mpecdsa goldfeder] by Rosario Gennaro and Steven Goldfeder

  - [Fast Secure Multiparty ECDSA with Practical Distributed Key Generation and Applications to Cryptocurrency Custody][mpecdsa lindell] by Yehuda Lindell, Ariel Nof, and Samuel Ranellucci

[mpecdsa goldfeder]: http://stevengoldfeder.com/papers/GG18.pdf
[mpecdsa lindell]: https://eprint.iacr.org/2018/987.pdf

## Notable merges

*Notable code changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-lightning][core lightning repo], and [libsecp256k1][libsecp256k1
repo].*

- [Bitcoin Core #14291][]: For use with Bitcoin Core's multiwallet mode,
  a new `listwalletdir` RPC can list all available wallets in the wallet
  directory.

- [Bitcoin Core #14424][]: Fixes a likely regression in 0.17.0 for
  watch-only wallets that require users to import their public keys for
  multisig scripts (rather than just importing the script) in order for
  Bitcoin Core to attempt spending the script using RPCs such as
  [fundrawtransaction][rpc fundrawtransaction] with the
  `includeWatching` flag.  This PR has been tagged for backport to
  0.17.1 whenever work on that should start.  A workaround for 0.17.0
  users is described in [Bitcoin Core #14415][].

- [LND #1978][], [#2062][LND #2062], [#2063][LND #2063]: new functions
  for creating sweep transactions have been added, replacing functions
  from the UTXO Nursery that is "dedicated to incubating time-locked
  outputs."  These new functions accept a list of outputs, generate a
  transaction for them with an appropriate fee that pays back into the
  same wallet (not a reused address), and signs the transaction.  The
  sweep transactions set nLockTime to the current block chain height,
  implementing the same anti-fee sniping technique adopted by other
  wallets such as Bitcoin Core and GreenAddress, helping to discourage
  chain reorgs and allowing LND's sweep transactions to blend in with
  those other wallets' transactions.

- [LND #2051][]: ensures that an attacker who chooses to lock his funds
  for a very long period of time (up to about 10,000 years) can't cause
  your node to lock the same amount of your funds for the same length of
  time.  With this patch, your node will reject requests from an
  attacker to lock his funds and your funds for a period of more than
  5,000 blocks (about 5 weeks).

- [C-Lightning #2033][]: provides a new `listforwards` RPC that lists
  forwarded payments (payments made in payment channels passing through
  your node), including providing information about the amount of fees
  you earned from being part of the forwarding path.  Additionally, the
  `getstats` RPC now returns a new field, `msatoshis_fees_collected`,
  containing the total amount of fees you've earned.

- [Libsecp256k1 #354][]: allows callers of the ECDH functions to use a
  custom hash function.  The Bitcoin consensus protocol doesn't use
  ECDH, but it is used elsewhere with the same curve parameters as
  Bitcoin in schemes described in BIPs [47][BIP47], [75][BIP75], and
  [151][BIP151] (old draft); Lightning BOLTs [4][BOLT4] and [8][BOLT8];
  and variously elsewhere such as [Bitmessage][], [ElementsProject][]
  side chains using confidential transactions and assets, and some
  Ethereum smart contracts.  Some of these schemes can't use the default
  hash function libsecp256k1 uses, so this merged PR allows passing a
  pointer to a custom hash function that will be used instead of the
  default and which permits passing arbitrary data to that function.

{% include references.md %}
{% include linkers/issues.md issues="14291,14424,1978,2062,2063,2051,2033,354,14415,14532" %}

[bitmessage]: https://bitmessage.org/wiki/Encryption
[elementsproject]: https://elementsproject.org/
[port scan summary]: https://gist.github.com/harding/bf6115a567e80ba5e737242b91c97db2
[nmap]: https://nmap.org/download.html
[news16 mpecdsa]: /en/newsletters/2018/10/09/#multiparty-ecdsa-for-scriptless-lightning-network-payment-channels
