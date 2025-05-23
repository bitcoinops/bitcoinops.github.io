---
title: OP_CHECKTEMPLATEVERIFY

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses
  - Soft Forks
  - Fee Management

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **OP_CHECKTEMPLATEVERIFY (CTV)** is a proposed new opcode that takes a
  commitment and requires any transaction executing
  the opcode to match the commitment in the following fields: its
  version, locktime, signature scripts, number of inputs, sequences,
  number of outputs, outputs, and the location of the input being spent
  within the spending transaction.  This allows an output to specify how
  its funds may be spent---a design known in Bitcoin as a *covenant*.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP119

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Proposed new opcode for transaction output commitments
    url: /en/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments

  - title: "Detailed summary: proposed transaction output commitments"
    url: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
    feature: true

  - title: COSHV proposal replaced
    url: /en/newsletters/2019/06/05/#coshv-proposal-replaced

  - title: Potential script changes, including new COSHV opcode
    url: /en/newsletters/2019/06/12/#potential-script-changes

  - title: "OP_CHECKTEMPLATEVERIFY (CTV) replaces COSHV proposal; concerns restated"
    url: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv

  - title: "Proposed changes to bip-CTV"
    url: /en/newsletters/2019/12/18/#proposed-changes-to-bip-ctv

  - title: "2019 year-in-review: OP_CHECKTEMPLATEVERIFY"
    url: /en/newsletters/2019/12/28/#ctv

  - title: "BIPs #875 assigns BIP119 to the OP_CHECKTEMPLATEVERIFY proposal"
    url: /en/newsletters/2020/01/29/#bips-875

  - title: OP_CHECKTEMPLATEVERIFY workshop summary
    url: /en/newsletters/2020/02/12/#op-checktemplateverify-ctv-workshop

  - title: Vault prototype with sample implementation using OP_CHECKTEMPLATEVERIFY
    url: /en/newsletters/2020/04/22/#vaults-prototype

  - title: "Sapio: a new language for building contracts with OP_CHECKTEMPLATEVERIFY"
    url: /en/newsletters/2020/08/05/#sapio

  - title: Public launch of Sapio with support for using `OP_CHECKTEMPLATEVERIFY`
    url: /en/newsletters/2021/04/21/#sapio-public-launch

  - title: "BIPs #1215 makes several updates to the BIP119 OP_CHECKTEMPLATEVERIFY proposal"
    url: /en/newsletters/2021/11/10/#bips-1215

  - title: "Bi-weekly IRC meetings scheduled for reviewing and discussing `OP_CHECKTEMPLATEVERIFY`"
    url: /en/newsletters/2022/01/05/#bip119-ctv-review-workshops

  - title: Mailing list and IRC discussion of CTV, including criticism and rebuttals
    url: /en/newsletters/2022/01/19/#op-checktemplateverify-discussion

  - title: Discussion about how CTV or other covenant features could make DLCs much more efficient
    url: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script

  - title: OP_TXHASH as a proposed alternative to CTV and APO
    url: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo

  - title: "Parameters published for `OP_CHECKTEMPLATEVERIFY` signet"
    url: /en/newsletters/2022/02/23/#ctv-signet

  - title: Continued CTV discussion and the design for a CTV-based vault
    url: /en/newsletters/2022/03/16/#continued-ctv-discussion

  - title: Discussion about activating CTV
    url: /en/newsletters/2022/04/27/#discussion-about-activating-ctv

  - title: Implications of bare CTV not having an address format
    url: /en/newsletters/2022/04/27/#noted

  - title: "Proposal to initially restrict `OP_TX` to the features provided by `OP_CTV`"
    url: /en/newsletters/2022/05/18/#updated-op-tx-proposal

  - title: "BIPs #1309 updates BIP119’s example implementation to use pythonic pseudocode"
    url: /en/newsletters/2022/05/18/#bips-1309

  - title: "New software fork of Bitcoin Core for testing to include support for CTV"
    url: /en/newsletters/2022/09/28/#bitcoin-implementation-designed-for-testing-soft-forks-on-signet

  - title: "Proposal for `OP_UNVAULT` opcode that can emulate CTV"
    url: /en/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes

  - title: "Analysis of alternative design for `OP_VAULT` using MATT-style covenants and CTV"
    url: /en/newsletters/2023/05/03/#matt-based-vaults

  - title: "Example of using MATT-style covenants to replicate CTV features"
    url: /en/newsletters/2023/06/07/#using-matt-to-replicate-ctv-and-manage-joinpools

  - title: "Mashup of OP_CTV and APO proposed using OP_CSFS and OP_TXHASH"
    url: /en/newsletters/2023/08/30/#covenant-mashup-using-txhash-and-csfs

  - title: "Using covenants like OP_CTV and APO to improve LN scalability"
    url: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability

  - title: "Mashup of OP_CTV and OP_CSFS proposed, along with new OP_INTERNALKEY"
    url: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed

  - title: Opposition to CTV based on commonly requiring exogenous fee
    url: /en/newsletters/2024/01/31/#opposition-to-ctv-based-on-commonly-requiring-exogenous-fees

  - title: "Exploding keys, a soft fork proposal with similar capabilities to CTV"
    url: /en/newsletters/2024/05/01/#ctv-like-exploding-keys-proposal

  - title: "BIP119 extensions for smaller hashes and arbitrary data commitments"
    url: /en/newsletters/2024/05/15/#bip119-extensions-for-smaller-hashes-and-arbitrary-data-commitments

  - title: "Post and website examining `OP_CHECKTEMPLATEVERIFY` testing on the default signet"
    url: /en/newsletters/2024/11/22/#signet-activity-report

  - title: "Proposed CTV enhancement opcodes: `OP_TEMPLATEHASH` and `OP_INPUTAMOUNTS`"
    url: /en/newsletters/2025/01/03/#ctv-enhancement-opcodes

  - title: "BIPs #1792 updates BIP119 with a revised introduction and mention of protocols using CTV"
    url: /en/newsletters/2025/03/28/#bips-1792

  - title: "Criticism of CTV motivation in a joint activation with CSFS"
    url: /en/newsletters/2025/04/04/#criticism-of-ctv-motivation

  - title: "CTV + CSFS allow creation of a perpetual covenant"
    url: /en/newsletters/2025/04/04/#ctv-csfs-allows-the-creation-of-a-perpetual-covenant

  - title: "Summary and criticism of CTV + CSFS benefits for discreet log contracts (DLCs)"
    url: /en/newsletters/2025/04/04/#dlcs

  - title: "Summary and criticism of CTV + CSFS benefits for accountable computing contracts"
    url: /en/newsletters/2025/04/04/#accountable-computing-contracts

  - title: "Summary and criticism of CTV + CSFS benefits for LN-Symmetry"
    url: /en/newsletters/2025/04/04/#ln-symmetry

  - title: "Summary and criticism of CTV + CSFS benefits for Ark"
    url: /en/newsletters/2025/04/04/#ark

  - title: "Details about how Ark could make use of CTV if activated"
    url: /en/newsletters/2025/04/04/#benefit-of-ctv-to-ark-users

  - title: "Description of benefits to BitVM from `OP_CTV` and `OP_CSFS`"
    url: /en/newsletters/2025/05/16/#description-of-benefits-to-bitvm-from-op-ctv-and-op-csfs

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Covenants
    link: topic covenants
---
CTV has been suggested for use with a variety of protocols:

- **Congestion control transactions:** a spender pays a single output
  that uses CTV to commit to a follow-up transaction that pays multiple
  outputs.  When the initial transaction is confirmed to a suitable
  depth, this can assure the parties with outputs in the follow-up
  transaction that they will eventually be paid (e.g. when feerates are
  lower).  This two-step process can probably be used anywhere [payment
  batching][topic payment batching] is an option, although it requires
  extra communication to receivers for them to learn that they have been
  paid prior to the follow-up transaction being confirmed.

- **Channel factories:** each change to a [channel factory's][topic
  channel factories] top-level state requires each party to receive a
  unilateral exit transaction that refunds them their current balance in
  the factory in case other parties later become unresponsive.  Without
  CTV or something similar, unilateral exit transactions must be signed
  by all participants in a channel factory before each member signs the
  new state transaction, requiring two full rounds of communication.
  With CTV, a commitment to the refund transaction can be included
  directly in the next state transaction.  This allows any party to
  propose a state transition that only requires one round of signing.
  Channel factories may also benefit from other uses of CTV, such as
  allowing channels to be opened in congestion control transactions.
  Channel factories have a similar structure to joinpools, so any
  features of CTV joinpools described below may also apply to CTV
  channel factories.

- **Joinpools:** similar to a channel factory, multiple users can [pool
  their funds together][topic joinpools] by creating a UTXO that allows
  any of them to unilaterally withdraw their funds at any time or allows
  all of them in agreement to spend a portion of the funds.  This is
  possible today by having each participant sign the unilateral exit
  transaction for the next state before they sign the next state, but
  this requires two rounds of signing.  When the number of parties
  needed to sign is large, each round can take a long time.  CTV reduces
  the amount of signing to one round.

  Additionally, when one party wants to unilaterally exit a joinpool or
  channel factory, some other parties may want to remain in the joinpool
  (or form subsets of the original joinpool).  This can minimize the
  amount of onchain fees that need to be paid by each party.  Remaining
  in an existing joinpool requires each party agree to the outcomes for
  each other party exiting.  Using presigned exits, the most efficient
  onchain version of this requires generating and transmitting a large
  number of offchain signatures, making it impractical for more
  than a few users to participate in any individual joinpool with
  per-party exit paths.  Using CTV, signature operations can be
  replaced with CTV operations, which leaves the computational
  complexity but doesn't require transmitting any additional data---each
  user can derive the necessary data on their own (which they would need
  to do anyway to validate the script they're paying).  Again, only the
  one round of signatures for each state transition would need to be
  communicated.  Alternative consensus change proposals specifically
  designed to make joinpools with per-party exits efficient onchain have
  been [proposed][tluv] several [times][op_evict], although some of
  their authors have mentioned that CTV would be complementary to their
  proposals. <!-- TODO:add citation; in particular I (harding) recall AJ saying this about TLUV -->

- **Vaults:** without CTV or another consensus change, the only known way
  to create a [vault][topic vaults] is using ephemeral keys and
  presigned transactions that give spends to the vault's recovery
  address priority over spends to a third-party.  Any ephemeral keys used
  in the vault setup need to be securely deleted.  This approach is
  fragile at best, making it reasonable for anyone with a large amount of
  funds---the ideal vault user---to be wary of trusting presigned vaults
  with large amounts of money.  By comparison, a CTV vault can replace
  each use of ephemeral keys with a CTV output, which can be entirely
  precomputed without any special key handling considerations.  The
  result is still less dynamic than many users might like, so specific
  consensus changes for vaults have been proposed, with at least one of
  those proposals ([BIP345][] `OP_VAULT`) using CTV in some of its
  operations.

- **DLC efficiency:** [discreet log contracts][topic dlc] (DLCs) often
  involve a large number of potential outcomes; for example, "what price
  will Bitcoin be in USD terms at the end of the day, rounded to the
  nearest whole dollar?" might easily involve more than 10,000 different
  outcomes.  Using existing DLC constructions, each outcome requires
  a separate [signature adaptor][topic adaptor signatures] that must be
  created, exchanged, verified, and stored.  By comparison, CTV can
  replace the adaptors and allow each party to independently compute
  most of the state from a short specification of the
  contract---minimizing bandwidth and storage.  A few signatures and
  adaptors are still needed, but the vast majority are eliminated.

## Alternatives to CTV

Many alternatives to CTV have been proposed.  The following have been
covered by Optech:

- **Presigned transactions:** anything CTV can do can also be done using
  presigned transactions and secure deletion of ephemeral keys.
  However, this requires perfectly reliable backups and deletion.  For
  CTV, deletion is not required and the amount of data that needs to be
  reliably backed up consists of only the data a user expects to put
  onchain anyway (some of which it may be possible to compute as needed).

- **SIGHASH_ANYPREVOUT:** this [proposal][topic sighash_anyprevout],
  which was designed to [improve payment channels][topic eltoo] before
  the announcement of CTV, can substitute for CTV in many cases (but not
  all), although it requires extra onchain vbytes to accomplish patterns
  that CTV is optimized for.  At least one [variant of
  SIGHASH_ANYPREVOUT][poinsot apo] has been proposed to extend the
  number of CTV usecases covered, although it still requires extra
  vbytes.

- **OP_CAT + OP_CHECKSIGFROMSTACK:** the composition of the proposed
  [OP_CAT][topic op_cat] and [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] opcodes can emulate CTV, although this may
  require significantly more vbytes.

- **OP_TX and OP_TXHASH:** are [roughly][op_tx] equivalent
  [proposals][op_txhash] to enable CTV features in a way that might be
  easier to extend in the future.  Depending on the exact design, they
  may require slightly more vbytes to use than CTV.

- **Exploding keys:** this [proposal][dryja exploding keys] provides the
  core feature of CTV: the ability for a transaction output to commit to
  the outputs of the transaction that will spend it.  CTV accomplishes
  this using a hash digest on the stack; exploding keys accomplishes it
  using a [pay-to-contract][topic p2c]-like commitment to the hash
  digest.  The most efficient form of CTV use the same number of vbytes
  as exploding keys.  However, if the creator of a covenant wants to
  allow [taproot][topic taproot] keypath spends as an option, exploding
  keys can save at least 16 vbytes compared to CTV when the keypath
  option is not used.  Exploding key keypath spends would be indistinguishable
  from standard keypath spends made using the same segwit versions,
  improving privacy.  However, creating exploding keys uses elliptical
  curve operations rather than SHA256 hash operations, the later
  generally being faster to compute on general CPUs and for which many
  modern chipsets offer hardware optimization; this could make CTV much
  preferable for cases involving large contracts states, such as DLCs
  and joinpools.

## Criticisms of CTV

Several criticisms of CTV have been covered by Optech:

- **Not flexible enough:** CTV was deliberately designed to provide a
  limited function that would be useful in a variety of constructions
  but without enabling [recursive covenants][topic covenants].  However,
  [some critics][corallo flexible] would [prefer][corallo costs] to see
  a more general covenant solution.  They worry that many of the people
  who ask for CTV now will not be satisfied with it.  They may later ask
  for an improved construction that could render CTV unnecessary.  They
  advocate instead for effort to be devoted to finding a solution that
  will fully satisfy user desires.

- **Not generic enough:** CTV is almost maximally efficient at allowing
  an output to require it be spent to certain future outputs.  It
  additionally provides some flexibility in the construction of that
  spending transaction, mainly related to which inputs it includes.
  However, its capabilities overlap to a significant degree with other
  [covenant][topic covenants] proposals, so it has been
  [suggested][oconnor composable] that it would be better to use
  composable elements to replicate the features of CTV.  Those elements
  may also be useful on their own, or they may be extensible in ways
  that don't necessarily make sense for CTV.  This is the origin of
  proposals such as `OP_TX` (described previously).

- **Limited experimentation:** an [analysis][towns ctv usage] in 2022
  found limited experimentation with CTV on [signet][topic signet],
  although at least some additional experimentation has been performed
  since then.

- **Commonly requires exogenous fees:** CTV commitments to future
  transactions may be created long before those transactions are
  broadcast, making [fee estimation][topic fee estimation] challenging.
  A common solution to this is to allow [CPFP fee bumping][topic cpfp]
  and other types of [exogenous fee contribution][topic fee sourcing].  However,
  at least one reviewer has [argued][todd exogenous] that widespread use
  of exogenous fee sourcing puts Bitcoin's decentralization at risk due
  to an incentive to [pay fees out of band][topic out-of-band fees].

## Compositions of CTV and other consensus changes

Many proposals have been made for using CTV in combination with other
consensus changes.  Some of the proposals covered by Optech include:

- **CTV and OP_VAULT:** the [BIP345][] `OP_VAULT` proposed soft fork is
  designed (in its latest versions) to work directly with CTV for
  committing to spending operations for creating dynamic [vaults][topic
  vaults].

- **OP_VAULT alternative using MATT and CTV:** the [MATT][topic acc]
  proposed soft fork has been described as being able to almost emulate
  `OP_VAULT` when combined with CTV and two other opcodes.  This proposal
  appears mainly designed to showcase the flexibility of MATT rather
  than suggest activating MATT and CTV instead of `OP_VAULT` and CTV.

- **CTV and OP_CHECKSIGFROMSTACK:** the [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] (CSFS) proposed soft fork allows verifying that
  a signature on the stack commits to another item on the stack.  This
  is in comparison to existing signature verification operations in
  Bitcoin that verify that a signature commits to a large amount of data
  and metadata for the executing transaction.  It's [proposed][news285
  lnhance] that CTV and CSFS together can emulate the proposed
  `SIGHASH_ANYPREVOUT` (APO) soft fork and so can enable versions of
  [LN-Symmetry][topic eltoo] (eltoo).

## History

A simple covenant that committed to outputs was originally proposed as
`OP_CHECKOUTPUTSHASHVERIFY` (COSHV).  Its author updated it and gave the
updated version the name, `OP_SECURETHEBAG`.  The author later updated
it again and again used a different name,
`OP_CHECKTEMPLATEVERIFY`.  The earliest public version of the proposal
allowed use of inputs differently than the current proposal.  A later
[extension][ctv extensions] to the proposal would allow use of 20-byte hash
digests in addition the existing allowed use of 32-byte hash digests,
plus allow the inclusion of additional commitments that must be
provided as witness items when CTV is executed.

{% include references.md %}
[corallo flexible]: /en/newsletters/2019/05/29/#not-flexible-enough
[oconnor complexity]: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
[towns ctv usage]: /en/newsletters/2022/04/27/#analyzed
[corallo costs]: /en/newsletters/2022/04/27/#argued
[poinsot apo]: /en/newsletters/2022/04/27/#requested
[todd exogenous]: /en/newsletters/2024/01/31/#opposition-to-ctv-based-on-commonly-requiring-exogenous-fees
[ctv extensions]: /en/newsletters/2024/05/15/#bip119-extensions-for-smaller-hashes-and-arbitrary-data-commitments
[op_tx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[op_txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[dryja exploding keys]: /en/newsletters/2024/05/01/#ctv-like-exploding-keys-proposal
[oconnor composable]: /en/newsletters/2019/05/29/#not-generic-enough
[tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[op_evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[news285 lnhance]: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
