---
title: 'Bitcoin Optech Newsletter #67'
permalink: /en/newsletters/2019/10/09/
name: 2019-10-09-newsletter
slug: 2019-10-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests help testing release candidates for
Bitcoin Core and LND, tracks continued discussion about the proposed
noinput and anyprevout sighash flags, and describes several notable
changes to popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test Bitcoin Core 0.19.0rc1:** production users of Bitcoin Core
  are especially encouraged to test this [latest release candidate][core
  0.19.0] to ensure that it fulfills all of your organization's needs.
  Experienced users who plan to test are also asked to take a few
  moments to test the GUI and look for problems that might
  disproportionately affect less-experienced users who don't normally
  participate in RC testing.

- **Help test LND 0.8.0-beta-rc2:** experienced users of LND are
  encouraged to [help test][lnd 0.8.0-beta] the next release.  For the
  first time ever, this testing can include creating a [reproducible
  build][lnd repo build] of LND and verifying that it has the same hash
  as the binaries distributed by the LND developers.


## News

- **Continued discussion about noinput/anyprevout:** this proposed
  sighash flag that would allow LN implementations to use [eltoo][] was
  [discussed][noinput thread] again on the Bitcoin-dev and Lightning-dev mailing lists.
  After summarizing previous discussions, Christian Decker asked several
  questions: is the idea behind the proposal useful?  (Respondents seemed
  to agree that it was.)  Do people want mandatory chaperon signatures?
  (Respondents seemed moderately opposed.)  Do people want mandatory output
  tagging?  (Respondents seemed opposed, some strongly.)

    In response to the question about output tagging, C-Lightning
    contributor ZmnSCPxj [proposed][zmn internal tagging] an alternative
    tagging mechanism that would put the tag inside the taproot
    commitment, making it invisible unless a script-path spend was used.
    This could allow a spender who was worried about noinput to ensure
    they didn't pay noinput-compatible scripts---the [original goal][orig
    output tagging] behind output tagging---but without the decrease in
    privacy and fungibility created by output tagging.  Several people
    seemed to express interest in this idea, although it wasn't clear
    whether they wanted to see it as part of a proposal or they just
    preferred it to external output tagging (which, as noted above, was
    generally opposed by respondents).

    The entire thread is more than 20 messages at present and started a
    [spin-off discussion about `OP_CAT`][cat spinoff].  Hopefully the
    discussion will be able to settle the major unresolved issues
    related to noinput and help get this proposal on track for
    inclusion in a subsequent soft fork.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #13716][] adds `-stdinrpcpass` and
  `-stdinwalletpassphrase` parameters to
  `bitcoin-cli` that allow it to read either an RPC or wallet
  passphrase from the standard input buffer rather than as a CLI
  parameter that would be stored in shell history.  Echoing is also
  disabled on stdin during reading so that the passphrase isn't visible
  to anyone watching your screen.

- [Bitcoin Core #16884][] switches the default address type
  for users of the RPC interface (including via `bitcoin-cli`) from
  P2SH-wrapped P2WPKH to native segwit (bech32) P2WPKH.  This change is on the
  master development code branch and is not expected to be released
  until Bitcoin Core 0.20.0 sometime in mid-2020.  However, a [previous
  change][gui bech32] expected to be released as part of 0.19.0 in the
  next month or so will switch the default address type for GUI users to
  also use bech32 P2WPKH.

- [Bitcoin Core #16507][] fixes a [rounding issue][bitcoin core #16499] where a
  node would accept transactions into its mempool if they had a
  feerate greater than the node's dynamic minimum feerate but wouldn't
  relay those transactions to peers if the transactions' feerates were
  less than minimum rounded up to next 0.00001000 BTC.

- [LND #3545][] adds code and [documentation][lnd repo doc] that allows
  users to create reproducible builds of LND.  This should allow anyone with
  moderate technical skills to build identical binaries to those
  released by Lightning Labs, ensuring that users are running the
  peer-reviewed code from the LND repository and its dependencies.

- [LND #3365][] adds support for using `option_static_remotekey`
  commitment outputs as described [later in this section][opt static
  remotekey].
  This new commitment protocol is particularly useful when something has
  gone wrong and you've lost data.  If that happens, you need only wait
  for your channel counterparty to close the channel by paying a key
  directly derived from your HD wallet.  Because the key was generated
  without any additional data ("tweaking"), your wallet doesn't need any
  extra data in order to find and spend your funds.  This is a simplified
  alternative to the [data loss protection][] protocol that LND
  previously used and continues to understand.

- [C-Lightning #3078][] adds support for creating and using channels
  that spend Liquid-BTC on the Liquid sidechain.

- [C-Lightning #2803][] adds a new python package named `pyln` that
  includes a partial implementation of the LN specification.  As
  described in its [documentation][pyln-proto readme], "This package
  implements some of the Lightning Network protocol in pure python. It
  is intended for protocol testing and some minor tooling only. It is
  not deemed secure enough to handle any amount of real funds (you have
  been warned!)."

- [C-Lightning #3062][] causes the `plugin` command to return an error if a
  requested plugin hasn't reported successful startup within 20 seconds.

- [BOLTs #676][] amends [BOLT2][] to specify that a node should not send
  the `funding_locked` message until it has validated the funding
  transaction.  This warns future implementers about the problem that
  lead to the vulnerabilities [described in last week's newsletter][ln
  vuln disclosure].

- [BOLTs #642][] allows two peers opening a channel to negotiate an
  `option_static_remotekey` flag.  If both peers set this flag, any
  commitment transactions they create which they're able to spend
  unilaterally (e.g. to force close the channel) must pay their peer's
  funds to a static address negotiated during the initial channel open.
  For example, if Alice has the address `bc1ally`, Bob has the address
  `bc1bob`, and they both request `option_static_remotekey`,
  any commitment transactions that Alice can publish onchain must pay
  `bc1bob` and any commitment transactions that Bob can publish
  onchain must pay `bc1ally`.  If at least one of them doesn't set
  this flag, they'll fall back to the older protocol of using a different
  payout address for each commitment transaction, with the addresses
  created by combining the remote peer's pubkey with a commitment
  identifier.

    Always paying the same address allows that address to be a normal
    derivable address in the client's HD wallet, making it possible for
    the user to recover their funds even if they've lost all of their
    state besides their HD seed.  This is believed to be superior to the
    [data loss protection][] protocol which depends on storing enough
    state to be able to at least contact the remote peer and identify
    the channel.  With `option_static_remotekey`, it can be assumed that
    the remote peer will eventually get tired of waiting for a missing
    peer to show up and will unilaterally close the channel, putting the
    funds onchain in an address where your HD wallet will find them.

{% include linkers/issues.md issues="13716,16884,16507,16499,3545,3365,3078,2803,3062,676,642" %}
[lnd repo doc]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[lnd 0.8.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.0-beta-rc2
[lnd repo build]: #lnd-3545
[noinput thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002176.html
[cat spinoff]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002201.html
[ln vuln disclosure]: /en/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[data loss protection]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[pyln-proto readme]: https://github.com/ElementsProject/lightning/blob/master/contrib/pyln-proto/README.md
[opt static remotekey]: #bolts-642
[zmn internal tagging]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002180.html
[gui bech32]: /en/newsletters/2019/04/16/#bitcoin-core-15711
[orig output tagging]: /en/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
