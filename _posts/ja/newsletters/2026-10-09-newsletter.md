---
title: 'Bitcoin Optech Newsletter #426'
permalink: /ja/newsletters/2026/10/09/
name: 2026-10-09-newsletter-ja
slug: 2026-10-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、バージョン2 P2Pトランスポート上でピアが自身の1 byteのメッセージタイプIDを選択できるようにするBIPドラフトのリンクや、
BIPの番号をタグ付きハッシュに含めるべきかどうかに関する議論の要約、
コンセンサスの変更を必要としないプライベートなオンチェーン送金のためのメタプロトコルの提案について掲載しています。
また、新しいリリースとリリース候補の発表、人気のあるBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **BIP324用の動的な1 byteのメッセージタイプID:** Anthony Townsは、
  各ピアが[v2 P2Pトランスポート][topic v2 p2p transport]上で送信するメッセージについて、
  自身の1 byteのメッセージタイプIDを選択できるようにするBIPのドラフトをBitcoin-Devメーリングリストに[投稿しました][towns set324alias]。
  [BIP324][]は固定テーブルから1 byteのIDを割り当てるため、
  新しいメッセージにはグローバルに調整されたエントリーが必要であるか（[ニュースレター #392][news392 bip324 ids]参照）、
  完全な12 byteのメッセージ名を使用しなければなりません。今回提案された`set324alias`メッセージを使うと、
  ノードは接続時に自身のエイリアスを通知できるため、そのような調整なしにP2Pレイヤーで新しいメッセージをデプロイし、
  実験することができます。Townsはまた、スペースの節約量はpingのみをやりとりする接続では最大66%、
  一般的な接続では約5%で、既存の1 byte IDを持たない新しいメッセージがデプロイされるまではゼロであると[述べています][towns set324alias savings]。

- **BIPにおけるタグ付きハッシュの慣例に関する議論:** Fabian Jahrは、
  [BIP340][]のタグ付きハッシュを使用するBIPにおいて、タグにBIP番号を含めるべきかどうかを問うメールをBitcoin-Devメーリングリストに[投稿しました][jahr tagged hash]。
  BIP 324、340、352、374、445は番号を含めていますが、BIP 327とBIP 341は「TapLeaf」のような説明的な名前を使用しています。
  番号は一意性を保証しますが、番号が割り当てられた際にドラフトのタグを変更すると、
  既存の実装やテストベクターが壊れてしまいます。Jahrは自身の[DahLIAS][news415 dahlias]ドラフト（BIP459）を番号付きの形式に切り替えた後に
  この問題に気づきました。Sjors Provoostは、BIP138は番号を含めており、
  そのテストベクターの再生成は小さなコストだったと[返信しました][provoost tagged hash]。

- **コンセンサスの変更なしでオンチェーンでプライベートなBitcoin送金を行う提案:** Misha Komarovは、
  コンセンサスの変更を必要とせずにプライベートな送金を可能にする、
  Shielded Bitcoinと呼ばれるBitcoin上に構築された新しいメタプロトコルの提案について
  Delving Bitcoinに[投稿しました][shield del]。Komarovは、Clara ShikhelmanおよびAleksei Moskvinとともに、
  このプロトコルを説明する完全な[論文][shield paper]を最近公開しました。

  提案されたメタプロトコルの目標は、送金額も取引に関与する取引相手も明かさずに、
  ビットコインをプライベートに送金することです。これを、信頼できるオペレーター、対話性、
  ライブネスへの依存を必要とせずに実現することを目指しています。Shielded Bitcoinには、
  メタプロトコルへのペグインおよびペグアウトの手段が必要です。このプロセスは近日公開予定の関連論文で詳述される予定ですが、
  Komarovは、PIPEsと呼ばれるウィットネス暗号（witness encryption）スキームに基づくものになると述べています（[ニュースレター #393][news393 pipes]参照）。

  Shielded Bitcoinの送金は、noteと呼ばれる所有権オブジェクトに基づいており、
  これはBitcoinのUTXOと同様の役割を果たします。noteは、金額や受取人の鍵情報などの情報を格納する暗号化されたレコードです。
  送金を行う際、アリスは、新しい暗号化されたnote、使用される各noteに対するnullifierと呼ばれる一意の番号、
  そしてnoteが存在すること、彼女がそれらを使用する権限を持つこと、
  入力の金額が出力の金額と等しいことを示す証明を含むBitcoinトランザクションを公開します。これらの証明は、
  インデクサー（indexer）と呼ばれる外部プログラムによって検証され、
  いずれのnoteも以前に使用されていないことが確認されます。証明が有効であれば、
  新しいnoteがリストに追加され、nullifierは使用済みとして記録されます。誰でもインデクサーを運用できるため、
  証明の検証を中央集権的なサービスに依存する必要はありません。

  このメタプロトコルはノンカストディアルです。ウォレットは単一のシードから異なる鍵を導出し、それぞれが、
  支出鍵、受信送金用の読み取り専用鍵、送信送金用の鍵といった固有の役割を持ちます。
  有効な支出鍵のみがnoteを送金する権限を与え、マイナー、インデクサー、外部の観察者などの第三者が資金を盗むことはできません。

  Komarovはまた、作成されたnoteの数、手数料、投稿されたデータのサイズとタイミング、
  シールド送金が発生したという事実など、外部の観察者から何が見えるかの概要も示しました。Komarovは、
  一度限りのセットアップセレモニーの必要性（これは少なくとも1つの誠実な参加者が関与する場合にセキュリティの主張が有効になります）や、
  プロトコルへの参加と離脱が可視的な痕跡を残すという事実などの制限とトレードオフについて説明しました。Komarovはまた、
  この設計を他の提案されているオンチェーンプライバシープロトコルと比較しました。たとえば、
  [CoinJoin][topic coinjoin]や[PayJoin][topic payjoin]、
  [クライアントサイド検証][topic client-side validation]に基づくアプローチを使用するShielded CSV（現在はGlass Coins）、
  そして最も近い設計で独自のチェーンを使用するZcashなどです。

  その後の議論で、ZmnSCPxjは、外部サービスが与えられると、
  リソースに制約のあるデバイスが資金を回復するためにスキャンする必要があるデータを削減できるが、
  サービスにビューイング鍵が与えられた場合、Electrumのようなプライバシーの損失というコストが伴う可能性があると指摘しました。
  また、片方向のペグアウトにウィットネス暗号スキームの条件として表現されるSPV証明が必要かどうかも尋ねました。
  共著者のClara Shikhelmanは、ペグアウトは固定された額面を使用し、
  ペグアウトに関する全情報は近日公開予定の論文で詳述される予定だと返信しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 32.0rc3][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc32 testing]が利用可能です。

- [Core Lightning 26.06.9][]は、この人気のあるLNノード実装のセキュリティリリースです。
  チャネルの再確立、[スプライシング][topic splicing]、[HTLC][topic htlc]の処理、
  アクセス制御などにおける脆弱性を修正しています。また、通常の[ゴシップ][topic channel announcements]、
  ping、[オニオンメッセージ][topic onion messages]に対してピアを誤ってスロットリングすることでチャネルのトラフィックを遅延させる可能性があった
  26.06.8のリグレッションも修正しています。セキュリティ修正を動作する悪用コードに変換することを困難にするためにそのテストは一時的に非公開となっていますが、
  ソースコードはすぐに利用可能です。プロジェクトはアップグレードを強く推奨しています。

- [LDK v0.3-rc3][]は、LN対応のウォレットやアプリケーションを構築するためのこのライブラリの次期メジャーバージョンの
  3番めのリリース候補です。保留中の[スプライシング][topic splicing]に対する[RBF][topic rbf]による手数料引き上げと、
  同一のスプライシング内での資金の追加と削除のサポートが追加されています。また、
  デフォルトで[アンカーチャネル][topic anchor outputs]をネゴシエートし、
  アプリケーションが着信チャネルを明示的に受け入れることを必須としています。アップグレードすると、
  ペイメントメタデータを含む以前発行された[BOLT11][]インボイスは無効になります。
  開発者はテストの前に[APIおよび後方互換性の変更][ldk 0.3 notes]を確認してください。

- [LDK v0.2.7][]と[v0.1.13][ldk v0.1.13]は、LN対応のウォレットやアプリケーションを構築するためのこのライブラリの
  0.2ブランチと0.1ブランチのセキュリティリリースです。どちらも、後述するチャネル再確立時の資金窃取の修正と、
  Electrumベースの同期におけるDoSの修正が含まれています。バージョン0.2.7にはさらに、
  後述する[LSPS2][BLIP52]の金額検証と古いチャネル状態の修正が含まれています。バージョン0.1.13は、
  無効な[HTLC][topic htlc]によって引き起こされるチャネルマネージャーのデシリアライズの失敗も修正しており、
  これは以前0.2.6で修正されていたものです。

- [BTCPay Server 2.4.5][]は、このセルフホスト型決済プロセッサのセキュリティリリースです。
  サーバーサイドリクエストフォージェリを防ぐため、Lightning接続、[LNURL][topic lnurl]、インボイス通知、
  webhookで使用される送信HTTPリクエストにおいて、プライベートネットワーク上の宛先をデフォルトでブロックします。
  また、インボイスと返金の権限を厳格化し、インボイス作成を高速化しています。Docker関連の変更として、
  既存のデプロイメントを含めてTorがオプトイン方式に変更されたほか、
  メンテナンスされていないいくつかの連携機能が削除されました。管理者はアップグレードし、
  [デプロイメント構成の変更点][btcpay 2.4.5 announcement]を確認することが推奨されます。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #36277][]は、実験的なオプトインのプライベートブロードキャスト機能における
  潜在的な[トランザクションの発信元のプライバシー][topic transaction origin privacy]の漏洩を修正します（ニュースレター
  [#388][news388 private broadcast]および[#425][news425 private broadcast]参照）。
  これまでは、ネットワークを通じてトランザクションを（自分宛てに）受け取り直すと、
  残りの初期プライベートブロードキャストの試行がキャンセルされていました。
  プライベートブロードキャストピアのうちの1つを制御する攻撃者は、
  その接続でのリクエストを遅延させつつ、
  別の接続を通じて発信元と疑われるノードにトランザクションを中継し返すことで、この動作を悪用できました。
  ノードがリクエストに応答する代わりに保留中のプライベート接続を閉じた場合、
  攻撃者はそのノードがトランザクションの発信元であると推測できました。今回の修正によりBitcoin Coreは、
  トランザクションがすでに伝播している場合でも、TorまたはI2P経由で3つの初回プライベートブロードキャストの試行をすべて完了するようになり、
  その後の再試行については必要に応じて停止することを許容しています。

- [Bitcoin Core #36365][]は、[mempoolベースの手数料推定機能][topic fee estimation]に関する2つの問題を修正します（
  [ニュースレター #420][news420 fee estimation]参照）。これまでは、
  既存の承認ベースの推定機能が有効な推定値を持っていても、mempoolベースの推定機能が利用できない場合に、
  統合された推定機能はエラーを返していました。今回の修正により、mempoolベースの推定機能が利用できない場合には、
  既存の推定値にフォールバックしつつ、両方が利用可能な場合は引き続き2つのうち低い方を選択します。
  このPRはまた、mempoolの読み込みに失敗した場合に、再起動直後にmempoolベースの推定機能が使用されることを防ぎます。
  これまでは、保存された健全性統計情報により空のmempoolが健全と見なされ、
  不当に低い手数料推定値が得られる可能性がありました。また、`estimatesmartfee`
  RPCのデフォルトの`fee_rate_estimator`値を`none`から`auto`に変更し、認識されない値は拒否するようになりました。

- [Bitcoin Core #36338][]は、[BIP352][] [サイレントペイメント][topic silent payments]の実装のバグを修正します。
  このバグにより、トランザクションに変更されているがコンセンサス上は有効なP2PKHインプットが含まれている場合に、
  ウォレットが支払いを見逃す可能性がありました（[ニュースレター #425][news425 silent payments]参照）。
  攻撃者は、トランザクションを無効化することなく、無効な署名と異なる公開鍵を含む条件分岐をインプットの`scriptSig`に挿入できました。
  これまでは、Bitcoin Coreは無効な署名を受け入れるダミーの署名チェッカーを使って`scriptSig`を評価し、
  その分岐を実行して誤った公開鍵を抽出していたため、その結果スキャナーが支払いを見逃す可能性がありました。
  修正後は、使用されるアウトプットにコミットされたハッシュとHASH160が一致する有効な圧縮公開鍵を`scriptSig`内から検索するようになりました。
  この実装はまだウォレットには統合されていません。

- [Bitcoin Core #32895][]は、ウォレットを最後に開いたクライアントのバージョンとサポートする機能を記録することで、
  将来の自動アップグレードに備える仕組みを導入します。この記録がない場合、ウォレットをアップグレードし、
  古いバージョンのBitcoin Coreで再度開き、その後再びアップグレードすると、
  古いウォレットレコードと新しいウォレットレコードが混在する可能性があります。たとえば、
  古いバージョンが古い形式で新しいレコードを作成する一方で、
  新しいバージョンはウォレットがすでにアップグレード済みであると想定してマイグレーションをスキップするかもしれません。
  新しいメタデータにより、将来のバージョンはこうしたアップグレード・ダウングレード・アップグレードのシナリオを識別し、
  必要なマイグレーションを実行できるようになります。一部のアップグレードには秘密鍵へのアクセスが必要なため、
  ウォレットを最後に復号したクライアントの機能も別途記録します。

- [Core Lightning #9582][]は、v26.06.8（[ニュースレター #424][news424 cln release]参照）のセキュリティおよび
  信頼性に関する修正を含む77件のコミットをmasterブランチに移植します。1つの修正は、
  完了した[スプライシング][topic splicing]の後の強制閉鎖において、
  その後のチャネル更新によって取り消された可能性のある古いコミットメントトランザクションがブロードキャストされ、
  相手方が[ペナルティ][topic ln-penalty]として資金を請求できてしまうことを防ぎます。もう1つの修正は、
  スクリプトと金額の両方に基づいてアウトプットを照合することで、オンチェーンでの[HTLC][topic htlc]の解決を修正します。
  これまでは、同じペイメントハッシュと有効期限を持ちながら金額が異なるHTLCが混同される可能性があり、
  対応する送信HTLCがオンチェーンで請求可能なままである一方で、CLNが受信HTLCを失敗させてしまうことがありました。
  このPRはまた、`makesecret` RPCの使用を許可された呼び出し元がマスターruneの暗号シークレットを導出し、
  制限のないRPC認可トークンを偽造できるという権限昇格の脆弱性を修正します。CLNは現在、
  この予約済みのシークレットの導出をブロックします。その他の修正は、
  [ゴシップ][topic channel announcements]関連のDoSリスク、
  [デュアルファンディング][topic dual funding]およびスプライシング[RBF][topic rbf]の処理、
  [アンカー][topic anchor outputs]手数料の計算、[マルチパートペイメント][topic multipath payments]の処理、
  runeの検証とブラックリスト登録、[BOLT11][]および[BOLT12][topic offers]メッセージの処理、
  オニオンルーティング、REST APIのリソース枯渇の脆弱性に対処します。

- [Eclair #3390][]と[#3388][eclair #3388]は、
  [デュアルファンディング][topic dual funding]および[スプライシング][topic splicing]中の過剰なマイニング手数料に対する
  保護機能の不備を修正します（[ニュースレター #423][news423 eclair fees]参照）。前者は、
  Eclairが鍵を保持する一方でトランザクションを構築する、侵害されたBitcoin Coreバックエンドが、
  手数料を誤って報告したりトランザクションアウトプットを操作したりして、
  Eclairに意図した以上の支払いを行うトランザクションに署名させる可能性に対する保護です。Eclairは現在、
  実際の手数料を独立して検証し、再構築されたファンディングトランザクションが期待される金額を守っていることを確認します。
  後者は、Eclairが置換用のデュアルファンディングまたはスプライシングトランザクションに資金を拠出する際に、
  悪意のあるチャネルピアが過度に高い[RBF][topic rbf]手数料率を押し付けることを防ぎます。Eclairは現在、
  ピアが[流動性の購入][topic liquidity advertisements]を通じて手数料を支払う場合を除き、
  ローカルで計算した最大値を超える提案を拒否します。

- [LDK #5057][]は、悪意のあるチャネルピアが転送中の[HTLC][topic htlc]の資金を盗むことを可能にする脆弱性を修正します。
  再接続時に、ピアは`channel_reestablish`メッセージで、
  すでに`revoke_and_ack`で承認済みのコミットメントを受け取っていないと偽って主張できました。
  LDKはこの主張を誤って受け入れ、`ChannelMonitor`に記録することなく
  新しい有効なコミットメントトランザクションに署名してしまう可能性がありました。ピアはその後、
  このトランザクションをオンチェーンで公開できます。LDKがその後転送された支払いを決済した場合、
  プリイメージを知っているにもかかわらず、対応する受信HTLCの請求に失敗する可能性がありました。
  これにより、悪意のあるピアはHTLCの期限切れ後にその資金を取り戻すことができました。LDKは現在、
  ピアの承認がまだ未完了の場合にのみコミットメントの再送信を許可し、そうでない場合はチャネルを強制閉鎖します。

- [LDK #5042][]は、[LSPS2][BLIP52]の[JITチャネル][topic jit channels]の支払いを処理する際に
  LSPが資金を失う可能性があったバグを修正します。これまでは、LSPは受信HTLCの金額を検証せずに、
  支払者のオニオンペイロードで指定された転送金額を信頼していました。悪意のある支払者は、
  より少ない金額を送りながらより大きな送信支払いを要求することができ、
  LSPに差額を自身の資金で補填させることができました。現在、LSPS2の`htlc_intercepted`ハンドラーは、
  要求された送信金額が実際の受信HTLCの金額を超えないことを検証します。この条件が満たされない場合、
  LDKはチャネルを開いたり資金を転送したりする前にHTLCを失敗として返します。

- [LDK #5046][]は、`ChannelMonitor`よりも古い`ChannelManager`の状態で再起動した際に、
  転送ノードが資金を失う可能性があったバグを修正します。LDKはこの状況でチャネルを正しく強制閉鎖しますが、
  送信[HTLC][topic htlc]を下流に一度もコミットされていないものとして誤って扱い、
  対応する受信HTLCを上流のピアに失敗として返す可能性がありました。その後、
  下流のピアが送信HTLCをオンチェーンで請求し、LDKが損失を負担することになります。LDKは現在、強制閉鎖の前に、
  以前ブロックされたモニター更新のうちどれがすでに適用済みかを確認し、
  下流にコミットされたHTLCが誤って上流に失敗として返されるのではなく、
  モニターによって解決されるように残されることを保証します。

- [LDK #5028][]は、SCIDエイリアスをサポートするピアとの新しい[非公開チャネル][topic unannounced channels]を開く際に、
  SCIDエイリアスのみによる転送をデフォルトにします。これにより、
  実際のSCIDを使ったインボイスや転送プローブを通じてチャネルのファンディングアウトプットが露呈することを回避します。
  これまでは、アプリケーションは`negotiate_scid_privacy`設定を有効にする必要がありましたが、
  この設定は削除されました。ピアがこれをサポートしないか受け入れない場合、
  ネゴシエーションは引き続きこの保護のないチャネルにフォールバックします。
  既存のチャネルはネゴシエートされた動作を維持します。

- [LND #11290][]は、[ブラインドペイメントパス][topic rv routing]を含む[BOLT11][]インボイスを構築する際の
  オーバーフローのバグを修正します（[ニュースレター #315][news315 lnd blinded]参照）。これまでは、
  LNDは隠されたホップの転送手数料を集計するために32 bit演算を使用しており、
  比較的低い手数料（約4,295 msatまたは4,295 ppm）でオーバーフローする可能性がありました。これにより、
  インボイスが隠されたホップが実際に課す手数料より低い手数料を表示し、
  受信者がインボイスの金額より少ない金額を受け取ることになるため、支払いが失敗する可能性がありました。
  LNDは現在、集計手数料の計算に64 bitのチェック付き演算を使用し、
  手数料がインボイス形式の上限を超えるパスを除外します。

{% include snippets/recap-ad.md when="2026-10-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="36277,36365,36338,32895,9582,3390,3388,5057,5042,5046,5028,11290" %}

[towns set324alias]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes
[news392 bip324 ids]: /ja/newsletters/2026/02/13/#bips-2092
[towns set324alias savings]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes/m/JHCPpVWaBAAJ
[jahr tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg
[news415 dahlias]: /ja/newsletters/2026/07/24/#bip340-bip
[provoost tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg/m/OHPZw92DCQAJ
[shield del]: https://delvingbitcoin.org/t/shielded-bitcoin-private-transfers-on-the-bitcoin-l1/2912
[shield paper]: https://www.allocinit.xyz/uploads/shielded-bitcoin.pdf
[news393 pipes]: /ja/newsletters/2026/02/20/#bitcoin-pipes-v2
[Bitcoin Core 32.0rc3]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc3/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[Core Lightning 26.06.9]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.9
[LDK v0.3-rc3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.3-rc3
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc3/CHANGELOG.md
[LDK v0.2.7]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.7
[LDK v0.1.13]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.13
[BTCPay Server 2.4.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.5
[btcpay 2.4.5 announcement]: https://blog.btcpayserver.org/btcpay-server-2-4-5/
[ldk #5057]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5057
[ldk #5042]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5042
[ldk #5046]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5046
[ldk #5028]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5028
[BLIP52]: https://github.com/lightning/blips/blob/master/blip-0052.md
[news388 private broadcast]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[news425 private broadcast]: /ja/newsletters/2026/10/02/#bitcoin-core-36312
[news420 fee estimation]: /ja/newsletters/2026/08/28/#bitcoin-core-34075
[news425 silent payments]: /ja/newsletters/2026/10/02/#bitcoin-core-35301
[news424 cln release]: /ja/newsletters/2026/09/25/#core-lightning-26-06-8
[news423 eclair fees]: /ja/newsletters/2026/09/18/#eclair-3376
[news315 lnd blinded]: /ja/newsletters/2024/08/09/#lnd-8735
