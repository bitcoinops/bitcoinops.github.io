---
title: HD key generation

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: bip32

## Optional.  An entry will be added to the topics index for each alias
aliases:
 - BIP32
 - HD wallets

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Wallet Collaboration Tools

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP32

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Bitcoin Core #14150 adds key origin support to descriptors for tracking BIP32 xpubs"
    url: /en/newsletters/2018/10/30/#bitcoin-core-14150

  - title: "Suggestion to include BIP32 derivation paths in BIP174 PSBTs"
    url: /en/newsletters/2019/05/14/#addition-of-derivation-paths-to-bip174-psbts

  - title: "BIPs #784 updates BIP174 PSBTs to include a BIP32 xpub"
    url: /en/newsletters/2019/07/17/#bips-784

  - title: "Question about BIP32 extended pubkeys (xpubs) versus ypubs and zpubs"
    url: /en/newsletters/2019/07/31/#why-does-the-importmulti-rpc-not-support-zpub-and-ypub

  - title: "Question: what is the max allowed depth for BIP32 derivation paths?"
    url: /en/newsletters/2019/12/18/#what-is-the-max-allowed-depth-for-bip32-derivation-paths

  - title: "Question: why was the BIP32 fingerprint used for BIP174 PSBT?"
    url: /en/newsletters/2020/01/29/#why-was-the-bip32-fingerprint-used-for-bip174-psbt

  - title: "Proposal for using one BIP32 keychain to seed multiple child keychains"
    url: /en/newsletters/2020/04/15/#proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains

  - title: "BIPs #910 Assigns BIP85 to the Deterministic Entropy From BIP32 Keychains proposal"
    url: /en/newsletters/2020/06/17/#bips-910

  - title: Proposed BIP for BIP32 path templates
    url: /en/newsletters/2020/07/08/#proposed-bip-for-bip32-path-templates

  - title: Proposal for secure exchange of BIP32 xpubs during multisig wallet set up
    url: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets

  - title: Closing lost LN channels with only a BIP32 seed
    url: /en/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed

  - title: "BIPs #1089 assigns BIP87 to proposal for standardized BIP32 paths for multisig wallets"
    url: /en/newsletters/2021/05/26/#bips-1089

  - title: "BIPs #1097 assigns BIP129 to proposal for exchange of xpubs during multisig wallet set up"
    url: /en/newsletters/2021/05/26/#bips-1097

  - title: "Bitcoin Core #22095 adds test to ensure BIP32 derived keys are correctly padded"
    url: /en/newsletters/2021/06/09/#bitcoin-core-22095

  - title: Proposed BIP32 key derivation path for single-sig P2TR
    url: /en/newsletters/2021/06/30/#key-derivation-path-for-single-sig-p2tr

  - title: No changes to BIP32 derivation needed to implement taproot receiving support
    url: /en/newsletters/2021/07/14/#preparing-for-taproot-4-from-p2wpkh-to-single-sig-p2tr

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **HD key generation** as specified in **BIP32** allows securely
  creating an unlimited number of keypairs from a seed as small as 128
  bits.  A wallet may also create extended pubkeys (xpubs) that allow
  external software to create new pubkeys for the wallet without
  learning the corresponding private keys.

---
{% include references.md %}
{% include linkers/issues.md issues="" %}
