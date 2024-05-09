---
title: 'Bitcoin Optech Newsletter #184'
permalink: /ja/newsletters/2022/01/26/
name: 2022-01-26-newsletter-ja
slug: 2022-01-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、pay-to-contractプロトコルを使って構築されたアウトプットを使用する際の
フィールドを追加するPSBTの拡張の提案を掲載しています。
また、Bitcoin Stack Exchangeのトップポストや、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **P2Cフィールド用のPSBTの拡張:** Maxim Orlovskyは、
  以前[ニュースレター #37][news37 psbt p2c]で紹介した
  [Pay-to-Contract][topic p2c](P2C)プロトコルを使って作成したアウトプットから支払いをするための
  オプションフィールドを[PSBT][topic psbt]に追加する新しいBIPを[提案しました][orlovsky p2c]。
  P2Cでは、送信者と受信者が契約（またはその他）のテキストに合意し、そのテキストにコミットする公開鍵を作成することができます。
  そして送信者は、支払いがそのテキストにコミットされたこと、
  そのコミットメントが受信者の協力なしに計算上不可能であったことを後で証明することができます。
  要するに、送信者は何に対する支払いであったのかを裁判所や公衆に証明することができるのです。

  しかし、受信者は、受け取った資金を使用するためには、使用した鍵（通常[HDキーチェーン][topic bip32]の一部）に加えて、
  契約のハッシュが必要になります。Orlovskyの提案では、
  このハッシュをPSBTに追加することで、署名用のウォレットやハードウェアデバイスが有効な署名を生成できるようにします。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-it-possible-to-convert-a-taproot-address-into-a-v0-native-segwit-address-->Taprootアドレスをv0 native segwitアドレスに変更することは可能ですか？]({{bse}}111440)
  ある取引所がTaprootをサポートしておらず、
  ユーザーのP2TR（native segwit v1）Taproot引き出しアドレスをP2WSH（native segwit v0）アドレスに変更した結果、
  ユーザーからその結果のv0アウトプットからビットコインを救済する方法があるか質問されました。
  Pieter Wuilleは、これにはユーザーがP2TRアドレスの公開鍵にハッシュするスクリプトを見つける必要があり、
  それは計算実行上不可能な演算であるため、これらのビットコインを救済することはできないと指摘しています。

- [<!--was-bitcoin-0-3-7-actually-a-hard-fork-->Bitcoin 0.3.7は実際にハードフォークだったのか？]({{bse}}111673)
  BA20D731B5806B1Dは、Bitcoin 0.3.7のリリースがハードフォークに分類される原因となったのは何故なのかと疑問を抱きました。
  Antoine Poinsotは、`scriptSig`と`scriptPubKey`の評価を分離する[0.3.7][bitcoin 0.3.7 github]のバグ修正後、
  以前は無効だった署名を有効にすることができることを説明するために`scriptPubKey`と`scriptSig`の値の例を示しています。

- [<!--what-is-signature-grinding-->署名の圧縮とは？]({{bse}}111660)
  Murchによると、ECDSAの署名圧縮とは、rの値が範囲の半分以下になるまで署名を繰り返すプロセスで、
  これによりBitcoinのECDSAのシリアライズ形式に基づいて署名が1バイト（32バイト vs 33バイト）小さくなります。
  署名が小さくなると手数料の低減につながり、署名が32バイトであることが既知になると、より正確な手数料見積もりに役立ちます。

- [<!--how-is-network-conflict-avoided-between-chains-->チェーン間のネットワーク競合はどうやって回避されますか？]({{bse}}111967)
  Murchは、ノードが同じネットワーク（mainnet、testnet、signet）上のピアに接続されているかどうかを識別するために、
  P2Pの[メッセージ構造][wiki message structure]で定義されているマジックナンバーを使用する方法について説明しています。

- [<!--how-many-bips-were-adopted-in-the-standard-client-in-2021-->2021年、標準クライアントに採用されているBIPはいくつありますか？]({{bse}}111901)
  Pieter Wuilleは、Bitcoin Coreに実装されているBIPを記録しているBitcoin Coreの[BIPドキュメント][bitcoin bips doc]のリンクを挙げています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #2134][]は、デフォルトで[Anchor Output][topic anchor outputs]を有効にし、
  ブロードキャスト時にその手数料率が低すぎる場合、コミットメントトランザクションの手数料を引き上げられるようにしました。
  Anchor Outputスタイルの手数料引き上げは、[CPFP][topic cpfp]を介して機能するため、
  ユーザーは`bitcoind`のウォレットにUTXOを用意しておく必要があります。

- [Eclair #2113][]は、手数料引き上げの自動管理を追加しました。
  これには、時間どおりに承認されることの重要性によってトランザクションを分類すること、
  各ブロックの後でトランザクションを再評価し手数料を引き上げるのが適切かどうかを判断すること、
  トランザクションの手数料を引き上げる必要がある場合に備えて現在のネットワーク手数料率を再評価すること、
  トランザクションの手数料率を引き上げる必要がある場合にインプットを追加することが含まれます。
  PRの説明では、Eclairのような外部プログラムが必要とするアドオンウォレットの管理する内容を減らすことができる
  Bitcoin CoreのウォレットAPIの[改善][Bitcoin Core #23201]もアピールしています。

- [Eclair #2133][]は、デフォルトで[Onionメッセージ][topic onion messages]のリレーを開始します。
  [ニュースレター #181][news181 onion]で言及されたレート制限は、
  LNプロトコルのこの実験的なパーツの悪用による問題を防ぐために使用されます。

- [BTCPay Server #3083][]では、
  管理者が（LN以外のソフトウェアでも実装可能な）[LNURL認証][lnurl authentication]を使ってBTCPayインスタンスにログインできるようになりました。

- [BIPs #1270][]は、署名フィールドの許容値について[PSBT][topic psbt]の仕様を明確化しました。
  Rust Bitcoinの最近のアップデートで署名フィールドの[パースが厳格になったため][news183 rust-btc psbt]、
  PSBTのフィールドにプレースホルダーを入れるかどうか、有効な署名のみを許可するかどうかについて議論されました。
  その結果、PSBTには有効な署名のみが含まれるべきであると判断されました。

- [BOLTs #917][]は、[BOLT1][]で定義された`init`メッセージを拡張し、
  ノードが接続先のピアに、そのピアが使用しているIPv4もしくはIPv6アドレスを通知する機能を追加しました。
  [NAT][]の背後にあるピアは自分のIPアドレスを認識できないため、
  これによりピアはアドレスが変更された際にネットワークに通知するIPアドレスを更新することができます。

{% include references.md %}
{% include linkers/issues.md issues="2134,2113,23201,2133,3083,1270,917" %}
[orlovsky p2c]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019761.html
[news181 onion]: /ja/newsletters/2022/01/05/#eclair-2099
[lnurl authentication]: https://github.com/fiatjaf/lnurl-rfc/blob/legacy/lnurl-auth.md
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[news37 psbt p2c]: /en/newsletters/2019/03/12/#extension-fields-to-partially-signed-bitcoin-transactions-psbts
[bitcoin 0.3.7 github]: https://github.com/bitcoin/bitcoin/commit/6ff5f718b6a67797b2b3bab8905d607ad216ee21#diff-8458adcedc17d046942185cb709ff5c3L1135
[wiki message structure]: https://en.bitcoin.it/wiki/Protocol_documentation#Message_structure
[bitcoin bips doc]: https://github.com/bitcoin/bitcoin/blob/master/doc/bips.md
[news183 rust-btc psbt]:/ja/newsletters/2022/01/19/#rust-bitcoin-669
