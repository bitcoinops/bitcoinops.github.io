---
title: 'Bitcoin Optech Newsletter #29'
permalink: /en/newsletters/2019/01/15/
name: 2019-01-15-newsletter
slug: 2019-01-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a security upgrade for C-Lightning,
describes a paper and additional research into wallets that accidentally
revealed their private keys, and lists some notable code changes in
popular Bitcoin infrastructure projects.

## Action items

- **Upgrade to C-Lightning 0.6.3:** this [release][cl 0.6.3] fixes a remote DoS
  vulnerability that could be used to crash C-Lightning nodes and
  potentially steal money.  See the *notable code changes* section below
  for details.  This release also includes other less critical bug fixes
  and new features.

## News

- **Weak signature nonces discovered:** a preprint [paper][weak nonces]
  by researchers Joachim Breitner and Nadia Heninger describes how they
  discovered hundreds of Bitcoin private keys by looking for signatures
  generated using nonces with less than the expected entropy of 256
  bits.  Independent [code archaeology][gmaxwell bitcore] by Gregory
  Maxwell indicates that the main culprit was probably the BitPay
  Bitcore software which introduced a bug around July 2014 and released
  a fix about a month later.  (Note: BitPay Bitcore is unrelated to
  Bitcoin Core.)  From there, the bug propagated to software such as
  BitPay Copay that depended upon Bitcore.  About 97% of the faulty
  signatures found in the paper are compatible with Maxwell's Copay
  hypothesis, and the paper provides plausible explanations for most of
  the remaining 3% of signatures, indicating that users of modern
  wallets are probably safe provided they do not continue to use
  addresses whose bitcoins they spent using earlier vulnerable programs.

    If you ever used an affected version of Bitcore (0.1.28 to 0.1.35),
    Copay (0.4.1 to 0.4.3), or other vulnerable software, you should
    create a new wallet file, send all of your funds from the old wallet
    file to an address in the new wallet, and discontinue use of the
    previous wallet file.  When designing software that signs Bitcoin
    transactions, you should prefer to use peer-reviewed implementations
    that generate signature nonces deterministically, such as
    [libsecp256k1][] which implements [RFC6979][].

    The fast analysis method employed by the authors of the paper took
    advantage of users who engaged in address reuse, but even keys for
    addresses that have not been reused are vulnerable to attack if the
    nonce generation is biased or too small.  This can be either through
    using the same method for keys that were used multiple times (e.g.
    for Replace-By-Fee) or through simply brute-forcing using the
    [baby-step giant-step][] or [Pollard's Rho][] methods.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], and [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #15039][] disables nLockTime-based anti-fee-sniping if
  the most recent block seen by the node had a timestamp eight or more
  hours ago.  Anti-fee-sniping attempts to equalize the advantages
  between honest miners who simply extend the block chain and dishonest
  miners who create chain forks in an attempt to steal fees from honest
  miners.  However, when using anti-fee-sniping, nodes that have been
  offline for a while don't know what block is at the tip of the chain
  and so they could create multiple transactions offline that would all
  use the same very old nLockTime value, linking those transactions
  together in block chain analysis.  This merge fixes the problem by
  disabling the feature if a node is offline for too long.

- [C-Lightning #2214][] fixes a remote crash bug which could lead
  to loss of funds. **All users are advised to upgrade to 0.6.3 to
  get a fix for this issue.**

    The vulnerability allowed a peer to crash your C-Lightning node by
    trying to get you to accept a payment with a smaller timelock than
    your node allows.  If a crashed node remains shutdown for too long,
    it's possible for an attacker to steal from it if they previously
    opened a channel with that node.  Note, though, that the attacker
    must risk their own money to attempt the attack, and so nodes can
    pretend to be offline in order to take money from any
    attackers---which is hoped to be enough of a risk to discourage most
    attacks.

- [C-Lightning #2230][] updates the `listpeers` RPC's "channel" output to
  include a `private` flag indicating whether the channel is being
  announced to peers on not.

- [C-Lightning #2244][] disables plugins by default but adds a
  configuration option `--enable-plugins` to enable them at startup.
  Plugins may be re-enabled by default for a future release when the
  entire plugin API has been implemented.

- [Eclair #797][] changes the way payment routes are calculated.
  Previously, routes were calculated from the spender to the receiver;
  now they're calculated from the receiver to the spender.  This fixes a
  problem where the node was miscalculating fees.

{% include references.md %}
{% include linkers/issues.md issues="15039,2214,2230,2244,797" %}
[gmaxwell bitcore]: https://bitcoin.stackexchange.com/questions/83559/what-is-the-origin-of-insecure-64-bit-nonces-in-signatures-in-the-bitcoin-chain/
[weak nonces]: https://eprint.iacr.org/2019/023.pdf
[RFC6979]: https://tools.ietf.org/html/rfc6979
[cl 0.6.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.3
[baby-step giant-step]: https://en.wikipedia.org/wiki/Baby-step_giant-step
[pollard's rho]: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm
