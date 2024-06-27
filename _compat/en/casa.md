---
layout: page
permalink: /en/compatibility/casa/

name: Casa
internal_url: /en/compatibility/casa
logo: /img/compatibility/casa/casa.png
rbf:
  tested:
    date: "2019-10-24"
    platforms:
      - iOS
    version: "2.9.0"
  features:
    receive:
      notification: "false"
      list: "false"
      details: "false"
      shows_replaced_version: "false"
      shows_original_version: "false"
    send:
      signals_bip125: "false"
      list: "false"
      details: "false"
      shows_replaced_version: "false"
      shows_original_version: "false"
  examples:
    - image: /img/compatibility/casa/rbf/approve-send-transaction.png
      caption: >
        Sending Transaction - Default send transaction screen. No RBF options.
    - image: /img/compatibility/casa/rbf/transaction-list.png
      caption: >
        Receiving Replacement Transaction - Since no unconfirmed transaction
        appears, neither original nor replacement show until the replacement
        transactions confirms.
segwit:
  tested:
    date: "2019-10-24"
    platforms:
      - iOS
    version: "2.9.0"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "false"
      bech32m: "untested"
      default: "p2sh_wrapped_p2wsh"
    send:
      bech32: "true"
      bech32m: "true"
      change_bech32: "false"
      segwit_v1: "Fails on signing attempt."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/casa/segwit/receive-p2sh-wrapped-segwit.png
      caption: >
        Casa Keymaster defaults to P2SH-wrapped segwit addresses.
    - image: /img/compatibility/casa/segwit/send-to-bech32.png
      caption: >
        Casa Keymaster allows sending to bech32 addresses. Change addresses
        are not bech32 native, but P2SH-wrapped segwit addresses.
---

<!-- Casa -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
