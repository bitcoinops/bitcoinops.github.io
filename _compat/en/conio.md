---
layout: page
permalink: /en/compatibility/conio/

name: Conio
internal_url: /en/compatibility/conio
logo: /img/compatibility/conio/conio.png
rbf:
  tested:
    date: "2018-10-31"
    platforms:
      - iOS
    version: "2.5.6"
  features:
    receive:
      notification: "false"
      list: "false"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "true"
    send:
      signals_bip125: "true"
      list: "false"
      details: "false"
      shows_replaced_version: "untested"
      shows_original_version: "untested"
  examples:
    - image: /img/compatibility/conio/rbf/send-screen-default.png
      caption: >
        Sending RBF Transaction - Default send transaction screen. No RBF options. Transaction is sent with RBF signaled.
    - image: /img/compatibility/conio/rbf/transaction-details-sent.png
      caption: >
        Bumping RBF Transaction - Transaction details screen for a sent and unconfirmed transaction. Cannot get Send Faster button enabled even when funds to bump are available.
    - image: /img/compatibility/conio/rbf/notification-incoming-rbf.png
      caption: >
        Bumping RBF Transaction - Notice of incoming transaction. No RBF flag.
    - image: /img/compatibility/conio/rbf/transaction-list-incoming-rbf.png
      caption: >
        Bumping RBF Transaction - Transaction list screen showing incoming RBF enabled transaction. No RBF flag.
    - image: /img/compatibility/conio/rbf/transaction-details-incoming-rbf.png
      caption: >
        Bumping RBF Transaction - Transaction details of incoming transaction. No RBF signaled. "Receive Faster" for CPFP.
    - image: /img/compatibility/conio/rbf/transaction-details-incoming-rbf-2.png
      caption: >
        Bumping RBF Transaction - More transaction details.
    - image: /img/compatibility/conio/rbf/transaction-details-incoming-rbf-3.png
      caption: >
        Bumping RBF Transaction - More transaction details. After a period of time the Receive Faster button was now enabled.
    - image: /img/compatibility/conio/rbf/transaction-details-incoming-rbf-receive-faster.png
      caption: >
        Bumping RBF Transaction - Transaction details showing Receive Faster options.
    - image: /img/compatibility/conio/rbf/notification-replacement.png
      caption: >
        Receiving Bumped RBF Transaction - Receiving bumped transaction shows “Incoming” amount as the sum of the original and replacement transaction.
    - image: /img/compatibility/conio/rbf/transaction-list-incoming-replacement.png
      caption: >
        Receiving Bumped RBF Transaction - Both original and replacement transaction show in transaction list screen.
    - image: /img/compatibility/conio/rbf/transaction-list-replacement-confirmed.png
      caption: >
        Receiving Bumped RBF Transaction - After replacement transaction confirms, the original is removed from the list.
    - image: /img/compatibility/conio/rbf/transaction-details-replacement.png
      caption: >
        Receiving Bumped RBF Transaction - Additional transaction details
        available once transaction was confirmed.
segwit:
  tested:
    date: "2019-08-19"
    platforms:
      - iOS
    version: "3.1.3"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "false"
      bech32m: "untested"
      default: "p2sh_wrapped_p2wsh"
    send:
      bech32: "true"
      bech32m: "untested"
      change_bech32: "false"
      segwit_v1: "Server error 500 while attemping to send."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/conio/segwit/receive-screen.png
      caption: >
        Coino only receives to P2SH-wrapped P2WSH addresses.
    - image: /img/compatibility/conio/segwit/send-screen.png
      caption: >
        Conio allows sending to any segwit v0 bech32 address.
    #- image: /img/compatibility/conio/segwit/send-screen.png
    #  caption: >
    #    Conio shows a server error when attempting to send to segwit v1 outputs.
---

<!-- Conio -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
