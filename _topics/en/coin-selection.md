---
title: Coin selection

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Fee Management
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Coin selection** is the method a wallet uses to choose which of its
  UTXOs to spend in a particular transaction.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Coin selection simulations
    url: /en/newsletters/2018/06/26/#coin-selection-simulations

  - title: Coin selection groups for privacy and consolidation
    url: /en/newsletters/2018/07/17/#coin-selection-groups-discussion

  - title: Bitcoin Core unlikely to add coin selection RPC
    url: /en/newsletters/2018/07/24/#coin-selection-rpc-unlikely

  - title: Bitcoin Core PR#17290 coin selection for customized transactions
    url: /en/newsletters/2019/11/27/#bitcoin-core-17290

  - title: Bitcoin Core PR#13756 adds flag to avoid address reuse privacy loss
    url: /en/newsletters/2019/06/26/#bitcoin-core-13756

  - title: Bitcoin Core 0.19 adds wallet flag to avoid address reuse privacy loss
    url: /en/newsletters/2019/11/27/#optional-privacy-preserving-address-management

  - title: "Bitcoin Core #22009 introduces new heuristic to compare the effectiveness of coin selection results"
    url: /en/newsletters/2021/09/08/#bitcoin-core-22009

  - title: "Bitcoin Core #17526 adds Single Random Draw coin selection algorithm"
    url: /en/newsletters/2021/10/06/#bitcoin-core-17526

  - title: "What is the coin selection 'waste metric'?"
    url: /en/newsletters/2022/05/25/#what-does-waste-metric-mean-in-the-context-of-coin-selection

  - title: "Bitcoin Core #24584 prefers input sets composed of a single output type for privacy"
    url: /en/newsletters/2022/08/10/#bitcoin-core-24584

  - title: "BTCPay Server #4600 updates its coin selection to avoid unnecessary inputs for payjoin"
    url: /en/newsletters/2023/02/15/#btcpay-server-4600

  - title: "Bitcoin Core #27021 adds interface for calculating an output's ancestor fee deficit"
    url: /en/newsletters/2023/05/24/#bitcoin-core-27021

  - title: "Bitcoin Core #26152 now pays any fee deficit for unconfirmed outputs chosen by coin selection"
    url: /en/newsletters/2023/09/20/#bitcoin-core-26152

  - title: "New coin selection strategies proposed and tested for Bitcoin Core"
    url: /en/newsletters/2024/01/03/#new-coin-selection-strategies

  - title: "Bitcoin Core #27877 updates Bitcoin Core's wallet with CoinGrinder coin selection strategy"
    url: /en/newsletters/2024/02/21/#bitcoin-core-27877

  - title: "New coin selection strategy for LN liquidity providers"
    url: /en/newsletters/2024/02/28/#coin-selection-for-liquidity-providers

  - title: "LND #8378 makes several improvements to LND’s coin selection features"
    url: /en/newsletters/2024/03/06/#lnd-8378

  - title: "LND #8515 updates multiple RPCs to accept the name of the coin selection strategy to be used"
    url: /en/newsletters/2024/04/10/#lnd-8515

  - title: Notes from Bitcoin developer discussion about coin selection
    url: /en/newsletters/2024/05/01/#coredev-tech-berlin-event

  - title: "Effect of SubtractFeeFromOutputs on coin selection in Bitcoin Core"
    url: /en/newsletters/2024/06/28/#how-does-subtractfeefrom-work

## Optional.  Same format as "primary_sources" above
see_also:
  - title: An Evaluation of Coin Selection Strategies
    link: https://murch.one/erhardt2016coinselection.pdf

---
Most early Bitcoin wallets implemented relatively simple coin
selection strategies, such as spending UTXOs in the order they were
received (first-in, first-out), but as fees have become more of a
concern, some wallets have switched to more advanced algorithms that
try to minimize transaction size.

Coin selection strategies can also be used to improve onchain privacy
by trying to avoid the use of UTXOs associated with previous
transactions in later unrelated transactions.

{% include references.md %}
