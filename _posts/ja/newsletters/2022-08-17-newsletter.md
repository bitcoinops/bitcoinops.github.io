---
title: 'Bitcoin Optech Newsletter #213'
permalink: /ja/newsletters/2022/08/17/
name: 2022-08-17-newsletter-ja
slug: 2022-08-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinのコンセンサスを変更せずにDLCの改善にBLS署名を使用する方法と、
新しいソフトウェアリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更の概要など、
恒例のセクションを掲載しています。

## ニュース

- **DLCにBitcoin互換のBLS署名を使用:**
  Discreet Log Contracts (DLC)は、オラクルとして知られる信頼できる第三者が、
  データの一部を証明できるようにします。オラクルを信頼する個人が、
  オラクルにコントラクトの存在やその条件を明かすことなく、その証明をコントラクトに使用することができるのが[DLCのメリット][topic dlc]です。
  DLCは、当初[Schnorr署名][topic schnorr signatures]の特徴を利用する提案でしたが、
  その後より一般化した[署名アダプター][topic adaptor signatures]を利用する形で開発されてきました。

  今週、Lloyd Fournierが[BLS][]（Boneh-Lynn-Shacham）署名を使用してオラクルに証明させることについてのメリットを
  DLC-Devメーリングリストに[投稿しました][fournier dlc-dev]。
  BitcoinはBLS署名をサポートしておらず、それを追加するためにはソフトフォークが必要ですが、
  FournierはBLS署名から安全に情報を抽出し、Bitcoinに変更を加えることなくBitcoin互換の署名アダプターを使用できる方法を説明した
  共著の[論文][fournier et al]をリンクしました。

  そしてFournierは、BLSベースの証明のいくつかの利点を説明しています。
  その中で最も重要なのは、「ステートレス」なオラクルが実現可能になることです。
  これは、（オラクルではない）コントラクトの参加者が、オラクルに証明してもらいたい情報について非公開での合意を可能にします。
  たとえば、オラクルが実行可能な任意のプログラミング言語で書かれたプログラムを指定できます。
  そして、そのコントラクトに従って、オラクルにその使用を伝えることなく預けた資金を割り当てることができます。
  コントラクトを決済するタイミングが来たら、各参加者は自分でプログラムを実行し、
  その結果に全員が合意したらオラクルを介さずにコントラクトを協力的に決済することができます。
  合意が得られなかった場合は、各参加者がプログラムをオラクルに送信し（おそらくこれに対して少額の支払いが発生する）、
  プログラムのソースコードを実行し、その実行結果に対するBLS署名を送り返してもらうことができます。
  この証明は、DLCのオンチェーン決済を可能にする署名に変換することができます。
  現在のDLCのコントラクトと同様に、オラクルはどのオンチェーントランザクションがそのBLS署名に基づくものなのか知ることはできません。
  （5-of-10のような）閾値設定を含む、複数のオラクルも使用することができます。

  投稿は、コントラクトの作成時にコントラクトを認識する必要がある既存のDLCオラクルに対するステートレスオラクルの優位性を説得力のある形で提示しています。
  この記事を書いている時点では、他のDLCコントリビューターからの返信はありませんでした。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust Bitcoin 0.29][]は、このシリーズの新しいメジャーリリースです。
  [リリースノート][rb29 rn]には、APIの破壊的な変更だけでなく、
  [Compact Blockリレー][topic compact block relay]のデータ構造のサポート（[BIP152][]）や、
  [Taproot][topic taproot]や[PSBT][topic psbt]サポートの改善など、多数の新機能やバグ修正が含まれていることが記されています。

- [Core Lightning 0.12.0rc2][]は、この人気のあるLNノード実装の次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23480][]は、鍵を調整することなく使用する場合（非推奨、[BIP341][bip341 internal]参照）、
  もしくは内部鍵とスクリプトが知られていない場合（これは安全でない可能性があります。詳細はPRのコメントおよびPRに追加されたドキュメントを参照）に、
  Taprootのアウトプットで公開された鍵を参照するための`rawtr()`ディスクリプターで[アウトプット・スクリプト・ディスクリプター][topic descriptors]を更新しています。
  既存の`raw()`ディスクリプターを使用することで、これらの鍵を参照することは可能ですが、
  これはBitcoin CoreのUTXOのデータベースをスキャンするための`scantxoutset` RPCようなツールで使用することを意図しており、
  新しい`rawtr()`ディスクリプターにより、鍵のオリジン情報などTaprootのアウトプットに追加情報を関連付けるのが簡単になります。
  鍵のオリジン情報は、[バニティアドレス][vanity addresses]を作成するためのインクリメンタルな調整や、
  [プライバシーのための協調的な調整][reusable taproot addresses]など、別の鍵生成方式が使用されていることを示す場合があります。

- [Bitcoin Core #22751][]は、未承認トランザクションの配列を受け取り、
  そのトランザクションでどれだけのBTCがウォレットの残高に追加されるか、もしくは減らされるかを返す`simulaterawtransaction` RPCを追加しました。

- [Eclair #2273][]は、2つのLNノードがより緊密に連携して新しいペイメントチャネルを開設する、
  [提案中の][bolts #851]対話型のファンディング・プロトコルを実装しました。対話型のファンディングの実装により、
  Eclairはチャネルに参加する両方のノードが新しいチャネルに資金を提供できる[デュアル・ファンディング][topic dual funding]のサポートに近づきました。
  ディアル・ファンディングの追加の準備も、今週[Eclair #2247][]でマージされました。

- [Eclair #2361][]は、[BOLTs #996][]で提案されているように（[ニュースレター #211][news211 bolts996]参照）、
  チャネルの更新時に`htlc_maximum_msat`フィールドを含めるよう要求するようになりました。

- [LND #6810][]は、ウォレットで自動生成するアウトプットスクリプトのほほすべてで、
  支払いの受け取りに[Taproot][topic taproot]アウトプットを使用するようになりました。
  さらに、[LND #6633][]では`option_any_segwit`のサポートを実装し（[ニュースレター #151][news151 any_segwit]参照）、
  チャネルの協調クローズで資金をTaprootアウトプットで受け入れるようにしました。

- [LND #6816][]は、[ゼロ承認チャネル][topic zero-conf channels]の使用方法に関する[ドキュメント][lnd 0conf]を追加しました。

- [BDK #640][]は、`get_balance`関数を更新し、現在の残高を4つのカテゴリに分けて返すようになりました。
  承認済みのアウトプット用の`available`残高、
  自身のウォレットからの未承認アウトプット（つまり、お釣り用のアウトプット）用の`trusted-pending`残高、
  外部ウォレットからの未承認アウトプット用の`untrusted-pending`残高、
  Bitcoinのコンセンサスルールに従って使用可能になるまでに最低100回の承認に達していないコインベース（マイニング）アウトプット用の`immature`残高。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23480,22751,2273,2361,2247,996,6810,6633,6816,640,851" %}
[rust bitcoin 0.29]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.29.1
[core lightning 0.12.0rc2]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc2
[bls]: https://ja.wikipedia.org/wiki/ボネ・リン・シャチャム署名
[fournier dlc-dev]: https://mailmanlists.org/pipermail/dlc-dev/2022-August/000149.html
[fournier et al]: https://eprint.iacr.org/2022/499.pdf
[bip341 internal]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#constructing-and-spending-taproot-outputs
[news211 bolts996]: /ja/newsletters/2022/08/03/#ldk-1519
[news151 any_segwit]: /ja/newsletters/2021/06/02/#bolts-672
[lnd 0conf]: https://github.com/lightningnetwork/lnd/blob/6c915484ba056870f9ed8b57f043d51f26137507/docs/zero_conf_channels.md
[vanity addresses]: https://en.bitcoin.it/wiki/Vanitygen
[reusable taproot addresses]: https://gist.github.com/Kixunil/0ddb3a9cdec33342b97431e438252c0a
[rb29 rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/110b5d89630d705e5d5ed0541230923eb4fc600f/CHANGELOG.md#029---2022-07-20-edition-2018-release
