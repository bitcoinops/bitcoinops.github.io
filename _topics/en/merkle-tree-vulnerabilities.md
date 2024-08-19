---
title: Merkle tree vulnerabilities

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Security Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: "Weaknesses in Bitcoin's Merkle Root Construction"
    link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/attachments/20190225/a27d8837/attachment-0001.pdf

  - title: "CVE-2012-2459: block merkle calculation exploit"
    link: https://bitcointalk.org/?topic=102395

  - title: Leaf-Node weakness in Bitcoin Merkle Tree Design
    link: https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Bitcoin Core #29412 checks for every known way to mutate a valid block into an invalid block"
    url: /en/newsletters/2024/03/06/#bitcoin-core-29412

  - title: Disclosure of invalidity caching vulnerability
    url: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure

  - title: "Bitcoin Core #27608 protects against an invalidity caching vulnerability"
    url: /en/newsletters/2023/05/17/#bitcoin-core-27608

  - title: "CVE-2017-12842 leaf-node weakness"
    url: /en/newsletters/2018/12/28/#cve-2017-12842

  - title: "CVE-2017-12842: discussion about minimum transaction size"
    url: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion

  - title: "CVE-2017-12842: merkle tree fix proposed in consensus cleanup soft fork"
    url:  /en/newsletters/2019/03/05/#merkle-tree-attacks

  - title: "CVE-2017-12842: discussion of lowering minimum relayable transaction size"
    url: /en/newsletters/2022/10/19/#minimum-relayable-transaction-size

  - title: "CVE-2017-12842: Bitcoin Core PR Review Club discussion about lowering min relayable tx size"
    url: /en/newsletters/2022/11/09/#bitcoin-core-pr-review-club

  - title: "LDK #3215 rejects transactions less than 65 bytes to protect against merkle tree vulnerabilites"
    url: /en/newsletters/2024/08/16/#ldk-3215

## Optional.  Same format as "primary_sources" above
see_also:
  - title: CVEs
    link: topic cves

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Merkle tree vulnerabilities** are a class of problems in the design
  of the merkle tree used by the Bitcoin consensus protocol.

---

A [merkle tree][] whose number of elements is a power of two can trivially
be compressed into a merkle root: for a given set of elements (e.g. {A,
B, C, D}) create pairs of elements (e.g. {A,B}) and hash them together;
take the resultant internal elements (e.g., {AB, CD}}), create pairs,
and hash them together again.  Repeat until only one element remains,
the merkle root (e.g. {ABCD}).

```text
     ABCD
    /    \
  AB      CD
 /  \    /  \
A    B  C    D
```

Merkle trees allow a single 32-byte hash digest, called a _merkle root_,
to commit to all of the transactions in a block in a way that
allows creating very space-efficient proofs of inclusion (called
_partial merkle proofs_).  However, Bitcoin blocks may contain a number
of transactions that is not a power of two, requiring a more complicated
algorithm to construct the merkle root.  The algorithm chosen for
Bitcoin hashes any unbalanced element with itself:

```text
     ABCC
    /    \
  AB      CC
 /  \    /
A    B  C
```

There's also the special case of a block with only one transaction
having its hash used as the merkle root:

```text
A
|
A
```

The subsequent sections describe several vulnerabilities associated with
this algorithm, along with their deployed mitigations.

## Invalidity caching

Bitcoin Core prevents wasting bandwidth, CPU, and memory
downloading and validating invalid blocks multiple times by caching the
header hash of recently seen blocks that are known to be invalid.
However, an attacker could modify a valid block to make it look like an
invalid block.  Consider the following valid block from our description
above:

```text
     ABCC
    /    \
  AB      CC
 /  \    /
A    B  C
```

The attacker can modify that block by duplicating the final transaction
to create a block with an identical merkle root but which is invalid (as
the second _C_ transaction spends a UTXO that was already spent in the
first _C_ transaction, the double spending of UTXOs being forbidden):

```text
     ABCC
    /    \
  AB      CC
 /  \    /  \
A    B  C    C{% comment %}<!-- skip-test -->{% endcomment %}
```

If Bitcoin Core saw the invalid form of the block first, it would store
its block header hash in its invalidity cache and refuse to accept the
valid form of the block from any of its peers until the cache was
cleared (which occurs when the node is restarted).  An attacker could
use this to [eclipse attack][topic eclipse attacks] particular nodes.

The vulnerability was [reported][voight merkle] in 2012, assigned
[CVE-2012-2459][topic cves], and quietly fixed without ever being
exploited (to the best of our knowledge).

A [variation][news37 merkle] of the vulnerability was re-introduced into
Bitcoin Core in version 0.13.0 (2016) and quietly fixed in version
0.14.0 (2017).  Another variation was discovered and
[fixed][news251 merkle] in 2023.  A refactor of related code intended to prevent the
problem from recurring in the future was [added][news292 merkle] in
early 2024.

[news37 merkle]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
[news251 merkle]: /en/newsletters/2023/05/17/#bitcoin-core-27608
[news292 merkle]: /en/newsletters/2024/03/06/#bitcoin-core-29412

## Transactions as txids and vice versa

The same hash algorithm is used to compute merkle leaf nodes as internal
nodes.  A leaf node is `sha256d(<transaction>)` and an internal node is
`sha256d(<X>|<Y>)`, where `|` represents concatenation and `X` and `Y`
are each 32-byte hash digests from a leaf node or another internal node.

That means the two 32-byte digests can masquerade as a 64-byte
transaction.  This can be used to make a valid block look like an
invalid block, triggering the invalidity caching attack described in the
previous section.  For example:

![Diagram of two identical merkle roots derived from different block data](/img/posts/2019-03-merkle-ambiguity.svg)

The reverse is also possible: a 64-byte transaction can masquerade
as two 32-byte digests.  One of those digests can be the hash of a
partial merkle branch that references legitimate-seeming transactions.
For example, the actual block may include valid 64-byte transaction _X_:

```text
     ABCX
    /    \
  AB      CX
 /  \    /  \
A    B  C    X
```

But _X_ can also be interpreted as internal hash _EF_:

```text
     ABCX
    /    \
  AB      CX
 /  \    /  \
A    B  C   EF
           /  \
          E    F
```

The Bitcoin P2P protocol message used to relay blocks, `block`, includes
a field that indicates how many transactions a block contains.  The
number of transactions in a block indicates the shape of its merkle
tree, as every transaction must be on the bottom row of the tree.  The
derived shape of the merkle tree is used to verify that a block header's
merkle root commits to every transaction in a block.  For example, the
tree above, which seems to contain the transactions _E_ and _F_, is
mishapen, so a full node would consider it invalid.

Every committed transaction must also be valid for the block to be
valid.

The pre-image and second-preimage resistance of the SHA256d hash
function makes it extremely computationally improbable that the hash of a
valid 64-byte transaction will correspond to the two hashes of known valid
internal merkle nodes.  That means it should not be possible to produce
two valid versions of the same block with different sets of transactions:
one set that includes a single 64-byte valid transaction and another set
that includes two or more valid transactions lower in the merkle tree to
the two halves of that 64-byte value.

That means Bitcoin Core's validation of merkle tree shape and
every transaction should make it impossible to trick different full
nodes into accepting different sets of transactions that can lead to a
chainsplit.

However, lightweight clients using _simplified payment verification_
(SPV) do not validate every transaction in a block (often they don't
fully validate any of them).  They simply check that a block header
merkle root commits to any transactions of interest.  In that case, it's
computationally feasible (though still expensive) to create a valid
transaction can be interpreted as a commitment one valid 32-byte
internal merkle node (the other commitment being invalid).  This attack
was discovered in 2017 and is known as [CVE-2017-12842][topic cves].

Several ways are known for mitigating or fixing this attack:

- Honest services providing merkle branch information to lightweight
  clients can tell them how many transactions the full block contains,
  allowing the lightweight client to verify that the partial merkle
  branch they're interested in corresponds to the shape of the full
  block.  This requires the lightweight client to trust the server (or poll
  multiple servers, one of which must be honest).

- A soft fork can make 64-byte transactions invalid.  This has been
  proposed as part of the [consensus cleanup][topic consensus cleanup]
  soft fork.  A 64-byte transaction only has enough space to spend
  an output that doesn't contain any meaningful security, so nobody should
  be using them for secure purposes, perhaps making it reasonable to
  consider them invalid.

Note: that when we say "64 bytes" above, we are referring to a transaction's
_stripped size_, its size in the pre-segwit legacy serialization format,
which is what's used to connect a transaction to the merkle root.  This
may be different than its size in vbytes.

## Alternative merkle tree algorithms

New additions to Bitcoin's consensus rules, such as those added in the
[taproot][topic taproot] soft fork, use merkle trees in several new
ways.  Their construction includes different rules for working with
unbalanced trees and uses slightly different hash digest algorithms for
different parts of the merkle tree, reducing the risk that one element
will be conflated for another.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[voight merkle]: https://bitcointalk.org/?topic=102395
[merkle tree]: https://en.wikipedia.org/wiki/Merkle_tree
