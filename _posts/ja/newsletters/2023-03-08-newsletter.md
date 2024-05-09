---
title: 'Bitcoin Optech Newsletter #241'
permalink: /ja/newsletters/2023/03/08/
name: 2023-03-08-newsletter-ja
slug: 2023-03-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、いくつかの利点がある`OP_VAULT`の代替設計の提案と、
新しい週刊Optechポッドキャストの発表を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、
新しいソフトウェアリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **OP_VAULTの代替設計:** Greg Sandersは、
  `OP_VAULT`/`OP_UNVAULT`の提案機能（[ニュースレター #234][news234 vault]参照）を提供するための代替設計を
  Bitcoin-Devメーリングリストに[投稿しました][sanders vault]。
  彼の代替案は、2つではなく3つのopcodeを追加するものです。例を挙げると:

  - *<!--alice-deposits-funds-in-a-vault-->*
    アリスは、少なくとも2つの[リーフスクリプト][topic tapscript]を含むスクリプトツリーを持つ
    [P2TRアウトプット][topic taproot]に支払いをすることで資金をVault（金庫）にデポジットします。
    このうち１つは、時間遅延のあるUnvault（引き出し）処理をトリガーできるもので、
    もう１つは、即座に資金を凍結するものです。例：`tr(key,{trigger,freeze})`

    - *<!--trigger-leafscript-->トリガー・リーフスクリプト*には、
      （アリスのホットウォレットに署名を要求するような）信頼性の低い認可条件と、
      `OP_TRIGGER_FORWARD` opcodeが含まれています。アリスはこのリーフスクリプトを作成する際に、
      *支払い遅延*パラメーター（たとえば1,000ブロック（約1週間）の相対タイムロック）を提供します。

    - *<!--freeze-leafscript-->フリーズ・リーフスクリプト*には、
      アリスが指定したい認可条件（無くても良い）と`OP_FORWARD_DESTINATION` opcodeが含まれています。
      アリスはこのリーフスクリプトを作成する際に、
      （コールドウォレットやハードウェア署名デバイスに複数の署名を要求するような）
      より信頼性の高い認可条件を選択します。アリスは、
      ハッシュダイジェストの形でこれらの条件へのコミットメントをopcodeに提供します。

  - *<!--alice-triggers-an-unvaulting-->*
    アリスは、上記のスクリプトツリー宛のアウトプットのトリガー・リーフスクリプトを使用することで（インプットとして使用することで）、
    Unvault（引き出し処理）をトリガーします。この時点で、
    彼女は`OP_TRIGGER_FORWARD` opcodeに2つのパラメーターを提供します。
    1つはこのインプットの資金を受け取るアウトプットのインデックスで、
    もう１つはこの後資金を使用する際の方法についてのハッシュベースのコミットメントです。
    opcodeは、トランザクションの指示されたアウトプットが、
    トリガー・リーフスクリプトが前に指定された遅延（たとえば1,000ブロック）と等しい
    `OP_CHECKSEQUENCEVERIFY`(CSV)による相対遅延と
    アリスのコミットメントハッシュを含む`OP_FORWARD_OUTPUTS` opcodeで置き換えられていることを除いて、
    使用しようとしているスクリプトツリーと同様のスクリプトツリーを持つP2TRアウトプットに支払いをしているか検証します。
    スクリプトツリーを再構築する方法は、以前の[Covenant][topic covenants]の提案である
    `OP_TAPLEAF_UPDATE_VERIFY`（[ニュースレター #166][news166 tluv]参照）と似ています。

  - *<!--alice-completes-the-unvaulting-->* アリスは、相対タイムロックが切れるまで待ち、
    `OP_FORWARD_OUTPUTS` opcodeを持つtapleafを選択してUnvaultアウトプットを使用することで引き出しを完了させます。
    opcodeは、このトランザクションのアウトプットの金額と
    スクリプトのハッシュがアリスが前のトランザクションで作成したコミットメントと同じか検証します。
    このケースでは、アリスは資金をVaultに預け入れ、引き出しを開始し、
    アリスの監視プログラムが指定されたアウトプット宛の意図された支払いか確認するために少なくとも1,000ブロック待ち、
    支払いが完了したことになります。

  - *<!--alice-freezes-the-funds-->* 何か問題が発生した場合、アリスは資金を凍結します。
    彼女は、資金をVaultに預けた瞬間から引き出しが完了するまでの間、いつでもこの処理を行うことができます。
    資金を凍結するためには、彼女は単純にVaultトランザクションまたはトリガートランザクションのアウトプットを
    フリーズ・リーフスクリプトを使って使用する選択をします。
    アリスがVaultトランザクションで明示的にフリーズ・リーフスクリプトを配置したことを思い出してください。
    また、それが引き出しを開始するトリガートランザクションにも暗黙的に継承されていることに注意してください。

  元の`OP_VAULT`の設計と比べたこのアプローチの利点の１つは、
  フリーズ・リーフスクリプトにアリスが指定したい任意の認可条件を含めることができる点です。
  `OP_VAULT`の提案では、アリスが選択したパラメーターを知る者は誰でも、
  彼女の資金をフリーズ・スクリプト宛に使用することができました。
  これはセキュリティ上の問題にはなりませんが、迷惑になります。
  Sandersの設計では、アリスは（たとえば）凍結を開始するのに非常に軽量の保護されたウォレットに署名を要求することができます。
  これはおそらく、ほんとどの嫌がらせ目的の攻撃を防ぐのに十分な負担となりますが、
  アリスが緊急時に素早く資金を凍結するのを妨げるほどの障壁ではありません。

  他のいくつかの利点は、コンセンサスで強制される[Vaultプロトコル][topic vaults]をより理解しやすくし、
  安全性を検証しやすくすることを目的としています。上記の記事を書いた後、
  `OP_VAULT`の提案者であるJames O'Beirneは、Sandersのアイディアに好意的な返事をしました。
  O'Beirneはさらなる変更のアイディアも持っていたため、今後のニュースレターで紹介する予定です。

- **新しいOptech Podcast:** Twitterスペースで毎週開催されているOptech Audio Recapが
  ポッドキャストとして提供されるようになりました。各エピソードは、
  すべての一般的なポッドキャストプラットフォームやOptechのウェブサイトでの書き起こしで利用できます。
  Bitcoinの技術的なコミュニケーションを向上させるというOptechのミッションにおいて、
  これが大きな前進であると考える理由など、詳細は[ブログ記事][podcast post]をご覧ください。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Bitcoin-inquisition: Activation logic for testing consensus changes][review club bi-16]は、
Anthony TownsによるPRで、[Bitcoin Inquisition][]プロジェクトでソフトフォークをアクティベート、
非アクティベートするための新しい方法を追加しています。
これは、[signet][topic signet]で実行されテストに使用されるよう設計されています。
このプロジェクトについては、[ニュースレター #219][newsletter #219 bi]で取り上げています。

具体的には、このPRは[BIP9][]のブロックのバージョンビットを使用する方法を[Heretical Deployments][]と呼ばれるものに置き換えます。
mainnetでのコンセンサスやリレーの変更は、慎重な（人間の）コンセンサスの構築と
精巧な[ソフトフォークのアクティベーション][topic soft fork activation]メカニズムを必要とするため、
アクティベートするのが困難で時間がかかりますが、
テスト用のネットワークではこれらの変更のアクティベートを効率化できます。
このPRでは、バグや望ましくないことが判明した変更を無効化する方法も実装されており、
これはmainnetとは大きく異なる点です。

{% include functions/details-list.md
  q0="なぜBitcoin Coreにマージされていないコンセンサスの変更をデプロイしたいのですか？
      Bitcoin Coreにコードをマージし、その後でsignetでテストすることに（あるとしたら）どんな問題があるのでしょうか？"
  a0="いくつかの理由が議論されました。mainnetユーザーが実行しているCoreのバージョンのアップグレードを要求できないので、
      バグが修正された後でも、一部のユーザーはバグのあるバージョンを実行し続ける可能性があります。
      regtestのみに依存すると、サードパーティ製のソフトウェアの統合テストが難しくなります。
      コンセンサスの変更を別のリポジトリにマージすることは、Coreにマージするよりもリスクが低くなります。
      アクティベートされてなくても、ソフトフォークロジックを追加すると既存の動作に影響を与えるバグを導入する可能性があります。"
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-37"

  q1="Heretical Deploymentsは、BIP9の状態（`DEFINED`、`STARTED`、`LOCKED_IN`、`ACTIVE`、`FAILED`）に似た
      有限状態マシンの一連の状態を遷移しますが、`ACTIVE`の後に`DEACTIVATING`という状態が追加されます（
      その後に最終の状態`ABANDONED`が続きます）。状態`DEACTIVATING`の目的は何ですか？"
  a1="ソフトフォークにロックされた資金を引き出す機会をユーザーに提供するためのものです。
      フォークが非アクティベートもしくはリプレースされると、ユーザーはその資金を使用できなくなる可能性があります。
      たとえそれが誰でも使用可能な資金であったとしてもです。Txが非標準となり拒否されると使用できなくなります。
      懸念されるのは、限定されたsignetの資金が永久に失われることではなく、UTXOセットが肥大化する可能性があることです。"
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-92"

  q2="なぜこのPRでは`min_activation_height`が削除されているのですか？"
  a2="新しい状態モデルでは、ロックインとアクティベーションの間に設定可能な間隔はありません。
      Heretical Deploymentsでは、次の432ブロック（3日間）の状態マシン期間の開始時に自動的にアクティベートされます
      （この期間はHeretical Deploymentsでは固定されています）。"
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-126"

  q3="TaprootがこのPRに埋め込まれているのはどうしてですか？"
  a3="埋め込まなければ、それをHeretical Deploymentにする必要があり、コーディングの手間がかかります。
      また、そうするといずれタイムアウトになりますが、Taprootは決してタイムアウトしないようにする必要があります。"
  a3link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-147"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.02][]は、この人気のLN実装の新バージョンのリリースです。
  これには、バックアップデータのピアストレージ（[ニュースレター #238][news238 peer storage]参照）の実験的なサポートや、
  [デュアル・ファンディング][topic dual funding]や[Offer][topic offers]の実験的なサポートの更新が含まれています。
  また、その他にもいくつかの改善とバグ修正が含まれています。

- [LDK v0.0.114][]は、LN対応のウォレットやアプリケーションを構築するためのこのライブラリの新バージョンのリリースです。
  いくつかのセキュリティ関連のバグが修正され、[Offer][topic offers]を解析する機能が追加されています。

- [BTCPay 1.8.2][]は、この人気のあるBitcoin用のセルフホスト型ペイメントプロセッサソフトウェアの最新リリースです。
  バージョン1.8.0のリリースノートには、「このバージョンでは、カスタムチェックアウトフォームや、
  店舗のブランディングオプション、再設計されたPOSキーパッド、新しい通知アイコンとアドレスラベルが追加されました。」とあります。

- [LND v0.16.0-beta.rc2][]は、この人気のLN実装の新しいメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [LND #7462][]では、リモート署名とステートレスinit機能を使用した監視専用ウォレットの作成が可能になりました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="7462" %}
[core lightning 23.02]: https://github.com/ElementsProject/lightning/releases/tag/v23.02
[lnd v0.16.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc2
[LDK v0.0.114]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.114
[BTCPay 1.8.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.8.2
[podcast post]: /ja/podcast-announcement/
[sanders vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021510.html
[news234 vault]: /ja/newsletters/2023/01/18/#vault-opcode
[news166 tluv]: /ja/newsletters/2021/09/15/#covenant-opcode-proposal-covenant-opcode
[news238 peer storage]: /ja/newsletters/2023/02/15/#core-lightning-5361
[newsletter #219 bi]: /ja/newsletters/2022/09/28/#signet-bitcoin
[review club bi-16]: https://bitcoincore.reviews/bitcoin-inquisition-16
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[heretical deployments]: https://github.com/bitcoin-inquisition/bitcoin/wiki/Heretical-Deployments
[bip9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
