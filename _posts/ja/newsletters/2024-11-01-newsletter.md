---
title: 'Bitcoin Optech Newsletter #327'
permalink: /ja/newsletters/2024/11/01/
name: 2024-11-01-newsletter-ja
slug: 2024-11-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、タイムアウトツリー型のチャネルファクトリーの提案と、
サイレントペイメントの生成時に使用される離散対数の等価性の証明に関するBIPのドラフトを掲載しています。
また、新しいソフトウェアのリリースや、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **<!--timeout-tree-channel-factories-->タイムアウトツリー型のチャネルファクトリー:**
  ZmnSCPxjは、 _SuperScalar_ という新しいマルチレイヤー[チャネルファクトリー][topic channel factories]設計の提案を
  Delving Bitcoinに[投稿し][zmnscpxj post1]、Optechのコントリビューターと[議論しました][deepdive]。
  この設計の目標は、広範な合意を必要とする大規模なプロトコル変更を待たずに、
  単一のベンダーが簡単に実装可能な構造を提供することです。たとえば、ウォレットソフトウェアを配布する
  LSP（Lightning Service Provider）は、LNのトラストレス性を損なうことなく、
  ユーザーがより安価にチャネルを開き、インバウンド流動性を受け取ることができるようになります。

  全体的な構造は _タイムアウトツリー_ に基づいており、 _ファンディングトランザクション_ は
  事前に定義された子トランザクションのツリーに支払いをし、
  最終的に多数の個別のペイメントチャネルにオフチェーンで支払います。
  設定可能なタイムアウト（１ヶ月など）が経過すると、タイムアウトツリーに関与している参加者の一部は、
  ツリーに残っている資金を没収されます。これは期限切れになる前に資金を引き出すか、
  代替のセキュリティを見つけるインセンティブが生まれ、ツリーの一部をオンチェーンに公開するのではなく、
  安価なオフチェーンメカニズムの利用を促すことができます。
  以前紹介したタイムアウトツリー（[ニュースレター #270][news270 timeout trees]参照）では、
  タイムアウトしたユーザーの資金はサービスプロバイダーのものになっていましたが、
  ZmnSCPxjは、これを逆転させ、サービスプロバイダーのタイムアウトした資金をユーザーのものとするようにします。
  これにより、トランザクションを承認する負担がエンドユーザーではなく、サービスプロバイダーに課せられます。

  使用されるタイムアウトツリーでは、各参加者が署名を提供する必要があります。
  これによりコンセンサスの変更は不要になりますが、
  よく知られている[複数の署名者の調整問題][news270 coordination]により、
  ファクトリー内の実際の最大ユーザー数が制限されます。

  タイムアウトツリーのほとんどのリーフは、
  現在使用されている一般的なタイプのチャネル（[LN-Penalty][]）のオフチェーンファンディングトランザクションで、
  LNチャネルの管理に既存のコードを再利用できます。各チャネルの参加者は、
  エンドユーザーとタイムアウトツリーを作成したLSPです。
  ツリーのリーフの一部は、資金のリバランス目的でLSPにより排他的に管理される場合があります。

  ルートとリーフの間には、[Duplexペイメントチャネル][topic duplex micropayment channels]があります。
  LN-Penaltyチャネルとは異なり、Duplexチャネルでは2人より多くの参加者が安全に資金を共有することができます。
  ただし、LN-Penaltyが実質的に無制限の更新が可能なのに対し、Duplexチャネルの更新数は比較的少なくなります。
  中間のDuplexチャネルは、LSPと２人のエンドユーザーが関与するリバランスを可能にするために使用されます。
  これらのリバランスは、オフチェーンの速度で安全に完了できるため、
  ユーザーはチャネルに十分なキャパシティがなかったとしても、ほぼ瞬時に入金を受け取ることができます。

  [その後の投稿][zmnscpxj post2]で、ZmnSCPxjはDuplexチャネルの一部を
  [Spillmanスタイル][spillman channel]の（単方向）のマイクロペイメントチャネルに置き換えることを説明しました。
  これは、一方的な閉鎖の場合にはオンチェーンの効率が悪くなるものの、
  協力的な閉鎖の場合にはオンチェーンの効率がよくなります。

  この提案には適度な議論がありました。著者は、この提案の弱点の１つは、
  複数の異なる種類のチャネルを使用することによる技術的な複雑さと、
  どのようなチャネルファクトリーの設計においても固有の課題となるオフチェーンの状態管理だと述べています。
  ただし、この提案には単一のチームで実装でき、LNプロトコルに多くの変更を加えることなく標準のLNと相互運用できるという利点があります。

- **DLEQ証明のBIPドラフト:** Andrew Tothは、
  Bitcoinで使用される楕円曲線（secp256k1）の[離散対数の等価性][topic dleq]（DLEQ）の証明を
  生成および検証するための[実装][dleq imp]のリンクとBIPのドラフトをBitcoin-Devメーリングリストに[投稿しました][toth dleq]。
  DLEQを使用すると、（対応する公開鍵など）秘密鍵について何も明かすことなく、
  秘密鍵を知っていることを証明することができます。これは、過去に、
  どのUTXOを所有しているかを明かすことなく、UTXOを所有していることを証明するために使用されました（
  ニュースレター[#83][news83 podle]および[#131][news131 podle]参照）。

  現在のBIPは、複数の個別の署名者で作成された[サイレントペイメント][topic silent payments]のサポートを目的としています。
  署名者の１人が嘘をついたり、誤りを犯したりすると、資金が失われる可能性があります。
  DLEQを使用すると、各署名者は他の署名者に秘密鍵を明かすことなく正しく署名したことを証明できます。
  以前の議論については、[ニュースレター #308][news308 sp]をご覧ください。

  この提案に対して、以前JoinMarketの[coinjoin][topic coinjoin]実装用の
  DLEQ証明システムを実装したAdam Gibsonから[返信][gibson dleq]がありました。
  彼は、BIPバージョンのDLEQをサイレントペイメント以外の用途にも柔軟に対応できるようにするためのいくつかの変更を提案しました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 2.0.0][]は、このセルフホスト型のペイメントプロセッサの最新リリースです。
  新機能には、「ローカライゼーションの改善、サイドバーナビゲーション、オンボーディングフローの改善、
  ブランディングオプションの改善、プラグイン可能なレートプロバイダーのサポート」などが含まれています。
  アップグレードにはいくつかの重大な変更とデーベースの移行が含まれています。
  アップグレードをする前に、[お知らせ][btcpay post]を読むことをお勧めします。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31130][]では、過去セキュリティ上の脆弱性があり（ニュースレター[#310][news310 upnp]参照）、
  デフォルトで既に無効になっている`miniupnp`の依存性を削除し、UPnP（Universal Plug and Play）
  インターネットゲートウェイデバイス（IGD）のサポートを削除しました。
  これは、NATポートマッピングプロトコル（NAT-PMP）へのフォールバックを備えたポート制御プロトコル（PCP）に置き換えられました
  （ニュースレター[#323][news323 pcp]参照）。これにより、手動設定なしでノードに到達できるようになり、
  `miniupnp`の依存関係に関連するセキュリティリスクがなくなります。

- [LDK #3007][]は、`OutboundTrampolinePayload`列挙型に２つの新しい`BlindedForward`と`BlindedReceive`を追加し、
  [BOLT12][]の[オファー][topic offers]プロトコルを実装するための基礎として、
  [トランポリンルーティング][topic trampoline payments]内の[ブラインドパス][topic rv routing]のサポートを導入します。

- [BIPs #1676][]は、[BIP85][]が広く展開され、破壊的な変更を導入する段階を過ぎたため、
  ステータスを最終版に更新します。これは、最近の重大な変更がマージされ、その後元に戻された（ニュースレター
  [#324][news324 bip85]参照）後に提案されました。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31130,3007,1676" %}
[news83 podle]: /ja/newsletters/2020/02/05/#podle
[news131 podle]: /ja/newsletters/2021/01/13/#ln-utxo
[news308 sp]: /ja/newsletters/2024/06/21/#psbt
[zmnscpxj post1]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[deepdive]: /en/podcast/2024/10/31/
[news270 timeout trees]: /ja/newsletters/2023/09/27/#covenant-ln
[zmnscpxj post2]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143/16
[spillman channel]: https://en.bitcoin.it/wiki/Payment_channels#Spillman-style_payment_channels
[toth dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0f40eab-42f3-4153-8083-b455fbd17e19n@googlegroups.com/
[dleq imp]: https://github.com/BlockstreamResearch/secp256k1-zkp/blob/master/src/modules/ecdsa_adaptor/dleq_impl.h
[gibson dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/77ad84ed-2ff8-4929-b8da-d940c95d18a7n@googlegroups.com/
[ln-penalty]: https://en.bitcoin.it/wiki/Payment_channels#Poon-Dryja_payment_channels
[btcpay post]: https://blog.btcpayserver.org/btcpay-server-2-0/
[btcpay server 2.0.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.0
[news270 coordination]: /ja/newsletters/2023/09/27/#covenant-ln
[news310 upnp]: /ja/newsletters/2024/07/05/#miniupnpc
[news323 pcp]: /ja/newsletters/2024/10/04/#bitcoin-core-30043
[news324 bip85]: /ja/newsletters/2024/10/11/#bips-1674