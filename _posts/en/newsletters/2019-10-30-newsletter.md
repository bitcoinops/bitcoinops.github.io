---
title: 'Bitcoin Optech Newsletter #70'
permalink: /en/newsletters/2019/10/30/
name: 2019-10-30-newsletter
slug: 2019-10-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the latest C-Lightning release,
requests help testing a Bitcoin Core release candidate,
describes discussions about simplified LN commitments using CPFP
carve-out, and summarizes several top-voted questions and answers from
the Bitcoin Stack Exchange.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade to C-Lightning 0.7.3:** this latest [release][c-lightning
  0.7.3] adds support for a PostgreSQL backend, makes it possible to
  send funds directly to a particular address when closing a channel,
  and allows you keep your HD wallet seed encrypted when `lightningd`
  isn't running---plus many other features and several bug fixes.

- **Help test Bitcoin Core release candidate:** experienced users are encouraged to
  help test the latest release candidates for the upcoming version of
  [Bitcoin Core][Bitcoin Core 0.19.0].

## News

- **LN simplified commitments:** in two separate threads, developers
  of LND discussed their work on implementing simplified commitments,
  which are LN settlement transactions that only pay a minimal onchain
  transaction fee and which contain two additional outputs (one for each
  party).  The idea is to allow either party to choose what transaction
  fee they want to pay at the time the transaction is broadcast, which
  they can do using Child-Pays-For-Parent (CPFP) fee bumping from their
  individual output.  Although this has been discussed in the past, it
  was vulnerable to an attack that is expected to be resolved by the
  inclusion of CPFP carve-out in the upcoming Bitcoin Core version
  0.19.0 (see [Newsletter #56][pr15681]).

  In the first thread, Johan Halseth posted an [email][halseth
  carve-out] about loosening mempool policy in order to make
  simplified commitments even simpler.  This received several
  objections on the basis that a slight change wouldn't be effective
  and too much change would put the network at risk of
  bandwidth-wasting attacks.  However, this discussion (and a separate
  [discussion][rubin justification] started on the #bitcoin-core-dev
  IRC channel by Jeremy Rubin) revealed that many developers wanted to
  gain a better understanding of the current rules and how they might
  be improved.  A good outline of the subject was sourced from a
  presentation given by Suhas Daftuar that has now been converted into
  a [wiki page][daftuar duo].

  In the second thread, Joost Jager [resumed][anchor thread] an old
  thread started by Rusty Russell with a proposed specification for
  simplified commitments (see [Newsletter #23][opt_simplified]).
  Based on the upcoming carve-out feature and other developments in
  LN, Jager makes several suggestions, including: using the name
  "anchor output" for the outputs meant to be spent with CPFP; using
  an additional set of pubkeys for the anchors to ease splitting
  responsibilities between cold and hot wallets; and using static keys
  to simplify backup recovery.  He subsequently opened a [PR][BOLTs
  #688] to the BOLTs repository to add simplified commitments to the
  LN protocol specification.

- **Publication of videos and study material from schnorr/taproot workshop:**
  Optech published a [blog post][taproot workshop] with links to videos, Jupyter
  notebooks, GitHub repositories, and more information produced for the
  schnorr and taproot workshops held in San Francisco and New York
  City last month.  These explain the fundamentals of both proposals,
  guide students through actually using them, and then describe strategies
  for making optimal use of the features they add to Bitcoin.

  All developers interested in these features which may be added to
  Bitcoin in the future are encouraged to review the study material,
  especially developers participating in the [taproot review][]
  described in [last week's newsletter][tr].

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why does hashing public keys not actually provide any quantum resistance?]({{bse}}91049)
  Andrew Chow lists several considerations regarding public keys and quantum
  resistance, including: the need to reveal the public key during spending, the
  large number of bitcoins in outputs with known public keys, and numerous ways
  which public keys are exposed outside of just transacting due to not currently
  being treated as secrets.

- [Will schnorr multi-signatures completely replace ECDSA?]({{bse}}90855)
  Ugam Kamat explains how the proposed addition of schnorr signatures in
  segwit v1 does not remove the need for ECDSA. ECDSA is required to spend
  non-segwit as well as segwit v0 outputs.

- [Why doesn't RBF include restrictions on the outputs?]({{bse}}90858)
  Andrew Chow gets into some of the design choices in [BIP125][] Opt-in Replace
  by Fee (RBF) and compares it to the First Seen Safe Replace by Fee (FSS-RBF)
  approach. Chow notes the drawbacks of FSS-RBF but also warns against the
  acceptance of any unconfirmed transaction.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17165][] removes support for the [BIP70][] payment
  protocol.  This change has only been made on the master development
  branch and will probably not be released until version 0.20, expected
  about six months from now.  BIP70 was made optional in [version
  0.18.0][core 0.18.0] and will be disabled by default in the upcoming
  0.19.0; see [Newsletter #19][pr14451] for more information.

  This is the last significant feature in Bitcoin Core to depend on
  OpenSSL, and a [PR][Bitcoin Core #17265] has been opened to complete
  the removal of that dependency.  OpenSSL has been the source of
  previous vulnerabilities in Bitcoin Core (e.g. [Heartbleed][] and
  [non-strict signature encoding][ber]) and much effort over the past
  five-plus years has been invested into eliminating it as a
  dependency.

{% include linkers/issues.md issues="17165,17265,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3
[tr]: https://github.com/ajtowns/taproot-review
[tr rsvp]: https://forms.gle/iiPaphTcYC5AZZKC8
[core 0.18.0]: https://bitcoincore.org/en/releases/0.18.0/#build-system-changes
[pr14451]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[ber]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[pr15681]: /en/newsletters/2019/07/24/#bitcoin-core-15681
[opt_simplified]: /en/newsletters/2018/11/27/#simplified-fee-bumping-for-ln
[anchor thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002249.html
[halseth carve-out]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002240.html
[daftuar duo]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Mempool-and-mining
[rubin justification]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-10-24.html#l-660
[taproot workshop]: /en/schorr-taproot-workshop/
[taproot review]: https://github.com/ajtowns/taproot-review
[tr]: /en/newsletters/2019/10/23/#taproot-review
