---
title: "Bitcoin Optech Newsletter #23"
permalink: /en/newsletters/2018/11/27/
name: 2018-11-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter provides a reminder about potential feerate
increases, summarizes suggested improvements to sighash flags to
accompany BIP118 `SIGHASH_NOINPUT_UNSAFE`, and briefly describes a
proposal to simplify fee bumping for LN commitment transactions.  Also
included are selected recent Q&A from Bitcoin StackExchange and
descriptions of notable code changes in popular Bitcoin infrastructure
projects.

## Action items

- **Monitor feerates:** recent reductions in the exchange rate are the likely cause of
  a modest decrease in hashrate and a possible increase in the number
  of coins traveling to or from exchanges, which could lead to increased
  feerates during the next week.  Unless there is a dramatic new change
  in hashrate during the next week, a difficulty adjustment is expected
  around Sunday that will mitigate most of the recent hashrate reductions.

## News

- **Sighash updates:** Pieter Wuille started a [thread][wuille sighash]
  on the Bitcoin-Dev mailing list suggesting two additions for future
  changes to segwit sighashes, especially [BIP118][]
  `SIGHASH_NOINPUT_UNSAFE`.  A signature hash is the data committed to
  by a signature in a transaction. Normally the hash commits to a list
  of which coins are being spent, which scripts are receiving the coins,
  and some metadata---but it's possible to sign only some of the
  transaction fields in order to allow other users to change your
  transactions in specific ways you might find acceptable (e.g. for
  layer-two protocols).

    Wuille suggests two additions to what metadata is hashed.  Both will
    be optional, but both can become the default for normal onchain
    wallets.  First, the transaction fee is included in the hash in
    order to allow hardware wallets or offline wallets to ensure they
    aren't being tricked into sending excess fees to miners.
    Second, the scriptPubKey of the coins being spent is also included
    in the hash---this also helps secure hardware wallets and offline
    wallets by eliminating a current ambiguity about whether the script
    being spent is a scriptPubKey, P2SH redeemScript, or segwit
    witnessScript.

- **Simplified fee bumping for LN:** funds in a payment channel are
  protected in part by a multisig contract that requires both parties
  sign any state in which the channel can close.  Although this provides
  trustless security, it has an unwanted side-effect related to
  transaction fees---the parties may be signing channel states weeks or
  months before the channel is actually closed, which means they have to
  guess what the transaction fees will be far in advance.

    Rusty Russell has opened a [PR][simple commit PR] to the BOLT
    repository and started a mailing list [thread][simple commit thread]
    for feedback on a proposal to modify the construction and signing
    of some of the LN transactions in order to allow both [BIP125][]
    Replace-by-Fee (RBF) fee bumping and Child-Pays-For-Parent (CPFP)
    fee bumping.  In a [follow-up email][corallo simple commit], Matt
    Corallo indicated that the proposal is probably dependent on some
    changes being made to the methods and policies nodes use for
    relaying unconfirmed transactions.

## Selected Q&A from Bitcoin StackExchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help answer other people's questions.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

- [How could you create a fake signature to pretend to be
  Satoshi?][bse 81115] Gregory Maxwell asks and answers a question about
  you could create a value that looked like an ECDSA signature corresponding
  to an arbitrary public key---such as one known to belong to Satoshi
  Nakamoto---but without having access to the private key.  Maxwell
  explains that it's easy---if you can trick people into skipping part
  of the verification procedure.

- [How to encrypted a message using a Bitcoin keypair?][bse 80640]
  Pieter Wuille and Gregory Maxwell each answer a question about using
  Bitcoin private and public keys for encryption rather than their
  typical use for signing and verification.  Wuille's answer provides
  detail about the mechanism for accomplishing this, but both answers
  warn users about the dangers of trying to perform encryption with
  keys and tools that are intended for non-encrypted use with Bitcoin.

- [What is transaction pinning?][bse 80804] John Newbery asks and
  answers a question about the term *transaction pinning.*  His
  definition describes a way to make it prohibitively expensive to
  fee bump even a small transaction that signals opt-in Replace-by-Fee
  (RBF).  (Transaction pinning can create problems for protocols such as
  LN where security depends on some transactions confirming within a
  certain period of time.)

- [What makes batch verification of Schnorr signatures effective?][bse
  80702] Pieter Wuille provides a simple explanation for how it's
  possible to do several multiplication operations simultaneously on an
  elliptic curve.  This can be significantly faster than doing single
  multiplication in series, allowing multiple signatures to be verified
  together faster than they could be individually verified.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="35739976c1d9ad250ece573980c57e7e7976ae23"
  end="a7dc03223e915d7afb30498fe5faa12b5402f7d8"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="4da1c867c3209dab4e4a824b73d89fc38b616b37"
  end="8924d8fb20eb2abfd9cc93c6cc7eb6951184cb88"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="d5aaa11373cc6759f9f894a1daf7fb88d0834bc9"
  end="95e47cdac298b8e534feb073c70da004c08b3e93"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="314a61d72474aa29ff4afba8472553ad91d88e9d"
  end="314a61d72474aa29ff4afba8472553ad91d88e9d"
%}

- [Bitcoin Core #14708][] prints a warning when unrecognized section
  names are used in the `bitcoin.conf` configuration file.  For example,
  if you create the following configuration file using the name
  `testnet` instead of the correct name `test`, Bitcoin Core would
  previously silently ignore the testnet options.  This merged PR causes
  it to print a notice: "Warning: Section [testnet] is not recognized."

    ```toml
    [testnet]
    txindex = 1
    ```
- [C-Lightning #2087][] adds new fields to the results of the `getinfo` RPC for
  the number of the node's peers, number of pending channels, number of
  active channels, and number of inactive channels.  This now matches
  information displayed by LND's `getinfo` RPC.

- [C-Lightning #2096][] strips the text `lightning:` prefixed to a
  [BOLT11][] invoice before attempting to process it.  This text is
  sometimes added so that LN wallets can register for it as URI
  handlers.  The prefix text will be striped if it is all lowercase or
  all uppercase (but not mixed case) per the [BIP173][] bech32
  specification.

- C-Lightning [#2081][c-lightning #2081] and [#2092][c-lightning #2092]
  fix a problem with running multiple RPC commands in parallel.  As a
  user-visible change, `lightningd` now adds a double newline (`\n\n`)
  instead of just a single newline to the final output from an RPC.  As
  single newlines may be used elsewhere in RPC output, terminating with
  a double newline makes it easy for a non-JSON parser to find the end
  of the results from one RPC call and the beginning of the results from
  a subsequent call when the same socket is used for both.

- [Bitcoin Core #14756][] adds the ability for the `rpcauth.py` script to
  accept a password on stdin rather than as a command-line parameter
  that might be stored in shell history.  This script is the preferred
  way to generate login credentials for RPC access when not using
  `bitcoin-cli` as the same user that started the `bitcoind` daemon.

- [Bitcoin Core #14532][] changes the settings used to bind Bitcoin
  Core's RPC port to anything besides the default (localhost).
  Previously, using the `-rpcallowip` configuration option would cause
  Bitcoin Core to listen on all interfaces (although still only
  accepting connections from the allowed IP addresses); now, the
  `-rpcbind` configuration option also needs to be passed to specify the
  listening addresses.  New warnings are printed for unlikely
  configurations and to advise users about the danger of listening on
  untrusted networks.  It is hoped that this change will help reduce the
  number of nodes listening for RPC connections on public interfaces,
  the danger of which was described in the *News* section of [Newsletter
  #18][].

- [C-Lightning #2095][] enforces the [BOLT2][] maximum amounts for
  channel and payment value after it was discovered that C-Lightning wasn't
  obeying these limits.  A future change will likely support an optional
  wumbo bit (jumbo bit) that allows the node to negotiate extra-large
  channels and payment amounts.

{% include references.md %}
{% include linkers/issues.md issues="14708,2087,2096,2081,2092,14756,14532,2095" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 81115]: {{bse}}81115
[bse 80640]: {{bse}}80640
[bse 80804]: {{bse}}80804
[bse 80702]: {{bse}}80702

[wuille sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016488.html
[simple commit PR]: https://github.com/lightningnetwork/lightning-rfc/pull/513
[simple commit thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001643.html
[corallo simple commit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001666.html
