---
layout: page
permalink: /en/compatibility/blockchaininfo/

name: Blockchain.info
internal_url: /en/compatibility/blockchaininfo
logo: /img/compatibility/blockchaininfo/blockchaininfo.png
rbf:
  tested:
    date: "2019-07-05"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      notification: "false"
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
    - image: /img/compatibility/blockchaininfo/rbf/send-default-screen.png
      caption: >
        Sending Transaction - Default send transaction screen. No RBF option.
    - image: /img/compatibility/blockchaininfo/rbf/send-screen-custom-fees.png
      caption: >
        Attempting Transaction Replacement - Sending transaction. Custom transaction
        fee option expanded. No bump fee option available.
    - image: /img/compatibility/blockchaininfo/rbf/transaction-list-sent.png
      caption: >
        Attempting Transaction Replacement - Sent transaction is shown. No option for RBF bumping.
    - image: /img/compatibility/blockchaininfo/rbf/transaction-list-incoming-rbf.png
      caption: >
        Receiving Transaction Signaling RBF - Receiving RBF signaling transaction. RBF flag is shown.
segwit:
  tested:
    date: "2021-06-01"
    platforms:
      - web
    version: "n/a"
  features:
    receive:
      p2sh_wrapped: "false"
      bech32: "true"
      bech32m: "true"
      default: "bech32"  # https://github.com/bitcoinops/bitcoinops.github.io/pull/510#issuecomment-859732513
    send:
      bech32: "true"
      bech32m: "true"
      change_bech32: "true"  # https://github.com/bitcoinops/bitcoinops.github.io/pull/510#issuecomment-859732513
      segwit_v1: "Error occurs during sending process, after validation."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/blockchaininfo/segwit/receive-screen.png
      caption: >
        Blockchain only generates P2PKH addresses for receiving.
    - image: /img/compatibility/blockchaininfo/segwit/send-screen.png
      caption: >
        Blockchain can send to bech32 addresses.
    #- image: /img/compatibility/blockchaininfo/segwit/send-v1-error.png
    #  caption: >
    #    Blockchain initially allows to send to segwit v1 addresses but an error
    #    occurs after completing the send process.
---

<!-- Blockchain.info -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
