---
title: 'Bitcoin Optech Newsletter #186'
permalink: /ja/newsletters/2022/02/09/
name: 2022-02-09-newsletter-ja
slug: 2022-02-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Replace-by-Feeトランザクションのリレーポリシーの変更に関する議論に加えて、
Bitcoin Core PR Review Clubミーティングの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションを掲載しています。

## ニュース

- **RBFポリシーに関する議論:** Gloria Zhaoは、Bitcoin-Devメーリングリストで、
  Replace-by-Fee ([RBF][topic rbf])のポリシーに関する[議論][zhao rbf]を開始しました。
  彼女のメールは、現在のポリシーの背景を説明し、
  長年にわたって発見されたいくつかの問題（[Pinning攻撃][topic transaction pinning]など）を列挙し、
  ポリシーがウォレットのユーザーインターフェースにどう影響するかを検証し、
  そしていくつかの可能な改善策について説明しています。
  次のブロックテンプレート（マイナーがProof of Workのために作成しコミットするブロック候補）における
  トランザクションを考慮した改善案に大きな注意が払われました。
  置換が次のブロックテンプレートに与える影響を評価することで、
  次のブロックのマイナーがより多くの手数料収入を得られるかどうかを、
  ヒューリスティックを使用せずに確実に判断することができます。
  Zhaoの要約と提案に対して、何人かの開発者が、追加の提案および代替案を含むコメントを返信しました。

  この要約が書かれている間も、議論は続いています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*


[Add usage examples][reviews 748]は、Elichai TurkelによるPRで、
ECDSA署名および[Schnorr署名][topic schnorr signatures]、ECDH鍵交換のサンプルを追加するものです。
これは、libsecp256k1のPRに対する最初のReview Clubミーティングでした。
参加者は、良い乱数ソースの重要性について議論し、サンプルを通じてlibsecp256k1についての一般的な質問をしました。

{% include functions/details-list.md
  q0="<!--why-do-the-examples-show-how-to-obtain-randomness-->なぜサンプルではランダム性の取得方法を示しているのですか？"
  a0="このライブラリの多くの暗号方式の安全性は、秘密鍵、nonceおよびsaltが秘密/ランダムであることに依存しています。
もし攻撃者が、ランダム性のソースから返される値を推測したり、影響を与えることができると、
署名を偽造したり、秘密にしようとしている情報を知ったり、鍵を推測したりすることができるようになるかもしれません。
このように暗号方式を実装する際の課題は、ランダム性を取得することにあることが多く、サンプルはこの事実を強調しています。"
  a0link="https://bitcoincore.reviews/libsecp256k1-748#l-99"

  q1="<!--is-it-a-good-idea-to-make-recommendations-for-how-to-obtain-randomness-->ランダム性の取得方法について推奨される良いアイディアはありますか？"
  a1="libsecp256k1のメインのユーザーであるBitcoin Coreは、OSやP2Pネットワークで受信したメッセージおよび、
その他のエントロピーのソースを組み込んだ、ランダム性のための独自アルゴリズムを持っています。
独自のエントロピーを持つ必要がある他のユーザーの場合、ランダム性の優れたソースが非常に重要であり、
OSのドキュメントが常に明確であるとは限らないため、推奨内容がユーザーの役に立つかもしれません。
これらの推奨内容は、OSのサポートや脆弱性によって古くなる可能性があるため、
メンテナンスの負担はありますが、これらのAPIは頻繁に変更されることはないため負担も最小限になると予想されます。"
  a1link="https://bitcoincore.reviews/libsecp256k1-748#l-120"

  q2="<!--can-you-follow-the-examples-added-in-the-pr-is-anything-missing-from-them-->PRで追加されたサンプルについて不足していることはありますか？"
  a2="参加者は、サンプルのコンパイルと実行、デバッガの使用、サンプルコードとBitcoin Coreの使用方法の比較、
非Bitcoinユーザーに対するUXの検討の経験について議論しました。ある参加者は、
Schnorr署名を生成した後に検証しないのは、Bitcoin Coreのコードと[BIP340][]の推奨から逸脱していると指摘しました。
別の参加者は、メッセージのハッシュ化を忘れるとユーザーの誤用につながる可能性があるため、
`secp256k1_ecdsa_sign`の前に`secp256k1_sha256`の使用例を示すことを提案しました。"
  a2link="https://bitcoincore.reviews/libsecp256k1-748#l-193"

  q3="<!--what-can-happen-if-a-user-forgets-to-do-something-like-verify-the-signature-after-signing-call-seckey-verify-or-randomize-the-context-->
ユーザーが署名後に署名の検証を忘れたり、`seckey_verify`の呼び出し、contextのランダム化などを忘れた場合、
どのようなことが起こり得るのでしょうか？"
  a3="最悪の場合、もし実装に欠陥があれば、署名後に署名の検証を忘れると、
誤って無効な署名を与えてしまうことになります。鍵をランダムに生成した後の`seckey_verify`の呼び出しを忘れると、
（無視できる確率ですが）無効な鍵を持つ可能性があります。
contextのランダム化は、サイドチャネル攻撃からの保護を目的としています。
このランダム化は、最終結果には影響を与えませんが、
実行された操作に関する情報を取得するために悪用される可能性のある中間値をブラインドします。"
  a3link="https://bitcoincore.reviews/libsecp256k1-748#l-226"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.14.2-beta][]は、いくつかのバグ修正と小さな改善を含むメンテナンスバージョンのリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23508][]は、ソフトフォークのデプロイステータスを`getblockchaininfo`RPCから、
  新しい`getdeploymentinfo`RPCに移動しました。新しいRPCはさらに、
  チェーンの先頭時点だけでなく、特定のブロック高でのデプロイステータスを照会することができます。

- [Bitcoin Core #21851][]は、arm64-apple-darwin (Apple M1)用のビルドのサポートを追加しました。
  この変更は現在マージされており、コミュニティは次のリリースでM1バイナリが動作することを期待できます。

- [Bitcoin Core #16795][]は、`getrawtransaction`、`gettxout`、`decoderawtransaction`、`decodescript` RPCを更新し、
  デコードされたscriptPubKeyに対して推測される[output script descriptor][topic descriptors]を返すようになりました。

- [LND #6226][]は、従来の`SendPayment`、`SendPaymentSync`、`QueryRoutes`
  RPCを使用して作成されるLNを介してルーティングされる支払いのデフォルト手数料として5%を設定します。
  新しい`SendPaymentV2` RPCを使用して送信される支払いはデフォルトで手数料ゼロが設定され、
  基本的にユーザーが値を指定する必要があります。
  追加でマージされたPR、[LND #6234][]は、従来のRPCで行われた1,000 satoshi未満の支払いに対して、
  デフォルトで100%の手数料が設定されます。

- [LND #6177][]は、[HTLC][topic HTLC]インターセプターのユーザーが、HTLCが失敗した理由を指定できるようになりました。
  これにより、失敗がLNDを使用するソフトウェアにどう影響するかテストするのにインターセプターがより便利になります。

- [LDK #1227][]は、経路探索ロジックを改善し、既知の過去の支払いの失敗/成功を考慮するようにしました。
  これらの失敗/成功は、チャネルバランスの上限と下限を決定するために使用され、
  経路探索ロジックが経路を評価する際に、より正確な成功確率を提供します。
  これは、以前のニュースレター（[#142][news142 pps]、[#163][news163 pickhardt richter paper]、
  [#172][news172 cl4771]を含む）で紹介したRené Pickhardtや他の人が以前説明したアイディアの実装です。

- [HWI #549][]は、[BIP370][]で定義された[PSBT][topic psbt]バージョン2のサポートを追加しました。
  既存のColdcardハードウェア署名デバイスのように、バージョン0のPSBTをネイティブにサポートするデバイスを使用する場合、
  v2のPSBTはv0のPSBTに変換されます。

- [HWI #544][]は、Trezorハードウェア署名デイバイスを使用した[Taproot][topic taproot]支払いの受け取り、
  送信をサポートするようになりました。

{% include references.md %}
{% include linkers/issues.md v=1 issues="23508,21851,16795,6226,6234,6177,1227,549,544" %}
[lnd 0.14.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.2-beta
[zhao rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019817.html
[news163 pickhardt richter paper]: /ja/newsletters/2021/08/25/#zero-base-fee-ln-discussion-ln
[news142 pps]: /ja/newsletters/2021/03/31/#paper-on-probabilistic-path-selection
[news172 cl4771]: /ja/newsletters/2021/10/27/#c-lightning-4771
[reviews 748]: https://bitcoincore.reviews/libsecp256k1-748
