---
title: 'Bitcoin Optech Newsletter #136'
permalink: /ja/newsletters/2021/02/17/
name: 2021-02-17-newsletter-ja
slug: 2021-02-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、トランザクション署名の生成と検証のための新しい定数時間アルゴリズムの開発についての説明、
未承諾トランザクションの処理を止める提案についての言及、マルチシグウォレットをセットアップする方法について提案されたBIPの要約、
LN上でのエスクローに関する議論から得られた洞察の共有、双方向のアップフロント手数料に関する新たな議論へのリンクと、
悪意あるハードウェアウォレットのリスクを軽減するための新しいプロトコルについての言及をお送りします。
また、更新されたクライアントやサービスについてのニュースや、新しいソフトウェアリリースおよびリリース候補の通知、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更点の説明を含む通常のセクションを掲載しています。

## ニュース

- **<!--faster-signature-operations-->より高速な署名演算:** Russell O'ConnorとAndrew Poelstraは、
  Bitcoin Coreの署名検証を15%高速化できるアルゴリズムの実装を発表する[ブログ記事][safegcd bounds]を公開しました。
  これはまた、サイドチャネル攻撃によるデータ漏洩リスクを軽減する定数時間アルゴリズムを使用したままでも、署名生成にかかる時間を25%短縮できます。
  これは、デバイスのリソースが限定されているハードウェアウォレットの開発者にとって特に興味深いことかもしれません。

  ブログ記事では、Daniel J. BernsteinとBo-Yin Yangによる新しいアルゴリズムの開発、
  Peter Dettmanによるlibsecp256k1の実装（[ニュースレター #111][news111 secp767]で言及）、
  アルゴリズムが定数時間で目標を達成するために必要な最大ステップ数を計算するためのPieter Wuilleによる斬新でCPU効率の高い方法、
  Gregory MaxwellによるBernsteinとYangのアルゴリズムのより効率的なバリエーション、
  O'ConnorとPoelstraによる、Wuilleの境界検査プログラムの正しさを保証するためのCoq Proof Assistantへの実装について説明しています。
  libsecp256k1のDettmanのオリジナルの実装は、[PR #831][libsecp256k1 #831]としてWuilleによる最近の開発で更新されました。

- **<!--proposal-to-stop-processing-unsolicited-transactions-->未承諾トランザクションの処理を止める提案:** 通常、
  ノードは新しいトランザクションの通知をP2Pプロトコルの`inv`メッセージで受け取ることを期待しています。
  ノードがそのトランザクションに興味がある場合（以前に他のピアからそのトランザクションを受信したことがない場合など）、
  ノードは`getdata`メッセージを使ってそのトランザクションを要求し、
  ブロードキャスターは`tx`メッセージでそのトランザクションを返信します。
  しかし、ほぼ10年間、一部の軽量クライアントや他のソフトウェアは、`inv`や`getdata`の手順をスキップし、
  未承諾で`tx`メッセージを送信するようになっています（[例][bitcoinj unsolicited]）。

  今週、Antoine RiardがBitcoin-Devメーリングリストにそのような未承諾の`tx`メッセージの処理を止める提案を[投稿しました][riard post]。
  [Bitcoin CoreのPR][Bitcoin Core #20277]で議論されているように、
  これによりノードはトランザクションを受信して処理するタイミングをより細かく制御できるようになり、
  検証にコストのかかるトランザクションを送信するピアの影響を制限する追加の方法が提供されます。
  Riardは、この変更を早ければBitcoin Coreの次のメジャーバージョンであるバージョン22.0で行う提案をしています。

  このアプローチの欠点は、現在未承諾の`tx`メッセージを送信しているすべてのクライアントは、
  Bitcoin Coreの0.21.xもしくはそれ以前のバージョン（または同様の動作を他のBitcoin実装）が
  ネットワークからいなくなる前にアップグレードしないとトランザクションを送信することができなくなることです。
  古いバージョンが完全にネットワークからいなくなるには通常数年かかるため、
  クライアントのアップグレードを完了するには十分な時間が必要です。影響を受けるクライアントの開発者は、
  提案を読んでコメントを検討することをお勧めします。

- **<!--securely-setting-up-multisig-wallets-->マルチシグウォレットを安全にセットアップする:** Hugo Nguyenは、
  ウォレット、特にハードウェアウォレットがマルチシグの署名者になるために必要な情報を安全に交換する方法を記述したBIPドラフトを
  Bitcoin-Devメーリングリストに[投稿しました][nguyen post]。
  交換する必要のある情報には、使用するScriptテンプレート（署名に2-of-3の鍵が必要なP2WSHなど）や、
  署名に使用する予定のキーパスにおける各署名者の[BIP32][]拡張公開鍵（xpub）が含まれています。

  簡単に説明すると、（複数のハードウェアウォレットメーカーに対応して開発された）Nguyenの提案では、
  コーディネーターがScriptテンプレートを選択し、プライベートな暗号と認証クレデンシャルを生成することで、
  マルチシグフェデレーションプロセスを開始します。これらのパラメーターはメンバーのウォレットと共有され、
  メンバーウォレットは適切なキーパスを選択し、対応する秘密鍵で生成された署名と一緒にxpubを返します。
  {identifying_parameters, key_path, xpub, signature}のセットは、各ウォレットによって暗号化され、
  コーディネーターに返されます。続いて、コーディネーターは、それらを[output script descriptor][topic descriptors]に結合し、
  暗号化し各メンバーウォレットに返します。各メンバーウォレットは、自身のxpubが含まれていることを確認し、
  署名するScriptテンプレートとしてdescriptorを保存します。

  この提案はメーリングリストでかなりの議論を受け、いくつかの変更が計画されています。
  提案が成熟し、実装に近づくにつれて重要な更新があるかどうか、議論を監視していきます。

- **<!--escrow-over-->LN上のエスクロー:** １年以上前にLightning-Devメーリングリストで議論が[始まった][zmn escrow1]
  LNでのノンカストディ型のオンチェーンエスクローの作成について、ここ１週間で[新たな議論][aragoneses escrow]がみられました。
  議論の中で特に際立っていたのは、Booleanステートメントに対して[ド・モルガンの法則][de morgan's laws]の１つの使って,
  エスクロー、また支払いを受け取る前に売り手が債権を発行する必要があるトレードオフを持つ[おそらく][kohen escrow]
  多くのLNベースのコントラクトの構築を大幅に簡素化するZmnSCPxjによる[投稿][zmn escrow2]でした。
  ZmnSCPxjのアイディアでは、[PTLC][topic ptlc]を使用する必要があり、これは現在
  [Taproot][topic taproot]がアクティベートされるまで実現しそうにありません。

- **<!--renewed-discussion-about-bidirectional-upfront-ln-fees-->双方向のアップフロントLN手数料に関する新たな議論:**  Joost Jagerは、
  Lightning-Devメーリングリストで、チャネルの限られた利用可能な資金（"流動性"）と同時支払いキャパシティ（"HTLC slots"）を使用して、
  送信者と受信者が消費する時間に応じて課金するLNサービス手数料の追加について議論を[再開しました][jager hold fees]。
  Jagerは以前の提案（[ニュースレター #122][news122 bidir]参照）を基に、固定手数料を支払い処理時間に比例した手数料（"hold fees"）で拡張しています。
  この提案は適度な議論を受け、１つの[懸念][zmn hold fee privacy]は送信者/受信者のプライバシーの低下でした。
  この根本的な課題は5年前から[知られており][russell loop]、何度も議論されてきたので、今後も議論が続くことを期待しています。

- **<!--anti-exfiltration-->流出防止:** Andrew PoelstraとJonas Nickは、Shift Crypto [BitBox02][]およびBlockstream [Jade][]
  ハードウェアウォレットに実装されているセキュリティ技術についてのブログ[記事][anti-exfil]を公開しました。
  その目標は、ハードウェアウォレットとそれを制御するコンピューターの両方が、
  署名を生成するために使用されるナンスが確実に推測不可能な値であることをそれぞれ保証できるようにすることです。
  これにより、悪意あるハードウェアウォレットのファームウェアが、ファームウェアの作成者に知られているナンスを生成するのを防ぎます。
  ナンスを知られてしまうと、ファームウェアの作成者は、チェーン上で見つけたデバイスのトランザクション署名の１つと組み合わせて、その秘密鍵を導出し、
  その鍵で管理されている他のビットコインを使用することができるようになります。
  この記事では、ほぼ1年前にこのテーマに関するメーリングリストのスレッドで言及された
  （ニュースレター [#87][news87 exfil]および [#88][news88 exfil]を参照）、使用された技術を説明しています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **BlockstreamがLNsyncを発表:**
  [LNsync][blockstream blog lnsync]を使用すると、しばらくオフラインだったLightningウォレットが、
  支払いの宛先まで最適なルーティングをするためのLNのトポロジーの更新をすばやくダウンロードできます。
  オープンソースのプラグインである[historian][github historian]は、C-Lightningのユーザーにこの機能を提供します。

- **Rustの軽量クライアントNakamotoのリリース:**
  Alexis Sellierは、[Compact Block Filter][topic compact block filters]をベースにした
  "低リソース使用率、モジュール性、セキュリティに重点を置いたRustのBitcoin軽量クライアント実装"
  である[Nakamoto][nakamoto blog]をリリースしました。

- **Blockstream SatelliteがLNデータとBitcoin Coreのソースをブロードキャスト:**
  Blockstreamの衛星からのブロードキャストには、Bitcoinブロックチェーンデータに加えて、[Bitcoin Coreのソースコード][blockstream satellite bitcoin code]、
  衛星に最適化されたBitcoinフォーク（[Bitcoin Satellite][github bitcoin satellite]）のコードおよび
  [LNゴシップデータ][blockstream satellite ln data]が含まれています。

- **Blockstream GreenがCSVを実装:**
  Green Walletは、これまでウォレットのリカバリーの仕組みにnLockTimeを使用しており、
  ユーザーが資金を回収するために各取引の後にBlockstreamから事前署名されたトランザクションを含むバックアップメールを受信するようになっていました。
  [`OP_CHECKSEQUENCEVERIFY` (CSV) を使ったリカバリーの仕組みを実装][blockstream green csv]することで、
  トランザクション固有のバックアップファイルや、ウォレットにメールアドレスを関連付けることなく、
  ウォレットをリカバリーできるようになりました。

- **Muun 2.0リリース:**
  モバイルのBitcoinおよびLightningウォレットMuunの[2.0リリース][muun 2.0 blog]は、
  マルチシグやウォレットのリカバリー機能を含む他、AndroidとiOSのモバイルアプリをオープンソース化しています。

- **Joinmarket 0.8.1リリース:**
  [0.8.1のリリース][joinmarket 0.8.1]には、外部で作成された[PSBT][topic psbt]のサポートや[Signet][topic signet]のサポート、
  [BIP21][] URIの大文字アドレスのサポートの修正（[ニュースレター #127][news127 bech32 casing]参照）が含まれています。
  JoinMarketのターミナルベースのUI、[JoininBox][github joininbox]も0.8.1をサポートするよう更新されました。

- **VBTCでLNおよびSegwitバッチによる引き出しが可能に:**
  ベトナムの取引所であるVBTCは、最近[Lightningによる引き出しを可能に][vbtc blog lightning]した後、
  [Segwitバッチ引き出しオプションを追加しました][vbtc blog segwit]。
  インセンティブのあるSegwitバッチ引き出しは、mempoolが大量のトランザクションバックログを持つ可能性が低い時間を対象として、
  週に1回行われます。

- **Bitcoin Dev Kit v0.3.0リリース:**
  RustのウォレットライブラリBitcoin Dev Kitは、CLIの独自のリポジトリへの分割を含む[v0.3.0のリリース][bdk 0.3.0 blog]を発表しました。
  最近の[BDK v0.2.0][bdk 0.2.0 blog]のリリースでは、分枝限定法（BnB）によるコイン選択および、
  （最近追加された`sortedmulti`を含む）[descriptor][topic descriptors]テンプレートなどが追加されました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.12.1-beta.rc1][]は、LNDのメンテナンスリリースのリリース候補です。
  誤ってチャネルが閉鎖される可能性のあるエッジケースや、一部の支払いが不必要に失敗する可能性のあるバグを修正した他、
  いくつかのマイナーな改善とバグ修正が行われています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、
[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20944][]は、`getmempoolinfo` RPCおよび`mempool/info`
  RESTエンドポイントで返されるオブジェクトに新しい`total_fee`フィールドを追加しました。
  `total_fee`は、現在mempoolにあるすべてのトランザクションのトランザクション手数料の合計を示します。

- [LND #4909][]では、デーモンを再起動することなく、LNDの*ミッションコントロール*サブシステムの設定を取得し、
  一時的に変更できる新しい`getmccfg`および`setmccfg`RPCが追加されました。
  ミッションコントロールは、過去の支払いに関する情報を使って、次の支払いの試行のためのより良い経路を選択します。

- [Rust-Lightning #787][]により、エラーメッセージによるチャネル閉鎖は、
  メッセージを送信した相手がチャネルのカウンター・パーティである場合にのみ発生するようになりました。
  これまでは、悪意のあるピアがチャネルIDを知っていれば任意のチャネルを強制的に閉じることが可能でした。

- [BTCPay Server #2164][]では、ウォレットのセットアップウィザードが再設計され、
  BTCPayの内部ウォレットをセットアップし、オプションでユーザー自身のリモートソフトウェアもしくはハードウェアウォレットと
  統合することができるようになりました。これはBTCPayのインターフェースの再設計の始まりです。

- [HWI #443][]では、BitBox02ハードウェアウォレットを使用したマルチシグインプットへの署名のサポートが追加されました。

- [Bitcoin Core #19145][]は、`gettxoutsetinfo`RPCの`hash_type`オプションを拡張し、
  現在のブロック高で設定されたUTXOセットの[MuHash3072][]ダイジェストを生成する新しい`muhash`パラメーターを受け入れます。
  これは、UTXOセットのSHA256ダイジェストを生成するデフォルトの代わりの方法です。
  この方法で実行すると、MuHashはSHA256関数と同じ量のデータを処理する必要があるため、
  低速のシングルボードコンピューターで数分かかる可能性のある
  `gettxoutsetinfo`RPCのパフォーマンスに大きな変化はないと予想されます。
  しかし、以前計算されたMuHashオブジェクトは、比較的安価に要素を追加、削除できるため、将来のPRでは、
  各ブロックのUTXOセットのMuHashサマリーを迅速に計算し、それらのサマリーを単純なデータベースに保存し、
  要求に応じてほぼ即座にダイジェスト形式で返すことができるようになると期待されています。
  これは、選択された過去のブロック高でUTXOセットのハッシュを比較する機能に依存している[AssumeUTXO][topic assumeutxo]プロジェクトにも役立ちます。

- [C-Lightning #4364][]では、チャネルパートナーへの問題の通知方法を変更し、
  既存のエラーメッセージを真の*errors*と単なる*warnings*に分離しています。
  現在の[BOLT1][]の仕様では、どんなエラーが発生した際にもチャネルを閉鎖するよう要求していますが
  （ただし普遍的に実装されているようには見えません）、[提案された仕様の更新][bolts #834]により、
  より柔軟な対応を可能にする警告メッセージが導入されています。興味のある方は、
  "関係あるが、直接関係していないソフト警告エラー"と説明している、
  Carla Kirk-CohenによるLightning-Devメーリングリストへの今週の[投稿][kirk-cohen post]を読んでみてはいかがでしょうか。

{% include references.md %}
{% include linkers/issues.md issues="20944,4909,787,2164,443,19145,4364,834,831,20277" %}
[LND 0.12.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta.rc1
[safegcd bounds]: https://medium.com/blockstream/a-formal-proof-of-safegcd-bounds-695e1735a348
[bitcoinj unsolicited]: https://github.com/bitcoinj/bitcoinj/blob/7d2d8d7792ec5f4ce07ff82980b4e723993221e8/core/src/main/java/org/bitcoinj/core/TransactionBroadcast.java#L145
[de morgan's laws]: https://en.wikipedia.org/wiki/De_Morgan's_laws
[btcmag demo]: https://bitcoinmagazine.com/articles/good-griefing-a-lingering-vulnerability-on-lightning-network-that-still-needs-fixing
[anti-exfil]: https://medium.com/blockstream/anti-exfil-stopping-key-exfiltration-589f02facc2e
[news111 secp767]: /en/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[riard post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018391.html
[nguyen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018385.html
[zmn escrow1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-June/002028.html
[aragoneses escrow]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002948.html
[zmn escrow2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002955.html
[kohen escrow]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002970.html
[jager hold fees]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002958.html
[news122 bidir]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[zmn hold fee privacy]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002967.html
[russell loop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[bitbox02]: https://shiftcrypto.ch/bitbox02/
[jade]: https://blockstream.com/jade/
[news87 exfil]: /ja/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /ja/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[muhash3072]: /ja/newsletters/2021/01/13/#bitcoin-core-19055
[kirk-cohen post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002964.html
[blockstream blog lnsync]: https://blockstream.com/2021/01/22/en-lnsync-getting-your-lightning-node-up-to-speed-quickly/
[github historian]: https://github.com/lightningd/plugins/tree/master/historian
[nakamoto blog]: https://cloudhead.io/nakamoto/
[blockstream satellite bitcoin code]: https://blockstream.com/2021/02/02/en-blockstream-provides-backup-satellite-broadcast-for-bitcoin-core-source-code/
[github bitcoin satellite]: https://github.com/Blockstream/bitcoinsatellite
[blockstream satellite ln data]: https://blockstream.com/2021/01/29/en-new-blockstream-satellite-updates/
[blockstream green csv]: https://blockstream.com/2021/01/25/en-blockstream-green-bitcoin-wallets-now-using-checksequenceverify-timelocks/
[muun 2.0 blog]: https://medium.com/muunwallet/announcing-muun-2-0-d61b0844dc0a
[joinmarket 0.8.1]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.8.1.md
[news127 bech32 casing]: /en/newsletters/2020/12/09/#thwarted-upgrade-to-uppercase-bech32-qr-codes
[github joininbox]: https://github.com/openoms/joininbox
[vbtc blog segwit]: https://blog.vbtc.exchange/2021/batched-segwit-withdrawals-tutorial-5
[vbtc blog lightning]: https://blog.vbtc.exchange/2020/how-to-withdraw-bitcoin-lightning-network-tutorial-3
[bdk 0.3.0 blog]: https://bitcoindevkit.org/blog/2021/01/release-v0.3.0/
[bdk 0.2.0 blog]: https://bitcoindevkit.org/blog/2020/12/release-v0.2.0/
