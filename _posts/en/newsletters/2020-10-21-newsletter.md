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

- MuSig2 FIXME:jnewbery

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

FIXME:bitschmidty

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

- [Bitcoin Core #19770][] RPC: getpeerinfo: Deprecate "whitelisted" field (replaced by "permissions") FIXME:bitschmidty

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

