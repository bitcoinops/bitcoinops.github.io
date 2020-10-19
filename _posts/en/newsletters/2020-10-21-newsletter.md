---
title: 'Bitcoin Optech Newsletter #120'
permalink: /en/newsletters/2020/10/21/
name: 2020-10-21-newsletter
slug: 2020-10-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter provides an overview of the new MuSig2 paper,
summarizes additional discussion about upfront fees in LN, and describes
a proposal to simplify management of LN payments.  Also included are our
regular sections with summaries of notable improvements to clients and
services, announcements of releases and release candidates, and changes
to popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **MuSig2 paper published:** Jonas Nick, Tim Ruffing, and Yannick Seurin
  published [the MuSig2 paper][musig 2 paper] describing a new variant of the
  [MuSig][topic musig] signature scheme with a two round signing protocol.

    MuSig is a signature scheme that allows multiple signers to create an
    aggregate public key derived from their individual private keys, and then
    collaborate to create a single valid signature for that public key. The
    aggregate public key and signature are indistinguishable from any other
    [schnorr][topic schnorr signatures] public key and signature.

    The original version of MuSig required a three round signing protocol:
    first, the co-signers exchange commitments to nonce values, then they
    exchange the nonce values themselves, and finally, they exchange the
    partial signatures. Without this three round protocol, an attacker could
    interact with an honest signer in multiple concurrent signing sessions to
    obtain a signature on a message that the honest signer did not want to sign.

    Using deterministic nonces, which is very common practice in single-signer
    schemes, is unsafe for multi-signer schemes, as described in the [original
    MuSig blog post][musig blog post unsafe deterministic nonce]. Precomputing the
    nonces in advance and exchanging them at key setup time is also unsafe, as
    described in a [blog post by Jonas Nick][unsafe nonce sharing]. It _is_,
    however, safe to precompute the nonces and exchange the nonce commitments
    early, moving one of the three rounds to the key setup stage.

    Removing the requirement to exchange nonce commitments has been an active
    area of research, and last month the [MuSig-DN paper][musig-dn] was published, demonstrating
    how nonce commitment exchange could be removed by generating the nonce
    deterministically from the signers' public keys and the message, and providing a
    non-interactive zero-knowledge proof that the nonce was generated
    deterministically along with the nonce. This removed the requirement of
    exchanging nonce commitments at the cost of a more expensive signing operation.

    The new MuSig2 scheme achieves a simple two round signing protocol without the
    need for a zero-knowledge proof. What's more, the first round (nonce exchange)
    can be done at key setup time, allowing two different variants:

    - interactive setup (key setup and nonce exchange) and non-interactive signing

    - non-interactive setup (address computed from public keys) and interactive
      signing (nonce exchange followed partial signature exchange)

    The non-interactive signing variant could be particularly useful for cold storage
    schemes and offline signers, and also for offchain contract protocols such as LN,
    where the nonces could be exchanged at channel setup time.

- **More LN upfront fees discussion:** after [last week's
  discussion][news119 upfront], Joost Jager asked developers on the
  Lightning-Dev mailing list to again [consider][jager hold fees] how to
  charge fees for attempting to route payments---fees that would have to
  be paid even if the attempt failed.  This could help mitigate both *jamming
  attacks* that can prevent nodes from earning routing fees and *probing
  attacks* that allow third parties to track other people's channel balances.
  Unfortunately, developers have not yet found a satisfactory way to
  trustlessly charge upfront fees, so recent discussion has focused on
  trust-based methods that may involve such small amounts of fee that
  users will find them acceptable.

    Unfortunately, none of the methods discussed this week seemed to
    meet with widespread acceptance.  Several developers expressed
    concern that methods could be abused to penalize small honest nodes.
    Other developers noted that the alternative to upfront payment is
    an increased reliance on reputation---which likely
    disproportionately benefits larger nodes.  We're sure developers will
    continue working on this important issue and we'll report on any
    notable progress in future newsletters.

- **Simplified HTLC negotiation:** Rusty Russell [posted][russell
  simplified] to the Lightning-Dev mailing list about simplifying how
  payments are made and resolved in LN channels.  Currently, both sides
  of a channel can each propose relaying or settling a payment, which
  requires creating or removing an [HTLC][topic htlc] from the offchain
  commitment transaction.  Sometimes both sides propose a change at the
  same time and so there are conflicting commitment transactions.  These
  potential conflicts may get more complicated if dynamic changes to the
  commitment transaction format and settings are allowed (see
  [Newsletter #108][news108 upgrade commitment]).  One proposal to
  eliminate that complication is to only allow dynamic changes when all
  HTLCs have been resolved and the channel is quiet---that improves
  safety but is more restrictive than desired.

    Russell's proposal this week was to allow only one party in
    a channel to propose HTLC changes.  This eliminates the risk of
    conflicting proposals but it increases the average network
    communication overhead by half a round trip (assuming each party
    proposes an equal number of HTLC changes).  Responsibility for
    proposing changes can be transferred from one party to the other as
    needed, allowing each party to propose channel updates at different
    times.

    As of this writing, the proposal received only a small amount of
    discussion from other LN implementation maintainers, so its future
    remains uncertain.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **BlueWallet adds Payjoin:**
  [Payjoin][topic payjoin] support (BIP78) has been added in BlueWallet's latest
  [v5.6.1 release][bluewallet payjoin] for both desktop and mobile.

- **Bitfinex supports wumbo channels:**
  As an [early supporter of Lightning][news77 bitfinex lightning], Bitfinex has
  now [added the ability][bitfinex wumbo blog] to deposit and withdraw large amounts of bitcoin via
  [wumbo (large) LN channels][topic large channels].

- **Esplora C-Lightning plugin released:**
  Luca Vaccaro has released an [initial version][github esplora clnd plugin] of
  an Esplora C-Lightning plugin that fetches Bitcoin data from the [block
  explorer][topic block explorers] instead of a local `bitcoind` node.

- **Coinfloor supports bech32:**
  After recently announcing support for bech32 withdrawal (send) support,
  Coinfloor has now also announced [bech32 deposit (receive) support][coinfloor bech32 blog].

- **Bisq supports bech32:**
  Peer-to-peer Bitcoin exchange software Bisq has implemented bech32 send and
  receive support in the latest [1.4.1 version][bisq bech32].

- **Unchained Capital supports PSBT:**
  In a [blog post][unchained capital psbt blog], Unchained outlines their
  support for [PSBT][topic psbt] and the Coldcard hardware wallet.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19953][] implements [schnorr signature
  verification][topic schnorr signatures] ([BIP340][]), [taproot][topic
  taproot] verification ([BIP341][]), and [tapscript][topic tapscript]
  verification ([BIP342][]).  The new soft fork rules are currently only
  used in the private test mode ("regtest"); they are not
  enforced in mainnet, testnet, or the default signet.  The plan is to
  release the code in Bitcoin Core 0.21.0 and then prepare a subsequent
  release (e.g. 0.21.1) that can begin enforcing the soft fork's new
  rules when an activation signal is detected.  The particular
  activation signal or signals to use are still being discussed in the
  [##taproot-activation][] IRC chatroom ([logs][##taproot-activation
  logs]).

    {% comment %}<!-- $ git diff 450d2b2371...865d2c37e2 | grep '^+' \
                        | grep -v '^+$' | grep -v '^+ */[/*]' | grep -v '^+ *\*' \
                        | grep -v '^+++' | wc -l
                      512
    -->{% endcomment %}

    The code [consists][sipa summary] of about [700 lines][sipa
    consensus] of consensus-related changes (500 excluding comments and
    whitespace) and [2,100 lines][sipa tests] of tests.  Over 30 people
    directly reviewed this PR and its [predecessor][Bitcoin Core
    #17977], and many others participated in developing and reviewing
    the underlying research, the BIPs, the related code in libsecp256k1,
    and other parts of the system.  There is still more work to do, but
    getting the code properly reviewed was arguably the most critical
    step---so we extend our most grateful appreciation to everyone who
    helped achieve this milestone.

- [Bitcoin Core #19988][] redesigns the logic Bitcoin Core uses to
  request transactions from its peers.  The major changes described by
  the PR description include: Bitcoin Core will now more strongly prefer
  requesting transactions from *outbound peers*---peers where the
  connection was opened by the local node; Bitcoin Core will now request
  an unlimited number of transactions from a peer rather than stopping
  at 100 (though slow responders won't be preferred); and Bitcoin Core
  won't keep track of as many pending transaction requests as before,
  the previous limit being seen as excessive.  The change also greatly
  improves the readability of the code and the ability to test that the
  transaction request logic is working as expected.  This testing may
  help reduce the chance that a flaw can be exploited against
  users of time-sensitive transactions (such as in LN and many other
  contract protocols).

- [Bitcoin Core #19077][] wallet: Add sqlite as an alternative wallet database and use it for new descriptor wallets FIXME:dongcarl

- [Bitcoin Core #19770][] deprecates the `whitelisted` field returned from the
  `getpeerinfo` RPC, which previously had its scope expanded by more granular permissioning
  (see [Newsletter #60][news60 permissions]). `whitelisted` is set to be
  deprecated in v0.21 and is planned to be removed in v0.22.

- [Bitcoin Core #17428][] writes a file at shutdown with the network
  addresses of the node's two outbound block-relay-only peers.  The next
  time the node starts, it reads this file and attempts to reconnect to
  those same two peers.  This prevents an attacker from using node
  restarts to trigger a complete change in peers,
  which would be something they could use as part of an [eclipse
  attack][topic eclipse attacks] that could potentially trick
  the node into accepting invalid bitcoins.

- [LND #4688][] adds a new `--duration` parameter that can be used to
  indicate how long until LND stops making additional attempts to send a
  payment.  The default remains 60 seconds.

- [Libsecp256k1 #830][] enables GLV endomorphism, which allows verifying
  signatures with up to 33% fewer operations (see a comment to the PR
  with actual [performance test results][o'beirne bitcoinperf]).  The PR
  also removes the slower code for operating without endomorphism as
  there's no reason to use it now that the patent on the GLV technique
  has expired (see [Newsletter #117][news117 glv]).  This PR also
  implements an independent `memcmp` (memory compare) function to avoid
  the problems with GCC's internal version of that function (see
  [another section][news117 memcmp] in Newsletter #117).  These changes
  were subsequently [pulled][Bitcoin Core #20147] into Bitcoin Core.

{% include references.md %}
{% include linkers/issues.md issues="19953,17977,19988,19077,19770,17428,4688,830,20147" %}
[sipa summary]: https://github.com/bitcoin/bitcoin/pull/19953#issuecomment-691815830
[sipa consensus]: https://github.com/bitcoin/bitcoin/compare/450d2b2371...865d2c37e2
[sipa tests]: https://github.com/bitcoin/bitcoin/compare/206fb180ec...0e2a5e448f426219a6464b9aaadcc715534114e6
[o'beirne bitcoinperf]: https://github.com/bitcoin/bitcoin/pull/20147#issuecomment-711051877
[news108 upgrade commitment]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news117 glv]: /en/newsletters/2020/09/30/#us-patent-7-110-538-has-expired
[news117 memcmp]: /en/newsletters/2020/09/30/#discussion-about-compiler-bugs
[news119 upfront]: /en/newsletters/2020/10/14/#ln-upfront-payments
[jager hold fees]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002826.html
[russell simplified]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002831.html
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[##taproot-activation logs]: http://gnusha.org/taproot-activation/
[musig 2 paper]: https://eprint.iacr.org/2020/1261
[musig blog post unsafe deterministic nonce]: https://blockstream.com/2019/02/18/en-musig-a-new-multisignature-standard/#uniform-randomness
[unsafe nonce sharing]: /en/newsletters/2019/11/27/#schnorr-taproot-updates
[musig-dn]: https://medium.com/blockstream/musig-dn-schnorr-multisignatures-with-verifiably-deterministic-nonces-27424b5df9d6
[composable musig in ln]: /en/newsletters/2019/12/04/#composable-musig
[news60 permissions]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[bluewallet payjoin]: https://github.com/BlueWallet/BlueWallet/releases/tag/v5.6.1
[news77 bitfinex lightning]: /en/newsletters/2019/12/18/#bitfinex-supports-ln-deposits-and-withdrawals
[bitfinex wumbo blog]: https://blog.bitfinex.com/trading/bitfinex-supports-the-lightning-networks-wumbo-channels/
[github esplora clnd plugin]: https://github.com/lvaccaro/esplora_clnd_plugin/releases/tag/v0.1
[coinfloor bech32 blog]: https://coinfloor.co.uk/hodl/2020/10/09/upgrades-to-btc-deposits/
[bisq bech32]: https://github.com/bisq-network/bisq/releases/tag/v1.4.1
[unchained capital psbt blog]: https://unchained-capital.com/blog/now-coldcard/
