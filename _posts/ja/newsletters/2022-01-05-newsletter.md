---
title: 'Bitcoin Optech Newsletter #181'
permalink: /ja/newsletters/2022/01/05/
name: 2022-01-05-newsletter-ja
slug: 2022-01-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Full replace-by-feeをゆっくりと段階的に行う代替案と、
提案中の`OP_CHECKTEMPLATEVERIFY`のソフトフォークをレビューするための一連のミーティングの発表について掲載しています。
また、リリースおよびリリース候補の発表や人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点のまとめなど、
恒例のセクションも含まれています。

## ニュース

- **簡単なFull RBFの次にオプトインRBFへ:**
  Jeremy Rubinは、[ニュースレター #154][news154 rbf]に掲載した、
  Bitcoin CoreでFull [replace by fee][topic rbf]（RBF）を有効にすることについて
  Bitcoin-Devメーリングリストのスレッドに[返信しました][rubin rbf]。
  現在、[BIP125][]に従ってシグナルを送るトランザクションは、
  （いくつかの制限付きで）より高い手数料のトランザクションに置き換えることができます。
  以前の提案は、置換可能性を示すオプトインのシグナルをセットしたものだけではなく、
  最終的にあらゆるトランザクションを置き換え可能にする（Full RBF）というものでした。
  一部のマーチャントは、リレーノードが合理的に可能な限り置き換えを困難にし、
  少なくともオプションで低コストの商品やサービスに対して
  未承認トランザクションを即座に受け入れられるようにすることを望んていると指摘しています。

    Rubinの代替案は、依然Full RBFへの移行を推奨していますが、まずはどのトランザクションについても、
    ノードが最初に受信してから*n*秒間はFull RBFを許可することから始めることを提案しています。
    *n*秒経つと、BIP125のオプトインフラグが現在と同じように尊重されます。
    これにより、*n*秒経てば、マーチャントは現在と同様に未承認のトランザクションを受け入れることができます。
    さらに重要なことは、安全性のために置換可能性に依存しているプロトコルが、
    プロトコルノードやWatchtowerがトランザクションを最初に知ってから*n*秒以内に合理的に応答できる限り、
    非オプトインのトランザクションについて心配する必要がないことです。

- **BIP119 CTVのレビューワークショップ:**
  Jeremy Rubinは、Bitcoin-Devメーリングリストで、
  [BIP119][]の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]の仕様について、
  ネットワークへの展開方法を含め、定期的なミーティングを開催することを[発表しました][rubin ctv-review]。
  最初のミーティングは、1月11日（火）20:00 UTCから、Libera.Chatの[##ctv-bip-review][]で開催されます。
  その後のミーティングは、2週間ごとに同じ時間に開催される予定です。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust-Lightning 0.0.104][]は、いくつかのAPIの改善を含む、このLNノードライブラリの最新のリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23789][]は、新しく作成されたお釣り用のアウトプットを常に送信先のアウトプットのタイプと一致するようにし、
  可能な場合は[P2TR][topic taproot]のお釣り用アウトプットの作成を優先します。
  このPRは、Taprootの早期採用者のお釣り用のアウトプットが、
  レガシーアドレスに支払う際に簡単に特定されてしまうという[プライバシーの懸念][tr output linking]に対応するものです。

- [Bitcoin Core #23711][]は、
  未承認トランザクションの受け入れとリレーに関するBitcoin Coreの*ポリシー*のいくつかをドキュメント化したものです。
  このドキュメントは、受け入れやリレーの動作に依存する必要があるウォレットやコントラクトプロトコルの作者にとって特に役立つでしょう。

- [Bitcoin Core #17631][]は、FilterおよびRESTエンドポイントを有効にしたノード上で、
  [Compact Block Filter][topic compact block filters]を提供する新しいRESTエンドポイントを追加しました。

- [Bitcoin Core #22674][]は、トランザクションのパッケージを検証し、
  ノードのトランザクションリレーポリシーに対してそれをテストするロジックを追加しています。
  この場合のパッケージとは、1つの子トランザクションと、そのすべての未承認の親トランザクションを指します。
  後続のPRは、[CPFP][topic cpfp]と[RBF][topic rbf]のサポートを追加することで検証ロジックを拡張する予定です。

    後続のPRでは、現在利用可能なロジックを使用して検証されるトランザクションのパッケージを、
    ローカルノードにピアから送信できるようにする方法が追加されるでしょう。
    これにより[パッケージリレー][topic package relay]が可能になり、
    LNのようなコントラクトプロトコルの信頼性と安全性が向上します。
    このPRでは、パッケージ検証ルールに関する[ドキュメント][package doc]も追加されています。

[package doc]: https://github.com/glozow/bitcoin/blob/046e8ff264be6b888c0f9a9d822e32aa74e19b78/doc/policy/packages.md

- [Bitcoin Core #23718][]は、[PSBT][topic psbt]に含まれる
  すべてのハッシュとプリイメージを保持し表示するためのサポートを追加しました。
  [HTLC][topic htlc]やその他のコントラクトプロトコルのプリミティブで使用されるPSBTには、
  PSBTの*Updater*または*Signer*のいずれかがそのプリイメージを知っているハッシュが含まれている場合があります。
  このプリイメージは、目的の最終トランザクションを生成するために必要になる場合があります。
  このPRは、Bitcoin Coreがそのようなトランザクションの作成、
  管理およびファイナライズに効果的に参加しやすくするためのものです。
  Bitcoin Coreが[miniscript][topic miniscript]を採用した場合、さらに改善が期待されます。

- [Bitcoin Core #17034][]は、PSBTバージョン2([ニュースレター #128][news128 psbt]参照)のサポートと、
  [ニュースレター #72][news72 psbt]に掲載した独自のPSBT拡張用のフィールドを含む、追加のPSBTフィールドを追加しました。
  Bitcoin Coreは独自拡張を理解しませんが、処理するPSBTでそれらを保持し、
  `decodepsbt` RPCの結果でそれらを表示するようになりました。

- [Bitcoin Core #23113][]は、
  ユーザーが[非圧縮公開鍵][uncompressed public key]を使用してsegwitのマルチシグアドレスの作成を要求した場合に、
  警告フィールドを含むよう`createmultisig` RPCと`addmultisig` RPCを更新しました。
  segwitのオリジナルの実装以来、Bitcoin Coreは、
  デフォルトで、非圧縮公開鍵が含まれるsegwitインプットを使用する未承認トランザクションをリレーまたはマイニングしません。
  つまり、圧縮されていない鍵を使用してアドレスを作成したユーザーは、
  そのアドレスで受け取った資金を使うことができなくなる可能性があります。
  そのため、これらのRPCでは、圧縮されていない鍵に対して[bech32][topic bech32]アドレスは作成されず、
  代わりにレガシー（base58check）アドレスが作成されます。
  新しい警告フィールドは、このような状況にあるユーザーが、
  要求したものとは違うタイプのアドレスを受け取る理由を理解するのに役立つはずです。

- [Bitcoin Core GUI #459][]は、古いアドレスタイプに加えて、
  bech32mアドレスを作成する機能を備えたアドレス生成ダイアログを更新しました。

    {:.center}
    ![Screenshot address picker](/img/posts/2022-01-core-gui-address-picker.png)

- [Eclair #2090][]は、`max-per-peer-per-second`設定オプションで、
  [Onionメッセージ][topic onion messages]のレートを制限する機能を追加しました。

- [Eclair #2104][]は、オンチェーンで即時に使用可能な残高が、
  [Anchor Output][topic anchor outputs]を使用した[CPFPによる手数料の引き上げ][topic cpfp]を使用して
  タイムリーにチャネルを閉じるために必要な推定金額以下になった場合に、
  ローカルノードオペレーターに警告するログメッセージを追加しています。
  LN開発者または独自のリザーブ値を選択するオペレーターは、
  Eclairの推定値と[LNDで][news149 lnd5274]使用される[推定値][news113 lnd4908]を比較することをお勧めします。

- [Eclair #2099][]は、`onion-messages`設定オプションを追加し、
  [Onionメッセージ][topic onion messages]をリレーしない（ただし、ノードがメッセージを送受信することは可能）、
  すべてのメッセージをリレーする（新しいピアへの接続を開く必要があるものを含む）、
  既存の接続のメッセージのみをリレーするよう設定できるようになりました。

- [Libsecp256k1 #964][]は、libsecp256k1ライブラリのリリースプロセスとバージョン管理方式の概要をまとめています。

- [Rust Bitcoin #681][]は、[BIP371][]の[Taproot][topic taproot]用の[PSBT][topic psbt]フィールドのサポートを追加しました。

- [Rust-Lightning #1177][]は、上位レベルのウォレットアプリケーションが受け取りたい支払いに関する情報を、
  Rust-Lightning自体が保存する必要性を無くしました。代わりに、支払いに関する重要な情報は暗号化され、
  [ペイメント・シークレット][topic payment secrets]にエンコードされます。
  支払いを受け取ると、暗号化されたペイメント・シークレットは復号され、平文の情報は
  支払いの[HTLC][topic htlc]を保護するために使用されている[ペイメント・ハッシュ][payment hash]を満たす
  [ペイメント・プリイメージ][payment preimage]を導出するのに使用されます。

    これは、[ニュースレター #168][news168 stateless]に掲載したアイディアの簡略化された実装です。
    他のLN実装では、インボイスに関する情報（例えば、マーチャントのショップソフトウェアが提供する任意の注文識別子）を
    保存することができますが、Rust-Lightningは上位アプリケーションに直接統合することを想定したライブラリであるため、
    上位アプリケーションが自身の支払い要求の詳細を管理できるようにし、これを回避しています。

- [HWI #545][]および[#546][HWI #546]、[#547][HWI #547]は、
  `tr()`[descriptor][topic descriptors]のサポート、
  [BIP371][]のTaproot用の[PSBT][topic psbt]フィールドのサポート、
  基礎となるハードウェア署名デバイスで利用可能な場合にTaproot Script用の[bech32m][topic bech32]アドレスをサポートすることで、
  [Taproot][topic taproot]のサポートを追加しています。
  これらのPRの時点では、HWIは、Taprootをサポートする一部の署名デバイスのファームウェアを完全にサポートしていないため、
  これらのデバイスではまだTaprootのサポートは有効になっていないことに注意してください。

- [BIPs #1126][]は、Bitcoinのハードフォークの変更案である*Optical Proof of Work* (OPoW)の[BIP52][]を追加しました。
  これは、マイニング機器（資本支出）と電力および運用コスト（運用支出）の間のコスト分担を変更すると主張するものです。
  このアイディアはBitcoin-Devメーリングリスト上で[以前議論され][opow ml]、支持者と反対者が両方いました。

{% include references.md %}
{% include linkers/issues.md issues="23789,23711,17631,22674,23718,17034,23113,459,2090,2104,2099,964,681,1177,545,546,547,1126,912" %}
[opow ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018951.html
[##ctv-bip-review]: https://web.libera.chat/?channels=##ctv-bip-review
[rust-lightning 0.0.104]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.104
[rubin rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019696.html
[rubin ctv-review]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019719.html
[news154 rbf]: /ja/newsletters/2021/06/23/#allowing-transaction-replacement-by-default
[news128 psbt]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[news72 psbt]: /ja/newsletters/2019/11/13/#bips-849
[tr output linking]: /ja/preparing-for-taproot/#output-script-matching-output-script
[uncompressed public key]: https://btcinformation.org/en/developer-guide#public-key-formats
[payment preimage]: https://github.com/lightning/bolts/blob/master/00-introduction.md#payment-preimage
[payment hash]: https://github.com/lightning/bolts/blob/master/00-introduction.md#Payment-hash
[news168 stateless]: /ja/newsletters/2021/09/29/#stateless-ln-invoice-generation-ln
[news113 lnd4908]: /ja/newsletters/2021/01/27/#lnd-4908
[news149 lnd5274]: /ja/newsletters/2021/05/19/#lnd-5274
