---
title: 'Bitcoin Optech Newsletter #39'
permalink: /en/newsletters/2019/03/26/
name: 2019-03-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a proposal to encrypt P2P communication
and describes Lightning Loop, a tool and service for withdrawing
bitcoins from an LN channel to an onchain transaction.  Also included
are links to resources about bech32 adoption, summaries of popular
questions and answers from Bitcoin StackExchange, and a list of notable
code changes in popular Bitcoin infrastructure projects.

## Action items

- **Help test Bitcoin Core 0.18.0 RC2:** The second Release Candidate
  (RC) for the next major version of Bitcoin Core has been [released][0.18.0].
  Testing is still needed by organizations and experienced users who
  plan to run the new version of Bitcoin Core in production.  Use [this
  issue][Bitcoin Core #15555] for reporting feedback.

## News

- **Version 2 P2P transport proposal:** Jonas Schnelli sent a [proposed
  BIP][v2 transport] to the Bitcoin-Dev mailing list that specifies an algorithm to be
  used to encrypt traffic between peers.  It also specifies some other
  minor changes to the creation of protocol messages, such as allowing
  peers to use bandwidth-saving short identifiers and eliminating the
  SHA256-based checksum on messages, as the [AEAD][]-based encryption
  scheme protects data integrity.  The proposal is meant to replace
  [BIP151][] and it contains links to an example implementation for
  Bitcoin Core and some benchmarks.  See [Newsletter #10][] for previous
  discussion about P2P protocol encryption.

- **Loop announced:** Lightning Labs [announced][loop announced] a new
  tool and service to facilitate *submarine swaps*, HTLC-based atomic
  swaps of offchain bitcoins for onchain bitcoins.  In essence, Alice
  sends Bob an LN payment secured by a secret she knows, preventing Bob
  from claiming it.  Bob then creates an onchain payment that Alice can
  spend by revealing the secret.  Alice waits for the payment to receive
  a suitable number of confirmations and then spends it onchain to any
  address she chooses---revealing the secret in the process.  Bob sees
  Alice's onchain transaction and uses its revealed secret to claim the
  LN payment Alice sent him earlier.  If Alice doesn't reveal the secret,
  the onchain payment contains a refund condition that allows Bob to
  spend it back to himself after a timelock expires.

    Most of the process is trustless, so neither party has an
    opportunity to steal from the other (provided the software operates
    (and is operated) correctly).  The exception is the creation of the
    initial onchain transaction and the possible need for Bob to create
    a refund transaction: if the trustless exchange doesn't happen, Bob
    will receive no compensation for the onchain transaction fees
    required for both of those transactions.  According to the [Loop
    documentation][], their implementation has Alice send Bob a small
    trusted payment via LN in advance of the trustless exchange as an act of
    good faith and an assurance that the operation won't end up costing
    Bob money.

    By allowing Alice and Bob to swap onchain and offchain funds, all
    while continuing to use their existing channels, Loop helps users
    keep their channels open longer and makes it conceivable that they
    could stay open indefinitely.

- **Square Crypto developer group announced:** the CEO of Square
  [announced on Twitter][sqcrypto announced] that they are forming a
  group to employ several contributors to open source Bitcoin projects,
  including both developers and a designer.  See their announcement for
  application instructions.  (Note: Square is also a sponsoring member
  of Optech.)

## Bech32 sending support

*Week 2 of 24.  From now until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 easy] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

As described [last week][bech32 easy], implementing just segwit
spending should be easy.  Yet we suspect some managers might wonder
whether there are enough people using segwit to justify their team
spending development effort on it.  This week, we look at sites that
track various segwit adoption statistics so that you can decide whether
it's popular enough that your wallet or service might become an outlier
by failing to support it soon.

Optech tracks statistics about segwit use on our [dashboard][optech
dashboard]; another site tracking related statistics is [P2SH.info][].
We see an average of about 200 outputs per block are sent to native
segwit addresses (bech32).  Those outputs are then spent in about 10% of all
Bitcoin transactions.  That makes payments involving native segwit addresses
more popular than almost all altcoins.

![Screenshot of Optech Dashboard segwit usage stats](/img/posts/2019-03-segwit-usage.png)

However, many wallets want to use segwit but still need to deal with
services that don't yet have bech32 sending support.  These wallets can
generate a P2SH address that references their segwit details, which is
less efficient than using bech32 but more efficient than not using
segwit at all.  Because these are normal P2SH addresses, we can't tell
just by looking at transaction outputs which P2SH addresses are
pre-segwit P2SH outputs and which contain a nested segwit
commitment, and so we don't know the actual number of payments to
nested-segwit addresses.  However, when one of these outputs is spent,
the spender reveals whether the output was segwit. The above statistics
sites report that currently about 37% of transactions contain at least
one spend from a nested-segwit output.  That corresponds to about 1,400
outputs per block on average.

Any wallet that supports P2SH nested segwit addresses also likely
supports bech32 native addresses, so the number of transactions made by
wallets that want to take advantage of bech32 sending support is
currently over 45% and rising.

To further gauge segwit popularity, you might also want to know which
notable Bitcoin wallets and services support it.  For that, we recommend
the community-maintained [bech32 adoption][] page on the Bitcoin Wiki or
the [when segwit][] page maintained by BRD wallet.

The statistics and compatibility data show that segwit is already well
supported and frequently used, but that there are a few notable holdouts
that haven't yet provided support.  It's our hope that our campaign and
other community efforts will help convince the stragglers to catch up on
bech32 sending support so that all wallets that want to take advantage
of native segwit can do so in the next few months.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- Multiple questions about LN transport security: Rene Pickhardt asked
  several questions about the encryption used to communicate LN
  messages, such as [why is message length encrypted?]({{bse}}85259) and
  [what's special about ChaCha20-Poly1305?]({{bse}}84953).  The answers
  to these questions may be especially interesting in the context of the
  proposed BIP for a Bitcoin P2P encrypted transport protocol, which is
  planned to use the same cipher.

- Multiple questions about Schnorr-based signatures: Pickhard also asked
  several question about [BIP-Schnorr][], [Taproot][], and the plans to
  make those features available to Bitcoin transactions.  See [will
  Schnorr allow a single signature per block?]({{bse}}85213) and [does
  MuSig have the same security as current Bitcoin
  multisig?]({{bse}}85101).

- [How were the parameters for the secp256k1 curve
  chosen?]({{bse}}85387)  This is the elliptical curve used in Bitcoin.
  Some curve parameters play an important role in security, so it's
  useful to know whether those parameters were chosen wisely.  Other
  parameters don't matter much for security, but their history might be
  interesting anyway.  In his answer, Gregory Maxwell provides the
  history he's learned so far, an explanation of why the still-open
  questions don't affect security, and why we might never learn any more
  about the origin of certain curve parameters.

- [What addresses should I support when developing a
  wallet?]({{bse}}84978) A developer asks whether he should support both
  P2PKH (`1foo...`) addresses and P2SH-wrapped segwit (`3bar...`)
  addresses, or whether it's safe to just provide the P2SH address.
  Andrew Chow answers that just the P2SH address is enough.  Gregory
  Maxwell extends this by saying that, if developer did decide to
  display two addresses, a better combination would be the P2SH-wrapped
  segwit address and a native segwit (bech32) address (`bc1baz...`).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #10973][] makes Bitcoin Core's built-in wallet component access
  information about the block chain through a well-defined interface
  rather than directly accessing functions and variables on the node component.
  There are no user-visible changes associated
  with this update, but the merge is notable because it's the last of a
  set of foundational refactorings that should make it easy for
  future changes to run the node and the wallet/GUI in separate
  processes (see [Bitcoin Core #10102][] for one approach to this), as
  well as improving the modularity of the Bitcoin Core codebase and
  allowing more focused component testing.
  Besides laying the groundwork for major changes to come, this PR is
  notable for being open for over a year and a half, receiving almost
  200 code-review comments and replies, and requiring over 150 updates
  and rebases.  Optech thanks the PR author, Russell Yanofsky, for his
  amazing dedication in seeing this PR through to merge.

- [Bitcoin Core #15617][] omits sending `addr` messages containing the
  IP addresses of peers the node currently has on its ban-list.  This
  prevents your node from telling other nodes about peers it found
  to be abusive.

- [Bitcoin Core #13541][] modifies the `sendrawtransaction` RPC to
  replace the `allowhighfees` parameter with a `maxfeerate` parameter.
  The earlier parameter, if set to true, would send the transaction even
  if the total fee exceeded the amount set by the `maxtxfee`
  configuration option (default: 0.1 BTC).  The new parameter takes a
  feerate and will reject the transaction if its feerate is above the
  provided value (regardless of the setting for `maxtxfee`).  If no
  value is provided, it'll only send the transaction if its fee is
  below the `maxtxfee` total.

- [LND #2765][] changes how the LN node responds to channel breaches
  (attempted theft).  Previously, if an attempted breach was detected,
  the node created a breach remedy transaction to collect all funds
  associated with that channel.  However, when users start using
  watchtowers, the watchtower may create a breach remedy transaction
  but not include all the possible funds.  (This doesn't mean the
  watchtower is malicious: your node may simply not have had a chance to
  tell the watchtower about the latest commitments it accepted.) This PR
  updates the logic used to generate the breach remedy transaction so
  that it only collects the funds that haven't been collected by prior
  breach remedy transactions, allowing recovery of any funds the
  watchtower didn't collect.

- [LND #2691][] increases the default address look-ahead value during
  recovery from 250 to 2,500.  This is the number of keys derived from
  an HD seed that the wallet uses when rescanning the block chain for
  your funds.  Previously, if your node gave out more than 250 addresses
  or pubkeys without any of them being used, your node would not find
  your complete balance on its first rescan, requiring you to initiate
  additional attempts.  Now, you'd need to give out more than 2,500
  addresses before reiteration might become necessary.  An earlier
  version of this PR wanted to set this value to 25,000, but there were
  concerns that this would significantly slow down rescanning with the
  BIP158 Neutrino implementation, so the value was decreased until it
  could be shown that people needed a value that high.  (Note: checking
  addresses against a BIP158 filter is very fast by itself; the problem
  is that any match requires downloading and scanning the associated
  block---even if it's a false-positive match.  The more addresses you
  check, the greater the number of expected false positives, so scanning
  becomes slower and requires more bandwidth.)

- [C-Lightning #2470][] modifies the recently-added `setchannelfee` RPC
  so that "all" can be passed instead of a specific node's id in order
  to set the routing fee for all channels.

- [Eclair #826][] updates Eclair to be compatible with Bitcoin Core 0.17
  and upcoming 0.18, dropping support for 0.16.

{% include references.md %}
{% include linkers/issues.md issues="10973,15617,13541,2765,2691,2470,826,15555,10102" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[aead]: https://en.wikipedia.org/wiki/Authenticated_encryption
[loop announced]: https://blog.lightning.engineering/posts/2019/03/20/loop.html
[loop documentation]: https://github.com/lightninglabs/loop/blob/master/docs/architecture.md
[sqcrypto announced]: https://twitter.com/jack/status/1108487911802966017
[bech32 easy]: {{news38}}#bech32-sending-support
[optech dashboard]: https://dashboard.bitcoinops.org/
[p2sh.info]: https://p2sh.info/
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[when segwit]: https://whensegwit.com/
[taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[v2 transport]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016806.html
