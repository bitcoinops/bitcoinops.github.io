---
title: 'Bitcoin Optech Newsletter #78: 2019 Year-in-Review Special'
permalink: /ja/newsletters/2019/12/28/
name: 2019-12-28-newsletter-ja
slug: 2019-12-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja

excerpt: >
  この特別編のOptech Newsletterでは、2019年におけるビットコインの重要な開発についてサマリーします。
---
{{page.excerpt}} これは[2018 summary][]の続編です。

{% comment %}
  ## Commits
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  8863

  ## Merges
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --merges --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  1988

  ## Mailing list posts
  $ for d in .lists.bitcoin-devel/ .lists.lightning/ ; do
    find $d -type f | xargs -i sed -n '1,/^$/p' '{}' | grep '^Date: .* 2019 ' | wc -l
  done | numsum
  1529

  ## Newsletter words; divide by 350 to get pages
  #
  ## Note, doesn't include this summary
  $ cd _posts/en/newsletters   # end italics_
  $ find 2019-* | xargs wc -w | tail -n1   # end italics*
  72450 total
{% endcomment %}

本サマリーは、この１年の約9,000コミット（約2,000マージ）、1,500を超えるメーリングリストへの投稿、数千件のIRCログ、その他のパブリックな情報などをレビューした[weekly newsletters][] を元に作成しております。すべての素晴らしい仕事をサマライズするために50のニュースレターの発行、200ページ相当のコンテンツの作成を行いました。それでも、多くの重要なコントリビューションを掲載できませんでした。特に、バグ・フィックス、テスト、レビュー、サポートなど非常に重要だけれどもニュースにならないものです。当サマリーでは、更に１年間を数ページにまとめるために、他の素晴らしい数多くのコントリビューションを省略しました。

それゆえに、本ニュースを続ける前に、2019年にビットコインに貢献したすべての人に心から感謝します。後続のサマリーで、たとえ、貴方やプロジェクトに言及することがなくとも、Optechそしてすべてのビットコイン・ユーザは、ビットコインに貢献した貴方に言葉にならないほど感謝しています。

## Contents

- January
    - [BIP127 proof of reserves](#bip127)
- February
    - [Bitcoin Core compatible with HWI](#core-hwi)
    - <a href="#miniscript">Miniscript</a>
- March
    - [Consensus cleanup soft fork proposal](#cleanup)
  - <a href="#signet">Signet</a>
    - [Lightning Loop](#loop)
- April
    - <a href="#assumeutxo">AssumeUTXO</a>
    - [Trampoline payments](#trampoline)
- May
    - <a href="#taproot">Taproot</a>
    - [SIGHASH_ANYPREVOUT](#anyprevout)
    - [OP_CHECKTEMPLATEVERIFY](#ctv)
- June
    - [Erlay and other P2P relay improvements](#erlay-and-other-p2p-improvements)
    - <a href="#watchtowers">Watchtowers</a>
- July
    - [Reproducible builds](#reproducibility)
- August
    - [Vaults without covenants](#vaults)
- September
    - <a href="#snicker">SNICKER</a>
    - [LN vulnerability](#ln-cve)
- October
    - [LN anchor outputs](#anchor-outputs)
- November
    - <a href="#bech32-mutability">Bech32 mutability</a>
    - [Bitcoin Core OpenSSL removal](#openssl)
    - [Bitcoin Core BIP70 removal](#bip70)
- December
    - [Multipath payments](#multipath)
- Featured summaries
    - [Major releases of popular infrastructure projects](#releases)
    - [Notable technical conferences and other events](#conferences)
    - [Bitcoin Optech](#optech)
    - [New open source infrastructure solutions](#new-infrastructure)

## January

{:#bip127}
１月に、Steven Rooseは、ビットコイン・カストディ業者が特定の量のビットコインを管理していることのエビデンスの作成に利用できる *proof of reserves* 疑似トランザクションの標準フォーマットを[提案][roose reserves]しました。この種のツールは、預金者がカストディアン業者からコインを引き出すことを保証するものではありませんが、カストディアン業者はコインの損失や盗難を隠すことが困難となります。Rooseはreserve proofsの作成に部分的署名ビットコイントランザクション（[PSBTs][topic psbt]）を元にした [ツール][news33 reserves]の作成を進めており、[BIP127][]として仕様を公開しています。

## February

{:#core-hwi}
2月には、ビットコイン・コアのマスター開発ブランチに、
[Hardware Wallet Interface (HWI)][topic hwi] Python ライブラリとコマンドラインツールを利用するために必要となる最後のPR群がマージされました。HWIは3月に初期の安定リリースが発表され、[4月][wasabi hwi]にWasabi Walletがサポート追加、11月にBTCPayが [side package][btcpayserver.vault]を通じてサポートを追加しました。<!--
https://github.com/btcpayserver/btcpayserver/pull/1152 -->.  HWIはハードウェア・ウォレットとソフトウェア・ウォレットが [output script descriptors][topic descriptors] と
部分的署名ビットコイン・トランザクション  ([PSBTs][topic psbt])の組み合わせでやり取りすることを容易にします。2019年は標準化されたフォーマットやAPIのサポートが進んだことにより、ユーザが特定のソリューションのみを選択するのではなく、ニーズに応じてハードウェアとソフトウェア・ソリューションの適切な組み合わせを選択することが容易にできるようになりました。

<div markdown="1" id="miniscript">
さらに2月には、Pieter Wuilleが[Stanford Blockchain Conference][] にて彼が取り組んでいたoutput script descriptorsのスピンアウトである[miniscript][topic miniscript]に関する [プレゼンテーション][wuille sbc miniscript]を実施しました。Miniscriptはビットコイン・スクリプトの階層化表現であり、ソフトウェアによる自動分析を簡素化します。これにより、スクリプトを満たすためにウォレットが提供する必要があるデータ（例えば、署名、ハッシュプリイメージ）、スクリプトにより利用されるトランザクションデータ量とそれを満たすデータ、ならびに、スクリプトがコンセンサス・ルールと一般的なトランザクション・リレー・ポリシーをパスするかどうかが分析可能となります。

Miniscriptに加えて、WuilleとAndrew PoelstraとSanket Kanjalkarは、miniscriptへコンパイルされるコンポーザブルなポリシー言語を提供しました（miniscript自体はBitcoin Scriptへ変換されます）。ポリシー言語により、コインを利用するために満たすべき条件を容易に記述することができます。複数のユーザでコインを共有してコントロールしたい場合、ポリシー言語のコンポーザビリティによりそれぞれのユーザーのサイン・ポリシーを一つのスクリプトで組み合わせることが容易になりました。

これが広範囲に普及した場合、異なるビットコインを扱うシステムが共に１つのトランザクションに署名することが容易になり、ウォレットのフロントエンド、LNノード、コインジョイン・システム、マルチシグ・ウォレット、コンシューマ・ハードウェア・ウォレット、ハードウェア・署名・モジュール（HSM）やその他のハードウェア、ソフトウェアを統合するために必要なカスタムコードの量が、大幅に削減されます。

Wuilleと彼の協力者らは、1年を通じてminiscriptに取り組み続け、続いて[コミュニティ・フィードバックを求め][news61 miniscript feedback]、ビットコイン・コアにサポートを追加する[PRを開きました][Bitcoin Core #16800]。Miniscriptは12月にLNディベロッパーにより、アップグレードされたバージョンによるオンチェーン・トランザクションの複数の新しいスクリプトを[分析し最適化する][anchor miniscript]ために利用されました。
</div>

## March

<div markdown="1" id="cleanup">
3月には、Matt Corallo がビットコインのコンセンサス・コードの潜在的な問題を取り除く[consensus cleanup soft fork][topic consensus cleanup]を提案しました。これらが適用されることにより、[time warp attack][]の解消、レガシー・スクリプトの[ワーストケースのCPU使用量][worst case CPU usage]の低減、キャッシュしているトランザクション検証結果の信頼性向上、既知の（コストはかかる）[軽量クライアントへの攻撃][news37 merkle tree attacks]の解消が見込まれます。

Time-warp のフィックスなど一部の提案は多くの人々の関心を引きつけましたが、ワーストケースのCPU使用量、検証結果のキャッシュのフィックスに関しての提案は、[批判][news37 cleanup discussion]も受けました。おそらく、それ故にこの年の後半にかけて実装に向けて当提案が進捗することはありませんでした。
</div>

<div markdown="1" id="signet">
また3月には、Kalle Almが、[signet][topic signet]に関するイニシャル・フィードバックをリクエスト、後に[BIP325][]となりました。Singet プロトコルは、全ての有効なブロックが中央集権型パーティによって署名される必要があるテストネットを作ることが可能です。この中央集権化はビットコインとは正反対のものですが、テスターが破壊的なシナリオ（chain  reorganizationなど）を作成したり、単にソフトウェア相互運用性テストを実施したい場合などに、テストネットとして理想的なものとなります。既存のビットコインのテストネットでは、reorgやその他のディスラプションが頻繁に発生、またそれが長期間にわたることもあり、テスト実施を非現実的なものとしています。

Signetは一年を通じて成熟していき、ゆくゆくはC-Lightningといったソフトウェアに[統合][cl signet]、[eltoo][]のデモなどに利用されていくでしょう。ビットコイン・コアにサポートを追加する[プルリクエスト][Bitcoin Core #16411]はオープンになっています。
</div>

{:#loop}
さらに、3月にはLightning Labsが[Lightning Loop][]を発表し、チャネルをクローズすることなく、オンチェーンのUTXOにLNチャネルからファンドの一部を引き出すノン・カストディアル・ソリューションを提供しました。6月には、既存のチャネルにUTXOを送信（追加）できるようLoopを[アップグレード][loop-in]しました。Loopは通常のオフチェーン・LN・トランザクションで使用されているHash Time Locked Contracts (HTLCs)を使用し、想定通りユーザのファンドがLNチャネルに転送されているか、もしくは、オンチェーントランザクションフィー以外の全てのコストのリファンドをユーザが受け取ることを保証します。これによりLoopはほぼ完全にトラストレスになります。
<div markdown="1" class="callout" id="releases">
### 2019 summary<br>Major releases of popular infrastructure projects

- [C-Lightning 0.7][] は、3月にリリースされ、年末までにかなり利用されるプラグイン・システムを追加しました。また、監査性を強化した安全性の高い[再現可能なビルド][topic reproducible builds]をサポートする最初のC-Lightningリリースとなりました。

- [LND 0.6-beta][] は、4月にリリースされ[Static Channel Backups (SCBs)][lnd scb] のサポートを追加しました。これにより、最新のチャネル・ステートを失ったとしても、LNチャネルでセトルしたファンドをリカバリーすることができます。このリリースには、新しいチャネルを開くのを支援する改善されたautopilotの機能や、チャネルを閉じる、またはカストディアンを利用することなくオンチェーンでファンドを動かすための [Lightning Loop][]とのBuit-in 互換性が含まれます。

- [Bitcoin Core 0.18][]は5月にリリースされ、部分的署名ビットコイン・トランザクション([PSBT][topic psbt])のサポートの改善、[output script descriptors][topic output script descriptors]のサポートが追加されました。これら2つの機能の追加により、Hardware Wallet Interface ([HWI][])の初期リリース・バージョンを利用することができます。

- [Eclair 0.3][]は5月にリリースされ、バックアップ・安全性の改善、プラグインのサポートの追加、Tor hidden serviceとしての稼働を可能にしました。

- [LND 0.7-beta][]は7月にリリースされ、オフライン時にチャネルを保護する [watchtower][topic watchtowers]を利用するサポートを追加しました。

- [LND 0.8-beta][]は10月にリリースされ、より拡張可能なオニオン・フォーマットのサポートを追加し、バックアップ・安全性を改善、watchtowerサポートを改善しました。

- [Bitcoin Core 0.19][]は11月にリリースされ、[CPFP carve-out][topic cpfp carve out] mempool policyを実装し、 [BIP158][]スタイルの[コンパクト・ブロック・フィルター][topic compact block
  filters] （現時点ではRPCのみ）の初期サポートを追加し、[BIP37][] ブルーム・フィルターならびに[BIP70][] payment requestsをデフォルトにするプロトコルを無効化することでセキュリティを改善しました。また、GUIユーザーをbech32アドレスをデフォルトにしました。

- [C-Lightning 0.8][]は12月にリリースされ、[multipath payments][topic multipath payments] のサポートを追加、デフォルトネットワークをテストネットからメインネットに変更しました。また、デフォルトでsqliteサポートに加えてpostgresqlサポートを提供するなど代替データベースをサポートする最初のメジャーリリースとなりました。
</div>

## April

{:#assumeutxo}
4月には、James O’Beirneが[AssumeUTXO][topic assumeutxo]を提案しました。これは、最近のUTXOセットの信頼するコピーをダウンロード、使用することでフルノードで古いブロックチェーンのヒストリーの検証を先送りすることができる手法です。新しく立ち上げたノードでは数時間、数日と待つのではなく、フルノードを使って、ウォレットやその他のソフトウェアがノードをスタートして数分でトランザクションの送受信を実施できます。

AssumeUTXOでは、ノードは最終的に初期のUTXOの状態を検証できるまで、バックグラウンドでブロックチェーンのヒストリーをダウンロード、検証することを提案しています。これにより、最終的にAssumeUTXOを利用しない通常のノードと同等のトラストレスなセキュリティを確保することができます。O'Beirneは年間を通じてプロジェクトに取り組み、 徐々に[新しい機能][dumptxoutset]を追加し、将来的にAssumeUTXOをビットコイン・コアに取り込むため既存コードのリファクタリングを実施しました。

<div markdown="1" id="trampoline">
また、4月には、Pierre-Marie Padiouが[トランポリン・ペイメント][topic trampoline payments]のアイデアを[提案][trampoline proposed]しました。これは、軽量LNノードがパス・ファインディングを重量ルーチング・ノードにアウトソースします。モバイルアップなどの軽量ノードは、すべてのLNルーティング・グラフをトラックすることが出来ないかもしれないため、ルート探索が困難になります。Padiouの提案は、軽量ノードにペイメントを近接ノードへルートし、そのノードに残りのパスを計算させるものです。ペイメントはトランポリンノードを経由して（跳ねて）行き先までたどり着きます。
プライバシー向上のため、支払者は順番に複数のトランポリンノードからの支払いの跳ね返りを要求する場合があります。これにより支払いが最終的な受取人宛なのか、または別のトランポリンノードにルーティングしているかどうか各ノードは分からなくなります。

LN仕様にトランポリン・ペイメントの機能を追加するための[PR][trampolines pr] は現在オープンになっており、Eclairの実装はトランポリン・ペイメントをリレーする [実験的なサポート][exp tramp] を追加しています。
</div>

## May

<div markdown="1" id="taproot">
5月にはPieter Wuilleは、[bip-taproot][]と [bip-tapscript][]からなる[taproot soft fork][topic taproot]を提案しました。これらは共に昨年の [bip-schnorr][] の提案の内容を継承しています。これらが実装されると、シングルシグ、マルチシグや多くのコントラクトにおいて同じスタイルのscriptPubKeysを使用することが可能になります。マルチシグや複雑なコントラクトの多くの支払いが、同様に見え、シングルシグの支払いにように見えます。これにより、大きくユーザ・プライバシーとコイン・ファンジビリティを改善すると同時に、マルチシグ、コントラクト・ユースケースにて消費されるブロックチェーンスペースの量を削減できます。

マルチシグとコントラクトの支払いがtaprootのプライバシーとスペース節約をフル活用出来ない場合でも、オンチェーンにコードのサブセットのみを入れれば良いだけかもしれません。それにより、現在よりもよいプライバシーとブロックチェーンスペース効率向上が見込まれます。Taprootに加えて、[tapscript][topic tapscript]によりビットコインのスクリプトの能力を改良します。主に、将来、新しいopcodeを追加することをより簡単にきれいにできるようにします。

この提案は残りの1年に渡り、多くの議論とレビューが実施されました。その中にはAnthony Townsによって開催されました、150人以上がレビューの手助けをするためにサインアップした[group review sessions][taproot review] などが含まれます。
</div>

<div markdown="1" id="anyprevout">
Townsは5月にtapscriptと組み合わせて利用できる2つの新しい署名ハッシュである、`SIGHASH_ANYPREVOUT`と`SIGHASH_ANYPREVOUTANYSCRIPT`を提案しました。

署名ハッシュ(sighash)は、署名がコミットするトランザクションのフィールドと関連するデータのハッシュです。ビットコインにおいて異なるsighashはトランザクションの異なる部分にコミットします。それにより、署名者にオプションとして、他のユーザがトランザクションに対して特定の修正を実施できるようにします。2つの新しく提案されたsighashは、UTXO[BIP118][]の[SIGHASH_NOINPUT][topic sighash_noinput]と同様に機能します。意図的に利用するUTXOを特定しないことにより、（例えば、同一のpubkeyを利用するなど）スクリプトが満たしさえすれば、署名によりいかなるUTXOでも送信することができます。

インプットがないスタイルのsighashの主要な提案された利用方法は、LN向けに以前提案された[eltoo][topic eltoo] update layerを可能にすることです。Eltooはチャネル構築と管理を複数の観点から簡素化します。特にオンチェーンのチャネルコストを大きく削減できるため[2つ以上の参加者が含まれるチャネル][topic channel factories]を簡素化することが望ましいとされています。
</div>

<div markdown="1" id="ctv">
当月に提案された3つ目のソフトフォークは、Jeremy Rubinからのもので、`OP_CHECKTEMPLATEVERIFY`(CTV)と呼ばれる新しい[opcode][coshv]です。これにより、例えば、本スクリプトを使用したトランザクションの後続トランザクションのoutputには他の特定のoutputが含まれている必要があるなど、限られた形式の契約(covenants)が可能になります。

 これの推奨される使用法は、後で数十、数百、または数千の異なる受信者に支払うトランザクション（またはトランザクションのツリー）を使用してのみ使用できる少量のoutputを将来支払うことにコミットすることです。

これにより、コインジョインスタイルのプライバシーを強化し、セキュリティ強化された保管庫をサポートし、取引手数料が急増した場合の支出コストを管理するための新しい手法が可能になります。

Rubinは、CTVの展開バージョンをより効果的に可能にするべくBitcoin Coreの一部の改善のためにPRを開くなど、CTVへの貢献を、本年の終わりまで実施しています。
</div>

<div markdown="1" class="callout" id="conferences">
### 2019 summary<br>Notable technical conferences and other events

- [Stanford Blockchain Conference][], January, Stanford University
- [MIT Bitcoin Expo][], March, MIT
- [Optech Executive Briefing][], May, New York City
- [Magical Crypto Friends (technical track)][mcf], May, New York City
- [Breaking Bitcoin][], June, Amsterdam
- [Bitcoin Core developers meetup][coredevtech amsterdam], June, Amsterdam
- [Edge Dev++][], September, Tel Aviv
- [Scaling Bitcoin][], September, Tel Aviv
- [Cryptoeconomic Systems Summit][], October, MIT
</div>

## June

<div markdown="1" id="erlay-and-other-p2p-improvements">
Gleb Naumenko、Pieter Wuille、Gregory Maxwell、Sasha Fedorova、Ivan
Beschastnikhは[erlay][topic erlay]の[論文][erlay]を発表しました。アナウンスのバンドワイズを試算上84%削減する [libminisketch-based][topic minisketch] set reconciliationを利用した、ノード間でコンファームしていないトランザクションアナウンスをリレーするプロトコルです。論文ではerlayによりノードがデフォルトで接続するアウトバウンド接続の数を大幅に増加することが実現可能になることも記載されています。これは、ほとんどのPoWのブロックチェーンにないブロックをエクセプトすることでノードを騙す[エクリプス攻撃][eclipse attacks]に対する各ノードの耐性を改善します。より多くのアウトバウンド接続が可能になることで、トラックしたり、ノードが起点とするペイメントを遅延させるなど他の攻撃に対するノードの耐性を改善します。Erlayに関するワークは、追加の研究やreconciliation protocolの[BIP330][] の提案など一年間に渡り続きました。

今年のP2Pリレーにおける他の改善は、ビットコイン・コアの[トランザクション・リレーのプライバシー改善][#14897]（Sergi Delgado-Seguraらによる[TxProbe][] 論文に記載されている問題を取り除く）と エクリプス攻撃に対する抵抗を改善する、新しいブロックのリレーにのみ使われる [2つの追加アウトバウンド接続][two extra outbound connections]の追加です。
</div>

<div markdown="1" id="watchtowers">
数多くの先行ワークを経て、6月にLNDにaltruist(利他的) [LN watchtowers][topic watchtowers] が[マージ][altruist watchtowers]されました。Altruist watchtowersでは、クライアントのチャネルを保護することの対価として、プロトコル経由でいかなる報酬も受け取りません。それゆえ、ユーザは自分自身のwatchtowerを建てるか、watchtower operatorの慈善に依存しますが、他のユーザの代わりにペナルティ・トランザクションをwatchtowerが確実に送信することのデモとしては十分だと思われます。これにより長期間オフラインになるユーザーが資金を失わないことを確実にします。

Altruist watchtowersは、最終的には [LND 0.7.0-beta][lnd 0.7-beta] でリリースされ、年内に追加の開発が実施されました。それらには、[watchtowerの仕様提案][watchtower spec] や [eltoo][topic eltoo]のような次世代のペイメント・チャネルとの組み合わせに関する[議論][eltoo watchtowers]が含まれます。

</div>

## July

<div markdown="1" id="reproducibility">
7月には、Carl DongのPRがビットコイン・コア・プロジェクトに[マージ][guix merge] されました。これは、GNU Guix （"geeks"と発音する）を利用してビットコイン・コアのLinuxバイナリーのビルド再現性のサポートを追加するものです。ビットコイン・コアは、これまで[Gitian][] システムを使った再現性のあるビルドをサポートしてきましたが、セットアップが難しく、数百ものUbuntu パッケージのセキュリティに依存しています。比べて、Guixはインストール、実行が容易で、Guixを用いてビットコイン・コアをビルドした場合、パッケージの依存関係がより少なくなります。長期的には、Guixのコントリビューターは、`bitcoind`のようなバイナリーが単独で監査可能なソースコードから得られたことをユーザーが検証できるようにするために[trusting trust][]問題を取り除けるように作業しています。

2020年にリリースされるビットコイン・コアの最初のメジャー・バージョンでGuixが使われることに期待を寄せており（おそらく古いGitianベースのメカニズムと並行して使用される）、1年を通じてGuixビルド・サポートの作業が続けられました。

また、[C-Lightning][cl repro]と[LND][lnd repro]のレポジトリーに信頼できるコンパイラーを使ってそれらのSWの再現性のあるビルドの作成方法に関するドキュメンテーションが追加されました。
</div>

## August

<div markdown="1" id="vaults">
8月には、Bryan Bishopが[covenantsを使わないビットコインにおけるVaults][vaults on
Bitcoin without using covenants]の実装手法を提案しました。*Vaults*は、仮に攻撃者がユーザの通常の秘密鍵を入手したとしても、攻撃者がファンドを盗む能力を制限するスクリプトを表すために使われる用語です。*[Covenant][topic covenants]*は他の特定のスクリプトに対してのみ送信できるスクリプトのことです。現在のビットコイン・スクリプト言語を利用してCovenantsを作成する既知の方法はありませんが、お金をvault contractにデポジットする際にユーザがいくつかのステップを実行するコードを走らすことができれば、Covenantsが必ずしも必要ではないことが分かりました。

特に、Bishopはvaultの弱点とその軽減方法についても記載しました。攻撃者によってvaultから盗むことの出来る最大資金を制限することができるというものです。実用的なvaultの開発は、個人のユーザ、取引所などの大規模なカストディアン事業者にとっても有用です。
</div>

<div markdown="1" class="callout" id="optech">
### 2019 summary<br>Bitcoin Optech

2年目のOptechは、6社の新規メンバーのサインアップ、NYCブロックチェーン・ウィークに[executive briefing][optech executive briefing]の開催、 [24週連続][bech32 sending support] のbech32送信のサポートのプロモーション、websiteにウォレット、サービスの[compatibility matrix][]の追加、51週分の[newsletters][]の発行<!-- #28 to
#78, inclusive -->、一部のニュースレター、ブログの[日本語][xlation ja]や[スペイン語][xlation es]などへの翻訳の開始、 [topics index][]の作成、[Scalability Workbook][]へのチャプターの作成、パブリックにリリースされた[jupyter notebooks][]を用いた2回の [schnorr/taproot workshops][] の開催、[BTSE][]と[BRD][]によるフィールドレポートの発行などを実施しました。

2020年も大きなプランがあり、皆様には継続して[Twitter][]をフォロー、 [weekly newsletter][]を購読し、または、[RSS feed][]を追っていただけることを期待いたします。
</div>

## September

<div markdown="1" id="snicker">
Adam Gibsonは既存ビットコイン・システム向けの非対話型・[コインジョイン][topic coinjoin]を[提案][snicker]しました。SNICKERと呼ばれるプロトコルは、ユーザが自身のUTXOの一つを選択し、グローバルなUTXOセットからランダムにUTXOを1つ選択し、同一のトランザクションで利用します。提案者がこのトランザクションの一部に署名し、パブリックサーバーに部分的署名ビットコイン・トランザクション([PSBT][topic psbt])のフォーマットでアップロードします。他のユーザーがサーバをチェックし、PSBTを確認したら、ダウンロードして署名し、ブロードキャストすることができます。これにより、両者が同時にオンラインである必要がなく、コインジョインを完成できます。提案者は、他のユーザがコインジョインをアクセプトするまで、同じUTXOを利用してPSBTsを作りたいだけ作成し、アップロードすることができます。

他のコインジョインのアプローチに対するSNICKERの主要な優位性は、両者が同時にオンラインである必要がないこと、ならびに、[BIP174][] PSBTサポート対応済みのウォレット（多くのウォレットが対応してきています）であれば簡単にサポート可能である点です。
</div>

{:#ln-cve}
9月にはまた、C-Lightning, Eclair, そして LNDのメンテナーは以前のバージョンのソフトウェアに影響を与える脆弱性を[公開][ln missed validation]しました。チャネルオープンの際のトランザクションが正しいスクリプト、金額であるチェックが実装されていなかったことが問題のようです。 悪用された場合、オンチェーン上でチャネル・ペイメントをコンファームすることが不可能になり、invalid channelからvalid channelへペイメントをリレーすることにより、ノードがお金を失う可能性があります。Optechは、最初の脆弱性に関するパブリック・アナウンスメントの前に、お金を失ったというユーザーを認識しておりません。LNの仕様は、将来の実装者が同じ失敗に直面することを避けるために[アップデート][news67 bolts676]され、LN通信プロトコルに対する[他の変更提案][dual-funding serialization]が、この種の他の失敗を避けることにつながることが期待されています。

## October

<div markdown="1" id="anchor-outputs">
LNディベロッパーにより、過度の遅延なくユーザがいつでもチャネルをクローズ可能にするという長年の課題への対応に関して、10月から11月に非常に重要な進捗がありました。
ユーザが複数のチャネルのうちの１つをクローズしたいが、リモート・ピアに連絡がつかない場合、ユーザはチャネルの最新の*コミットメント・トランザクション*をブロードキャストします。これは、オフチェーンのコントラクトの最新のバージョンでチャネルのファンドをそれぞれのオンチェーンで支払うpre-signed transactionです。この際にコミットメント・トランザクションが、数日から数週間前の安いトランザクション・フィーの頃に作成され、セキュリティー上重要なタイムロック期限の前までに取り込まれるのに十分な高いフィーが設定されていな可能性があります。

この問題の解決策としては、fee bump commitment trasctionを可能にすることが知られています。しかしながら、ビットコイン・コアのノードでは帯域やCPUを消費するDenial of Service (DoS) 攻撃を防ぐためにfee bumpingを制限しています。LNのようなトラストレスでマルチユーザーのプロトコルでは、カウンター・パーティが、あなたのLNコミットメント・トランザクションのコンファメーションを遅延させるために故意にアンチ・DoS・ポリシーを発動する攻撃者であるかもしれません（[transaction pinning][topic transaction pinning]と呼ばれる攻撃です）。このトランザクションは、タイムロックが解除されるまでにコンファームされないかもしれないため、攻撃者はカウンターパーティからファンドを盗むことが可能になります。

昨年、Matt Coralloは、Child-Pays-For-Parent (CPFP) fee bumpingに関連するビットコイン・コアのトランザクション・リレー・ポリシーの一部から、特例を除くことを[提案][carve-out proposed]しました。この特例は、2者のコントラクト・プロトコル（例えば、現在のLN）が、それぞれのパーティーに、彼ら自身のfee bumpを作成することを保証することが可能です。Coralloのアイデアは、[CPFP carve-out][topic cpfp carve out] という名称でBitcoin Core 0.19の一部としてリリースされました。その前のリリースでも、その他のLNディベロッパーがこの変更を利用開始するために必要なLNスクリプトやプロトコル・メッセージの[改定][anchor outputs]は実施されていました。当ニュースレター執筆段階では、これらの仕様変更はネットワークへのデプロイの前の最終実装・受け入れ待ちです。
</div>

<div markdown="1" class="callout" id="new-infrastructure">
### 2019 summary<br>新しいオープン・ソース・インフラストラクチャー・ソリューション

- [Proof of reserves tool][] は、2月にリリースされました。これにより取引所やその他のビットコイン・カストディアン業者が [BIP127][] reserve proofs を利用して特定のUTXOのセットに対してコントロールしていることを証明することができます。

- [Hardware Wallet Interface][topic hwi] は、3月にリリースされ、[PSBTs][topic psbt]と [output script descriptors][topic output script descriptors]に既に互換性のあるウォレットが、セキュア・キー・ストレージ及び署名にハードウェア・ウォレットの複数の異なるモデルを利用することを容易にします。

- <a href="/en/newsletters/2019/03/26/#loop-announced">Lightning Loop</a>は、3月にリリース（loop-inサポートは6月に追加）され、既存チャネルをクローズまたは、新しいチャネルをオープンすることなく、LNチャネルからファンドを追加・削除することを可能にします。

</div>

## November

<div markdown="1" id="bech32-mutability">
[Taproot][topic taproot] paymentsに bech32アドレスを利用するという11月の議論は、5月に発見された[bech32アドレスの問題][bech32 malleability issue] で注目を集めました。[BIP173][]によると、ミス・コピーされたbech32 文字列が検出されない失敗率は最悪でも10億回に1回程度とされてきました。しかしながら、`p`で終わるbech32 文字列は、その前に`q`を削除、挿入しても有効な文字列となります。これは実用的には、segwit P2WPKH、P2WSH addressesに影響を与えません。一つのアドレスタイプを別のものに変えるには少なくとも19連続で`q`が追加される、または削除される必要がありますが、v0 segwit addressの文字列の長さは固定長であり、変更されると無効となるためです。<!-- "19 characters" math in
_posts/en/newsletters/2019-11-13-newsletter.md -->

しかし、taprootで提案されているようなv1+ segwit addressでは可変長を前提としており、v0 segwit addressのように無効にはならず、脆弱性のあるアドレスへの一つの `q` の挿入、削除により、ファンドの損失につながります。BIP173の共著者であるPiter Wuilleは、[追加の調査][bech32 analysis]を実施し、この件のみがbech32の起こりうるエラー訂正機能からの逸脱であるとし、ビットコインにおいては20バイトまたは32バイトのウィットネス・プログラムでのみBIP173アドレスの利用ができるように制限することを提案しました。これによりv1、それ以降のsegwit addressのバージョンについてもv0 segwit addressと同等の信頼性のあるエラー訂正が提供可能です。また、次世代のビットコイン・アドレス・フォーマットにおいてもBCH誤り訂正の適用が可能になります。

</div>

{:#openssl}
また、11月にはビットコイン・コアは[Open SSLへの依存関係を削除][rm openssl]しました。これは、初期の2009リリースであるビットコイン 0.1からコードベースに存在したものです。OpenSSLは、[コンセンサスの脆弱性][non-strict der]、[リモート・メモリー・リーク][heartbleed]（潜在的な秘密鍵の漏洩）、[その他のバグ][cve-2014-3570]、並びに[低いパフォーマンス][libsecp256k1 sig speedup]の原因となっていました。今回の削除により将来の脆弱性の頻度が低下することが期待されます。

{:#bip70}
OpenSSLの廃止の一部として、ビットコイン・コアのバージョン 0.18の[BIP70][] ペイメント・プロトコルのサポートは廃止予定となり、後のバージョン 0.19でデフォルトでサポートが無効となりました。この決定は、2019年にBIP70を継続利用していたいくつかの企業のCEOによって[支持][ceo bitpay] されました。

## December

{:#multipath}
12月にLN ディベロッパーは前年の[プランニング・ミーティング][ln1.1]に立てた主要な目標の一つである基本的な [マルチパス・ペイメント][topic multipath payments]の[実装][mpp
implementation]を達成しました。ペイメントを複数パートに分割し、各パートが異なるチャネル経由で別々にルーティングします。これにより、一度に複数のチャネルを利用して資金の送受信が可能になり、ユーザのオフチェーンの残高合計分の送信や、フル・キャパシティー分の受信が一度のペイメントで（特定の安全上の制約の範囲内において）可能になります。 <!-- safety restrictions: non-wumbo and channel reserve funding --> また、送信者が特定のチャネルの残高を気にする必要がなくなるため、LNがよりユーザーフレンドリーになることが期待されます。

## Conclusion

上述のサマリーでは、革新的な提案や改善はなかったと言えるかもしれません。ビットコインやLNが既に稼働している裏側で、更に改善するため改修・構築がされていくという、多くの地道な、しかし重要な段階的改善の積み重ねでした。ディベロッパーの取り組みは、よりアクセスしやすいハードウェア・ウォレットの開発（HWI）、マルチシグやコントラクトのユースケース向けにウォレット間の通信の一般化（descriptors, PSBTs, miniscript）、コンセンサスのセキュリティの強化（cleanup soft fork）、テストの簡素化（signet）、不必要なカストディの排除（loop）、ノード立ち上げの簡易化（assumeutxo）、プライバシーの改善・ブロックスペースの削減（taproot）、LNのenforcement簡素化（anyprevout）、feerate高騰に対する運用改善（CTV）、バンドワイズ削減（erlay）、オフライン時におけるLNのユーザーの安全確保（watchtowers）、build時の信頼の必要性の削減（reproducible builds）、盗難防止（vaults）、プライバシーをよりアクセス可能にする技術（SNICKER）、LNユーザ向けのオンチェーンのフィー管理（anchor outputs）、LNペイメントがより自動でスムーズに働く技術（multipath payments）などで、これらは2019年のハイライトにすぎません。

ビットコイン・コントリビューターが2020年に成し遂げることは推測することしかできませんが、現状稼働しているものを壊すことなく、より良くしていく数多くの変更がされていくことでしょう。

*Optech Newsletterは1月8日より通常の水曜日配信版に戻ります。

{% include references.md %}
{% include linkers/issues.md issues="16800,16411,17268,17292" %}
[#14897]: /en/newsletters/2019/02/12/#bitcoin-core-14897
[2018 summary]: /en/newsletters/2018/12/28/
[altruist watchtowers]: /en/newsletters/2019/06/19/#lnd-3133
[anchor miniscript]: https://github.com/lightningnetwork/lightning-rfc/pull/688#pullrequestreview-326862133
[anchor outputs]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[bech32 analysis]: /ja/newsletters/2019/12/18
[bech32 malleability issue]: https://github.com/sipa/bech32/issues/51
[bech32 sending support]: /en/bech32-sending-support/
[bitcoin core 0.18]: /en/newsletters/2019/05/07/#bitcoin-core-0-18-0-released
[bitcoin core 0.19]: /ja/newsletters/2019/11/27
[brd]: /en/newsletters/2019/08/07/#bech32-sending-support
[breaking bitcoin]: /en/newsletters/2019/06/19/#breaking-bitcoin
[btcpayserver.vault]: https://github.com/btcpayserver/BTCPayServer.Vault
[btse]: /en/btse-exchange-operation/
[carve-out proposed]: /en/newsletters/2018/12/04/#cpfp-carve-out
[ceo bitpay]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[c-lightning 0.7]: /en/newsletters/2019/03/05/#upgrade-to-c-lightning-0-7
[c-lightning 0.8]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.0
[cl repro]: https://github.com/ElementsProject/lightning/blob/master/doc/REPRODUCIBLE.md
[cl signet]: /en/newsletters/2019/07/24/#c-lightning-2816
[coredevtech amsterdam]: /en/newsletters/2019/06/12/#bitcoin-core-contributor-meetings
[coshv]: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
[cryptoeconomic systems summit]: /en/newsletters/2019/10/16/#conference-summary-cryptoeconomic-systems-summit
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[dual-funding serialization]: https://twitter.com/rusty_twit/status/1179976386619928576
[dumptxoutset]: /ja/newsletters/2019/11/13/#bitcoin-core-16899
[eclair 0.3]: https://github.com/ACINQ/eclair/releases/tag/v0.3
[eclipse attacks]: https://eprint.iacr.org/2015/263.pdf
[edge dev++]: /en/newsletters/2019/09/18/#bitcoin-edge-dev
[eltoo watchtowers]: /ja/newsletters/2019/12/11
[exp tramp]: /ja/newsletters/2019/11/20/#eclair-1209
[gitian]: https://github.com/devrandom/gitian-builder
[guix merge]: /en/newsletters/2019/07/17/#bitcoin-core-15277
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[jupyter notebooks]: https://github.com/bitcoinops/taproot-workshop#readme
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
[lightning loop]: /en/newsletters/2019/03/26/#loop-announced
[ln1.1]: /en/newsletters/2018/11/20/#feature-news-lightning-network-protocol-11-goals
[lnd 0.6-beta]: /en/newsletters/2019/04/23/#lnd-0-6-beta-released
[lnd 0.7-beta]: /en/newsletters/2019/07/03/#lnd-0-7-0-beta-released
[lnd 0.8-beta]: /ja/newsletters/2019/10/16
[lnd repro]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[lnd scb]: /en/newsletters/2019/04/09/#lnd-2313
[ln missed validation]: /ja/newsletters/2019/10/02
[loop-in]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[mcf]: /en/newsletters/2019/05/21/#talks-of-technical-interest-at-magical-crypto-friends-conference
[mit bitcoin expo]: /en/newsletters/2019/03/19/#mit-bitcoin-club-2019-expo-videos-available
[mpp implementation]: /en/newsletters/2019/12/18/#ln-implementations-add-multipath-payment-support
[news33 reserves]: /en/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[news37 cleanup discussion]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[news37 merkle tree attacks]: /en/newsletters/2019/03/05/#merkle-tree-attacks
[news61 miniscript feedback]: /en/newsletters/2019/08/28/#miniscript-request-for-comments
[news67 bolts676]: /ja/newsletters/2019/10/09/#bolts-676
[newsletters]: /en/newsletters/
[non-strict der]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[optech executive briefing]: /en/2019-exec-briefing/
[proof of reserves tool]: /en/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[rm openssl]: /ja/newsletters/2019/11/27/#bitcoin-core-17265
[roose reserves]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016633.html
[scalability workbook]: https://github.com/bitcoinops/scaling-book
[scaling bitcoin]: /en/newsletters/2019/09/18/#scaling-bitcoin
[schnorr/taproot workshops]: /en/schorr-taproot-workshop/
[snicker]: /en/newsletters/2019/09/04/#snicker-proposed
[stanford blockchain conference]: /en/newsletters/2019/02/05/#notable-talks-from-the-stanford-blockchain-conference
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[taproot review]: /ja/newsletters/2019/10/23
[time warp attack]: /en/newsletters/2019/03/05/#the-time-warp-attack
[topics index]: /en/topics/
[trampoline proposed]: /en/newsletters/2019/04/02/#trampoline-payments-for-ln
[trampolines pr]: /en/newsletters/2019/08/07/#trampoline-payments
[trusting trust]: https://www.archive.ece.cmu.edu/~ganger/712.fall02/papers/p761-thompson.pdf
[twitter]: https://twitter.com/bitcoinoptech/
[two extra outbound connections]: /en/newsletters/2019/09/11/#bitcoin-core-15759
[txprobe]: /en/newsletters/2019/09/18/#txprobe-discovering-bitcoin-s-network-topology-using-orphan-transactions
[vaults on bitcoin without using covenants]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[wasabi hwi]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v1.1.4
[watchtower spec]: /ja/newsletters/2019/12/04/#proposed-watchtower-bolt
[weekly newsletter]: /en/newsletters/
[weekly newsletters]: /en/newsletters/
[worst case cpu usage]: /en/newsletters/2019/03/05/#legacy-transaction-verification
[wuille sbc miniscript]: /en/newsletters/2019/02/05/#miniscript
[xlation es]: https://bitcoinops.org/es/publications/
[xlation ja]: https://bitcoinops.org/ja/publications/
