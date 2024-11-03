---
layout: page
permalink: /en/compatibility/river-financial/

name: River Financial
internal_url: /en/compatibility/river-financial
logo: /img/compatibility/river-financial/river-financial.png
rbf:
  tested:
    date: "2020-01-23"
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
      signals_bip125: "true"
      list: "untested"
      details: "untested"
      shows_replaced_version: "untested"
      shows_original_version: "untested"
  examples:
    - image: /img/compatibility/river-financial/rbf/rbf_onchain_deposit.png
      caption: >
        When a transaction enters River's mempool or is included in a block, River sends a notification to the user about the new deposit. There is currently no RBF notice.
    - image: /img/compatibility/river-financial/rbf/rbf_new_onchain_deposit.png
      caption: >
        The original transaction that gets bumped with RBF will not be listed and is replaced with the new transaction.
    - image: /img/compatibility/river-financial/rbf/rbf_dashboard.png
      caption: >
        When viewing transaction history, only the new replaced transaction is shown.
segwit:
  tested:
    date: "2020-01-12"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "true"
      bech32m: "untested"
      default: "bech32_p2wsh"
    send:
      bech32: "true"
      bech32m: "true"
      change_bech32: "true"
      segwit_v1: "Transaction can be created and broadcast, relayed by peers
      compatible with Bitcoin Core v0.19.0.1 or above."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/river-financial/segwit/deposit_onchain.png
      caption: >
        River deposit addresses are bech32 P2WSH (native segwit) by default.
    - image: /img/compatibility/river-financial/segwit/withdraw_onchain.png
      caption: >
        River supports withdrawals to legacy and segwit addresses.
---

<!-- River Financial -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
