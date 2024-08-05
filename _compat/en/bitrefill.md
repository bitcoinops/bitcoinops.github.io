---
layout: page
permalink: /en/compatibility/bitrefill/

name: Bitrefill
internal_url: /en/compatibility/bitrefill
logo: /img/compatibility/bitrefill/bitrefill.png
rbf:
  tested:
    date: "2018-11-06"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      notification: "na"
      list: "false"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "true"
    send:
      signals_bip125: "true"
      list: "false"
      details: "false"
      shows_replaced_version: "na"
      shows_original_version: "na"
  examples:
    - image: /img/compatibility/bitrefill/rbf/send-screen.png
      caption: >
        Sending Transaction - Default send transaction screen. No RBF info. Transaction was sent via RBF.
    - image: /img/compatibility/bitrefill/rbf/transaction-list-sent.png
      caption: >
        Attempting Transaction Replacement - Transaction list screen. No way to manually bump the transaction. Was sent RBF.
    - image: /img/compatibility/bitrefill/rbf/transaction-list-incoming-rbf.png
      caption: >
        Receiving Transaction Signaling RBF - No incoming transactions show initially during original transaction. This delay could have been related to delays in relaying the transaction in the Bitcoin network.
    - image: /img/compatibility/bitrefill/rbf/transaction-list-incoming-replacement.png
      caption: >
        Receiving Replacement Transaction - After replacement transaction was broadcast, both transactions show up as pending. Stayed as pending even after the replacement transaction had 6+ confirmations.
    - image: /img/compatibility/bitrefill/rbf/transaction-list-replacement-confirmed.png
      caption: >
        Receiving Replacement Transaction - At some point in the next day, the original transaction was marked failed and replacement transaction was credited to account and marked complete.
segwit:
  tested:
    date: "2019-04-12"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "false"
      bech32m: "untested"
      default: "p2sh_wrapped"
    send:
      bech32: "true"
      bech32m: "untested"
      change_bech32: "true"
      segwit_v1: "Address does not pass validation."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/bitrefill/segwit/receive-screen.png
      caption: >
        Bitrefill allows P2SH-wrapped segwit deposits. No bech32 option available.
    - image: /img/compatibility/bitrefill/segwit/send-screen.png
      caption: >
        Bitrefill can send to bech32 native addresses. Change address is also bech32.
    #- image: /img/compatibility/bitrefill/segwit/send-v1.png
    #  caption: >
    #    Bitrefill displays an address validation error for segwit v1 addresses.
---

<!-- Bitrefill -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
