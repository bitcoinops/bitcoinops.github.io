---
layout: page
permalink: /en/compatibility/onekey/

name: OneKey
internal_url: /en/compatibility/onekey
logo: /img/compatibility/onekey/onekey.png
rbf:
  tested:
    date: "2023-04-07"
    platforms:
      - macOS
    version: "n/a"
  features:
    receive:
      notification: "false"
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
    - image: /img/compatibility/onekey/rbf/send-screen-1.png
      caption: >
        Sending Transaction - Default send (withdrawal) screen. No RBF options.
    - image: /img/compatibility/onekey/rbf/send-screen-2.png
      caption: >
        Sending Transaction - Default send (withdrawal) screen. No RBF options.
    - image: /img/compatibility/onekey/rbf/send-screen-3.png
      caption: >
        Sending Transaction - Default send (withdrawal) screen. No RBF options.
    - image: /img/compatibility/onekey/rbf/history.png
      caption: >
        Sending Transaction - Default send (withdrawal) screen. No RBF options.
    - image: /img/compatibility/onekey/rbf/receive.png
      caption: >
        Attempting Transaction Replacement - Transaction not sent via RBF. No fee bump options.

segwit:
  tested:
    date: "2023-04-07"
    platforms:
      - macOS
    version: "4.2.1"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "true"
      bech32m: "untested"
      default: "p2sh_wrapped"
    send:
      bech32: "true"
      bech32m: "untested"
      change_bech32: "true"
      segwit_v1: "true"
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/onekey/segwit/receive-screen.png
      caption: >
        By default, OneKey generates a BIP49 P2SH-P2WPKH Base58 receive addresses.
        There is also an option to generate a BIP44 P2PKH, BIP84 P2WPKH and BIP86 P2TR addresses.
---
<!-- Onekey -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
