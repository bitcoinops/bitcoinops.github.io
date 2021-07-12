---
title: 'Bitcoin Optech Newsletter #157'
permalink: /en/newsletters/2021/07/14/
name: 2021-07-14-newsletter
slug: 2021-07-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about a proposed new
opcode and links to an updated wiki page for tracking bech32m support.
Also included are our regular sections with highlights from a Bitcoin
Core PR Review Club meeting, suggestions about preparing for taproot,
and descriptions of notable changes to popular Bitcoin infrastructure
projects.

## News

- **Request for `OP_CHECKSIGFROMSTACK` design suggestions:** Jeremy
  Rubin [posted][rubin csfs] to the Bitcoin-Dev mailing list a draft specification
  for an [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] opcode and
  asked for feedback from any developers who would prefer an alternative
  design.  Some alternatives were discussed, but the thread also
  branched off into a discussion about whether an [OP_CAT][] opcode
  should be introduced at the same time.

    `OP_CAT` and `OP_CSFS` would enable arbitrary transaction
    introspection---the ability to receive bitcoins to a script that
    could check almost any part of the transaction that later spends
    those bitcoins.  This can enable many advanced features (including
    versions[^expensive] of other proposed upgrades like
    [SIGHASH_ANYPREVOUT][topic sighash_noinput] and
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]), but
    `OP_CAT` also makes it possible to create recursive
    [covenants][topic covenants] which could permanently restrict the
    spendability of any bitcoins committed to the covenant.  Some people
    have [objected][rubin cost/benefit] to allowing covenants in Bitcoin, but several
    [arguments][harding altcoins] were [made][towns multisig] to the
    effect that the worst case problems of recursive covenants already
    exist in Bitcoin today so we shouldn't be concerned about enabling
    `OP_CAT` or a similar opcode.

    Despite the discussion, Rubin decided he wanted to keep his
    `OP_CSFS` proposal independent of any proposal to add `OP_CAT`,
    [arguing][rubin just csfs] that `OP_CSFS` is useful enough on its
    own.

- **Tracking bech32m support:** the Bitcoin Wiki page for [bech32
  adoption][wiki bech32 adoption] has been [updated][erhardt bech32m
  tweet] to track which software and services support spending or
  receiving to [bech32m][topic bech32] addresses for taproot.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Use script_util helpers for creating P2{PKH,SH,WPKH,WSH} scripts][review club #22363] is a PR by
Sebastian Falbesoner which substitutes manual script creation with calls to `script_util` helper
functions in functional tests and fixes an error in the `get_multisig()` function. The review club
meeting broke down terminology and each of the script output types used in the PR.

{% include functions/details-list.md

  q0="What do `key_to_p2pkh_script`, `script_to_p2sh_script`, `key_to_p2wpkh_script` and
`script_to_p2wsh_script` in script\_util.py do?" a0="These are helper functions to construct
`CScript` objects for Pay to Public Key Hash, Pay to Script Hash, Pay to Witness Public Key Hash,
and Pay to Witness Script Hash scripts from public keys and scripts."
  a0link="https://bitcoincore.reviews/22363#l-17"

  q1="Define scriptPubKey, scriptSig, and witness."
  a1="The scriptPubKey and scriptSig are fields in the output and input of a transaction,
respectively, for specifying and satisfying spending conditions. The witness is an additional field for the same
purpose introduced with Segregated Witness. Spending requirements are committed to in an output's
scriptPubKey and the input that spends it must be accompanied by data satisfying those conditions in the
scriptSig and/or witness."
  a1link="https://bitcoincore.reviews/22363#l-31"

  q2="Define redeem script and witness script. What is the relationship between them?"
  a2="P2SH and P2WSH output types commit to a script hash in the
  scriptPubKey. When the output is spent, the spender must
provide the script itself, along with any signatures or other data required to make it pass.
The script is called a redeemScript when contained in the scriptSig and a
witness script when in the witness. In that sense, they are analogous; a redeemScript is to a P2SH
output what a witness script is to a P2WSH output. They are not mutually exclusive, however,
since a transaction spending a P2SH-P2WSH output contains both."
  a2link="https://bitcoincore.reviews/22363#l-55"

  q3="To send coins to someone with spending conditions encoded in a script, what is included in the
scriptPubKey of the output? What needs to be provided in the input when the coin is spent?"
  a3="The scriptPubKey includes the script hash and opcodes to verify a match: `OP_HASH160
OP_PUSHBYTES_20 <20B script hash> OP_EQUAL`. The scriptSig includes the script itself and initial
stack."
  a3link="https://bitcoincore.reviews/22363#l-102"

  q4="Why do we use Pay-To-Script-Hash instead of Pay-To-Script?"
  a4="The primary motivation as stated in [BIP16][] is to create a generic way of funding arbitrarily
complex transactions while placing the burden of supplying spending conditions on the one who
redeems the funds. Participants also mentioned that keeping the script out of scriptPubKeys means
its associated fees are not paid until redemption and results in a smaller UTXO set."
  a4link="https://bitcoincore.reviews/22363#l-112"

  q5="When a non-segwit node validates a P2SH-P2WSH input, what does it do? What does a segwit-enabled
node do in addition to the procedure performed by a non-segwit node?"
  a5="The non-segwit node never sees the witness; it simply enforces P2SH rules by verifying that
the redeemScript matches the hash committed to in the scriptPubKey. A segwit node recognizes this
data as a witness program and uses the witness data and appropriate scriptCode to enforce segwit
rules."
  a5link="https://bitcoincore.reviews/22363#l-137"

  q6="What is wrong with the P2SH-P2WSH script in the original
[`get_multisig()`](https://github.com/bitcoin/bitcoin/blob/091d35c70e88a89959cb2872a81dfad23126eec4/test/functional/test_framework/wallet_util.py#L109)
function?"
  a6="It uses the witness script instead of its hash in the P2SH-P2WSH redeem script."
  a6link="https://bitcoincore.reviews/22363#l-153"
%}

## Preparing for taproot #4: from P2WPKH to single-sig P2TR

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/03-p2wpkh-to-p2tr.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.13.1-beta.rc2][LND 0.13.1-beta] is a maintenance release with
  minor improvements and bug fixes for features introduced in
  0.13.0-beta.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [C-Lightning #4625][] updates its [LN offers][topic offers] implementation to match the latest
  [specification changes][offers spec changes]. Notably, offers are no longer
  required to contain a signature. This significantly shortens the encoded
  string for offers, improving QR code recognizability.

- [Eclair #1746][] adds support for replicating data to a PostsgreSQL
  database in parallel to the primary SQLite database. The feature is
  meant to facilitate testing for servers that want to make an eventual backend transition.  Last
  year, Suredbits engineer Roman Taranchenko described customizing
  Eclair for enterprise-use with a PostgreSQL backend in an Optech
  [field report][suredbits enterprise ln].

- [LND #5447][] adds a [document][lnd leader] describing how to set up
  multiple LND nodes in a cluster with an alternative database that is
  replicated between the cluster's nodes and which allows for automatic
  failover.  Interested readers may wish to contrast this with the
  approach taken by Eclair and described in [Newsletter #128][news128
  eclair akka].

- [Libsecp256k1 #844][] makes several updates to the API for [schnorr
  signatures][topic schnorr signatures].  Most notable is a
  [commit][nick varsig] that allows signing and verifying messages of
  any length.  All current uses of signatures in Bitcoin sign a 32-byte
  hash, but allowing signing of variable-length data could be useful for
  applications outside of Bitcoin or to enable a new opcode such as
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] to [verify
  signatures][oconnor var csfs] created for non-Bitcoin systems.  It's
  expected that the [BIP340][] specification of schnorr signatures for
  Bitcoin will be updated to describe safely signing variable length
  data.

- [BIPs #943][] updates [BIP118][] to build on soon-to-be activated
  taproot and tapscript rather than SegWit v0. Additionally, this revision
  renames the title to [SIGHASH_ANYPREVOUT][topic sighash_noinput]
  from SIGHASH_NOINPUT to reflect that the sighash flag is now referred to as
  "ANYPREVOUT" given that while any prevout may potentially be used with
  the signature, some aspects of the input are still committed to.

- [BTCPay Server #2655][] signals to web browsers that they should not
  send the HTTP `referer` <!-- sic --> field when the user clicks on a
  link to a transaction in a [block explorer][topic block explorers].  This avoids telling the block
  explorer what BTCPay server the user came from---that information
  being strong evidence that the server either originated or received
  the transaction being viewed in the block explorer.  Even with this
  change, users desiring strong privacy should still avoid looking up
  their own transactions on third-party block explorers.

## Footnotes

[^expensive]:
    Using `OP_CHECKSIGFROMSTACK` (`OP_CSFS`) to implement the principle
    feature of proposals like [BIP118][]'s [SIGHASH_ANYPREVOUT][topic
    sighash_noinput] or [BIP119][]'s [OP_CHECKTEMPLATEVERIFY][topic
    op_checksigfromstack] would require more block space than those
    optimized proposals if scriptpath spending is used.  The
    [argument][news48 generic csfs] in favor of `OP_CSFS` is that it
    allows starting with a generic construction and proving that people
    will actually use the feature before a consensus change is used to
    add a more efficient implementation.  Additionally, with the
    introduction of [taproot][topic taproot] keypath spends, any script
    can be resolved with the minimal use of block space in some
    situation, possibly reducing the need for specific constructions
    that save space in non-optimal situations.

{% include references.md %}
{% include linkers/issues.md issues="4625,5447,844,1746,943,2655,22363" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta.rc2
[bip341 cite22]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_ref-22-0
[News128 eclair akka]: /en/newsletters/2020/12/16/#eclair-1566
[oconnor var csfs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019193.html
[erhardt bech32m tweet]: https://twitter.com/murchandamus/status/1413687483246776322
[wiki bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[rubin csfs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019192.html
[harding altcoins]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019203.html
[towns multisig]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019209.html
[rubin just csfs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019229.html
[lnd leader]: https://github.com/bhandras/lnd/blob/f41771ce54bb7721101658477ad538991fc99fe6/docs/leader_election.md
[nick varsig]: https://github.com/bitcoin-core/secp256k1/pull/844/commits/a0c3fc177f7f435e593962504182c3861c47d1be
[news48 generic csfs]: /en/newsletters/2019/05/29/#not-generic-enough
[op_cat]: /en/topics/op_checksigfromstack/#relationship-to-op_cat
[rubin cost/benefit]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019200.html
[offers spec changes]: https://github.com/lightningnetwork/lightning-rfc/pull/798#issuecomment-871124755
[suredbits enterprise ln]: /en/suredbits-enterprise-ln/
