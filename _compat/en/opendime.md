---
layout: page
permalink: /en/compatibility/opendime/

name: Opendime
internal_url: /en/compatibility/opendime
logo: /img/compatibility/opendime/opendime.png
rbf:
  tested:
    date: "2018-10-18"
    platforms:
      - macOS
    version: "2.1.0"
  features:
    receive:
      notification: "na"
      list: "false"
      details: "na"
      shows_replaced_version: "true"
      shows_original_version: "false"
    send:
      signals_bip125: "false"
      list: "untested"
      details: "untested"
      shows_replaced_version: "untested"
      shows_original_version: "untested"
  examples:
    - image: /img/compatibility/opendime/rbf/sending-instructions.png
      caption: >
        Sending Transaction - Opendime does not have traditional wallet
        capabilities. You can either sweep the private key to use in a regular
        wallet or use the balance.py script to send all funds to an address.
    - image: /img/compatibility/opendime/rbf/sending-script.png
      caption: >
        Sending Transaction - There is a balance.py python script which can send a transaction using pycoin but does not specify RBF when creating a transaction.
    - image: /img/compatibility/opendime/rbf/transaction-list-incoming-rbf.png
      caption: >
        Receiving Transaction Signaling RBF - Opendime uses a simple address explorer on opendime.com. No RBF Flag. OPENDIME’s simple transaction list explorer does not provide RBF flag notice. However there are links to other explorers on the page (Blockchain.info, Blocktrail, LocalBitcoins, BitInfoCharts, a BIP122 link).
    - image: /img/compatibility/opendime/rbf/transaction-list-incoming-replacement.png
      caption: >
        Receiving Replacement Transaction - Transaction list screen when a transaction has been replaced. Bottom transaction is the replacement transaction. Original transaction does not show up in list anymore.
segwit:
  tested:
    date: "2019-07-24"
    platforms:
      - macOS
    version: "2.2.0"
  features:
    receive:
      p2sh_wrapped: "false"
      bech32: "false"
      bech32m: "untested"
      default: "p2pkh"
    send:
      bech32: "true"
      bech32m: "untested"
      change_bech32: "na"
      segwit_v1: "Untested."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/opendime/segwit/receive-screen.png
      caption: >
        Opendime has a single P2PKH receive address. It can send to bech32
        addresses using the included balance.py script.
---

<!-- OpenDime -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
