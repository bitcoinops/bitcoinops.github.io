---
title: 'Bitcoin Optech Newsletter #221'
permalink: /en/newsletters/2022/10/12/
name: 2022-10-12-newsletter
slug: 2022-10-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal to allow casual LN users
to stay offline for up to several months at a time and describes a document
about allowing transaction information servers to host unused wallet
addresses.  Also included are our regular sections with the summary of a
Bitcoin Core PR Review Club, announcements of new software releases and
release candidates (including a critical LND fix), and descriptions of
notable changes to popular Bitcoin infrastructure software.

## News

- **LN with long timeouts proposal:** John Law [posted][law post] to the
  Lightning-Dev mailing list a [proposal][law pdf] to allow casual
  Lightning users to remain offline for up to several months without
  risk of losing any funds to their channel partners.  Although this is
  technically possible in the current LN protocol, it would depend on
  setting settlement-delay parameters to high values that would allow a
  griefing user or an accident to prevent funds in more than a dozen
  channels from being used for those same months.  Law's proposal mitigates
  that problem through two protocol modifications:

    - *Triggered HTLCs:* a standard [HTLC][topic htlc] used for payment
      has Alice offering Bob some amount of BTC if he's able to publish
      a previously-unknown *preimage* for a known hash digest.
      Alternatively, if Bob doesn't publish the preimage by a certain
      time, Alice is able to spend the money back to her own wallet.

        Law suggests that Bob still be allowed to claim the payment at
        any moment with the publication of the preimage, but Alice would
        need to fulfill an additional restriction.  She would need to
        clearly warn Bob of her intent to spend the money back to her
        wallet by getting a *trigger* transaction confirmed onchain.
        Only when the trigger transaction had been confirmed by a
        certain number of blocks (or for a certain duration of time)
        would Alice be able to spend the money.

        This would ensure Bob was able to claim his funds at any time up
        until the trigger transaction had received the agreed-upon
        number of confirmations, even if months had passed
        since a normal HTLC would've timed out.  If Bob is adequately
        compensated for his waiting, then it's ok if Alice remains
        offline all that time.  For an HTLC routed from Alice through Bob
        onto some distant node, only the channel between Alice and Bob
        would be affected---every other channel would settle the HTLC
        promptly (as in the current LN protocol).

    - *Asymmetric delayed commitment transactions:* each of the two
      partners in an LN channel holds an unpublished commitment
      transaction that they can publish and try to get confirmed at any
      time.  Both versions of the transaction spend the same UTXO, so
      they conflict with each other---meaning only one can actually get
      confirmed.

        This means when Alice wants to close the channel, she can't just
        simply broadcast her version of the commitment transaction with
        a reasonable feerate and assume it will get confirmed.  She also
        has to wait and check whether Bob instead gets his version of
        the commitment transaction confirmed, in which case she may need
        to take additional actions to verify his transaction included the
        latest channel state.

        Law proposes that Alice's version of the commitment transaction
        remain the same as today so that she can publish it at any time,
        but that Bob's version include a time lock so that he can only
        publish it if Alice has been inactive for a long time.  Ideally,
        this allows Alice to publish the latest state secure in the
        knowledge that Bob can't publish a contradictory version,
        allowing her to safely go offline after her publication.

    Law's proposals were still receiving initial feedback as this
    description was being written.

- **Recommendations for unique address servers:** Ruben Somsen
  [posted][somsen post] to the Bitcoin-Dev mailing list a
  [document][somsen gist] with another suggestion for how users can avoid
  [output linking][topic output linking] without trusting a third-party
  service or using an cryptographic protocol that's not currently widely
  supported, like [BIP47][] or [silent payments][topic silent payments].
  The recommended method is especially intended for wallets that are
  already providing their addresses to third parties, such as those that
  use public [address lookup servers][topic block explorers] (which is
  believed to be the majority of lightweight wallets).

    For an example of how the method might work, Alice's wallet
    registers 100 addresses on the Example.com electrum-style server.
    She then includes "example.com/alice" in her email signature.  When
    Bob wants to donate money to Alice, he visits her URL, gets an
    address, verifies that Alice signed it, and then pays to it.

    The idea has the advantage of being widely compatible with many
    wallets through a partly-manual process and possibly easy to
    implement with an automated process.  Its downside is that users who
    are already compromising their privacy by sharing addresses with a
    server will be further committing to the privacy loss.

    Discussion of the suggestions was ongoing on both the mailing list
    and the document at the time this summary was being written.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Make AddrFetch connections to fixed seeds][review club 26114]
is a PR by Martin Zumsande that makes `AddrFetch` connections to
the [fixed seeds][] (hard-coded IP addresses) instead of just adding
them to `AddrMan` (the database of our peers).

{% include functions/details-list.md
  q0="When a new node starts up from scratch, it must first connect
with some peers from whom it will perform Initial Block Download (IBD).
Under what circumstances does it connect to the fixed seeds?"
  a0="Only if it isn't able to connect to peers whose addresses are
provided by the hard-coded Bitcoin DNS seed nodes. This most
commonly occurs when the node is configured to not use IPv4 or IPv6
(for example, `-onlynet=tor`)."
  a0link="https://bitcoincore.reviews/26114#l-27"

  q1="What observable behavior change does this PR introduce?
What kinds of addresses do we add to `AddrMan`, and under what circumstances?"
  a1="The node, rather than immediately adding the fixed seeds to its
`AddrMan` and making full connections to some of them, instead
makes `AddrFetch` connections to some of them,
and adds the _returned addresses_ to `AddrMan`. (`AddrFetch` are
short-term connections that are used only to fetch addresses.)
The node then connects to some of the addresses
now in its `AddrMan` to perform IBD.
This results in fewer full connections
to the fixed-seed nodes; instead, more connections are attempted
from the much larger set of nodes that the fixed-seed nodes
tell us about. `AddrFetch` connections can return _any_ type
of addresses, for example, `tor`; the results are not limited to
IPv4 and IPv6."
  a1link="https://bitcoincore.reviews/26114#l-63"

  q2="Why might we want to make an `AddrFetch` connection instead
of a full outbound connection to fixed seeds?
Why might the node operator behind a fixed seed prefer this as well?"
  a2="An `AddrFetch` connection allows our node to choose
IBD peers from a much larger set of peers, which increases
overall network connectivity distribution. The fixed seed node
operators would be less likely to have multiple simultaneous IBD peers,
which reduces the resource requirements on their nodes."
  a2link="https://bitcoincore.reviews/26114#l-77"

  q3="The DNS seed nodes are expected to be responsive and serve
up-to-date addresses of Bitcoin nodes. Why doesn’t this help
a -onlynet=tor node?"
  a3="The DNS seed nodes provide only IPv4 and IPv6 addresses;
they're not able to supply any other type of address."
  a3link="https://bitcoincore.reviews/26114#l-35"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.15.2-beta][] is a security critical emergency release that
  fixes a parsing error that prevented LND from being able to parse
  certain blocks.  All users should upgrade.

- [Bitcoin Core 24.0 RC1][] is the first release candidate for the
  next version of the network's most widely used full node
  implementation.  A [guide to testing][bcc testing] is available.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #6500][] Adds the ability to encrypt the Tor private key on disk
  using the wallet's private key instead of storing it in plaintext.
  Using the flag, `--tor.encryptkey`, LND encrypts the private key and the
  encrypted blob is written to the same file on disk, allowing users to
  still keep the same functionality (like refreshing a hidden service),
  but adds protection when running in untrusted environments.

{% include references.md %}
{% include linkers/issues.md v=2 issues="6500" %}
[review club 26114]: https://bitcoincore.reviews/26114
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[law post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003707.html
[law pdf]: https://raw.githubusercontent.com/JohnLaw2/ln-watchtower-free/main/watchtowerfree10.pdf
[somsen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020952.html
[somsen gist]: https://gist.github.com/RubenSomsen/960ae7eb52b79cc826d5b6eaa61291f6
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[lnd v0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[fixed seeds]: https://github.com/bitcoin/bitcoin/tree/master/contrib/seeds
