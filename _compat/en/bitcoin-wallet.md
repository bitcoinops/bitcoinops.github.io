---
layout: page
permalink: /en/compatibility/bitcoin-wallet/

# https://github.com/bitcoin-wallet/bitcoin-wallet
name: Bitcoin Wallet
internal_url: /en/compatibility/bitcoin-wallet
logo: /img/compatibility/bitcoin-wallet/bitcoin-wallet.png
segwit:
  tested:
    date: "2019-11-06"
    platforms:
      - Android
    version: "7.26"
  features:
    receive:
      p2sh_wrapped: "false"
      bech32: "true"
      bech32m: "false"
      default: "bech32"
    send:
      bech32: "true"
      bech32m: "true"
      change_bech32: "true"
      bech32_p2wsh: "true"
---

<!-- Bitcoin Wallet -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
