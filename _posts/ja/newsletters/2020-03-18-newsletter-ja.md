---
title: 'Bitcoin Optech Newsletter #89'
permalink: /ja/newsletters/2020/03/18/
name: 2020-03-18-newsletter
slug: 2020-03-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LN規格の更新提案の要約、サービス、クライアントソフトウェア、およびBitcoinインフラストラクチャプロジェクトへの主な変更に関する定期的なセクションをお届けします。

## Action items

*今週はなし。*

## News

- **Watchtower BOLTの提案が更新されました:** Sergi Delgado Seguraは [Watchtower][topic watchtowers]との推奨通信プロトコルの[更新版][watchtower bolt]をLighted-Devメーリングリストに[送信][segura email]しました。この提案の元の説明については、[Newsletter#75][news75 watchtower]を参照してください。Seguraによると、このアップデートには「ユーザーアカウント、支払い方法、メッセージ署名」に関する詳細が含まれています。彼のメールには、追加したい機能のリストも記載されており、メールの終わり近くでそれぞれについて議論がされています。

## Changes to services and client software

*この月刊セクションでは、ビットコインのウォレットとサービスの興味深い更新を取り上げます。*

- **バッチでのCoinbase引き出しトランザクション:** Coinbaseは、[batch withdrawals][coinbase batching blog]を展開します。これはBitcoinネットワークの負荷を50％削減すると推定しています。支払い毎にオンチェーントランザクションを生成する各出金の代わりに、10分ごとに複数の支払いが[単一のトランザクションに結合][scaling payment batching]されます。

- **Bitstampはbech32をサポートします:** Exchangeが[bech32入金と引き出しの両方のサポート][bitstamp bech32 blog]を発表しました。Bitstampユーザーはネイティブの[bech32][topic bech32]アドレスを使用することで恩恵を受けることができます。

- **Deribitはbech32の引き出しをサポートしています:**DeribitはExchangeユーザーは、ビットコインをbech32ネイティブアドレスに引き出しできるようになった旨を[発表][deribit bech32 withdrawal tweet]しました。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo] 、[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #16902][]はコンセンサスコードを変更して、「OP_IF」および関連するオペコードの解析の非効率性を修正します。レガシーおよびsegwit v0スクリプトでは、非効率性が重大な問題を引き起こすとは考えられていません。ただし、[tapscript][topic tapscript]の提案により、攻撃者は非効率性を利用して、検証に大量のCPUを必要とする可能性のあるトランザクションでブロックを作成できます。非効率性を修正することにより、提案されているschnorr、taproot、およびtapscriptソフトフォークで行う必要のある変更量を減らすことが可能です。詳細については、ビットコインコアPRレビュークラブ[会議メモ][club #16902]でこのPRをご覧ください。

- [LND #3821][]は、LNチャネルに[アンカーコミットメント][topic anchor outputs]を追加し、チャネル信号の両方の参加ノードがサポートする場合、デフォルトで有効にします。アンカーコミットメント・トランザクションは、いずれかの当事者が一方的に料金を引き上げることができます。この機能は、コミットメント・トランザクションがオンチェーン料金にコミットして長時間経過後にブロードキャストされる（オンチェーン料金がその間に上昇する）可能性があることを考慮したものです。

- [LND #3963][]は、LNDを安全に使用する方法に関する詳細な[ドキュメント][lnd op safety]を追加します。

- [Eclair #1319][]は、[Newsletter #85][news85 ln stuck] で説明されているのと同じソリューションを実装します。このソリューションはチャネル資金提供者がお金を受け取っているが、支払いのコミットメント（HTLC）コストを支払うのに資金が不十分なために支払いが拒否されるというまれなスタックチャネルの問題を解決します。

{% include references.md %}
{% include linkers/issues.md issues="16902,3821,3963,1319" %}
[lnd op safety]: https://github.com/lightningnetwork/lnd/blob/master/docs/safety.md
[segura email]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-March/002586.html
[watchtower bolt]: https://github.com/sr-gi/bolt13/blob/master/13-watchtowers.md
[club #16902]: https://bitcoincore.reviews/16902/
[news75 watchtower]: /ja/newsletters/2019/12/04/#proposed-watchtower-bolt
[news85 ln stuck]: /ja/newsletters/2020/02/19/#c-lightning-3500
[coinbase batching blog]: https://blog.coinbase.com/coinbase-rolls-out-bitcoin-transaction-batching-5f6d09b8b045
[bitstamp bech32 blog]: https://www.bitstamp.net/article/weve-added-support-bech32-bitcoin-addresses-bitsta/
[deribit bech32 withdrawal tweet]: https://twitter.com/DeribitExchange/status/1234904442169851909
