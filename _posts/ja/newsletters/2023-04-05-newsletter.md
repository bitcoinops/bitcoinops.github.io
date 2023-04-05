---
title: 'Bitcoin Optech Newsletter #245'
permalink: /ja/newsletters/2023/04/05/
name: 2023-04-05-newsletter-ja
slug: 2023-04-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ウォッチタワーの責任の証明についてのアイディアと、
新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも掲載しています。

## ニュース

- **<!--watchtower-accountability-proofs-->ウォッチタワーの責任の証明:**
  Sergi Delgado Seguraは、[ウォッチタワー][topic watchtowers]が検出可能なプロトコル違反に対応できなかった場合の責任について、
  先週Lightning-Devメーリングリストに[投稿しました][segura watchtowers post]。
  たとえば、アリスがウォッチタワーにLNの古いチャネル状態を検知して応答するためのデータを提供し、
  その後その状態が承認されウォッチタワーが応答に失敗した場合です。
  アリスは、ウォッチタワーが適切な応答をしなかったことを公に証明することで、
  ウォッチタワーのオペレーターに責任を追わせたいと考えます。

    基本的な原理は、ウォッチタワーがよく知られた公開鍵を保持していて、
    対応する秘密鍵を使って受け入れた違反検知データの署名を生成するというものです。
    アリスは、未解決の侵害があった後、そのデータと署名を公開し、
    ウォッチタワーが責任を果たせなかったことを証明することができます。
    しかし、Delgadoは実際の責任の説明はそれほど単純ではないと指摘します:

    - *<!--data-storage-requirements-->データ保存の必要性:* 上記の仕組みでは、
      アリスがウォッチタワーに違反検知用のデータを送信するたびに追加の署名を保存する必要があり、
      アクティブなLNチャネルではかなりの頻度になる可能性があります。

    - *<!--no-deletion-capability-->削除機能がない:* 上記の仕組みでは、
      ウォッチタワーが違反検知用のデータを永遠に保存する必要が出てきます。
      ウォッチタワーは特定の期間だけデータを保存するよう望むかもしれません（たとえば特定の期間だけ支払いを受けるなど）。

    Delgadoは、この2つの問題に対する実用的な解決策として、暗号学的アキュムレーターを提案しています。
    アキュムレーターは、特定の要素が要素の大きな集合内のメンバーであることをコンパクトに証明することができ、
    データ構造全体を再構築することなく新しい要素を集合に追加することができます。
    アキュムレーターの中には、再構築することなく要素を削除できるものもあります。
    Delgadoは、[gist][segura watchtowers gist]で検討する価値のある
    いくつかの異なるアキュムレーターの構造を概説しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.16.0-beta][]は、この人気のLN実装の新しいメジャーバージョンのベータリリースです。
  [リリースノート][lnd rn]には、多数の新機能、バグ修正、パフォーマンスの向上が記載されています。

- [BDK 1.0.0-alpha.0][]は、[ニュースレター #243][news243 bdk]で紹介したBDKの主な変更のテストリリースです。
  下流プロジェクトの開発者は、統合テストを開始することが推奨されます。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Core Lightning #5967][]は、ノードが閉じたチャネル関するデータ（ノードが閉じられた原因も含む）を提供する
  `listclosedchannels` RPCを追加しました。また、古いピアに関する情報も保持されるようになりました。

- [Eclair #2566][]は、オファーを受け入れるためのサポートを追加しました。
  オファーは、オファーに関するインボイス要求に応答し、
  そのインボイスに対する支払いを受け入れるか拒否するかハンドリングを行うプラグインによって登録される必要があります。
  Eclairは、要求と支払いがプロトコルの要件を満たすことを保証します。ハンドラは、
  購入される商品またはサービスが提供できるかどうかを判断するだけで済みます。
  このため、Eclairの内部ロジックに影響を与えることなく、
  オファーをマーシャリングするためのコードを任意に合成することができます。

- [LDK #2062][]は、[BOLTs #1031][]（[ニュースレター #226][news226 bolts1031]参照）、
  [#1032][bolts #1032]（[ニュースレター #225][news225 bolts1032]参照）および
  [#1040][bolts #1040]を実装し、支払い（[HTLC][topic htlc]）の最終受信者が要求した金額よりも多くの金額を
  より長い期間で受け入れることができるようになりました。これにより、
  転送ノードが支払いのパラメーターを少し調整することで、次のホップが受信者であることを判断するのを難しくします。
  マージされたPRでは、[簡略化されたマルチパスペイメント][topic multipath payments]を使用する場合、
  支払人が受信者に要求された金額よりも少し多く支払うことができます。
  これは上記の利点を提供し、また選択した支払いパスがルーティング可能な最小額を有するチャネルを使用する場合に必要になる可能性があります。
  たとえば、アリスは合計900 satを2つに分割したいものの、選択した両方のパスが最小額として500 satを要求する場合です。
  この仕様変更により、アリスは2つの500 satの支払いを送ることができるようになり、
  希望する経路を使用するために合計100 satの過払いを選択することができます。

- [LDK #2125][]は、インボイスの有効期限までの時間を決定するためのヘルパー関数を追加しました。

- [BTCPay Server #4826][]は、[LNURL][]インボイスの作成と取得のためのサービスフックを可能にしました。
  これは、BTCPay Serverのライトニングアドレス機能にNIP-57のzapのサポートを追加するためのものです。

- [BTCPay Server #4782][]は、各支払いのレシートページに[支払いの証明][topic proof of payment]を追加しました。
  オンチェーン支払いの場合、証明はトランザクションIDになります。LN支払いの場合は、
  証明は[HTLC][topic htlc]のプリイメージになります。

- [BTCPay Server #4799][]は、[BIP329][]で指定されたフォーマットでトランザクションの
  [ウォレットラベル][topic wallet labels]をエクスポートする機能を追加しました。
  将来のPRでは、アドレス用のラベルのような、他のウォレットデータのエクスポートがサポートされるかもしれません。

- [BOLTs #765][]は、LNの仕様に[ルート・ブラインディング][topic rv routing]を追加しました。
  ルート・ブラインディングは、[ニュースレター #85][news85 blinding]で最初に紹介したもので、
  ノードが支払いや[オニオン・メッセージ][topic onion messages]を受け取る際に、
  支払人や送信者にノードの識別子を明かすことなく受け取れるようにします。
  他に直接識別可能な情報を明かす必要はありません。ルート・ブラインディングは、
  支払いやメッセージが転送される最後の数ホップを受信者が選択することで機能します。
  これらのステップは、通常の転送情報と同様にオニオン暗号化され、支払人もしくは送信者に提供され、
  彼らはその最初のホップに支払いを送信します。その最初のホップは、
  次のホップを復号し、そのホップに支払いを転送し、
  次のホップも後続のホップを復号するプロセスを、受信者が支払いを受け取るまで繰り返します。
  その際、これらのノードが支払人もしくは送信者に公開されることはありません。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5967,2566,2062,1031,1032,1040,2125,4826,4782,4799,765" %}
[lnd v0.16.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[segura watchtowers post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003892.html
[segura watchtowers gist]: https://gist.github.com/sr-gi/f91f007fc8d871ea96ead9b27feec3d5
[news85 blinding]: /ja/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news226 bolts1031]: /ja/newsletters/2022/11/16/#bolts-1031
[news225 bolts1032]: /ja/newsletters/2022/11/09/#bolts-1032
[news243 bdk]: /ja/newsletters/2023/03/22/#bdk-793
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.16.0.md
[lnurl]: https://github.com/lnurl/luds
