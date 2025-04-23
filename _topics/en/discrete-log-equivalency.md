---
title: "Discrete log equivalency (DLEQ)"

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: dleq

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - "Proofs of discrete log equivalency (PODLE)"

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: "P(o)ODLE"
    link: https://reyify.com/blog/p-o-odle/

  - title: Proposed DLEQ BIP
    link: https://github.com/bitcoin/bips/pull/1689

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: PODLE proposed for use in dual-funded LN channels
    url: /en/newsletters/2020/02/05/#podle

  - title: Analysis of proposal to use PODLE in dual-funded LN channels
    url: /en/newsletters/2020/02/19/#using-podle-in-ln

  - title: New proposal to prevent UTXO probing in LN dual funding compared to PODLE
    url: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing

  - title: "C-Lightning #4410 updates to latest dual-funding specification draft, which no longer uses PODLE"
    url: /en/newsletters/2021/03/17/#c-lightning-4410

  - title: Continued discussion of PSBTs for silent payments with DLEQ proofs to verify correct ECDH generation
    url: /en/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments

  - title: Draft BIP for DLEQ proofs
    url: /en/newsletters/2024/11/01/#draft-bip-for-dleq-proofs

  - title: "BIPs #1689 merges BIP374 to specify a standard way to generate and verify DLEQs"
    url: /en/newsletters/2025/01/03/#bips-1689

  - title: "BIPs #1687 adds BIP375 to specify sending DLEQs for multi-signer silent payments using PSBT"
    url: /en/newsletters/2025/01/17/#bips-1687

  - title: "BIPs #1758 updates BIP374 to prevent potential leakage of the private key"
    url: /en/newsletters/2025/03/07/#bips-1758

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Discrete log equivalency (DLEQ)** or **proofs of discrete log
  equivalency (PODLE)** is the ability to prove two points on an
  elliptic curve were both derived from the same private value (such as
  a private key).  Applications of it include committing to ownership of
  a key in the UTXO set without publicly revealing the specific UTXO and
  proving a silent payment output was constructed correctly without
  disclosing a private key.

---
DLEQs have several different applications in Bitcoin:

## PODLEs in JoinMarket

The earliest use of PODLE, pronounced _poodle_, was in the JoinMarket
[coinjoin][topic coinjoin] implementation to allow a user (such as
Alice) to claim to control a UTXO without publicly revealing anything
about that UTXO.  If another user (such as Bob) wanted to coinjoin
with that UTXO, Alice could prove to him only that she actually owned
the claimed UTXO.  If Alice lied about owning the UTXO or attempted to
create multiple proofs for the same UTXO, Bob could prove to everyone
that she lied and other users would be less likely to interact with her
in the future.

PODLEs as used in JoinMarket take advantage of a property of [schnorr
signature][topic schnorr signatures] verification.  If the same private
key and the same private nonce are used to generate different public keys
and public nonces using different _generators_, the _s_ value of a
signature that is valid for one key and nonce will also be valid for the
other key and nonce.

For example, Alice creates a private key (a large number) and derives
from it a Bitcoin public key in the normal way by multiplying the
private key by a specified elliptic curve point (called a
generator).  Alice also multiplies the same private key by a second
generator.  Alice then creates a private nonce (another large number)
and multiplies it by Bitcoin's usual generator and the secondary
generator.  Then Alice commits to a message and creates an _s_ value for
the combination of private key, private nonce, and message.  That same
_s_ value will be valid for either the Bitcoin public key or the public
key created with the secondary generator.

When Alice announces to JoinMarket participants that she has a UTXO, she
provides the secondary public key (as a hash digest).  When Bob accepts
her offer, she provides him the details of her UTXO (including the
Bitcoin public key), the secondary public key (undigested),
both public nonces, and the _s_ value that proves discrete log
equivalency.  If Bob's verification succeeds, only he learns the
identity of Alice's UTXO; if it fails, it can prove Alice lied.

## DLEQ in silent payment signing

The output address for a [silent payment][topic silent payments] is
created using [elliptic curve diffie-hellman][ecdh] (ECDH) which
involves computing values using private keys.  When several private keys
are involved that belong to independent signers, it's possible for one
signer to include a correct signature but an incorrect value for the
output address.  This will lead to the destruction of money as it is
sent to an output that cannot be spent by the receiver.

The method for creating a secondary public key in PODLE (described
previously) is functionally the same as creating an ECDH key, so a very
similar protocol is used to create DLEQs for silent payments.  These
DLEQs only need to be shared from one signer of a transaction to the
other signers.  Each signer can verify that every other signer produced
a correct ECDH value without any of the signers needing to share their
private keys.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
