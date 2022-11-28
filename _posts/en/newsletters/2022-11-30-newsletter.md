---
title: 'Bitcoin Optech Newsletter #228'
permalink: /en/newsletters/2022/11/30/
name: 2022-11-30-newsletter
slug: 2022-11-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to mitigate LN jamming
attacks using reputation credential tokens.  Also included are our
regular sections with announcements of new software releases and release
candidates and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Reputation credentials proposal to mitigate LN jamming attacks:**
  Antoine Riard [posted][riard credentials] to the Lightning-Dev mailing
  list a [proposal][riard proposal] for a new credential-based
  reputation system to help prevent attackers from temporarily blocking
  payment ([HTLC][topic htlc]) slots or value, preventing honest users
  from being able to send payments---a problem called [channel jamming
  attacks][topic channel jamming attacks].

    In LN today, spenders choose a path from their node to the receiving
    node across multiple channels operated by independent forwarding
    nodes.  They create a set of trustless instructions that describes
    where each forwarding node should next relay the payment, encrypting
    those instructions so that each node receives only the minimum
    information it needs to do its job.

    Riard proposes that each forwarding node should only accept the relay
    instructions if they include one or more credential tokens that were
    previously issued by that forwarding node.  The credentials include
    a [blind signature][] that prevents the forwarding node from
    directly determining which node was issued the credential
    (preventing the forwarding node from learning the network identity
    of the spender).  Each node may issue credentials according to its
    own policy, although Riard suggests several distribution methods:

    - *Upfront payments:* if Alice's node wants to forward payments
      through Bob's node, her node first uses LN to buy a credential
      from Bob.

    - *Previous success:* if a payment that Alice sent through Bob's
      node is successfully accepted by the ultimate receiver, Bob's node
      can return a credential token to Alice's node---or even more
      tokens than were previously used, allowing Alice's node to send
      additional value through Bob's node in the future.

    - *UTXO ownership proofs or other alternatives:* although not
      necessary for Riard's initial proposal, some forwarding nodes may
      experiment with giving credentials to everyone who proves they own
      a Bitcoin UTXO, perhaps with modifiers that give older or
      higher-value UTXOs more credential tokens than newer or
      lower-value UTXOs.  Any other criteria can be used as each
      forwarding node chooses for itself how to distribute its
      credential tokens.

    Clara Shikhelman, whose own co-authored proposal partly based on
    local reputation was described in [Newsletter #226][news226 jam],
    replied to [ask][shikelman credentials] whether credential tokens
    were transferable between users and whether that could lead to the
    creation of a market for tokens.  She also asked how they would work
    with [blinded paths][topic rv routing] where a spending node
    wouldn't know the full path to the receiving node.

    Riard [replied][riard double spend] that it would be difficult to
    redistribute credential tokens and create a market for them because
    any transfer would require trust.  For example, if Bob's node
    issues a new credential to Alice, who then tries to sell the
    credential to Carol, there's no trustless way for Alice to prove she
    won't try to use the token herself even after Carol has paid her.

    For blinded paths, [it appears][harding paths] the receiver can
    provide any necessary credentials in an encrypted form without
    introducing a secondary vulnerability.

    Additional feedback for the proposals was received on its related
    [pull request][bolts #1043].

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.5-beta.rc2][] is a release candidate for a maintenance
  release of LND.  It contains only minor bug fixes according to its
  planned release notes.

- [Core Lightning 22.11rc3][] is a release candidate for the next major
  version of CLN.  It'll also be the first release to use a new version
  numbering scheme, although CLN releases continue to use [semantic
  versioning][].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5727][] begins deprecating numeric JSON request IDs
  in favor of IDs using the string type.  [Documentation][cln json ids]
  is added describing the benefit of string IDs and how to get the most
  out of creating and interpreting them.

- [Eclair #2499][] allows specifying a blinded route to use when using a
  [BOLT12 offer][topic offers] to request payment.  The route may
  include a route leading up to the user's node plus additional hops
  going past it.  The hops going past the node won't be used, but they
  will make it harder for the spender to determine how many hops the
  receiver is from the last non-blinded forwarding node in the route.

- [LND #7122][] adds support to `lncli` for processing binary [PSBT][topic
  psbt] files. [BIP174][] specifies that PSBTs may be encoded either as plain
  text Base64 or binary in a file. Prior, LND already supported importing
  Base64-encoded PSBTs either as plain text or from file.

- [LDK #1852][] accepts a feerate increase proposed by a channel peer
  even if that feerate isn't high enough to safely keep the channel
  open at present.  Even if the new feerate isn't entirely safe, its
  higher value means it's safer than what the node had before, so it's
  better to accept it than try to close the channel with its existing
  lower feerate.  A future change to LDK may close channels with
  feerates that are too low, and work on proposals like [package
  relay][topic package relay] may make [anchor outputs][topic anchor
  outputs] or similar techniques adaptable enough to eliminate concerns
  about present feerates.

- [Libsecp256k1 #993][] includes in the default build options the
  modules for extrakeys (functions for working with x-only pubkeys),
  [ECDH][], and [schnorr signatures][topic schnorr signatures].  The
  module for reconstructing a public key from a signature is still not
  built by default "because we don't recommend ECDSA recovery for new
  protocols. In particular, the recovery API is prone to misuse: It
  invites the caller to forget to check the public key (and the
  verification function always returns 1)."

{% include references.md %}
{% include linkers/issues.md v=2 issues="5727,2499,7122,1852,993,1043" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc3
[cln json ids]: https://github.com/rustyrussell/lightning/blob/a25c5d14fe986b67178988e6ebb79610672cc829/doc/lightningd-rpc.7.md#json-ids
[riard credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003754.html
[riard proposal]: https://github.com/lightning/bolts/blob/80214c83190836c4f7699af9e8920769607f1a00/www-reputation-credentials-protocol.md
[blind signature]: https://en.wikipedia.org/wiki/Blind_signature
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[shikelman credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003755.html
[riard double spend]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003765.html
[harding paths]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003767.html
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[semantic versioning]: https://semver.org/spec/v2.0.0.html
