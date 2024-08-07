---
layout: page
permalink: /en/compatibility/electrum/

name: Electrum
internal_url: /en/compatibility/electrum
logo: /img/compatibility/electrum/electrum.png
rbf:
  tested:
    date: "2018-08-28"
    platforms:
      - macOS
    version: "3.2.2"
  features:
    receive:
      notification: "false"
      list: "true"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "false"
    send:
      signals_bip125: "true"
      list: "true"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "false"
  examples:
    - image: /img/compatibility/electrum/rbf/default-wallet-send-screen.png
      caption: >
        Sending Transaction - Default Wallet Send Screen.
    - image: /img/compatibility/electrum/rbf/preference-rbf-checkbox.png
      caption: >
        Sending Transaction - Preferences Pane with RBF checkbox.
    - image: /img/compatibility/electrum/rbf/transaction-list-outgoing-rbf-transaction.png
      caption: >
        Sending Transaction - Transaction list screen for outgoing RBF signaling
        transaction. RBF noted.
    - image: /img/compatibility/electrum/rbf/transaction-details-outgoing-rbf-transaction.png
      caption: >
        Sending Transaction - Transaction details screen for outgoing RBF
        signaling transaction. No note of RBF signaling.
    - image: /img/compatibility/electrum/rbf/transaction-list-context-menu-increase-fee.png
      caption: >
        Attempting Transaction Replacement - Transaction List context menu for “Increase fee”.
    - image: /img/compatibility/electrum/rbf/dialog-bumped-fee-input.png
      caption: >
        Attempting Transaction Replacement - Dialog for inputting replacement transaction fee.
    - image: /img/compatibility/electrum/rbf/transaction-list-replacement-tx-only.png
      caption: >
        Attempting Transaction Replacement - Transaction list shows only one
        unconfirmed transaction, the latest replacement transaction. RBF noted.
    - image: /img/compatibility/electrum/rbf/transaction-details-replacement-tx.png
      caption: >
        Attempting Transaction Replacement - Transaction details of replacement transaction. No RBF noted. No note of original transaction.
    - image: /img/compatibility/electrum/rbf/incoming-transaction-alert.png
      caption: >
        Receiving Transaction Signaling RBF - Notification of incoming transaction. No specific note that the transaction is RBF signaled.
    - image: /img/compatibility/electrum/rbf/transaction-list-rbf-noted.png
      caption: >
        Receiving Transaction Signaling RBF - Transaction List Screen. Notes RBF
        signaling as well as fee size.
    - image: /img/compatibility/electrum/rbf/transaction-details-incoming.png
      caption: >
        Receiving Transaction Signaling RBF - Transaction Details screen for an
        RBF signaling transaction. No RBF note.
    - image: /img/compatibility/electrum/rbf/alert-incoming-replacement-tx.png
      caption: >
        Receiving Replacement Transaction - New transaction notification for the RBF replacement transaction.
    - image: /img/compatibility/electrum/rbf/transaction-list-replacement-tx.png
      caption: >
        Receiving Replacement Transaction - Transaction List Screen. Notes
        transaction signaling RBF as well as fee size. The replacement transaction does not
        show up as a separate. The original transaction disappears.
    - image: /img/compatibility/electrum/rbf/transaction-details-incoming-replacement.png
      caption: >
        Receiving Replacement Transaction - Transaction details of incoming
        replacement transaction. RBF not noted.
segwit:
  tested:
    date: "2019-04-11"
    platforms:
      - macOS
    version: "3.3.4"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "true"
      bech32m: "untested"
      default: "bech32"
    send:
      bech32: "true"
      bech32m: "true"
      change_bech32: "true"
      segwit_v1: "Error message during broadcasting of transaction."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/electrum/segwit/create-wallet.png
      caption: >
        Electrum prompts users to choose a wallet type. Segwit or Legacy options
        available with Segwit as the default option.
        available.
    - image: /img/compatibility/electrum/segwit/receive-screen.png
      caption: >
        Default receive screen when using a "Segwit" wallet uses bech32 native
        addresses for receiving.
    - image: /img/compatibility/electrum/segwit/create-wallet-p2sh-wrapped.png
      caption: >
        Electrum also [allows p2sh-wrapped segwit
        addresses](https://bitcointalk.org/index.php?topic=3057784.msg31519322#msg31519322)
        with a workaround.
    - image: /img/compatibility/electrum/segwit/address-list.png
      caption: >
        Electrum uses the wallet type's address format for change addresses.
        When using bech32/segwit wallet, the change addresses are bech32.
    - image: /img/compatibility/electrum/segwit/send-screen.png
      caption: >
        Sending to bech32 addresses is possible from all Electrum wallet types.
    #- image: /img/compatibility/electrum/segwit/send-segwit-v1-error.png
    #  caption: >
    #    Sending to segwit v1 addresses fails during broadcast of transaction.
---

<!-- Electrum -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
