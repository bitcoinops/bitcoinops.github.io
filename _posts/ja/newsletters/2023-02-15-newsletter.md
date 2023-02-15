---
title: 'Bitcoin Optech Newsletter #238'
permalink: /ja/newsletters/2023/02/15/
name: 2023-02-15-newsletter-ja
slug: 2023-02-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinのブロックチェーンにデータを保存することについての継続的な議論と、
いつくかの種類のマルチパーティプロトコルに対する仮想的な手数料希薄化攻撃、
tapscriptの署名コミットメントが同じツリー内の異なる部分で使用できることについて掲載しています。
また、サービスやクライアントソフトウェアの変更や、新しいリリースおよびリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。
さらに、Bitcoinの技術文書と議論にフォーカスした新しい検索エンジンについて、
私たちの珍しい推奨事項を提供します。

## ニュース

- **<!--continued-discussion-about-block-chain-data-storage-->ブロックチェーンへのデータ保存に関する継続議論:**
  今週、Bitcoin-Devメーリングリストのいくつかのスレッドで、
  ブロックチェーンにデータを保存することについて議論が続きました。

    - *<!--offchain-coin-coloring-->オフチェーンのコインカラーリング:*
      Anthony Townsは、特定のトランザクションアウトプットに特別な意味を割り当てるために
      現在使用されているプロトコルの概要を[投稿しました][towns color]。
      これは、一般的に*コインカラーリング*と呼ばれています。彼はまた、
      エンコードされたバイナリデータをBitcoinトランザクションに格納し、
      それを特定のカラードコインと関連付けるために使用されている関連プロトコルもまとめています。
      現状をまとめた後、彼は、[nostr][]メッセージ転送プロトコルを使用してデータを保存し、
      それをBitcoinトランザクションで転送可能なカラードコインと関連付ける方法について説明しました。
      これには、いくつかの利点があります:

      - *<!--reduced-costs-->コストの削減:* データはオフチェーンで保存されるので、
        データに対してトランザクション手数料を支払う必要がない。

      - *<!--private-->プライベート:* 2人のユーザーがカラードコインを交換しても、
        それが参照するデータについて、他の誰にも知られることがない。

      - *<!--no-transaction-required-for-creation-->作成時にトランザクションを必要としない:*
        既存のUTXOにデータを関連付けることができるため、新しいUTXOを作成する必要がない。

      - *<!--resistant-against-censorship-->検閲耐性:* データとカラードコインの関連付けが広く知られていない場合、
        カラードコインの転送は、他のオンチェーンBitcoin支払いと同様の検閲耐性がある。

      検閲耐性の側面を考慮し、Townsは「カラーリングされたビットコインはほぼ避けられず、
      防止/回避するために時間を費やすべきものではなく、単に対応しなければならないものです。」と主張しています。
      彼は、カラードコインが代替可能なビットコインよりも価値があるかもしれないという考えを、
      転送される額よりもトランザクションの重みに基づいてトランザクション手数料を課すBitcoinの運用と比較し、
      これが必ずしも著しく不均衡なインセンティブにつながるとは思わないと結論付けています。

    - *標準トランザクションで許容する`OP_RETURN`のスペースの増加:*
      Christopher Allenは、`OP_RETURN`を使用してトランザクションアウトプットに任意のデータを入れるのと、
      トランザクションのwitnessデータに入れるのとどちらが良いか[質問しました][allen op_return]。
      いくつかの議論の後、数名の参加者は（[1][todd or]、[2][o'connor or]、[3][poelstra or]）、
      `OP_RETURN`アウトプットに83バイト以上の任意のデータを格納できるように、
      デフォルトのトランザクションリレーポリシーおよびマイニングポリシーを緩和することに賛成であると指摘しました。
      彼らは、大量のデータを保存する他の方法が現在使用されており、
      代わりに`OP_RETURN`が使用されても追加的な害はないだろうと理由を述べました。

- **<!--fee-dilution-in-multiparty-protocolst-->マルチパーティプロトコルにおける手数料の希薄化:**
  Yuval Kogmanは、Bitcoin-Devメーリングリストに特定のマルチパーティプロトコルに対する攻撃について[投稿しました][kogman dilution]。
  この攻撃は[以前から説明されていました][riard dilution]が、Kogmanの投稿により再び注目されるようになりました。
  マロリーとボブがそれぞれ、予想されるサイズと手数料の（予想される手数料率を意味します）共同トランザクションに1つのインプットを提供することを想像してください。
  ボブは、自分のインプットに対して予想されるサイズのwitnessを提供しますが、
  マロリーは予想よりもはるかに大きなwitnessを提供します。これにより、
  トランザクションの手数料率は事実上低下します。このことに関するいくつかの影響がメーリングリストで議論されました:

    - *<!--mallory-gets-bob-to-pay-her-fees-->マロリーがボブに手数料を支払わせる:*
      マロリーがブロックチェーンに大きなwitnessを含めるための何らかの下心がある場合（たとえば任意のデータを追加したい場合など）、
      ボブの手数料の一部をそのための手数料の支払いに充てることができます。たとえば、
      ボブは10,000 satoshiの手数料で1,000 vbyteのトランザクションを作成し、
      10 sat/vbyteを支払うことで迅速に承認させたいと考えています。
      マロリーは、ボブが予想しない9,000 vbyteのデータをトランザクションに詰め込み、
      手数料率を1 sat/vbyteに引き下げました。ボブはどちらのケースでも同じ手数料を支払いますが、
      彼が望んでいたもの（素早い承認）は得られず、マロリーはコストを負担することなく
      9,000 sat相当のデータをブロックチェーンに追加できます。

    - *<!--mallory-can-slow-confirmation-->マロリーは承認を遅くできる:*
      低手数料率のトランザクションの承認をより遅らせることができます。時間的制約のあるプロトコルでは、
      これはボブにとって深刻な問題になり得ます。他の場合、ボブはトランザクションの手数料を引き上げる必要があるかもしれず、
      その場合、追加のコストがかかります。

  Kogmanは、彼の投稿でいくつかの緩和策を説明していますが、それらはすべてトレードオフを伴うものです。
  [もう１つの投稿][kogman dilution2]では、現在展開されているプロトコルで脆弱なものは認識していないと述べています。

- **Tapscriptの署名のmalleability:** 上記の手数料の希薄化に関する会話の余談として、
  開発者のRussell O'Connorは、[Tapscript][topic tapscript]用の署名は、
  Taprootツリー内の別の場所に配置されたTapscriptのコピーに適用できることを[指摘しました][o'connor tsm]。
  たとえば、同じTapscript *A*がTaprootツリー内の2つの異なる場所に配置されているとします。
  より深い場所にある代替条件を使用するには、支払いトランザクションのwitnessデータ内に
  追加の32バイトのハッシュを配置する必要があります。

    ```text
      *
     / \
    A   *
       / \
      A   B
    ```

   つまり、ボブが署名を提供する前に、マロリーが自分のTapscriptの有効なwitnessを提供したとしても、
   マロリーがより大きなwitnessを持つ別バージョンのトランザクションをブロードキャストする可能性があるということです。
   ボブはマロリーからTapscriptツリーの完全なコピーを受け取ることによってのみ、この問題を防ぐことができます。

   将来のBitcoinのソフトフォークアップグレードに関連して、Anthony Townsは
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO)のテストに使用されているBitcoin
  Inquisitionのリポジトリに、その拡張機能のユーザーに対してこの問題を防ぐためにAPOが追加のデータをコミットすることを検討する
  [Issue][bitcoin inquisition #19]を公開しました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Lianaウォレットがマルチシグを追加:**
  [Liana][news234 liana]の[0.2リリース][liana 0.2]で、
  [ディスクリプター][topic descriptors]を使用したマルチシグのサポートを追加しています。

- **Sparrowウォレット1.7.2リリース:**
  Sparrowの[1.7.2リリース][sparrow 1.7.2]では、[Taproot][topic taproot]のサポート、
  [BIP329][]のインポートとエクスポート機能（[ニュースレター #235][news235 bip329]参照）および、
  ハードウェア署名デバイス用の追加サポートが追加されています。

- **BitcoinexライブラリがSchnorrをサポート:**
  [Bitcoinex][bitcoinex github]は、関数型プログラミング言語Elixir用のBitcoinユーティリティライブラリです。

- **Libwally 0.8.8リリース:**
  [Libwally 0.8.8][]は、[BIP340][]のタグ付きハッシュのサポート、
  [BIP118][] ([SIGHASH_ANYPREVOUT][topic SIGHASH_ANYPREVOUT])を含む追加のsighashのサポート、
  [miniscript][topic miniscript]、ディスクリプターおよび[PSBT][topic psbt]関数を追加しました。

## Optechのお勧め

[BitcoinSearch.xyz][]は、Bitcoinの技術文書や議論用に最近立ち上げられた検索エンジンです。
このニュースレターでリンクされているいくつかのソースを素早く見つけるために使用でき、
私たちが以前使用した他のより手間のかかる方法よりも大幅に改善されています。
この[コード][bitcoinsearch repos]への貢献は大歓迎です。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.02rc2][]は、この人気のLN実装の新しいメンテナンスバージョンのリリース候補です。

- [BTCPay Server 1.7.11][]は、新しいリリースです。
  前回取り上げたリリース（1.7.1）以降、いくつかの新機能が追加され、多くのバグ修正と改善が行われました。
  特に注目すべきは、プラグインやサードパーティの統合に関するいくつかの変更や
  従来のMySQLやSQLiteからの移行パスの追加、クロスサイトスクリプティングの脆弱性の修正です。

- [BDK 0.27.0][]は、Bitcoinウォレットやアプリケーションを構築するためのこのライブラリのアップデートです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。

- [Core Lightning #5361][]は、ピアストレージバックアップ用の実験的なサポートを追加しました。
  [ニュースレター #147][news147 backups]で最後に掲載したように、
  これによりノードはピア用に暗号化された小さなバックアップファイルを保存できるようになります。
  ピアが後で再接続する必要がある場合（おそらくデータを失った後で）、バックアップファイルを要求することができます。
  ピアは、ウォレットシードから導出した鍵を使用してファイルを復号し、そのコンテンツを使って、
  すべてのチャネルの最新の状態を復元することができます。
  これは[Static Channel Backup][topic static channel backups]の拡張形式とみなすことができます。
  マージされたPRは、暗号化されたバックアップの作成、保存、取得をサポートします。
  コミットメッセージに記載されているように、この機能はまだ完全に仕様化されておらず、他のLN実装に採用されていません。

- [Core Lightning #5670][]および[#5956][core lightning #5956]は、
  最近の[仕様変更][bolts #851]と相互運用性のテスターからのコメントに基づいて、
  [デュアル・ファンディング][topic dual funding]の実装にさまざまなアップデートを行いました。
  さらに、インタラクティブなチャネルオープンに必要な、
  P2SHでラップされたアウトプットのすべての資金をネイティブなsegwitアウトプットに移動させるための
  `upgradewallet` RPCが追加されました。

- [Core Lightning #5697][]は、[BOLT11][]インボイスに署名する`signinvoice` RPCを追加しました。
  以前は、CLNは[HTLC][topic HTLC]のハッシュのプリイメージを持っている場合のみインボイスに署名し、
  インボイスへの支払いを請求できることを保証していました。このRPCは、その動作を上書きすることができ、
  たとえば今インボイスを送信し、後でプラグインを使って別のプログラムからプリイメージを取得するのに使用することができます。
  このRPCを使用する人は誰でも、あなたのノードに向けられた支払いのプリイメージを知っている第三者は、
  その支払いが到着する前にその支払いを請求できることに注意する必要があります。
  これはあなたの資金を盗むだけでなく、あなたがインボイスに署名しているため、
  あなた宛に支払われたという非常に説得力のある証拠を生成します（この証拠は、非常に説得力があるため、
  多くの開発者はこれを*支払いの証明*と呼んでいます）。

- [Core Lightning #5960][]は、連絡先アドレスとPGP鍵を含む[セキュリティポリシー][cln security.md]を追加しました。

- [LND #7171][]は、[MuSig2][topic musig]の最新の[BIPドラフト][musig draft bip]をサポートするよう
  `signrpc` RPCをアップグレードしました。このRPCは、セッション内のすべての操作が正しいプロトコルを使用するように、
  MuSig2プロトコルのバージョン番号にリンクされたセッションを作成するようになりました。
  MuSig2プロトコルの旧バージョンのセキュリティ問題については、[ニュースレター #222][news222 musig2]で言及されています。

- [LDK #2022][]は、最初に成功しなかった[Spontaneous Payment][topic spontaneous payments]を
  自動的に再送信するサポートを追加しました。

- [BTCPay Server #4600][]では、*不要な*インプット、
  特に複数のインプットを含むトランザクションのどのアウトプットよりも大きなインプットを持つトランザクションを作成しないように、
  [Payjoin][topic payjoin]の実装の[コイン選択][topic coin selection]を更新しました。
  これは、通常の単一の支払人、単一の受取人の支払いでは発生しません。最大のインプットは、
  支払いのアウトプットに対して十分な支払いを提供し、追加インプットは発生しないでしょう。
  このPRをは、[Payjoinを分析した論文][paper analyzing payjoins]からヒントを得たものです。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5361,5670,5956,851,5697,5960,7171,2022,4541,4600" %}
[news147 backups]: /ja/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed-bip32
[cln security.md]: https://github.com/ElementsProject/lightning/blob/master/SECURITY.md
[news222 musig2]: /ja/newsletters/2022/10/19/#musig2
[musig draft bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[paper analyzing payjoins]: https://eprint.iacr.org/2022/589.pdf
[bitcoinsearch repos]: https://github.com/bitcoinsearch
[towns color]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021396.html
[nostr]: https://github.com/nostr-protocol/nostr
[allen op_return]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021387.html
[todd or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021435.html
[o'connor or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021439.html
[poelstra or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021438.html
[kogman dilution]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021444.html
[riard dilution]: https://gist.github.com/ariard/7e509bf2c81ea8049fd0c67978c521af#witness-malleability
[kogman dilution2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021459.html
[o'connor tsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021452.html
[bitcoin inquisition #19]: https://github.com/bitcoin-inquisition/bitcoin/issues/19
[bitcoinsearch.xyz]: https://bitcoinsearch.xyz/
[news234 liana]: /ja/newsletters/2023/01/18/#liana
[liana 0.2]: https://github.com/wizardsardine/liana/releases/tag/0.2
[sparrow 1.7.2]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.2
[news235 bip329]: /ja/newsletters/2023/01/25/#bips-1383
[bitcoinex github]: https://github.com/RiverFinancial/bitcoinex
[libwally 0.8.8]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.8
[core lightning 23.02rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc2
[BTCPay Server 1.7.11]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.11
[bdk 0.27.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.0
