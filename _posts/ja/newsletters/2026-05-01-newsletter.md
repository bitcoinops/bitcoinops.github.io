---
title: 'Bitcoin Optech Newsletter #403'
permalink: /ja/newsletters/2026/05/01/
name: 2026-05-01-newsletter-ja
slug: 2026-05-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、コンパクトブロックフィルターで使用されるGCSの代替として
バイナリフューズフィルターを利用する研究について掲載しています。また、
Bitcoinのコンセンサスルールの変更に関する議論や、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **BIP158のGCSの代替としてのバイナリヒューズフィルター**: Csaba Purszkiは、
  [BIP158][]で定義されている[コンパクトブロックフィルター][topic compact block filters]で使用されている
  GCS（Golomb-Rice Coded Sets）より良い代替手段を見つけるための研究をDelving Bitcoinに[投稿しました][bin fuse del]。

  Purszkiによると、適切な代替手段は、近似的なセットメンバーシップ用の確率的データ構造であるバイナリヒューズフィルターで、
  特にFuse16と呼ばれる16-bit版が挙げられています。この種のアルゴリズムの主な特徴は、
  O(1)のクエリ時間を実現できる点であり（参考までにGCSはO(N)）、
  これによりフィルターのクエリに必要なCPUパワーが削減できます。さらに、これらのフィルターは、
  偽陰性ゼロを保証し、偽陽性率は`1/2^k`（`k`はbit数）となります。

  Purszkiは、現在のGCSのパフォーマンスとバイナリヒューズフィルターを比較した予備的な研究結果を提供しています。
  テストは10種類の異なるウォレットのユースケース（24個のスクリプトから480個のスクリプトまで）で、
  mainnetの50,000ブロックまでフィルターを実行し、デスクトップのx86_64とARMという2つの異なるCPUで実施されました。
  バイナリヒューズフィルターは、ウォレットのユースケースに応じてARMで6倍〜45倍、デスクトップで9〜80倍の高速化を達成し、
  代償として帯域幅がわずかに0%〜3%増加しました。手法と完全な結果の詳細については、
  [Purszkiのウェブサイト][bin fuse web]をご覧ください。

  Kyotoの開発者のRobert Netzkeは、GCSに対する偽陽性率の違いと、
  このアルゴリズムで発生し得る障害についてコメントしました。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **フォールバックSPHINCS鍵を備えたポスト量子HDウォレット:** Conduitionは、
  Bitcoin-Devメーリングリストへの[投稿][c ml pq bip32]で、
  フォールバック[SPHINCS][news383 sphincs]鍵を備えた[ポスト量子][topic quantum resistance]
  [BIP32][]互換の[階層的決定性ウォレット][topic bip32]の設計について説明しました。
  この設計では、BIP32の子鍵導出関数を置き換えることで、
  [secp256k1][secp256k1]の鍵と並行してSPHINCSの鍵を生成します。
  SPHINCSの鍵には代数的な関係がないため、非強化導出された子鍵はその親および兄弟と同じSPHINCS鍵を共有します。
  これにより、ウォレットはBIP32ウォレットと同等のプライバシーを保つために、
  SPHINCS鍵を使って支払いをするスクリプトにナンス（またはsecp256k1鍵）を挿入する必要があります。
  この設計上の選択の利点は、コストの高い完全なSPHINCS鍵の導出を最初の非強化導出ステップまで遅延させ、
  それ以降のすべての非強化導出鍵についてキャッシュできる点にあります。このウォレット設計は、
  [BIP360][]のP2MRアウトプットおよび将来の`OP_CHECKSPHINCS`（または類似のもの）と組み合わせて、
  量子耐性ウォレットへの移行を可能にすることを意図しています。Conduitionは、
  このようなウォレット構造は、将来的にコストの低いポスト量子署名アルゴリズムと組み合わせることも可能であり、
  万が一それらが安全でないことが判明した場合に備えて、SPHINCSが信頼できるフォールバック手段になることを示唆しています。

- **<!--discussion-of-a-post-quantum-output-type-->ポスト量子アウトプットタイプの議論**:
  Antoine Poinsotは、Bitcoin-Devメーリングリストに（後のソフトフォークによって量子脆弱な鍵での支払いを無効化できる
  [P2TR][topic taproot]ライクなアウトプットタイプとは対照的に）純粋なポスト量子アウトプットタイプを擁護する[投稿をしました][ap ml pqout]。
  論点の核心は、量子脆弱な支払いを無効化するかどうか、いつ無効化するのが理にかなっているのかという判断と、
  ユーザーが各自の裁量でポスト量子暗号への移行を可能にすることとは分離すべきだという点です。
  続くやり取りの中で、参加者たちは[Tapscript][topic tapscript]へのポスト量子署名の追加と
  純粋なポスト量子アウトプットタイプの追加の両方について合意しました。移行をどの程度奨励すべきか、
  また量子脆弱な署名をいつ/無効化すべきかなど、いくつかの未解決の論点が残っています。

- **コンセンサスを変更することなくTapscriptにポスト量子鍵を埋め込む提案**: Daniel
  Buchnerは、署名検証パラメーターを完全に規定することなく柔軟なポスト量子ウォレットの設計を可能にする可能性のある道筋の提案を
  Bitcoin-Devメーリングリストに[送りました][db ml minpqc]。[BIP342][]の署名検証opcodeは、
  32 byte以外のすべての鍵を未知の鍵タイプとして扱い、空でない任意の署名で有効とするため、
  スクリプトを秘密に保つか、未知の鍵に加えて安全な[BIP340][]署名も要求する限り、
  他の鍵長（この場合は先頭にタグ byteを付与した）を現状のスクリプトでも使用できます。Buchnerの提案が標準化されると、
  ウォレットは現時点でさまざまなポスト量子鍵タイプを用いてスクリプトを構築しつつ、
  ソフトフォークによってポスト量子鍵での安全な仕様が可能になるまで、量子脆弱な鍵での使用を継続できるようになります。
  多くの量子移行の提案と同様に、本提案も鍵の再利用が厳格に防止されている場合にのみ、
  量子攻撃者に対して安全性を保ちます。Buchnerは本提案へのフィードバックを募集しています。

- **signet上でBIP54の遅いブロックの実証**:
  Antoine Poinsotは、[BIP54][]（[コンセンサスクリーンアップ][topic consensus cleanup]）が防止する
  検証に時間がかかるブロックの種類を示す実証についてDelving Bitcoinに[投稿しています][ap delving slowblocks]。
  1日3回、検証に時間がかかるブロックの束が最も使用されているBitcoinの[signet][topic signet]上で署名された後に再編成で取り除かれることで、
  これらのブロックの伝播および検証挙動のテストを可能にしつつ、signetの初期ブロックダウンロードを永続的に低下させないように行われました。
  世界中の多くの人が遅いブロックが自分のノードに到達するのを観察し、検証および伝播の挙動をログに記録しました。
  予想通り、検証の遅いブロックは一般的なブロックと比較してネットワーク内をはるかに遅く伝播し、
  個々のノード上で完全に検証されるまでに大幅に長い時間を要しました。なお、これらの実証用のブロックは、
  BIP54によって防止されるワーストケースには遠く及ばないことに注意が必要です。

- **BIP32シードのzk-STARK証明を使用したポスト量子BIP86リカバリー**:
  Olaoluwa Osuntokun (roasbeef)は、[BIP32][]を使って導出された鍵で保護された量子脆弱なコインの
  zk-STARKリカバリーを実証する自身のプロジェクトをBitcoin-Devメーリングリストに[投稿しました][oo ml pqrecovery]。
  暗号学的に意味のある量子コンピューターに直面して[secp256k1][secp256k1]が無効化された場合の
  コインのリカバリーのためのこのメカニズムは、長らく議論されてきたものの、完全に実証されたことはありませんでした。
  Osuntokunは必要な証明者および検証者の完全に動作する実装を作成し、
  この方法によるリカバリーが少なくとも可能であることを示すベンチマークを提供しました。
  当初の実装は意図的に最適化されておらず、複数の開発者がリカバリーの証明と検証の両方のコストを下げる最適化を提案しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 26.04.1][]は、[ゴシップ][topic channel announcements]プロトコルの修正に加え、
  メジャーリリース直後に問題が発生した環境向けのビルドシステムの修正が含まれるメンテナンスリリースです。

- [BTCPay Server 2.3.8][]は、このセルフホスト型ペイメントソリューションのマイナーリリースで、
  サブスクリプションとPOS機能のアップデート、LUD21 [LNURL-pay][topic lnurl]のサポート、
  サブスクリプションサービスの管理用APIの追加、その他の修正と改善が含まれています。

- [BTCPay Server 2.3.9][]は、メンテナンスリリースで、
  プラグインクラッシュ後のサーバー復旧に対応し、v2.3.8で発生したxpubのパースの問題を修正しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33671][]は、`getbalances` RPC（[ニュースレター #46][news46 getbalances]参照）に
  `nonmempool`フィールドを追加します。これは、未ブロードキャスト、非標準、排除された、
  または長すぎるmempoolチェーンの一部であるトランザクションなど、
  承認もノードのmempoolにも含まれていないトランザクションによって使用されたウォレットUTXOのためのものです。
  これまで、ウォレットがそれらのトランザクションを記録していたにも関わらず、
  残高バケットからこれらのインフライトの支払いに紐付いた金額が省かれることがあり、
  `getbalances`がそれらのコインに対するウォレットの会計処理を完全には反映していませんでした。
  本PRは、その金額を本来あるべき通常の`mine`バケットにカウントし、
  `nonmempool`を介してオフセットを提供することで、各フィールドの合計がウォレットの全体残高と一致するようにしつつ、
  mempoolとの不一致を明示します。

- [Bitcoin Core #34885][]は、`libbitcoinkernel` C API（[ニュースレター #380][news380 kernel]参照）に、
  チェーンブランチ上で指定された高さにおけるブロックの祖先を取得するための
  `btck_block_tree_entry_get_ancestor()`を追加します。
  `btck_block_tree_entry_get_previous()`を繰り返し呼び出して１ブロックずつ遡る代わりに、
  古くなった先端やフォークした先端からブロックロケーターを構築する呼び出し側は、
  必要な高さの祖先を直接要求できるようになります。

- [Bitcoin Core #33920][]は、ビルド時に埋め込まれたノードのASMapデータ（[ニュースレター #394][news394 asmap]参照）を
  ファイルにエクスポートする`exportasmap` RPCを追加します。これにより、
  ユーザーは`contrib/asmap-tool.py`などのツールを使用してデータの検査、検証、分析を行えるようになります。

- [Bitcoin Core #34911][]は、`deprecatedrpc`設定オプションを使用して明示的に要求されない限り、
  いくつかのmempool RPCのレスポンスから非推奨の[RBF][topic rbf]関連のbooleanフィールドを削除します。
  Bitcoin Core 28.0以降、フルRBFの挙動がデフォルトとなり、
  `mempoolfullrbf`オプションはBitcoin Core 29.0で削除されたため、
  `getmempoolinfo` RPCはデフォルトで`fullrbf`フィールドを返さなくなります。
  `getrawmempool`、`getmempoolentry`、`getmempoolancestors`および`getmempooldescendants` RPCは、
  デフォルトで[BIP125][]に記載された非推奨の`bip125-replaceable`を返さなくなります。

- [BIPs #1548][]は、[PSBT][topic psbt]スタイルのkey-valueマップに基づく
  [アウトプットスクリプトディスクリプター][topic descriptors]向けの効率的なコンテナフォーマットである
  BOD（Binary Output Descriptors）の仕様[BIP391][]を追加します。このBIPはクローズ済みで、
  代替として[BIP393][]がリストされています。[BIP393][]では、ディスクリプターアノテーション（[ニュースレター
  #400][news400 bip393]参照）などのウォレットメタデータを処理するための代替方法が提案されたため、
  [BIP391][]は撤回されました。

- [HWI #831][]は、Ledger Nano Gen5ハードウェア署名デバイスのサポートを追加します。

- [BDK #2188][]は、Electrumサーバーから返されたトランザクションが要求されたtxidと一致することを、
  キャッシュまたは使用前に検証するようにします。これまでは、サーバーが`fetch_tx()`リクエストに対して
  任意のトランザクションデータと異なるtxidを返すことができ、BDKはそれを受け入れていました。

- [BDK #2115][]は、`ToBlockHash`トレイトをオプションの`prev_blockhash()`メソッドで拡張することで、
  `CheckPoint`に直前のブロックハッシュの認識機能を追加します。これにより、
  BDKは隣接するチェックポイントのペイロードがブロックヘッダーのように直前のブロックハッシュ情報を含む場合に、
  それらが接続することを検証できるようになります。これはまた、
  `merge_chains()`が高さ0で衝突するチェックポイントを通常の再編成として扱って置き換えることも防止します。
  今後は2つのチェックポイントチェーンがジェネシスについて一致しない場合、マージは失敗します。
  `CheckPoint`に関するこれまでの作業については、ニュースレター[#372][news372 checkpoint]および
  [#390][news390 checkpoint]をご覧ください。

{% include snippets/recap-ad.md when="2026-05-05 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33671,34885,33920,34911,831,2188,2115,1548" %}
[c ml pq bip32]: https://groups.google.com/g/bitcoindev/c/5tLKm8RsrZ0
[news383 sphincs]: /ja/newsletters/2025/12/05/#slh-dsa-sphincs
[secp256k1]: https://en.bitcoin.it/wiki/Secp256k1
[ap ml pqout]: https://groups.google.com/g/bitcoindev/c/JA3kDl8AmQg
[db ml minpqc]: https://groups.google.com/g/bitcoindev/c/jn7COyeHtW0
[ap delving slowblocks]: https://delvingbitcoin.org/t/consensus-cleanup-demo-of-slow-blocks-on-signet/2367
[oo ml pqrecovery]: https://groups.google.com/g/bitcoindev/c/Q06piCEJhkI
[bin fuse del]: https://delvingbitcoin.org/t/binary-fuse-filters-as-an-alternative-to-bip-158-gcs/2428
[bin fuse web]: https://purszki.github.io/bitcoin_research_01/
[BTCPay Server 2.3.8]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.8
[BTCPay Server 2.3.9]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.9
[Core Lightning 26.04.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04.1
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
[news372 checkpoint]: /ja/newsletters/2025/09/19/#bdk-1582
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news390 checkpoint]: /ja/newsletters/2026/01/30/#bdk-2037
[news394 asmap]: /ja/newsletters/2026/02/27/#bitcoin-core-28792
[news400 bip393]: /ja/newsletters/2026/04/10/#bips-2099
[news46 getbalances]: /en/newsletters/2019/05/14/#bitcoin-core-15930
