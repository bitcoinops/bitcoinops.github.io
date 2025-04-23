---
title: 'Bitcoin Optech Newsletter #331'
permalink: /ja/newsletters/2024/11/29/
name: 2024-11-29-newsletter-ja
slug: 2024-11-29-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinスクリプト用のLisp方言に関する最近の議論を掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **Bitcoinスクリプト用のLisp方言:** Anthony Townsは、
  ソフトフォークでBitcoinに追加可能なBitcoin用のLisp方言を作成する[研究][topic bll]の続きについて、
  いくつか投稿しました。

  - *bll, symbll, bllsh:* Townsは、Chia Lisp開発者のArt Yerkesからの、
    （プログラマーが通常書く）高レベルコードと（実際に実行されるもので、
    通常はコンパイラによって高レベルコードから作成される）低レベルコード間の適切なマッピングを確保するためのアドバイスについて、
    長い間考えていたと[述べています][towns bllsh1]。彼は、
    「（miniscriptがスクリプトに対して行うように）高レベル言語を低レベル言語の使いやすいバリエーションとして扱う」
    という[miniscript][topic miniscript]のようなアプローチを取ることにしました。
    その結果、2つの言語と1つのツールができました。

    - *Basic Bitcoin Lisp言語 (bll)* は、ソフトフォークでBitcoinに追加できる低レベルの言語です。
      Townsによると、前回の更新時点（[ニュースレター #294][news294 btclisp]参照）で、
      bllはBTC Lispに似ています。

    - *シンボリックbll (symbll)* は、bllに変換される高レベル言語です。
      関数型プログラミングに慣れている人にとっては、比較的簡単なはずです。

    - *Bllシェル (bllsh)* は、bllとsymbllでスクリプトをテストし、
      symbllからbllにコンパイルし、デバッグ機能を使用してコードを実行できる[REPL][]です。

  - *symbllとGSRにおける量子安全な署名の実装:*
    Townsは、既存のopcodeとRusty RussellのGSR（_Great Script Restoration_）[提案][russell gsr]で定義されたopcodeを使用して
    Winternitz One Time Signatures (WOTS+)を実装することに関するJonas Nickの[Twitter投稿][nick wots]を[リンク][towns wots]しています。
    Townsは、次にbllshでsymbllを使用してWOTSを実装することを比較しました。
    これにより、オンチェーンに配置する必要があるデータ量が少なくとも83%、場合によっては95%以上削減されます。
    これにより、P2WPKHアウトプットの30倍のコストで[量子安全な署名][topic quantum resistance]を使用することができます。

  - *<!--flexible-coin-earmarks-->柔軟なコインの用途指定:*
    Townsは、１つのUTXOを特定の金額と使用条件に分割できるsymbll（およびおそらく[Simplicity][topic simplicity]）と互換性のある
    汎用構造について[説明しています][towns earmarks]。使用条件が満たされると、
    関連付けられた金額を使用することができ、UTXOの残りの金額は残りの条件と一緒に新しいUTXOに戻されます。
    UTXOのすべて使用できるようにする別の条件が満たされる場合もあります。たとえば、
    これによりすべての参加者が条件の一部を更新することに同意できるようになります。これはTownsが以前提案した
    `OP_TAP_LEAF_UPDATE_VERIFY`（TLUV、[ニュースレター #166][news166 tluv]参照）に似た
    柔軟なタイプの[コベナンツ][topic covenants]の仕組みですが、Townsは以前、
    コベナンツは「正確でも有用な用語でもない」と考えていると[書いています][towns badcov]。

    （[LN-Symmetry][topic eltoo]ベースのチャネルを含む）LNチャネルのセキュリティとユーザビリティの向上や、
    [BIP345][]版の[Vault][topic vaults]の代替、
    TLUVで使用することが検討されているのと同様の[ペイメントプール][topic joinpools]の設計であるものの
    [x-only公開鍵][topic x-only public keys]でその提案が抱えていた問題を回避するものなど、
    これらの _柔軟なコインの用途指定_ をどのように使用できるかについて、いくつかの例が示されています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [ColliderScriptはBitcoinをどのように改善し、どのような機能を可能にしますか？]({{bse}}124690)
  Victor Kolobovは、ColliderScript（[ニュースレター #330][news330 cs]および[ポッドキャスト #330][pod330 cs]参照）の潜在的な用途として、
  [コベナンツ][topic covenants]、[Vault][topic vaults]、[CSFS][topic op_checksigfromstack]のエミュレーション、
  Validity Rollup（[ニュースレター #222][news222 validity rollups]参照）などを挙げる一方、
  このようなトランザクションの計算コストが高いことも言及しています。

- [標準ルールでトランザクションweightを制限するのはなぜですか？]({{bse}}124636)
  Murchは、Bitcoin Coreの標準weight制限に対する賛否両論を示し、
  より大きなトランザクションに対する経済的需要がこの[ポリシー][policy series]の有効性を損なう可能性について概説しています。

- [PayToAnchorを使用する際のscriptSigは常に空となると予想されますか？]({{bse}}124615)
  Pieter Wuilleは、[Pay-to-Anchor（P2A）][topic ephemeral anchors]アウトプットの[構築][news326 p2a]方法により、
  scriptSigが空であることを含む、segwitの使用条件に準拠する必要があることを指摘しています。

- [未使用のP2Aアウトプットはどうなりますか？]({{bse}}124617)
  Instagibbsは、ブロックに格納するための手数料率が、P2Aアウトプットをスイープする価値があるほど低下すると、
  未使用のP2Aアウトプットは最終的にスイープされ、UTXOセットから削除されると指摘しています。
  さらに、最近マージされた[エフェメラルダスト][news330 ed]のPRを参照しています。
  このPRでは、[子トランザクション][topic cpfp]がすぐに使用される場合に、
  手数料ゼロのトランザクションでダストの閾値未満のアウトプットを1つ許可します。

- [BitcoinのPoWアルゴリズムは、なぜ難易度の低いハッシュのチェーンを使用しないのですか？]({{bse}}124777)
  Pieter WuilleとVojtěch Strnadは、Bitcoinのマイニングのプログレスフリー特性が
  このようなアプローチで侵害された場合に発生するマイニングの集中化の圧力について説明しています。

- [Script内のfalseの値の明確化]({{bse}}124673)
  Pieter Wuilleは、Bitcoin Script内でfalseと評価される3つの値（空の配列、0x00のみで構成される配列、
  0x00で構成され末尾が0x80の配列）を指定しています。その他の値はすべてtrueと評価されると指摘しています。

- [<!--what-is-this-strange-microtransaction-in-my-wallet-->私のウォレットにあるこの奇妙なマイクロトランザクションはなんですか？]({{bse}}124744)
  Vojtěch Strnadは、アドレスポイズニング攻撃の仕組みと、そのような攻撃を軽減する方法について説明しています。

- [使用できないUTXOはありますか？]({{bse}}124865)
  Pieter Wuilleは、暗号仮定が破られたとしても使用できないアウトプットの例を2つ示しています。
  `OP_RETURN`アウトプットとscriptPubKeyが10,000 byteを超えるアウトプットです。

- [BIP34がコインベーストランザクションのlocktimeやnSequenceを介して実装されなかったのはなぜですか？]({{bse}}75987)
  Antoine Poinsotは、この古い質問に対して、[ロックタイム][topic timelocks]はトランザクションが
  *無効* となる最後のブロックを表すため、コインベーストランザクションの`nLockTime`の値を
  現在のブロックの高さに設定することはできないと指摘しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 24.11rc2][]は、この人気のLN実装の次期メジャーバージョンのリリース候補です。

- [BDK 0.30.0][]は、ウォレットや他のBitcoin対応アプリケーションを構築するための
  このライブラリのリリースです。いくつかのマイナーなバグ修正が含まれており、
  ライブラリのバージョン1.0へのアップグレードが予定されています。

- [LND 0.18.4-beta.rc1][]は、この人気のLN実装のマイナーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31122][]は、mempoolの`changeset`インターフェースを実装し、
  ノードが提案されたお釣りのセットがmempoolの状態に与える影響を計算できるようにします。
  たとえば、トランザクションやパッケージが受け入れられた際に、
  祖先/子孫/[TRUC][topic v3 transaction relay]（および将来のクラスター）の制限に違反しているかどうかを確認したり、
  [RBF][topic RBF]による手数料の引き上げによってmempoolの状態が改善されるかどうかを判断したりします。
  このPRは、[クラスターmempool][topic cluster mempool]プロジェクトの一部です。

- [Core Lightning #7852][]は、descriptionフィールドを再導入することで、
  `pyln-client`プラグイン（Pythonのクライアントライブラリ）の24.08未満のバージョンとの下位互換性を復元します。

- [Core Lightning #7740][]は、`askrene`（[ニュースレター #316][news316 askrene]参照）プラグインの
  最小コストフロー（MCF）ソルバーを改善し、MCF解法の複雑さを抽象化するAPIを提供することで、
  新しく追加されたグラフベースのフロー計算アルゴリズムの統合を容易にしました。
  このソルバーは、`renepay`（[ニュースレター #263][news263 renepay]参照）と同じ
  チャネルコスト関数のリニアライゼーションを採用し、経路探索の信頼性を向上させています。
  また、msatsを超えるカスタマイズ可能な単位のサポートを導入し、大きめな支払いのためのスケーラビリティを向上させています。
  このPRでは、フロー計算の効率を向上させるために、`simple_feasibleflow`、`get_augmenting_flow`、
  `augment_flow`、`node_balance`メソッドを追加しています。

- [Core Lightning #7719][]は、Eclairとの[スプライシング][topic splicing]の相互運用を実現し、
  2つの実装間でスプライシングを実行できるようにしました。このPRでは、
  リモートファンディングキーのローテーションのサポート、コミットメント署名メッセージ用の`batch_size`の追加、
  パケットサイズ制限による以前のファンディングトランザクションの送信の防止、
  メッセージからのブロックハッシュの削除、事前設定されたファンディングアウトプット残高の調整など、
  Eclairの実装に合わせるためのいくつかの変更が導入されました。

- [Eclair #2935][]は、チャネルピアによって強制閉鎖が開始された場合の
  ノードオペレーターへのイベントの通知を追加しました。

- [LDK #3137][]は、ピアによって開始された[デュアルファンドチャネル][topic dual funding]を受け入れるサポートを追加しましたが、
  そのようなチャネルへの資金提供や作成はまだサポートされていません。
  `manually_accept_inbound_channels`がfalseに設定されている場合、チャネルは自動的に受け入れられますが、
  `ChannelManager::accept_inbound_channel()`関数では手動で受け入れることができます。
  デュファルファンドチャネルと非デュファルファンドチャネルのインバウンド要求を区別するために、
  新しい`channel_negotiation_type`フィールドが導入されました。
  [ゼロ承認][topic zero-conf channels]デュアルファンドチャネルと、
  ファンディングトランザクションの[RBF][topic rbf]による手数料の引き上げはサポートされていません。

- [LND #8337][]は、LNDでイベント駆動型のプロトコル有限状態マシン（FSM）を作成するための再利用可能なフレームワークである
  `protofsm`パッケージを導入しました。状態、遷移、イベントを処理するための定型的なコードを書く代わりに、
  開発者は状態、イベントをトリーがするもの、それらの間を移動するためのルールを定義することができ、
  `State`インターフェースは動作をカプセル化し、イベントを処理し、終端状態を決定します。
  一方、デーモンアダプターは、トランザクションのブロードキャストやピアメッセージの送信などの副作用を処理します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="31122,7852,7740,7719,2935,3137,8337" %}
[news294 btclisp]: /ja/newsletters/2024/03/20/#btc-lisp
[russell gsr]: https://github.com/rustyrussell/bips/pull/1
[towns bllsh1]: https://delvingbitcoin.org/t/debuggable-lisp-scripts/1224
[repl]: https://ja.wikipedia.org/wiki/REPL
[towns wots]: https://delvingbitcoin.org/t/winternitz-one-time-signatures-contrasting-between-lisp-and-script/1255
[nick wots]: https://x.com/n1ckler/status/1854552545084977320
[towns earmarks]: https://delvingbitcoin.org/t/flexible-coin-earmarks/1275
[news166 tluv]: /ja/newsletters/2021/09/15/#covenant-opcode-proposal-covenant-opcode
[towns badcov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[core lightning 24.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc2
[bdk 0.30.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.0
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 askrene]: /ja/newsletters/2024/08/16/#core-lightning-7517
[news263 renepay]: /ja/newsletters/2023/08/09/#core-lightning-6376
[news330 cs]: /ja/newsletters/2024/11/22/#covenants-based-on-grinding-rather-than-consensus-changes
[pod330 cs]: /en/podcast/2024/11/26/#covenants-based-on-grinding-rather-than-consensus-changes
[news222 validity rollups]: /ja/newsletters/2022/10/19/#validity-rollups
[policy series]: /ja/blog/waiting-for-confirmation/
[news326 p2a]: /ja/newsletters/2024/10/25/#pay-to-anchor
[news330 ed]: /ja/newsletters/2024/11/22/#bitcoin-core-30239