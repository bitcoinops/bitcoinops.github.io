---
title: 'Bitcoin Optech Newsletter #423'
permalink: /ja/newsletters/2026/09/18/
name: 2026-09-18-newsletter-ja
slug: 2026-09-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、マイニングプールの難易度コントローラーが処理の遅いマイナーを取り残してしまう問題の分析と、
Utreexoの初期ブロックダウンロードに対する改善提案や、使用不可能なTaproot内部鍵を指定するためのBIPドラフトのリンクを掲載しています。
また、サービスやクライアントソフトウェアの最近の更新、新しいリリースとリリース候補の発表、
人気のあるBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **処理速度の低下したマイナーを取り残すVardiffコントローラー:**
  Eric Priceは、[マイニングプール][topic pooled mining]が速度の落ちたマイナーに対してどのように難易度を調整するかについての分析を
  Delving Bitcoinに[投稿しました][price vardiff]。プールは各マイナーにシェア難易度を割り当てます。
  これはネットワークの難易度より低いターゲットで、ブロックヘッダー候補がシェアとして提出されるために満たすべきものです。
  可変難易度（vardiff）コントローラーと呼ばれるソフトウェアが、プール内またはマイナーとプールの間のプロキシとして動作し、
  マイナーのシェアの到着速度に基づいてその難易度を増減させ、安定したレートを目指します。処理速度が低下したマイナーは、
  以前の速度向けに設定された難易度のままになるため、生成するシェアが少なくなります。
  シェアが到着したときにのみ更新するコントローラーは、この速度低下に気づけない可能性があります。

  Priceは、コントローラーのパラメータを調整してもこの問題は解決できないと主張しています。
  コントローラーは到着しないシェアからレートを推定できないためです。
  シェアが到着したときにのみ再計算するコントローラーは、難易度を無期限に高すぎる状態に保ってしまう可能性があります。
  彼の修正案は、マイナーからのシェアがないまま一定の間隔が経過するたびに難易度を下げるタイマー機能です。
  Stratum v2のリファレンス実装はすでにこれを行っていますが、長期間接続を維持しているマイナーに対する回復が遅いという課題があります。
  一方、Ckpoolはシェアの到着時にのみ再計算します。彼は、
  マイナーのシェアの一部を破棄する[シェーピングプロキシ][shape proxy]をリリースし、
  運営者が自分のプールが難易度を適切に下げるかどうかをテストできるようにしました。

  Anthony Townsは、Stratum v2および[DATUM][news325 datum]のデプロイメントで使用されるローカルプロキシ
  またはゲートウェイでこの問題を処理することを[提案しました][towns vardiff]。
  たとえばシェアなしで30秒経過した後に接続の難易度を半減させるといった方法です。Priceもこれに同意し、
  [別のスレッド][price frontier]で、マイナーごとの制御は各マイナーのシェアを直接確認できる
  最後のホップに置かれなければならないと主張しました。

- **Utreexoの初期ブロックダウンロードの改善**: Davidson Souzaは、
  初期ブロックダウンロード（IBD）中の[Utreexo][topic utreexo]のパフォーマンスを改善する方法についてDelving Bitcoinに[投稿しました][utreexo ibd del]。
  Utreexoは、UTXOセットを完全なマークルツリーのフォレスト（集合体）として表現する動的アキュムレータで、
  ノードはツリーのルートのみを保存すればよい仕組みです。
  各トランザクションの検証に包含証明を添付する必要があるため帯域幅は増加するものの、
  その代わりに検証ノードのストレージ要件を削減することを目的としています。
  各包含証明のサイズは関連するブロックと同程度であるため、合計のデータ要件は約1.3TBになります。
  最近使用されたUTXOを広範にキャッシュしても、明示的な削除のための証明データは約200GBに達します。
  この提案はIBD中に削除証明を必要としないようにすることで、証明のオーバーヘッドをほぼゼロにします。

  現在[BIPs #1923]で議論されているBIP181によると、Utreexoにはツリーへのアウトプットの追加と削除の両方を行う`modify`操作があります。
  前者は破棄と移動のサイクルを活用する複数ステップのプロセスに従い、後者はツリーのノードを削除し、
  その兄弟ノードを親があった位置に移動することで動作します。Souzaと他の開発者は、
  追加操作に暗黙的な削除を含めるように変更することを提案しました。あるUTXOが使用済みであることを事前に知っていれば、
  それをツリーに追加するのを避け、削除操作と同様にルートを直接ツリーの上方に押し上げるだけで済むからです。

  重要なポイントのひとつは、どのUTXOがすでに使用済みかをどのように知るかです。
  Souzaの提案は[SwiftSync][topic swiftsync]のhintsfileを活用します。
  これはまさに使用済みアウトプットを追跡することを目的としたファイルで、
  提供されたファイルが正しいかどうかを確認するためのハッシュの集約値も保持しています。つまり、
  この暗黙的な削除操作はIBD中にのみ利用可能で、それ以降はUtreexoクライアントは通常の追加および削除操作に戻ることになります。
  `assumevalid`版のSwiftSync実装は現在[Floresta #1115][flor PR115]で開発中で、非`assumevalid`版も活発に開発されています。

- **使用不可能な内部鍵のための新しいBIPドラフト**: NTLは、
  [Taproot][topic taproot]のキーパスを使用不可能にする方法を規定する新しいBIPドラフトの提案について
  Bitcoin-Devメーリングリストに[投稿しました][unspendable ml]。この新しい仕様は、Salvatore Ingala、Pieter Wuille、
  Josie Bakerおよび他の開発者の間でDelving Bitcoin上で行われた以前の議論（[ニュースレター #283][news283 unspendable]参照）と、
  Andrew Tothが[BIPs #1746][]で専用のBIPを定義しようとした以前の試み（[ニュースレター #338][news338 unspendable]参照）に基づいています。

  この提案はすでに[ドラフト][unspendable gh]として利用可能で、
  既知の署名鍵が存在しない内部鍵のプレースホルダーとして`_`を規定しています。また、
  内部鍵は[BIP341][]のNothing Up My Sleeve（NUMS）ポイント（離散対数が不明なポイント）と、
  正規化されたポリシーのタグ付きハッシュであるチェーンコードを用いて、
  合成的な[BIP32][]拡張公開鍵から導出されなければならないと規定しており、
  これにより異なる実装が独立して同じアドレスを再現できるようになります。

  著者によると、新しい提案は3つの指針に従っています。この特定の問題に直接影響する場合を除いて他のBIPへの準拠を強制しないこと、
  新しい暗号技術や構造を提案せず、すでに利用可能なもののみを使用すること、そしてスクリプトのセマンティックな正規化を主張しないことです。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **BitBoxAppがSparkベースのライトニング支払いを追加:**
  BitBoxは、Breez SDKとSparkの[ステートチェーン][topic statechains]上に構築された、
  モバイル版BitBoxApp [4.52.0][bitboxapp 4.52.0]のパブリックベータ版ホットウォレットを[発表しました][bitbox ln blog]。

- **Covenants.diyスクリプトエディタ:**
  [covenants.diy][covenants diy]は、[コベナンツ][topic covenants]スクリプトを構築し、
  その実行をブラウザ内でステップ実行するためのエディタです。[`OP_CTV`][topic op_checktemplateverify]、
  [`OP_CSFS`][topic op_checksigfromstack]、[`OP_CAT`][topic op_cat]、
  [ANYPREVOUT][topic sighash_anyprevout]、`OP_TEMPLATEHASH`、`OP_INTERNALKEY`、`OP_PAIRCOMMIT`、
  `OP_TXHASH`などの機能をサポートしており、テストネットワークでの使用を想定しています。

- **EntropyLabオフライン鍵計算ツール:**
  [EntropyLab][entropylab gh]は、エアギャップ環境での使用向けの自己完結型HTMLファイルで、
  ユーザーが提供したエントロピーや既存の鍵素材を、[BIP39][]シード、拡張鍵、
  [ディスクリプター][topic descriptors]、アドレス、[BIP85][]子エントロピー、
  [BIP352][]の[サイレントペイメント][topic silent payments]アドレスなどに変換します。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Eclair 0.14.3][]は、このLNノード実装のセキュリティリリースで、
  悪意のあるピアによって悪用可能な脆弱性を修正しており、アップグレードを強く推奨します。
  チャネルの閉鎖、[スプライシング][topic splicing]、[オンザフライファンディング][topic jit channels]に関する問題を修正しています。
  また、以下の注目すべき変更で説明されているとおり、ファンディング手数料率に設定可能な上限を追加し、
  [トランポリンノード][topic trampoline payments]が支払いの成功率を高めるためにより低い手数料を保持できるようにしています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35445][]は、`h`形式の強化導出マーカーを使用する[miniscript][topic miniscript]式を含む
  既存の[ディスクリプター][topic descriptors]ウォレットが、
  バージョン31.0へのアップグレード後に読み込めなくなる互換性バグを修正します。
  以前の変更である[#31734][bitcoin core #31734]は、
  内部ディスクリプター識別子を計算する際のBitcoin Coreによる強化導出パスの表現方法を変更しており、
  新しいソフトウェアが既存のウォレットを誤って破損していると報告する原因となっていました。保存された識別子は、
  再計算して検証する値としてではなく、関連するウォレットレコード間のリンクとして扱われるようになりました。
  `importdescriptors`および`createwalletdescriptor` RPCは、
  ディスクリプタがすでに存在するかどうかを確認する際に、正規化されたディスクリプター文字列を比較するようになりました。

- [Bitcoin Core #36076][]は、[PSBT][topic psbt]を結合する際に`combinepsbt`が
  インプットの要求された署名ハッシュ（sighash）タイプを破棄してしまう可能性があるバグを修正します。
  最初のPSBTに`PSBT_IN_SIGHASH_TYPE`が含まれていない場合、別のPSBTからの署名がそのフィールドなしでコピーされ、
  `ALL|ANYONECANPAY`のようなデフォルト以外のsighashタイプを使用する有効な署名がファイナライズ時に拒否される可能性がありました。
  最初のPSBTにこのフィールドがない場合はコピーされるようになり、引数の順序に関係なくファイナライズできるようになりました。

- [Bitcoin Core #36150][]は、プルーニングを新しい[コンパクトブロックフィルターインデックス][topic compact block filters]（`-blockfilterindex`）
  またはUTXOセット統計インデックス（`-coinstatsindex`）（[ニュースレター #198][news198 coinstats]参照）と一緒に有効にすると、
  インデックスが同期できなくなる可能性があるバグを修正します。
  プルーニングされていないノードが両方の設定を有効にして再起動された場合、
  新しいインデックスがどのブロックが必要かを判断する前にブロックファイルがプルーニングされる可能性がありました。
  現在は、インデックスは最初のブロックを処理する前であっても、高さ0にプルーニングロックを設定します。

- [Bitcoin Core #36174][]は、置き換え後のHTTPサーバー（[ニュースレター #411][news411 http]参照）に
  送信側のバックプレッシャーを追加し、[ニュースレター #422][news422 http]で説明された受信側の保護を補完します。
  これまでは、クライアントがレスポンスを読み取らずに多数のリクエストを送信でき、
  キューに入ったレスポンスデータが際限なく増大する可能性がありました。現在は、
  サーバーは接続の送信バッファが32 MiBを超えるとその接続のさらなるリクエストの処理を一時停止し、
  クライアントがレスポンスを消化すると再開します。以前の修正は、受信リクエストが処理できる速度よりも速く蓄積するのを防ぐものでした。

- [Bitcoin Core #34743][]は、IBD中にブロックダウンロードを停滞させた手動選択ピアの処理方法を変更します（[ニュースレター #237][news237 stall]参照）。
  これまでは、ピアがブロックの配信に失敗し、それなしではダウンロードが進行できない場合、
  ノードはそのピアを切断していました。現在は、`-addnode`、`-connect`、または`addnode`
  RPCを使用して選択されたピアについては、ノードはそれらの未処理のブロックを他のピアからリクエストできるようにし、
  停滞しているピアへの新しいブロックリクエストを2分間一時停止します。手動ピアは引き続き、
  個別のブロックダウンロードおよびヘッダー同期のタイムアウトの対象となります。

- [Bitcoin Core #36081][]は、`getmininginfo` RPCのレスポンスに`bestblockhash`フィールドを追加します。
  既存の`next`オブジェクト（[ニュースレター #339][news339 mininginfo]参照）と合わせて、
  マイニングソフトウェアは現在の先端のハッシュと次のブロックの難易度ターゲットを単一のRPC呼び出しで取得できるようになります。
  これまでは、別々のRPC呼び出しでハッシュとマイニング情報を取得すると、先端の変更と競合し、異なる先端を参照する値が生成される可能性がありました。

- [Bitcoin Core #35975][]は、同じトランザクションの2つの改変バージョンに対して`bumpfee`を呼び出した際に発生していた
  ウォレットのクラッシュを修正します。これまでは、一方のバージョンの手数料を引き上げても、
  もう一方が置き換え済みとして直ちにマークされませんでした。その後もう一方のバージョンの手数料を引き上げようとすると、
  アサーションエラーが発生してノードがクラッシュする可能性がありました。現在は、どちらのバージョンの手数料を引き上げても、
  そのすべての改変版が置き換え済みとしてマークされます。すでに置き換えられたバージョンをバンプしようとするとエラーになります。
  このPRはまた、コメントと[置換に関する][topic rbf]メタデータが、
  手数料引き上げの置き換えを含む改変されたトランザクションにコピーされ、
  ウォレットの再読み込み後も保持されることを保証します。

- [BIPs #2241][]は、[ニュースレター #417][news417 staletip]で以前議論された、
  最近のステイルチェーンチップのオプトインリレーを規定する[BIP332][]を追加します。`staletip`メッセージには、
  既知のフォークポイントのブロックハッシュ、ステイルブランチのヘッダーおよび
  送信者がステイルチップのブロックデータを提供する意思があるかどうかを示すフラグが含まれます。
  ピアは[BIP434][]を使用してサポートをネゴシエートします。
  これは[ニュースレター #410][news410 bip434]で説明されているとおり、Bitcoin Coreに実装されています。
  推奨されるリソース制限には、アナウンスあたり20ヘッダーと1,000ブロックの新しさのウィンドウが含まれます。

- [BIPs #2258][]は、[BIP93][] [codex32][topic codex32]を更新し、
  チェックサムの長さ制限をチェックする際にプレフィックスの寄与分を含めるようにします。これまでは、
  これらのチェックはデータ部分のみをカウントしていたため、
  一部の文字列がチェックサムの明示されたエラー検出保証でカバーされる長さを超えることが許容されていました。
  仕様とリファレンス実装は現在、完全な展開後の長さを使用してチェックサムを選択および検証します。さらに、
  このPRはマスターシードのエンコーディングを16、20、24、28、32、または64バイトのシードに制限し、
  誤って挿入または削除された文字を訂正する際の曖昧さを軽減します。
  これらのサイズの既存のエンコーディングは変更されませんが、
  以前は許可されていた他のサイズのエンコーディングはもはや仕様に適合しません。

- [Eclair #3380][]は、キャッシュされたHTTP Basic認証の資格情報を利用したクロスサイトリクエストフォージェリを防ぐため、
  WebSocket接続を含め、`Origin`ヘッダーを含むAPIリクエストを拒否します。
  ブラウザベースのフロントエンドは、Eclairを直接呼び出す代わりに、独自のバックエンドを使用する必要があります。
  `curl`や`eclair-cli`などのコマンドラインクライアントは、このヘッダーを設定しない限り影響を受けません。

- [Eclair #3376][]は、チャネルの閉鎖、[スプライシング][topic splicing]、
  [オンザフライファンディング][topic jit channels]に関するいくつかの問題を修正します。
  Eclairが手数料を支払う場合、閉鎖手数料のネゴシエーションは、設定された最大閉鎖手数料率を超え、
  かつローカルの手数料範囲外にあるピアの提案を拒否するようになりました。これまでは、
  ネゴシエーションのフォールバックがローカルのチャネル残高を枯渇させかねない過大な手数料を受け入れる可能性がありました。
  未完了のスプライシング中に強制閉鎖する場合、スプライシングの公開に必要なピアの署名が欠けているときは、
  Eclairはファンディングトランザクションが完全に署名されている最新のコミットメントを使用するようになりました。
  ピアがスプライシングをブロードキャストし、それが先に承認された場合、
  Eclairは代わりに新しいファンディングアウトプットを使用するコミットメントで閉鎖します。さらに、
  このPRは[ブラインドパス][topic rv routing]経由の支払いに対してオンザフライファンディングを実行する前に、
  リレー手数料と[CLTV expiry delta][topic cltv expiry delta]をチェックし、
  資金の損失につながる可能性のある安全でない転送を防ぎます。このPRは、
  新しい`on-chain-fees.max-funding-feerate`設定（デフォルトは50 sat/vB）を追加し、
  チャネル開設とスプライシングのための[自動推定される手数料率][topic fee estimation]に上限を設けます。

- [Eclair #3372][]は、[トランポリンノード][topic trampoline payments]として動作するEclairノードがより低い手数料を保持できるようにし、
  送信者の手数料予算のより多くを下流のルーティングに利用できるようにします。
  ルーティングヒントまたは[ブラインドパス][topic rv routing]を含む支払いについては、
  新しい`relay.fees.min-local-trampoline`設定でEclairが保持する最小手数料を定義します。
  運営者はこの最小値を標準的な送信チャネル手数料よりも低く設定することで、
  受信者のLSP（Lightning Service Provider）が課すものを含む下流の合計手数料が予算を超えてしまう場合でも、
  支払いが成功するのを助けることができます。これらのヒントがない支払いは、引き続き通常のローカルチャネルコストを含みます。
  さらに、このPRは`relay.fees.min-trampoline`で要求されるデフォルトの最小合計手数料予算を、
  1 satに転送額の0.01%を加えた値から、2 satsに0.04%を加えた値に引き上げます。

- [LND #11163][]は、外部ソフトウェアが転送を承認または拒否できる
  フォワードインターセプター（[ニュースレター #104][news104 intercept]参照）を使用している際の、
  再送された[HTLC][topic htlc]の処理を修正します。ピアの再接続やノードの再起動後、
  LNDはすでに転送済みの受信HTLCを再処理することがあります。これまでは、LNDはこれを新しいインターセプションとして扱い、
  送信HTLCがまだアクティブであるにもかかわらず、たとえば有効期限が近すぎるなどの理由で拒否する可能性がありました。
  現在は、LNDは既存の転送レコードをチェックし、再送されたHTLCが元の支払いの解決まで継続できるようにします。
  インターセプターの判断をまだ待っている支払いについては、
  LNDは代わりに元の自動失敗期限（[ニュースレター #224][news224 intercept]参照）のままHTLCを保留し、
  再送時の2回目の有効期限チェックを回避します。

- [BDK #2246][]および[#2263][bdk #2263]は、
  アウトプットの未確定なトランザクション祖先をチェックすることで、
  ウォレット残高の分類（[ニュースレター #213][news213 balance]参照）を改善します。これまでは、
  未承認の受信支払いを使用した際のお釣りは、承認待ちの受信トランザクションに依存しているにもかかわらず、
  信頼できるものと見なされる可能性がありました。BDKは現在、
  その信頼できないステータスを子孫トランザクションに引き継ぎます。新しい`classify_outpoints`
  APIはアウトプットごとの分類を公開し、更新された`balance` APIはアプリケーションがどのトランザクションを信頼できないとするか、
  いつトランザクションが確定したと見なすかを個別に定義できるようにします。2つめのPRは、
  6承認を要求するなどの確定ルールをアプリケーションが定義するのを助けるために、
  `ChainPosition::confirmations_lower_bound`を追加します。これは承認したブロックを含む保守的な承認数を返し、
  未承認のトランザクションや提供された先端より上の承認高さについてはゼロを返します。

{% include snippets/recap-ad.md when="2026-09-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1923,1746,35445,31734,36076,36150,36174,34743,36081,2241,3380,2258,3376,3372,11163,2246,2263,35975" %}

[price vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718
[shape proxy]: https://github.com/marafoundation/sv2-apps/tree/shape-proxy-v0.1.0/test-tools/shape-proxy
[towns vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718/4
[news325 datum]: /ja/newsletters/2024/10/18/#datum
[price frontier]: https://delvingbitcoin.org/t/vardiff-belongs-at-the-frontier/2734
[utreexo ibd del]: https://delvingbitcoin.org/t/implicit-deletions-and-improvements-in-utreexo-ibd/2881
[flor PR115]: https://github.com/getfloresta/Floresta/pull/1115
[bitbox ln blog]: https://blog.bitbox.swiss/en/introducing-lightning-in-the-bitboxapp/
[bitboxapp 4.52.0]: https://github.com/BitBoxSwiss/bitbox-wallet-app/releases/tag/v4.52.0
[covenants diy]: https://covenants.diy/
[entropylab gh]: https://github.com/OogaBoogaX/entropylab
[unspendable ml]: https://groups.google.com/g/bitcoindev/c/se3TkNnbno4
[news283 unspendable]: /ja/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors
[news338 unspendable]: /ja/newsletters/2025/01/24/#bip
[unspendable gh]: https://github.com/bitryonix/bips/blob/bip-xxxx-unspendable-internal-keys/bip-xxxx-unspendable-internal-keys.mediawiki
[news198 coinstats]: /ja/newsletters/2022/05/04/#bitcoin-core-21726
[news237 stall]: /ja/newsletters/2023/02/08/#bitcoin-core-25880
[news339 mininginfo]: /ja/newsletters/2025/01/31/#bitcoin-core-31583
[news417 staletip]: /ja/newsletters/2026/08/07/#stale-tip-bip
[news410 bip434]: /ja/newsletters/2026/06/19/#bitcoin-core-35221
[news411 http]: /ja/newsletters/2026/06/26/#bitcoin-core-35182
[news422 http]: /ja/newsletters/2026/09/11/#bitcoin-core-36123
[Eclair 0.14.3]: https://github.com/ACINQ/eclair/releases/tag/v0.14.3
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news224 intercept]: /ja/newsletters/2022/11/02/#lnd-6831
[news213 balance]: /ja/newsletters/2022/08/17/#bdk-640
