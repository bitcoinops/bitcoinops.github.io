---
title: 'Bitcoin Optech Newsletter #399'
permalink: /ja/newsletters/2026/04/03/
name: 2026-04-03-newsletter-ja
slug: 2026-04-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ウォレットのフィンガープリンティングがPayjoinのプライバシーを損なう仕組みと、
ウォレットバックアップメタデータ形式に関する提案を掲載しています。また、
Bitcoinのコンセンサスルールの変更に関する提案のまとめや、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき変更など、恒例のセクションも掲載しています。

## ニュース

- **Payjoinプライバシーにおけるウォレットのフィンガープリンティングリスク**: Armin Sabouriは、
  Payjoin実装間の差異が[Payjoin][topic payjoin]トランザクションのフィンガープリンティングを可能にし、
  Payjoinのプライバシーを損なう仕組みについてDelving Bitcoinに[投稿しました][topic payjoin fingerprinting]。

  Sabouriは、Payjoinトランザクションは標準的な単一当事者のトランザクションと区別がつかないように見えるべきだと述べています。
  しかし共同トランザクションの痕跡が残る場合があります。

  - トランザクション内

    - 単一のトランザクション内でインプットとアウトプットを所有者毎に分割する。

    - インプットのエンコーディングの違い。

    - インプットのbyte長。

  - トランザクション間

    - 後方: 各インプットは、それ自身のフィンガープリントを持つ以前のトランザクションによって作成されている。

    - 前方: 各アウトプットは、将来のトランザクションで使用される可能性があり、フィンガープリントが露出する。

  続いてSabouriは、Samourai、PDKデモ、Cake Wallet（Bull Bitcoin Mobileへの送金）の３つのPayjoin実装をレビューし、
  それぞれにフィンガープリンティングを可能にする相違点を発見しています。具体的には以下のものが含まれます（ただしこれらに限りません）:

  - インプットの署名エンコードの違い。

  - SIGHASH_ALL byteが一方には含まれるが、もう一方には含まれない。

  - アウトプット金額の割り当て

  Sabouriは、これらのウォレットフィンガープリントの一部は取り除くことが容易である一方、
  特定のウォレットの設計上の選択に起因するものもあると結論づけています。
  ウォレット開発者は、Payjoinを実装する際にこうしたプライバシーの漏洩の可能性を認識しておくべきだとしています。

- **ウォレットバックアップメタデータ形式に関するBIPドラフト**: Pythcoinerは、
  ウォレットバックアップメタデータの共通構造に関する新しい提案をBitcoin-Devメーリングリストに[投稿しました][wallet bip ml]。
  [BIPs #2130][]で公開されているこのBIPドラフトは、アカウントディスクリプターや鍵、[ラベル][topic wallet labels]、
  [PSBT][topic psbt]などさまざまな種類のメタデータを標準的な方法で保存する仕様を策定し、
  異なるウォレット実装間の互換性確保や、ウォレットの移行・復元プロセスの簡素化を目的としています。
  Pythcoinerによると、エコシステムには共通仕様が存在しておらず、本提案はそのギャップを埋めることを目指しています。

  技術的な観点では、提案されている形式は、バックアップ構造を表す単一の有効なJSONオブジェクトを含む
  UTF-8エンコードされたテキストファイルです。BIPにはJSONオブジェクトに含めることができる各フィールドが列挙されており、
  それらはすべてオプションであることが明記されています。また、
  各ウォレット実装は有用でないと判断したメタデータを自由に無視できるものとされています。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **コンパクトな同種写像PQCはHDウォレット、鍵の調整、サイレントペイメントを置き換え可能**:
  Conduitionは、[ポスト量子][topic quantum resistance]暗号システムとして
  同種写像ベース暗号（IBC）のBitcoinへの適用可能性に関する研究をDelving Bitcoinに[投稿しました][c delving ibc hd]。
  楕円曲線の離散対数問題（ECDLP）は、ポスト量子の世界では安全でなくなる可能性がある一方、
  楕円曲線の数学そのものに根本的な欠陥があるわけではありません。簡単に言うと、
  同種写像とはある楕円曲線から別の楕円曲線へのマッピングです。IBCの暗号学的仮定は、
  特定の種類の楕円曲線間の同種写像を計算することは困難である一方、
  基底曲線から同種写像とそのマッピング先の曲線を生成することは容易であるという点にあります。
  したがって、IBCにおける秘密鍵は同種写像であり、公開鍵はマッピング後の曲線となります。

  ECDLPの秘密鍵と公開鍵のように、同じソルト（例：[BIP32の導出][topic bip32]ステップ）から新たな秘密鍵と公開鍵を独立して計算し、
  導出された秘密鍵が導出された公開鍵に対して正しく署名することが可能です。Conduitionはこれを
  「再ランダム化（rerandomization）」と呼んでおり、これによって[BIP32][]、[BIP341][]および[BIP352][]が
  （おそらく追加の暗号技術的な工夫を伴いつつも）根本的に実現可能になるとしています。

  現時点では、IBC向けの[MuSig][topic musig]や[FROST][topic threshold signature]のような署名集約プロトコルは存在しておらず、
  conduitionは、Bitcoin開発者と暗号学者に対し、その可能性を研究するよう呼びかけています。

  既知のIBC暗号システムにおける鍵と署名のサイズは、ECDLPに依存する暗号システムの鍵の約2倍ですが、
  ハッシュベースや格子ベースの暗号システムよりははるかに小さいものです。検証コストは、
  デスクトップマシンでも高く（1回の検証あたり1ミリ秒程度）、ハッシュベースや格子ベースと同程度の水準です。

- **VaropsバジェットとTapscriptリーフ 0xc2（Script Restoration）がBIP 440および441に**:
  Rusty Russellは、Great Script Restoration（またはGrand Script Renaissance）の最初の２つのBIPが、
  BIP番号の割り当てのために提出されたことをBitcoin-Devメーリングリストに[投稿しました][rr ml gsr bips]。
  これらはそれぞれBIP 440およびBIP 441として番号が付与されました。[BIP440][news374 varops]は、
  各操作コストの会計システムを構築することで、以前無効化されたScriptのopcodeを復元します。
  この会計システムは、ワーストケースのブロックレベルのスクリプト検証コストが、
  ワーストケースの署名操作数のブロックの検証コストを超えないようにします。[BIP441][news374 c2]は、
  2010年にサトシによって無効化されたopcodeを復元する新しい[Tapscript][topic tapscript]バージョンの検証について説明しています。

- **SHRIMPS: 複数のステートフル署名デバイス間で2.5KBのポスト量子署名**:
  Jonas Nickは、ポスト量子Bitcoinに向けた新しい準ステートフルなハッシュベース署名について
  Delving Bitcoinに[投稿しました][jn delving shrimps]。SHRIMPSは、
  [SPHINCS+][news383 sphincs]の署名サイズが、特定のセキュリティレベルを維持しつつ生成可能な署名の最大数に応じてスケールする
  という特性を活用しています。

  [SHRINCS][news391 shrincs]の設計と同様に、SHRIMPSの鍵は2つの鍵をハッシュして組み合わせたものです。
  この場合、両方の鍵はステートレスなSPHINCS+の鍵ですが、パラメーターセットが異なります。
  1つめの鍵は少数の署名に対してのみ安全で、その鍵を使用する各署名デバイスにおける最初（または最初の数回）の署名に使用することを意図しています。
  2つめの鍵はより多数の署名（Bitcoinの文脈では事実上無制限）に対して安全で、
  各デバイスはそのデバイスからの署名が一定回数（ユーザーが選択可能な場合もあり）を超えたら、この鍵にフォールバックします。
  その結果、単一のシードから多数導出できる任意の鍵が少数回しか署名しないというBitcoinの一般的なユースケースにおいては、
  ほぼすべての署名を2.5KB未満に抑えることができます。一方で、鍵が何度も再利用された場合でも、署名総数に実質的な上限はなく、
  その代わりに後続の署名は約7.5KBになります。SHRIMPSが準ステートフルと呼ばれるのは、グローバルな状態を保持する必要はないものの、
  各署名デバイスが署名に使用するSHRIMPS鍵毎に数bitの状態を記録しなければならないからです（各デバイスと鍵ペアにおける最初の署名のみが
  小さい署名サイズの恩恵を受ける場合は、1 bitで済みます）。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 31.0rc2][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc31 testing]が利用可能です。

- [Core Lightning 26.04rc2][]は、この人気のLNノードの次期メジャーバージョンの最新のリリース候補で、
  以前のリリース候補からスプライシングの更新とバグ修正が続いています。

- [BTCPay Server 2.3.7][]は、このセルフホスト型のペイメントソリューションのマイナーリリースで、
  プロジェクトを.NET 10に移行し、サブスクリプションとインボイスのチェックアウト機能を改善し、
  その他いくつかの機能強化とバグ修正を行っています。プラグイン開発者は、
  アップデート時にプロジェクトの[.NET 10移行ガイド][btcpay net10]に従ってください。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32297][]は、`bitcoin-cli`に`-ipcconnect`オプションを追加します。
  これにより、Bitcoin Coreが`ENABLE_IPC`でビルドされ、ノードが`-ipcbind`（
  ニュースレター[#320][news320 ipc]および[#369][news369 ipc]参照）で起動されている場合、
  HTTPの代わりにUnixソケット経由のプロセス間通信（IPC）を使って`bitcoin-node`インスタンスに接続し、制御できるようになります。
  `-ipcconnect`を省略した場合でも、`bitcoin-cli`はまずIPCを試み、IPCが利用できない場合はHTTPにフォールバックします。
  これは、[マルチプロセス分離プロジェクト][multiprocess]の一部です。

- [Bitcoin Core #34379][]は、ウォレットに秘密鍵の一部しか持たない[ディスクリプター][topic descriptors]が含まれている場合に、
  `gethdkeys` RPC（[ニュースレター #297][news297 rpc]参照）を`private=true`で呼び出すと失敗するバグを修正します。
  `listdescriptors`の修正（[ニュースレター #389][news389 descriptor]参照）と同様に、
  このPRは利用可能な秘密鍵を返します。なお、完全な監視専用ウォレットに対して、`gethdkeys private=true`を呼び出した場合は、
  引き続き失敗します。

- [Eclair #3269][]は、アイドル状態のチャネルから自動的な流動性回収機能を追加します。
  `PeerScorer`が両方向の合計支払い量がチャネルキャパシティの5%を下回ったことを検知すると、
  [中継手数料][topic inbound forwarding fees]を設定済みの最小値に向けて段階的に引き下げます。
  手数料が最低5日間最小値になったままでも取引量が回復しない場合、Eclairは当該ピアとの冗長なチャネルを閉鎖します。
  チャネルが閉鎖されるのは、ノードが資金の少なくとも25%を保有し、かつローカル残高が既存の
  `localBalanceClosingThreshold`設定を超えている場合に限られます。

- [LDK #4486][]は、`rbf_channel`エンドポイントを`splice_channel`にマージし、
  新規の[スプライス][topic splicing]とインフライトスプライスの手数料引き上げの両方に対応する単一のエントリーポイントとして提供します。
  スプライスが既に進行中の場合、`splice_channel`から返される`FundingTemplate`には`PriorContribution`が含まれるため、
  ユーザーは新しい[コイン選択][topic coin selection]をすることなくスプライスを[RBF][topic rbf]できます。
  スプライスのRBFの動作については、[ニュースレター #397][news397 rbf]をご覧ください。

- [LDK #4428][]は、新しい`create_channel_to_trusted_peer_0reserve`メソッドにより、
  信頼済みのピアとのゼロチャネルリザーブでのチャネル開設・受け入れのサポートを追加します。
  ゼロリザーブチャネルは、相手方がチャネル内のオンチェーン残高を全額使用することが可能です。
  これは、[アンカーアウトプット][topic anchor outputs]を使用するチャネルとゼロ手数料コミットメントチャネル（
  [ニュースレター #371][news371 0fc]参照）の両方で有効です。

- [LND #9982][]、[#10650][lnd #10650]、[#10693][lnd #10693]は、
  [Taproot][topic taproot]チャネルにおける[MuSig2][topic musig]ナンスのワイヤーハンドリングを強化します。
  `ChannelReestablish`に`LocalNonces`フィールドが追加され、
  ピアが[スプライス][topic splicing]関連の更新に複数のナンスを調整できるようになります。
  `lnwire`はナンスを含むメッセージのTLVデコード時にMuSig2公開ナンスを検証し、
  `LocalNoncesData`のデコードでは各ナンスエントリーが検証されます。

- [LND #10063][]は、[RBF][topic rbf]協調閉鎖フローを[MuSig2][topic musig]を使用した
  [Simple Taproot Channel][topic simple taproot channels]に拡張します。
  ワイヤーメッセージは[Taproot][topic taproot]固有のナンスと部分署名フィールドを持ち、
  閉鎖の状態マシンは`shutdown`、`closing_complete`、`closing_sig`の各段階で、
  ジャストインタイムのナンスパターンを持つMuSig2セッションを使用します（RBF協調閉鎖フローの背景については、
  [ニュースレター #347][news347 rbf coop]をご覧ください）。

{% include snippets/recap-ad.md when="2026-04-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2130,32297,34379,3269,4486,4428,9982,10650,10693,10063" %}

[topic payjoin]: /en/topics/payjoin/
[topic payjoin fingerprinting]: https://delvingbitcoin.org/t/how-wallet-fingerprints-damage-payjoin-privacy/2354
[c delving ibc hd]: https://delvingbitcoin.org/t/compact-isogeny-pqc-can-replace-hd-wallets-key-tweaking-silent-payments/2324
[rr ml gsr bips]: https://groups.google.com/g/bitcoindev/c/T8k47suwuOM
[news374 varops]: /ja/newsletters/2025/10/03/#first-bip
[news374 c2]: /ja/newsletters/2025/10/03/#second-2-bip
[jn delving shrimps]: https://delvingbitcoin.org/t/shrimps-2-5-kb-post-quantum-signatures-across-multiple-stateful-devices/2355
[news383 sphincs]: /ja/newsletters/2025/12/05/#slh-dsa-sphincs
[news391 shrincs]: /ja/newsletters/2026/02/06/#shrincs-324-byte
[wallet bip ml]: https://groups.google.com/g/bitcoindev/c/ylPeOnEIhO8
[news297 rpc]: /ja/newsletters/2024/04/10/#bitcoin-core-29130
[news320 ipc]: /ja/newsletters/2024/09/13/#bitcoin-core-30509
[news347 rbf coop]: /ja/newsletters/2025/03/28/#lnd-8453
[news369 ipc]: /ja/newsletters/2025/08/29/#bitcoin-core-31802
[news371 0fc]: /ja/newsletters/2025/09/12/#ldk-4053
[news389 descriptor]: /ja/newsletters/2026/01/23/#bitcoin-core-32471
[news397 rbf]: /ja/newsletters/2026/03/20/#ldk-4427
[multiprocess]: https://github.com/bitcoin/bitcoin/issues/28722
[bitcoin core 31.0rc2]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc2/
[Core Lightning 26.04rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc2
[BTCPay Server 2.3.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.7
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[btcpay net10]: https://blog.btcpayserver.org/migrating-to-net10/
