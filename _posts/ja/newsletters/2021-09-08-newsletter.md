---
title: 'Bitcoin Optech Newsletter #165'
permalink: /ja/newsletters/2021/09/08/
name: 2021-09-08-newsletter-ja
slug: 2021-09-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin関連のMIMEタイプの提案と、
新しい分散型のマイニングプールの設計についての論文を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、
Taprootの準備、新しいリリースとリリース候補、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **Bitcoin関連のMIMEタイプ:** Peter Grayは、[PSBT][topic psbt]や、
  バイナリフォーマットのトランザクション、[BIP21][] URI用のMIMEタイプの[IANA][]への登録について、
  Bitcoin-Devメーリングリストに[投稿しました][gray mime]。
  Andrew Chowは、以前PSBTのMIMEタイプを登録しようとしたものの、
  その申請は却下されたことを[説明しました][chow mime]。
  彼は、MIMEタイプの登録には[IETF][]仕様（RFC）を作成する必要があり、
  定まった文書にするためには相当な作業が必要になると考えていました。
  Grayは、代わりに、Bitcoinアプリケーションで使用される非公式のMIMEタイプを定義するためのBIPの作成を[提案しました][gray bip]。

- **P2Poolの代替Braidpool:** [P2Pool][]は、2011年からから分散型のプールベースのBitcoinマイニングに使用されているシステムです。
  Bitcoin-Devメーリングリストに[投稿された][pool2win post]新しい[論文][braidpool paper]では、
  認識されているいくつかの欠陥と、2つの注目すべき改善点を持つ分散型プールの代替設計について説明しています。
  第三者へのトラストを最小限に抑えたペイメントチャネルの使用により支払い用のブロックスペースをより効率的に使用し、
  プールメンバー間のより高いレイテンシー接続に対する許容度を高めます。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Use legacy relaying to download blocks in blocks-only mode][review club #22340]は、
Niklas GöggeによるPRで、`-blocksonly`設定オプションを設定しているノードが、
ブロックのダウンロードに常にレガシーなブロックリレーを使用するようにするものです。
Review Clubでは、レガシーなブロックダウンロードと[BIP152][]スタイルの[Compact Block][topic compact block relay]ダウンロードを比較し、
blocksonlyノードが後者の恩恵を受けれない理由を議論しました。

{% include functions/details-list.md

  q0="<!--what-sequence-of-messages-is-used-in-legacy-block-relaying-->
レガシーなブロックリレーではどんなメッセージシーケンスが使用されていますか？"
  a0="v0.10以降のノードでは、[ヘッダーを最初に同期します][headers first pr]:
ノードはまずピアからブロックヘッダーを含む`headers`メッセージを受信します。
ヘッダーを検証した後、メッセージを通知したピアに`getdata(MSG_BLOCK, blockhash)`メッセージを送信して完全なブロックを要求し、
ピアは完全なブロックを含む`block`メッセージで応答します。"
  a0link="https://bitcoincore.reviews/22340#l-49"

  q1="<!--what-sequence-of-messages-is-used-in-bip152-low-bandwidth-compact-block-relaying-->
BIP152の低帯域幅のCompact Blockリレーで使用されるメッセージシーケンスはどんなものですか？"
  a1="ピアは、接続の開始時に`sendcmpct`メッセージを送信することで、Compact Blockリレーを使用したいことを通知します。
低帯域幅のCompact Blockリレーは、レガシーなブロックリレーと非常によく似ています:
ノードはブロックヘッダーを処理した後、`getdata(MSG_CMPCT_BLOCK, blockhash)`メッセージを使ってピアにCompact Blockを要求し、
その応答で`cmpctblock`を受信します。ノードはCompact Blockのshortidを使って、
mempool内と追加のトランザクションキャッシュからブロック内のトランザクションを探すことができます。
それでも未知のトランザクションがある場合は、`getblocktxn`を使ってそれをピアに要求し、
応答で`blocktxn`メッセージを受信します。"
  a1link="https://bitcoincore.reviews/22340#l-56"

  q2="<!--what-sequence-of-messages-is-used-in-bip152-high-bandwidth-compact-block-relaying-->
BIP152の高帯域幅のCompact Blockリレーで使用されるメッセージシーケンスはどんなものですか？"
  a2="ノードは、接続の開始時に`hb_mode`に1を設定した`sendcmpct`メッセージを送信することで、
最初に接続を確立する際にピアに高帯域幅のCompact Blockを要求することができます。
これは、ピアが最初にヘッダーを送信したり、ブロックの`getdata`要求を待つことなく、
直ちに`cmpctblock`を送信できることを意味します。必要に応じて、
ノードは`getblocktxn`および`blocktxn`を使用して、低帯域幅のCompact Blockリレーと同じように、
ブロックの未知のトランザクションを要求、ダウンロードすることができます。"
  a2link="https://bitcoincore.reviews/22340#l-59"

  q3="<!--why-does-compact-block-relay-waste-bandwidth-for-blocksonly-nodes-during-block-download-how-much-bandwidth-is-wasted-->
ブロックのダウンロード中に、blocksonlyのノードが帯域幅を無駄にする理由は何ですか？どのくらいの帯域幅が無駄になりますか？"
  a3="Compact Blockリレーは、ブロック内のトランザクションの大半を再ダウンロードする必要がないため、
mempoolを持つノードの帯域幅使用量を削減します。しかし、blocksonlyモードのノードは、
トランザクションのリレーに参加せず、通常そのmempoolは空です。
つまり、いずれにせよすべてのトランザクションをダウンロードする必要があります。
shortidや`getblocktxn`、`blocktxn`のオーバーヘッドを[加味すると1ブロックあたり約38kB][aj calculations]の無駄な帯域幅が発生し、
`getblocktxn`メッセージと`blocktxn`メッセージの余計な往復により、ブロックのダウンロードにかかる時間も増加します。"
  a3link="https://bitcoincore.reviews/22340#l-82"

  q4="<!--does-a-node-in-blocksonly-mode-keep-a-mempool-->blocksonlyモードのノードはmempoolを保持しますか？"
  a4="blocksonlyノードは、トランザクションリレーには参加していませんが、mempoolは持っており、
それにはいくつかの異なる理由でトランザクションが含まれている場合があります。
例えば、ノードが通常モードであった後にblocksonlyモードで再起動した場合、mempoolは再起動の間も保持されます。
また、ウォレットやクライアントインターフェースを介して送信されたトランザクションは、
mempoolを使用して検証、中継されます。"
  a4link="https://bitcoincore.reviews/22340#l-97"

  q5="<!--what-is-the-difference-between-blocksonly-and-block-relay-only-should-these-changes-be-applied-for-block-relay-only-connections-as-well-->
blocksonlyとblock-relay-onlyの違いは何ですか？今回の変更はblock-relay-onlyの接続にも適用すべきものですか？"
  a5="blocksonlyモードはノードの設定で、block-relay-onlはピア接続の属性です。
ノードはblocksonlyモードで起動すると、すべてのピアとのversionハンドシェイクで`fRelay=false`を送信し、
トランザクション関連のメッセージを送信するピアを切断します。
blocksonlyモードかどうかに関わらず、ノードはblock-relay-only接続を持つことがあり、
その場合、トランザクションの受信やaddrメッセージを無視します。
このように、block-relay-only接続の存在は、ノードのmempoolのコンテンツや、
Compact Blockメッセージからブロックを再構築する機能とは関係がないため、
これらの変更をblock-relay-only接続に適用すべきではありません。"
  a5link="https://bitcoincore.reviews/22340#l-111"
%}

## Taprootの準備 #12: VaultとTaproot

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/11-vaults-with-taproot.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0]は、
  このフルノード実装とそれに付随するウォレットおよび他のソフトウェアの次のメジャーバージョンのリリース候補です。
  この新バージョンの主な変更点は、[I2P][topic anonymity networks]接続のサポート、
  [Tor v2][topic anonymity networks]接続の廃止、ハードウェアウォレットのサポートの強化などです。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2]は、Bitcoin Coreのメンテナンス版のリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22009][]では、[コイン選択時に][topic coin selection]
  分枝限定法（BnB）アルゴリズムとナップサックアルゴリズムの両方を常に実行し、
  結果の費用対効果を比較する新しい*waste score*ヒューリスティックを使用し最良の結果を選択するようウォレットを更新しました。
  これまでは、変化のないBnBの結果が見つかった場合、常にそれを優先していました。

  waste scoreヒューリスティックは、すべてのインプットは最終的に10 sat/vBの手数料率で使用されなければならず、
  お釣り用のアウトプットは回避可能であると仮定しています。
  インプットは、現在の手数料率とベースラインの手数料率でのコストの差としてスコア化され、
  手数料率が低いときにインプットを使用するとwaste scoreが減り、手数料率が高いときに使用するとwaste scoreが増えます。
  お釣り用のアウトプットは、それを作成するためのコストと将来それを使用するためのコストから、
  常にwaste scoreを増加させます。

  さまざまな手数料率で使用するウォレットにおいては、このアプローチにより一部のインプットの消費がより低い手数料率にシフトされ、
  ウォレット全体の運用コストが削減されます。統合と節約のコイン選択動作を分離するベースライン手数料率は、
  新しいオプション`-consolidatefeerate`で設定できます。
  その後のPR [Bitcoin Core #17526][]では、Single Random Drawに基づく、第3のコイン選択アルゴリズムの追加が提案されています。

- [Eclair #1907][]は、[エクリプス攻撃][topic eclipse attacks]を防ぐためにブロックチェーン
  watchdogを使用する方法（[ニュースレター #123][news123 eclair watchdogs]参照）を更新しました。
  Torが利用可能な場合、Eclairは（可能な場合、ネイティブなオニオンエンドポイントを使用して）
  watchdogへのコンタクトにTorを使用するようになりました。
  これにより、上流の攻撃者がwatchdogプロバイダーだけを選択的に検閲することがより困難になるでしょう。

- [Eclair #1910][]は、Bitcoin CoreのZMQメッセージインターフェースの使用方法を更新し、
  新しいブロックの情報を得る際の信頼性を向上させました。ブロックの発見にZMQを使用している人は、
  この変更を調査することをお勧めします。

- [BIPs #1143][]は、[output script descriptor][topic descriptors]を定義したBIP 380-386を導入しました。
  output script descriptorは、ウォレットやその他のプログラムが特定のScriptや関連するScriptのセットに対して作成された支払いや、
  使用された支払いを追跡できるようにするために必要なすべての情報を含む単純な言語です。
  [BIP380][]は、その理念や一般的な構造、共有式、チェックサムについて定義しています。
  残りのBIPは、各descriptorの機能そのものを定義しており、非segwit ([BIP381][])、
  segwit ([BIP382][])、multisig ([BIP383][])、アウトプットの組み合わせ([BIP384][])、
  RAW Scriptとアドレス([BIP385][])、ツリー([BIP386][]) のdescriptorに分類されます。

- [BOLTs #847][]では、2つのチャネルピアが協調クローズするトランザクションで支払う手数料を調整できるようになりました。
  これまでは、1つの手数料のみが送信され、相手はその手数料をそのまま受け入れるか拒否するというものでした。

- [BOLTs #880][]では、`openchannel`メッセージと`acceptchannel`メッセージに`channel_type`フィールドを追加し、
  送信ノードがノードの配信したfeature bitとは異なるチャネル機能を明示的に要求できるようにしました。
  この後方互換性のある変更は、[Eclair #1867][]や[LND #5669][]で既に実装されており、
  [C-Lightning #4616][]の一部としてマージが待たれています。

- [BOLTs #824][]では、[anchor output][topic anchor outputs]チャネルのステートコミットメントプロトコルに若干の変更を加えています。
  以前のプロトコルでは、事前署名された[HTLC][topic htlc]の使用では手数料を含むことができましたが、
  これは[ニュースレター #115][news115 anchor fees]で説明されている手数料を盗む攻撃ベクトルを生むことになりました。
  この代替プロトコルでは、すべての事前署名HTLCの使用は、手数料ゼロのため、手数料を盗むことはできません。

## 脚注

{% include references.md %}
{% include linkers/issues.md issues="22009,1907,1910,1143,847,880,824,1867,5669,4616,22340,17526" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[news115 anchor fees]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news123 eclair watchdogs]: /en/newsletters/2020/11/11/#eclair-1545
[p2pool]: https://bitcointalk.org/index.php?topic=18313.0
[gray mime]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019385.html
[iana]: https://en.wikipedia.org/wiki/Internet_Assigned_Numbers_Authority
[chow mime]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019386.html
[ietf]: https://en.wikipedia.org/wiki/Internet_Engineering_Task_Force
[gray bip]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019390.html
[braidpool paper]: https://github.com/pool2win/braidpool/raw/main/proposal/proposal.pdf
[pool2win post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019371.html
[aj calculations]: https://github.com/bitcoin/bitcoin/pull/22340#issuecomment-872723147
[headers first pr]: https://github.com/bitcoin/bitcoin/pull/4468
[series preparing for taproot]: /ja/preparing-for-taproot/
