---
layout: page
permalink: /en/compatibility/bitmex/

name: BitMEX
internal_url: /en/compatibility/bitmex
logo: /img/compatibility/bitmex/bitmex.png
rbf:
  tested:
    date: "2018-11-05"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      notification: "na"
      list: "false"
      details: "false"
      shows_replaced_version: "false"
      shows_original_version: "false"
    send:
      signals_bip125: "false"
      list: "untested"
      details: "untested"
      shows_replaced_version: "untested"
      shows_original_version: "untested"
  examples:
    - image: /img/compatibility/bitmex/rbf/send-screen.png
      caption: >
        Sending Transaction - Send Transaction screen. Transactions sent out of BitMEX are not RBF signaled. BitMEX only accepts confirmed transactions.
segwit:
  tested:
    date: "2021-01-27"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      p2sh_wrapped: "false"
      bech32: "true"
      bech32m: "untested"
      default: "bech32"
    send:
      bech32: "true"   # https://blog.bitmex.com/bitmex-enables-bech32-sending-support/
      bech32m: "true"
      change_bech32: "true"
      segwit_v1: "Bech32m supported." # https://twitter.com/BitMEXResearch/status/1492152557044654082
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/bitmex/segwit/receive-screen.png
      caption: >
        BitMEX uses a static P2SH address per user account.
---
<!-- BitMex -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
