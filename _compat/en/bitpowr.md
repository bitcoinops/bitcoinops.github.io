---
layout: page
permalink: /en/compatibility/bitpowr/

name: Bitpowr
internal_url: /en/compatibility/bitpowr
logo: /img/compatibility/bitpowr/bitpowr.png
rbf:
  tested:
    date: "2022-08-22"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      notification: "false"
      list: "false"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "false"
    send:
      signals_bip125: "false"
      list: "untested"
      details: "untested"
      shows_replaced_version: "untested"
      shows_original_version: "untested"
  examples:
    - image: /img/compatibility/bitpowr/rbf/send-screen.png
      caption: >
        Sending Transaction - Send transaction.
    - image: /img/compatibility/bitpowr/rbf/send-screen-with-amount.png
      caption: >
        Sending Transaction - Send Transaction With Amount.
    - image: /img/compatibility/bitpowr/rbf/send-fee-notice.png
      caption: >
        Send Transaction - Transaction Fees Notice
    - image: /img/compatibility/bitpowr/rbf/send-change-fee.png
      caption: >
        Send Transaction - Change Transaction Fees Options
    - image: /img/compatibility/bitpowr/rbf/transactions-list.png
      caption: >
        Receiving Transaction - Incoming transaction.

segwit:
  tested:
    date: "2021-08-17"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "true"
      bech32m: "untested"
      default: "p2pkh"
    send:
      bech32: "true"
      bech32m: "untested"
      change_bech32: "true"
      segwit_v1: "true"
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/bitpowr/segwit/receive-screen.png
      caption: >
        Bitpowr supports bech32, p2pkh and p2sh receiving addresses.
    - image: /img/compatibility/bitpowr/segwit/send-screen.png
      caption: >
        Bitpowr supports sending to bech32, p2pkh and p2sh wrapped addresses via the API and UI.
    - image: /img/compatibility/bitpowr/segwit/send-change-segwit.png
      caption: >
        Bitpowr supports bech32, p2pkh and p2sh wrapped change addresses. You can choose via the API
        and its default to bech32 on dashboard.
---

<!-- BitPowr -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
