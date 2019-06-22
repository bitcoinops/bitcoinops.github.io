---
title: 'Bitcoin Optech Newsletter #52'
permalink: /en/newsletters/2019/06/26/
name: 2019-06-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test C-Lightning and LND RCs:** both [C-Lightning][cl rc] and
  [LND][lnd rc] are in the process of testing Release Candidates (RC)
  for their next versions.  Experienced users of either program are
  encouraged to help test the RCs so that any remaining bugs can be
  identified and fixed before their final releases.

## News

FIXME

## Bech32 sending support

*Week 15 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/15-data-entry.md %}

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME(schmidty):q&a

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #13756][] adds a `setwalletflags` RPC that can be used
  to toggle flags for the wallet, including a new `avoid_reuse` flag
  that (when enabled) will prevent the wallet from spending bitcoins
  received to an address that the wallet has already used for spending.
  This prevents block chain analysts from being able to associate
  multiple spends with the same wallet through spending address
  reuse---an attack on privacy often exploited using [dust attacks][].
  This new flag is disabled by default, but it can be combined with the
  `avoidpartialspends` configuration option described in [Newsletter
  #6][] to ensure that all bitcoins received to the same address so far
  are spent at the same time, ensuring that there are none left over in
  an inaccessible balance.

- [Bitcoin Core #15651][] causes Bitcoin Core to always bind to the
  default port when listening on Tor (e.g. port 8333 for mainnet) even
  if it is configured to listen on another port for normal clearnet
  traffic.  The previous behavior where it listened on the custom port
  on all interfaces made it easy to find the clearnet identify of a Tor
  node using a custom Bitcoin port.

- [Bitcoin Core #16171][] removes the `mempoolreplacement` configuration
  option.  This option configured whether or not the node would accept
  replacements of transactions into its mempool according to the
  [BIP125][] opt-in Replace-by-Fee (RBF) rules.  This option was added
  at the [last moment][Bitcoin Core #7386] during the 0.12 release cycle
  and developers have [argued][sdaftuar rbf] that it's almost never what miners or
  node operators want---miners because it reduces their profitabliity
  and node operators because, even if the operator doesn't like opt-in
  RBF, disabling this option prevents them from receiving warnings about
  replacements.  Users who don't like RBF are better off ignoring opt-in
  transactions until they've been confirmed (as [described in
  BIP125][bip125 recv wallet policy]).  It's believed almost all nodes
  are currently using the default option and the only miner known to be
  using the option recently confirmed that was a misconfiguration on
  their part, so the option is being removed for lack of use and because
  there's no reason to recommend anyone use it.

- [Bitcoin Core #16026][] makes the `createmultisig` and
  `addmultisigaddress` RPCs always return a legacy P2SH multisig address
  if any of public keys used are [uncompressed pubkeys][].  Per
  [BIP143][], uncompressed pubkeys must not be used with the current
  version of segwit (version 0).  Bitcoin Core won't relay segwit spends
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
