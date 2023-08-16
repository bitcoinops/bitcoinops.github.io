---
title: 'Bitcoin Optech Newsletter #264'
permalink: /ja/newsletters/2023/08/16/
name: 2023-08-16-newsletter-ja
slug: 2023-08-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、サイレントペイメントアドレスに有効期限を追加することについての議論と、
サーバーレスPayjoin用のBIPドラフトの概要を掲載しています。
寄稿されたフィールドレポートでは、スクリプトレスマルチシグのためのMuSig2ベースのウォレットの実装と展開について掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **<!--adding-expiration-metadata-to-silent-payment-addresses-->サイレントペイメントアドレスに有効期限メタデータの追加:**
  Peter Toddは、[サイレントペイメント][topic silent payments]用のアドレスにユーザーが選択した有効期限を追加する推奨事項を
  Bitcoin-Devメーリングリストに[投稿しました][todd expire]。
  複数の支払いを受け取るのに同じアドレスを使用すると[アウトプットがリンクされる][topic output linking]
  通常のBitcoinアドレスとは異なり、サイレントペイメント用のアドレスは、
  適切に使用されるたびに一意のアウトプットスクリプトが生成されます。
  これにより、受信者が個別の支払い毎に異なる通常のアドレスを支払人に提供することが不可能または不便な場合に、
  プライバシーが大幅に向上します。

    Peter Toddは、すべてのアドレスが期限切れになることが望ましいと指摘しています:
    ほとんどのユーザーは、ある時点でウォレットの使用を止めるでしょう。
    通常のアドレスは一度しか使用されないことが予想されるため、有効期限切れの懸念はそれほどありませんが、
    サイレントペイメントでは繰り返し使用されることが予想されるため、有効期限を含めることがより重要になります。
    彼は、今から180年後までの有効期限をサポートする2バイトの有効期限か、
    約45,000年後までの有効期限をサポートする3バイトの有効期限のいずれかをアドレスに含めることを提案しています。

    この提言は、メーリングリスト上で適度な議論がされましたが、この執筆時点では明確な決着はついていません。

- **サーバーレスPayjoin:** Dan Gouldは、
  _サーバーレスPayjoin_ （[ニュースレター #236][news236 spj]参照）の[BIPドラフト][spj bip]を
  Bitcoin-Devメーリングリストに[投稿しました][gould spj]。
  [BIP78][]で定義されている[Payjoin][topic payjoin]自体は、
  受信者が支払人から[PSBT][topic psbt]を安全に受け取るためのサーバーを運用することを想定しています。
  Gouldは、受信者が[BIP21][] URIを使用して、Payjoinの支払いを受け取るために使用したいリレーサーバーと
  対称暗号鍵を宣言することから始まる非同期リレーモデルを提案しています。
  支払人は、取引のPSBTを暗号化し、受信者の希望するリレーに送信します。
  受信者はそのPSBTをダウンロードし、復号し、署名したインプットを追加して暗号化し、再びリレーに送信します。
  支払人は変更されたPSBTをダウンロードし、復号し、それが正しいことを確認し、署名しBitcoinネットワークにブロードキャストします。

    [返信][gibson spj]の中で、Adam Gibsonは、BIP21 URIに暗号鍵を含めることの危険性と、
    リレーが受信者と支払人のIPアドレスと、ほぼ同じ時間帯にブロードキャストされた
    一連のトランザクションを関連付けることができるプライバシーに対するリスクについて警告しました。
    Gouldはその後、暗号鍵に関するGibsonの懸念に対処するために提案を[修正しました][gould spj2]。

    私たちは、このプロトコルに関する継続的な議論を期待しています。

## フィールドレポート: MuSig2の実装

{% include articles/ja/bitgo-musig2.md extrah="#" %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.08rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27213][]は、Bitcoin Coreがより多様なネットワーク上のピアとの接続を作成、
  維持するのを支援し、状況によっては[エクリプス攻撃][topic eclipse attacks]のリスクを低減します。
  エクリプス攻撃は、ノードが1つの誠実なピアにも接続することができず、
  ネットワークの他の部分とは異なるブロックのセットを与えることができる不誠実なピアとの接続が残った場合に発生します。
  このような攻撃は、ネットワークの他の部分が同意していないにもかかわらず、
  特定のトランザクションが承認されたとノードを納得させるために使用することができ、
  ノードオペレーターを騙して、決して使用できないビットコインを受け入れるよう仕向ける可能性があります。
  接続の多様性を高めることは、小規模ネットワーク上のピアがメインネットワークから分離され、
  最新のブロックを受信できなくなるという偶発的なネットワーク分割を防ぐのにも役立ちます。

    マージされたPRは、到達可能な各ネットワーク上の少なくとも1つのピアへの接続を開こうとし、
    ネットワーク上の唯一のピアが自動的に排除されるのを防ぎます。

- [Bitcoin Core #28008][]は、[BIP324][]で定義されている
  [v2トランスポートプロトコル][topic v2 P2P transport]の実装に使用される予定の暗号化と復号化ルーチンを追加しました。
  PRから引用すると、以下の暗号とクラスが追加されています:

    - "RFC8439セクション2.8のChaCha20Poly1305 AEAD"

    - "BIP324で定義されている[Forward Secrecy] FSChaCha20ストリーム暗号、ChaCha20の鍵の再生成ラッパー"

    - "BIP324で定義されているFSChaCha20Poly1305 AEAD、ChaCha20Poly1305の鍵の再生成ラッパー"

    - "BIP324パケットエンコーディング用の鍵合意、鍵導出、ストリーム暗号およびAEADをカプセル化するBIP324Cipherクラス"

- [LDK #2308][]は、LDKもしくは互換性のある実装を使用する受信者が支払いから抽出できるカスタムTLV（Tag-Length-Value）レコードを
  支払いに含めることができるようにしました。これにより、カスタムデータやメタデータを支払いと共に簡単に送信できます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27213,28008,2308" %}
[todd expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021849.html
[gould spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021868.html
[spj bip]: https://github.com/bitcoin/bips/pull/1483
[gibson spj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021872.html
[gould spj2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021880.html
[news236 spj]: /ja/newsletters/2023/02/01/#payjoin
[core lightning 23.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc2
