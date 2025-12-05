---
title: 'Bitcoin Optech Newsletter #383'
permalink: /ja/newsletters/2025/12/05/
name: 2025-12-05-newsletter-ja
slug: 2025-12-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、NBitcoinライブラリに影響する修正済みの脆弱性について掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する議論や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **NBitcoinライブラリにおけるコンセンサスバグ:** Bruno Garciaは、
  `OP_NIP`使用時に発生する可能性のあるNBitcoinの理論的なコンセンサス障害について
  Delving Bitcoinに[投稿しました][bruno delving]。
  基盤となる配列が最大容量に達している状態で、`_stack.Remove(-2)`が呼び出されると、
  Remove操作はインデックス14の要素を削除し、後続の要素を下にシフトしようとします。
  このシフト処理中に、実装は存在しない`_array[16]`にアクセスしようとし、例外が発生します。

  このバグは、[差分ファジング][diff fuzz]によってのみ発見されました。また、
  この障害は、try/catchブロックで補足されていたため、従来のファジング手法では発見されなかった可能性があります。
  問題を発見した後、Bruno Garciaは2025年10月23日にNicolas Dorierに報告しました。
  同日、Nicolas Dorierは問題を確認し、修正[パッチ][nbitcoin patch]を公開しました。
  NBitcoinを使用しているフルノード実装は知られていないため、チェーン分岐のリスクはありません。
  これが開示が迅速に行われた理由です。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **LNHANCEソフトフォーク**: moonsettlerは、LNHANCEを構成する4つのopcodeすべてで
  BIPとリファレンス実装が更新されたことを受け、LNHANCEのソフトフォークを[提案しました][ms ml lnhance]。
  [BIP119][]（[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]）、
  [BIP348][]（[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]）、
  [BIP349][]（INTERNALKEY）および[BIPs #1699][]（PAIRCOMMIT）は、
  [Tapscript][topic tapscript]に再バインド可能な署名とマルチコミットメントを追加し、
  すべてのScriptバージョンに次トランザクションへのコミットメントを追加します。
  `OP_TEMPLATEHASH`を含む同様のTapscript専用opcodeのパッケージが[最近提案されました][news365 oth]。
  このパッケージは同様の機能を備えていますが、汎用的なマルチコミットメントはなく、
  より新しいためコードの大部分についてまだ十分なレビューを受けていません。

- **varopsバジェットベンチマーク**: Julianは、[varopsバジェット][bip varops]下での
  Bitcoinスクリプト実行のベンチマークを行うための呼びかけを[行いました][j ml varops]。
  Script Restoration（[ニュースレター #374][news374 gsr]参照）チームは、
  選択されたvaropsパラメーターを確認または改善するために、
  さまざまなハードウェアおよびオペレーティングシステムで[ベンチマーク][j gh bench]を実行し、
  結果を共有するようにユーザーに求めています。Russell O'Connorへの回答として、
  Julianは、新しい[Tapscript][topic tapscript]バージョンでは、
  （sigopsバジェットに加えてではなく）sigopsバジェットの代わりにvaropsバジェットが使用されることを明確にしました。

- **SLH-DSA (SPHINCS) 耐量子署名の最適化**:
  [量子コンピューティング][topic quantum resistance]に対するBitcoinの強化に関する活発な議論を続ける中で、
  conduitionは署名アルゴリズムSPHINCSの最適化に関する研究を[発表しました][c ml sphincs]。
  これらの最適化には、数MBのRAMと、ローカルでコンパイルされたシェーダー（高度に最適化されたCPU固有のマシンコードで、
  永続的にキャッシュされるか、起動時に計算される）が必要です。適用可能な場合、
  最適化SPHINCSの署名と鍵生成処理は、従来の先端技術よりも桁違いに高速化され、
  楕円曲線の演算よりもわずか2桁遅いだけです。さらに重要なことは、
  最適化された署名検証は、楕円曲線の署名検証とほぼ同じ速度であるということです。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning v25.12][]は、この主要なLN実装のリリースで、
  新しいバックアップ方法として[BIP39][]ニーモニックシードフレーズを追加し、
  経路探索を改善し、実験的な[JITチャネル][topic jit channels]のサポートを追加するなど、
  多くの機能追加とバグ修正が行われています。データベースの重大な変更のため、
  このリリースには問題が発生した場合に備えてダウングレードツールが含まれています（詳細は以下参照）。

- [LDK 0.2][]は、ライトニングアプリケーション構築用ライブラリのメジャーリリースです。
  （実験的な）[スプライシング][topic splicing]のサポート、
  [非同期支払い][topic async payments]用の静的なインボイスの提供と支払い、
  [エフェメラルアンカー][topic ephemeral anchors]を使用したゼロ手数料のコミットメントチャネル、
  その他多くの機能やバグ修正、APIの改善が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Core Lightning #8728][]は、ユーザーが間違ったパスフレーズを入力した際に
  `hsmd`がクラッシュするバグを修正しました。現在は、このユーザーのエラーケースを適切に処理し、
  終了するようになりました。

- [Core Lightning #8702][]は、アップグレードエラーが発生した場合に、
  データベースのバージョンを25.12から以前の25.09にダウングレードする`lightningd-downgrade`ツールを追加しました。

- [Core Lightning #8735][]は、再起動時に一部のオンチェーン支払いがCLNのビューから消えてしまうという
  長年のバグを修正しました。起動時に、CLNは（デフォルトで）最新15ブロックをロールバックし、
  それらのブロックで使用されたUTXOの高さを`null`にリセットしてから再スキャンします。
  これまでは、CLNはこれらのUTXOの再監視に失敗し、
  既に閉鎖したチャネルの[チャネルアナウンス][topic channel announcements]をリレーし続けたり、
  重要なオンチェーン支払いを見逃したりする可能性がありました。このPRは、
  起動時にこれらのUTXOを再監視することを保証し、このバグによって以前見逃されていた支払いをリカバリーするために、
  1回だけ後方スキャンを行います。

- [LDK #4226][]は、受信した[トランポリン][topic trampoline payments]オニオンの
  amountおよびCLTVフィールドを外側のオニオンと検証するようになりました。
  また、トランポリン支払いの転送のサポートに向けた最初のステップとして3つの新しいローカル失敗理由
  `TemporaryTrampolineFailure`、`TrampolineFeeOrExpiryInsufficient`、
  `UnknownNextTrampoline`を追加しました。

- [LND #10341][]は、Hidden Serviceの再起動時に、
  ノードアナウンスと`getinfo`出力で同じ[Tor][topic anonymity networks]オニオンアドレスが重複していたバグを修正しました。
  このPRは、`createNewHiddenService`関数がアドレスを重複させないことを保証します。

- [BTCPay Server #6986][]は、サーバ管理者がユーザーログインに
  `Subscription`（[ニュースレター #379][news379 btcpay]参照）を必須にできる`Monetization`を導入しました。
  この機能により、アンバサダーや新規ユーザーをオンボーディングするBitcoinユーザー、
  そしてローカルコンテキストの事業者は、自身の活動をマネタイズできるようになります。
  デフォルトで7日間の無料トライアル期間と無料のスタータープランが用意されていますが、
  サブスクリプションはカスタマイズ可能です。既存ユーザーは自動的にサブスクリプションに登録されませんが、
  後から移行することは可能です。

- [BIPs #2015][]は、[コンセンサスクリーンアップ][topic consensus cleanup]提案である[BIP54][]に
  テストベクタを追加し、4つの緩和策それぞれにベクタのセットを導入しました。
  これらのベクタは、Bitcoin Inquisitionの[BIP54][]実装と、
  カスタムBitcoin Coreのマイニング単体テストから生成され、
  実装とレビューでの使用方法がドキュメント化されています。詳細については、
  [ニュースレター #379][news379 bip54]をご覧ください。

{% include snippets/recap-ad.md when="2025-12-09 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1699,8728,8702,8735,4226,10341,6986,2015" %}
[ms ml lnhance]: https://groups.google.com/g/bitcoindev/c/AlMqLbmzxNA
[gs ml thikcs]: https://groups.google.com/g/bitcoindev/c/5wLThgegha4/m/iUWIZPIaCAAJ
[j ml varops]: https://groups.google.com/g/bitcoindev/c/epbDDH9MHNw/m/OUrIeSHmAAAJ
[news365 oth]: /ja/newsletters/2025/08/01/#taproot-op-templatehash
[news374 gsr]: /ja/newsletters/2025/10/03/#draft-bips-for-script-restoration-bip
[bip varops]: https://github.com/rustyrussell/bips/blob/guilt/varops/bip-unknown-varops-budget.mediawiki
[j gh bench]: https://github.com/jmoik/bitcoin/blob/gsr/src/bench/bench_varops.cpp
[c ml sphincs]: https://groups.google.com/g/bitcoindev/c/LAll07BHwjw/m/2k7o2VKwAQAJ
[bruno delving]: https://delvingbitcoin.org/t/consensus-bug-on-nbitcoin-out-of-bound-issue-in-remove/2120
[nbitcoin patch]: https://github.com/MetacoSA/NBitcoin/pull/1288
[diff fuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
[LDK 0.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2
[news379 btcpay]: /ja/newsletters/2025/11/07/#btcpay-server-6922
[news379 bip54]: /ja/newsletters/2025/11/07/#bip54-test-vector
[Core Lightning v25.12]: https://github.com/ElementsProject/lightning/releases/tag/v25.12