---
title: Accidental confiscation

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Soft Forks
  - Transaction Relay Policy

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Invalidation of `OP_CODESEPARATOR` could prevent existing UTXOs from being spent"
    url: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion

  - title: "Amnesty proposed for potential old uses of `OP_CODESEPARATOR` in new cleanup proposal"
    url: /en/newsletters/2024/04/03/#revisiting-consensus-cleanup

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Soft fork activation
    link: topic soft fork activation

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Accidental confiscation** can occur if a poorly designed soft fork
  permanently prevents a user from being able to get a transaction
  confirmed.

---
A soft fork is a restriction on the previous consensus rules.  If a soft
fork overly restricts the use of a feature that a user needs to spend
some bitcoins they previously received, those bitcoins will become
unspendable unless the soft fork behavior is changed in a later hard
fork.

Such confiscation can be done deliberately, in which case the operators
of economic full nodes who enforce the consensus rules need to decide if
the benefits of a confiscatory soft fork outweigh its problems.  But it
can also happen accidentally if a soft fork is poorly designed or if
there's poor communication between consensus developers and developers
of contract protocols.  Three particular risks stand out:

- **Unknown use of upgrade features:** some features of the consensus
  protocol, such as the `OP_NOPx` and `OP_SUCCESSx` opcodes are reserved
  for future soft forks.  If anyone begins using them before a soft
  fork, they could become a victim of accidental confiscation.  For that
  reason, Bitcoin Optech _very_ strongly recommends anyone considering
  use of a feature reserved for soft fork upgrades publicly announce
  their plans to protocol developer communication channels and
  proactively monitor any discussion of new soft forks for changes to
  the features being used.

- **Presigned transactions:** some contract protocols and uses of
  Bitcoin may require a user to generate a spending transaction, sign it
  with the necessary private keys, and then delete the private keys.
  This prevents them from being able to sign alternative versions of the
  transaction.  If the Bitcoin consensus rules are changed to make the
  spending transaction invalid, the user's funds are lost.  Optech
  recommends that presigned transaction protocols be well documented,
  they be checked against standardness policy (see below), and that
  anyone using them monitor any discussion of new soft fork proposals
  for changes that would render those transactions invalid.

- **Committed scripts:** P2SH, P2WSH, and P2TR scriptpaths are all
  scripts that do not appear on the blockchain when the user commits to
  potentially using them.  Any soft fork restriction to the scripting
  language can make a previously satisfiable script into one that cannot
  be satisfied.   Optech makes the same recommendation here as we do for
  presigned transactions.

## Relationship to transaction standardness policy

Full nodes such as Bitcoin Core will not relay certain transactions,
allow them into their mempools, or put them in block templates---even if
those transactions are valid according to the current consensus rules.
There are a variety of reasons for the transaction relay policies, but
some of those policies exist to discourage anyone from using features
reserved for future soft fork upgrades.

For example, if you create a transaction at present which executes
`OP_NOP9`, that transaction will be considered non-standard and will not
be relayed while it is unconfirmed.  It's still valid in a block and all
full nodes must accept it in a block to remain in consensus.

The goal is for anyone who begins using a reserved feature to quickly
discover that transactions using that feature are hard to get mined.
They can then either switch to an alternative method of accomplishing
the same thing or they can convince full node developers to change their
relay policy, which hopefully serves as sufficient public notification
that the feature is being used, preventing later accidental confiscation.

{% include references.md %}
{% include linkers/issues.md issues="" %}
