---
title: 'Bitcoin Optech Newsletter #430'
permalink: /ja/newsletters/2026/11/06/
name: 2026-11-06-newsletter-ja
slug: 2026-11-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、家庭用ルーターの背後にあるノードを到達可能にするために
TCPホールパンチングを利用することに関する継続的な議論と、
コベナンツをエミュレートする際に共同署名者が適用する支払いポリシーを標準化するBIPドラフトを掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する提案と議論、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **ホームノードのためのTCPホールパンチングに関する議論の継続:**
  家庭用ルーターの背後にあるノード同士が互いの接続を受け入れられるようにするためにホールパンチングを利用するという
  0xB10CによるDelving Bitcoinスレッドについての5月の[まとめ][news406 holepunch]に続き、0xB10Cは、
  仕様と実験的なBitcoin Core実装の作業が再開されたことを[投稿しました][b10c holepunch recap]。
  ホームノードは通常、アウトバウンド接続しか行えず、Bitcoin Core 30.0で
  NAT-PMPによるポートマッピングをデフォルトで有効にしても、期待されたほど多くのノードが到達可能にはなりませんでした。
  ホールパンチングは、2つのホームノードが同時に互いへの接続を開始し、
  それぞれのルーターが相手のトラフィックを通過させるようにする手法で、
  ポートフォワードを補完する手段となります。到達可能な誠実なノードが増えれば、
  外部から接続しやすいノードを持つ攻撃者が、ターゲットとなるノードのアウトバウンド接続スロットを埋め尽くすことが難しくなります。

  0xB10Cはこれまでに議論された4つの設計を振り返り、コーディネーターを必要としない新しい選択肢を[提案しました][b10c holepunch option6]。
  この設計では、ノードはホールパンチ可能なアドレスと一時的な公開鍵を新しい[addr v2][topic addr v2]メッセージ形式でアナウンスし、
  各ノードペアは共有シークレットと新しいブロックごとに、同じ候補リストとホールパンチングのタイミングを導出します。
  攻撃者が実在するアドレスでこの方式を溢れさせることができるというAnthony Townsの異論を受け、
  さらにその後、到達不能なノードはリスニングノードに比べてこうしたアナウンスを受信できる確実性がはるかに低いことが判明したため、
  彼は、ピアを探しているホームノードの検証済みアドレスをリスニングノードが保持する「掲示板」方式の代替案も示しました。

  Townsは、ランダムなインバウンド接続がそもそもホームノードの役に立つのか疑問を呈し、
  ホールパンチングは攻撃者が誠実なノードに直接到達することを容易にする一方で、
  誠実なノードへの接続を保証することにはほとんど役立たないと[主張しました][aj holepunch goals]。
  彼は、約10,000個のアドレスをアナウンスする攻撃者は、大半の誠実なノードにとって早い段階でマッチする相手になると見積もり、
  より低リスクな代替案としてランダムなピアとの短時間の接続を提案しました。Jonathan Harvey-Buschelは、
  誠実なノードは攻撃者が制御するノードよりも到達可能性が低いことを示すデータを引用し、
  ノード自身の[Tor][topic anonymity networks]サービスを介した調整を支持しました。その後Townsは、
  最近のTCPやプロトコルの脆弱性を踏まえると、ホームユーザーにとってはインバウンド接続を受け入れないことの方が
  安全なデフォルトなのではないかと[問いかけました][aj holepunch cves]。議論は継続中です。

- **共同署名者の支払いポリシーを標準化するためのBIPドラフト:** Luke Carriereは、
  [コベナンツ][topic covenants]をエミュレートする際に共同署名者が適用する支払いポリシーを標準化する提案について、
  Delving Bitcoinに[投稿しました][cosigner pols del]。Johan Halsethの[ブラインド共同署名者][news412 blinded cosigners]や
  [チェーンコードの委任][news364 delegation]など、最近のいくつかの設計はそれぞれ独自のポリシーを定義しているため、
  ある設計向けに構築されたウォレットは、別の設計向けに構築された共同署名者やオラクルを使用できません。
  Carriereはこの[ドラフト][cosigner pol draft]についてBIP番号を求めてはおらず、
  標準化するレイヤーとしてここが適切かどうかを問いかけています。

  ドラフトは以下のいくつかの設計原則に従っています:

  - Bitcoin Scriptで適用できるものはすべてScriptで適用しなければならず、
    共同署名者のポリシーはScriptで適用できないものだけを定義します。

  - 共同署名者を必要としない支払いパスが少なくとも1つ常に利用可能でなければなりません。

  - 共同署名者が支払いをどのように検証するか、そしてその誠実性を何が担保するかは、
    ポリシーごとに選択する差し替え可能なプロファイルとします。

  - 既存のオラクルを変更なしで再利用できるように、
    共同署名者は[DLC][topic dlc]形式のオラクルのアテステーションを受け入れなければなりません。

  ポリシーは5つの要素で構成されています。アウトプットは資金を保持する[Taproot][topic taproot]ディスクリプターを定義し、
  共同署名者グループはどの共同署名者が参加し、何人が署名しなければならないかを示し、
  テンプレートは共同署名者が署名できるトランザクションをその正確なアウトプットとともに列挙し、
  条件は各テンプレートに署名する前に何が成立していなければならないかを定め、
  プロファイルは検証モード、証拠の形式、および不正時の責任追及の仕組み（もしあれば）を指定します。
  シリアライゼーションにJSONとTLVのどちらを使うか、ブラインド検証を今仕様に規定すべきか、
  それとも実装経験がさらに蓄積されるまで待つべきか、ステートメントのアテステーション形式をこの提案で規定するかDLCの仕様で規定するか、
  フォールバックパスにタイムロックを必須とするかなど、いくつかの点は未解決のままです。

  その後の議論で、PREDGEは、`statement-v0`と呼ばれる証拠プロファイルの1つにファイナリティフラグがないため、
  共同署名者が後で訂正される暫定的なアテステーションに基づいて行動してしまう可能性があると指摘しました。
  さらにtehiyaduは、異なる実装が同じバイト列を受け入れながら異なる条件を適用することを防ぐために、
  ポリシーハッシュは正確な検証者のセマンティクスにコミットすべきだと述べました。
  Carriereは両方の指摘に同意し、ファイナリティフラグを追加し、検証者のルールを厳密に定めると述べました。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **BIP54に関する議論の継続**: Antoine Riardは、
  [コンセンサスクリーンアップ][topic consensus cleanup]ソフトフォーク（[BIP54][]）の現状に関する自身の見解を
  Bitcoin-Devメーリングリストに[投稿しました][ar ml bip54]。witnessを除いたサイズが
  ちょうど64 byteのトランザクションを禁止するルールが、依然として最も議論の多いルールです。
  Bitcoin Coreの実装がレビューとテスト中で、BIPからリンクされているリファレンス実装となっています（[Bitcoin Core #35793][]）。
  このPRはregtestで新しいルールを有効にするもので、mainnetでのアクティベーションは含まれません。彼はまた、
  btcdでの相互運用性の作業（[btcd #2537][]）にも言及し、libbitcoinの実装については把握していないと述べました。
  彼の見解では、残っているのは、さらなるレビューとテスト、segwit以前のScriptにおける署名操作数を2,500に制限する提案と
  64 byteルールについてウォレットが把握できるようにするためのドキュメント、
  そしてその後でアクティベーションロジックです。あくまで個人的な見解として、コミュニティがそれまでに合意すれば、
  2027年後半にアクティベーションの検討を開始するのは現実的かもしれないと述べました。

  Pieter Wuilleは、BIP54の2つのタイムスタンプルールがチェーン長をどのように制限するかに関する
  Delving Bitcoinのスレッドを[更新しました][pw delving timewarp lean]（[ニュースレター #425][news425 timewarp]参照）。
  最初の投稿には現在、作業量の下限を求める正確な式が含まれており、その式と10進数近似の両方が、
  リンクされたLeanコードで証明されるようになりました。

  Riardは、BIP54の設計中に提起された懸念点について[フォローアップしました][ar ml forwardblocks]。
  それは、[タイムワープ][topic time warp]バグを修正すると、Mark Friedenbachが提案した
  [フォワードブロック][news16 forward]のようなスタイルのコンセンサス変更が、将来にわたって不可能になるというものです。
  今回の修正はタイムスタンプの操作を排除するのではなく制限するものであるため、
  より限定的なフォワードブロックの提案であれば依然として実装可能です。彼は、
  修正後も許容される7,200秒のウィンドウ幅によって、難易度調整期間ごとに難易度を約0.60%下げ、
  ブロックレートをほぼ同程度上げることができると見積もりました。これは、
  元の提案による容量の拡大には遠く及びません。Riardはまた、
  このアイディアは従来ルールのもとでも健全ではないと主張しました。検証者は、
  トランザクションをフォワードチェーン上で一度処理し、互換チェーンに同期される際に再度処理することになりますが、
  ユーザーが二重に支払わない限り手数料は同じであり、アップグレードしていないノードも追加データをダウンロードしなければなりません。
  Riardは、この主張を述べた短い脚注をBIP54に追加することを提案し、Friedenbachに反論を求める予定です。

- **<!--opt-in-replay-protection-prototype-->オプトインのリプレイ保護プロトタイプ**:
  Sjors Provoostは、チェーン分岐時のオプトインのリプレイ保護に関する
  Delving Bitcoinのスレッド（[ニュースレター #420][news420 replay]参照）で、
  新しいwitnessバージョンを使用するプロトタイプについて[提案しました][sj delving replay]。
  ペイロードが0x01で始まる[annex][topic annex]を用いて特定のブロックを4 byteのブロック高で指定し、
  インプットに含まれるすべての署名が、意図したチェーン上のそのブロックのハッシュにコミットします。
  ハッシュ自体はトランザクション内には含まれません。彼は追加コストを1.75 vbyteとしています。
  指定されるブロックは、コインベースの成熟期間と同じく、少なくとも100ブロック前のものでなければなりません。
  彼は、ハッシュレートが均等に分かれた場合でも、ルールは片側でのみ成立すればよいため、
  コインを分割できるまでの待ち時間は最長でも2日になると述べました。彼は、このwitnessバージョンを、
  [CISA][topic cisa]（BIP460）、[BIP360][]、後からキーパスを無効化できる[P2TRv2][news403 pqout]スタイルのアウトプットなど、
  新しいwitnessバージョンを必要とする別の提案と一緒にリリースすることを提案しました。

  Anthony Townsは、新しいwitnessバージョンは不要で、[BIP118][]のようなスタイルで、
  Taprootの署名チェック用の新しい公開鍵エンコーディングがあれば十分だと[返信しました][aj delving replay]。
  Provoostは、そのエンコーディングは検討したもののハックだと考えており、
  自身の理解ではキーパスによる支払いでは機能しないと[答えました][sj delving replay keypath]。

  Moonsettlerは、この機能が最も重要となる分岐において100ブロックを要求することが望ましいのか[疑問を呈し][ms delving replay]、
  その遅延を緩和可能なポリシールールとして維持することを提案しました。Provoostは、
  より速い側でコインが移動して承認を得た後は、遅い側ではもはや保護が必要ないと[返信しました][sj delving replay maturity]。
  Provoostはまた、このルールは論争的なハードフォークの前にデプロイされ、両方の側がそれを継承することを想定しており、
  どちらの側も簡単にはそれを取り除けないと書きました。ブロックハッシュは署名メッセージにのみ含まれるため、
  ルールを削除するには、ハッシュを含めるようにトランザクションのシリアライゼーションを変更する必要があるためです。

- **未移行のコインのためのQSAVE**: James Taggは、コインを焼却することなく
  [ポスト量子][topic quantum resistance]環境に移行するQSAVE（Quantum Secure Asset Verification and Escrow）の
  [5つのBIPドラフト][qsave drafts]を
  Bitcoin-Devメーリングリストに[投稿しました][jt ml qsave]。
  彼はこれらを[BIP361][]および[Hourglass][news395 hourglass]の代替案として位置づけています。
  ソフトフォークとしていつでもアクティベート可能な適用開始ブロック高を設定し、それ以降、
  既知のポスト量子タイプのレジストリに含まれないインプットは、未知のScriptタイプや将来のScriptタイプも含め、
  すべて未移行として扱われます。未移行のインプットは、引き続きロックスクリプトを満たす必要があるのに加え、
  第2の要素も必要とします。それは、同一のシードから使用対象のスクリプトとポスト量子鍵の両方が導出されることを示すゼロ知識証明、
  あるいは期限（カットオフ）前にコミットされたポスト量子バインディングのいずれかです。
  トランザクション内の未移行のインプットのいずれかにこの第2の要素がない場合、
  使用可能なすべてのアウトプットはリカバリーアウトプットでなければなりません。
  QSAVEには期限切れ（サンセット）の概念がないため、第2の要素がなくてもコインが破棄されることはありません。
  オンチェーンの証明があれば、第三者なしでいつでも直接使用できます。それ以外の場合について、
  彼はオフチェーンの遺失物処理プロセスについても言及しました（その法的・経済的な扱いはコンセンサスの範囲外としています）。
  このプロセスでは、分散型のカストディアンのセットが、バックアップカストディアンと拒否権を持つコントローラーとともに
  リカバリーアウトプットを保持し、さらにその資金から得られる0.5%程度の保守的な運用益は慈善事業に充てられる仕組みとなっています。
  ドラフトでは、カットオフ前のウォーターマーク、彼がQD5と呼ぶオプションのML-DSA-87鍵および
  [BIP360][]（[P2MR][news393 p2mr]）アウトプット用のzk-STARK支払いリーフの仕様も規定されています。

- **未移行のアウトプットに対するProof-of-decay**: bitKingAEは、
  初期のP2PKコインのように[ポスト量子][topic quantum resistance]の脅威にさらされるアウトプットのうち、
  猶予期間内に移動されないものを縮小させるスケッチをDelving Bitcoinに[投稿しました][bk delving decay]。
  猶予期間が終了すると、アウトプットの金額はブロック高に応じたスケジュールで段階的に減少します。
  失われたsatoshiは、コインを凍結したり署名を作成できる人に委ねたりするのではなく、
  焼却されるかマイニング報酬として支払われます。投稿の例では、50,000ブロックごとに残高の数パーセントを減少させるものでした。
  Vinicius Cestariは、3つの異論を[返信しました][vc delving decay]。量子攻撃者は猶予期間の終了を待ち、
  減衰が大きく進む前に脅威にさらされたアウトプットを奪取できること、
  量子攻撃の急激な進歩があればさらに早く資金を奪えること、そしてこの仕組みは、すでに鍵を盗まれた所有者を含め、
  何もしない所有者の残高を減少させてしまうことです。

- **BIP300のバンドル検閲**: Ori Newmanは、[ドライブチェーン][topic sidechains]の提案（[BIP300][]）において、
  ハッシュレートの26%を持つマイナーが有効な引き出しバンドルを無期限に検閲できると
  Bitcoin-Devメーリングリストで[主張しました][on ml bip300]。彼によれば、
  26%のマイナーが、自身がマイニングするすべてのブロックでALARMを送信すると、
  それらのブロックはそれぞれ保留中のすべてのバンドルのスコアを1ずつ下げます。
  残りの74%のハッシュレートがすべてのブロックで特定のバンドルに対して賛成票を投じたとしても、
  26,300ブロックのウィンドウの終了時点でのスコアの期待値は12,624となり、必要な13,150に届きません。彼は、
  ALARMおよびその他の反対票を禁止することを提案しました。これにより誠実な多数派の前提が回復し、
  ハッシュレートの51%に支持されたバンドルはほぼ確実に承認され、49%の支持しか得られないバンドルはほぼ確実に否認されます。
  現在のルールが意図的なものである場合は、代わりにBIPに「75%の誠実な多数派の前提」を明記するよう求めました。
  彼はこれをBitcoinのセキュリティモデルからの大きな逸脱だとしつつも、この前提を支持する根拠の1つとして、
  ハッシュレートが75%未満の攻撃者にとっては資金を盗むことがより困難になる点を挙げました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.21.6-beta][]および[v0.20.7-beta][lnd v0.20.7-beta]は、この人気のLNノード実装の
  0.21ブランチと0.20ブランチのセキュリティリリースです。どちらにも、
  以下の[LND #11456][]で説明するLinuxカーネルの脆弱性CVE-2026-98432の緩和策が含まれています。
  LNDの緩和策では根本的な脆弱性は修正されないため、Linuxのオペレーターはアップグレードに加えて、
  他のサービスを保護するためにホストでMPTCPを無効にし、パッチが適用されたカーネルをインストールする必要があります。

- [Core Lightning 26.06.10][]は、この人気のLNノード実装のセキュリティリリースです。
  [デュアルファンディング][topic dual funding]、[スプライシング][topic splicing]、
  オンチェーンでの[HTLC][topic htlc]の解決、アクセス制御、その他のコンポーネントの脆弱性が修正されています。
  セキュリティ修正のソースコードは公開されていますが、ユーザーがアップグレードする時間を確保するため、
  関連するテストは一時的に非公開となっています。プロジェクトはアップグレードを強く推奨しています。

- [BTCPay Server 2.4.7][]は、このセルフホスト型ペイメントプロセッサーのセキュリティリリースです。
  支払い上限、他のストアのデータへのアクセス、認証、リソース枯渇に影響する問題を含む、
  Anthropicの[OSS Scannerプログラム][anthropic oss scanner]によって報告された
  85件のセキュリティ上の問題が修正されています。また、支払いの会計処理と信頼性の問題も修正されています。
  特に複数のマーチャントで共有されているサーバーでは、アップデートが強く推奨されます。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #36539][]は、GUIからエクスポートされる未署名トランザクションおよび手数料の引き上げについて、
  PSBTv0形式を復元しました。Bitcoin Core 32.1では、これらの[PSBT][topic psbt]をバージョン2でエクスポートしていたため、
  ユーザーはバージョン0のみをサポートするツールで署名できませんでした。
  `-signer`で設定される別の外部署名者のワークフロー（[ニュースレター #138][news138 signer]参照）は、
  引き続きPSBTv2を使用するため、それらのユーザーはHWI 2.1.0以降など、PSBTv2をサポートする外部署名者が必要です。

- [Bitcoin Core #35714][]は、ブロックデータまたはundoデータのディスクへのフラッシュに失敗した後に、
  ノードがブロックインデックスとUTXOデータベースを更新する可能性があったバグを修正しました。
  この失敗によってノードにはシャットダウンが通知されますが、これらの書き込みを処理するコードが、
  ノードが停止する前にデータベースを更新してしまう可能性がありました。これらの更新が成功した場合、
  裏付けとなるブロックデータまたはundoデータがまだ安全に保存されていない状態をデータベースが記録してしまう可能性がありました。
  これにより、ノードのローカル状態に不整合が生じ、復旧が困難になる可能性がありました。現在は、
  失敗したフラッシュの試行中はこれらのデータベースへの書き込みをスキップします。これは、
  [ニュースレター #414][news414 flush]で取り上げた、オプションのインデックスに対する以前のフラッシュ順序の保護を補完するものです。

- [Bitcoin Core #35492][]は、`bitcoin-wallet dump`（[ニュースレター #130][news130 dump]参照）が、
  不完全なウォレットのエクスポートを書き込んだ後に成功を報告する可能性があったバグを修正しました。これまでは、
  このコマンドは出力先のファイルを開けるかどうかはチェックしていましたが、ディスク容量の不足など、
  その後の書き込みの失敗を検出していませんでした。その結果、ユーザーはエクスポートが完了したと誤解し、
  ウォレットを復元しようとした際にデータの欠落に気付くことになる可能性がありました。現在は、ファイルの書き込み、
  フラッシュ、クローズを検証するようになりました。失敗を報告し、不完全なダンプファイルを削除します。

- [BIPs #2205][]、[#2210][bips #2210]および[#2212][bips #2212]は、
  [クロスインプット署名集約][topic cisa]（CISA）に関する3つのドラフト仕様を追加しました。[BIP458][]は、
  非対話型のハーフアグリゲーションを規定しており、`n`個の既存の[BIP340][]署名を、
  `64 × n` byteではなく`32 × (n + 1)` byteに結合します。[BIP459][]は、
  複数の鍵とメッセージに対して単一の64 byteの集約署名を生成する対話型プロトコルであるDahLIASを規定しています。
  [BIP460][]は、新しいwitnessバージョン2のアウトプットのキーパスによる支払いにこれらのスキームを使用することを提案しており、
  スクリプトパスによる支払いでは個別の署名を維持し、キーパスのインプットがオプトアウトできるようにしています。
  この提案が[ニュースレター #417][news417 cisa]で取り上げられて以降、
  オプトアウトしたインプットは特別なマーカーなしで通常の[BIP341][]署名を使用するよう変更され、
  ウォレットは既存の署名ロジックを再利用しながら新しいアウトプットタイプを採用できるようになりました。
  これにより、[coinjoin][topic coinjoin]や[payjoin][topic payjoin]など、
  複数のインプットが参加するトランザクションのweightと手数料が削減されます。
  提案されたトランザクションの集約をデプロイするにはソフトフォークが必要です。BIP460では、
  アクティベーションのメカニズムとパラメーターは規定されていません。

- [Core Lightning #9419][]は、ローカルで失敗した転送の試行について、`listforwards`
  RPCと`forward_event`通知にオプションの`failure_reason`フィールドを追加しました。これまでは、
  複数の異なる問題が同じプロトコルの失敗コードを共有していたため、オペレーターが転送の失敗理由を判断するのは困難でした。
  新しいフィールドは、アウトバウンドの流動性の不足、送信先ピアのオフライン、
  保留中の[HTLC][topic htlc]の数または合計額の制限などの原因を区別します。

- [Core Lightning #9592][]は、`xpay`（[ニュースレター #330][news330 xpay]参照）を更新し、
  転送ノードが`unknown_next_peer`を2回返した後は、その支払いの残りでそのノードを回避するようにしました。
  これまでは、失敗ごとに報告されたチャネルのみが除外されていたため、支払いのリトライ時間が切れるまで、
  後続の試行で同じノードを経由する別のチャネルが選択され続ける可能性がありました。現在は、
  同じノードからの2回目の失敗後、`xpay`は支払いのプライベートな`askrene`ルーティングレイヤーを通じてそのノードを除外します。
  このヒューリスティックは使用可能なチャネルを除外してしまう可能性がありますが、同じノードを経由した試行の繰り返しを制限します。

- [LDK #5089][]は、[アンカーアウトプット][topic anchor outputs]を持つチャネルの
  強制閉鎖時の手数料の引き上げを更新しました。アンカーアウトプットを使用する[CPFP][topic cpfp]の
  子トランザクションに必要な資金をLDKが取得できない場合、コミットメントトランザクションのみをブロードキャストするようになりました。
  これまでは、この失敗によって両方のトランザクションがブロードキャストされないままとなり、
  チャネル資金の回収が遅れる可能性がありました。コミットメントにはすでに手数料が含まれているため、
  手数料の推定が保守的だった場合やネットワークの需要が減少した場合には、承認に十分な場合があります。ただし、このフォールバックは、
  リレーに手数料を支払う子トランザクションを必要とする[ゼロ手数料のコミットメントトランザクション][topic v3 commitments]には適用されません。
  この問題はProject Loupeによって報告されました。

- [LND #11456][]は、MPTCPを使用したリモートコード実行が実証されたLinuxカーネルの脆弱性
  [CVE-2026-98432][mptcp advisory]を緩和するため、
  Multipath TCP（MPTCP）リスナーをデフォルトで無効にしました。Go 1.24以降では、
  サポートされているLinuxシステムでこれらのリスナーがデフォルトで有効になっているため、
  LNDのオペレーターはMPTCPを明示的に設定していなくても脆弱性にさらされる可能性がありました。この変更により、
  LNDのGoのデフォルト設定で`multipathtcp=0`が設定されます。これにより、
  LNDのリスナーを経由する実証済みのエクスプロイトの経路はブロックされますが、
  根本的なカーネルのバグは修正されません。影響を受けるシステムには、引き続きパッチが適用されたカーネルが必要です。
  既存のバイナリを使用しているオペレーターは、環境変数`GODEBUG=multipathtcp=0`を指定してLNDを再起動することで、
  同じ緩和策を適用できます。

- [LND #11357][]は、[BOLTs #1357][]（[ニュースレター #428][news428 bolts11]参照）に従って、
  [BOLT11][]インボイスの検証を厳格化しました。最初のフィールドを使用して残りを無視するのではなく、
  重複したペイメントシークレットフィールドを拒否するようになり、異なる出現箇所を選択するパーサー間での曖昧さを防止します。
  これは、以前の重複したペイメントハッシュの拒否（[ニュースレター #425][news425 lnd]参照）を基にしたものです。
  仕様の更新で追加されたテストにより、既存の要件が適用されていなかったことも明らかになりました。
  デコーダーは、ペイメントハッシュ、description hash、ペイメントシークレット、受信者の公開鍵をパースする際に、
  これらのフィールドを存在しないものとして扱うのではなく、不正な長さを拒否するようになりました。これまでは、
  サイズが不正な受信者の公開鍵フィールドがあると、LNDが署名から鍵を復元する処理にフォールバックする可能性がありました。
  明示的な受信者の公開鍵を含むインボイスについては、low-SのECDSA署名も必須となります。ただし、
  公開鍵が署名から復元される場合には、この制限は適用されません（[ニュースレター #381][news381 low-s]参照）。

- [LND #11413][]は、SQLiteまたはPostgreSQLを使用するノードにおいて、
  保存された送信支払いの結果の起動時のクリーンアップを高速化しました。通常の運用中、
  ノードはローカルで開始され解決された[HTLC][topic htlc]の試行ごとに結果を蓄積します。起動時には、
  不要になった結果を削除します。これまでは、エントリーを個別に読み取って削除するためにデータベースとの往復が繰り返し必要で、
  リモートのPostgreSQLを使用している負荷の高いノードでは、クリーンアップに数時間かかる可能性がありました。
  現在は、保留中の支払いを再開するのに必要な結果を保持しつつ、データベース操作をバッチ処理するようになりました。

- [LND #11151][]は、インバウンドのチャネルを受け入れる際に、
  過剰なコミットメントの手数料率と不十分な初期残高のチェックを追加しました。LNDは、
  [3ブロックの推定値][topic fee estimation]の10倍と100 sat/vbyteのいずれか大きい方を上回る手数料率の提案を拒否するようになりました。
  また、[BOLT2][]の初期リザーブのルールを適用し、それとは別に、
  どちらの当事者の初期残高もその当事者が維持すべきリザーブを超えていないチャネルを拒否します。
  コミットメントの手数料はチャネルの開設者が支払いますが、過剰な手数料は開設者の使用可能な残高を消費する可能性があり、
  開設中に受信者の保留中チャネルのキャパシティを浪費させ、ファンディングトランザクションが承認されると使用できないチャネルが残ることになります。
  これは、[ニュースレター #429][news429 lnd fees]で取り上げた最低手数料率のチェックを補完するものです。

- [Rust Bitcoin #7067][]は、[Taproot][topic taproot]の署名ハッシュ（sighash）のヘルパーを拡張し、
  オプションの[annex][topic annex]と、スクリプトパスによる支払いの場合は
  署名チェックの前に最後に実行された[OP_CODESEPARATOR][topic OP_CODESEPARATOR]のopcode位置を受け付けるようにしました。
  どちらも署名がコミットするメッセージに影響します。これまでは、これらの便利な関数はannexがなく、
  `OP_CODESEPARATOR`も実行されていないことを前提としていたため、そのような支払いを処理する呼び出し元は、
  誤ったダイジェストの生成を避けるためにより汎用的なsighash関数を使用する必要がありました。
  ヘルパーはこれらの値を直接受け付けるようになりましたが、セパレーターの位置は引き続き呼び出し元が決定する必要があります。
  annexがなく、`OP_CODESEPARATOR`も実行されていない支払いを処理する呼び出し元は、
  新しい引数に`None`を渡すことで以前の動作を維持できます。レガシーおよびsegwit v0の支払いに関連するsighash APIの変更については、
  [ニュースレター #427][news427 rust bitcoin]をご覧ください。

{% include snippets/recap-ad.md when="2026-11-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35793,11456,36539,35714,35492,2205,2210,2212,9419,9592,5089,11357,1357,11413,11151,7067" %}

[news406 holepunch]: /ja/newsletters/2026/05/22/#nat-bitcoin-tcp
[b10c holepunch recap]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/18
[b10c holepunch option6]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/22
[aj holepunch goals]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/25
[aj holepunch cves]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/35
[cosigner pols del]: https://delvingbitcoin.org/t/bip-draft-co-signer-spending-policies/2955
[news412 blinded cosigners]: /ja/newsletters/2026/01/02/#vault
[news364 delegation]: /ja/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[cosigner pol draft]: https://github.com/lukecarriere/bip-cosigner-spending-policies/blob/468fdd1b75647432ed56c3a2b5579cbcfedaec74/bip-cosigner-spending-policies.md
[ar ml bip54]: https://groups.google.com/g/bitcoindev/c/TBBakeBK8_E
[btcd #2537]: https://github.com/btcsuite/btcd/pull/2537
[pw delving timewarp lean]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899/29
[news425 timewarp]: /ja/newsletters/2026/10/02/#bip54
[ar ml forwardblocks]: https://groups.google.com/g/bitcoindev/c/T9s8nflvlK0
[news16 forward]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[sj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/11
[news403 pqout]: /ja/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news420 replay]: /ja/newsletters/2026/08/28/#discussion-on-universal-opt-in-replay-protection
[aj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/12
[sj delving replay keypath]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/13
[ms delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/14
[sj delving replay maturity]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/15
[jt ml qsave]: https://groups.google.com/g/bitcoindev/c/5G38b3JL9fA
[qsave drafts]: https://www.qsave.org/legal/bip-suite
[news395 hourglass]: /ja/newsletters/2026/03/06/#hourglass-v2
[news393 p2mr]: /ja/newsletters/2026/02/20/#bips-1670
[on ml bip300]: https://groups.google.com/g/bitcoindev/c/7P0_BHRAYQI
[bk delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970
[vc delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970/2

[LND v0.21.6-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.6-beta
[lnd v0.20.7-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.7-beta
[Core Lightning 26.06.10]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.10
[BTCPay Server 2.4.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.7
[anthropic oss scanner]: https://github.com/anthropics/oss-scanner
[mptcp advisory]: https://www.openwall.com/lists/oss-security/2026/10/30/1
[LDK #5089]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5089
[news138 signer]: /ja/newsletters/2021/03/03/#bitcoin-core-16546
[news414 flush]: /ja/newsletters/2026/07/17/#bitcoin-core-34897
[news130 dump]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news417 cisa]: /ja/newsletters/2026/08/07/#taproot-cisa-bip460
[news330 xpay]: /ja/newsletters/2024/11/22/#core-lightning-7799
[news428 bolts11]: /ja/newsletters/2026/10/23/#bolts-1357
[news425 lnd]: /ja/newsletters/2026/10/02/#lnd-11190
[news381 low-s]: /ja/newsletters/2025/11/21/#bolts-1284
[news429 lnd fees]: /ja/newsletters/2026/10/30/#lnd-11373
[news427 rust bitcoin]: /ja/newsletters/2026/10/16/#rust-bitcoin-6956
