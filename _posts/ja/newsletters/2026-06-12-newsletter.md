---
title: 'Bitcoin Optech Newsletter #409'
permalink: /ja/newsletters/2026/06/12/
name: 2026-06-12-newsletter-ja
slug: 2026-06-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、testnet4テストネットワークを後継版に置き換えるためのドラフトBIPについて掲載しています。
また、新しいリリースおよびリリース候補の発表と、人気の高いBitcoin基盤ソフトウェアの注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **testnet5のドラフトBIP**: Pol Espinasaは、Fabian Jahrとの共著で、
  [testnet4][topic testnet]をtestnet5に置き換えるための[ドラフト BIP][testnet5 BIP]について、
  Bitcoin-Devメーリングリストに[投稿しました][testnet5 ml]。
  この提案は、testnet4の信頼性の低さに動機付けられており、それは
  (20分ルールとしても知られる)難易度の例外が継続的に悪用されていることに起因します。
  このルールでは、直前のブロックから20分が経過した後、CPUマイナーは難易度`1`で
  ブロックをマイニングできるため、短時間で大量の低難易度ブロックがマイニングされる
  「ブロックストーム」が発生する可能性があります([ニュースレター #311][news311 block storm]参照)。

  ドラフトBIPでは、testnetが可能な限りmainnetの挙動に一致するよう、
  難易度の例外ルールを削除することを提案しています。testnet5では、2つの変更点を除いて
  mainnetと同じコンセンサスルールに従います。その変更点とは、ブロック`1`からの[BIP54][]
  ([コンセンサスクリーンアップソフトフォーク][topic consensus cleanup])の有効化と、
  Proof of Workの最大ターゲットを`0x1a0fffff`(testnet4よりも低い最大ターゲット、
  つまりより高い最小難易度)に設定することです。

  Espinasaは、他の開発者にこの提案へのフィードバックを提供するよう呼びかけました。
  メーリングリストのスレッドでの議論は、新しいネットワークを立ち上げるのではなく既存のtestnet4にパッチを適用すること、
  testnetコインをプレマインする可能性、そして新しいネットワークにとって最適な最小難易度に集中しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.21.0-beta][]は、この人気のLNノード実装の次期メジャーバージョンのリリースです。
  基本的な[オニオンメッセージ][topic onion messages]の転送や、
  [RBF][topic rbf]による協調閉鎖をサポートする本番対応のSimple [Taproot][topic taproot] Channel、
  チャネル閉鎖に対する再編成保護、[Neutrino][topic compact block filters]ベースのノードのより高速な初期同期、
  オプションのネイティブSQLペイメントストアへのマイグレーション、加えて複数のバグ修正が追加されています。

- [Core Lightning 26.06.1][]は、この人気のLNノードの現行メジャーバージョンのメンテナンスリリースです。
  `make install`の実行後に発生する`bwatch`プラグインの登録失敗を修正します。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35410][]は、[プライベートトランザクションブロードキャスト][topic transaction origin privacy]の再試行が、
  [TorやI2P][topic anonymity networks]を使わずにIPv4またはIPv6ピアへ直接接続してしまう可能性のあるバグを修正します。
  `sendrawtransaction`が`-privatebroadcast=1`([ニュースレター #388][news388 private broadcast]参照)と共に使用された場合、
  Bitcoin Coreはトランザクションのブロードキャスト接続をTorまたはI2Pプロキシ経由で強制します。
  これらの接続のいずれかが[BIP324][] v2トランスポートを試みて失敗した場合、v1トランスポートで再試行します。
  これまでは、その他の点では直接IPv4/IPv6接続を行うノードにおいて、
  この再試行がプライベートブロードキャストのプロキシオーバーライドを忘れてしまう可能性がありました。
  今後はプロキシオーバーライドが保存され、v2からv1への再接続においても引き継がれます。

- [Bitcoin Core #34779][]は [BIP323][]を実装し、ブロックヘッダの`nVersion`のビット5から28をマイナー向けの追加ナンス空間として予約します(
  [ニュースレター #405][news405 bip323]参照)。これまで、これらのビットは未知のソフトフォークのシグナリングを監視する
  [BIP9][]バージョンビット警告ロジックの監視範囲の一部でした。Bitcoin Coreは今後、[BIP323][]で予約されたビットを
  その警告ロジックから除外し、これらのビットをナンスのローリングに使用するマイナーが未知のソフトフォーク警告を引き起こさないようにします。

- [Bitcoin Core #32150][]は、[分岐限定法][Branch-and-Bound]による[コイン選択][topic coin selection]アルゴリズムを書き直し、
  同等のインプットセットを再現するだけの探索木のパーツを遡って探索することを回避します。
  同じ選択プレフィックスを繰り返しバックトラックして再テストする代わりに、新しい探索は次に試すUTXOを追跡し、
  ターゲットに到達できない枝を切り落とし、次の有用な候補へ直接移行し、
  同じ実効値を持つ重複したあるいはより無駄の多いUTXOをスキップします。これにより、
  ウォレットは反復回数の予算を、より多くの異なる候補選択に充てることができます。

- [LDK #4647][]は、[BOLT12][topic offers]の[ブラインドメッセージパス][topic rv routing]において
  リモートの導入ノードを使用するのをやめました。これはチャネルを持たないピアからのメッセージを受信することはあっても転送しない
  LNDのオプトイン式[オニオンメッセージ][topic onion messages]サポートとの非互換性を回避するためです。
  LDKはアナウンスされた受信者自身を導入ポイントとして使用し、相互運用性を向上させますが、受信者のプライバシーは低下します。

- [BTCPay Server #7218][]は、BTCマルチシグウォレット向けのガイド付きセットアップフローを追加します。
  ストアのオーナーは署名ポリシーを選択し、ストアユーザーに手動またはBTCPay Server Vaultを通じて署名者の鍵を提出するよう招待し、
  生成されたアドレスを確認し、必要な鍵が集まった時点でウォレットを作成できます。

- [BIPs #2186][]は [BIP77][]を更新し、[Payjoin v2][topic payjoin]の受信者が
  [BIP78][]互換の送信者にどのように応答するかを規定します。[BIP77][]の通常の応答パスでは、
  送信者が提供するリプライキーを使って提案[PSBT][topic psbt]を暗号化し、
  送信者が導出したリプライメールボックスへ届けますが、[BIP78][]の送信者はリプライキーを提供しません。
  代わりに、受信者はbase64エンコードされた提案PSBTを、送信者が元のPSBTを投稿した受信者のメールボックスへ書き戻します。
  受信者はOHTTPでカプセル化されたPUTリクエストを使用してディレクトリに送信します。
  これは、各実装で使われている後方互換の応答パスを文書化したものです。

{% include snippets/recap-ad.md when="2026-06-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35410,34779,32150,4647,7218,2186" %}

[testnet5 ml]: https://groups.google.com/g/bitcoindev/c/kGUMTxOvdJA/m/Eyx5FxQeAAAJ
[testnet5 BIP]: https://github.com/bitcoin/bips/pull/2196
[news311 block storm]: /ja/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[LND 0.21.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta
[Core Lightning 26.06.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.1
[news388 private broadcast]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[news405 bip323]: /ja/newsletters/2026/05/15/#bips-2116
[Branch-and-Bound]: https://ja.wikipedia.org/wiki/分枝限定法
