---
title: 'Bitcoin Optech Newsletter #252'
permalink: /ja/newsletters/2023/05/24/
name: 2023-05-24-newsletter-ja
slug: 2023-05-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinおよび関連プロトコルのためのゼロ知識Validity Proofに関する研究を掲載しています。
また、mempoolポリシーに関する限定週刊シリーズの新しい記事や、
クライアントとサービスのアップデート、新しいリリースとリリース候補、
人気のあるBitcoinインフラストラクチャプロジェクトの変更など、恒例のセクションも含まれています。

## ニュース

- **ゼロ知識Validity Proofによる状態の圧縮:** Robin Linusは、
  システムにおける将来の操作をトラストレスに検証するためにクライアントがダウンロードする必要のある状態の量を削減するために
  Validity Proofを使用することについて、Lukas Georgeと共著の[論文][lg paper]を
  Bitcoin-Devメーリングリストに[投稿しました][linus post]。
  彼らはまず、彼らのシステムにBitcoinを適用しました。
  ブロックヘッダーのチェーンにおけるProof of Workの累積量を証明し、
  特定のブロックヘッダーがそのチェーンの一部であることをクライアントが検証できるプロトタイプができたことを報告しています。
  これにより、複数のプルーフを受け取ったクライアントは、どのProof of Workが最も作業量が多いかを判断できるようになります。

  また、ブロックチェーンのすべてのトランザクションの状態変化が通貨のルール（
  たとえば、新しいブロックによって作成されるビットコインの量、
  非コインベースの各トランザクションが破棄（使用）したビットコインよりも多くの量を持つUTXOを作成してはならないこと、
  マイナーはブロックで破棄されたUTXOと作成されたUTXOの差額を請求できることなど）を遵守していることを証明する次善のプロトタイプもあります。
  このプルーフと現在のUTXOセットのコピーを受け取ったクライアントは、
  そのセットが正確かつ安全であることを検証することができます。
  多くのコントリビューターが自身のノードでこれらのブロックをすべて正常に検証したことに同意した場合に、
  古いブロックのスクリプトの検証をオプションでスキップする[Bitcoin Coreの機能][assumevalid]にちなんで、
  彼らはこれを _assumevalid_ プルーフと呼んでいます。

  プルーフの複雑さを最小限にするため、彼らは、
  彼らのシステムに最適化されたハッシュ関数を使用したバージョンの[Utreexo][topic utreexo]を使用しています。
  また、このプルーフとUtreexoクライントを組み合わせることで、
  非常に少量のデータをダウンロードした後、そのクライアントがすぐにフルノードとして動作し始めることができるようになると述べています。

  プロトタイプの有用性に関しては、
  「ヘッダーチェーンのプルーフとassumevalidステートプルーフをプロトタイプとして実装しています。
  前者は証明可能ですが、後者は妥当なサイズのブロックを証明するためにはまだ性能改善が必要です。」と書かれています。
  また、スクリプトを含む完全なブロックの検証にも取り組んでいますが、
  その実現には少なくとも40倍の速度向上が必要だと述べています。

  Bitcoinブロックチェーンの状態の圧縮に加えて、彼らは、LLのTaproot AssetsやRGBの一部の使用法（
  ニュースレター[#195][news195 taro]および[#247][news247 rgb]参照）と同様の、
  Client-Side-Validation型のトークンプロトコルに使用できるプロトコルについても説明しています。
  アリスがボブにトークンの一部を転送する場合、ボブは、そららのトークンが作成された時点までのすべての転送履歴を検証する必要があります。
  理想的なシナリオにおいて、その履歴は転送回数とともに線形に増加します。
  しかし、ボブがアリスから受け取ったトークンよりも多い量をキャロルに支払いたい場合は、
  アリスから受け取ったトークンの一部と、別のトランザクションで受け取ったトークンの一部を組み合わせる必要があります。
  そしてキャロルは、アリスを経由した履歴と、ボブの別のトークン履歴の両方を検証する必要があります。
  これはマージと呼ばれます。マージが頻繁に起きると、検証する必要のある履歴のサイズは、
  そのトークンのユーザー間のすべての転送履歴のサイズに近づきます。
  Bitcoinではすべてのフルノードがすべてのユーザーのトランザクションを検証しています。
  これと比較すると、Client-Side-Validationを使用するトークンプロトコルでは、
  同様の検証は厳密には必要ではありませんが、マージが頻繁に起こると、最終的に事実上同様の検証が必要になります。

  つまり、Bitcoinの状態を圧縮できるプロトコルは、マージが頻繁に起きる場合でも、
  トークンの履歴の状態を圧縮するのに適応できるということです。
  著者らは、それを実現する方法について説明しています。
  彼らの目標は、トークンの以前の転送が、そのトークンのルールに従っていることの証明を生成することです。
  これには、以前の各転送がブロックチェーンにアンカリングされていることを証明するために、Bitcoinに対するプルーフを使用することも含まれています。
  アリスは、トークンをボブに転送し、一定サイズの短い有効性のプルーフを渡すことができます。
  ボブはプルーフを検証し、転送が特定のブロック高で行われ、彼のトークンウォレットに支払われ、
  自分がそのトークンを独占的に制御していることを知ることができます。

  この論文では、追加で実施可能な研究開発について頻繁に言及していますが、
  私達はこれをBitcoinの開発者が10年以上にわたって望んでいた[機能][coinwitness]に向けた心強い進歩であると感じています。

## 承認を待つ #2: インセンティブ

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊シリーズです。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/02-cache-utility.md %}

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Passportファームウェア 2.1.1 リリース:**
  ハードウェア署名デバイスPassportの[最新のファームウェア][passport 2.1.1]は、
  [Taproot][topic taproot]アドレスへの送金、[BIP85][]機能のサポートに加え、
  [PSBT][topic psbt]の処理やマルチシグ構成の改善をしています。

- **MuSigウォレットMunstrリリース:**
  [MuSig][topic musig]マルチシグトランザクションの署名に必要なラウンド通信を簡単にするために
  [Nostrプロトコル][nostr protocol]を使用する[Munstrソフトウェア][munstr github]のベータ版です。

- **CLNのプラグインマネージャーCoffeeリリース:**
  [Coffee][coffee github]は、[CLNプラグイン][news22 plugins]のインストール、
  設定、依存関係の管理およびアップグレードの側面を改善するCLNプラグインマネージャーです。

- **Electrum 4.4.3 リリース:**
  Electrumの[最新][electrum release notes]バージョンには、
  コインコントロールの改善や、UTXOのプライバシー分析ツール、SCID（Short Channel Identifier）のサポートや、
  他の修正、改善が含まれています。

- **Trezor SuiteがCoinjoinをサポート:**
  Trezor Suiteソフトウェアは、CoinjoinコーディネーターzkSNACKsを使用する[Coinjoin][topic coinjoin]のサポートを[発表しました][trezor blog]。

- **Lightning LoopのデフォルトがMuSig2に:**
  [Lightning Loop][news53 loop]は、スワッププロトコルのデフォルトとして[MuSig2][topic musig]を使用するようになり、
  手数料の低減とプライバシーの向上を実現します。

- **Mutinynetがテスト用に新しいsignetを発表:**
  [Mutinynet][mutinynet blog]は、ブロックタイムが30秒のカスタムsignetで、
  [ブロックエクスプローラ][topic block explorers]やFaucet、
  ネットワーク上で動作するテストLNノードやLSPを含むテストインフラを提供します。

- **NunchukがコインコントロールとBIP329のサポートを追加:**
  NunchukのAndroidおよびiOSの最新バージョンでは、[コインコントロール][nunchuk blog]と
  [BIP329][]ウォレットラベルエクスポート機能が追加されています。

- **MyCitadel Walletがminiscriptのサポートを強化:**
  [v1.3.0][mycitadel v1.3.0]リリースでは、
  [タイムロック][topic timelocks]を含むより複雑な[miniscript][topic miniscript]機能が追加されています。

- **Coldcard用のEdge Firmwareの発表:**
  Coinkiteは、Coldcardハードウェアサイナー用の実験的なファームウェアを[発表しました][coinkite blog]。
  このファームウェアは、ウォレット開発者やパワーユーザーが新しい機能を試すために設計されています。
  初期の6.0.0Xリリースには、Taprootのkeypath支払いと、[Tapscript][topic tapscript]のマルチシグ支払い、
  [BIP129][]のサポートが含まれています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.05][]は、このLN実装の最新バージョンのリリースです。
  これには、[ブラインド・ペイメント][topic rv routing]や、[PSBT][topic psbt]バージョン2、
  より柔軟な手数料率の管理など、多くの改善が含まれています。

- [Bitcoin Core 23.2][]は、Bitcoin Coreの前のメジャーバージョンのメンテナンスリリースです。

- [Bitcoin Core 24.1][]は、Bitcoin Coreの現在のバージョンのメンテナンスリリースです。

- [Bitcoin Core 25.0rc2][]は、Bitcoin Coreの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27021][]では、アウトプットの未承認の祖先トランザクションを特定の手数料率まで引き上げるのに
  どれだけのコストがかかるか計算するインターフェースが追加されました。
  [コイン選択][topic coin selection]が特定の手数料率で特定のアウトプットの使用を検討している場合、
  その手数料率における祖先の手数料不足が計算され、その結果が有効値から差し引かれます。
  これにより、他の使用可能なアウトプットがある場合に、
  ウォレットが新しいトランザクションに対して手数料不足のアウトプットを選択するのを抑制することができます。
  [後続のPR][bitcoin core #26152]では、このインターフェースは
  いずれにせよ不足のあるアウトプットを選択する必要がある場合に、
  ウォレットが余分な手数料（ _手数料引き上げ_ と呼ばれる）を支払うことを可能にするためにも使用され、
  新しいトランザクションがユーザーが要求した実効手数料率を支払うことを保証します。

  このアルゴリズムは、未承認UTXOの関連する未承認トランザクションのクラスター全体を評価し、
  ターゲットの手数料率でブロックに選択されたであろうトランザクションを剪定することで、
  任意の祖先の一群に対して手数料の引き上げを評価することができます。
  2つめの方法は、複数の未承認アウトプットにまたがる手数料の引き上げを集約して、
  潜在的な祖先の重複を補正することができます。

- [LND #7668][]は、チャネルを開設する際に、最大500文字までのプライベートテキストを関連付ける機能を追加し、
  オペレーターが後でその情報を取得できるようにします。これにより、
  特定のチャネルを開いた理由を思い出すのに役立ちます。

- [LDK #2204][]は、ピアに通知するため、またはピアのアナウンスを解析する際に使用するための、
  カスタム機能ビットを設定する機能を追加しています。

- [LDK #1841][]は、以前LN仕様に追加されたセキュリティ勧告（[ニュースレター #128][news128 bolts803]参照）を実装しています。
  [アンカー・アウトプット][topic anchor outputs]を使用するノードは、トランザクションを迅速に承認する必要がある場合、
  複数の当事者が管理するインプットを一緒にバッチ処理しようとしてはなりません。
  この実装により、他の当事者が承認を遅らせることができなくなります。

- [BIPs #1412][]は、[ウォレットラベルエクスポート][topic wallet labels]用の[BIP329][]を更新し、
  鍵のオリジン情報を格納するフィールドを追加しました。
  さらに、仕様ではラベルの長さの制限を255文字にすることが提案されています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27021,7668,2204,1841,1412,26152" %}
[Core Lightning 23.05]: https://github.com/ElementsProject/lightning/releases/tag/v23.05
[bitcoin core 23.2]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021679.html
[lg paper]: https://zerosync.org/zerosync.pdf
[news128 bolts803]: /en/newsletters/2020/12/16/#bolts-803
[news247 rgb]: /ja/newsletters/2023/04/19/#rgb
[news195 taro]: /ja/newsletters/2022/04/13/#transferable-token-scheme
[coinwitness]: https://bitcointalk.org/index.php?topic=277389.0
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[passport 2.1.1]: https://foundationdevices.com/2023/05/passport-version-2-1-0-is-now-live/
[munstr github]: https://github.com/0xBEEFCAF3/munstr
[nostr protocol]: https://github.com/nostr-protocol/nostr
[coffee github]: https://github.com/coffee-tools/coffee
[news22 plugins]: /en/newsletters/2018/11/20/#c-lightning-2075
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[trezor blog]: https://blog.trezor.io/coinjoin-privacy-for-bitcoin-11aaf291f23
[mutinynet blog]: https://blog.mutinywallet.com/mutinynet/
[news53 loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[nunchuk blog]: https://nunchuk.io/blog/coin-control
[mycitadel v1.3.0]: https://github.com/mycitadel/mycitadel-desktop/releases/tag/v1.3.0
[coinkite blog]: https://blog.coinkite.com/edge-firmware/
