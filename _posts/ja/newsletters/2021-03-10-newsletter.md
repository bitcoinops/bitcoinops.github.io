---
title: 'Bitcoin Optech Newsletter #139'
permalink: /ja/newsletters/2021/03/10/
name: 2021-03-10-newsletter-ja
slug: 2021-03-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、提案されているTaprootのアクティベーション方法に関する継続的な議論の要約と、
Taprootに基づいて構築されている既存のソフトウェアの文書化の取り組みのリンクを掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要やリリースとリリース候補の発表、
人気のあるBitcoinのインフラストラクチャプロジェクトの注目すべき変更点の解説などの通常のセクションが含まれています。

## ニュース

- **<!--taproot-activation-discussion-->Taprootのアクティベーションに関する議論:**
  先週のアクティベーションに関する議論では、[BIP8][]で`LockinOnTimeout=true` (`LOT=true`)とするか、
  `LOT=false`とするかで意見が割れたため、今週のメーリングリストでの議論のほとんどは、
  代替となるアクティベーションメカニズムに焦点を当てていました。
  いくつかの提案は以下のとおりです:

    - *<!--user-activated-soft-fork-uasf-->User Activated Soft Fork (UASF):*
      Bitcoin CoreのソフトフォークにBIP8 `LOT=true`を実装するための計画が[議論されています][uasf discussion]。
      この計画では、（広く提案されているように）2022年7月までにTaprootのアクティベートするようマイナーに要求しますが、
      マイナーはそれよりも早くアクティベートすることも可能です。

    - *<!--flag-day-->フラグ・デイ:*
      今から約18ヶ月後に（提案されている）Taprootをアクティベートする特定のブロック高や時間を
      ノードにプログラムするいくつかの提案（[1][flag day corallo]、[2][flag day belcher]）。
      アクティベーションにマイナーのシグナルは必要なく、早期のアクティベーションはできません。
      Anthony Townsが[実装のドラフト][bitcoin core #21378]を書きました。

    - *<!--decreasing-threshold-->閾値の減少:* 新しいコンセンサスルールがロックインされる前に、
      マイナーがTaprootの準備ができていることを通知する必要のあるブロックの数を、
      時間の経過とともに徐々に減少させるいくつかの提案（[1][decthresh guidi]、[2][decthresh luaces]）。
      [ニュースレター #107][news107 decthresh]で紹介したAnthony Townsの昨年の提案も参照。

    - *<!--a-configurable-lot-->設定可能な`LOT`:*
      BIP8の`LOT`の値を設定オプションにするという以前議論された提案（[ニュースレター #137][news137 bip8conf]参照）に加えて、
      RPCコマンドを呼び出す外部スクリプトによって`LOT=true`を適用する方法を示す大まかなコードが[投稿されました][rubin invalidateblock]。
      また、`LOT=true`がブロックチェーンを不安定にすることを懸念するノード運用者が反対する方法を示す追加のコードも[作成されました][towns anti-lot]。

    - *<!--a-short-duration-attempt-at-miner-activation-->短期間のマイナーアクティベーションの試み:*
      Taprootのアクティベーションロジックを実装したフルノードのリリース直後から
      マイナーがTaprootをロックインするまでに約3ヶ月の期間を与えるという[更新された提案][harding speedy]。
      この試みが失敗した場合、コミュニティには他のアクティベーション方法への移行が推奨されます。
      試みが成功した場合も、エコノミーのほとんどがノードをアップグレードできるよう、
      Taprootがアクティベートされるまでに数ヶ月の遅延が発生します。
      この提案のために、[Bitcoin Coreの既存のBIP9のコード][bitcoin core #21377]をベースにしたものと、
      [以前提案されたBIP8の実装をベースにした][bitcoin core #21392]実装のドラフトが、
      それぞれAnthony TownsとによってAndrew Chow書かれました。

    どの提案も、ほぼすべての人の第一希望になることはないと思われましたが、
    *Speedy Trial*という名の短期間の試みを[受け入れてもいい][folkson gist]という人は多いようでした。
    一方、次のようないくつかの懸念事項もありました:

    - *<!--could-be-co-opted-for-mandatory-activation-->強制的なアクティベーションに利用される可能性:*
      マイナーが早期にTaprootをサポートする通知をしない場合に他のアクティベーションの試行を推奨していますが、
      早期の強制アクティベーションを求めるユーザーのグループに利用されるのではないかという懸念が[表明されました][corallo not speedy enough]。
      ただし、このような危険なほど短いタイムラインで強制アクティベーションの試行を表明したグループは[これまでいません][##taproot-activation log 3/5]。

    - *<!--using-time-based-or-height-based-parameters-->時間ベースのパラメーターか、高さベースのパラメーターか:*
      本提案では、（直近11ブロックの中央値に基づく）タイムスタンプかブロック高のいずれかを使用して、
      `start`、`timeout`および`minimum_activation`パラメーターを設定する際のトレードオフについて説明しています。
      タイムスタンプを使用すると、Bitcoin Coreへのパッチが最も小さく、レビューも容易になります。
      ブロック高を使用すると、特にマイナーにとって、少し予測可能性が高くなり、BIP8を使用する他の試みと互換性があります。

    - *<!--myopic-->近視眼的:* 提案が短期的なものに焦点を合わせすぎていることが[懸念][russell concern]されました。
      [IRCで要約されている][irc speedy]ように、"Speedy Trialは、マイナーがTaprootをアクティベートする（可能性の高い）ケースに完全に備えるものですが、
      Segwitがタイムリーにアクティベートできなかったことから得られた教訓を体系化したものではありません。
      Taprootのアクティベーションは、今後のアクティベーションのテンプレートを作成する機会です。
      このテンプレートは、最良の結果だけでなくアクティベーションを進行するためのあらゆる方法において、
      開発者、マイナー、マーチャント、投資家およびエンドユーザーの役割と責任を明確に定義します。
      特に、Bitcoinの実用上のユーザーが持つ最終決定者の役割を有効にし、正式に記します。
      これを定義することは、将来ますます困難になるでしょう。なぜなら、それを定義するのはすでに危機に陥っているときのみで、
      Bitcoinの成長は、将来の合意がより大きな規模で行われる必要があり、それはより困難になることを意味するからです。"

    - *<!--speed-->スピード:* この提案はIRCのチャネル ##taproot-activation での最初の議論に基づき、
      マイナーにTaprootをロックインするのに約3ヶ月与え、（ロックインが達成された場合）
      アクティベートまでにシグナルの計測開始から固定の6ヶ月待つことを提案しています。
      これに対して、もう少し短いタイムラインや長いタイムラインを求める声がありました。

    さまざまな提案に関する議論を引き続き追跡し、今後のニュースレターで重要な進展をまとめます。

- **<!--documenting-the-intention-to-use-and-build-upon-taproot-->Taprootを利用する、Taprootに依拠する意思の文書化:**
  アクティベーション方法に関する議論の中で、Chris Belcherは、ソフトフォークのアクティベートに関する議論において
  開発者がSegwitを実装する意思があること表明したソフトウェアの大規模なリストが編集されたことを[指摘しました][flag day belcher]。
  彼は、同様のリストを作成し、Taprootを支持する総計を後世のために記録することを提案しました。
  そうすれば、Taprootがどのような方法でアクティベートされることになったとしても、
  エコノミーの大部分がTaprootを望んでいることが明らかになるでしょう。

    Jeremy Rubinは、Bitcoin-Devメーリングリストに開発者がTaprootの新機能の提案に基づいて構築されたプロジェクトのリンクを投稿できる、
    それに似た[wikiページ][taproot uses]へのリンクを[投稿しました][rubin building]。
    これにより、Taprootが人々が実際に望むソリューションを提供し、その機能が利用されるように設計されていることを保証することができます。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Erlay: bandwidth-efficient transaction relay protocol][review club #18261]は、
Gleb NaumenkoによるPR（[#18261][Bitcoin Core #18261]）で、
[BIP330][]をBitcoin Coreに実装することを提案しています。

Review Clubでは、[Erlay][topic erlay]に関連するトレードオフ、実装および
潜在的な新しい攻撃ベクトルに焦点を当てて議論しました。その後のミーティングでは、
Erlayの効率的なリレープロトコルの基礎となるPinSketch *set reconciliation*
アルゴリズムを実装した[ライブラリ][minisketch]である[Minisketch][topic minisketch]について議論しました。

{% include functions/details-list.md
  q0="<!--what-is-erlay-->Erlayとは？"
  a0="帯域幅の効率やスケーラビリティおよびネットワーク・セキュリティを向上させるために、
     *フラッディング*と*set reconciliation*の組み合わせをベースにした新しいトランザクションリレー方法です。
     このアイディアは、2019の論文*[Bandwidth-Efficient Transaction Relay for Bitcoin][erlay paper]*
     で発表され、[BIP330][]で規定されています。"

  q1="<!--what-advantages-does-erlay-bring-->Erlayがもたらすメリットは?"
  a1="ノード運用に必要な帯域幅のおよそ半分を占める[トランザクションリレーのための帯域幅使用量が減少し][erlay 1]、
     [ピア接続のスケーラビリティ][erlay 2]が向上することで、ネットワークが分断攻撃に対してより堅牢になり、
     [単一ノードがエクリプス攻撃に対してより耐性を持つようになります][erlay 3]。"

  q2="<!--what-are-some-tradeoffs-of-erlay-->Erlayのトレードオフは何ですか？"
  a2="トランザクションの伝播レイテンシーがわずかに増加します。Erlayでは、
     すべてのノード間で未確認のトランザクションをリレーする時間が3.15秒から5.75秒に増加すると推定されます。
     これは全体のトランザクション処理時間である約10分のごく一部です。
     もう１つのトレードオフは、コードの追加と計算の複雑さです。"
  a2link="https://bitcoincore.reviews/18261#l-94"

  q3="<!--why-can-set-reconciliation-introduced-by-erlay-scale-better-than-flooding-->
  なぜErlayで導入されるset reconciliationはフラッディングよりもスケールするのですか？"
  a3="各ノードが受信したすべてのトランザクションをそのピアに通知するフラッディングによるトランザクション伝播は、
     帯域幅の効率が悪く、冗長性が高くなります。これはネットワークの接続が向上するとより顕著になりますが、
     ネットワーク接続の向上はネットワークの成長とセキュリティには望ましいことです。
     Erlayは、非効率なフラッディングによって送信されるトランザクションデータを減らし、
     より効率的なset reconciliationに置き換えることで、スケーラビリティを向上させます。"

  q4="<!--what-would-be-the-change-in-frequency-of-the-existing-peer-to-peer-message-types-->
     既存のP2Pメッセージタイプの頻度はどう変化しますか？"
  a4="Erlayでは、`inv`メッセージの頻度は減り、`getdata`と`tx`メッセージの頻度は変わりません。"
  a4link="https://bitcoincore.reviews/18261#l-140"

  q5="<!--how-would-2-peers-reach-agreement-on-using-erlay-s-set-reconciliation-->
     2つのピアはどうやってErlayのset reconciliationの使用に合意するのですか？"
  a5="version-verackのハンドシェイク中に交換される新しい`sendrecon`P2Pメッセージを介して合意します。"
  a5link="https://bitcoincore.reviews/18261#l-212"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Eclair 0.5.1][]は、このLNノードの最新のリリースで、起動速度の向上、
  ネットワークグラフの同期時に消費する帯域幅の削減、
  [Anchor Output][topic anchor outputs]のサポートに向けた一連の小さな改善が行われています。

- [HWI 2.0.0RC2][hwi 2.0.0]は、HWIの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20685][]では、[I2P SAMプロトコル][I2P SAM protocol]を使用したI2Pプライバシーネットワークのサポートが追加されています。
  この機能は[長い間要望されていました][Bitcoin Core #2091]が、[addr v2][topic addr v2]の追加によって最近可能になりました。
  I2Pの実行を希望するノード運用者のためのドキュメントはまだ作成中ですが、
  [Bitcoin StackExchange Q&A][i2p b.se]に開始するためのヒントが記載されています。

- [C-Lightning #4407][]は、`listpeers`RPCを更新し、各チャネルの現在の一方的なクローズ・トランザクションに関する手数料
  （手数料の総額と手数料率の両方）を含む情報を提供するフィールドを追加しました。

- [Rust-Lightning #646][]は、[マルチパス支払い][topic multipath payments]のサポートを追加できるように、
  支払いのための複数のパスを検索する機能を追加しました。

- [BOLTs #839][]では、ファンディング・トランザクションの確認に失敗した場合に、
  ファンディング手数料を節約するためのファンディング・トランザクションのタイムアウトに関する推奨事項が追加され、
  チャネルの資金提供者と受給者に強力な保証を提供します。
  新しい推奨事項では、資金提供者が2016ブロック以内にファンディング・トランザクションが確実に承認されることをコミットし、
  受給者が2016ブロック以内にそれを確認できない場合、保留中のチャネルを忘れることを推奨しています。

- [BTCPay Server #2181][]は、[BIP21][bip21]のURIをQRコードとして提示する際にbech32アドレスを大文字にします。
  これにより、大文字の部分文字列をより効率的にエンコードできるため、[QRコードの密度が低くなります][bech32 uppercase qr]。
  この変更に先立ち、BIP21 URIスキームを持つウォレットの広範な[互換性調査][btcpay uri survey]が行われました。

{% include references.md %}
{% include linkers/issues.md issues="20685,4407,646,839,2181,21378,21377,21392,2091,18261" %}
[uasf discussion]: http://gnusha.org/uasf/2021-03-02.log
[flag day corallo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018495.html
[flag day belcher]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018538.html
[decthresh guidi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018476.html
[decthresh luaces]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018587.html
[rubin invalidateblock]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018514.html
[towns anti-lot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018512.html
[harding speedy]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018583.html
[irc speedy]: http://gnusha.org/taproot-activation/2021-03-08.log
[folkson gist]: https://gist.github.com/michaelfolkson/92899f27f1ab30aa2ebee82314f8fe7f
[corallo not speedy enough]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018596.html
[##taproot-activation log 3/5]: http://gnusha.org/taproot-activation/2021-03-06.log
[rubin building]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018604.html
[taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
[news107 decthresh]: /en/newsletters/2020/07/22/#mailing-list-thread
[news137 bip8conf]: /ja/newsletters/2021/02/24/#taproot
[eclair 0.5.1]: https://github.com/ACINQ/eclair/releases/tag/v0.5.1
[hwi 2.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.0-rc.2
[russell concern]: https://twitter.com/rusty_twit/status/1368325392591822848
[btcpay uri survey]: https://github.com/btcpayserver/btcpayserver/issues/2110
[bech32 uppercase qr]: /en/bech32-sending-support/#creating-more-efficient-qr-codes-with-bech32-addresses
[bip21]: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
[I2P wiki]: https://ja.wikipedia.org/wiki/I2P
[I2P SAM protocol]: https://geti2p.net/ja/docs/api/samv3
[i2p b.se]: https://bitcoin.stackexchange.com/questions/103402/how-can-i-use-bitcoin-core-with-the-anonymous-network-protocol-i2p
[erlay paper]: https://arxiv.org/abs/1905.10518
[erlay 1]: https://bitcoincore.reviews/18261#l-94
[erlay 2]: https://bitcoincore.reviews/18261#l-97
[erlay 3]: https://bitcoincore.reviews/18261#l-99
[minisketch]: https://github.com/sipa/minisketch
