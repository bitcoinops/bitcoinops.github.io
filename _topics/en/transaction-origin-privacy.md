---
title: Transaction origin privacy

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Transaction Relay Policy
  - Privacy Enhancements
  - Privacy Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Bitcoin Wiki: Privacy---Traffic analysis"
      link: https://en.bitcoin.it/wiki/Privacy#Traffic_analysis

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Bitcoin Core #18861 only allows a peer to request a tx if it informed that peer about the tx"
    url: /en/newsletters/2020/05/27/#bitcoin-core-18861

  - title: "Transcript: 'TxProbe: discovering Bitcoin's network topology using orphan transactions'"
    url: /en/newsletters/2019/09/18/#txprobe-discovering-bitcoin-s-network-topology-using-orphan-transactions

  - title: "Bitcoin Core #14897 introduces a semi-random order when requesting transactions"
    url: /en/newsletters/2019/02/12/#bitcoin-core-14897

  - title: "Bitcoin Core #15834 fixes a bug introduced in #14897 semi-random order for requesting transactions"
    url: /en/newsletters/2019/06/19/#bitcoin-core-15834

  - title: "Bitcoin Core #19109 adds a per-peer rolling bloom filter to track recent tx announcements"
    url: /en/newsletters/2020/07/22/#bitcoin-core-19109

  - title: "Replacement cycle mitigation of frequent transaction rebroadcasting with potential privacy reduction"
    url: /en/newsletters/2023/10/25/#frequent-rebroadcasting

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Anonymity networks
    link: topic anonymity networks

  - title: V2 P2P Transport
    link: topic v2 p2p transport

  - title: Dandelion
    link: topic dandelion

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Transaction origin privacy** is the ability to hide the origin of a
  transaction from network surveillance.
---
If an eavesdropper can see every transaction relayed by every node, they
can assume that the first node to send a transaction is the node where
that transaction originated.  This implies that someone at that node's
IP address created that transaction.  Whether that implication is
correct or not, this capability is harmful to user privacy.

Even when surveillance of the entire Bitcoin network is not possible,
there are many methods for attempting to locate which node originated a
transaction.  Developers have expended significant effort on improving
transaction origin privacy.  Some previous and ongoing efforts include:

- **Lightning Network:** although onchain LN transactions still need
  transaction origin privacy, offchain LN payments that are routed
  through onion-encrypted messages are more resistant to many of the
  techniques applied against onchain Bitcoin transactions.

- [Anonymity networks][topic anonymity networks]: support has been added
  to Bitcoin Core for encrypted relay of transaction and other data over
  Tor, I2P, and CJDNS.  Several other Bitcoin programs support some or
  all of these protocols.  Encryption makes it much more difficult for
  an eavesdropper to reliably determine the origin of a transaction.

- [v2 P2P transport][topic v2 p2p transport]: this protocol will provide
  native encryption of transaction and other data for Bitcoin programs.

- [Dandelion][topic dandelion]: this protocol will allow a node which
  did not originate a transaction to be the first to publicly broadcast
  it, potentially making it much more difficult to determine the actual
  origin.  Dandelion will be much more effective if it is combined with
  encryption, either naively or through anonymity networks.

- **Mempool rebroadcast:** the Bitcoin protocol can't provide any
  assurance to wallets that their unconfirmed transactions have been received
  by honest nodes and miners.  This means wallets may need to
  periodically rebroadcast unconfirmed transactions.  Every rebroadcast
  increases the opportunity for a surveillant to determine which IP
  address originated the transaction.  Bitcoin Core developers have been
  working on having all nodes periodically rebroadcast some unconfirmed
  transactions from their mempools so that it won't be clear whether a
  rebroadcast was initiated by a wallet involved in the transaction or
  just some random node.  Rebroadcast may also have other beneficial
  effects beyond privacy.

{% include references.md %}
{% include linkers/issues.md issues="" %}
