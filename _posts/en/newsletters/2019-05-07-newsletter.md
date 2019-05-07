---
title: 'Bitcoin Optech Newsletter #45'
permalink: /en/newsletters/2019/05/07/
name: 2019-05-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter highlights some of the changes in the
recently-released Bitcoin Core 0.18.0, briefly mentions two proposed BIPs, describes how bech32 addresses
are forward compatible with expected protocol improvements, and
summarizes notable changes in popular Bitcoin infrastructure projects.

## Action items

- **Consider upgrading to Bitcoin Core 0.18.0:** released last week, the
  latest version of Bitcoin Core brings new features, performance
  improvements, and bug fixes.  See the *news* section below for
  more details.

## News

- **Bitcoin Core 0.18.0 released:** this new major version contains
  several significant new features plus many minor features and
  bugfixes.  The project's [release notes][0.18 notes] describe
  all notable changes and a list of each of the 119 people whose merged
  PRs helped contribute to this release.  Some features we think readers
  of this newsletter might find especially interesting include,

    - *More PSBT tools and refinements:* the previous major release,
      0.17, introduced support for [BIP174][] Partially-Signed Bitcoin
      Transactions (PSBTs) designed to help multiple programs or devices
      collaboratively create and sign transactions, such as multisig
      wallets, hardware wallets, and cold wallets.  The 0.18 release
      builds on that foundation with several bugfixes and improvements,
      including three new RPCs: `joinpsbts` to merge together multiple
      PSBTs; `analyzepsbt` to tell the user what they next need to do
      with the PSBT; and `utxoupdatepsbt` to add necessary information
      to a PSBT from a node's UTXO set.  Additionally, the PSBT section
      from the 0.17 release notes has been placed in a [separate
      document][PSBT documentation] and expanded to cover new features
      added in 0.18.

    - *Initial RPC support for output script descriptors:* Bitcoin
      software needs a way to find all the transactions on the block chain
      that pay a user's wallet.  This is easy if the wallet only supports one
      scriptPubKey format---e.g., for P2PKH, the wallet hashes each of
      its pubkeys and looks for any scriptPubKeys paying `0x76a9[hash160
      of any wallet pubkey]88ac`.  But Bitcoin Core's built-in wallet
      currently supports many different scriptPubKey formats---P2PK,
      P2PKH, P2WPKH, bare multisig, P2SH commitments, and P2WSH
      commitments.  This provides flexibility and backwards
      compatibility but comes at a cost of poor scalability: the wallet
      expends CPU time scanning for old or rare scripts that most users
      never use.

        [Output script descriptors][] are a new language developed by Pieter
        Wuille for concisely describing scriptPubKeys so that the wallet
        knows exactly what it should scan for.  The ultimate goal is for
        Bitcoin Core's wallet to contain a simple list of descriptors
        describing all of its scripts---a list that may be as short as a
        single descriptor for most users but supporting broad
        flexibility for future upgrades and advanced use cases (including
        multisig and hardware signing); see PR [#15487][Bitcoin Core
        #15487] and [#15764][Bitcoin Core #15764] for work towards that
        end.  However, to allow both users and project developers to
        build experience working with descriptors before fundamental
        changes are made to the wallet, the 0.18 release updates
        existing RPCs and adds new RPCs that work with descriptors.
        Existing RPCs updated with descriptor support include
        `scantxoutset`, `importmulti`, `getaddressinfo`, and
        `listunspent`.  New RPCs include `deriveaddresses` and
        `getdescriptorinfo`.

    - *Basic hardware signer support through independent tool:* released
      separately from 0.18, but still part of the Bitcoin Core project,
      is the [Hardware Wallet Interaction][HWI] (HWI) tool that allows
      users comfortable working on the command line to use Bitcoin Core
      with several popular models of hardware wallets.  Internally, the
      tool makes heavy use of PSBTs and output script descriptors,
      allowing it to be integrated with other wallets that support those
      interfaces (e.g. [Wasabi wallet's experimental support][wasabi
      hwi]).  Work has already begun on more directly integrating HWI
      with the main Bitcoin Core tools and building graphical interfaces
      for it.

    - *New wallet tool:* alongside `bitcoind` and other Bitcoin programs
      is a new `bitcoin-wallet` tool.  This command-line tool currently
      only allows the user to create a new wallet or perform some basic
      inspections on an existing wallet, but it's planned to add more
      features to the tool in subsequent releases.

    - *New architecture and new Ubuntu Snap package:* this is the first
      release to provide [pre-built binaries][bitcoincore.org download]
      for Linux on the RISC-V CPU architecture.  For users of Ubuntu and
      compatible systems, this release also provides a [Snap package][]
      that replaces the PPA that was updated in previous releases.
      Both the RISC-V and Snap packages include binaries that are
      deterministically built and [signed][gitian sigs] by multiple
      Bitcoin Core contributors.

      {% comment %}<!--
      152 Tests and QA
      74 Docs
      65 wallet
      55 RPCs and other APIs
      51 GUI
      47 Build system
      43 Misc
      17 p2p and network code
      13 Platform support
      9 block and tx handling
      1 mining
      1 consensus
      -->{% endcomment %}

    - *Numerous testing and Quality Assurance (QA) changes:* the
      [release notes][0.18 notes] list all the PRs related to 0.18 that
      Bitcoin Core's release manager thought were significant, split
      into twelve categories.  Although the significance and
      categorization criteria are somewhat arbitrary, and the number of
      PRs doesn't necessarily correlate to the amount of work done, we
      think it's notable that the "Tests and QA" section in the release
      notes has more than double the number of PRs listed in any other
      category.  We don't often get to write about testing in this
      newsletter---tests are rarely news unless something goes
      wrong---so we wanted to take this opportunity to remind readers
      that testing remains an active and important part of Bitcoin Core
      development.

    - *Plan to switch to bech32 receiving addresses by default:* as
      mentioned in the *news* section of [Newsletter #40][], the release
      notes announce the project's intention to switch to bech32 sending
      addresses by default in either the next major version (0.19,
      [expected around November 2019][0.19 release schedule]) or the
      version after that (expected about a year from now).  The earlier
      date is the current target.

- **Proposal for support of Schnorr signatures and Taproot script
  commitments:** Pieter Wuille [posted][tap post] to the Bitcoin-Dev
  mailing list a proposed [BIP for Taproot][taproot] (using Schnorr
  signatures) and a proposed [BIP for Tapscript][tapscript], a small
  variation on Bitcoin's current Script language to be used with Taproot
  encumbrances.  Also provided is a [reference implementation][tap ref]
  of the two proposals that makes all consensus changes in about 520
  lines of code (excluding changes related to Schnorr signatures that
  will be added to the [libsecp256k1][] library; see the previously-released
  [bip-schnorr][] for more information).

    The announcement of the proposals came too late in the writing
    process for us to provide a detailed description in this newsletter,
    although we did alter some other text in this newsletter to reflect
    the release of the proposals.  We plan to provide full coverage
    next week.

## Bech32 sending support

*Week 8 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 easy] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

What do bip-taproot and bip-tapscript mean for people who have
implemented bech32 sending support or who are planning to implement it?
In particular, if you haven't implemented segwit sending support yet,
should you wait to implement it until the new features have been
activated?  In this weekly section, we'll show why you shouldn't wait
and how implementing sending support now won't cost you any extra effort
in the future.

The designers of segwit and bech32 had a general idea what future
protocol improvements would look like, so they engineered segwit
scriptPubKeys and the bech32 address format to be forward compatible
with those expected improvements.  For example an address supporting
Taproot might look like this:

```text
bc1pqzkqvpm76ewe20lcacq740p054at9sv7vxs0jn2u0r90af0k63332hva8pt
```

You'll notice that looks just like other bech32 addresses you've
seen---because it is.  You can use the exact same code we provided in
[Newsletter #40][] (using the bech32 reference library for Python) to decode
it.

```python
>> import segwit_addr
>> address='bc1pqzkqvpm76ewe20lcacq740p054at9sv7vxs0jn2u0r90af0k63332hva8pt'
>> witver, witprog = segwit_addr.decode('bc', address)
>> witver
1
>> bytes(witprog).hex()
'00ac06077ed65d953ff8ee01eabc2fa57ab2c19e61a0f94d5c78cafea5f6d46315'
```

The differences here from the decoded bech32 addresses we've shown in
previous newsletters are that this hypothetical Taproot address uses a
witness version of `1` instead of `0` (meaning the scriptPubKey will
start with `OP_1` instead of `OP_0`) and the witness program is one
byte longer than a P2WSH witness program.  However, these don't matter
to your software if you're just spending.  We can use the exact same
example code from [Newsletter #40][news40 bech32] to create the
appropriate scriptPubKey for you to pay:

```python
>> bytes([witver + 0x50 if witver else 0, len(witprog)] + witprog).hex()
'512100ac06077ed65d953ff8ee01eabc2fa57ab2c19e61a0f94d5c78cafea5f6d46315'
```

This means anyone who implements bech32 support in the generic way
described in Newsletter #40 shouldn't need to do anything special in
order to support future script upgrades.  In short, the work you invest
into providing bech32 sending support now is something you won't need to
repeat when future expected changes to the Bitcoin protocol are
deployed.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15323][] updates the `getmempoolinfo` RPC and
  `/rest/mempool/info.json` REST endpoints so that they return a
  `loaded` field that's *true* if the saved mempool has been fully
  loaded from disk or *false* if it's still loading.

- [Bitcoin Core #15141][] takes the code that bans peers for sending
  invalid data and moves it from the validation code into the
  network-management code.  Specifically, when the network code passes
  new data to the validation code and the validation code returns
  invalid, it also returns a reason for the invalidity.  The network
  code can use this reason to determine whether the peer who sent the
  data should be banned, otherwise penalized, or not penalized at all
  (e.g. the peer sent invalid data because it's running a node version
  from before a soft fork and so is unaware of the new rules).  This not
  only creates a clearer division between layers in the system's code
  but it also prepares for future improvements in the peer-handling code
  that will allow it to be smarter about banning peers based on multiple
  criteria.

{% comment %}<!-- This was direct pushed (no PR): https://github.com/lightningd/plugins/commit/187c66a9b1412edced3c51cb53ba568f245a5614 --> {% endcomment %}

- The [C-Lightning plugin repository][] received an [autopilot][cl
  autopilot] plugin that can help users choose one or more channels to
  open to start sending LN payments.  The plugin is based on an [earlier
  PR][C-Lightning #1888] to the main C-Lightning codebase.

{% include references.md %}
{% include linkers/issues.md issues="15487,15764,15323,15141,1888" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[bech32 easy]: {{news38}}#bech32-sending-support
[snap package]: https://snapcraft.io/bitcoin-core
[0.19 release schedule]: https://github.com/bitcoin/bitcoin/issues/15940
[c-lightning plugin repository]: https://github.com/lightningd/plugins
[cl autopilot]: https://github.com/lightningd/plugins/tree/master/autopilot
[0.18 notes]: https://bitcoincore.org/en/releases/0.18.0/
[psbt documentation]: https://github.com/bitcoin/bitcoin/blob/master/doc/psbt.md
[bitcoincore.org download]: https://bitcoincore.org/en/download/
[gitian sigs]: https://github.com/bitcoin-core/gitian.sigs
[news40 bech32]: {{news40}}#bech32-sending-support
[wasabi hwi]: https://github.com/zkSNACKs/WalletWasabi/pull/1341
[tap post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016914.html
[taproot]: https://github.com/sipa/bips/blob/bip-schnorr/bip-taproot.mediawiki
[tapscript]: https://github.com/sipa/bips/blob/bip-schnorr/bip-tapscript.mediawiki
[tap ref]: https://github.com/sipa/bitcoin/commits/taproot
