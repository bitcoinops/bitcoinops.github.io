---
title: 'Bitcoin Optech Newsletter #190'
permalink: /en/newsletters/2022/03/09/
name: 2022-03-09-newsletter
slug: 2022-03-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes multiple facets of a discussion about
how much future soft forks should increase the expressiveness of
Bitcoin's Script and Tapscript languages and summarizes a proposal to
charge for bandwidth used relaying onion messages.  Also included are
our regular sections with the summary of a Bitcoin Core PR Review Club
meeting, announcements of new software releases and RCs, and descriptions
of notable changes to popular Bitcoin infrastructure projects.

## News

- **Limiting Script language expressiveness:** on the Bitcoin-Dev
  mailing list, several sub-discussions were started out of the
  proposals to add `OP_TXHASH` or `OP_TX` opcodes to Script (see
  Newsletters [#185][news185 optxhash] and [#187][news187 optx]).
  Jeremy Rubin had [noted][rubin recurse] that the proposals (possibly
  in combination with other opcode proposals, like [OP_CAT][]) might
  allow the creation of recursive [covenants][topic
  covenants]---conditions that would need to be fulfilled in every
  transaction re-spending those bitcoins or any bitcoins merged with it
  for perpetuity.  It was [asked][harding recurse] whether anyone
  had concerns about allowing recursive covenants in Bitcoin, with some
  of the most notable concerns being summarized below:

    - *Gradual loss of censorship resistance:* contributor Shinobi
      [posted][shinobi recurse] a repeat of his concerns previously
      mentioned in [Newsletter #157][news157 csfs] about recursive
      covenants that gave a powerful third party control over subsequent
      spending of any coins that the entity currently controlled.  For
      example, a government could require (by law) that its populace
      only accept coins that the government could later seize (as
      enforced by Bitcoin consensus rules).

        [Replies][aj reply] to Shinobi's post [echoed][darosior reply]
        arguments from [a year ago][harding altcoin] about the same
        gradual loss of censorship resistance also being possible by
        users switching to an alternative cryptocurrency (altcoin) or
        sidechain-like construct with the same requirement for
        third-party control.

    - *Encouraging unnecessary computation:* developer James O'Beirne
      [expressed][obeirne reply] concern that the addition of too much
      expressiveness to Bitcoin's Script or [Tapscript][topic tapscript]
      languages would encourage the creation of scripts that used more
      than the minimum number of operations necessary to prove someone
      authorized to spend a coin had chosen to spend that money.
      Ideally, any UTXO (coin) can be spent today using a single compact
      proof that the spend was authorized, such as a 64-byte [schnorr
      signature][topic schnorr signatures].  Bitcoin already allows more
      complex scripts to enable the creation of contracts, such as
      multisignature compacts and protocols like LN, but this capability
      can be abused to include operations in scripts that aren't
      necessary to enforce the terms of a contract.  For example,
      Bitcoin has in the past been at [risk][cve-2013-2292] of
      denial-of-service attacks from specially-designed transactions
      that repeatedly performed operations requiring much CPU or memory.
      O'Beirne worries increased expressiveness could both create new
      DoS vectors as well as result in programmers creating unoptimized
      scripts that use more node resources than necessary.

    - *Introduction of turing completeness:* developer ZmnSCPxj
      [criticized][zmn turing] the addition of opcodes that allow the
      creation of *deliberate* recursive covenants as also allowing the
      *accidental* creation of recursive covenants.  Money paid into
      recursive covenants, whether deliberately or accidentally, would
      never again be fully fungible with ordinary bitcoins.  ZmnSCPxj
      phrased this concern in context of [turing completeness][] and the
      [halting problem][].

    - *Enablement of drivechains:* extending his previous argument about
      turing completeness, ZmnSCPxj further [argues][zmn drivechains]
      that increased Script language expressiveness would also enable
      the implementation of [drivechains][topic sidechains] similar in
      principle to that specified in [BIP300][], which several Bitcoin
      developers have [argued][towns drivechains] could lead to either a
      loss of user funds or a reduction in censorship resistance.  Users
      of a drivechain could lose funds if not enough of the Bitcoin
      economy chose to run full nodes enforcing the drivechain's
      rules---but if a large part of the economy did choose to enforce a
      drivechain's rules, all other users wanting to remain in consensus
      would need to validate all of that drivechain's data, effectively
      making the drivechain part of Bitcoin without there ever being an
      explicit soft fork decision to modify Bitcoin's rules.

        This particular sub-thread received extended discussion and
        produced a [spin-off thread][drivechains vs ln] comparing
        drivechain security to LN security in the presence of a majority
        of mining hashrate attempting to steal bitcoins.

- **Paying for onion messages:** Olaoluwa Osuntokun [posted][osuntokun
  bandwidth] to the Lightning-Dev mailing list this week about adding
  the ability for nodes to pay for the bandwidth they use sending [onion
  messages][topic onion messages].  The previously-proposed onion
  messages protocol allows one node to send a message to another node
  routed through an LN path without using an [HTLC][topic htlc].  The
  main advantage of onion messages over HTLCs for keysend-style messages
  is that onion messages don't require temporarily locking up any
  bitcoins, making them more cost efficient and more flexible (e.g.,
  onion messages can be sent between peers even when they don't share a
  channel).  However, the lack of direct financial cost in sending onion
  messages also makes some developers concerned that they'll be used to
  relay traffic over LN for free, making it more expensive to operate an
  LN node and creating an incentive for large numbers of nodes to
  disable onion message relay.  This could become especially problematic
  if onion messages are used for important communication between nodes,
  such as proposed for [offers][topic offers].

    Osuntokun suggested that nodes could pre-pay for the onion message
    bandwidth they wanted to use.  For example, if Alice wants to route
    10 kB of data to Zed through Bob and Carol, she will first use
    [AMP][topic amp] to pay Bob and Carol for at least 10 kB of
    bandwidth at the message relay rates advertised by their respective
    nodes.  When paying Bob and Carol, Alice registers a unique session
    ID with each of them and includes that ID in the encrypted messages
    she asks them to relay for her.  If the amount Alice has paid is
    sufficient for the bandwidth her messages use, Bob and Carol
    participate in relaying the messages to Zed.

    Rusty Russel [replied][russell reply] with several criticisms, most
    notably:

    - *HTLCs are already currently free:* the main counterargument
      against the concern about free onion message relay has always been
      that it's already possible to use HTLCs to relay traffic over LN
      essentially for free.[^htlcs-essentially-free]  It's unclear,
      though, whether this will remain the case permanently---many
      proposals to fix [channel jamming attacks][topic channel jamming
      attacks] suggest charging for the failed HTLCs which can be used
      to freely route data today.

    - *Session identifiers reduce privacy:* in the previous example, the
      session identifiers Alice registers with Bob and Carol allow them
      to know which messages came from the same user.  If instead there
      had been no session ID, they wouldn't know whether the different
      messages had all come from the same user or different users all
      using parts of the same route.  Russell noted that he'd considered blinded
      tokens when working on onion messages, but he was concerned that
      it "gets complex fast".

  Russell instead suggested simply rate limiting the number of onion
  messages a node forwards (with different limits from different
  categories of peers).

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:glozow

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/#FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.105][] adds support for phantom node payments (see
  [Newsletter #188][news188 phantom]) and better probabalistic payment
  pathfinding (see [Newsletter #186][news186 pp]), in addition to
  providing a number of other features and bug fixes (including [two
  potential DoS vulnerabilities][rl dos]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23542][] removes Bitcoin Core's preference to only
  connect to peers on the default Bitcoin port (8333 for mainnet).
  Instead, Bitcoin Core will open connections to peers on any port
  except for a few dozen ports known to be used by other services.  Port
  8333 is still the default port Bitcoin Core binds to locally, so only
  nodes which override the default will advertise that they accept
  connections on other ports.  Some additional information about this
  change may be found in the *Bitcoin Core PR Review Club* summary
  earlier in this newsletter.

- [BDK #537][] refactors wallet address caching into a public method.
  Previously, the only way to ensure that a wallet’s internal database
  had addresses loaded and cached was through an internal function---meaning
  that an offline wallet had no mechanism to ensure that the database had
  addresses loaded. This patch enables use cases like offline wallets being
  used as a multisig signer and validating change addresses. Relatedly,
  [BDK #522][] adds an API for internal addresses, which is useful for
  applications to create a transaction that splits an output into several
  smaller ones.

## Footnotes

[^htlcs-essentially-free]:
    When user Alice relays an HTLC-based keysend message to user Zed
    through routing nodes Bob and Carol, Alice can construct the HTLC
    with a hash with no known preimage, guaranteeing it will fail and so
    neither Bob nor Carol will receive any money.  The only costs Alice
    bears for sending such a message are the costs of creating the
    channel (if she created it) and for later closing it (if she's
    responsible for paying those costs)---plus the risk that an attacker
    will either steal the private key for her LN hot wallet or any of
    the other data that could compromise her LN channels.  For a secure
    and bug-free node with long-lived channels, these costs should be
    essentially zero, and so HTLC-based keysend messages can be
    currently considered to be free.

{% include references.md %}
{% include linkers/issues.md v=1 issues="23542,522,537" %}
[ldk 0.0.105]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.105#security
[news185 optxhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news187 optx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[rubin recurse]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019872.html
[op_cat]: /en/topics/op_checksigfromstack/#relationship-to-op_cat
[shinobi recurse]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019891.html
[news157 csfs]: /en/newsletters/2021/07/14/#request-for-op-checksigfromstack-design-suggestions
[darosior reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019892.html
[aj reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019923.html
[harding altcoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019203.html
[obeirne reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019890.html
[cve-2013-2292]: /en/topics/cve/#CVE-2013-2292
[zmn turing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019928.html
[zmn drivechains]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019976.html
[turing completeness]: https://en.wikipedia.org/wiki/Turing_completeness
[halting problem]: https://en.wikipedia.org/wiki/Halting_problem
[towns drivechains]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019984.html
[drivechains vs ln]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019991.html
[osuntokun bandwidth]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003498.html
[russell reply]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003499.html
[harding recurse]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019885.html
[rl dos]: https://github.com/lightningdevkit/rust-lightning/blob/main/CHANGELOG.md#security
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[news186 pp]: /en/newsletters/2022/02/09/#ldk-1227
