---
title: 'Bitcoin Optech Newsletter #173'
permalink: /ja/newsletters/2021/11/03/
name: 2021-11-03-newsletter-ja
slug: 2021-11-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、トランザクションを直接マイナーに送信することについての議論と、
ウォレットの実装に推奨されるTaprootのTest Vectorのセットへのリンクの掲載に加えて、
Taprootの準備について、新しいリリースとリリース候補、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点についての恒例のセクションも含まれています。

## ニュース

- **<!--submitting-transactions-directly-to-miners-->マイナーに直接トランザクションを送信する:**
  Lisa Neigutは、Bitcoin-Devメーリングリストで、P2Pトランザクションリレーネットワークを廃止し、
  ユーザーがマイナーに直接トランザクションを送信する可能性について[スレッド][neigut relay]を立ち上げました。
  この動作モードの利点として提案されたのは、必要な帯域幅の削減、プライバシーの向上、
  [RBF][topic rbf]や[CPFP][topic cpfp]のパッケージルールの複雑さの解消、
  次のブロックの手数料率のコミュニケーションの改善などでした。
  しかし、何人かは反対しました:

  - **<!--bandwidth-requirements-->必要な帯域幅:**
    2016年から使用されている[Compact Block Relay][topic compact block relay]では、
    未承認トランザクションを受信したノードが、そのトランザクションがブロックに含まれている場合に、
    最小限の帯域幅のオーバーヘッドにより再受信をスキップできることを、いくつかの回答が指摘しています。
    今後提案されている[Erlay][topic erlay]などの改良により、
    未承認トランザクションリレーによる帯域幅のオーバーヘッドをさらに小さくすることができます。

  - **<!--improved-privacy-->プライバシーの向上:**
    マイナーにのみトランザクションを送信することで、承認前のトランザクションは公開されなくなりますが、
    Pieter Wuilleは、マイナーにネットワークの特権ビューも提供することになると[主張しています][wuille relay]。
    公的な透明性が望ましいでしょう。

  - **<!--rbf-cpfp-and-package-complexity-->RBF、CPFPとパッケージの複雑さ:**
    ノードオペレーターはマイナーよりもリソースを消費する攻撃に敏感であることは確かですが、
    Gloria Zhaoは、これは主に程度の問題であると[指摘しています][zhao relay]。
    同じ攻撃がより大規模に実行されるとマイナーにも影響が及ぶため、
    ノードがすでに採用しているのと同じタイプの防御策がマイナーにも必要になるでしょう。

  - **<!--feerate-communication-->手数料率のコミュニケーション:**
    Bitcoin Coreが手数料率を推定するために使用している現在の方法は、
    未承認トランザクションを受信し、それが承認済みブロックで確認できるまでの時間を確認することに基づいています。
    これはリアルタイムの手数料率の情報よりも遅れがありますが、
    Pieter Wuilleは、マイナーに弱いブロック（チェーンに追加するのに十分なproof of workを持っていないブロック）をブロードキャストさせるなど、
    以前から提案されている他の方法を使うことで改善できると[提案しています][wuille relay]。
    弱いブロックは、PoWが有効なブロックよりも頻繁に発生するため、
    マイナーが現在取り組んでいるトランザクションに関するより新しい情報を提供することができます。

  直接的な反論に加えて、現行システムのいくつかの利点が指摘されています:

    - **<!--miner-anonymity-->マイナーの匿名性:**
      現在50,000台以上のノードがすべてのトランザクションをリレーしているため、
      マイナーはそれらのノードの1つをひっそりと運用することで必要な情報を簡単に受け取ることができます。
      仮名の開発者ZmnSCPxjは、たとえTorのような匿名ネットワーク上であっても、
      マイナーに永続的なIDを維持させることで、マイナーの特定が容易になり、
      一部のトランザクションを検閲するよう強制することができると[提案しました][zmnscpxj relay]。

    - **<!--censorship-resistance-->検閲耐性:**
      現在、誰もが基本的にあらゆるコンピューターを使ってノードを立ち上げ、
      リレーされたトランザクションを受信し、マイニング機器に接続し、マイニングを始めることができます。
      Pieter Wuilleは、マイナーに直接送信する場合はそうはならないと[指摘しています][wuille relay]。
      新規マイナーがトランザクションを受信するためには、自分のノードを配信する必要がありますが、
      検閲や[シビル攻撃][sybil attacks]の両方に耐性のあるアクセスしやすい方法はありません。
      特に、Wuilleは「マイナーが自分の[送信先URL]をオンチェーンで公開する仕組みは役に立ちません。
      それは、その公開を検閲しないように他のマイナーに依存するでしょう」と述べています。

    - **<!--centralization-resistance-->集中化への耐性:**
      Wuilleはまた、「追加の送信のコストと複雑さは、[各マイナーの]ハッシュレートとは無関係だが、
      メリットは[ハッシュレート]に正比例する。」とも述べています。
      これにより、「ほとんどのウォレットにとって、
      最大規模のいくつかのプールに[トランザクション]を送信することがはるかに容易になり」、
      集中化が促進されることになります。

- **<!--taproot-test-vectors-->TaprootのTest Vector:**
  Pieter Wuilleは、Bitcoin-Devメーリングリストに[Taproot][topic taproot]の[BIP341][]仕様への追加を提案している
  [Test Vector][bips #1225]のセットを[投稿しました][wuille test]。
  それらは、「key/scriptからのマークルルート / tweak / scriptPubKeyの計算、
  key path支払いのsigmsg / sighash / signatureの計算、
  script path支払いのcontrol blockの計算をカバーするウォレットの実装」にフォーカスしています。

    Test Vectorは[アクティベーション後すぐ][p4tr waiting]にTaprootを使えるようにしたいと考え、
    実装に取り組んでいる開発者にとって特に有用なものになるはずです。

## Taprootの準備 #20: アクティベーション時に何が起こる？

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/20-activation.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.20.2][]は、Bitcoin Coreの前のブランチのメンテナンスリリースで、
  小さな機能とバグ修正を[含んでいます][bcc0.20.2 rn]。

- [C-Lightning 0.10.2rc2][]は、[経済合理性のないアウトプットのセキュリティ問題][news170 unec bug]の修正、
  データベースサイズの縮小、
  `pay`コマンドの有効性の向上が[含まれた][decker tweet]リリース候補です（下記の*注目すべき変更*のセクションを参照）。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23306][]では、Address ManagerがIPアドレス毎に複数のポートをサポートできるようになりました。
  歴史的に、Bitcoin Coreは固定ポート8333を使用し、自動的にアウトバウンド接続をする際にこのポートのアドレスを強く推奨してきました。
  この動作は、（Bitcoinネットワーク上でアドレスをゴシップする）非BitcoinサービスのDoSから、
  Bitcoinノードが利用されるのを防ぐのに役立つと示唆されていますが、
  ネットワークトラフィックを観察することでBitcoinノードを簡単に検出することもできます。
  それぞれの（IPとポート）の組み合わせを個別のアドレスとして扱うことで、
  将来的にアドレスをより統一的に扱うことができます。

- [C-Lightning #4837][]では、`--max-dust-htlc-exposure-msat`設定オプションが追加され、
  金額がdust limitを下回る保留中のHTLCの合計残高を制限します。
  詳細については、Rust-Lightningの同様のオプションについての[以前の記事][news162 mdhemsat]をご覧ください。

- [Eclair #1982][]では、ノードオペレーターの対応を必要とする重要な通知を集めた新しいログファイルを導入しました。
  付属のリリースノートによると、`notifications.log`がノードオペレーターが監視すべきものです。

- [LND #5803][]では、支払いユーザーが繰り返し支払いするための追加の手順を実行しなくても、
  同じ[Atomic Multipath Payment (AMP)][topic multipath payments]インボイスへの
  複数の[Spontaneous payment][topic spontaneous payments]が可能になりました。
  同じインボイスへの複数の支払いを受け取る機能は、
  既存の[簡略化されたマルチパス支払い][topic multipath payments]の実装では不可能なAMPの機能です。

- [BTCPay Server #2897][]は、支払い方法として[LNURL-Pay][]のサポートを追加し、
  [Lightningアドレス][news167 lightning addresses]のサポートも有効にしています。

{% include references.md %}
{% include linkers/issues.md issues="23306,4837,1982,5803,2897,1225" %}
[c-lightning 0.10.2rc2]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2rc2
[neigut relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019572.html
[wuille relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019578.html
[zhao relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019579.html
[zmnscpxj relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019573.html
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[news170 unec bug]: /ja/newsletters/2021/10/13/#ln-spend-to-fees-cve-ln-cve
[bitcoin core 0.20.2]: https://bitcoincore.org/bin/bitcoin-core-0.20.2/
[bcc0.20.2 rn]: https://bitcoincore.org/en/releases/0.20.2/
[wuille test]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019587.html
[p4tr waiting]: /ja/preparing-for-taproot/#なぜ待つ必要があるのか
[LNURL-Pay]: https://github.com/fiatjaf/lnurl-rfc/blob/luds/06.md
[news167 lightning addresses]: /ja/newsletters/2021/09/22/#lightning
[news162 mdhemsat]: /ja/newsletters/2021/08/18/#rust-lightning-1009
[series preparing for taproot]: /ja/preparing-for-taproot/
