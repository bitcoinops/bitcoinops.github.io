{% auto_anchor %}

As taproot nears activation at block {{site.trb}}, we can start to look
forward to some of the consensus changes that developers have previously
expressed the desire to build on top of taproot.

- **Cross-input signature aggregation:** [schnorr signatures][topic schnorr
  signatures] make it easy for
  owners of several distinct public and private
  key pairs to create a single signature that proves all of the key
  owners cooperated in creating the signature.
    With a future consensus change, this may allow a transaction to
    contain a single signature which proves the owners of all the UTXOs
    being spent in that transaction authorized the spend.
    This will save about 16 vbytes per keypath spend after the first
    input, providing significant savings for consolidation and
    [coinjoins][topic coinjoin].  It could even make coinjoin-based
    spending cheaper than spending by yourself, providing a mild
    incentive to use more private spending.

- **SIGHASH_ANYPREVOUT:** every normal Bitcoin transaction includes one
  or more inputs, and each of those inputs references the output of a previous
  transaction, using its txid.  That reference tells full verification nodes like
  Bitcoin Core how much money the transaction can spend and what
  conditions need to be fulfilled to prove the spend was authorized.
  All ways of generating
  signatures for Bitcoin transactions, both with and without taproot,
  either commit to the txids in the prevouts or don't commit to the
  prevouts at all.

    That's a problem for multiuser protocols that don't want to use a
    precise pre-arranged series of transactions.  If any user can skip a
    particular transaction, or change any detail of any transaction
    besides its witness data, that will change any later transaction's
    txid.  Changing the txid invalidates any signatures previously
    created for later transactions.  This forces offchain protocols to
    implement mechanisms (such as LN-penalty) that penalize any user who
    submits an older transaction.

    [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] can eliminate this
    problem by allowing a signature to skip committing to the prevout
    txid.  Depending on other flags used, it will still commit to other
    details about the prevout and the transaction (such as amount and
    script), but it will no longer matter what txid is used for the
    previous transaction.  This will make it possible to implement both the
    [eltoo][topic eltoo] layer for LN and
    [improvements][p4tr vaults] in [vaults][topic vaults] and other
    contract protocols.

- **Delegation and generalization:** after you create a script (taproot
  or otherwise), there's [almost][rubin delegation] no way for you to
  delegate to additional people the ability to spend from that script
  short of giving them your private key (which can be [extremely
  dangerous][bip32 reverse derivation] when using [BIP32][] wallets).  Additionally, taproot could
  be made more affordable for users who want to use a keypath spend plus
  just a small number of script-based conditions.  Several methods for
  enhancing taproot by generalizing it and providing [signer
  delegation][topic signer delegation] have been proposed:

    - **Graftroot:** [proposed][maxwell graftroot] shortly after the
      introduction of the idea for taproot, graftroot would give an
      extra feature to anyone capable of making a taproot keypath
      spend.  Instead of directly spending their funds, the keypath
      signers could instead sign a script that described new conditions
      under which the funds could be spent, delegating spending
      authority to anyone capable of satisfying the script.  The
      signature, the script, and whatever data was needed to satisfy the
      script would be provided in the spending transaction.  The keypath
      signers could delegate to an unlimited number of scripts in this
      way without creating any onchain data until an actual spend
      occurred.

    - **Generalized taproot (g'root):** a few months later, Anthony
      Towns [suggested][towns groot] a way to use public key points to
      commit to multiple different spending conditions without
      necessarily using a [MAST][topic mast]-like construction.  This
      *generalized taproot* (g'root) construction is "potentially more
      efficient for cases [where the taproot assumption doesn't
      hold][p4tr taproot assumption]".  It also "[offers][sipa groot
      agg] an easy way to construct a softfork-safe cross-input
      aggregation system".

    - **Entroot:** a [more recent][wuille entroot] synthesis of
      graftroot and g'root that simplifies many cases and makes them more
      bandwidth efficient.  It can support signer delegation from anyone
      able to satisfy any of the entroot branches, not just those able
      to create a top-level keypath spend.

- **New and old opcodes:** the taproot soft fork includes support for
  [tapscript][topic tapscript] which provides an improved way to add new
  opcodes to Bitcoin, `OP_SUCCESSx` opcodes.  Similar to the `OP_NOPx` (no
  operation) opcodes added early in Bitcoin's history, the `OP_SUCCESSx`
  opcodes are designed to be replaced with opcodes that don't always
  return success.  Some proposed new opcodes include:

    - **Restore old opcodes:** a number of opcodes for math and string
      operations were disabled in 2010 due to concerns about security
      vulnerabilities.  Many developers would like to see these opcodes
      re-enabled after a security review, and (in some cases) perhaps
      extended to handle larger numbers.

    - **OP_CAT:** one of the previously-disabled opcodes that deserves
      special mention is [OP_CAT][op_cat subtopic], which researchers
      have since discovered can [enable][keytrees] all [sorts][rubin
      pqc] of [interesting][poelstra cat] behavior on Bitcoin by itself,
      or which can be [combined][topic op_checksigfromstack] with other
      new opcodes in interesting ways.

    - **OP_TAPLEAF_UPDATE_VERIFY:** as described in [Newsletter #166][news166 tluv],
      an `OP_TLUV` opcode can enable [covenants][topic covenants] in a way that's
      particularly efficient and powerful when used with taproot's
      keypath and scriptpath capabilities.  This can be used to
      implement [joinpools][topic joinpools], [vaults][topic vaults], and other security
      and privacy improvements.  It may also combine well with
      [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify].

All of the ideas above are still only proposals.  None is guaranteed to
be successful.  It'll be up to researchers and developers to bring each
proposal to maturity and then for users to decide whether adding each
feature to Bitcoin is worth the effort of changing Bitcoin's consensus
rules.

{% endauto_anchor %}

[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[wuille entroot]: https://gist.github.com/sipa/ca1502f8465d0d5032d9dd2465f32603
[towns groot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016249.html
[maxwell graftroot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[p4tr multisignatures]: /en/preparing-for-taproot/#multisignature-overview
[p4tr vaults]: /en/preparing-for-taproot/#vaults-with-taproot
[rubin delegation]: /en/newsletters/2021/03/24/#signing-delegation-under-existing-consensus-rules
[p4tr taproot assumption]: /en/preparing-for-taproot/#is-cooperation-always-an-option
[op_cat subtopic]: /en/topics/op_checksigfromstack/#relationship-to-op_cat
[keytrees]: https://blockstream.com/2015/08/24/en-treesignatures/#h.2lysjsnoo7jd
[rubin pqc]: https://rubin.io/blog/2021/07/06/quantum-bitcoin/
[poelstra cat]: https://www.wpsoftware.net/andrew/blog/cat-and-schnorr-tricks-i.html
[bip32 reverse derivation]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#implications
[sipa groot agg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-October/016461.html
