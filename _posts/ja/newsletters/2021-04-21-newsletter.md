---
title: 'Bitcoin Optech Newsletter #145'
permalink: /ja/newsletters/2021/04/21/
name: 2021-04-21-newsletter-ja
slug: 2021-04-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Taprootのアクティベーションの進捗、
スタックしている支払いにある程度対応するためのLN Offerのアップデート、
LNDのanchor outputに関するフィードバックのお願い、
スマートコントラクト開発ツールキットSapioの公開について紹介しています。
また、人気のあるクライアントやサービスの変更点、新しいリリースとリリース候補および、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点をまとめた通常のセクションも含まれています。

## ニュース

- **<!--taproot-activation-release-candidate-->Taprootアクティベーションのリリース候補:**
  [先週のニュースレター][news144 activation]で[Taproot][topic taproot]のアクティベーションに関する更新をお伝えしてから、
  Bitcoin Coreプロジェクトは[Speedy Trial][news139 speedy trial]のアクティベーションの仕組みを実装した[プルリクエスト][Bitcoin Core #21377]と、
  アクティベーションパラメータを含む[２つめのPR][Bitcoin Core #21686]をマージしました。
  これらのPRと他のいくつかのPRは、現在Bitcoin Core 0.21.1の最初のリリース候補（RC）の一部になっています。
  テストやその他の品質保証作業は、このニュースレターの発行後、すくなくとも数日間は継続される予定です。
  詳細については、以下のRCおよびマージ概要のセクションを参照ください。

- **<!--using-ln-offers-to-partly-address-stuck-payments-->LN offerを利用してスタックした支払いに一部対処:**
  LNインボイスへの支払いをしようとした際、場合によっては、支払いが長期間スタックする場合があります。
  障害が解決するまでの間に、2つめのインボイスを要求し2回めの支払いをすると、2回分の支払いをすることになります。

    今週、Rusty Russellは、支払いの受領者が前のインボイスに取って代わる新しいインボイスにコミットできるようにする
    [Offer][topic offers]の仕様案の変更をLightning-Devメーリングリストに[投稿しました][russell invoice cancel]。
    送信者が2つめのインボイスに支払いをした場合、二重支払いになるリスクは残りますが、
    Offerの受領者の署名とLN固有の支払いの証明を組み合わせることで、
    両方の支払いが受理された場合に、送信者は受領者が不正な行動をしたことを証明することができます。
    人気のあるビジネスなど、定評のある受領者に支払う場合は、大きな問題である支払いのスタックを解消できる可能性があります。

    Offer仕様の更新により、受領者は支払いを受け取り、問題は下流のノードにあることを示すことができます。
    その場合、送信者と受領者、両者の資金は完全に安全で、ただ、
    送信者が特定の支払いスロット（[HTLC][topic htlc]スロット）を再利用できるようになるまで
    しばらく待つ必要があるだけです。このような対話的なコミュニケーションが可能な点は、
    通常のインボイスに比べてOfferの明らかな利点です。

- **<!--using-anchor-outputs-by-default-in-lnd-->LNDのanchor outputのデフォルト利用:**
  Olaoluwa Osuntokunは、LNDの次期メジャーバージョンではデフォルトで
  [anchor output][topic anchor outputs]を使用したいという要望をLNDの開発者メーリングリストに[投稿しました][osuntokun anchor]。
  anchor outputにより、チャネルを閉鎖した未承認のLNコミットメントトランザクションの手数料を
  [CPFP][topic cpfp]で引き上げることができます。残念ながら、
  LNモデルでのCPFPの手数料の引き上げにはいくつかの課題があります:

    - *<!--not-always-optional-->必ずしもオプションではない:*
      通常のオンチェーントランザクションでは、多くのユーザーは手数料を引き上げるのではなく、
      トランザクションが承認されるまで長く待つことができます。LNでは、
      待つという選択肢がない場合もあり、その場合、
      数時間以内に手数料の引き上げを行わないと資金が失われる可能性があります。

    - *<!--timelocked-outputs-->タイムロックされたアウトプット:*
      ほとんとの通常のオンチェーン支払いでは、CPFPで手数料を引き上げたいユーザーは、
      引き上げたいトランザクションのアウトプットに保持されている資金を使って、
      手数料を引き上げることができます。LNの場合、
      これらの資金はチャネルの閉鎖がオンチェーンで完全に決済されるまで利用できません。
      つまり、ユーザーは手数料を支払うために別のUTXOを使用する必要があります。

    上記の２つの懸念に対処するために、LNDは、anchor outputのユーザーに対して、
    チャネルが開いている間、すくなくとも１つの適切な値を持つ承認済みのUTXOをウォレットに保持するよう要求しています。
    これにより必要に応じてCPFPの手数料引き上げを確実に負担できますが、
    すくなくともチャネルが開いている間は、最後のオンチェーン資金を
    （新しいチャネルを開くためであっても）使用することができないといった影響が生じます。

    Osuntokunの要望は、LND上に構築されたウォレットやサービスに対して、
    これらの懸念やanchor outputに関するその他の懸念事項が深刻な問題を引き起こすかどうかを開発チームに通知することです。
    質問はLND固有のものですが、回答はすべてのLNノードに影響を与える可能性があります。

- **<!--sapio-public-launch-->Sapioの一般公開:**
  Jeremy Rubinは、Bitcoin-Devメーリングリストに、
  スマートコントラクト開発ツールキットSapioを公開したというアナウンスを[投稿しました][rubin sapio]。
  Sapioは、Bitcoin Scriptを使って表現可能なスマートコントラクトを作成するためのRustベースのライブラリと関連ツールです。
  この言語はもともとRubinが提案した[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] opcode (`OP_CTV`)
  を利用するために設計されたものですが、信頼できる署名オラクルを使って、
  そのopcodeやtaprootなどのBitcoinの潜在的な機能をシミュレートできます。
  このリリースには、Sapioライブラリに加えて、広範なドキュメント実験的なフロントエンドも含まれています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Specter v1.3.0 リリース:**
  [Specter v1.3.0][]には、RBFの追加サポート、アプリケーション内でのBitcoin Coreのセットアップ、
  HWI 2のサポート、[ブロックエクスプローラ][topic block explorers]や手数料の見積もりに
  [mempool.space][news132 mempool.space]を使用するオプションが含まれています。

- **Specter-DIY v1.5.0:**
  ハードウェアウォレットファームウェアSpecter-DIYは、カスタムSIGHASHフラグのサポートと
  [miniscript][topic miniscript]を含む完全な[descriptor][topic descriptors]のサポートを追加した
  v1.5.0を[リリースしました][specter-diy github]。

- **BlueWallet v6.0.7がメッセージ署名機能を追加:**
  [BlueWallet v6.0.7][bluewallet v6.0.7]では、Bitcoinアドレスを使ったメッセージの署名と検証が可能になり、
  その他の機能や修正も行われています。

- **AztecoがLightningのサポートを発表:**
  Bitcoinのバウチャー企業Aztecoは、
  Lightning Networkを介して購入したビットコインの交換のサポートを[発表しました][azteco lightning blog]。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1]は、Bitcoin Coreのリリース候補で、
  このリリースが有効になると、[Schnorr署名][topic schnorr signatures]や[Tapscript][topic tapscript]の使用が可能になる
  [Taproot][topic taproot]の提案のソフトフォークのルールを適用します。
  これらは、それぞれBIP [341][BIP341]、[340][BIP340]および[342][BIP342]で定義されています。
  また、[BIP350][]で定義された[bech32m][topic bech32]アドレスへの支払いを行う機能も含まれていますが、
  mainnet上でそのようなアドレスに送金されるビットコインは、
  taprootなどのそのようなアドレスを使用するソフトフォークがアクティベートされるまで安全ではありません。
  この他にもバグ修正や小さな改善が行われています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21377][]では、Taprootソフトフォークのためのアクティベーションの仕組みが、
  [#21686][Bitcoin Core #21686]ではアクティベーションパラメータが追加されました。
  4月24日以降の最初の難易度調整から、
  マイナーはビット 2を使ってTaprootのアクティベーションの準備完了を通知できるようになります。
  通知期間内の1つの難易度調整期間の2016ブロックの内1815（90%）が準備完了の通知を送ると、
  ソフトフォークのアクティベーションはロックインされます。通知期間は、
  8月11日以降の最初の難易度調整期間で終了します。ロックインされると、
  11月12日頃に到達すると予想されるブロック高709632でTaprootがアクティベートされます。

- [Bitcoin Core #21602][] は、`listbanned`RPCに`ban_duration`と
  `time_remaining`という2つフィールドを追加する更新をしました。

- [C-Lightning #4444][]は、C-LightningのContinuous Integration (CI)テストの
  デフォルトターゲットに[lnprototest][] (LN Protocol Test)を追加し、
  開発者がC-Lightningの通常のビルドシステムからテストを実行するのをより簡単にしました。
  LN Protocol Testは、実装が[LNプロトコル仕様][ln protocol specification]に従っているかどうかを簡単にテストできます。

- [LND #4588][]は、お釣りの額がとても少なく、それを使用するにのかかるコストより金額が低い場合、
  お釣り用のアウトプットの作成をスキップします。

- [LND #5193][]は、（[Compact Block Filter][topic compact block filters]プロトコルを実装している）
  Neutrinoクライアントを使用するLNDインスタンスでは、デフォルトでチャネル検証を無効にします。
  このオプションは、ピアから受け取ったチャネル通知が正しいことを前提としているため、
  クライアントはこれらの通知を検証するために必要な古いブロックをダウンロードする必要がありません。
  これには誤って通知されたチャネルを使って支払いを行おうとしても失敗するという欠点があり、
  時間を無駄にしますが、資金の損失は発生しません。
  これは軽量クライアントの使用を既に選択している人にとっては合理的なトレードオフです。
  この新しいデフォルト動作は、新しい設定オプション`--neutrino.validatechannels=true`を使って無効にすることができます。

- [LND #5154][]は、プルーニングされたフルノードでLNDを使用するための基本的なサポートを追加し、
  LNDがローカルノードによって削除されたブロックを外部のBitcoinノードに要求できるようにします。
  LNDはプルーニングされたノードを経由することなく、ブロックから必要な情報を抽出することができます。
  ユーザー自身のフルノードが前にブロックを検証しているため、これによってセキュリティモデルが変わることはありません。

- [LND #5187][]に、新しい`channel-commit-interval`と`channel-commit-batch-size`パラメータが追加されました。
  このパラメータを使ってLNDがチャネルの状態を更新するまでの待ち時間と、1回の更新で送信する最大の変更数を設定できます。
  これらの値が高いほど、ビジー状態のLNDノードはより効率的になりますが、その代償としてレイテンシーが若干高くなります。

- [Rust-Lightning #858][]は、Electrumスタイルのブロックチェーンデータソースと相互運用するための内部サポートを追加します。

- [Rust-Lightning #856][]は、ファンディング・トランザクションの処理方法を更新しました。
  これまでウォレットは、新しいチャネルを開くファンディング・トランザクションを作成し、
  そのtxidのみをRust Lightningに渡すようになっていました。今回の変更で、
  Rust Lightningは完全なファンディング・トランザクションを受け入れるようになりました。
  C-Lightningの最近の変更（[ニュースレター #141][news141 cl funding]参照）と同様に、
  これによりLNソフトウェアがファンディング・トランザクションをブロードキャスト前にチェックし、
  それが正しいことを確認することができます。

- [HWI #498][]は、BitBox02ハードウェアウォレットを使った任意のBitcoinスタイルのメッセージへの署名のサポートを追加しました。

- [BTCPay Server #2425][]は、BTCPayインボイスに関連付けられていないアドレスに対しても、
  ウォレットの[PayJoin][topic payjoin]支払いの受信のサポートを追加します。

{% include references.md %}
{% include linkers/issues.md issues="21377,21686,21602,4444,4588,5193,5154,5187,858,856,498,2425" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[news139 speedy trial]: /ja/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[russell invoice cancel]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002992.html
[osuntokun anchor]: https://groups.google.com/a/lightning.engineering/g/lnd/c/OuC56qq6IaY
[rubin sapio]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018759.html
[lnprototest]: https://github.com/rustyrussell/lnprototest
[ln protocol specification]: https://github.com/lightningnetwork/lightning-rfc/
[news141 cl funding]: /ja/newsletters/2021/03/24/#c-lightning-4428
[news144 activation]: /ja/newsletters/2021/04/14/#taproot-activation-discussion-taproot
[specter v1.3.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.3.0
[news132 mempool.space]: /ja/newsletters/2021/01/20/#mempool-v2-0-0
[specter-diy github]: https://github.com/cryptoadvance/specter-diy/releases
[bluewallet v6.0.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.0.7
[azteco lightning blog]: https://medium.com/@Azteco_/at-azteco-weve-been-experimenting-with-lightning-for-over-a-year-refining-our-thinking-and-user-b9d112cff13c
