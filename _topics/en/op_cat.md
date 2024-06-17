---
title: OP_CAT

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BIN24-1: `OP_CAT`"
      link: https://github.com/bitcoin-inquisition/binana/blob/master/2024/BIN-2024-0001.md

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Replicating `OP_CHECKSIGFROMSTACK` with schnorr signatures and `OP_CAT`"
    url: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat

  - title: "Example of using the MATT proposal plus OP_CAT to manage joinpools"
    url: /en/newsletters/2023/06/07/#using-matt-to-replicate-ctv-and-manage-joinpools

  - title: "Alternative to COSHV (CTV) and SIGHASH_ANYPREVOUT: OP_CAT and OP_CHECKSIGFROMSTACK"
    url: /en/newsletters/2019/05/29/#not-generic-enough

  - title: "Discussion about `SIGHASH_ANYPREVOUT` spins off into discussion about `OP_CAT`"
    url: /en/newsletters/2019/10/09/#continued-discussion-about-noinput-anyprevout

  - title: "Discussion about `OP_CHECKSIGFROMSTACK` branches off into discussion about `OP_CAT`"
    url: /en/newsletters/2021/07/14/#request-for-op-checksigfromstack-design-suggestions

  - title: "Examination of the minimal set of features added to `OP_CAT` that would create recursive covenants"
    url: /en/newsletters/2022/05/18/#when-would-enabling-op-cat-allow-recursive-covenants

  - title: "Ark proposal would benefit from `OP_CAT` and `OP_CHECKSIGFROMSTACK`"
    url: /en/newsletters/2023/05/31/#proposal-for-a-managed-joinpool-protocol

  - title: "Proposed BIP for `OP_CAT`"
    url: /en/newsletters/2023/10/25/#proposed-bip-for-op-cat

  - title: "Comments on draft BIP for `OP_CAT`"
    url: /en/newsletters/2023/11/01/#op-cat-proposal

  - title: "Simple vault prototype using `OP_CAT` and schnorr signatures"
    url: /en/newsletters/2024/02/28/#simple-vault-prototype-using-op-cat

  - title: "Bitcoin PR Review Club for `OP_CAT` on signet with Bitcoin Inquisition"
    url: /en/newsletters/2024/03/13/#bitcoin-core-pr-review-club

  - title: "BIPs #1525 adds BIP347 which proposes an `OP_CAT` opcode for tapscript"
    url: /en/newsletters/2024/05/15/#bips-1525

  - title: "Bitcoin Inquisition 27.0 begins enforcing `OP_CAT` on signet"
    url: /en/newsletters/2024/05/24/#bitcoin-inquisition-27-0

  - title: "`OP_CAT` script to validate proof of work"
    url: /en/newsletters/2024/06/07/#op-cat-script-to-validate-proof-of-work

## Optional.  Same format as "primary_sources" above
see_also:
  - title: OP_CHECKSIGFROMSTACK
    link: topic op_checksigfromstack

  - title: OP_CHECKTEMPLATEVERIFY
    link: topic op_checktemplateverify

  - title: MATT
    link: topic matt

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **OP_CAT** was originally an opcode in Bitcoin.  It was disabled in
  2010 but slight variations on it are frequently proposed to be
  added to Bitcoin using a soft fork.

---
Both the original `OP_CAT` and the new proposals for it
concatenate two elements on the stack into a single element.  For
example, the following script:

    <0xB10C> <0xCAFE> OP_CAT

Would become:

    <0xB10CCAFE>

The primary expected use for `OP_CAT` is for data provided by the
creator of a script to be concatenated with data provided by someone
spending from that script.  For example, Alice wants to create an
equivocation bond that she can't create competing spends for without
putting her funds at risk.  She generates a private key in the normal
way, derives a public key from it in the normal way, chooses a
random private nonce the same way she usually would for a [schnorr
signature][topic schnorr signatures], and derives the public nonce also
in the normal way.  She then pays to the following script:

    <public nonce> OP_CAT <pubkey> OP_CHECKSIG

Later, when she signs, instead of providing a complete schnorr
signature---which includes both a public nonce and a scalar---she's
forced to use the public nonce from her script.  In her witness field,
she only provides the scalar.  The scalar and the public nonce are
concatenated together to produce a [BIP340][] schnorr signature, which
is then verified against Alice's public key like normal using the
`OP_CHECKSIG` opcode.

If Alice later tries to sign a different version of the transaction,
she's forced to reuse the same public nonce but must (because of the
BIP340 equation) generate a different scalar.  This reuse of the same
nonce in different signatures from the same private key allows anyone to
derive her private key.  They can then create their own signatures for
Alice's private key, potentially spending her funds if they haven't been
spent already.

There are many other proposed applications of `OP_CAT`, see [BIN24-1][]
for one list.  Some applications, such as the example above, are
possible with just `OP_CAT` and other features that are already part of
Bitcoin script; other applications require additional new opcodes or
other changes to Bitcoin.

{% include references.md %}
{% include linkers/issues.md issues="" %}
