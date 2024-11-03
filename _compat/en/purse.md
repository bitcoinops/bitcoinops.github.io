---
layout: page
permalink: /en/compatibility/purse/

name: Purse
internal_url: /en/compatibility/purse
logo: /img/compatibility/purse/purse.png
rbf:
  tested:
    date: "2019-12-17"
    platforms:
      - web
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
    - image: /img/compatibility/purse/rbf/transaction-list.png
      caption: >
        Receiving Transaction Signaling RBF - No unconfirmed transactions appear in transaction list.
segwit:
  tested:
    date: "2019-12-17"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "true"
      bech32m: "untested"
      default: "bech32"
    send:
      bech32: "true"
      bech32m: "untested"
      change_bech32: "true"
      segwit_v1: "Transaction can be created and broadcast, relayed by peers
      compatible with Bitcoin Core v0.19.0.1 or above."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/purse/segwit/receive-screen-p2wpkh.png
      caption: >
        Purse deposit addresses are bech32 P2WPKH (native segwit) by default.
    - image: /img/compatibility/purse/segwit/receive-screen-nested.png
      caption: >
        As an option for users with legacy wallets, Purse also accepts deposits
        to P2SH-wrapped P2WPKH (nested segwit) addresses.
    - image: /img/compatibility/purse/segwit/send-screen.png
      caption: >
        Purse allows withdraws to both legacy and segwit addresses.
    #- image: /img/compatibility/purse/segwit/send-v1.png
    #  caption: >
    #    Purse can send to a segwit address of any witness program version.
---

<!-- Purse -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
