---
title: 'Bitcoin Optech Newsletter #425'
permalink: /ja/newsletters/2026/10/02/
name: 2026-10-02-newsletter-ja
slug: 2026-10-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Eclairの旧バージョンに影響する2件のサービス拒否脆弱性の責任ある開示と、
信頼できないストアを介してデバイス間でウォレットラベルを同期するための提案を掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する提案と議論の要約や、
新しいリリースとリリース候補の発表、人気のBitcoin基盤ソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **Eclairの2件のDoS脆弱性の開示**: Matt Morehouseは、
  Eclair v0.13.1以前に影響する2件のサービス拒否（DoS）脆弱性の[責任ある開示][topic responsible disclosures]を
  Delving Bitcoinに[投稿しました][mm eclair dos]。いずれも5月にリリースされた
  [Eclair v0.14.0][news407 eclair]で修正されており、古いバージョンをまだ実行しているユーザーはアップグレードする必要があります。
  どちらの攻撃も、[BOLT8][]のハンドシェイクが完了していれば実行でき、チャネルは必要ありません。

  1つめの脆弱性は、機能ビットのパース処理にあります。Eclairは`init`メッセージ内の機能ビットを1つずつパースし、
  ビットごとに複数のオブジェクトを割り当てていたため、最大長の`init`メッセージ1つで約300 MBのメモリが割り当てられては破棄され、
  パーススレッドが最大300 ms占有されていました。Morehouseのテストでは、
  数十の接続を持つ攻撃者がこのメッセージを繰り返し送信することで、1分以内にノードのすべてのピアを切断させ、
  5分以内にメモリを枯渇させました。Morehouseは、自身のLNファザーである[smite][smite repo]の最も基本的なテストでこのバグを発見しました。
  このテストは、バイト列を1つのメッセージとして送信し、対象が引き続き`ping`に速やかに応答するかを確認するものです。
  修正は、機能パース処理のリファクタリングである[Eclair #3264][]の一部として3月にマージされましたが、
  このPRでは脆弱性について言及されていませんでした。

  2つめの脆弱性は、ゴシップクエリにあります。[BOLT7][]は2022年4月に`query_short_channel_ids`メッセージのzlibエンコーディングを削除し、
  Eclairも同月にその送信を停止しましたが、受け入れは続けていました。zlibの解凍には出力制限がなかったため、
  64 kBのメッセージが64 MB、約1,700万個のオブジェクトに膨れ上がる可能性があり、
  このようなメッセージを大量に送りつけられるとノードは数秒でオフラインになりました。Morehouseは、1つめのバグの後、
  LLMを使用して、ピアが自身の費やす労力よりもはるかに多くの作業をノードに課すことができる他の箇所をEclairのコードベースから探し、
  これを発見しました。修正は[Eclair #3263][]です。

- **<!--proposal-for-wallet-label-synchronization-->ウォレットラベルの同期に関する提案**: Jakubは、
  仕様を書く前に関心を測るため、共有の信頼できないストアを介したウォレット間での
  [ウォレットラベル][topic wallet labels]の同期を標準化することについて
  Bitcoin-Devメーリングリストに[投稿しました][label sync ml]。
  [BIP329][]はラベルのエクスポートフォーマットを標準化しましたが（[ニュースレター #215][news215 label]参照）、
  同じ[ディスクリプター][topic descriptors]を使用するウォレット間（たとえばコーディネーターと監視専用ウォレットなど）での
  ラベルの移動は依然として手動でのエクスポートとインポートの繰り返しとなっており、
  関連するラベルなしでコイン選択の判断が行われています。

  この提案では、ウォレットは秘密鍵を一切使用せずに、ディスクリプターの正規の形式から
  保存場所と暗号鍵を導出するため、ディスクリプターを共有するウォレットは設定なしに同じデータを見つけられます。
  変更を加えていないBIP329のレコードは、認証付き暗号のエンベロープ内で転送されます。
  各レコードは書き込まれた時刻とともに保存されるため、2つのウォレットが同じラベルを変更した場合、
  最も新しい変更が優先されます。BIP329にはラベルを削除する方法がないため、
  削除は他のウォレットからラベルを取り除くマーカーとして記録されます。
  JakubはNostrを参照トランスポートとして提案していますが、プロトコルはデータを保存して返せるサービスだけを必要とします。
  Bitcoin SafeウォレットはすでにNostrを介してこの方法でラベルを同期しています。
  Jakubは、暗号鍵をディスクリプターから導出すべきか（ウォレットがディスクリプターのみからラベルを復元できるが、
  xpubを保持したすべての人にラベルが露出する）、それとも別のシークレットから導出すべきかを質問しました。
  また、デバイス間で1つの共有鍵ペアを使用するかデバイスごとのペアリングを使用するか、
  正規のディスクリプター形式をどのように定義するかも質問しました。

  Craig Rawは、ラベル同期は、[PSBT][topic psbt]やマルチシグセットアップ、
  支払いの承認といった他のユースケースも含む、より広範なウォレット間通信の仕様の一部であるべきだと返信しました。
  また、金融データの交換は検閲耐性よりもプライバシーを優先して最適化すべきであるとして、
  参照トランスポートプロトコルとしてNostrを使用することに異議を唱え、
  正規のアウトプットディスクリプターに関するBIPを執筆中であると述べました。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **PQCアウトプットタイプに関する議論の続き**: [ポスト量子][topic quantum resistance]アウトプットタイプに関する
  Pieter WuilleのDelving Bitcoinスレッドについての先月の[要約][news421 pqout]に続き、Antoine Riardは、
  量子脆弱な使用パスを後からそのアウトプットタイプ内に限って無効化できる[P2TRv2][news403 pqout]アウトプットは、
  ユーザーがそのアウトプットで受け取ることでオプトインすることになり、既存のアウトプットの一律の凍結を避けられるため、
  受け入れ可能であると肯定的に[返信しました][ar delving pqout]。彼は、
  [CISA][topic cisa]（インプット間の署名集約）をその変更とバンドルしないことを望んでおり、
  新しいウィットネススタイルを持つ[P2MR][news393 p2mr]ベースのタイプを後から導入し、
  無効化された後も一部のコインについてはsecp256k1で保護されたパスを維持できるようにするオプションのリーフバージョンを提案しました。

  Conduitionは、P2TRv2であっても単純なウィットネスバージョンの引き上げでは済まないと[主張しました][c delving pqout deriv]。
  実際にポスト量子パスを使用するウォレットは、[BIP32][]スタイルのワークフローに代わる、
  PQ鍵を導出するための新しい標準を依然として必要とするためです。Wuilleは、
  手数料やPQを気にしないユーザーを抱えるロングテールのウォレットがCISAへ移行する可能性は低く、
  また、P2TRv2もP2MRも、secp256k1の使用をいつ停止するかを誰かが決定することに依存しているため、
  カテゴリーとして絶対に量子安全なアウトプットタイプではないと[返信しました][pw delving pqout cisa2]。
  P2MRは所有者が決定できますが、Wuilleは、ほとんどのユーザーがその恩恵を受けるには、
  アドレスの再利用や公開鍵の共有が深く根付きすぎていると考えています。

  Antoine Poinsotは、P2TRv2とCISAは逆方向に引っ張り合うという点に[同意しました][ap delving pqout]。
  secp256k1の早期の無効化を想定せずにCISAを望むユーザーはP2TRv2を拒否する可能性があり、
  あるいはさらに悪いことに、ポスト量子の使用パスなしでP2TRv2を採用し、
  後のsecp256k1の無効化を阻害する可能性もあります。
  また、これらを別々のアウトプットタイプとして提供した場合、両方が広く使われるようになると、
  識別可能なフットプリントが残る可能性があることも指摘しました。ConduitionとWuilleは、
  P2MRの保護が実際に達成可能かどうかについて議論を続け、
  Conduitionは両方のアウトプットタイプをデプロイしてユーザーに選択させることを[提案しました][c delving pqout both]。

- **SNARKによるブロック全体の署名集約**: Conduitionは、
  ブロック内の多数の[ポスト量子][topic quantum resistance]署名を1つのSNARKに圧縮する設計のスケッチを
  Delving Bitcoinに[投稿しました][c delving snark]（Ethan Heilmanによる以前の
  [提案][eh delving stark]および[ニュースレター #412][news412 stark]も参照）。
  ハッシュベースの署名は検証コストは低いものの、サイズが大きくなります。
  手数料面で競争力を持たせるのに十分なウィットネスディスカウントを適用すると、
  アーカイブ用のストレージが年間テラバイト単位で増加することになります（[ニュースレター #417][news417 pqwit]参照）。

  Conduitionは、大規模なマイニングプールが証明を自ら生成することを想定しており、
  通常のノードは証明生成を行うべきではないと主張しています。
  彼の設計では、汎用の仮想マシン（VM）ではなく専用の集約回路を、再帰的な証明ではなく単一のフラットな証明を、
  そしてSLH-DSAではなくWOTS+Cを用いた[SPHINCS][news383 sphincs]の亜種を使用します。
  この亜種の検証はすべての署名について同じ回数のハッシュ操作で済みますが、
  SLH-DSAでは回数が署名者の選択に依存するため、SLH-DSA用の回路は最もコストが高いケースに合わせたサイズにしなければなりません。
  最も小さなハッシュベースのSNARK証明は、通常300～500 kBです。提案された証明の健全性に関する懸念を和らげるため、
  彼は将来の状況に応じてリカバリーまたはオプトアウトするためのいくつかの仕組みを概説しました。彼は、
  素の署名とSNARKの両方を有効なブロックフォーマットとして認めることには反対しています。
  これは、空のブロックをマイニングする代わりに証明が生成されている間マイナーがマイニングを続けられるようになりますが、
  リソース制限を最悪のケースを前提に設定しなければならなくなるためです。
  ハッシュ回路向けのSNARKプルーバーであるFlockのSHA256ベンチマークから単純に推定すると、
  10スレッドのCPUで10,000署名のブロックを証明するのに約20秒かかることが示唆され、
  これを10秒未満に短縮できる見込みがあるとのことです。Conduitionは、
  FlockでSPHINCS検証回路をテストした人はまだいないと述べています。Jonas Nickは、
  SNARKのランダムオラクルにおける証明は、同じSNARKの再帰的な使用を自動的にカバーするわけではないことを示す研究を[指摘しました][jn delving snark]。
  ZmnSCPxjは、マイナーが使用する証明（Prover）のコードにDoSがあるとブロック生成が停滞する可能性があると[警告し][zmn delving snark]、
  レビューを受けられるようProverをBitcoin Coreに同梱することを提案しました。

- **BIP54のタイムワープ修正によるチェーン長の上限**: Pieter Wuilleは、
  [コンセンサスクリーンアップ][topic consensus cleanup]提案（[BIP54][]）の2つのタイムスタンプルールが、
  所定の作業量のチェーンでマイニング可能なブロック数を制限するのに十分であることの証明を
  Delving Bitcoinに[投稿しました][pw delving timewarp]。
  この上限はLeanで機械検証されているため、証明対象の記述内容のみレビューすれば十分です。
  1つめのルール（古典的な[タイムワープ][topic time warp]）は、リターゲット期間の最初のブロックが、
  直前のブロックより7,200秒以上遡らないことを要求します。2つめのルール（Murch–Zawy、[ニュースレター #316][news316 timewarp]参照）は、
  期間の最後のブロックが最初のブロックより前の時刻にならないことを要求します。この2つを合わせると、
  長期的なブロックレートは約9分56秒につき1ブロックに制限され、
  さらに難易度の上昇という代償を払って得られる追加ブロックの数も制限されます。

  高さ966,270のチェーンの場合、この式で許容されるのは最大1,012,794ブロックで、
  どちらのルールもない場合と比べて約3,300倍厳しい制限となります。いずれか一方のルールを省くと、
  上限は33.4億ブロックを超えたままになります。Wuilleが報告した、
  実際に構築された最長のチェーンは1,007,326ブロックです。

  Wuilleの動機は、BIP54が埋め込まれた場合にこの上限に依存できる、
  Bitcoin Coreのヘッダー事前同期（presync）の[DoS保護][news216 presync]にありました。
  Zawyは別の定式化について議論しました。Wuilleはその後、
  所定の時間内に所定の長さのチェーンを生成するために必要な作業量についての補足的な下限を証明しました。

- **Vault向けコベナンツ提案の比較**: Lillian Wangは、事前署名トランザクション、
  [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]（CTV）、
  [`SIGHASH_ANYPREVOUT`][topic sighash_anyprevout] / `SIGHASH_ANYPREVOUTANYSCRIPT`（APO/APOAS）、
  `OP_TXHASH`、[`OP_CHECKCONTRACTVERIFY`][topic matt]（CCV、[BIP443][]）
  および[`OP_CAT`][topic op_cat]ベースの[Purrfect Vault][news291 cat vault]を使用した、
  簡略化された[Vault][topic vaults]の構成を比較した[レポート][vault report]をDelving Bitcoinに[投稿し][lw delving vaults]、
  Bitcoin-Devメーリングリストにも[クロスポストしました][lw ml vaults]。

  レポートは、
  CTVは事前計算されたアウトプットを持つシンプルなVaultに適しており、
  CCVは部分的な引き出しとトリガー時の引き出しアドレスの選択を最もよくサポートし、
  TXHASHは設計者の責任が増す代わりにコミットメントの柔軟性が高まると結論付けています。
  APOASとCATは、Vault以外のより幅広い用途も評価する場合には、より魅力的になる可能性があります。

  askii21mは、APOASはインプットの数にもインプットのインデックスにもコミットしないため、
  同じVaultアドレスへの2つのデポジットにまたがるAPOAS署名を、
  期待されるアウトプットを1回しか作成せず、2つめのデポジットの金額が手数料に回されるような
  単一のトランザクションにまとめることができる（ハーフスペンド）と[指摘しました][askii delving vaults]。
  そのため、Vaultアドレスを決して再利用しないことは、推奨事項ではなく必須要件となります。

- **確率的なライトニングチャネルのためのDepot**: John Lawは、
  オペレーターが、何千、何百万ものユーザーのライトニングチャネルをホストできる、
  期限付きの単一のTaprootアウトプット（Depot）に資金を提供する[プロトコル][depots paper]を
  Delving Bitcoinに[投稿しました][jl delving depots]。ユーザーは、
  自分の資金をオンチェーンに置くのではなく、ライトニング支払いでオペレーターからこれらのチャネルを購入します。
  これらの残高は通常、オンチェーンでクレームする価値がないほど小さいため、
  Depotはユーザーごとの小さな確定的なクレームを、同じ期待値を持つ大きなクレームの確率に置き換え、
  オンチェーンに現れうるクレームの数を制限します。

  購入された各チャネルには、ユーザーが選んだ0から大きな素数（P）までの間の秘密の推測値（guess）が割り当てられ、
  Depotの期限切れ後に1/Pの確率で「ヒット（hit）」となります。期限切れ前に、
  ユーザーはライトニングで（場合によっては後続のDepotへ）支払うことでDepot内の自分のチャネルを空にし、
  推測値を公開してチャネルがヒットしないようにチャネルを取り消すことが求められます。
  期限切れ後、オペレーターはターゲットを公開します。チャネルの推測値がターゲットと一致すれば、
  そのチャネルはヒットします。チャネルがヒットしなければ、オペレーターがアウトプットを回収します。
  ちょうど1つのチャネルがヒットした場合、そのユーザーはDepotを強制的にオンチェーンに展開し、
  自身のオフチェーン残高のP倍を受け取ることができます（つまり、P倍の支払いを1/Pの確率で受け取ることの期待値は、
  ユーザーの実際の残高と同じになります）。2つ以上のチャネルがヒットした場合、Depotはバーンされ、
  ユーザーがDepotの保有額を超えて回収することが防止されます。

  Lawによると、これによりオンチェーンフットプリントはユーザー1人あたり年間約1～2 vbyteに抑えられ、また、
  Depotはホストするユーザー数に関係なく一定サイズのトランザクションセットで解決されるため、
  強制的なオンチェーントランザクションが殺到する事態も回避されます。セキュリティは、[嫌がらせを行う者へのペナルティ][news329 opr]に依存しています。
  （たとえば、チャネルを空にする作業への協力を拒否するなどして）嫌がらせを行う当事者は、
  自身が与えた損害のうち設定された割合を失うことを覚悟しなければなりません。Depotには、
  [`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack]と[`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]が必要です。
  `OP_PAIRCOMMIT`（[BIP442][]）、`OP_MUL`、`OP_MOD`があればより効率的になりますが、必須ではありません。

  Anzusは、ユーザーが期限を逃したりデバイスを紛失したりした場合にどうなるかを質問しました。Lawは、
  自身の[タイムアウトツリー][topic timeout trees]とは異なり、オペレーターはユーザーが提供するシークレットなしにDepotをロールオーバーできないこと、
  ウォレットが早期の引き出しを自動化できること、そしてリカバリーにはシードに加えてDepotのパラメーターとチャネルの状態が必要であることを[回答しました][jl delving depots recover]。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.21.4-beta.rc1][]は、この人気のLNノード実装のメンテナンスリリースのリリース候補です。
  後述の注目すべきコードのセクションで説明する[チャネルアナウンス][topic channel announcements]の同期の修正と、
  新しいレガシーチャネルの制限が含まれています。その他の修正では、保留中の[HTLC][topic htlc]、
  [AMP][topic amp]インボイスの意図しないキャンセル、SQLグラフの移行の失敗に対処しています。
  `WalletKit`は、アウトプットを使用するトランザクションが指定された承認数に達するまで、
  そのアウトプットを確保できるようになりました。また、このリリースでは、
  チャネルを開設する際に明示的なチャネルタイプが必要になります。

- [LND v0.20.5-beta.rc1][]は、LNDの0.20リリースブランチのメンテナンスリリースのリリース候補です。
  保留中のHTLC、AMPインボイスのキャンセル、チャネルの同期に関する修正など、
  0.21.4-beta.rc1にも含まれるいくつかの修正がバックポートされ、オニオンペイロードのパース処理に上限が追加されています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29278][]は、ウォレットトランザクションの手数料率の上限をデフォルトで0.10
  BTC/kvB（10,000 sat/vB）に制限する`-maxfeerate`設定オプションを追加します。これまで、
  `-maxtxfee`オプションは絶対的な手数料の上限として文書化されていました。しかし、
  一部のチェックでは同じ金額を1,000 vBあたりの手数料としても解釈していました（[ニュースレター #54][news54 maxtxfee]参照）。新しいオプションは、
  手数料率の制限を手数料総額の制限から分離するもので、トランザクションの作成、
  [手数料の引き上げ][topic rbf]、[CPFP][topic cpfp]および通常のウォレットのブロードキャストに適用されます。

- [Bitcoin Core #35984][]は、[PSBT][topic psbt]の署名において、
  対応するアウトプットがない状態で`SIGHASH_SINGLE`署名が生成される可能性があったバグを修正します。
  このsighashタイプは、署名対象のインプットと同じインデックスにあるアウトプットにコミットします。
  対応するアウトプットが存在しない場合、レガシー署名では定数ハッシュに対する署名が生成されます（[ニュースレター #207][news207 single]参照）。
  この署名は、対応するアウトプットが存在しない状態である限り、同じ鍵で管理されている他のUTXOの使用に再利用できてしまいます。
  Bitcoin Coreは、レガシーインプットおよびSegwit v0インプットについて、このケースではインプットを未署名のままにしつつ、
  PSBTの他のインプットについては引き続き署名するようになりました。
  これは、トランザクションの署名に既に存在していたチェックを拡張したものです。

- [Bitcoin Core #35301][]は、アドレスのエンコードとデコード、
  適格なトランザクションインプットからの[Taproot][topic taproot]支払いアウトプットの導出、
  受信者への支払いを検出するためのトランザクションのスキャンをサポートすることで、
  [BIP352][]の[サイレントペイメント][topic silent payments]の実装を開始します。
  また、異なる導出アドレスへの支払いを区別し、お釣りを識別するためのラベルのサポートも追加します。
  この実装は、libsecp256k1のsilent-paymentsモジュール（[ニュースレター #415][news415 silent]参照）をベースにしています。
  ただし、このPRではまだ、ウォレットのRPCやGUIを介したサイレントペイメントの送受信は有効になっていません。

- [Bitcoin Core #36312][]は、実験的でオプトインの
  プライベートトランザクションブロードキャスト機能（[ニュースレター #388][news388 private broadcast]参照）におけるプライバシーリークを修正します。
  これまでは、[不正な動作をするピアを阻止する][news106 discouragement]と、
  同じアドレスへの通常の接続とプライベートブロードキャスト接続の両方が切断される可能性がありました。
  悪意あるピアは、この切断を意図的に引き起こすことで、プライベートブロードキャスト接続をノードの通常の接続と関連付け、
  [トランザクションの発信元のプライバシー][topic transaction origin privacy]を弱めることができました。
  今後は、不正な動作をするプライベートブロードキャストのピアは、そのアドレスを非推奨にすることなく切断され、
  通常のピアを非推奨にしても、同じアドレスへのプライベートブロードキャスト接続はそのまま維持されます。

- [Bitcoin Core #36284][]は、`-avoidpartialspends`オプション（[ニュースレター #6][news6 avoidpartial]参照）または
  ウォレットの`avoid_reuse`フラグ（[ニュースレター #52][news52 avoid reuse]参照）によって部分的な使用の回避が有効になっている場合に、
  適格な資金が十分にあるにもかかわらずウォレットが支払いを拒否する可能性があったバグを修正します。
  部分的な使用の回避は、[コイン選択][topic coin selection]の際に同じアドレスに支払われたアウトプットをグループ化して、
  [アウトプットのリンク][topic output linking]を減らします。これまでは、
  グループが適格性チェック（未承認の祖先の制限など）に失敗すると、
  その金額が選択可能な金額から2回差し引かれていました。今後は、拒否された各グループの金額は1回だけ差し引かれます。

- [Bitcoin Core #35752][]は、ウォレットの暗号化、暗号化パスフレーズの変更、
  秘密鍵の追加を行う際のエラー処理を修正します。これまでは、データベースへの書き込みが失敗しても、
  パスフレーズの変更が成功したように見えることがありましたが、
  ウォレットを再ロードした後は古いパスフレーズしか機能しませんでした。また、暗号化処理は、
  必要な鍵レコードが欠落していたり、平文の秘密鍵がデータベースに残っていたりしても成功を報告することがあり、
  データベースのコミットに失敗するとBitcoin Coreが終了することもありました。秘密鍵の挿入に失敗すると、
  鍵がメモリ内にのみ残り、再ロード時にウォレットから消えてしまうことがありました。今後は、
  ウォレットはデータベース操作をチェックし、失敗した暗号化の更新をロールバックし、
  対応する書き込みが成功した後にのみメモリ内の鍵を更新するため、失敗した操作を再試行できるようになります。
  またこのPRは、パスフレーズの変更に失敗した際に、それまでロックされていたウォレットがアンロックされたままになることを防ぎ、
  データベースや暗号化の失敗を、パスフレーズの誤りのエラーとは区別して報告するようにします。

- [Bitcoin Core #35813][]は、ウォレットが把握しているすべてのトランザクションを一覧表示できる
  `listrawtransactions`ウォレットRPCを追加します。このRPCは、トランザクションごとに1つのエントリーを、
  そのトランザクションの16進数とともに返します。既存の`listtransactions`
  RPCは会計上のエントリーを返します。つまり、受信アドレスへの自己送金は送金と受け取りの両方として表示される場合があり、
  すべてお釣りアドレスへ送られる送金は省略される場合があります。`count`パラメーターと
  `skip`パラメーターでページネーションが可能で、`verbose`を指定するとデコードされたトランザクションの詳細が追加されます。

- [BIPs #2276][]および[#2277][bips #2277]は、
  後の署名やトランザクションの抽出に必要な情報を破棄してしまう可能性があった[PSBT][topic psbt]のファイナライズのルールを修正します。
  前者は、[サイレントペイメント][topic silent payments]のインプットをファイナライズする際に
  `PSBT_IN_WITNESS_UTXO`を削除するという[BIP376][]の要件を削除します（[ニュースレター #401][news401 bip376]参照）。
  同じトランザクション内の他の[Taproot][topic taproot]インプットが、署名の計算のために、
  その使用済みアウトプットの金額とスクリプトを引き続き必要とする場合があるためです。後者は、
  PSBTv2のインプットがファイナライズされた後も、前のアウトプットの識別子、シーケンス番号、
  必須の[ロックタイム][topic timelocks]を保持するよう[BIP370][]を更新します。これらのフィールドを削除すると、
  PSBTが無効になったり、抽出されるトランザクションが変わってしまったりする可能性がありました。
  また、インプットのファイナライズ時にアウトプットのTaproot導出データを削除するという[BIP371][]の誤った指示も削除します。

- [LDK #4993][]は、未承認の[スプライシング][topic splicing]と競合するトランザクションで、
  ウォレットが確保済みのインプットを使用してしまう可能性があったバグを修正します。これまでは、
  チャネルが既に強制閉鎖されていることを理由にLDKが[RBF][topic rbf]による手数料引き上げのコントリビューションを拒否した場合、
  元のスプライシングでまだ必要なインプットを解放するようウォレットに指示することがありました。また、
  手数料引き上げの試行を繰り返す中で、ウォレットが重複した解放指示を受け取ったり、
  不要になった後も確保し続けたりすることもありました。今後は、各ファンディングコントリビューションが、
  以前の試行から引き継いだインプットとアウトプットを記録するようになり、
  失敗時にはそのコントリビューション自身の確保のみを解放するようウォレットに指示します。このPRではさらに、
  アプリケーションが失敗したコントリビューションを安全に再試行できるよう、エラー情報と予約の照会機能も追加されています。

- [LND #11173][]は、無効またはサイズが大きすぎるチャネル範囲のレスポンスによって、
  [チャネルアナウンス][topic channel announcements]の初期同期が次回の予定された試行まで停止する可能性があったバグを修正します。
  LNDは、レスポンスをクエリごとに合計100,000個のSCID（Short Channel ID）に制限しています（[ニュースレター #417][news417 scids]参照）。
  今後は、他に適格なピアが利用可能な場合、LNDは直ちにそのピアとの同期を再試行し、
  失敗したピアを一時的に選択対象から除外します。失敗したピアとの既存の接続は開いたままになります。

- [LND #11190][]は、複数のペイメントハッシュ（`p`）フィールドを含む[BOLT11][]インボイスを、
  ハッシュが同一であっても拒否するようLNDを更新します。これまでLNDは、BOLT11の仕様で推奨されているとおり、
  サポートされている最初のペイメントハッシュを使用し、残りを無視していました。しかし、
  他のインボイスパーサーは別のハッシュを選択する可能性があります。
  サービスのインボイスパーサーとライトニングノードが異なるハッシュを使用すると、
  サービスが完了済みの引き出しを未払いと誤って解釈し、結果として2回支払いが行われる可能性があります。
  重複を拒否することで、この曖昧さが解消されます。BOLT11は既に、
  インボイスの作成者に対して`p`フィールドをちょうど1つ含めることを要求しています。[BOLTs #1357][]は、
  読み取り側に重複の拒否を要求することを提案しています。

- [LND #11212][]は、レガシーコミットメントフォーマットを使用した新規チャネルの開設および受け入れのサポートを削除し、
  [BOLT2][]に準拠させます（[ニュースレター #305][news305 commitments]参照）。レガシーコミットメントでは、
  取引相手に支払うアウトプット（`to_remote`）の鍵を、
  コミットメントごとのポイント（per-commitment point）を使用して導出します。そのため、
  ノードがチャネルの状態を失った場合、ピアのコミットメントトランザクションから資金を回収するには、
  そのピアに欠落しているポイントを提供してもらう必要があります。
  静的リモート鍵（Static Remote Key）チャネルは、チャネルの更新をまたいでこのアウトプットの鍵を変更せずに維持するため、
  この依存関係を回避できます（[ニュースレター #67][news67 static remote key]参照）。
  既存のレガシーチャネルは引き続き使用できます。Eclairは昨年、同じ変更を行っています（[ニュースレター #378][news378 eclair legacy]参照）。

- [LND #11258][]は、送信側チャネルが閉鎖され、そのレコードがクリーンアップされた後にLNDが再起動すると、
  転送された[HTLC][topic htlc]が未解決のままになる可能性があったバグを修正します。これまでは、
  チャネルのクリーンアップによって、受信した決済または失敗のレスポンスが、
  受信側チャネルに確定（ロックイン）される前に削除されることがありました。これにより、
  受信側のHTLCがスタックしたままになり、受信側チャネルの不要な強制クローズと追加のオンチェーン手数料が発生する可能性がありました。
  今後LNDは、保留中のレスポンスをクローズされたチャネルとは別に保存し、
  それらを受信側のHTLCと照合するために必要な情報を保持し、起動時にそれらを再実行します。

{% include snippets/recap-ad.md when="2026-10-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3264,29278,35984,35301,36312,36284,35752,35813,11173,11190,1357,11212,11258,2276,2277,4993" %}

[mm eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-0/2914
[news407 eclair]: /ja/newsletters/2026/05/29/#eclair-v0-14-0
[smite repo]: https://github.com/lnfuzz/smite
[label sync ml]: https://groups.google.com/g/bitcoindev/c/p6UUOdGi9YI
[news215 label]: /ja/newsletters/2022/08/31/#wallet-label-export-format
[news421 pqout]: /ja/newsletters/2026/09/04/#pqc
[news403 pqout]: /ja/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news393 p2mr]: /ja/newsletters/2026/02/20/#bips-1670
[ar delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/18
[c delving pqout deriv]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/20
[pw delving pqout cisa2]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/22
[ap delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/32
[c delving pqout both]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/38
[c delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875
[eh delving stark]: https://delvingbitcoin.org/t/post-quantum-signatures-and-scaling-bitcoin-with-starks/1584
[news383 sphincs]: /ja/newsletters/2025/12/05/#slh-dsa-sphincs
[news412 stark]: /ja/newsletters/2026/07/03/#slh-dsa-stark
[news417 pqwit]: /ja/newsletters/2026/08/07/#segwit
[jn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/8
[zmn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/4
[pw delving timewarp]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899
[news316 timewarp]: /ja/newsletters/2024/08/16/#testnet4
[news216 presync]: /ja/newsletters/2022/09/07/#bitcoin-core-25717
[lw delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877
[lw ml vaults]: https://groups.google.com/g/bitcoindev/c/Tv4k9kK5KYA
[vault report]: https://raw.githubusercontent.com/Skyler-Cloud/Bitcoin-Vault-Comparison/main/bitcoin-vault-comparison.pdf
[askii delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877/4
[news291 cat vault]: /ja/newsletters/2024/02/28/#op-cat-vault
[jl delving depots]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892
[depots paper]: https://github.com/JohnLaw2/ln-depots/blob/main/depots_v1.0.pdf
[jl delving depots recover]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892/10
[news329 opr]: /ja/newsletters/2024/11/15/#mad-opr
[LND v0.21.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.4-beta.rc1
[LND v0.20.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.5-beta.rc1
[news54 maxtxfee]: /en/newsletters/2019/07/10/#bitcoin-core-16257
[news207 single]: /ja/newsletters/2022/07/06/#rust-bitcoin-1024
[news388 private broadcast]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[news106 discouragement]: /en/newsletters/2020/07/15/#bitcoin-core-19219
[news6 avoidpartial]: /en/newsletters/2018/07/31/#bitcoin-core-12257
[news52 avoid reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
[news305 commitments]: /ja/newsletters/2024/05/31/#bolts-1092
[news378 eclair legacy]: /ja/newsletters/2025/10/31/#eclair-3173
[news67 static remote key]: /ja/newsletters/2019/10/09/#lnd-3365
[news415 silent]: /ja/newsletters/2026/07/24/#libsecp256k1-1765
[news417 scids]: /ja/newsletters/2026/08/07/#lnd-10992
[LDK #4993]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/4993
[news401 bip376]: /ja/newsletters/2026/04/17/#bips-2089
