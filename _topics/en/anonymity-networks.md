---
title: Anonymity networks

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Tor
  - I2P

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Bitcoin Core #21594 adds a network type field to the `getnodeaddresses` RPC"
    url: /en/newsletters/2021/04/14/#bitcoin-core-21594

  - title: "Bitcoin Core #20197 updates eviction logic to keep long-running onion peers"
    url: /en/newsletters/2021/04/07/#bitcoin-core-20197

  - title: "Question: how to use I2P with Bitcoin Core?"
    url: /en/newsletters/2021/03/31/#how-can-i-use-bitcoin-core-with-the-anonymous-network-protocol-i2p

  - title: "Bitcoin Core #20685 adds support for the I2P privacy network"
    url: /en/newsletters/2021/03/10/#bitcoin-core-20685

  - title: "Bitcoin Core GUI #162 adds network type information to the GUI Peers window"
    url: /en/newsletters/2021/01/06/#bitcoin-core-gui-162

  - title: "Bitcoin Core #19954 completes the BIP155 addr v2 implementation"
    url: /en/newsletters/2020/10/14/#bitcoin-core-19954

  - title:  Bitcoin Core PR Review Club on a proposed implementation of BIP155 addr v2
    url: /en/newsletters/2020/08/12/#bitcoin-core-pr-review-club

  - title: BIP for new address relay message to support Tor v3 onion addresses
    url: /en/newsletters/2019/03/12/#version-2-addr-message-proposed

  - title: Bitcoin Core 0.21.0 released with support for Tor v3 onion addresses
    url: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0

  - title: "Year-in-review: support for Tor v3 onion addresses"
    url: /en/newsletters/2020/12/23/#addrv2

  - title: "Bitcoin Core #19991 enables tracking inbound connections from onion peers"
    url:  /en/newsletters/2020/10/07/#bitcoin-core-19991

  - title: Desktop version of Blockstream Green released with Tor support
    url: /en/newsletters/2020/06/17/#desktop-version-of-blockstream-green-wallet

  - title: Presentation on enhancements in LND 0.10, including better Tor support
    url: /en/newsletters/2020/05/06/#lnd-v0-10

  - title: "BOLTs #751 updates BOLT7 to better handled multi-network node announcements"
    url: /en/newsletters/2020/03/25/#bolts-751

  - title: CKBunker allows specifying spending conditions for a Tor-enabled Coldcard
    url: /en/newsletters/2020/02/19/#ckbunker-using-psbts-for-an-hsm

  - title: "Eclair #1278 allows users to skip using SSL when using an onion service"
    url: /en/newsletters/2020/02/05/#eclair-1278

  - title: "C-Lightning #3155 adds option to use a static onion service address"
    url: /en/newsletters/2019/12/11/#c-lightning-3155

  - title: "Blockstream Green built-in Tor support for both iOS and Android"
    url: /en/newsletters/2019/10/23/#blockstream-green-tor-support

  - title: "BIPs #766 assigns BIP155 to the addr v2 proposal for v3 onion addresses"
    url: /en/newsletters/2019/07/31/#bips-766

  - title: "Bitcoin Core #15651 always binds to the default port when listening on Tor"
    url: /en/newsletters/2019/06/26/#bitcoin-core-15651

  - title: "Eclair #736 adds support for using and becoming an onion service"
    url: /en/newsletters/2019/02/12/#eclair-736

  - title: "LND #1516 adds support for automatically setting up a v3 onion service"
    url: /en/newsletters/2018/09/18/#lnd-1516

  - title: "Bitcoin Core #22050 drops support for deprecated version 2 Tor onion services"
    url: /en/newsletters/2021/06/09/#bitcoin-core-22050

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Dandelion
    link: topic dandelion

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Anonymity networks** are systems that allow network communication
  without senders or receivers needing to reveal their IP addresses to
  each other.  The best known of these are Tor and I2P.

---

The use of anonymity networks can go a long way to improving the privacy
of Bitcoin software.  It's particularly beneficial when sending your own
transactions.  This is especially true for lightweight clients that
don't relay transactions for other peers, so any transaction sent from
their IP address can easily be associated with their network identity.

But using an anonymity network can also be a liability in some cases;
for example:

- **Following the best block chain** is a major challenge for full nodes
  and lightweight clients on anonymity networks.  Because anonymity
  networks allow the creation of a large number of false identities,
  systems that solely use them are vulnerable to sybil attacks that can
  become [eclipse attacks][topic eclipse attacks] which feed a different
  block chain to clients and nodes than what the rest of the network is
  using, possibly resulting in loss of funds.

- **Latency** can be an issue for routed contract protocol systems
  designed to be fast, such as LN.  Still, for many end users, it's fine
  to trade off slightly slower speed for much improved privacy.

Anonymity networks that are separate from Bitcoin, such as Tor and I2P,
can also be combined with privacy-improving techniques in Bitcoin, such
as [dandelion][topic dandelion].

Note: Tor onion services should not be confused with the onion
encryption used in LN.  Although both derive from the same ideas about
preserving privacy, they are two different systems.

{% include references.md %}
{% include linkers/issues.md issues="" %}
