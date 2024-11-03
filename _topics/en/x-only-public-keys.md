---
title: X-only public keys

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

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BIP340 schnorr signatures for secp256k1"
      link: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki#design

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Suggestion to use x-only public keys in taproot"
    url: /en/newsletters/2019/05/29/#move-the-oddness-byte

  - title: "Request for discussion about using x-only public keys in taproot"
    url: /en/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys

  - title: "Summary of updates to taproot proposal, including x-only public keys"
    url: /en/newsletters/2019/10/16/#taproot-update

  - title: "Taproot review: blog post published about x-only pubkeys"
    url: /en/newsletters/2019/11/13/#taproot-review-discussion-and-related-information

  - title: "Alternative x-only tiebreaker proposed and discussion of safety of precomputed pubkeys"
    url: /en/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker

  - title: "X-only workaround for covenant-based protocols"
    url: /en/newsletters/2022/07/13/#x-only-workaround

  - title: "Core Lightning #5646 updates the experimental implementation of offers to remove x-only public keys"
    url: /en/newsletters/2022/11/02/#core-lightning-5646

  - title: "Libsecp256k1 #993 includes in the default build options a modules for working with x-only pubkeys"
    url: /en/newsletters/2022/11/30/#libsecp256k1-993

  - title: "Should an even Y coordinate be enforced after every key-tweak operation, or only at the end?"
    url: /en/newsletters/2024/06/28/#should-an-even-y-coordinate-be-enforced-after-every-key-tweak-operation-or-only-at-the-end

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Schnorr signatures
    link: topic schnorr signatures

  - title: Taproot
    link: topic taproot

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **X-only public keys** are public keys for the secp256k1 elliptic
  curve that only provide the _x_ coordinate for their position in the
  finite field.  This is in comparison to _uncompressed public keys_ that
  provide both their _x_ and _y_ coordinates and _compressed public
  keys_ that provide their _x_ coordinate plus an additional bit to
  differentiate the two _y_ alternatives.

---
Bitcoin public keys are points on the secp256k1 elliptic curve over
a 256-bit finite field.  It's easy to describe such a point by giving
its _x_ and _y_ coordinates, using a 256-bit number for each (32 bytes
each, for a total of 64 bytes).  Uncompressed public keys do this,
adding a prefix byte for a total of 65 bytes.

If we describe just the _x_ coordinate and use the curve equation to
derive the _y_ coordinate, we find that each _x_ coordinate corresponds
to two different _y_ coordinates.  This allows us to compact our
description to 256 bits for the _x_ coordinate plus a single extra bit
to indicate which of the _y_ coordinates to use.  Compressed public keys
do this, containing the bit within their prefix byte for a total of 33
bytes.

The extra bit can be eliminated if only one of the two alternative _y_
coordinates is allowed.  X-only public keys do this, using a total of
32 bytes.  Segwit v1 ([taproot][topic taproot]) and the initial version
of [tapscript][topic tapscript] use x-only public keys for all signature
checking operations to reduce the size of public keys.

The advantage of x-only public keys is that they save space.  The
downside is that public keys need to be generated in a way that ensures
they only use the allowed _y_ coordinate.  This is easy for a wallet
generating a public key but it
was later realized that it could be quite challenging for any
[covenant][topic covenants] that needed to modify taproot witness
programs that commit to both a [MAST][topic mast]-like tree of scripts
and an x-only internal public key.

{% include references.md %}
{% include linkers/issues.md issues="" %}
