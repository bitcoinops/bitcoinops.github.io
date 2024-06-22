---
title: 'Bitcoin Optech Newsletter #308'
permalink: /ja/newsletters/2024/06/21/
name: 2024-06-21-newsletter-ja
slug: 2024-06-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNDの旧バージョンに影響する脆弱性の開示の発表と、
サイレントペイメント用のPSBTに関する継続的な議論を掲載しています。
また、サービスとクライアントソフトウェアの最近の変更や、
リリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも掲載しています。

## ニュース

- **LNDの旧バージョンに影響する脆弱性の開示:** Matt Morehouseは、
  LNDの0.17.0より前のバージョンに影響する脆弱性の開示をDelving Bitcoinに[投稿しました][morehouse onion]。
  LNは、複数の暗号化されたペイロードを含むOnion暗号化パケットを使用して、
  支払いの指示と[Onionメッセージ][topic onion messages]をリレーします。
  各ペイローにはその長さのプレフィックスが付与されてており、
  [2019年以降][news58 variable onions]、支払いには最大1,300バイトまでのサイズが[許可されています][bolt4]。
  その後導入されたOnionメッセージは、最大32,768バイトです。しかし、ペイロードサイズのプレフィックスは、
  最大2<sup>64</sup>バイトまで示すことができるデータ型を使用しています。

  LNDは、ペイロードの指定サイズを最大4GBまで受け入れ、ペイロードを処理する前にその量のメモリを割り当てます。
  これは、一部のLNDノードのメモリを使い果たすのに十分で、その結果、ノードがクラッシュしたり、
  OSによって終了したりします。また、このように構築された複数のOnionパケットを送信することで、
  より多くのメモリを持つノードをクラッシュさせることもできます。クラッシュしたLNノードは、
  資金を保護するために必要な時間的制約のあるトランザクションを送信することができず、
  資金が盗まれる可能性があります。

  この脆弱性は、最大メモリ割り当て量を65,536バイトに減らすことで修正されました。

  LNDノードを運用している人は、バージョン0.17.0以上にアップグレードする必要があります。
  最新のバージョン（執筆時点では0.18.0）へのアップグレードが常に推奨されます。

- **サイレントペイメント用のPSBTの継続的な議論:** 何人かの開発者が、
  [PSBT][topic psbt]を使用した[サイレントペイメント][topic silent payments]の送信を調整するためのサポートについて議論しています。
  [前回の要約][news304 sp-psbt]以降、各署名者が _ECDHシェア_ と、
  そのシェアが正しく生成されたことのコンパクトな証明を生成する手法の使用に焦点が当てられてきました。
  これらは、PSBTのインプットのセクションに追加されます。
  すべての署名者のシェアを受け取ると、受信者のサイレントペイメントスキャンキーと結合され、
  アウトプットスクリプトに配置される実際の鍵が生成されます（または、同じトランザクションで複数のサイレントペイメントが作られる場合は、
  複数のアウトプットスクリプト用の複数の鍵が生成されます）。

  トランザクションのアウトプットスクリプトが判明したら、各署名者はPSBTを再処理して署名を追加します。
  これにより、PSBTの完全な署名には2ラウンドのプロセスが必要になります（[MuSig2][topic musig]などの他のプロトコルで必要な他のラウンドに加えて）。
  ただし、トランザクション全体に対して署名者が1人だけの場合（たとえば、PSBTが単一のハードウェア署名デバイスに送信されている場合など）、
  署名プロセスは1ラウンドで完了できます。

  執筆時点では、議論に参加している全員がこのアプローチにほぼ同意しているようですが、
  エッジケースに関する議論は継続中です。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Casaがディスクリプターをサポート:**
  マルチシグサービスプロバイダーのCasaは、[ブログ記事][casa blog]で、
  [アウトプットスクリプトディスクリプター][topic descriptors]のサポートを発表しました。

- **Specter-DIY v1.9.0リリース:**
  [v1.9.0][specter-diy v1.9.0]のリリースでは、他の変更と共にTaprootの[miniscript][topic miniscript]のサポートと
  [BIP85][]アプリが追加されました。

- **定数時間分析ツールcargo-checkctの発表:**
  Ledgerの[ブログ記事][ledger cargo-checkct blog]で、
  [タイミング攻撃][topic side channels]を回避するためにRust暗号ライブラリが定数時間で実行されるかどうかを評価するツール
  [cargo-checkct][cargo-checkct github]が発表されました。

- **Jadeがminiscriptをサポート:**
  Jadeハードウェア署名デバイスファームウェアはminiscriptを[サポートするようになりました][jade tweet]。

- **Arkの実装の発表:**
  Ark Labsは、[Arkの実装][ark github]と[開発者向けリソース][ark developer hub]を含む、
  [Arkプロトコル][topic ark]に関するいくつかの取り組みを[発表しました][ark labs blog]。

- **Volt Walletベータ版の発表:**
  [Volt Wallet][volt github]は、ディスクリプター、[Taproot][topic taproot]、
  [PSBT][topic psbt]およびその他のBIPとライトニングをサポートします。

- **Joinstrがelectrumをサポート:**
  [Coinjoin][topic coinjoin]ソフトウェアの[Joinstr][news214 joinstr]が[electrumプラグイン][joinstr blog]を追加しました。

- **Bitkit v1.0.1リリース:**
  Bitkitは、セルフカストディアル型のBitcoinおよびライトニングモバイルアプリをベータ版から移行し、
  モバイルアプリストアで利用可能になったことを[発表しました][bitkit blog]。

- **Civkit アルファ版の発表:**
  [Civkit][civkit tweet]は、nostrとライトニングネットワーク上に構築されたP2P取引マーケットプレイスです。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.2rc1][]は、最新の[27.1リリース][bcc 27.1]にアップグレードできないユーザー向けの
  Bitcoin Coreのメンテナンスリリースのリリース候補です。

## 注目すべきコードとドキュメントの変更

_今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29325][]は、トランザクションのバージョンを符号なし整数として保存するようになりました。
  Bitcoin 0.1のオリジナルバージョン以降、トランザクションのバージョンは符号付き整数として保存されていました。
  [BIP68][]ソフトフォークでは、トランザクションのバージョンを符号なし整数として扱うようになりましたが、
  少なくとも1つのBitcoinの再実装ではこの動作を再現できず、コンセンサスエラーが発生する可能性があります（
  [ニュースレター #286][news286 btcd]参照）。常にトランザクションのバージョンを符号なし整数を使用して保存、使用することで、
  Bitcoin Coreのコードに基づく将来のBitcoinの実装で正しい型が使用されることが期待されます。

- [Eclair #2867][]では、[ブラインドパス][topic rv routing]でモバイルウォレットに割り当てられる新しい型
  `EncodedNodeId`を定義します。これにより、ウォレットプロバイダーは、次のノードがモバイルデバイスであることを通知され、
  モバイル固有の条件を考慮できるようになります。

- [LND #8730][]は、承認のターゲットを入力として受け取り、
  オンチェーントランザクションの[手数料の推定][topic fee estimation]をsat/kw（キロweight単位あたりのsatoshi）と
  sat/vbyteの両方で返すRPCコマンド`lncli wallet estimatefee`を導入します。

- [LDK #3098][]は、LDKのRGS（Rapid Gossip Sync）をv2に更新します。
  v2は、シリアライズされた構造にフィールドを追加したv1の拡張です。
  これらの新しいフィールドには、デフォルトのノード機能の数を示すバイト、
  ノード機能の配列、補足機能または各ノードの公開鍵に続くソケットアドレス情報が含まれます。
  この更新は、同様にゴシップv2と呼ばれる提案された[BOLT7][]の更新とは異なります。

- [LDK #3078][]は、設定オプションの`manually_handle_bolt12_invoices`がセットされている場合、
  受信時に`InvoiceReceived`イベントが生成されることで、[BOLT12][topic offers]インボイスの非同期支払いのサポートを追加します。
  `ChannelManager`でインボイスへ支払いを行うための新しいコマンド`send_payment_for_bolt12_invoice`が公開されました。
  これにより、コードでインボイスを評価した上で、支払うか拒否するかを決定できます。

- [LDK #3082][]は、エンコードおよびパース用のインターフェースと、
  [オファー][topic offers]の`InvoiceRequest`への応答としてBOLT12静的インボイスを構築するためのビルダーメソッドを追加することで、
  BOLT12静的インボイス（再利用可能な支払いリクエスト）をサポートします。

- [LDK #3103][]は、実際の支払いパスへの頻繁な[プローブ][topic payment probes]に基づくベンチマークで
  パフォーマンススコアラーを使用し始めます。これにより、より現実的なベンチマークが得られることが期待されます。

- [LDK #3037][]は、手数料率が古く低すぎる場合、チャネルを強制的に閉じるようになります。
  LDKは、過去1日の間に[推定器][topic fee estimation]が返した許容可能な最低手数料率を継続的に追跡します。
  各ブロックで、LDKは過去1日間の最低手数料率を下回るチャネルを閉じます。
  この目標は、「強制的に閉じる必要がある場合に、チャネルの手数料率が常にコミットメントトランザクションをオンチェーンで承認するのに
  十分であることを保証する」ことです。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2867,8730,3098,3078,3082,3103,3037,29325" %}
[news304 sp-psbt]: /ja/newsletters/2024/05/24/#psbt
[news58 variable onions]: /en/newsletters/2019/08/07/#bolts-619
[morehouse onion]: https://delvingbitcoin.org/t/dos-disclosure-lnd-onion-bomb/979
[bcc 27.1]: /ja/newsletters/2024/06/14/#bitcoin-core-27-1
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[news286 btcd]: /ja/newsletters/2024/01/24/#btcd
[casa blog]: https://blog.casa.io/introducing-wallet-descriptors/
[specter-diy v1.9.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.9.0
[cargo-checkct github]: https://github.com/Ledger-Donjon/cargo-checkct
[ledger cargo-checkct blog]: https://www.ledger.com/blog-cargo-checkct-our-home-made-tool-guarding-against-timing-attacks-is-now-open-source
[jade tweet]: https://x.com/BlockstreamJade/status/1790587478287814859
[ark labs blog]: https://blog.arklabs.to/introducing-ark-labs-a-new-venture-to-bring-seamless-and-scalable-payments-to-bitcoin-811388c0001b
[ark github]: https://github.com/ark-network/ark/
[ark developer hub]: https://arkdev.info/docs/
[volt github]: https://github.com/Zero-1729/volt
[news214 joinstr]: /ja/newsletters/2022/08/24/#coinjoin-proof-of-concept-joinstr
[joinstr blog]: https://uncensoredtech.substack.com/p/tutorial-electrum-plugin-for-joinstr
[bitkit blog]: https://blog.bitkit.to/synonym-officially-launches-the-bitkit-wallet-on-app-stores-9de547708d4e
[civkit tweet]: https://x.com/gregory_nico/status/1800818359946154471
