---
title: OP_CHECKSIGFROMSTACK

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **OP_CHECKSIGFROMSTACK (OP_CSFS)** is an opcode on
  ElementsProject.org-based sidechains that is sometimes proposed for
  implementation on Bitcoin.  The opcode allows checking whether a
  signature signs an arbitrary message.  The opcode takes three
  parameters: a signature, a message, and a public key.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: OP_CHECKSIGFROMSTACK code from ElementsProject.org
      link: https://github.com/ElementsProject/elements/blob/f08447909101bfbbcaf89e382f55c87b2086198a/src/script/interpreter.cpp#L1399

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Discussion of potential script changes, including `OP_CSFS`
    url: /en/newsletters/2019/06/12/#potential-script-changes

  - title: "Criticism of `OP_COSHV` and `SIGHASH_ANYPREVOUT`; `OP_CSFS` as alternative"
    url: /en/newsletters/2019/05/29/#not-generic-enough

  - title: "Discussion: the evolution of Bitcoin Script, `OP_CSFS` discussion"
    url: /en/newsletters/2018/10/09/#op-checksigfromstack

  - title: "Replicating `OP_CHECKSIGFROMSTACK` with schnorr signatures and `OP_CAT`"
    url: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat

  - title: "Call for `OP_CHECKSIGFROMSTACK` design suggestions"
    url: /en/newsletters/2021/07/14/#request-for-op-checksigfromstack-design-suggestions

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Covenants in Elements Alpha
    link: https://blockstream.com/2016/11/02/en-covenants-in-elements-alpha/

  - title: Covenants
    link: topic covenants
---
Bitcoin's existing signature-checking opcodes, such as `OP_CHECKSIG`,
don't allow specifying an arbitrary message.  The message they use is
derived from the transaction executing the signature-checking opcode.
This allows them to verify that the signature matches a certain public
key and that the private key used to generate both of those objects
was used to authorize the spend.  That mechanism is powerful enough to
secure Bitcoin UTXOs, but it precludes using digital signatures to
authenticate other types of data in the Bitcoin system.  The ability
to use `OP_CSFS` to verify an arbitrary message can enable several new
features for Bitcoin users:

- **Paying for signatures:** if Alice controls a private key that can
  sign a transaction paying Bob, Bob can use OP_CSFS to trustlessly
  offer to pay Alice for the signature he needs.  <!-- No source for
  this claim, but it seems obvious to me. -->

    More recently, protocols involving paying for signatures typically
    [assume the use of adaptor signatures][kohen selling sigs] that
    are more private and which use less block space.

- **Delegation:** Alice might want to delegate the authority to spend
  her coins to Bob without explicitly creating an onchain transaction
  transferring the coins to a 1-of-2 multisig between her and Bob.  If
  Alice designs her scripts with this sort of delegation in mind, she
  can put Bob's pubkey in a message and use OP_CSFS to prove that
  she's delegated spending authority to that key.  <!-- Source:
  "CHECKSIGFROMSTACK says you are going to push stuff on the stack,
  hash it, and then you can verify arbitrary pubkey privkey pairs. You
  can do this for delegation."
  https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-noinput-etc/
  -->

    An alternative approach that's more private, more flexible, and
    more block-space efficient is [graftroot][], although this
    requires a soft fork that has so far only been lightly discussed.

- **Oracles:** an oracle may agree to sign a message indicating the
  outcome of an event, e.g. the name of the national team that wins a
  sporting event.  Two or more users can then deposit money into a
  script using OP_CSFS that will pay a different person depending on
  which team the oracle indicates was the winner.  <!-- Source: "[...]
  any kind of outside oracle data. Say we're betting on price, and we
  have Bitstamp's key hardcoded in the script."
  https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2019-06-06-noinput-etc/
  -->

    More recent focus on oracle-moderated contracts involves using
    [Discreet Log Contracts][dlcs] (DLCs), which can be more private
    and more block-space efficient.

- **Double-spent protection bonds:** a service may promise to never
  try to double spend its UTXOs in order to encourage its payees to
  accept its unconfirmed transactions as reliable payments.  To
  demonstrate its good faith, the service can use OP_CSFS to offer
  payment of a bond to any user that can prove the same key was used
  to create two different signatures for transactions spending the
  same UTXO.  <!-- Source: "These new opcodes have several use cases,
  including double-spent protection bonds"
  https://web.archive.org/web/20160828061959/http://elementsproject.org/elements/opcodes
  -->

    This use of `OP_CSFS` can be compared to [single-show
    signatures][] that allow anyone who sees two signatures from the
    same key to derive the private key used to create them, allowing
    them to spend any other funds secured by that key.

- **Transaction introspection:** If the same pubkey and signature pair
  are valid both with `OP_CSFS` and `OP_CHECKSIG`, then the contents
  of the arbitrary message passed to `OP_CSFS` is identical to the
  serialized spending transaction (and other data) implicitly used
  with `OP_CHECKSIG`.  This makes it possible to put a validated copy
  of the spending transaction on the script evaluation stack where
  other opcodes can run tests on it in order to enforce restrictions
  on the spending transaction.

    For example, if `OP_CSFS` had been available in 2015 and 2016, it
    would've been possible to implement the features of [BIP65][]
    `OP_CHECKLOCKTIMEVERIFY` (CLTV) and [BIP112][]
    `OP_CHECKSEQUENCEVERIFY` (CSV) using without any consensus changes
    just by writing a verification script.

    Looking forward, `OP_CSFS` could also allow scripts to [implement
    the features][oconnor generic] of the proposed [SIGHASH_ANYPREVOUT][topic
    sighash_anyprevout] signature hash, as
    well as other opcode proposals such as
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify].
    Additionally, `OP_CSFS` would allow the creation of
    [covenants][topic covenants] that restrict the way in which a set
    of bitcoins may be spent---for example, a [vault][topic vaults] may
    restrict its spending transaction to a small set of acceptable
    scriptPubKeys to limit the risk of theft.

    The strength of `OP_CSFS` is that it provides full introspection
    of the signing transaction in a completely generic way.  Its
    weakness is that it requires essentially adding a complete copy of
    the signing transaction to the stack, which may significantly
    increase the size of transactions that want to use `OP_CSFS` for
    introspection.  By comparison, single-purpose introspection
    opcodes such as CLTV and CSV use minimal overhead, but adding each
    new special introspection opcode requires a consensus change and
    it may not be possible to disable their use (even if they become
    unpopular) without risking someone losing money.

### Relationship to OP_CAT

Proposals to add `OP_CSFS` to Bitcoin are often combined with
proposals to restore the `OP_CAT` opcode [removed][dead cat] as part
of the response to the [value overflow incident][].  This opcode
[catenates][] two elements, appending one to the other.  This makes it
possible to construct a message (such as a serialized transaction) by
appending together individual parts of the message (e.g. the fields of
a transaction).  Initializing the stack with the message already split
into parts simplifies the writing of scripts that perform tests on
those parts.  Beyond the basic risks of adding any new consensus
code to Bitcoin, there are no published downsides of adding `OP_CAT`.

{% include references.md %}
[dead cat]: https://github.com/bitcoin/bitcoin/commit/4bd188c4383d6e614e18f79dc337fbabe8464c82#diff-8458adcedc17d046942185cb709ff5c3R94
[value overflow incident]: https://en.bitcoin.it/wiki/Value_overflow_incident
[catenates]: https://english.stackexchange.com/questions/125416/concatenate-vs-catenate
[kohen selling sigs]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002077.html
[dlcs]: https://dci.mit.edu/smart-contracts
[single-show signatures]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2014-December/007038.html
[graftroot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[oconnor generic]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016946.html
