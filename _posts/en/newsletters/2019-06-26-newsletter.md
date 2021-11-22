---
title: 'Bitcoin Optech Newsletter #52'
permalink: /en/newsletters/2019/06/26/
name: 2019-06-26-newsletter
type: newsletter
layout: newsletter
lang: en
slug: 2019-06-26-newsletter
---
This week's newsletter announces a pending disclosure of minor
vulnerabilities for older Bitcoin Core releases, suggests continued
testing of RCs for LN software, and describes a proposed technique to
make Bitcoin Core nodes a bit more resistant to eclipse attacks.  Also
included are our regular sections on bech32 sending support, popular Stack Exchange topics, and notable
changes to popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Update Bitcoin Core to at least 0.17.1:** two minor vulnerabilities
  that affect older releases of Bitcoin Core are
  [scheduled][vulnerabilities announce] to be disclosed around August
  1st.  Neither vulnerability affects version 0.17.1 (released 25
  December 2018) or later versions.  We express our gratitude to Bitcoin
  Core contributor practicalswift for reporting the vulnerabilities.

- **Help test C-Lightning and LND RCs:** both [C-Lightning][cl rc] and
  [LND][lnd rc] are in the process of testing Release Candidates (RC)
  for their next versions.  Experienced users of either program are
  encouraged to help test the RCs so that any remaining bugs can be
  identified and fixed before their final releases.

## News

- **Differentiating peers based on ASN instead of address prefix:** an
  [eclipse attack][] prevents a full node from making even one
  connection to another honest node, allowing the attacker to prevent
  the node from learning about the most-proof-of-work block chain or
  from broadcasting time-sensitive transactions.  To help prevent
  eclipse attacks, a Bitcoin Core full node will ordinarily split its
  eight outgoing connections between nodes whose IP addresses differ in
  their first 16 bits (i.e. /16).  Many ISPs only have IP addresses in a
  small number of different /16 ranges or allocate their addresses to
  customers in a way that makes it difficult for customers to choose
  which prefix they get, making it harder for an attacker to acquire a
  large diversity of IP addresses from which to they can perform an
  eclipse attack.

    However, there are large ISPs such as cloud computing operations
    that manage multiple facilities that each use different IP ranges,
    making it possible for customers to more easily acquire addresses
    from multiple prefixes.  One possible solution to that problem would
    be to track which IP addresses are controlled by which ISPs and then
    partition the node's outgoing connections among different ISPs
    regardless of what addresses they use.  For example, this might be
    able to group together all IP addresses from Amazon AWS no matter
    what region the customer used for their servers.

    ISP-to-IP-address information is available from a whole-Internet
    routing table.  Unfortunately, those tables are over a gigabyte in
    size---too large to practically include with full nodes.  Pieter
    Wuille has been working on a compact encoding of just the information
    needed to identify different ISPs by their IP addresses (using the
    ISP's Autonomous System Number, ASN).  Wuille's table reduces the
    extra storage requirements to about 1 MB.  During this week's [IRC
    meeting][core dev meeting] of Bitcoin Core developers, Wuille and
    Matt Corallo asked whether 1 MB of extra data was small enough to
    distribute with Bitcoin Core in order to improve its ability to
    ensure connections to peers on different networks.  Meeting
    participants expressed support for the idea before spending time
    debating some implementation details.  Based on that feedback, we
    expect to see more development of this idea.

## Bech32 sending support

*Week 15 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/15-data-entry.md %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How can I mitigate concerns around the gap limit?]({{bse}}88128) Enrique
  inquires about potential loss of funds when using an HD wallet and exceeding
  the address gap limit. Andrew Chow and Bitcoin Holder explain that, while there
  are no loss of funds when exceeding the gap limit, the limit should be
  considered when restoring from backup or generating addresses outside of the
  wallet.

- [How do bitcoin nodes update the UTXO set when their latest blocks are replaced?]({{bse}}87991)
  Pieter Wuille describes how "[undo files][]" are
  used to update the UTXO set after a block reorganization.

- [Is there a reason why Bitcoin Core does not implement BIP39?]({{bse}}88237)
  Andrew Chow explains how Bitcoin Core's current wallet structure, plus security
  concerns about [BIP39][]'s use of PBKDF2, produce obstacles against its implementation.

- [Is a signature/private-key required to accept payment over Lightning Network?]({{bse}}88201)
  Yuya Ogawa asks about the possibility of accepting Lightning payments without having
  to keep a private key online. Rene Pickhardt points out that not only does
  [BOLT11][] require signed invoices, but the updating of channels also
  necessitates signatures and thus private keys.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #13756][] adds a `setwalletflag` RPC that can be used
  to toggle flags for the wallet, including a new `avoid_reuse` flag
  that (when enabled) will prevent the wallet from spending bitcoins
  received to an address that the wallet has already used for spending.
  This prevents block chain analysts from being able to associate
  multiple spends with the same wallet through spending address
  reuse---an attack on privacy often exploited using [dust attacks][].
  This new flag is disabled by default but, when enabled, it can be combined with the
  `avoidpartialspends` configuration option described in [Newsletter
  #6][] to ensure that all bitcoins received to the same address so far
  are spent at the same time, ensuring that there are none left over in
  a balance that requires passing a special option to spend.

- [Bitcoin Core #15651][] causes Bitcoin Core to always bind to the
  default port when listening on Tor (e.g. port 8333 for mainnet) even
  if it is configured to listen on another port for normal clearnet
  traffic.  The previous behavior where it listened on the custom port
  on all interfaces made it easy to find the clearnet identify of any Tor
  node that used a custom Bitcoin port.

- [Bitcoin Core #16171][] removes the `mempoolreplacement` configuration
  option.  This option configured whether or not the node would accept
  replacements of transactions into its mempool according to the
  [BIP125][] opt-in Replace-by-Fee (RBF) rules.  This option was added
  at the [last moment][Bitcoin Core #7386] during the 0.12 release cycle
  and developers have [argued][sdaftuar rbf] that it's almost never what miners or
  node operators want---miners because it reduces their profitability
  and node operators because, even if the operator doesn't like opt-in
  RBF, disabling this option prevents them from receiving warnings about
  replacements.  Users who don't like RBF are better off ignoring
  transactions that opt-in to RBF until they've been confirmed (as [described in
  BIP125][bip125 recv wallet policy]).  It's believed almost all nodes
  are currently using the default option and the only miner known to be
  using the option recently confirmed that was a misconfiguration on
  their part, so the option is being removed for lack of use and because
  there's no reason to recommend anyone use it.

- [Bitcoin Core #16026][] makes the `createmultisig` and
  `addmultisigaddress` RPCs always return a legacy P2SH multisig address
  if any of public keys used are [uncompressed pubkeys][].  Per
  [BIP143][], uncompressed pubkeys must not be used with the current
  version of segwit (version 0).  Bitcoin Core won't relay spends from segwit outputs
  that use uncompressed pubkeys and it's possible that a future soft
  fork will make them permanently unspendable.

{% include linkers/issues.md issues="13756,15651,16171,7386,16026" %}
[bech32 series]: /en/bech32-sending-support/
[bip125 recv wallet policy]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki#receiving-wallet-policy
[dust attacks]: {{bse}}81509
[cl rc]: https://github.com/ElementsProject/lightning/tags
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[sdaftuar rbf]: https://github.com/bitcoin/bitcoin/pull/16171#issuecomment-500393271
[uncompressed pubkeys]: https://btcinformation.org/en/developer-guide#public-key-formats
[undo files]: https://en.bitcoin.it/wiki/Data_directory#locks_subdirectory
[vulnerabilities announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/017040.html
[eclipse attack]: https://eprint.iacr.org/2015/263.pdf
[core dev meeting]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-06-20-19.01.log.html#l-36
