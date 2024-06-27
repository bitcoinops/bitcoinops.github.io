---
layout: page
permalink: /en/compatibility/bitcoin-core/

name: Bitcoin Core Wallet
internal_url: /en/compatibility/bitcoin-core
logo: /img/compatibility/bitcoin-core/bitcoin-core.png
rbf:
  tested:
    date: "2018-08-28"
    platforms:
      - macOS
    version: "0.16.2"
  features:
    receive:
      notification: "false"
      list: "false"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "true"
    send:
      signals_bip125: "true"  # default in GUI, not default from CLI
      list: "false"
      details: "false"
      shows_replaced_version: "true"
      shows_original_version: "true"
  examples:
    - image: /img/compatibility/bitcoin-core/default-wallet-send-screen.png
      caption: >
        Sending Transaction - Default wallet send screen.
    - image: /img/compatibility/bitcoin-core/wallet-send-screen-fee-details.png
      caption: >
        Sending Transaction - Wallet Send Screen (Transaction Fee details expanded).
    - image: /img/compatibility/bitcoin-core/low-fee-confirmation-with-rbf-note.png
      caption: >
        Sending Transaction - Warning prompt for low fee. Includes RBF note at the bottom when RBF disabled.
    - image: /img/compatibility/bitcoin-core/low-fee-confirmation-with-rbf-note-enabled.png
      caption: >
        Sending Transaction - Warning prompt for low fee. Includes RBF note at the bottom when RBF enabled.
    - image: /img/compatibility/bitcoin-core/transaction-list-outgoing-rbf-transaction.png
      caption: >
        Sending Transaction - Transaction list screen for outgoing transaction signaling RBF. No note of RBF signaling.
    - image: /img/compatibility/bitcoin-core/transaction-details-outgoing-rbf.png
      caption: >
        Sending Transaction - Transaction details screen for outgoing transaction signaling RBF. No note of RBF signaling.
    - image: /img/compatibility/bitcoin-core/transaction-details-context-menu-increase-fee.png
      caption: >
        Attempting Transaction Replacement - Transaction details context menu showing “Increase transaction fee”.
    - image: /img/compatibility/bitcoin-core/increase-fee-confirmation-prompt.png
      caption: >
        Attempting Transaction Replacement - Confirmation prompt for “Increase transaction fee”.
    - image: /img/compatibility/bitcoin-core/transaction-list-post-bump.png
      caption: >
        Attempting Transaction Replacement - Transaction list showing an additional transaction representing the replacement transaction. The original shows up greyed out with brackets around the amount.
    - image: /img/compatibility/bitcoin-core/transaction-details-bumped-transaction.png
      caption: >
        Attempting Transaction Replacement - Transaction details of the outgoing bumped RBF transaction. No flag for RBF.
    - image: /img/compatibility/bitcoin-core/notification-incoming-transaction.png
      caption: >
        Receiving Transaction Signaling RBF - Notification of incoming transaction. No specific note that the transaction signals RBF.
    - image: /img/compatibility/bitcoin-core/transaction-list-rbf-incoming.png
      caption: >
        Receiving Transaction Signaling RBF - Transaction List Screen. No RBF note.
    - image: /img/compatibility/bitcoin-core/transaction-details-rbf-incoming.png
      caption: >
        Receiving Transaction Signaling RBF - Transaction Details screen for an transaction signaling RBF. No RBF note.
    - image: /img/compatibility/bitcoin-core/notification-replacement-transaction.png
      caption: >
        Receiving Replacement Transaction - New transaction notification for the replacement transaction.
    - image: /img/compatibility/bitcoin-core/transaction-list-replacement-incoming.png
      caption: >
        Receiving Replacement Transaction - Transaction List Screen. No RBF note. Both the original and replacement transaction appear with “?”/unconfirmed.
    - image: /img/compatibility/bitcoin-core/transaction-details-original.png
      caption: >
        Receiving Replacement Transaction - Transaction Details screen for original transaction. No RBF note.
    - image: /img/compatibility/bitcoin-core/transaction-details-replacement.png
      caption: >
        Receiving Replacement Transaction - Transaction Details screen for replacement transaction. No RBF note.
segwit:
  tested:
    date: "2019-03-28"
    platforms:
      - macOS
    version: "0.17.1"
  features:
    receive:
      p2sh_wrapped: "true"
      bech32: "true"
      bech32m: "true"
      default: "p2sh_wrapped"
    send:
      bech32: "true"
      bech32m: "true"
      change_bech32: "true"
      segwit_v1: "Transaction can be created and broadcast, but does not make it
      to the mempool."
      bech32_p2wsh: "true"
  examples:
    - image: /img/compatibility/bitcoin-core/segwit/receive-screen.png
      caption: >
        Receive - Generate a new address with tooltip. Bech32 option defaults to
        unchecked. If checked, the checkbox will still be unchecked once
        Bitcoin-Qt is restarted.
    - image: /img/compatibility/bitcoin-core/segwit/address-screen.png
      caption: >
        Address Details - Showing Bech32 address as well as equivalent uri and QR code.
    - image: /img/compatibility/bitcoin-core/segwit/send-screen.png
      caption: >
        Send - By default, the change address takes the same type as the address
        being paid to. Can be overridden with change control's 'Custom change
        address'.
---

<!-- Bitcoin Core Wallet -->

{% assign tool = page %}
{% include templates/compatibility-page.md %}
