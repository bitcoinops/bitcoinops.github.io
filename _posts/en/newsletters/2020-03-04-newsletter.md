---
title: 'Bitcoin Optech Newsletter #87'
permalink: /en/newsletters/2020/03/04/
name: 2020-03-04-newsletter
slug: 2020-03-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed update to BIP340 schnorr
keys and signatures, seeks feedback on a proposal to improve startup
feature negotiation between full nodes, examines a suggestion for a
standardized way to prevent hardware wallets from using corrupt nonces
to leak private keys, and links to an analysis of the properties necessary in a
hash function for taproot to be secure.  Also included are our
regular sections for release announcements and notable changes to
popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Updates to BIP340 schnorr keys and signatures:** as previously
  mentioned in two separate items in Newsletter #84 ([1][news83 safety], [2][news83 tiebreaker]),
  several updates to [BIP340][] schnorr signatures have been proposed
  (which also affect [BIP341][] taproot).  Pieter Wuille [suggests][wuille
  update] changing which variant of a public key should be used with
  [BIP340][], with the new selection being based on the evenness of the
  key.  Also, the recommended procedure for generating a nonce has been
  changed to include the public key in nonce generation, to include
  independently-generated randomness when available, and to include a step in the nonce
  generation algorithm that uses the randomness to obfuscate the private key
  in order to protect the key against [differential power analysis][].

    Because of the significance of some of these changes, the tag for
    the tagged hashes in BIP340 is changed, ensuring that any code
    written for the earlier drafts will generate signatures that fail
    validation under the proposed revisions.  Wuille requests community
    feedback on the changes.

- **Improving feature negotiation between full nodes at startup:** Suhas
  Daftuar [requested feedback][daftuar wtxid] on a proposal to insert a
  message into the sequence used by nodes to open a connection with a
  new peer.  The new message would make it easier for a node to
  negotiate what features it wants to receive from its peer.  A
  challenge here is that previous versions of Bitcoin Core would
  terminate a new connection if certain messages didn't appear in a
  particular order---and it's into this strict sequence that Daftuar
  wants to insert a new message.  The proposal does increment the P2P
  protocol version to provide backwards compatibility, but Daftuar is
  seeking feedback from maintainers of full nodes about whether the
  insertion of negotiation messages would cause any problems.  If you're
  aware of any problems, please reply to the thread.

- **Proposal to standardize an exfiltration resistant nonce protocol:** Stepan
  Snigirev [started][snigirev nonce] a discussion on the Bitcoin-Dev
  mailing list about standardizing a protocol that prevents hardware
  wallets from using biased nonces to leak
  users' private keys.  One [previously proposed][sign to contract]
  mechanism for defending against this attack would be to use the *sign
  to contract protocol* to verify that the signature commits to
  randomness selected by the hardware wallet's host computer or mobile
  device.  Developers of libsecp256k1 have already been working on an
  API to both [enable generic sign to contract][secp s2c] and build an
  [exfiltration resistant nonce capability][secp nonce] on top of it.  Snigirev's
  email describes the currently preferred protocol and how it can be
  extended to multiple computers and Partially Signed Bitcoin
  Transactions ([PSBTs][topic psbt]).

- **Taproot in the generic group model:** Lloyd Fournier published his
  [poster][fournier poster] for the Financial Cryptography conference
  two weeks ago describing what properties must be present in the hash
  function used with taproot in order for taproot to be secure.  This
  extends a previous [proof][poelstra proof] by Andrew Poelstra which
  made the broader assumption that the hash function acted as a [random
  oracle][].  Those evaluating the cryptographic security of taproot are
  encouraged to review Poelstra's proof and Fournier's poster.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure.
Please consider upgrading to new releases or helping to test release
candidates.*

- [LND 0.9.1][] is a new minor version release that doesn't contain any
  new features but which fixes several bugs, including a bug that can
  result in "erroneous force closes between nodes".

- [Bitcoin Core 0.19.1][] (release candidate)

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17985][] net: Remove forcerelay of rejected txs FIXME:moneyball

- [Bitcoin Core #17264][] changes the default in RPCs that create or
  process Partially Signed Bitcoin Transactions ([PSBTs][topic psbt])
  to include any known [BIP32][] HD wallet derivation path.  This allows
  any other wallets that later process the PSBT to use that information
  to select the appropriate signing key or verify that a change output
  pays the correct address.  Those wanting to keep their derivation
  paths private may disable sharing using the `bip32_derivs`
  parameter.

- [C-Lightning #3490][] adds a `getsharedsecret` RPC that will derive a
  shared secret from the combination of the local node's private key and
  a user-specified public key.  This shared secret is derived the same
  way other shared secrets are derived in the LN protocol (SHA256 digest of the
  [ECDH][] result), which may not be the same way other programs derive
  shared secrets using elliptic curve cryptography (e.g. for [ECIES][]).
  This RPC can be useful for plugins that want to encrypt their
  communication with other LN nodes.

- [Eclair #1307][] updates the packaging scripts used by Eclair,
  producing a zip file with everything needed to use the software.  This
  new method allows Eclair GUI to be built deterministically in addition
  to the core library (which we reported in [Newsletter #83][news83
  eclair determ]).  [Reproducible builds][topic reproducible builds] help users ensure that the
  software they run is based on the source code that's been publicly
  reviewed.

- [Libsecp256k1 #710][] makes minor changes to the library to help with
  testing.  In one of the changes, a [function][secp256k1_ecdh] that
  could previously return a range of values (contrary to its documented
  behavior) will now only return either `0` or `1`.  At least one other
  library [used][rust-secp256k1 ecdh ret] the old behavior and a concern
  was [mentioned][ruffing concern] in the #secp256k1 IRC chatroom that
  other programs or libraries might also be using the old unadvised
  behavior.  If any of your programs use the `secp256k1_ecdh` function,
  consider reviewing the discussion on [this PR][710 comment] and in the
  related [rust-secp256k1 issue][rust-secp256k1 #196].

- [BIPs #886][] updates [BIP340][] schnorr signatures with two
  recommendations: (1) to include entropy in the nonce calculation
  whenever a random number generator is available, and (2) to verify any
  signatures produced by the software are valid before distributing them
  to outside programs, at least whenever the extra computation and delay
  isn't burdensome.  These two steps help ensure an attacker can't
  recover a user's private key by obtaining invalid signatures with
  reused nonces; see [Newsletter #83][news83 safety] for attack details.
  For other proposed changes to BIP340, see the [news item][bip340
  update] above in this week's newsletter.

{% comment %}<!-- BOLTs #714 merged but reverted -->{% endcomment %}

{% include references.md %}
{% include linkers/issues.md issues="17985,17264,3490,1307,710,886" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[lnd 0.9.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.1-beta.rc1
[fournier poster]: https://github.com/LLFourn/taproot-ggm/blob/master/main.pdf
[poelstra proof]: https://github.com/apoelstra/taproot/blob/master/main.pdf
[random oracle]: https://en.wikipedia.org/wiki/Random_oracle
[differential power analysis]: https://en.wikipedia.org/wiki/Power_analysis#Differential_power_analysis
[bip-wtxid-relay]: https://github.com/sdaftuar/bips/blob/2020-02-wtxid-relay/bip-wtxid-relay.mediawiki
[news83 safety]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news83 tiebreaker]: /en/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[wuille update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017639.html
[daftuar wtxid]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017648.html
[snigirev nonce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017655.html
[sign to contract]: https://www.wpsoftware.net/andrew/secrets/slides.pdf
[secp s2c]: https://github.com/bitcoin-core/secp256k1/pull/589
[secp nonce]: https://github.com/bitcoin-core/secp256k1/pull/590
[ecdh]: https://en.wikipedia.org/wiki/Elliptic_curve_Diffie-Hellman
[ecies]: https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
[bip340 update]: #updates-to-bip340-schnorr-keys-and-signatures
[news83 eclair determ]: /en/newsletters/2020/02/05/#eclair-1295
[secp256k1_ecdh]: https://github.com/bitcoin-core/secp256k1/blob/96d8ccbd16090551aa003bfa4acd108b0496cb89/src/modules/ecdh/main_impl.h#L29-L69
[rust-secp256k1 ecdh ret]: https://github.com/rust-bitcoin/rust-secp256k1/blob/master/src/ecdh.rs#L162
[ruffing concern]: https://gist.githubusercontent.com/harding/603c2b18241bf61bb0bbe7a0383cf1c9/raw/20656e901472f217d1faa381ddda1d11214900da/foo.txt
[710 comment]: https://github.com/bitcoin-core/secp256k1/pull/710#discussion_r370987476
[rust-secp256k1 #196]: https://github.com/rust-bitcoin/rust-secp256k1/issues/196
