---
title: BIP70 payment protocol

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **The BIP70 payment protocol** is an interactive protocol for
  sending payment requests and receiving payments.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  The protocol involves several steps:

  - Customer clicks a [BIP21][] `bitcoin:` URI extended with an
    additional `r` parameter (described in [BIP72][]).  The URI handler
    opens the user's wallet in response

  - The wallet contacts the merchant's server and asks for a payment request
    signed by the merchant's SSL certificate.  Upon receipt and
    validation of the signed payment request, the payment details are
    automatically filled out on the wallet's *Send Transaction* screen.
    Optionally, the user is notified that they're paying the owner of
    the domain corresponding to signing certificate (e.g.
    "example.com")

  - The customer reviews the payment details and clicks the *Send
    Transaction* button.  The transaction is generated and broadcast to
    the Bitcoin network.  A copy of the transaction is sent to the
    merchant, who then replies with an acknowledgment that the payment
    was received (optionally rebroadcasting the transaction from their
    own nodes)

  The protocol had several advantages over plain BIP21 URIs:

    - The merchant could request payment to any script---not just one
      of the popular address types---making the proposal forward
      compatible with new address formats

    - The customer's wallet automatically sent their own script to be
      used in case a refund needed to be issued

    - Payment requests had an expiration date after which point the quoted price
      would no longer apply

    - It gave the spending transaction directly to the merchant,
      allowing them to broadcast it.  This could allow a user to pay
      using Bluetooth or NFC even if they didn't currently have
      a connection to the Internet

  Its main disadvantage was that it required that spenders support the SSL
  certificate system, which includes many algorithms not otherwise used
  in Bitcoin and a complex Public Key Infrastructure (PKI) system.  In
  practice, this meant software needed to include a library such as
  OpenSSL as a dependency.  Bugs in that library could then be used to
  exploit Bitcoin programs, such as the OpenSSL [heartbleed][]
  vulnerability that potentially allowed attackers to [access private
  keys][core heartbleed] from Bitcoin Core in 2014.

  Ultimately, BIP70 never saw widespread adoption and almost all
  merchants and wallets that did once support it have either ended
  support or plan to end their support in the future.

  [heartbleed]: http://heartbleed.com/
  [core heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    ## BIPs 70, 71, 72 were part of the original protocol.  BIPs 73, 74,
    ## 75 are all related to BIP70 but were extensions that came later, so
    ## they probably shouldn't be linked as primary documentation
    - title: BIP70
    - title: BIP71
    - title: BIP72

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Pay-to-EndPoint (P2EP) has elements similar to BIP70
    url: /en/newsletters/2018/08/14/#pay-to-end-point-p2ep-idea-proposed

  - title: "Bitcoin Core PR#14451 allows building Bitcoin-Qt without BIP70 support"
    url: /en/newsletters/2018/10/30/#bitcoin-core-14451

  - title: "Bitcoin Core PR#15063 allows falling back to BIP21 parsing of BIP72 URIs"
    url: /en/newsletters/2019/02/19/#bitcoin-core-15063

  - title: "Bitcoin Core PR#15584 disables support for BIP70 by default"
    url: /en/newsletters/2019/09/18/#bitcoin-core-15584

  - title: "Bitcoin Core PR#17165 removes support for BIP70 payment protocol"
    url: /en/newsletters/2019/10/30/#bitcoin-core-17165

  - title: "Bitcoin Core 0.19 released with BIP70 support disabled by default"
    url: /en/newsletters/2019/11/27/#deprecated-or-removed-features

  - title: "2019 year-in-review: Bitcoin Core BIP70 deprecation and disablement"
    url: /en/newsletters/2019/12/28/#bip70

  - title: "Mailing list discussion about a BIP70 replacement"
    url: /en/newsletters/2021/03/03/#discussion-about-a-bip70-replacement

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
