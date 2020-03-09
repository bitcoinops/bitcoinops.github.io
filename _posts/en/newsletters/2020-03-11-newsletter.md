---
title: 'Bitcoin Optech Newsletter #88'
permalink: /en/newsletters/2020/03/11/
name: 2020-03-11-newsletter
slug: 2020-03-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a description of methods for preventing
hardware wallets from leaking private information through transaction
signatures and provides an update on the BIP322 generic signmessage
protocol.  Also included are our regular sections about new releases and
notable merges of popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Exfiltration resistant nonce protocols:** Pieter Wuille sent an
  [email][wuille overview] to the Bitcoin-Dev mailing list providing an
  overview of techniques that can prevent a hardware wallet or other
  offline signing device from communicating secret information to a
  third party by biasing the ECDSA or schnorr signatures it creates.
  The email is clearly written and packed with information.  Anyone with
  an interest in secure use of external signers should consider reading
  it.

- **BIP322 generic signmessage---progress or perish:** [BIP322][] author
  Karl-Johan Alm noted that his PR to add support for the [generic
  signmessage protocol][topic generic signmessage] has not see any
  progress towards getting merged for the past several months.  He's
  [seeking feedback][alm feedback]---including "unfiltered
  criticism"---about whether to take a different approach or to simply
  abandon the proposal.  As we've mentioned [previously][segwit
  signmessage], there is currently no widely adopted way for wallets to
  create and verify signed messages for anything besides legacy P2PKH
  addresses.  If wallet developers want to enable this capability for
  P2SH, P2WPKH, P2WSH, and (if taproot is activated) P2TR addresses,
  they are recommended to review Alm's email and provide feedback on
  their preferred path forward.

## Bitcoin Core PR Review Club

The [Bitcoin Core PR Review Club][] is a weekly IRC meeting for newer
contributors to the Bitcoin Core project to learn about the review process. An
experienced Bitcoin Core contributor provides background information about a
selected PR and then leads a discussion on IRC.

The Review Club is an excellent way to learn about the Bitcoin protocol, the
Bitcoin Core reference implementation, and the process of making changes to
Bitcoin. Notes, questions and meeting logs are posted on the website for those
who are unable to attend in real time, and as a permanent resource for those
wishing to learn about the Bitcoin Core development process.

In this section, we summarise a recent Review Club meeting.

- **[Try to preserve outbound block-relay-only connections during restart][review club 17428]:**
  This PR ([#17428][Bitcoin Core #17954]) by Hennadii Stepanov adds the concept
  of _anchor connections_ to Bitcoin Core, which the node will preferably try to
  reconnect to between restarts. These persistent connections could mitigate some
  classes of [eclipse attacks][topic eclipse attacks].

    Discussion began by establishing some fundamental concepts of eclipse attacks ("Can
    someone give a quick explanation of what an eclipse attack is?" _answer: when a
    node is isolated from all honest peers_; "can someone describe how an adversary
    would eclipse a node?" _answer: fill up their address list with addresses the
    attacker owns, then force them to restart or wait for them to restart_; and "if
    a node is eclipsed, what sort of attacks can an adversary execute on the
    victim?" _answer: withholding blocks, censoring transactions, and
    de-anonymizing transaction sources_) before moving on to analyzing the changes
    in the PR ("how does this PR mitigate an eclipse attack?" _answer: by keeping a
    list of some of the nodes you were connected to (anchor connections) and then
    reconnecting to them on restart_; and "what are the conditions for a peer to
    become and anchor?" _answer: the peer must be a blocks-only peer_.)

    Later in the meeting, there was discussion about the trade-offs and design
    decisions in the PR ("why are only blocks-only peers used as anchors?" _answer:
    to make network topology inference harder and preserve network privacy_; and
    "what happens if you choose an anchor who is able to remote-crash your node?"
    _answer: the malicious peer would be able to repeatedly crash your node on
    restart_.)

    Several attendees at the Review Club meeting left comments on the original PR,
    where discussion on design decisions continues.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.19.1][] was released with several bug fixes; see the
  [release notes][bitcoin core 0.19.1 notes] for details.  <!-- FIXME:confirm_release -->

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #1323][] allows nodes to advertise that they'll accept channel
  opens with a value higher than the previous limit of about 0.168 BTC.
  They do this by using the new `option_support_large_channel` feature
  in the `init` message, which was recently [added to BOLT 9][merged
  large_channel].  Supporting channel capacities larger than 0.168 BTC
  is part of the feature set known informally as "wumbo".  See
  [Newsletter #22][news22 wumbo] for details.

{% include references.md %}
{% include linkers/issues.md issues="1323,17954" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[bitcoin core 0.19.1 notes]: https://bitcoincore.org/en/releases/0.19.1/
[wuille overview]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017667.html
[alm feedback]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017668.html
[segwit signmessage]: /en/bech32-sending-support/#message-signing-support
[merged large_channel]: /en/newsletters/2020/02/26/#bolts-596
[news22 wumbo]: /en/newsletters/2018/11/20/#wumbo
[Bitcoin Core PR Review Club]: https://bitcoincore.reviews
[review club 17428]: https://bitcoincore.reviews/17428
