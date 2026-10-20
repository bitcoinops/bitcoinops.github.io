---
title: 'Bitcoin Optech Newsletter #417'
permalink: /ja/newsletters/2026/08/07/
name: 2026-08-07-newsletter-ja
slug: 2026-08-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、ピア間でステイルブロックの先端をリレーするためのBIPドラフトについて掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめたセクションや、
新しいリリースおよびリリース候補の発表、人気のBitcoin基盤ソフトウェアの注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **Stale TipリレーのBIPドラフト**: Ramとw0xltは、ピア間でStale Tip（勝者チェーンに敗れた古いチェーン先端）を
  リレーするためのオプトイン方式のP2Pメッセージの提案について、Bitcoin-Devメーリングリストに[投稿しました][stale tip ml]。
  現在、ステイルブロック率は監視が難しい指標です。ステイルブロックは、勝利したチェーンがリレーされるとすぐに伝播が止まってしまうためです。
  しかし、これはネットワークの健全性を確認するための有用なシグナルです。ステイルブロック率の変化は、
  検証やリレーのボトルネック、ネットワークの分断、あるいは[セルフィッシュマイニング][topic selfish mining]の挙動を明らかにする可能性があります。

  提案された[BIP][stale tip bip]は、直近のステイルチェーンの先端をピアに通知するための
  `staletip`という新しいメッセージを定義しています。このメッセージ自体には、
  ステイルブランチが分岐したブロック高（フォークポイント）、そのステイルブランチに属するブロックヘッダーのリスト、
  そしてそのブロックデータを提供する意思を示すフラグが含まれます。ノードは、
  ピアとの[BIP434][]ネゴシエーションの後にのみこのメッセージを送信すべきとされています（[ニュースレター #386][news386 bip434]参照）。

  現在、提案者らは他の開発者からのフィードバックを待っているところです。その間、
  この提案の[概念実証][stale tip poc]はすでに公開されています。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **Taprootのキーパス支払いに対するCISA（BIP460）**: Fabian Jahrは、
  [Taproot][topic taproot]形式のキーパス支払いを対象としたトランザクション全体での
  [クロスインプット署名集約（CISA）][topic cisa]に関するBIP460のドラフト（[BIPs #2212][]）を
  Bitcoin-Devメーリングリストに[投稿しました][fj ml cisa]。この提案は
  新しいウィットネスバージョン（v2）を導入するもので、そのキーパス支払いは[BIP341][]を踏襲しますが、
  各インプットのウィットネスの先頭に、半集約（ハーフアグリゲーション、BIP458/[BIPs #2205][]）、
  完全集約（フルアグリゲーション、BIP459/[BIPs #2210][]）、
  または標準的な[BIP340][] [Schnorr][topic schnorr signatures]署名を伴う
  明示的なオプトアウトのいずれかを選択するマーカーバイトが置かれる点が異なります。
  半集約は、多数の64 byteの署名を非対話的に各32 byteと単一の32 byteの集約パートに圧縮します（[ニュースレター #208][news208 halfagg]参照）。
  完全集約は、対話的な署名により、それらを単一の64 byteの集約署名にまで削減します（[ニュースレター #415][news415 dahlias]参照）。
  スクリプトパスの支払いは BIP341/BIP342のまま変更されず集約もされないため、
  `OP_SUCCESS`によるアップグレードパスが維持されます。提案されたスキームでは、
  署名は集約モードにコミットするため、集約はオプトインとなります。つまり、
  第三者がオプトアウトされた署名を半集約グループに組み込むことはできません。Jahrは、
  このウィットネスバージョンが[BIP360][]（P2MR）と衝突することを指摘しており、
  レビュアー（Mark Erhardtを含む）は、先にアクティベートされた提案が次の空きバージョンを取得することになると見込んでいます。

  Conduitionは、CISAが[ポスト量子][topic quantum resistance]移行とどのように整合するのかを[質問しました][c ml cisa]。
  集約には検証のために生のEC公開鍵が必要になるため、CISAを[P2TRv2][news403 pqout]と組み合わせれば手数料の節約が最大化されます（
  完全集約されたインプットあたり最小で1ウィットネスバイトになります）。しかし、これにはP2TRv2が抱える「ECの無効化タイミング」の問題が引き継がれます。
  一方、鍵をハッシュする方式（P2MRやP2TRH）はインプットあたりおよそ32〜65ウェイトユニットのコストがかかり、
  節約効果が低下します。Jahrは、トランザクションレベルのマーカー/グループの枠組みは将来の集約可能なスキームにも一般化できるはずであり、
  ハッシュで隠蔽するタイプのCISAバリエーションはロジックの大部分を共有する別のアウトプットタイプとして定義することもできるだろうと[返信しました][fj ml cisa conduition]。
  Adam Gibson（waxwing）は、共有トランザクション内で複数のユーザーがそれぞれ自分のインプットだけを完全集約したい場合に、
  スキームごとに単一グループという制限が妥当なのかを[疑問視しました][ag ml cisa]。これに対しJahrは、
  具体的なユースケースを示せば複数グループの可能性は残されていると[返信しました][fj ml cisa waxwing]。

- **ポスト量子ウィットネスデータへのSegwitコミットメント**: Pieter Wuilleは、
  [Segwit][topic segwit]の導入に伴うコストを繰り返すことなく[ポスト量子][topic quantum resistance]ウィットネスデータを付加するための設計案を
  Delving Bitcoinに[投稿しました][pw delving pqwit]。単純に2つめのウィットネス領域を設けると、
  新しいトランザクション識別子（pqwtxid）、それらのIDへのコインベースのコミットメント、マイニングスタックの変更、
  そして3つの識別子を追跡するP2Pロジックが必要になります。Wuilleの代替案では、
  各インプットの拡張ウィットネスデータをそのインプットの既存のウィットネスにコミットさせることで、
  既存のwtxidが追加データもカバーするようにしています。具体化された案では、インプットごとのウィットネス「スタイル」（
  0 = segwit、1 = pqdata、2以降は将来の拡張用）が導入され、各スタイルはそれぞれが独自のP2P拡張とウェイト関数を持ちます。
  未対応のスタイルは、アップグレードしていないノードとの互換性のために、有効なスタイル0のコミットメントとして表現できます。
  Anthony Townsは、スタイルを個別の認可ウェイト計算式になぞらえ、追加データなしでもロックタイムのような条件指定が機能するよう
  annexベースのコミットメントを提案しました。またポスト量子署名用に確保された容量は通常のデータには使用できないようにすべきだと主張し、
  そうすることでQ-day（耐量子暗号が必要となる日）以前のブロックが肥大化するのを防ぐべきだと論じました。
  Wuilleは、スタイルの導入は依然としてソフトフォーク、ストレージ、P2Pアップグレードを組み合わせたものではあるが、
  新しいトランザクションIDを必要としない点では異なることを確認しました。

- **PQCアウトプットタイプの議論**: Pieter Wuilleは、[ポスト量子][topic quantum resistance]アウトプットタイプの議論を一元化するために
  Delving Bitcoinのスレッドを[開始しました][pw delving pqout]。彼は、[BIP360][]（P2MR）、
  [P2TRv2][news403 pqout]、P2TRH（ハッシュされたアウトプットキーと公開鍵復元を持つTaproot風の方式、[ニュースレター #412][news412 pkr] 参照）、
  P2QR（最初からEC opcodeが無効化されたP2MR）、およびそれらのバリエーションを含む候補を表にまとめました。
  彼の現時点での推奨は、Q-day前の容易な移行を可能にし現在の手数料プロファイルを維持するP2TRv2（[トリップワイヤ/マイナーによるロックダウン機能][news412 p2xx]と
  [ハッシュベースのPQC opcode][news386 jn hash]を伴う）と、移行後にECとPQCのコストを個別に設定できるよう新しいウィットネススタイルを持つ長期的な
  P2MRベースのタイプの両方を展開することです。jeanpablojpによるregtestでの[測定結果][jp delving pqout]は、
  BIP360支払いには既存のTaprootの仕組みに対しておよそ96行のコンセンサス変更の差分が必要であり、
  深さ1のSchnorrリーフは同等のP2TRスクリプトパスより約32 byte軽量であることを示しました。
  Conduitionは、JahrのCISA提案（上記）により「P2TRv2+CISA」の組み合わせが自発的な移行にとって非常に魅力的になる一方で、
  将来的にECを無効化するソフトフォークのハードル（リスクや影響）が高まると指摘しました。また、
  ポスト量子送金の手数料の競争力を高めるための研究の方向性として、ブロック全体でのハッシュベース署名のPQ-SNARK集約を挙げました。

- **<!--input-triggered-transaction-expiry-->インプットをトリガーとするトランザクションの失効**:
  Josh Domanは、[フリーリレー][topic free relay]（手数料なしでのリレー）を伴わずに[HTLC][topic htlc]を失効させる仕組みを
  Delving Bitcoinに[投稿し][jd delving expire htlc]、続く投稿でそれを[インプットをトリガーとするトランザクションの失効][jd delving input expiry]として一般化しました。
  Peter Toddの[`OP_EXPIRE`][news274 expire]のような絶対時間による失効提案は、
  有効なトランザクションを後から無効にするため、ポリシーで次ブロックに取り込まれるレベルの手数料を強制しない限り、
  安価なリレースパムを可能にしてしまいます。Domanのアプローチは代わりに、対象となるUTXOを作成したトランザクションの承認が遅すぎた場合に、
  そのUTXOの使用を失効させます。具体的には、[BIP68][]の`nSequence`が高さベースの相対ロックタイムRを強制し、
  かつビット21がセットされている場合、`nLockTime`が高さベースであり、かつBIP68の最小組み入れ高さ以上でない限り、
  そのインプットは検証に失敗します。マイニングされた親トランザクションは深い再編成なしには無効になり得ないため、
  通常のブロック生成プロセスにおいて、一度有効になった子トランザクションが失効することはありません。
  これによりフリーリレーの問題が解消されます。ユースケースには、mempoolに依存しないHTLC転送（ローカルmempoolではなく
  chainstateを介したプリイメージ監視。低帯域幅ノードや[Utreexo型][topic utreexo]ノードに有用）や、
  [LN-Symmetry][topic eltoo]向けの疑似的なコントラクトレベル相対[タイムロック][topic timelocks]などが挙げられます。
  付随的な変更案として、`OP_CSV`でビット21の強制や、スクリプトで最大ロックタイムを規定できるようにするためのTapscript用の
  `OP_LOCKTIME`イントロスペクションopcodeの追加も検討されています。Anthony Townsはこのアイデアを`OP_TX`によるコインの生成ブロック高の参照と比較し、
  最小遅延を100ブロックにするという必要性（コインベースの成熟期間やToddの提案に合わせて選ばれた値）に疑問を呈しました。
  Domanはその後、より短い遅延で十分かもしれないと同意し、このプリミティブを、
  ユーザーが「現在」（`nLockTime`によるインプットの承認）を主張する仕組みとして再定義しました。
  これは同時に、ブロック報酬がなくなった後の大規模な再編成のコストを引き上げることにもなり得ます。

- **<!--layered-quantum-recovery-of-hashed-addresses-->ハッシュアドレスの多層的な量子リカバリー**:
  Shinobiは、[暗号学的に意味のある量子コンピュータ][topic quantum resistance]の存在により
  secp256k1による支払いが将来制限された場合に備えて、ハッシュされたアドレスタイプ（P2PKH、P2SH、P2WPKH、P2WSH、および類似の構成）で保護されたコインの
  多層的なリカバリープランをBitcoin-Devメーリングリストに[投稿し][shinobi ml qr]、
  Delving Bitcoinにも[クロスポストしました][shinobi delving qr]。単一のリカバリーメカニズムですべての鍵生成方法をカバーすることはできません。
  たとえば、[BIP32][]の階層的証明（最近Osuntokunによって[実証されました][news403 pqrecovery]）は非階層的な鍵には対応できず、
  ステートフルな期限前のタイムスタンプ付き証明は非アクティブなユーザーを対象外とし、
  commit-reveal方式の移行は公開鍵がすでに露出している場合に機能しません。
  secp256k1が無効化された後に任意のリカバリー方法で支払いを認可できるようにすれば、
  公開鍵と内部スクリプトパスが秘密のままであるという前提のもと、依然として鍵を管理しているハッシュアドレスの保有者を実質的にすべてカバーできます。
  将来これを実現しやすくするために、Shinobiは、ウォレットが新しい導出パスを使用し、
  xpubをサービスプロバイダーに漏らさないようElectrumスタイルのアドレス単位の残高クエリを使用することを提案しています。
  Conduitionは、リカバリーを、量子攻撃者が持たない既存の知識の非対称性を認証するものとして再定義しました。
  ハッシュされたスクリプトやBIP32シードはそうした非対称性です。彼は、一部のUTXO（特に初期のP2PKコインの多く）にはそうした非対称性が存在しないため、
  期限前にそれを作成する行動によってのみ、その所有者を攻撃者と区別できると強調しました。また、Taprootの内部鍵は、
  ハッシュアドレスの多層化とは別に、P2TRキーパスのリカバリーのための知識の非対称性として機能し得ると指摘しました。

- **Segregated Data（SegData）BIPドラフト**: MrHashは、
  任意のデータ格納のためのプルーニング可能でスクリプトから分離されたブロック領域を追加するソフトフォークである
  Segregated Dataについて、関連するBIPドラフト群をDelving Bitcoinに[投稿しました][mh delving segdata]。
  エントリはコインベースのマークルルートを介して（[BIP141][]スタイルで）コミットされ、ウィットネスディスカウントでカウントされ、
  UTXOセットから除外される使用不可能なvalueゼロのウィットネスv2参照アウトプットによってトランザクションに紐付けられます。
  どのopcodeもエントリの内容を読み取ることはできないため、エントリはプルーニング可能なままであり、
  支払いの条件として利用することもできません。また、保持期間を超えた後は、
  ノードはベースのシリアライゼーションだけで検証できます。目的は、
  スクリプトが評価する必要のないデータ（アプリケーションのBlob、アテステーション）に構造的な置き場所を与え、
  `OP_RETURN`やウィットネスへの詰め込みから移行できるようにすることであり、既存のそれらの手段自体は変更しません。
  Antoine PoinsotとPieter Wuilleは、ブロックを受け入れるためにフルノードがペイロードを保持する必要がないのであれば、
  そのデータは意味のある形でBitcoinのコンセンサスの一部とは言えず、ウェイトを膨らませるために手数料を払うことと等価であると主張しました。
  Mark Erhardtは、ウィットネスデータと同じコストで可用性が低下する方式を、
  データ埋め込みを行う者がなぜ好むのかを疑問視しました。Anthony Townsが深さに依存する存在ルールによる再編成リスクを説明した後、
  MrHashは、コンセンサスではコミットされたウェイト/長さのみを検証し、ペイロードの検証はポリシーとする方向に方針を転換しました。
  ドラフトはまだオープンで、ウィットネスバージョンの割り当ては、上記のBIP360およびBIP460の議論とも衝突しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Libsecp256k1 0.8.0][]は、Bitcoin関連の暗号処理のためのこのライブラリのリリースです。
  [ニュースレター #415][news415 silent]で説明された[BIP352][]の[サイレントペイメント][topic silent payments]モジュールを追加し、
  [ニュースレター #396][news396 sha256]で説明されたようにアプリケーションがハードウェア最適化されたSHA256圧縮実装を提供できるようにし、
  64 bitのフィールド演算を改善して、一部のGCCおよびMSVCビルドで最大約11%の署名検証の高速化を実現しています。
  また、非推奨となっていた`secp256k1_schnorrsig_sign`および`secp256k1_context_no_precomp`シンボルを削除しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35501][]は、同一トランザクションの複数のウィットネスバリエーションを保存できるようウォレットを更新します。
  これまでは、ウォレットがあるtxidのトランザクションを認識すると、同じtxidで異なるwtxidを持つ別のトランザクションは通常無視されていました。
  今回の変更により、ウォレットは各バリエーションを個別の`wtxvariant`データベースレコードに保存し、
  そのうちの1つを正規として選択します。優先順位は、承認済みのバリエーション、次にウィットネスデータを含むバリエーション、
  そして最もウェイトの小さいバリエーションの順です。正規のバリエーションは既存の`tx`レコードに残ります。
  `gettransaction`、`listtransactions`、`listsinceblock`の各RPCは、新しい`alternate_wtxids`
  フィールドで非正規のバリエーションを報告するようになりました。同じtxidで異なるwtxidを持つトランザクションに関する過去の言及については、
  ニュースレター[#193][news193 wtxid]および[#304][news304 wtxid]を参照してください。

- [Core Lightning #9298][]は、ブロックのポーリングとトランザクションのフィルタリングを
  `lightningd`の外に移すことを意図した実験的なブロックチェーン監視プラグイン`bwatch`への移行を前進させます。
  このPRは、`our_outputs`テーブルと`our_txs`テーブルを追加し、既存のウォレットテーブルからそれらへデータを埋め戻し、
  ウォレットの読み取りを新しいテーブルに切り替えることで、ウォレットのトランザクションおよびUTXOの追跡をこのシステムに移します。
  `--experimental-bwatch`を有効にすると、scriptPubKeyの監視によって資金の受け取りが検出され、
  アウトポイントの監視によってウォレットのアウトプットが使用されたことが検出されます。
  再編成の処理も含まれます。書き込みは一時的にレガシーの`outputs`および`transactions`テーブルにもミラーリングされるため、
  ユーザーは再スキャンなしでダウングレードできます。

- [Core Lightning #9353][]は、指定されたルートに対するホップごとのペイロードの合計が、[BOLT4][]で定義された
  オニオンパケットの1,300 byteの`hop_payloads`フィールドに収まらない場合に、
  `sendpay`がRPCエラーを返すようにします。これまでは、オニオンの構築処理がnullの結果を返し、
  `sendpay`がそれをチェックせずに送信コードに渡していたため`lightningd`がクラッシュしていました。この問題は、
  リバランシングプラグインが生成した25ホップのルートで観測されました。ただし、実際のルート制限は、
  ホップ数そのものではなく、各ホップのエンコードされたペイロードのサイズに依存します。

- [Eclair #3336][]は、ピアから受信した重複する[HTLC][topic htlc]決済メッセージが、
  提案中のリモートコミットメントの変更に複数回追加されるのを防ぎます。これまでは、
  ピアまたはローカルのメッセージキューが同じ`update_fulfill_htlc`、`update_fail_htlc`、
  `update_fail_malformed_htlc`メッセージを複数回配信する可能性があり、
  Eclairが重複するコミットメント変更を保存してしまい、
  その後ピア同士が`commit_sig`メッセージを交換した際にチャネルが強制閉鎖される可能性がありました。

- [LND #10942][]は、暗号化された受信者データが次のホップを`short_channel_id`（SCID）ではなく
  `next_node_id`で識別している場合の、[ブラインドペイメントパス][topic rv routing]上での
  [HTLC][topic htlc]転送のサポートを追加します。この問題は、LNDが受信者のブラインドパスにおける
  導入ノードであったCore Lightningの[BOLT12][topic offers]支払いで観測されました。
  CLNは[BOLT4][]で許可されている`next_node_id`形式を使用しましたが、
  LNDのHTLC転送コードはSCIDを必須としていたため、支払いが失敗していました。LNDは現在、
  既存の非厳密な転送ロジック（プライベートチャネルやエイリアスチャネルもサポートするもの）を使用して、
  ノードIDをそのピアとの利用可能なチャネルの1つに解決するようになりました。

- [LND #10992][]は、`query_channel_range`リクエストに対する[BOLT7][]の
  `reply_channel_range`レスポンスで受け入れるショートチャネルID（SCID）の数を制限することで、
  [チャネルアナウンスメント][topic channel announcements]の同期時に使用されるメモリを抑制します。
  これまでは、圧縮されたレスポンスにより、LNDが1つ以上の`reply_channel_range`メッセージにわたって予測不能な数の
  SCIDをデコードしバッファリングする可能性がありました。現在、LNDはメッセージあたり最大100,000 SCID、
  単一クエリあたり合計で最大100,000 SCIDを受け入れます。

- [Rust Bitcoin #6364][]は、[BIP434][]の`feature`
  メッセージ（ニュースレター[#386][news386 bip434]および[#390][news390 bip434]参照）のP2Pエンコードおよびデコードのサポートを、
  Bitcoin Coreの先行実装（[ニュースレター #410][news410 bip434]参照）に倣って追加します。
  プロトコルバージョン`70017`と`feature`の`NetworkMessage`バリアントを追加し、
  BIP434の機能識別子とデータのサイズ制限を強制します。この更新はメッセージの基盤を提供するものであり、
  ピアのフィーチャーネゴシエーションロジックは実装していません。

- [Rust Bitcoin #6642][]は、各トランザクションウィットネス要素に4MBのサイズ制限を適用します。
  この制限は[BIP141][]の400万ウェイトユニットのブロック制限に由来するもので、
  このサイズを超えるウィットネス要素は有効なブロックに収まりません。これまでは、
  トランザクションのデコード時に、Rust Bitcoinは最初のウィットネス要素にのみこの制限を適用し、
  後続の要素に対してはより大きなデフォルト制限である32MiBにリセットしていました。これにより、
  デコード中に過大な要素が受け入れられ、ウィットネスが不整合な状態のまま残り、
  後に[Taproot][topic taproot]の支払いとして解釈された際にパニックを引き起こす可能性がありました。
  これは、[ニュースレター #410][news410 witness]で説明されたウィットネスデコード時のメモリ割り当ての堅牢化に続くものです。

- [BTCPay Server #7491][]は、Greenfield APIの認証ハンドラーにおける二要素認証（2FA）バイパスを修正します。
  認証ハンドラーは FIDO2 2FA（[ニュースレター #146][news146 btcpay mfa]参照）のチェックは行っていましたが、
  時間ベースのワンタイムパスワード（TOTP）2FAのチェックを行っていませんでした。このため、
  TOTPで保護されたアカウントが2FAを提供することなくAPIにアクセスできてしまっていました。ハンドラーは、
  何らかの第二要素が有効になっている場合、この形式の認証を拒否するようになりました。

- [BTCPay Server #7488][]は、PSBTがすでに対応する前トランザクションを
  `non_witness_utxo`に含んでいる場合に、[Segwit][topic segwit]インプットへ`witness_utxo`を追加することで、
  [PSBT][topic psbt]署名の互換性を改善します。これにより、新しい[HWI][topic hwi]バージョンと併用した場合の
  Blockstream Jadeなどの署名デバイスに関する問題が、既存の`non_witness_utxo`を保持したまま解決されます。
  このPRは、保存された署名ステータスが古くなってしまう保留中のマルチシグトランザクションの問題も修正しています。
  BTCPay Serverは、それらの読み込み時に署名の進捗を再計算し、十分な署名が揃っていてPSBTが正常にファイナライズできる場合には
  `Signed`としてマークするようになりました。

{% include snippets/recap-ad.md when="2026-08-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2212,2205,2210,35501,9298,9353,3336,10942,10992,6364,6642,7491,7488" %}

[stale tip ml]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU
[stale tip bip]: https://github.com/pseudoramdom/bips/blob/staletip-bip-draft/bip-staletip.md
[stale tip poc]: https://github.com/w0xlt/bitcoin/tree/staletip-v4

[fj ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA
[c ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/V6PZL7bGAwAJ
[fj ml cisa conduition]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/kF-RpqEgBAAJ
[ag ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/-zRSmrFZGQAJ
[fj ml cisa waxwing]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/oOQ7TIEVAgAJ
[news208 halfagg]: /ja/newsletters/2022/07/13/#bip340
[news415 dahlias]: /ja/newsletters/2026/07/24/#bip340-bip
[news403 pqout]: /ja/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[pw delving pqwit]: https://delvingbitcoin.org/t/segwit-commitment-to-post-quantum-witness-data/2702
[pw delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749
[jp delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/3
[news412 pkr]: /ja/newsletters/2026/07/03/#p2mr-ec
[news412 p2xx]: /ja/newsletters/2026/07/03/#nums-ec
[news386 jn hash]: /ja/newsletters/2026/01/02/#bitcoin
[jd delving expire htlc]: https://delvingbitcoin.org/t/expiring-htlcs-without-free-relay/2663
[jd delving input expiry]: https://delvingbitcoin.org/t/input-triggered-transaction-expiry/2667
[news274 expire]: /ja/newsletters/2023/10/25/#op-expire
[shinobi ml qr]: https://groups.google.com/g/bitcoindev/c/gtxpSxgG7E4
[shinobi delving qr]: https://delvingbitcoin.org/t/post-quantum-recovery-of-hashed-addresses-with-no-confiscatory-risk/2714
[news403 pqrecovery]: /ja/newsletters/2026/05/01/#bip32-zk-stark-bip86
[mh delving segdata]: https://delvingbitcoin.org/t/bip-draft-segregated-data-a-prunable-script-isolated-block-region-for-data-carriage/2641
[news193 wtxid]: /ja/newsletters/2022/03/30/#witness
[news304 wtxid]: /ja/newsletters/2024/05/24/#bitcoin-core-30000
[news386 bip434]: /ja/newsletters/2026/01/02/#peer-feature-negotiation
[news390 bip434]: /ja/newsletters/2026/01/30/#bips-2076
[news410 bip434]: /ja/newsletters/2026/06/19/#bitcoin-core-35221
[news410 witness]: /ja/newsletters/2026/06/19/#rust-bitcoin-6321
[news146 btcpay mfa]: /ja/newsletters/2021/04/28/#btcpay-server-2356
[Libsecp256k1 0.8.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.8.0
[news415 silent]: /ja/newsletters/2026/07/24/#libsecp256k1-1765
[news396 sha256]: /ja/newsletters/2026/03/13/#libsecp256k1-1777
