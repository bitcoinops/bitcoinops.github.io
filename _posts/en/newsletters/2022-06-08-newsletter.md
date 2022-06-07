---
title: 'Bitcoin Optech Newsletter #203'
permalink: /en/newsletters/2022/06/08/
name: 2022-06-08-newsletter
slug: 2022-06-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with the summary of
a Bitcoin Core PR Review Club meeting, a list of new software releases
and release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

*No significant news this week.*

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Miniscript support in Output Descriptors][reviews 24148] is a PR authored by
Antoine Poinsot and Pieter Wuille to introduce watch-only support for
[Miniscript][topic miniscript] in [descriptors][topic descriptors].
Participants reviewed the PR over two meetings. Topics of discussion included
the uses of Miniscript, considerations for malleability, and the implementation
of the descriptor parser.

{% include functions/details-list.md

  q0="Which types of analysis enabled by Miniscript would be helpful for which
  use cases or applications?"
  a0="Several use cases and types of analysis were discussed. Miniscript enables
  analysis of the maximum witness size and thus the 'worst case' cost to spend the
  output at a given feerate. Predictable transaction weights help L2 protocol
  developers write more reliable fee-bumping mechanisms. Additionally, given some
  policy, the compiler generates a minimal Miniscript script (not necessarily the
  smallest possible, since Miniscript only encodes a subset of all scripts), which
  may be smaller than a hand-crafted one. Participants noted that Miniscript has
  helped optimize LN templates in the past. Finally, composition allows multiple
  parties to combine complex spending conditions and guarantee the resulting
  script's correctness without fully understanding all of them."
  a0link="https://bitcoincore.reviews/24148#l-41"

  q1="Miniscript expressions can be represented as trees of nodes, where each
  node represents a fragment. What does it mean when a node is “sane” or “valid”?
  Do they mean the same thing?"
  a1="Each node has a fragment type (e.g. `and_v`, `thresh`, `multi`, etc.) and
  arguments. A valid node's arguments match what the fragment type expects. A sane
  node must be valid and its script semantics must match its policy, be
  consensus-valid and standardness-compliant, only have non-malleable solutions,
  not mix timelock units (i.e. use both block height and time), and not have
  duplicate keys. As defined, these two properties are not identical; every sane
  node is valid, but not every valid node is sane."
  a1link="https://bitcoincore.reviews/24148#l-107"

  q2="What does it mean for an expression to be non-malleably satisfiable? After
  segwit, why do we still need to worry about malleability?"
  a2="A script is malleable if a third party (i.e. someone who doesn't have
  access to the corresponding private keys, among other assumptions) can modify it
  and still satisfy the spending condition(s). Segwit didn't remove the
  possibility of transaction malleation; it ensured that transaction malleation
  wouldn't break the validity of unconfirmed descendants, but malleability can
  still be problematic for other reasons. For example, if an attacker can stuff
  extra data into the witness and still satisfy the spending conditions, they can
  lower the transaction's feerate and negatively impact its propagation. A
  'non-malleably satisfiable expression' does not give third parties such options
  to modify an existing satisfaction into another valid satisfaction. A more
  complete answer can be found [here][sipa miniscript]."
  a2link="https://bitcoincore.reviews/24148#l-170"

  q3="Which function is responsible for parsing the output descriptor strings?
  How does it determine whether the string represents a `MiniscriptDescriptor`?
  How does it resolve a descriptor that can be parsed in multiple ways?"
  a3="The function `ParseScript` in script/descriptor.cpp is responsible for
  parsing output descriptor strings. It tries all other descriptor types first,
  and then calls `miniscript::FromString` to see if the string is a valid
  Miniscript expression. Due to this order of operations, descriptors that can be
  interpreted as both miniscript and non-miniscript (e.g. `wsh(pk(...))`) are
  parsed as non-miniscript."
  a3link="https://bitcoincore.reviews/24148-2#l-30"

  q4="When choosing between two available satisfactions, why should the one that
  involves fewer signatures, rather than the one which results in a smaller
  script, be preferred?"
  a4="Third parties attempting to malleate a transaction (i.e. without access to
  private keys) can remove signatures, but not create new ones. Choosing the
  satisfaction with additional signatures leaves the option for a third
  party to malleate the script and still satisfy the spending conditions.  For
  example, the policy `or(and(older(21), pk(B)), thresh(2, pk(A), pk(B)))` has two
  spending paths: it can always be spent when both A and B sign, or after 21
  blocks when just B signs. After 21 blocks, both satisfactions are available, but
  if a transaction with both A and B's signatures is broadcast, a third party
  could remove A's signature and still satisfy the other spending path. On the
  other hand, if the broadcasted transaction only contains B's signature, the
  attacker cannot satisfy the other spending condition unless it forges A's
  signature."
  a4link="https://bitcoincore.reviews/24148-2#l-106"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.0-beta.rc4][] is a release candidate for the next major
  version of this popular LN node.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24408][] adds an RPC to fetch mempool transactions
  spending from a given outpoint, streamlining the search for
  outpoints by selecting transactions individually rather than from
  a list of txids retrieved from `getrawmempool`. This is useful in
  Lightning when locating a spending transaction after a channel
  funding transaction has been spent or examining why an [RBF][topic rbf]
  transaction failed to broadcast by fetching the conflicting
  transaction.

- [LDK #1401][] adds support for zero-conf channel opens.  For related
  information, please see the summary of BOLTs #910 below.

- [BOLTs #910][] updates the LN specification with two changes.  The
  first allows Short Channel Identifier (SCID) aliases which can improve
  privacy and also allow referencing a channel even when its txid is
  unstable (i.e., before its deposit transaction has received a reliable
  number of confirmations).  The second specification change adds an
  `option_zeroconf` feature bit that may be set when a node is willing
  to use [zero-conf channels][topic zero-conf channels].

{% include references.md %}
{% include linkers/issues.md v=2 issues="24408,1401,910" %}
[lnd 0.15.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc4
[reviews 24148]: https://bitcoincore.reviews/24148
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
