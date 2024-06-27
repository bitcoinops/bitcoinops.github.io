---
layout: page
permalink: /en/compatibility/coinbase/

name: Coinbase
internal_url: /en/compatibility/coinbase
logo: /img/compatibility/coinbase/coinbase.png
rbf:
  tested:
    date: "2018-11-05"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      notification: "false"
      list: "false"
      details: "false"
      shows_replaced_version: "false"
      shows_original_version: "true"
    send:
      signals_bip125: "false"
      list: "untested"
      details: "untested"
      shows_replaced_version: "untested"
      shows_original_version: "untested"
  examples:
    - image: /img/compatibility/coinbase/rbf/send-screen-default.png
      caption: >
        Sending RBF Transaction - Default send transaction screen.
    - image: /img/compatibility/coinbase/rbf/send-confirm.png
      caption: >
        Sending RBF Transaction - Send transaction confirmation screen. Shows fees. No RBF flag. Transaction sent without RBF signaled.
    - image: /img/compatibility/coinbase/rbf/transaction-details-sent.png
      caption: >
        Bumping RBF Transaction - Transaction not sent with RBF so no bumping possible.
    - image: /img/compatibility/coinbase/rbf/transaction-details-sent-2.png
      caption: >
        Bumping RBF Transaction - After a period of time the View Transaction link shows up.
    - image: /img/compatibility/coinbase/rbf/transaction-list-incoming-rbf.png
      caption: >
        Receiving RBF Transaction - Incoming RBF transaction list. No RBF label.
    - image: /img/compatibility/coinbase/rbf/transaction-details-incoming-rbf.png
      caption: >
        Receiving RBF Transaction - Incoming RBF transaction details. No RBF label. Further transaction details are at BlockCypher explorer which does not label RBF transactions.
    - image: /img/compatibility/coinbase/rbf/transaction-list-incoming-replacement.png
      caption: >
        Receiving Bumped RBF Transaction - After bumped transaction confirmed, the bumped transaction then shows up and is credited. Original transactions stay as pending (even after 100 confirmations).
segwit:
  tested:
    date: "2019-04-11"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "false"
      bech32m: "false"
      default: "p2sh_wrapped"
    send:
      bech32: "true"
      bech32m: "false"
      change_bech32: "true"
      segwit_v1: "Fails address validation client side in the UI."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/coinbase/segwit/receive-screen.png
      caption: >
        Coinbase does not have an explicit option for receiving to bech32.
        Coinbase uses p2sh wrapped segwit addresses for receiving.
    - image: /img/compatibility/coinbase/segwit/send-screen.png
      caption: >
        Coinbase allows sending to either wrapped or native segwit addresses.
        There is also visual validation of the address format.
    - image: /img/compatibility/coinbase/segwit/transaction-details-sent.png
      caption: >
        Transaction details screen shows the bech32 address. However, the link
        for that address uses a block explorer (BlockCypher) which shows an
        error as it does not support bech32 addresses.
    - image: /img/compatibility/coinbase/segwit/change-address.png
      caption: >
        Coinbase uses bech32 for their change addresses, even when the send is
        going to non bech32.
    #- image: /img/compatibility/coinbase/segwit/send-segwit-v1.png
    #  caption: >
    #    Coinbase allows for sending to bech32 including P2WPKH and P2WSH for
    #    segwit v0. Coinbase detects segwit v1 addresses and displays a
    #    validation error.
---

<!-- Coinbase -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
