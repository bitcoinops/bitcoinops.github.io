---
title: 'Bitcoin Optech Newsletter #414'
permalink: /ja/newsletters/2026/07/17/
name: 2026-07-17-newsletter-ja
slug: 2026-07-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinプロトコルに形式検証を適用する新しいプロジェクトについて掲載しています。
また、新しいリリースとリリース候補の発表や、人気のBitcoin基盤ソフトウェアへの注目すべき変更点など恒例のセクションも含まれています。

## ニュース

- **Bitcoinプロトコルの形式検証**: Keagan McClellandは、Bitcoinプロトコルの形式検証に取り組んでいることについて、
  Bitcoin-Devメーリングリストと[Delving Bitcoin][verif del]に[投稿しました][verif ml]。形式検証とは、数学の形式手法を用いて、
  システムが仕様に対して正しいことを証明することを目指すソフトウェア開発の実践手法です。これは、
  Bitcoinのコンセンサスルールへの変更提案に関する事実の論争を解決する助けとなる可能性があります。Optechは以前、
  Bitcoinのコンセンサスルールの宣言的な実行可能仕様を開発する関連プロジェクトを取り上げました（[ニュースレター #402][news402 hornet]参照）。

  McClellandは、検証プロセスの[Lean4][lean lang]による実装である[btc-verified][verif gh]を開発しています。
  著者は、このアプローチを実証する初期結果を提供しました。特に、Bitcoinがマークルルートの計算に用いるアルゴリズムに注目しました。
  このアルゴリズムには、2つの異なるトランザクションリストが同一の[マークルルート][topic merkle tree vulnerabilities]を生成しうるという
  既知の欠陥（[CVE-2012-2459][topic cves]）が含まれています。Bitcoin Coreのマークルルート構築には、
  この変異を検出することを目的としたチェックが含まれています。McClellandはbtc-verifiedを用いて、このチェックが正しいこと、
  そしてSHA256が衝突耐性を持つという仮定の下で、2つの異なるトランザクションリストがこのチェックを通過して
  同一のマークルルートを生成することはできないことを、形式的に証明しました。

  最後に著者は、リポジトリと全体的なアプローチの両方について、他者からのフィードバックを求めました。
  また、リポジトリでAIを多用していることや、プロジェクトが現状では未成熟であることなど、いくつかの但し書きも示しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 30.3][]は、主要なフルノード実装のメンテナンスリリースです。
  通常運用時に過剰なディスクの読み書きを引き起こす可能性があったchainstateデータベースの問題を修正したほか、
  ウォレット、[PSBT][topic psbt]、[miniscript][topic miniscript]、ネットワーク、ビルド、テスト、ドキュメントに関する修正が含まれています。
  詳細は[リリースノート][bcc30.3 rn]をご覧ください。

- [Bitcoin Core 29.4][]は、主要なフルノード実装のメンテナンスリリースです。30.3と同じchainstateデータベースの書き換えの問題を修正し、
  選択された検証、ウォレット、ビルド、テスト、ドキュメント、CI、互換性に関する修正が含まれています。
  詳細は[リリースノート][bcc29.4 rn]をご覧ください。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35295][]は、ブロックのトランザクションインプットによって使われるコインを並列に取得することで、
  ブロック検証を高速化します。検証を開始する前に、Bitcoin Coreは複数のワーカースレッドを起動して異なる過去のアウトプットを並行して取得し、
  その一方でメインスレッドは通常の順序でブロックを処理します。新しい`-prevoutfetchthreads`オプションはデフォルトで8つのワーカーを使用し、
  最大16まで許可され、0に設定することでこの最適化を無効化できます。この変更により、多数のディスク読み込みのレイテンシが逐次的に積み重なるのを防ぎます。
  ハードウェアと設定次第で、著者のベンチマークでは初期ブロックダウンロード（IBD）が1.18倍から3倍以上の高速化を示しています。

- [Bitcoin Core #34897][]は、インデックスの先端が最後にフラッシュされたchainstateブロックの祖先でない限りインデックスのコミットをスキップすることで、
  オプションのインデックスがchainstateの最後の耐久的なUTXOフラッシュよりも先の状態を決して永続化しないようにします。これまでは、
  正常でないシャットダウンによって、chainstateがindexよりも前のブロックにある状態でBitcoin Coreが再起動し、
  2つのデータベース間で不整合が生じる可能性がありました。これは特に`coinstatsindex`にとって問題でした。
  そのローリング[MuHash][news131 muhash]の状態は、対応するブロックを再処理しない限り元に戻すのが難しく、
  しかもそのブロックはchainstate上では利用できなくなっているためです。インデックスはメモリ上でより新しいブロックを処理できますが、
  現在ではその進捗をディスクに保存する前にchainstateが追いつくのを待つようになりました。

- [Bitcoin Core #35406][]は、[プライベートブロードキャスト][topic transaction origin privacy]の追跡キューを
  10,000トランザクションに制限します（[ニュースレター #409][news409 privatebroadcast]参照）。この方法でブロードキャストされたトランザクションは、
  ネットワークから戻ってくるのが観測されるまで追跡されます。以前は追跡キューのサイズが無制限だったため、
  ポリシーの相違により決して戻ってこないトランザクションが無限に蓄積し、無制限のメモリとCPUを消費する可能性がありました。上限に達すると、
  Bitcoin Coreは既存のエントリを削除することなく新しい提出を拒否します。ユーザーは`getprivatebroadcastinfo`でキューを確認でき、
  `abortprivatebroadcast`で行き詰まったトランザクションを削除できます。

- [Bitcoin Core #35380][]は、各トランザクションインプットのwitness stackと`scriptSig`を公開するために、
  `btck_WitnessStack`ビューとその要素を数え・取得し・コピーする関数を追加し、`libbitcoinkernel`
  API([ニュースレター #380][news380 kernel]参照)を拡張します。これにより、
  [サイレントペイメント][topic silent payments]スキャナーを含む外部アプリケーションが、
  rawトランザクションを別途デシリアライズすることなく、segwitのwitnessデータやP2PKHの
  `scriptSig`に格納された公開鍵を取得できるようになります。これらのインプットの公開鍵は、
  サイレントペイメントスキャナーがトランザクションのアウトプットのいずれかがウォレットに属するかどうかを判断するために必要です。

- [Bitcoin Core #35568][]は、内部のLevelDB Bloom Filterを無効化することで、
  オプションの`txospenderindex`（[ニュースレター #394][news394 txospender]参照）の同期時間とディスク使用量を削減します。
  これらはデータベース検索の最適化であり、SPVウォレットが歴史的に使用してきた
  [BIP37][]の[Bloom Filter][topic transaction bloom filtering]とは無関係です。
  LevelDBのBloom Filterは一度も参照されておらず、処理とストレージのオーバーヘッドを増やすだけでした。
  著者のベンチマークではインデックスの完全な同期が4時間37分から3時間57分に短縮され、ディスク使用量は85.0 GiBから80.9 GiBに減少しました。
  既存のインデックスは互換性を保ちますが、以前に生成されたフィルターが使用していた領域を回収するにはインデックスの再構築が必要です。

- [Bitcoin Core #34538][]は、`externalip` オプションで明示的に設定されたアドレスを、
  たとえ`onlynet`オプションがそのネットワークを除外していても、通知の対象として適格にします。
  この変更は、あるネットワーク経由で自動的なアウトバウンド接続を開き、別のネットワーク経由でインバウンド接続を受け付けるノードにとって有益です。
  例えば、IPv4のみでアウトバウンド接続を確立しつつ、別途設定された[Tor][topic anonymity networks]
  オニオンサービスを運用しているノードを考えてみてください。これまでは、`onlynet`オプションがTorを到達不能とマークするため、
  Bitcoin Coreは手動で指定されたオニオンアドレスを拒否していました。

- [BIPs #2208][]は、[BIP54][]の[コンセンサスクリーンアップ][topic consensus cleanup]の根拠を更新します。
  この提案は、witnessを除外して64 byteになるトランザクションを無効化し、
  そのハッシュがマークルツリーの内部ノードのハッシュと混同されるのを防ぐことを提案しています。このPRは、
  64 byteのトランザクションを有効なまま保ちつつ、2つの32 byteの子ハッシュを連結すると有効な64 byteのトランザクションを形成してしまう
  マークルツリーの内部ノードを拒否する、という代替提案を文書化しています（[ニュースレター #412][news412 merkle64]参照）。さらに、
  このPRは、マークルプルーフの検証者は更新を決して必要としないというBIP54の従来の主張を訂正します。
  通常の64 byte以外のトランザクションのプルーフは自動的に保護されますが、64 byteのトランザクションのプルーフを受け入れる検証者は、
  アクティベーション後にそれらを拒否する必要があります。

- [LND #10962][]は、[RBF][topic rbf]による協調閉鎖フロー（[ニュースレター #347][news347 rbf]参照）が、
  [Taproot Assets][topic client-side validation]チャネルのように、
  ファンディングアウトプットが追加のプロトコル状態にコミットしている補助的なチャネルに対して使用されるのを防ぎます。
  LNDはこれまで、ピアレベルの機能ビットを用いてRBFクローザーを選択していましたが、
  そのクローザーは資産をクロージングトランザクションに引き継ぐために必要な補助フックを呼び出しません。
  そのため、有効なBitcoinトランザクションをブロードキャストしてしまい、資産のコミットメントを破壊して
  チャネルを閉鎖待ちの状態のまま行き詰まらせる可能性がありました。

- [LND #10897][]は、[Taproot Assets][topic client-side validation]チャネルのような補助的なチャネルのインプットを
  恒久的に取り残してしまう可能性があったsweeperのバグを修正します。これらのインプットは、その価値の大部分がオーバーレイ資産で表されるため、
  小さなビットコインの手数料予算しか持っていないことがあり、その一方で補助的なsweeperが最終的なsweepトランザクションに追加の予算を提供します。
  当初、LNDのフィルターは各インプット自身の予算のみを考慮していたため、失敗したsweepによって必要な開始手数料率が上昇すると、
  そのインプットが以降のあらゆる試行から除外される可能性がありました。現在ではフィルターは、
  インプットが最小リレー手数料と開始手数料率を賄えるかどうかを判断する際に、補助的な寄与分を含めるようになりました。

- [BINANAs #21][]は、ドラフト段階の`OP_PAIRCOMMIT`提案である [BIP442][]（[ニュースレター #395][news395 paircommit]参照）に
  BIN-2025-0003を割り当てます。

{% include snippets/recap-ad.md when="2026-07-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35295,34897,35406,35380,35568,34538,2208,10962,10897,21" %}

[verif ml]: https://groups.google.com/g/bitcoindev/c/OIml9stwbGQ
[verif del]: https://delvingbitcoin.org/t/btc-verified-formalizing-the-bitcoin-protocol/2684
[verif gh]: https://github.com/ProofOfKeags/btc-verified
[lean lang]: https://lean-lang.org/
[Bitcoin Core 30.3]: https://bitcoincore.org/bin/bitcoin-core-30.3/
[bcc30.3 rn]: https://bitcoincore.org/ja/releases/30.3/
[Bitcoin Core 29.4]: https://bitcoincore.org/bin/bitcoin-core-29.4/
[bcc29.4 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.4.md
[news131 muhash]: /ja/newsletters/2021/01/13/#bitcoin-core-19055
[news402 hornet]: /ja/newsletters/2026/04/24/#hornet-bitcoin
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news394 txospender]: /ja/newsletters/2026/02/27/#bitcoin-core-24539
[news409 privatebroadcast]: /ja/newsletters/2026/06/12/#bitcoin-core-35410
[news412 merkle64]: /ja/newsletters/2026/07/03/#prohibit-merkle-internal-node-preimages-that-encode-minimal-64-byte-transactions-64-byte
[news347 rbf]: /ja/newsletters/2025/03/28/#lnd-8453
[news395 paircommit]: /ja/newsletters/2026/03/06/#bips-1699
