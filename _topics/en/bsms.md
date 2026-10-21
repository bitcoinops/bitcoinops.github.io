---
title: Bitcoin Secure Multisig Setup

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: bsms

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Developer Tools
  - Wallet Collaboration Tools

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP129
      link: https://github.com/bitcoin/bips/blob/master/bip-0129.mediawiki

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Draft BIP for securely setting up multisig wallets
    url: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
    date: 2021-02-17
    feature: true

  - title: BIP129 assigned to Bitcoin Secure Multisig Setup
    url: /en/newsletters/2021/05/26/#bips-1097
    date: 2021-05-26

  - title: Nunchuk Group Wallet uses BSMS files to share multisig settings
    url: /en/newsletters/2025/03/21/#nunchuk-launches-group-wallet
    date: 2025-03-21

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
  **Bitcoin Secure Multisig Setup (BSMS)** is a protocol, specified in
  BIP129, for a coordinator and several signing devices to exchange the
  script template, extended public keys and key paths needed to form a
  multisig wallet, and to agree on an output script descriptor.  Messages
  are encrypted, and a short verification string lets signers check out of
  band that the coordinator did not substitute keys of its own.
---
BSMS is aimed at the case where a multisig wallet is assembled from devices
that have no trusted channel between them, and where the coordinator may be
a different wallet, service or person than the signers.  The protocol
defines three messages: the coordinator sends an invitation containing the
script template (for example, 2-of-3 P2WSH) and an encryption credential;
each signer returns a key record -- its key path, extended public key and a
signature made with the corresponding private key -- encrypted to the
coordinator; and the coordinator combines the records into an [output
script descriptor][topic descriptors] that it encrypts back to each signer.

Each signer checks that its own extended public key appears in the
descriptor before storing it as a script template it is willing to sign
for.  The key records also produce a short verification string that the
participants compare through a separate channel, so a compromised
coordinator cannot quietly substitute keys it controls.

The specification was published as a draft BIP in early 2021 and received
the BIP129 number later the same year.  BSMS files are also used outside the
setup flow: Nunchuk's Group Wallet repurposes the descriptor in a BSMS file
to share multisignature, taproot, coin control, MuSig2 and communication
settings among the participants of a shared wallet.

{% include references.md %}
{% include linkers/issues.md issues="" %}

[BIP129]: https://github.com/bitcoin/bips/blob/master/bip-0129.mediawiki
