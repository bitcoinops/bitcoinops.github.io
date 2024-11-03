---
layout: page
permalink: /en/compatibility/edge/

name: Edge
internal_url: /en/compatibility/edge
logo: /img/compatibility/edge/edge.png
rbf:
  tested:
    date: "2022-10-12"
    platforms:
      - Android
    version: "2.23.0"
  features:
    receive:
      notification: "false"
      list: "false"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "true"
    send:
      signals_bip125: "false"
      list: "untested"
      details: "untested"
      shows_replaced_version: "untested"
      shows_original_version: "untested"
  examples:
    - image: /img/compatibility/edge/rbf/send-screen-default.png
      caption: >
        Sending RBF Transaction - Default Send screen. No option for RBF.
    - image: /img/compatibility/edge/rbf/send-context-fees-menu.png
      caption: >
        Sending RBF Transaction - Context menu for send transaction show mining fee options.
    - image: /img/compatibility/edge/rbf/send-change-mining-fee.png
      caption: >
        Sending RBF Transaction - Mining fee options dialog.
    - image: /img/compatibility/edge/rbf/send-custom-mining-fee.png
      caption: >
        Sending RBF Transaction - Mining fee custom dialog.
    - image: /img/compatibility/edge/rbf/transaction-details-sent.png
      caption: >
        Bumping RBF Enabled Transaction - Mining fee custom dialog.
    - image: /img/compatibility/edge/rbf/transaction-details-incoming-rbf.png
      caption: >
        Receiving RBF Transaction - Receiving RBF enabled transaction. No RBF Flag.
    - image: /img/compatibility/edge/rbf/transaction-details-incoming-rbf-advanced.png
      caption: >
        Receiving RBF Transaction - Transaction details for received RBF transaction. Links to blockchair.com explorer.
    - image: /img/compatibility/edge/rbf/transaction-list-incoming-replacement.png
      caption: >
        Receiving Bumped RBF Transaction - Transaction list with top 2 transactions being the original and bumped RBF transaction. No RBF flag. Note that the balance only went up by the value of one of the transactions.
segwit:
  tested:
    date: "2022-10-12"
    platforms:
      - Android
    version: "2.23.0"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "false"
      bech32m: "untested"
      default: "p2sh_wrapped"
    send:
      bech32: "true"
      bech32m: "true"
      change_bech32: "false"
      segwit_v1: "An attempt to send to a bech32m taproot address shows an error that the address is invalid."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/edge/segwit/receive-screen.png
      caption: >
        Edge generates only
    - image: /img/compatibility/edge/segwit/send-screen.png
      caption: >
        Edge allows sends to segwit v0 native bech32 addresses.
    - image: /img/compatibility/edge/segwit/wallet-creation-screen.png
      caption: >
        Edge allows the creation of "Segwit" and "no Segwit" wallets. The
        "Segwit" wallets use P2SH-wrapped P2WPKH addresses. Both wallet types
        can send to segwit v0 addresses.
---

<!-- Edge -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
