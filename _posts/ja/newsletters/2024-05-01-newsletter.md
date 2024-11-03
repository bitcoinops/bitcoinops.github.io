---
title: 'Bitcoin Optech Newsletter #300'
permalink: /ja/newsletters/2024/05/01/
name: 2024-05-01-newsletter-ja
slug: 2024-05-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、公開鍵に埋め込まれたコミットメントを使用するCTVのような提案と、
Alloyを用いたコントラクトプロトコルの分析の検討、Bitcoin開発者の逮捕の発表、
CoreDev.tech開発者ミートアップの要約のリンクを掲載しています。また、
新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **CTVのようなExploding Keysの提案:**
  Tadge Dryjaは、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）の中心となるアイディアの
  もう少し効率的なバージョンの提案をDelving Bitcoinに[投稿しました][dryja exploding]。
  CTVを使用すると、アリスは以下のようなアウトプットに対して支払いを行うことができます:

  ```text
  OP_CTV <hash>
  ```

  ハッシュダイジェストのプリイメージは、トランザクションの主要な部分、
  特に各アウトプットの金額や各アウトプットのスクリプトに対するコミットメントです。たとえば以下のような:

  ```text
  hash(
    2 BTCをKeyBへ,
    3 BTCをKeyCへ,
    4 BTCをKeyDへ
  )
  ```

  `OP_CTV` opcodeは、これらのパラメーターと正確に一致するトランザクションで実行された場合に成功します。
  つまり、あるトランザクション内のアリスのアウトプットは、
  その次のトランザクションがアリスの期待と一致するものであれば、追加の署名や他のデータを必要とせずに、
  その次のトランザクションで使用することができます。

  Dryjaは、別の方法を提案しています。アリスは公開鍵に支払いをします（
  [Taproot][topic taproot]アウトプットに似ていますが、segwit versionが異なります）。
  その公開鍵は、1つ以上の実際の公開鍵と安全に金額にコミットする各鍵用のtweakの[MuSig2][topic musig]による集約で構築されます。
  たとえば（Dryjaの投稿からの抜粋）:

  ```text
  musig2(
    KeyB + hash(2 BTC, KeyB)*G,
    KeyC + hash(3 BTC, KeyC)*G,
    KeyD + hash(4 BTC, KeyD)*G
  )
  ```

  トランザクションは、基礎となる公開鍵に指定された金額を正確に支払った場合に有効になります。
  その場合、署名は必要ありません。Taprootを利用するCTVと比較すると、
  スペースがいくらか節約され、最小で約16 vbyteの節約になります。
  素のスクリプト（つまり、アウトプットスクリプトに直接記述されたもの）のCTVと比較すると、
  ほぼ同じスペースを使用するようです。

  CTVがTaprootで使用される場合、参加者全員が互いに合意したkeypath支払いがCTV実行の代替として提供され、
  参加者が資金の宛先を変更できるようになります。Exploding Keysは、
  KeyB、KeyC、KeyDを管理する人々によって同じことを可能にします。効率はどちらも同じです。

  Dryjaは、Exploding Keysは「OP_CTVの基本的な機能を提供する一方で、witnessデータを数バイト節約できます。
  それ自体ははそれほど魅力的ではないかもしれませんが、より複雑なコベナンツ構築の一部として便利なプリミティブになる可能性があるため、
  ここに紹介します」と書いています。

- **Alloyを使用したコントラクトプロトコルの分析:** Dmitry Petukhovは、
  [ニュースレター #291][news291 catvault]に掲載されたシンプルな`OP_CAT`ベースのVault用に
  [Alloy][]仕様言語を使用して作成した[仕様][petukhov spec]をDelving Bitcoinに[投稿しました][petukhov alloy]。
  Petukhovは、Alloyを使用していくつかの有用な修正を[見つけ][petukhov mods]、実装者が遵守すべき重要な制約を強調しました。
  コントラクトプロトコルの正式なモデリングに興味がある人は、
  彼の投稿と広範に文書化された仕様を読むことをお勧めします。

- **Bitcoin開発者の逮捕:** 他でも広く報道されているように、先週、米国司法当局の告発に基づき、
  プライバシーを強化したBitcoinウォレットSamouraiの開発者2名がソフトウェアに関連して逮捕されました。
  その後、他の2社が法的リスクを理由に米国顧客向けのサービス提供を停止する意向を発表しました。

  Optechの専門分野は、Bitcoin技術について執筆することであるため、
  この法的状況についての報道は他の出版物に任せる予定ですが、
  Bitcoinの成功に興味がある人、特に米国内または米国人とのつながりがある人は、
  常に最新情報を入手し、機会があればサポートの提供を検討してください。

- **CoreDev.techベルリンのイベント:** 多くのBitcoin Coreコントリビューターが、
  先月ベルリンで開催された定期的な[coredev.tech][]イベントに直接集まりました。
  このイベントのいくつかのセッションの[トランスクリプト][coredev xs]が参加者から提供されました。
  プレゼンテーションやコードレビュー、ワーキンググループ、その他のセッションが対象です:

  - ASMapの研究結果
  - assumeUTXOのmainnetの準備状況
  - BTC Lisp
  - CMake
  - クラスターmempool
  - コイン選択
  - インプットをまたいだ署名の集約
  - 現在のネットワークスパム
  - 手数料の推定
  - BIPに関する一般的な議論
  - グレートコンセンサスクリーンアップ
  - GUIの議論
  - レガシーウォレットの削除
  - libbitcoinkernel
  - MuSig2
  - P2Pのモニタリング
  - パッケージリレーのレビュー
  - プライベートトランザクションのブロードキャスト
  - 現在のGitHub Issueのレビュー
  - 現在のGitHub PRのレビュー
  - signet/testnet4
  - サイレントペイメント
  - Stratum v2テンプレートプロバイダー
  - warnet
  - 弱ブロック
  - その他のトピック

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Inquisition 25.2][]は、プロトコルの変更を[signet][topic signet]上でテストするために設計された
  この実験的なフルノード実装の最新リリースです。最新バージョンでは、
  signetで[OP_CAT][topic op_cat]のサポートが追加されています。

- [LND v0.18.0-beta.rc1][]は、この人気のLNノードの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #27679][]では、[ZMQ][]ディスパッチャーを使用して送信された通知を、
  Unixドメインソケットに発行できるようになりました。これは以前は、
  文書化されていない方法で設定オプションを渡すことで（おそらく意図せずに）サポートされていました。
  [Bitcoin Core #22087][]は設定オプションのパースをより厳密にし、
  Bitcoin Core 27.0でこの文書化されていないサポートを破壊し、
  [LND][gugger zmq]やおそらく他のプログラムにも影響を与えました。
  このPRでは、このオプションが正式にサポートされ、[ニュースレター #294][news294 sockets]で説明されている変更など、
  Bitcoin CoreのUnixソケットの他のオプションとの一貫性をもたせるためにセマンティクスがわずかに変更されています。

- [Core Lightning #7240][]は、ローカルのBitcoinノードが必要なブロックをプルーニングした場合に、
  P2Pネットワークから必要なブロックを取得するためのサポートを追加しています。
  CLNノードがローカルの`bitcoind`によってプルーニングされたブロックを必要とする場合、
  Bitcoin Coreの`getblockfrompeer` RPCを呼び出し、ピアにブロックを要求します。
  ブロックが正常に取得されると、 Bitcoin Coreは、
  ブロックを保持するヘッダーに接続してそのブロックを認証し（プルーニングされたブロックであっても）、ローカルに保存します。
  保存されたブロックは標準のブロック取得RPCを使って取得できるようになります。

- [Eclair #2851][]は、Bitcoin Core 26.1以降に依存するようになり、
  祖先を意識したファンディング用のコードを削除しました。代わりに、このアップグレードにより、
  手数料不足を補うように設計されたBitcoin Coreの新しいネイティブコードを使用できるようになります（
  [ニュースレター #269][news269 fee deficit]参照）。

- [LND #8147][]、[#8422][lnd #8422]、[#8423][lnd #8423]、[#8148][lnd #8148]、
  [#8667][lnd #8667]および[#8674][lnd #8674]は、LNDの古いスイーパーを新しい実装に置き換え、
  決済トランザクションとそれらの効果的な手数料の引き上げに必要なトランザクションのブロードキャストを可能にします。
  新旧の実装はどちらも、トランザクションが承認されなければならない期限や使用する開始手数料率など、
  ほとんど同じパラメーターを受け付けます。新しい実装では、手数料として支払う最大額である`budget`も追加されています。
  新しい実装では、より多くの設定が可能になり、テストの記述が容易になり、
  [CPFP][topic cpfp]と[RBF][topic rbf]両方の手数料引き上げを（適切な場合にそれぞれ）利用できるようになり、
  手数料の引き上げをバッチ処理することで手数料を節約し、手数料率は30秒毎ではなくブロック毎に更新するようになっています。

- [LND #8627][]は、ゼロを超える _インバウンド転送手数料_ を必要とするチャネル設定の変更をユーザーが要求した場合に、
  デフォルで拒否するようになりました。たとえば、アリスがボブを介してキャロルに支払いを転送したいケースを考えてみてください。
  デフォルトでは、ボブはインバウンド転送手数料用に新しく追加されたLNDの機能（[ニュースレター #297][news297 inbound]参照）を
  使用してアリスに追加手数料の支払いを要求することができなくなりました。この新しいデフォルトの挙動は、
  ボブのノードがインバウンド転送手数料をサポートしないノード（現在ほとんどすべてのLNノード）との互換性を保つことを保証します。
  ボブは、LNDの`accept-positive-inbound-fees`の設定でデフォルトを上書きすることで、後方互換性を失うことを選択することもできます。
  または、キャロルへのアウトバウンド転送手数料を引き上げてから、
  アリス以外からの支払いに割引を提供するためにマイナスのインバウンド転送手数料を使用することで、
  後方互換性を維持しながら望ましい結果を達成できる可能性があります。

- [Libsecp256k1 #1058][]は、公開鍵と署名を生成するアルゴリズムを変更しました。
  古いアルゴリズムと新しいアルゴリズムはどちらも、
  タイミング[サイドチャネル][topic side channels]の脆弱性を回避するために定数時間で実行されます。
  新しいアルゴリズムのベンチマークでは、約12%高速化されていました。
  PRのレビュアーの1人による[短いブログ記事][stratospher comb]では、
  新しいアルゴリズムがどのように機能するかについて説明しています。

- [BIPs #1382][]は、[祖先パッケージリレー][topic package relay]の提案に[BIP331][]を割り当てました。

- [BIPs #1068][]は、[BIP47][]バージョン1の再利用可能なペイメントコードの2つのパラメーターを交換し、
  Samouraiの実装と一致させています。再利用可能なペイメントコードの新しいバージョンに関する情報の入手先の詳細もBIPに追加されています。
  SamouraiによるBIP47の最初の実装は数年前に行われ、このPRは先週マージされるまで3年以上オープンされていたことに注意してください。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27679,7240,2851,22087,8147,8422,8423,8148,8667,8627,1058,1382,1068,8674" %}
[gugger zmq]: https://github.com/lightningnetwork/lnd/pull/8664#issuecomment-2065802617
[news269 fee deficit]: /ja/newsletters/2023/09/20/#bitcoin-core-26152
[news 297 inbound]: /ja/newsletters/2024/04/10/#lnd-6703
[stratospher comb]: https://github.com/stratospher/blogosphere/blob/main/sdmc.md
[petukhov alloy]: https://delvingbitcoin.org/t/analyzing-simple-vault-covenant-with-alloy/819
[petukhov mods]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576/16
[petukhov spec]: https://gist.github.com/dgpv/514134c9727653b64d675d7513f983dd
[alloy]: https://en.wikipedia.org/wiki/Alloy_(specification_language)
[dryja exploding]: https://delvingbitcoin.org/t/exploding-keys-covenant-construction/832
[zmq]: https://en.wikipedia.org/wiki/ZeroMQ
[news291 catvault]: /ja/newsletters/2024/02/28/#op-cat-vault
[news297 inbound]: /ja/newsletters/2024/04/10/#lnd-6703
[news294 sockets]: /ja/newsletters/2024/03/20/#bitcoin-core-27375
[bitcoin inquisition 25.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v25.2-inq
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[coredev.tech]: https://coredev.tech/
[coredev xs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-04/