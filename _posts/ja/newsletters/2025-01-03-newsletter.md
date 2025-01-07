---
title: 'Bitcoin Optech Newsletter #335'
permalink: /ja/newsletters/2025/01/03/
name: 2025-01-03-newsletter-ja
slug: 2025-01-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、集中型のCoinjoinプロトコルを使用するソフトウェアにおける
長年の非匿名化の脆弱性に関する情報のリンクと、スクリプトレスな閾値署名と互換性のある
ChillDKG分散鍵生成プロトコルに関するBIPドラフトの更新について掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する議論の概要や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの
注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **集中型Coinjoinに対する非匿名化攻撃:** Yuval Kogmanは、
  WasabiとGingerウォレットの現在のバージョンおよび、Samourai、Sparrow、
  Trezor Suiteソフトウェアウォレットの過去のバージョンで使用される[Coinjoin][topic
  coinjoin]プロトコルのプライバシーを低下させるいくつかの脆弱性について、
  詳細をBitcoin-Devメーリングリストに[投稿しました][kogman cc]。
  Kogmanは、WasabiとGingerで使用されるWabiSabiプロトコルの設計に携わりましたが（
  [ニュースレター #102][news102 wabisabi]参照）、「リリース前に抗議し、離脱しました」。
  脆弱性が悪用されると、集中型のコーディネーターは、どのユーザーがどのアウトプットを受け取ったかを判断できるため、
  単純なWebサーバーではなく高度なプロトコルを使用する利点がなくなります。
  Kogmanは、この脆弱性が複数のウォレット開発者に何年も前から知られていた証拠を示しています。
  同じソフトウェアの一部に影響する同様の脆弱性については、
  以前[ニュースレター #333][news333 vuln]で言及されています。

- **ChillDKGドラフトの更新:** Tim RuffingとJonas Nickは、
  BitcoinのFROST[スクリプトレス閾値署名][topic threshold signature]と互換性のある分散鍵生成プロトコルを記述した
  [ChillDKGの現在のBIPのドラフト][bip-chilldkg]のリンクをBitcoin-Devメーリングリストに[投稿しました][rn
  chilldkg]。最初の発表（[ニュースレター #312][news312 chilldkg]参照）から、
  セキュリティの脆弱性を修正し、問題のある参加者を特定できる調査フェーズを追加し、
  バックアップとリカバリーをより容易にしました。また、Sivaram Dhakshinamoorthyと協力して、
  彼の提案するBitcoinと互換性のあるFROST署名（[ニュースレター #315][news315 frost]参照）との同期を保っています。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた新しい月次セクション_

- **CTV拡張opcode:** 開発者のmoonsettlerは、すでに提案されている[OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify]と組み合わせて使用する2つの追加opcodeの提案を
  [Bitcoin-Dev][moonsettler ctvppml]メーリングリストと[Delving Bitcoin][moonsettler
  ctvppdelv]の両方に投稿しました:

  - _OP_TEMPLATEHASH_ は、トランザクションの要素のリストを取得し、
    それをCTV互換のハッシュに変換します。これにより、スタック操作で、
    使用するインプット、インプットの数、ロックタイム、各アウトプットの金額、
    各アウトプットのスクリプト、アウトプットの数、使用するトランザクションのバージョンに関する詳細を指定できます。

  - _OP_INPUTAMOUNTS_ は、インプットの一部またはすべてのsatoshiの金額をスタックに配置し、
    `OP_TEMPLATEHASH`のパラメーターとして使用できるようにします（たとえば、アウトプットに同じ金額を要求するなど）。

  これらのopcodeを組み合わせると、[BIP345][]の`OP_VAULT`で可能なものと同様の特性を持つ
  [Vault][topic vaults]を作成できます。opcodeは、他のコントラクトプロトコルに加えて、
  よりオンチェーン効率の高い種類の[アカウンタブルコンピューティング][topic acc]を実装するのに便利かもしれません。
  この記事の執筆時点では、Delving Bitcoinのスレッドで議論が進行中でした。

- **<!--adjusting-difficulty-beyond-256-bits-->256 bitを超える難易度の調整:**
  Andersは、ブロックヘッダーで使用可能な256 bitを超えるPoW（Proof of Work）難易度の調整に関する懸念を
  Bitcoin-Devメーリングリストに[投稿しました][anders diff]。
  これには、ハッシュレートの計り知れない増加（現在のレートの約2<sup>176</sup>倍の増加）が必要になりますが、
  それが実現した場合、Michael Cassanoは、フォークによってセカンダリハッシュターゲットが追加され、
  ブロックを有効にするためには、プライマリターゲットとセカンダリターゲットの両方を満たす必要があると[指摘しています][cassano diff]。
  これは、ブロック保留攻撃を軽減するための提案と似ています（[ニュースレター #315][news315 withholding]参照）。
  _フォワードブロック_ （[ニュースレター #16][news16 forward]参照）などの提案を含むこの種のフォークは、
  既存のルールを強化するだけなので、技術的にはソフトフォークとなる可能性がありますが、
  アップグレードされていないフルノードや、潜在的にすべての軽量（SPV）クライアントが、
  実際には承認がゼロであるにもかかわらず、あるトランザクションに何百、何千もの承認があるかのにように騙されたり、
  実際に承認されたトランザクションと競合したりしやすくなるため、そのような分類を使用したくないと考える開発者もいます。

- **<!--transitory-soft-forks-for-cleanup-soft-forks-->クリーンアップソフトフォークのための一時的なソフトフォーク:**
  Jeremy Rubinは、脆弱性を軽減または修正するために設計されたコンセンサスルールを一時的にのみ適用することについて
  Delving Bitcoinに[投稿しました][rubin transitory]。このアイディアは、
  新機能を追加するソフトフォークのために以前提案されていましたが（[ニュースレター #197][news197 transitory]参照）、
  新機能の支持者からも、提案に態度を決めかねているコミュニティメンバーからも支持を得られませんでした。
  Rubinは、このアイディアは脆弱性を修正しようとするものの、ユーザーが誤ってビットコインを使用できなくなるリスク（没収リスクと呼ばれる）や
  将来の脆弱性を容易に修正する能力が制限されたりするリスクを伴うソフトフォークにより適していると示唆しています。
  David Hardingは、一時的なソフトフォークのアイディアが以前支持を得なかったのは、
  数年ごとにコンセンサス変更の賛否を再度議論する必要があるということを、
  支持者も態度を決めかねているコミュニティメンバーも望んでいなかったからであり、
  この懸念は、変更が機能を追加するものであっても、脆弱性に対処するものであっても同じように適用されると[主張しました][harding transitory]。

- **<!--quantum-computer-upgrade-path-->量子コンピュータのアップグレードパス:**
  Matt Coralloは、高速な量子コンピューターによる偽造リスクのためにECDSAおよび[Schnorr 署名][topic schnorr
  signatures]が無効になっている場合でも資金を使用できるように、
  [Tapscript][topic tapscript]に量子耐性署名チェックopcodeを追加することについて
  Bitcoin-Devメーリングリストに[投稿しました。][corallo qc]。Luke Dashjrは、
  将来的に量子耐性のある署名チェックopcodeがどのように機能するかについて現在広く合意されている限り、
  ユーザーは後で利用可能になる可能性のあるオプションとしてコミットするだけでいいため、
  現時点でソフトフォークは不要であると[指摘しました][dashjr qc]。Tadge Dryjaは、
  量子コンピューターがビットコインを盗む寸前であると思われる場合に、
  量子安全ではないECDSAやSchnorr署名の使用を一時的に制限する一時的なソフトフォークを[提案しました][dryja qc]。
  その後、誰かが量子コンピューターでのみ解決可能なオンチェーンパズルコントラクトを解決した場合（
  または基本的な暗号の脆弱性が発見された場合）、一時的なソフトフォークは自動的に永続的になります。
  そうでない場合、一時的なソフトフォークは更新されるか、失効します（ECDSAとSchnorrによって保護されたビットコインが再度使用可能になります）。

- **<!--consensus-cleanup-timewarp-grace-period-->コンセンサスクリーンアップのタイムワープ猶予期間:**
  Sjors Provoostは、新しい難易度期間の最初のブロックが前の期間の最後のブロックより600秒以上前の時刻を持つことを禁止することで、
  [タイムワープ攻撃][topic time warp]を軽減する[コンセンサスクリーンアップ][topic consensus cleanup]の提案について、
  Delving Bitcoinに[投稿しました][provoost timewarp]。Provoostは、
  タイムスタンプの範囲を使用してnonceのスペースを拡張する（_タイムローリング_ と呼ばれる）ソフトウェアを使用する正直なマイナーが、
  クロックの遅いノードがすぐに受け入れないかもしれないブロックを誤って生成し、
  同じ時刻に生成される可能性のあるタイムスタンプの変動が少ない競合ブロックに比べて、
  ブロックの伝播が遅くなることを懸念しています。競合ブロックがベストブロックチェーンに残れば、
  タイムローリングブロックのマイナーは収益を失うことになります。Provoostは代わりに、
  7,200秒（約2時間）を超えて時間を逆行させることを禁止するなど、より緩やかな制限を提案しています。
  Antoine Poinsotは、600秒という選択は既知の問題を回避し、
  将来の時間の歪みに対する最も強力な防御を提供するものだと[主張しています][poinsot timewarp]。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK wallet-1.0.0][]は、Bitcoinウォレットやその他のBitcoin対応アプリケーションを構築するための
  このライブラリの最初のメジャーリリースです。元の`bdk`Rustクレートの名前が
  `bdk_wallet`に変更され（APIは安定を保つよう設計）、下位層のモジュールは
  `bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの
  独自のクレートに抽出されました。

- [LND 0.18.4-beta][]は、この人気のLN実装のマイナーリリースで、
  「通常のバグ修正と安定性の向上に加えて、カスタムチャネルの構築に必要な機能を提供します」。

- [Core Lightning v24.11.1][]は、実験的な`xpay`プラグインと
  古い`pay` RPC間の互換性を改善し、xpayユーザー向けに他のいくつかの改善を加えたマイナーリリースです。

- [Bitcoin Core 28.1rc2][]は、主流のフルノード実装のメンテナンスバージョンのリリース候補です。

- [LDK v0.1.0-beta1][]は、LN対応ウォレットとアプリケーションを構築するための
  このライブラリのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31223][]は、ノードが「[Tor][topic anonymity networks]サービスターゲット」
  P2Pポートを導出する方法（ニュースレター[#118][news118 tor]参照）を変更します。
  `-port`の値が指定されている場合は、デフォルトの8334ではなく、ユーザーが指定した`-port`値に1を加えた値を使用します。
  これにより、複数のローカルノードがすべて8334にバインドされ、ポートの衝突によりクラッシュするという問題が修正されます。
  ただし、稀に2つのローカルノードに連続した`-port`値が割り当てられた場合、
  導出されたonionポートが衝突する可能性がありますが、これは完全に回避する必要があります。

- [Eclair #2888][]は、[BOLTs #1110][]で定義されている[ピアストレージ][topic peer storage]プロトコルのサポートを実装します。
  これにより、ノードはそれを要求するピアの暗号化されたバックアップをデフォルトで最大65kBまで保存できます。
  この機能は、モバイルウォレットを提供するLSP（Lightning Service Provider）を対象としており、
  ノードオペレーターがデータを保存する期間を指定できる設定があります。これによりEclairは、
  CLNに続いて（ニュースレター[#238][news238 storage]参照）ピアストレージをサポートする２つめの実装になります。

- [LDK #3495][]は、ランダム化されたプローブから収集された実際のデータに基づいて
  [確率密度関数 (PDF)][probability density]と関連パラメーターを改善することで、
  LNの経路探索における過去の成功確率スコアリングモデルを改良します。このPRは、
  過去のモデルと事前モデルを実際の動作に合わせて、デフォルトのペナルティを強化し、
  経路探索の信頼性を向上させます。

- [LDK #3436][]は、`lightning-liquidity`クレートを`rust-lightning`リポジトリに移動します。
  このクレートは、（[ここで][lsp spec]定義されている）LSPをLDKベースのノードと統合するための型とプリミティブを提供します。

- [LDK #3435][]は、[ブラインドパス][topic rv routing]支払いコンテキストメッセージに認証フィールドを追加し、
  支払人がHMAC（Hash-based Message Authentication Codes）とnonceを含め、
  受信者が支払人を認証できるようにします。これにより、攻撃者が被害者ノードが発行した[BOLT11][]インボイスから
  `payment_secret`を取得し、その[オファー][topic offers]に期待される金額と一致しない場合でも
  支払いを偽造できる問題が修正されます。また同じ手法を用いた非匿名化攻撃の防止にも役立ちます。

- [LDK #3365][]は、アップグレード時に`holder_commitment_point`（次のコミットメントポイント）を、
  以前使用した`PendingNext`状態のままにするのではなく、
  `get_channel_reestablish`で取得することでアップグレード時にすぐに使用可能としてマークされるようにします。
  この変更により、アップグレード中にチャネルが安定状態にあり、
  次のコミットメントポイントが使用可能であることを求める`commitment_signed`メッセージを受信した際に、
  強制閉鎖されるのが防止されます。

- [LDK #3340][]は、[Pinning][topic transaction pinning]可能なアウトプットを持つオンチェーン
  の請求トランザクションの[バッチ処理][topic payment batching]を導入し、
  強制閉鎖シナリオでのブロックスペースの使用と手数料を削減します。
  これまでは、アウトプットはノードによって排他的に請求可能で、Pinningが不可能な場合のみバッチ処理されていました。
  現在は、取引相手が使用できる高さから12ブロック以内のアウトプットは、
  [HTLC][topic htlc]タイムアウトの[ロックタイム][topic timelocks]と組み合わせることができる限り、
  Pinning可能として扱われ、それに応じてバッチ処理されます。

- [BDK #1670][]では、新しいO(n)正規化アルゴリズムが導入され、
  正規のトランザクションを識別し、ウォレットのベストローカルチェーンの視点で承認される可能性が低い（非正規）
  未承認の競合を削除します。この大幅に効率的なアプローチは、特定のユースケースで
  [DoSリスクとなる可能性のある][canalgo]O(n²)ソリューションを提供していた
  古い`get_chain_position`メソッドを置き換えて削除します。

- [BIPs #1689][]は、[BIP374][]をマージし、Bitcoinで使用される楕円曲線（secp256k1）の
  [離散対数の等価性の証明（DLEQ）][topic dleq]を生成および検証する標準的な方法を定義します。
  このBIPは、複数の個別の署名者を使用して作成された[サイレントペイメント][topic silent payments]のサポートを目的としています。
  DLEQを使用すると、すべての署名者は秘密鍵を公開することなく、共同署名者に対して署名が有効であり、
  資金を失うリスクがないことを証明できます。

- [BIPs #1697][]は、細かい文法変更を行うことで、
  テンプレート化された[アウトプットスクリプトディスクリプター][topic descriptors]のセットに
  [MuSig][topic musig]サポートを追加するため、[BIP388][]を更新します。

- [BLIPs #52][]は、[BOLT8][]ピアツーピアメッセージ上のJSON-RPCフォーマットを使用して、
  LSPノードとそのクライアント間の通信で使用されるプロトコルを定義するため、[BLIP50][]を追加します。
  これは、[LSPの仕様リポジトリ][lsp spec]の上流のBLIPセットの一部であり、
  複数のLSPおよびクライアント実装で実際に稼働しているため、安定しているとみなされています。

- [BLIPs #54][]は、LNチャネルを持っていないクライアントが支払いの受け取りを始められるようにする
  [JITチャネル][topic jit channels]を定義するために[BLIP52][]を追加します。
  LSPが支払いを受け取ると、それに応じてクライアントへのチャネルが開かれ、
  チャネルの開設コストが最初に受け取った支払いから差し引かれます。
  これも[LSPの仕様リポジトリ][lsp spec]の上流のBLIPセットの一部です。

{% include snippets/recap-ad.md when="2025-01-07 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31223,2888,3495,3436,3435,3365,3340,1670,1689,1697,54,52,1110" %}
[news315 withholding]: /ja/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news16 forward]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[moonsettler ctvppml]: https://groups.google.com/g/bitcoindev/c/1P1aqkfwE7E
[moonsettler ctvppdelv]: https://delvingbitcoin.org/t/ctv-op-templatehash-and-op-inputamounts/1344/
[anders diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/qR4ucBeMCAAJ
[cassano diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/gPNAMn3ICAAJ
[corallo qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/4cM-7pf4AgAJ
[dashjr qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/YT0fR2j_AgAJ
[dryja qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/8nr6I5NIAwAJ
[rubin transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333
[news197 transitory]: /ja/newsletters/2022/04/27/#david-harding
[harding transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333/2
[provoost timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326
[poinsot timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/11
[news333 vuln]: /ja/newsletters/2024/12/13/#wasabi
[news315 frost]: /ja/newsletters/2024/08/09/#bip
[news312 chilldkg]: /ja/newsletters/2024/07/19/#frost
[kogman cc]: https://groups.google.com/g/bitcoindev/c/CbfbEGozG7c/m/w2B-RRdUCQAJ
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[rn chilldkg]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/Y2VhaMCrCAAJ
[bip-chilldkg]: https://github.com/BlockstreamResearch/bip-frost-dkg
[lnd 0.18.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta
[bitcoin core 28.1rc2]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[bdk wallet-1.0.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.0.0
[core lightning v24.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.1
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[news118 tor]: /en/newsletters/2020/10/07/#bitcoin-core-19991
[news238 storage]: /ja/newsletters/2023/02/15/#core-lightning-5361
[lsp spec]: https://github.com/BitcoinAndLightningLayerSpecs/lsp
[probability density]: https://ja.wikipedia.org/wiki/確率密度関数
[canalgo]: https://github.com/evanlinjin/bdk/blob/e9854455ca77875a6ff79047726064ba42f94f29/docs/adr/0003_canonicalization_algorithm.md
