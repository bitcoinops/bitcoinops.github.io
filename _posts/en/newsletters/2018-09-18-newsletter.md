---
title: 'Bitcoin Optech Newsletter #13'
permalink: /en/newsletters/2018/09/18/
name: 2018-09-18-newsletter
slug: 2018-09-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes action items related to the security
release of Bitcoin Core 0.16.3 and Bitcoin Core 0.17RC4, the
newly-proposed BIP322, and Optech's upcoming Paris workshop; a link to
the C-Lightning 0.6.1 release, more information about BIP322, and some
details about the Bustapay proposal; plus brief descriptions of notable
merges in popular Bitcoin infrastructure projects.

## Action items

- **Upgrade to Bitcoin Core 0.16.3 to fix denial-of-service vulnerability:**
  a bug introduced in Bitcoin Core 0.14.0 and affecting
  all subsequent versions through to 0.16.2 will cause Bitcoin Core to
  crash when attempting to validate a block containing a transaction
  that attempts to spend the same input twice.  Such blocks would be
  invalid and so can only be created by miners willing to lose the
  allowed income from having created a block (at least 12.5 XBT or
  $80,000 USD).

  Patches for [master][dup txin master] and [0.16][dup txin 0.16]
  branches were submitted for public review yesterday, the 0.16.3
  release has been tagged containing the patch, and binaries will
  be available for [download][core download] as soon as a sufficient
  number of well-known contributors have reproduced the deterministic
  build---probably later today (Tuesday).  Immediate upgrade is
  highly recommended.

- **Allocate time to test Bitcoin Core 0.17RC4:** Bitcoin Core will soon
  be uploading [binaries][bcc 0.17] for 0.17 Release Candidate (RC) 4
  containing the same patch for the DoS vulnerability described above.
  All testers of previous release candidates should upgrade.  Testing is
  greatly appreciated and can help ensure the quality of the final
  release.

- **Review proposed BIP322 for generic message signing:** this
  [recently-proposed][BIP322 proposal] BIP will allow users to create
  signed messages for all currently-used types of Bitcoin addresses,
  including P2PKH, P2SH, P2SH-wrapped segwit, P2WPKH, and P2WSH.  It has
  the potential to become an industry standard that will be implemented
  by nearly all wallets and may be used by many services (such as
  peer-to-peer marketplaces) as well as for customer support, so Optech
  encourages allocating some engineering time to ensure the proposal is
  compatible with your organization's needs.  See the News section below
  for additional details.

- **[Optech Paris workshop][workshop] November 12-13:** member
  companies should [send us an email][optech email] to reserve spots for
  your engineers.  Planned topics include a comparison of two methods
  for bumping transaction fees, discussion of partially signed Bitcoin
  transactions ([BIP174][]), an introduction to output script
  descriptors, suggestions for Lightning Network wallet integration, and
  approaches to efficient coin selection (including output
  consolidation).

## News

- **C-Lightning 0.6.1 released:** this minor update brings several
  improvements, including "fewer stuck payments, better routing, fewer
  spurious closes, and several annoying bugs fixed."  The [release
  announcement][c-lightning 0.6.1] contains details and links to
  downloads.

- **BIP322 generic signed message format:** since 2011, users of many
  wallets have had the ability to sign an arbitrary message using the
  public key associated with a P2PKH address in their wallet.  However,
  there's no standardized way for users to do the same using a P2SH
  address or any of the different types of segwit addresses (although
  there are some implemented [non-standard methods][trezor p2wpkh
  message signing] with limited functionality).  Picking up a
  Bitcoin-Dev mailing list discussion from several months ago,
  Karl-Johan Alm has [proposed][BIP322 proposal] a BIP that could work
  for any address (although it's not yet described how it would work for
  P2SH or P2WSH addresses involving an OP_CLTV or OP_CSV timelock).

  The basic mechanism is that the authorized spender or spenders for
  an address generate scriptSigs and witness data (including
  their signatures) in much the same way they would if they were
  spending the funds---except instead of signing the spending
  transaction, they sign their arbitrary message instead (plus some
  predetermined extra data to ensure they can't be tricked into
  signing an actual transaction).  The verifier's software then
  validates this information the same way it would to determine
  whether a spending transaction was valid.  This allows the message
  signing facility to be exactly as flexible as Bitcoin scripts
  themselves.

  Currently, discussion appears to be most active on the BIP
  proposal's [pull request][BIP322 PR].

- **Bustapay discussion:** a simplified alternative to the proposed
  Pay-to-Endpoint (P2EP) protocol [described in newsletter #8][news8
  news], Bustapay provides improved privacy for both spenders and
  receivers---and also allows receivers to accept payments without
  increasing the number of their spendable outputs, a form of automatic
  UTXO consolidation.  Although [proposed][bustapay proposal] to the
  Bitcoin-Dev mailing list a few weeks ago, several aspects of the
  proposal were [discussed][bustapay sjors] this week.

  Although P2EP and Bustapay could end up being implemented by only a
  few wallets and services similar to the [BIP70][] payment protocol,
  there's also chance they could end up being becoming as widely
  adopted as wallet support for [BIP21][] URI handlers.  Even if they
  don't see general adoption, their privacy advantage means they could
  end up well deployed among niche users.  In either case, it may be
  worth dedicating some engineering time towards tracking the
  proposals and proof of concept implementations to ensure your
  organization can easily adopt them if desirable.

## Notable commits

*Notable commits this week in [Bitcoin Core][bitcoin core repo], [LND][lnd
repo], and [C-lightning][core lightning repo].  Reminder: new merges to
Bitcoin Core are made to its master development branch and are unlikely
to become part of the upcoming 0.17 release---you'll probably have to
wait until version 0.18 in about six months from now.*

- [Bitcoin Core #14054][]: this PR prevents the node from sending
  [BIP61][] peer-to-peer protocol [reject messages][p2p reject] by
  default.  These messages were implemented to make it easier for
  developers of lightweight clients to get feedback on connection and
  transaction relay problems.  However, there's no requirement (or way
  to require) that nodes send a reject message or an accurate reject
  message, so the messages arguably only end up wasting bandwidth.

  It's recommended that developers connect their test clients to their
  own nodes and inspect their nodes' logs for error messages in case
  of problems (perhaps after enabling debug logging).  Users who still
  need to send `reject` messages can use the `-enablebip61`
  configuration option, although it's possible that `reject`
  messages will be removed altogether in a release after 0.18.

- [Bitcoin Core #7965][]: this long-standing issue tracked the removal
  of code in the libbitcoin_server component to handle whether the wallet is
  compiled or not.  The issue was finally closed this week by the merge of
  [Bitcoin Core #14168][]. This issue, along with a number of other issues such
  as [Bitcoin Core #10973][] (Refactor: separate wallet from node) and [Bitcoin
  Core #14180][] (Run all tests even if wallet is not compiled) are part of a
  long-term effort to disentangle the wallet code from the server code. Doing so
  provides a number of benefits including easier code maintenance, better
  opportunities for testing individual components, and potentially more secure
  software if the wallet component is moved to its own process.

- [LND #1843][]: a configuration option intended only for testing
  (`--noencryptwallet`) has been renamed to `--noseedbackup`, been
  marked as deprecated, and had its help text updated and changed to
  mostly uppercase warning text.  Developers are worried that ordinary
  users are enabling this option without realizing that it puts them
  only one failure away from permanently losing money.

- [LND #1516][]: thanks to updates in the upstream Tor daemon, this
  patch makes it possible for LND to automatically create and set up v3
  onion services in addition to its existing v2 automation.  For the
  automation to work, users must already have Tor installed and running
  as a service.

- [C-Lightning #1860][]: for testing, an RPC proxy is now used to simplify mocking
  responses to various RPC calls, making it easier to test lightningd's
  handling of things such as fee estimates and crashes of bitcoind.

{% include references.md %}
{% include linkers/issues.md issues="14054,1843,1516,7965,14168,10973,14180,1860" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /en/workshops
[news8 news]: /en/newsletters/2018/08/14/#pay-to-end-point-p2ep-idea-proposed
[c-lightning 0.6.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.1
[BIP322 proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016393.html
[BIP322 PR]: https://github.com/bitcoin/bips/pull/725
[trezor p2wpkh message signing]: https://github.com/trezor/trezor-mcu/issues/169
[bustapay proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[bustapay sjors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016383.html
[p2p reject]: https://btcinformation.org/en/developer-reference#reject
[dup txin master]: https://github.com/bitcoin/bitcoin/pull/14247
[dup txin 0.16]: https://github.com/bitcoin/bitcoin/pull/14249
[core download]: https://bitcoincore.org/en/download
