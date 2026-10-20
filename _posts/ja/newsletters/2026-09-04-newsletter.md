---
title: 'Bitcoin Optech Newsletter #421'
permalink: /ja/newsletters/2026/09/04/
name: 2026-09-04-newsletter-ja
slug: 2026-09-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、マイニングプールがコインベーストランザクションでサイレントペイメントを使ってマイナーに支払いをするアイデアと、
古いバージョンのCore Lightningに影響するDoS（サービス拒否）脆弱性の責任ある開示を掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する提案や議論のまとめや、新しいリリースとリリース候補の発表、
人気のあるBitcoin基盤ソフトウェアへの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **<!--using-silent-payments-for-miner-payouts-in-coinbase-transaction-->コインベーストランザクションでのマイナーへの支払いにサイレントペイメントを利用する**:
  average_garyは、[マイニングプール][topic pooled mining]がコインベーストランザクション内で
  直接マイナーごとに異なるアドレスへ支払う方法についてのアイデアをDelving Bitcoinに[投稿しました][spc del]。
  プールに`xpub`を渡して支払いごとに新しいアドレスを導出させる方式では、
  プールのデータベースが侵害された場合にプライバシー上の問題が生じる可能性があります。その代わりに、
  マイナーはStratum v2が提供する暗号化された通信チャネルを通じて、
  静的で何度使ってもプライバシーが漏洩しない[サイレントペイメント][topic silent payments]アドレスを共有できます。

  [BIP352][]のサイレントペイメントでは、受信者がトランザクションのインプットに含まれる公開鍵から共有シークレットを導出しますが、
  コインベーストランザクションにはそれがありません。そこでプールは、送信側の公開鍵`A_send`を導出するために使う一時的な秘密鍵を作成します。
  プールが悪意ある秘密鍵`a_send`を探索（グラインド）するのを防ぐため、
  `A_send`を現在マイニング中のブロックの高さとともにハッシュします。
  これが通常のトランザクションにおけるOutPoint由来の一意性の代わりとなります。
  最終的に34 byteの`A_send`は、いわゆるプールタグの代わりにコインベースのscriptSigに格納され、
  マイナーはブロックチェーンをスキャンして資金を見つけられるようになります。

  著者は、このアイデアを正式な仕様へと発展させるため、フィードバックや批評を求めています。

- **CLNにおけるDoS脆弱性の責任ある開示**:
  Erick Cestariは、[25.09][cln v25.09]より前のバージョンのCLNノードに影響を及ぼす重大なサービス拒否（DoS）脆弱性に関する情報を、
  責任ある開示の手順に従ってDelving Bitcoinに[投稿しました][cln dos del]。攻撃者は、
  チャネルを開設することなく[BOLT8][]のハンドシェイクを完了させるだけで、
  ノードに対して可能な限り大きい`pong`応答を要求する`ping`メッセージを大量に送りつけ、
  TCPソケットを一切読み取らないことで、ノードをメモリ不足（OOM）によるクラッシュに追い込むことが可能でした。

  この問題はCLNの接続管理方法に関係していました。各ピアはノードとBOLT8の暗号化されたNoiseチャネルを開き、
  その接続は`connectd`という専用のデーモンによって管理されます。このデーモンはTCP接続を処理し、
  受信メッセージを復号し、送信元ピアとのペイメントチャネルを管理する特定のサブデーモンへルーティングします。
  しかし、一部のメッセージはデーモン自身がローカルで処理します。その1つが`ping`メッセージであり、
  送信者は`pong`応答のサイズを指定できます。

  CLNはサブデーモンへルーティングされるメッセージにはバックプレッシャー（負荷制御）の仕組みを適用しており、
  `connectd`はサブデーモンの準備が整うまで待ってから新しいメッセージを読みます。しかし、
  デーモン自身が処理するメッセージにはこれが適用されず、ローカル処理されるメッセージは読み続けていました。
  攻撃者は、許容される最大サイズである65,531 byteの応答を要求する`ping`メッセージを繰り返し送信し、
  応答を一切読まないことで、まず自分のTCPソケットバッファを、次にピア側のバッファを埋め尽くせました。
  これにより`peer_outq`キューが排出されなくなり、OOMクラッシュが発生する事態となっていました。

  この問題は、`connectd`デーモンに独自のバックプレッシャーの仕組みを設け、
  次の受信メッセージを読む前に実際に`peer_outq`キューが排出されることを条件とすることで修正されました。
  修正は[Core Lightning #8525][]で導入され、リリース25.09で公開されました。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **PQCアウトプットタイプに関する議論の続き**: 先月取り上げた[ポスト量子][topic quantum resistance]アウトプットタイプに関する
  Pieter WuilleのDelving Bitcoinスレッドの[まとめ][news417 pqout]に続き、
  Wuilleは、[CISA][topic cisa]と[P2TRv2][news403 pqout]を組み合わせれば移行への強いインセンティブになるという
  Conduitionの主張に[返信しました][pw delving pqout cisa]。Wuilleは、
  手数料率の節約（多くのインプットを持つトランザクションにおいて最大約28%のウェイト削減と試算）だけでは、
  いわゆるロングテール層（多数の小規模なウォレットやカストディアンなど）を動かすには不十分だと考えています。その理由として、
  ウォレットやカストディアンのサポートがボトルネックであること、CISAは仕様と実装の複雑さを増してP2TRv2ソフトフォークを遅らせる可能性があること、
  事業者がP2TRv2とCISAを同時にリリースできるようになるまでPQC関連の作業を先延ばしにする可能性があることを挙げています。
  彼は依然として、一般的なユーザー向けのデフォルトとしてP2TRv2を、
  EC上の点（公開鍵）を隠したい高度なユーザー向けには[P2MR][news393 p2mr]をデフォルトとすることを好ましいと考えています。
  耐量子時代においては、ハッシュベース署名に対して、シリアライズ後のサイズよりも
  CPU負荷を重視する新たなウィットネスのコスト計算ルールが必要になるだろうと指摘しました（[ニュースレター #417][news417 pqwit]参照）。
  また、第三者のリレーノードが署名を逐次的に集約する方式は、実際の帯域幅コストをコンセンサス層の内側に隠してしまい、
  マイナーへの直接送信を促すことで既存のマイニングプールを既得権益化しかねないと警告しました。Conduitionは、
  CISAをサポートするアウトプットタイプをまず通常のBIP340署名で採用し、
  署名の集約機能は後から追加することも可能だと[反論しました][c delving pqout cisa]。また、
  ハッシュベース署名の手数料をEC署名と競合できるレベルにするために（シリアライズ後の）ブロックサイズを8倍（あるいはそれ以上）に拡大する場合、
  ブロック全体のSNARK集約でウィットネスを削減（プルーニング）できなければ、アーカイブストレージは年間テラバイト規模になると述べました。
  Adam Gibsonは、CISAをP2TRv2に束ねることはP2TRv2の「まず普及を」という目標に適さないというWuilleの見解に[同意しました][ag delving pqout]。

- **DropKick: commit/reveal方式のPQC救済策**: Conduitionは、
  Bitcoin-DevメーリングリストにDropKickの概要を[投稿しました][c ml dropkick]。これは、
  Q-day（耐量子計算機耐性が必要になる日）までにコインをPQC対応のアウトプットに移動させていないユーザー向けの、
  commit/reveal方式の[ポスト量子][topic quantum resistance]救済プロトコルです（ニュースレター [#361][news361 pqcr]および
  [#348][news348 utxo proving]参照）。ユーザーは、自身のポスト量子公開鍵と所有権の証明（知識の非対称性を示す証拠）へのコミットメントを、
  ブロック内のどこか（例えば`OP_RETURN`やtaproot tweakなど）に隠します。PQ耐性のあるUTXOを自分で持たないユーザーは、
  信頼できないアグリゲーターにコミットメントを渡すことができます。アグリゲーターは多数のユーザーのコミットメントを単一のオンチェーンルートの下に
  マークルコミットメントとしてまとめます（その際、救済されるコインから手数料を支払うことも可能です）。
  一定期間の遅延の後、ユーザーは証明（ポスト量子公開鍵による署名）と、
  そのコミットメントが以前のブロックに含まれていたことを示すSPV方式の開示証明を提示します。
  DropKickは、知識の非対称性が判定可能なUTXO（ハッシュされた公開鍵などの隠れたデータが存在することを、
  検証者がアウトプットだけから判断できるもの）のみを対象とする限り、没収を伴わないソフトフォークとして展開できます。
  BIP32の鍵導出のような判定不能なケースまで対象にすればより多くのコインを救えますが、
  一部のコインが没収されるリスクも生じます。なお、P2PKのコインは対象にできません。
  コミットメントを投稿するために各ユーザーがPQセキュアなUTXOを持つ必要があるTadge DryjaのLifeboatと比べると、
  DropKickはオンチェーンの全コミットメントをインデックス化し順序付ける必要をなくしますが、
  その代償としてreveal時のマイナーによる検閲リスクがあります。Conduitionは、
  長めの遅延（ユーザーがUTXOの1%を正直なマイナーに支払うなら約100ブロック）と金額に比例した手数料を組み合わせれば
  検閲を不採算にできると主張しています。ただしこれは、検閲者が検閲の試みを覆すブロックを再編成する能力を持たない、
  あるいはその意思がないことを前提としています。

- **SHRINCSのBIPドラフト**: ConduitionはSHRINCSワーキンググループを代表してBitcoin-Devメーリングリストに、
  Bitcoin向けの半ステートフルな[ハッシュベース][news386 jn hash]署名方式としてSHRINCSを規定する最初の[ドラフト][shrincs bip]を[投稿しました][c ml shrincs]（
  [ニュースレター #391][news391 shrincs]参照）。公開鍵は48 byteです。ステートフルな署名は最小で548 byte、
  組み込みのステートレスなフォールバックは5,777 byteの署名を生成します（ドラフトでは、LNのような高頻度プロトコルでもフォールバックを利用できるよう、
  ステートレス署名の許容回数上限を2^40回に引き上げています）。検証速度は、
  SHA256のハードウェアアクセラレーションを利用する場合、
  バイトあたり[BIP340][]の[Schnorr][topic schnorr signatures]署名の4〜16倍高速で、
  最悪の場合でもステートレス署名1つあたりSHA256圧縮処理2,792回分です。当初の提案からの主な変更点には、
  SLH-DSA（FIPS-205）とのブラックボックス互換性、任意の構造を取れる柔軟なXMSSツリー、
  そしてより高速（かつサイズの大きい）ステートフルパラメーターの採用が含まれます。
  ドラフトが規定するのは署名方式のみで、新しいopcodeや新しいアウトプットタイプによるこの新署名のデプロイは別途の提案の対象となります。
  ステートフルなカウンタを再利用すると、観測者に署名を偽造されてしまいます。Antoine Riardは、
  5,777 byteのステートレス署名は、これらのフィールドが割引されない限り
  現在のトランザクションのおよそ90倍のオンチェーンコストになると[指摘しました][ar ml shrincs]。
  また、マシン検証されたWOTS+C証明を伴うJonas Nickとremix7531のCライブラリ[libshrincs][news419 libshrincs]も、
  SHRINCSを統合したい人々への実装面の支援として別途リリースされました。

- **BIP448およびCSFS/CTVのデモとアプリケーション**:
  [BIP448][]（`OP_TEMPLATEHASH`、[`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack]（CSFS）、
  `OP_INTERNALKEY`をまとめた[Tapscript][topic tapscript]バンドル。[ニュースレター #397][news397 bip448]参照）に関する取り組みが続いており、
  デモや実装、概念実証を集約する新しいサイトが登場しています。[BIP448][bip448 org]のGitHub Organizationでは
  Bitcoin Inquisition（アクティベーションを伴わないBitcoin Coreパッチ）、[miniscriptとPSBTの統合][news395 thikcs]、
  [LN-Symmetry][topic eltoo]のBOLTドラフトとCore Lightningでの実装、
  [Ark][topic ark]の`OP_TEMPLATEHASH`のsignet上での[デモ][news419 thark]といった実装が収集されています。
  同Organizationによると、次回のBitcoin Inquisitionリリースでは、
  デフォルト[signet][topic signet]上でこのバンドル一式が利用可能になる予定です。
  askii21mは[Taproot][topic taproot]アウトプットを構築し、選択可能なopcodeセットの下で
  Tapscriptをステップ実行できるブラウザベースのエディターであるcovenants.diyを[発表しました][askii delving cvd]。
  このエディターには、BIP448の再バインド可能な状態、[BIP119][]のVaultと輻輳制御、
  BIP348の委任などの例がパーマリンク付きで掲載されています。CofundのJesus Najera（setzeus）は、
  Vault、輻輳制御、Arkの発行、LN-Symmetryなど20以上の構成を含むインタラクティブな
  Covenants Use-Case Atlasを[公開しました][cofund atlas]。

  Ademanは、小規模なジャストインタイム（[JIT][topic jit channels]）ライトニングチャネルを開くために使われるArkの
  OOR（Out-Of-Round）仮想トランザクションアウトプット（VTXO）割り当てに関連する構成案を[投稿しました][ademan delving lark]。
  Arkサーバーはオペレーターであると同時に最初のVTXO保有者でもあるため、現状では同じVTXOを何度も再割り当てすることが可能です。
  Ademanの二重解釈防止用ボンド（equivocation bond）は、割り当て用の鍵を用いて、
  異なる[BIP341][] sighashに対する2つのCSFS検証可能な署名を公開することで没収の対象となります。
  このボンドと事前割り当てされたトランザクションツリーには次トランザクションへの[コベナンツ][topic covenants]が必要で、
  それには[`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]（CTV）または`OP_TEMPLATEHASH`のいずれかを利用できます。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 26.06.7][]は、人気のあるLNノード実装の現行メジャーバージョンに対するセキュリティリリースです。
  責任ある開示が行われた複数の脆弱性を修正しており、いずれも実際に悪用されていることは確認されていません。
  これらの脆弱性は、上記のニュースセクションで開示について説明したErick Cestariを含む研究者らによって報告されました。
  プロジェクトは全ユーザーに強くアップグレードを推奨しています。
  [ニュースレター #420][news420 cln embargo]で述べたとおり、修正内容のリバースエンジニアリングを遅らせるため、
  ソースコードは8月28日のバイナリリリースから14日間公開が保留されます。その後、
  CLNの[再現可能なビルド][topic reproducible builds]によってユーザーはバイナリを検証できるようになります。
  8月28日から9月1日の間に`v26.06.7`または`latest`タグをプルしたDockerユーザーは、
  新バージョンを名乗るものの修正を含まないイメージを受け取っています。
  該当するユーザーはイメージのダイジェストを確認し、再度プルする必要があります。

- [LND v0.21.3-beta][]は、人気のあるLNノード実装のメンテナンスリリースです。
  後述の注目すべきコード更新セクションで説明するピアのリソース制限、`channel_update`のエンコーディング修正、
  ダスト[HTLC][topic htlc]の解決の修正に加え、
  [ニュースレター #420][news420 lnd deadlock]の[PSBT][topic psbt]資金供給デッドロック修正を含みます。
  また、[Taproot Assets][topic client-side validation]チャネルのような補助アウトプットを持つチャネルにおける協調閉鎖手数料のバグ、
  レガシーな[AMP][topic amp]インボイスに対するネイティブSQLインボイスマイグレーションの失敗、
  REST WebSocketプロキシのパニック、いくつかのゴシップクエリと協調閉鎖のバグを修正し、
  実験的な`XCreateAccount` RPCを追加しています（[ニュースレター #419][news419 lnd account]参照）。

- [LND v0.20.4-beta][]は、LNDの0.20リリースブランチのメンテナンスリリースです。
  ピアのリソース制限、`channel_update`のエンコーディング修正、ダストHTLCの解決修正を含む0.21.3-betaの修正の大半をバックポートしており、
  さらにインバウンド手数料や[MuSig2][topic musig]のnonceのような固定長TLVレコードについて、
  宣言された長さが誤っている場合に黙って受理・再エンコードするのではなく拒否するようになりました。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #36111][]は、`validateaddress` RPCにおいて、
  長過ぎる[bech32][topic bech32]文字列に対するエラーを報告する際に使用されるメモリを制限します。
  これまでは、[BIP173][]が定める90文字の制限を超える文字列に対して、
  制限を超えた各位置すべてがエラー位置として返され（[ニュースレター #177][news177 bech32]参照）、
  それぞれが個別のJSON値に変換されていました。今後、RPCは長さ違反が始まる90文字目のみを返します。
  作者のテストでは、HTTPリクエストの最大サイズに近い認証済みリクエストで、
  変更前は約5.7 GiBのメモリを消費していましたが、変更後は240 MiBとなりました。

- [Bitcoin Core #36032][]は、`createrawtransaction`、`createpsbt`、`sendmany`など、
  トランザクションを構築するRPCのパフォーマンスを改善します。具体的には、
  アウトプットのパースを二次関数的処理から線形処理に変更しました。これまでのパーサーは、
  アウトプットのキーを反復処理する度に、対応する値をそれぞれ個別に検索していたため、
  その都度同じ内部リストを走査し直していました。加えて、`sendmany`はパース中もウォレットのロックを保持していました。
  今後、パーサーは[ニュースレター #419][news419 gettxspendingprevout]の`gettxspendingprevout`修正と同様に、
  インデックスに基づいてキーと値を一緒に走査するようになります。作者の報告では、
  デバッグビルドで10,000個のアウトプットをパースする時間が1.8秒から0.5秒に短縮されました。

- [Core Lightning #9435][]は、[BOLT2][]の規定に従い、
  ピアから`next_commitment_number`がゼロの`channel_reestablish`メッセージが送信された場合に
  チャネルを強制閉鎖するようCLNを更新します。ゼロという値はピアがチャネルの状態を失ったことを示しており、
  最新のコミットメントトランザクションをブロードキャストすることで、
  ピアは[Static Channel Backup][topic static channel backups]を用いて残高を回復できます。これまでは、
  CLNはこれを開いたばかりのチャネルに対してのみ強制していました。それ以外のチャネルでは、
  CLNはまずピアの古い`next_revocation_number`を検出して警告を送り、チャネルは開いたままにしていました。

- [Eclair #3368][]は、非[Taproot][topic taproot]チャネルのピアから受け取った`commitment_signed`メッセージに、
  [Simple Taproot Channel][topic simple taproot channels]が[MuSig2][topic musig]の部分署名に使う
  `partial_signature_with_nonce` TLVを含んでいる場合のバグを修正します（[ニュースレター #404][news404 eclair taproot]参照）。
  Eclairはメッセージの通常のECDSA署名を正しく検証していたものの、意図せず送信された部分署名をピアの署名として誤って保存していました。
  これにより、Eclairが後でチャネルを強制閉鎖できなくなっていました。今後、
  Eclairは検証前にチャネルのコミットメント形式に合致する署名タイプを選択し、検証済みの署名のみを保存します。

- [Eclair #3366][]は、仕様に準拠しないピアに対する[スプライシング][topic splicing]の安全性を強化します。
  Eclairは、自身の`stfu`[静止][topic channel commitment upgrades]メッセージの後にチャネル更新を送るピアや、
  スプライシングの交渉中に`commitment_signed`メッセージを送るピアを切断するようになりました。
  スプライシングの署名中にピアがチャネルの既存コミットメントを進めようとした場合は、
  受理する代わりに強制閉鎖します。また、コミットメント番号がチャネルのものと一致しなくなったスプライシングや
  [デュアルファンディング][topic dual funding]の[RBF][topic rbf]の試行も拒否します。さらに、
  Eclairが[Liquidity Ads][topic liquidity advertisements]を通じて流動性を販売するスプライシングが署名開始後に中断された場合、
  Eclairはその対価となる受信[HTLC][topic htlc]を直ちに失敗させるようになりました（
  関連する修正については[ニュースレター #379][news379 eclair liquidity]参照）。

- [LND #11090][]は、受信`ping`メッセージにレート制限をかけ、各ピアの送信メッセージキューに上限を設けることで、
  上記ニュースセクションでCLNについて述べたようなリソース枯渇を防ぎます。各ピア接続について、
  LNDは2つのトークンバケットを保持するようになりました。受信`ping`リクエスト用のバケットは200トークンから始まり、
  毎秒10トークンずつ補充されます。このバケットを使い切ったピアは切断されます。
  送信`pong`応答用のバケットは20トークンから始まり、毎秒1トークンずつ補充されます。
  こちらを使い切るとLNDは応答を停止します。これは[BOLT1][]からの意図的な変更です。
  各ピアの送信キューにも10,000メッセージまたは約16 MiBの上限が設けられます。さらにこのPRは、
  `channel_update`[ゴシップメッセージ][topic channel announcements]のエンコーディングを修正し、
  [インバウンド手数料][topic inbound forwarding fees]を広告するLND自身の更新が、
  ブロードキャストするバイト列とまったく同じものに対して署名されるようにします。
  これまではこれらのバイト列が異なることがあり、ピアが更新を拒否する原因となっていました。また、
  LNDが他ノードから転送する更新についても、認識できないTLVレコードを削除して発信元の署名を無効にするのではなく、
  そのまま保持するようになりました（同様のEclairの修正については[ニュースレター #418][news418 eclair flags]参照）。

- [LND #11140][]は、送信側チャネルが強制閉鎖され、転送中の[HTLC][topic htlc]が
  一方の当事者のコミットメントトランザクションでのみ[ダスト][topic uneconomical outputs]として[トリム][topic trimmed htlc]される場合のLNDの処理方法を修正します。
  これまでは、HTLCがLND側のコミットメントにはアウトプットを持つがピア側のコミットメントがアウトプットなしで承認された場合、
  LNDは自分のコミットメントを基準に判断していたため、受信HTLCをフェイルバックしませんでした。
  その結果、受信HTLCは上流のチャネルが期限近くで強制閉鎖されるまで保留のままとなっていました。
  今後、LNDは実際に承認されたコミットメントに基づいて判断します。また、
  送信HTLCが自分のコミットメントではダストだがピアのコミットメントでアウトプットを持つ場合、
  ピアがプリイメージでそのアウトプットを請求できる可能性があるため、LNDは受信HTLCを早期に失敗させなくなりました。

- [HWI #792][]では、`signtx`コマンドに`--registration`オプションが追加されました。このオプションを使用すると、
  `registerdescriptor`コマンドでハードウェア署名デバイスに登録された[BIP388][]ウォレットポリシーを使って[PSBT][topic psbt]に署名できます（
  ニュースレター[#419][news419 hwi]および[#420][news420 hwi]参照）。このオプションは、
  `registerdescriptor`が返すシリアライズされた登録情報（ポリシー名、[ディスクリプター][topic descriptors]、
  デバイスタイプ、LedgerのHMACのようなデバイス固有の登録データ）を受け入れます。
  BitBox02、Coldcard Edge、Jade、および非レガシーなLedgerデバイスがサポートされています。

- [BDK #2262][]は、ウォレットのトランザクショングラフを再インデックスする際に、
  ウォレット自身のアウトプットの一部を見落とす可能性があったバグを修正します。BDKの`KeychainTxOutIndex`は、
  これまでに見た最大の[BIP32][]導出インデックスを超えて先読みする[アドレスのウィンドウ][topic gap limits]を監視し、
  より大きいインデックスのアウトプットが見つかるたびにウィンドウを拡張します。これまでは、
  再インデックスは各アウトプットを一度しか調べなかったため、現在のウィンドウを超えるアウトプットはウォレットに属さないと判断され、
  後のアウトプットによってウィンドウが拡張された後も再検査されることはありませんでした。
  アウトプットはランダムな順序で調べられるため、同じウォレットでも実行ごとに異なる残高が表示されることがありました。
  再インデックスは今後、ウィンドウの拡張が止まるまで処理を繰り返します。

{% include snippets/recap-ad.md when="2026-09-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8525,36111,36032,9435,3368,3366,11090,11140,792,2262" %}
[spc del]: https://delvingbitcoin.org/t/silent-payments-coinbase/2833
[cln dos del]: https://delvingbitcoin.org/t/disclosure-crashing-cln-with-a-flood-of-pings/2846
[cln v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[news417 pqout]: /ja/newsletters/2026/08/07/#pqc
[news417 pqwit]: /ja/newsletters/2026/08/07/#segwit
[news403 pqout]: /ja/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news393 p2mr]: /ja/newsletters/2026/02/20/#bips-1670
[pw delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/6
[c delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/7
[ag delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/15
[c ml dropkick]: https://groups.google.com/g/bitcoindev/c/6SqWPfBf-p0
[news361 pqcr]: /ja/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[news348 utxo proving]: /ja/newsletters/2025/04/04/#sha256-utxo
[c ml shrincs]: https://groups.google.com/g/bitcoindev/c/HbVboXIFiG8
[shrincs bip]: https://github.com/SHRINCS/shrincs-bip/blob/main/SHRINCS.md
[ar ml shrincs]: https://gnusha.org/pi/bitcoindev/b4bb949d-bd35-424d-a1d1-459e6cca263an@googlegroups.com/
[news386 jn hash]: /ja/newsletters/2026/01/02/#bitcoin
[news391 shrincs]: /ja/newsletters/2026/02/06/#shrincs-324-byte
[news419 libshrincs]: /ja/newsletters/2026/08/21/#libshrincs
[news397 bip448]: /ja/newsletters/2026/03/20/#bips-1974
[news395 thikcs]: /ja/newsletters/2026/03/06/#templatehash-csfs-ik
[bip448 org]: https://github.com/bip448
[news419 thark]: /ja/newsletters/2026/08/21/#op-templatehash-ark
[askii delving cvd]: https://delvingbitcoin.org/t/covenants-diy-a-node-editor-for-covenant-scripts/2826
[cofund atlas]: https://getcofund.com/research/covenants-use-case-atlas
[ademan delving lark]: https://delvingbitcoin.org/t/improving-the-security-of-lark-oor-channels-with-equivocation-bonds/2816
[news177 bech32]: /ja/newsletters/2021/12/01/#bitcoin-core-16807
[news419 gettxspendingprevout]: /ja/newsletters/2026/08/21/#bitcoin-core-35889
[news379 eclair liquidity]: /ja/newsletters/2025/11/07/#eclair-3206
[news418 eclair flags]: /ja/newsletters/2026/08/14/#eclair-3341
[news419 hwi]: /ja/newsletters/2026/08/21/#hwi-842
[news404 eclair taproot]: /ja/newsletters/2026/05/08/#eclair-3144
[news420 hwi]: /ja/newsletters/2026/08/28/#hwi-841
[Core Lightning 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[LND v0.21.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.3-beta
[LND v0.20.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.4-beta
[news420 cln embargo]: /ja/newsletters/2026/08/28/#core-lightning
[news420 lnd deadlock]: /ja/newsletters/2026/08/28/#lnd-11008
[news419 lnd account]: /ja/newsletters/2026/08/21/#lnd-11065
