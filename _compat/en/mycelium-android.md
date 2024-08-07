---
layout: page
permalink: /en/compatibility/mycelium-android/

name: Mycelium (Android)
internal_url: /en/compatibility/mycelium-android
logo: /img/compatibility/mycelium-android/mycelium-android.png
rbf:
  tested:
    date: "2022-10-12"
    platforms:
      - Android
    version: "3.16.0.13"
  features:
    receive:
      notification: "na"
      list: "true"
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
    - image: /img/compatibility/mycelium-android/segwit/send-screen.png
      caption: >
        Sending Transaction - Default send transaction screen. No options for RBF while sending or in app settings.
        Miner fee slider.
    - image: /img/compatibility/mycelium-android/rbf/transaction-list-incoming-double-spend.png
      caption: >
        Receiving Transaction Signaling RBF - Fee Bump is displayed as double spend. Sometimes, when receiving any transaction, no unconfirmed transactions show.
    - image: /img/compatibility/mycelium-android/rbf/transaction-list-in-out.png
      caption: >
        Attempting Transaction Replacement - Transaction list. No option to bump since transaction sent without RBF.
        Unconfirmed transaction without RBF signal is shown without warning.
segwit:
  tested:
    date: "2022-10-12"
    platforms:
      - Android
    version: "3.16.0.13"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "true"  # https://github.com/mycelium-com/wallet-android/issues/425#issuecomment-440792004
      bech32m: "false"
      default: "p2sh_wrapped"
    send:
      bech32: "true" # https://github.com/mycelium-com/wallet-android/issues/425#issuecomment-440792004
      bech32m: "false"
      change_bech32: "true"
      segwit_v1: "Fails during bech32m address validation."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/mycelium-android/segwit/receive-screen.png
      caption: >
        Mycelium generates P2PKH, P2SH-P2WPKH, and P2WPKH receive addresses.
    - image: /img/compatibility/mycelium-android/segwit/send-screen.png
      caption: >
        Mycelium can send to any bech32 addresses.
    #- image: /img/compatibility/mycelium-android/segwit/send-screen-segwit-v1-error.png
    #  caption: >
    #    Mycelium displays a validation error when trying to send to a segwit v1
    #    address (or any other bech32m address).
    #    https://github.com/mycelium-com/wallet-android/issues/645
---

<!-- Mycelium Android -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
