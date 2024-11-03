---
title: 'Bitcoin Optech Newsletter #310'
permalink: /ja/newsletters/2024/07/05/
name: 2024-07-05-newsletter-ja
slug: 2024-07-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、旧バージョンのBitcoin Coreに影響する10件の脆弱性の開示と、
BOLT11インボイスにブラインドパスを含めることができるようにする提案を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Core 0.21.0より前のバージョンに影響する脆弱性の開示:**
  Antoine Poinsotは、サポート終了からほぼ2年が経過したBitcoin Coreのバージョンに影響する
  10件の脆弱性の[発表][bcco announce]のリンクをBitcoin-Devメーリングリストに[投稿しました][poinsot disclose]。
  開示内容を以下にまとめます:

  - [miniupnpcのバグによるリモートコード実行][Remote code execution due to bug in miniupnpc]:
    Bitcoin Core 0.11.1（2015年10月リリース）より前のバージョンでは、
    ノードは[NAT][]経由で着信接続を受信できるようにデフォルトで[UPnP][]が有効になっていました。
    これは、[miniupnpcライブラリ][miniupnpc library]を使用して実現されていましたが、
    Aleksandar Nikolicがこのライブラリがさまざまなリモート攻撃に対して脆弱であることを発見しました（[CVE-2015-6031][]）。
    これは上流のライブラリで修正され、修正がBitcoin Coreに組み込まれ、
    デフォルトでUPnPを無効にするよう更新されました。このバグを調査している際に、
    Bitcoin開発者のWladimir J. Van Der Laanが同じライブラリに別のリモートコード実行の脆弱性があることを発見しました。
    これは[責任を持って開示され][topic responsible disclosures]、
    上流のライブラリで修正され、Bitcoin Core 0.12（2016年2月リリース）に組み込まれました。

  - [大きなメッセージによる複数のピアからのノードクラッシュDoS][Node crash DoS from multiple peers with large messages]:
    Bitcoin Core 0.10.1より前のバージョンでは、ノードは最大32MBのサイズのP2Pメッセージを受け入れていました。
    ノードは当時も今も最大約130の接続を許可しています。すべてのピアがほぼ同時に最大サイズのメッセージを送信した場合、
    ノードはその他のノード要件に加えて、約4GBのメモリを割り当てる必要があり、
    これは多くのノードが利用可能なメモリよりも多い量でした。この脆弱性は、BitcoinTalk.orgのユーザー
    Evil-Knievelによって責任を持って開示され、[CVE-2015-3641][]が割り当てられ、
    Bitcoin Core 0.10.1で最大メッセージサイズを約2MBに制限することで修正されました（後にsegwit用に約4MBに増加）。

  - [<!--censorship-of-unconfirmed-transactions-->未承認トランザクションの検閲][Censorship of unconfirmed transactions]:
    新しいトランザクションは通常、ピアがトランザクションのtxidまたはwtxidをノードに通知することでアナウンスされます。
    ノードがそのtxidまたはwtxidを初めて確認した場合、最初にアナウンスしたピアに完全なトランザクションを要求します。
    ノードはピアからの応答を待つ間、同じtxidまたはwtxidをアナウンスした別のピアを追跡します。
    最初のピアがタイムアウトの前にトランザクションを応答しない場合、
    ノードは2つめのピアにトランザクションを要求します（その要求がタイムアウトした場合は、3つめのピアに、以下同様）。

    Bitcoin Core 0.21.0より前のバージョンでは、ノードは50,000件の要求のみを追跡していました。
    これにより、最初のピアはtxidをアナウンスし、ノードの完全なトランザクションの要求への応答を遅らせ、
    ノードの他のピアがトランザクションをアナウンスするのを待ち、
    別のtxidのアナウンスを50,000件（おそらくすべて偽物）送信します。こうすることで、
    ノードの最初のピアへの元の要求がタイムアウトすると、他のピアに要求しなくなります。
    攻撃者（最初のピア）は、この攻撃をずっと繰り返し、ノードがトランザクションを受信できないようにすることができます。
    未承認トランザクションの検閲により、トランザクションがすぐに承認されなくなると、
    LNなどのコントラクトプロトコルで資金が失われる可能性があることに注意してください。
    John NewberyはAmiti Uttarwarと共に発見した内容を引用し、責任を持って脆弱性を開示し、
    Bitcoin Core 0.21.0で修正がリリースされました。

  - [無制限の禁止リストによるCPU/メモリDoS][Unbound ban list CPU/memory DoS]:
    Bitcoin Core（バージョン0.19.0で初めて追加された）[PR #15617][bitcoin Core #15617]では、
    `getaddr`P2Pメッセージを受信する度に、ローカルノードが禁止しているすべてのIPアドレスを最大2,500回チェックするコードが追加されました。
    ノードの禁止リストの長さは無制限で、攻撃者が多数のIPアドレスを管理している場合（簡単に入手可能なIPv6アドレスなど）、
    リストが膨大な数になる可能性があります。リストが長いと、各`getaddr`要求でCPUとメモリが過剰に消費され、
    ノードが使用できなくなったり、クラッシュする可能性があります。この脆弱性には、
    [CVE-2020-14198][]が割り当てられ、Bitcoin Core 0.20.1で修正されました。

  - [<!--netsplit-from-excessive-time-adjustment-->過度な時間調整によるネットワーク分割][Netsplit from excessive time adjustment]:
    Bitcoin Coreの旧バージョンでは、接続した最初の200個のピアが報告した時間の平均によって時計がずれる可能性がありました。
    コードでは最大70分のずれを許容することになっていました。Bitcoin Coreのすべてのバージョンでは、
    タイムスタンプが2時間以上先のブロックは一時的に無視されます。2つのバグの組み合わせにより、
    攻撃者は被害者の時計を2時間以上過去にずらすことができ、正確なタイムスタンプを持つブロックが無視される可能性がありました。
    この脆弱性は、開発者practicalswiftによって責任を持って開示され、Bitcoin Core 0.21.0で修正されました。

  - [<!--cpu-dos-and-node-stalling-from-orphan-handling-->オーファンの処理によるCPU DoSとノードの停止][CPU DoS and node stalling from orphan handling]:
    Bitcoin Coreノードは、_オーファントランザクション_ と呼ばれる最大100件のトランザクションのキャッシュを保持します。
    これらのトランザクションについては、ノードのmempoolまたはUTXOセットに必要な親トランザクションの詳細がありません。
    新しいトランザクションが検証されると、ノードはオーファントランザクションのいずれかが処理できるかどうかを確認します。
    Bitcoin Core 0.18.0より前のバージョンでは、オーファンキャッシュがチェックされる度に、
    ノードは最新のmempoolとUTXOステートを使用して各オーファントランザクションの検証を試行していました。
    キャッシュされた100件のトランザクションすべてが検証に過度のCPUを必要とするように構築されていた場合、
    ノードは過度のCPUを浪費し、数時間新しいブロックとトランザクションを処理できなくなります。
    この攻撃は、基本的に無料で実行できます。オーファントランザクションは、存在しない親トランザクションを参照できるため、
    自由に作成できます。停止したノードはブロックテンプレートを作成できず、マイナーが収益を得るのを妨げる可能性がありました。
    また、トランザクションの承認を妨げるために使用され、（LNなどの）コントラクトプロトコルのユーザーが損失を被る可能性があります。
    開発者のsec.eineは責任を持ってこの脆弱性を開示し、Bitcoin Core 0.18.0で修正されました。

  - [大きな`inv`メッセージによるメモリDoS][Memory DoS from large `inv` messages]:
    `inv`P2Pメッセージには、最大50,000個のブロックヘッダーのハッシュを含めることができます。
    バージョン0.20.0より前のBitcoin Coreノードは、認識していないハッシュ毎に個別の`getheaders`メッセージを使って、
    そのメッセージに応答します。各メッセージは約1KBです。その結果、ノードはピアがそのメッセージを受け入れるのを待つ間、
    約50MBのメッセージをメモリに保存していました。これはノードのすべてのピア（デフォルトで最大約130）によって実行される可能性があり、
    ノートの通常のメモリ要件に加えて、6.5GBを超えるメモリを使用します。これは多くのノードをクラッシュさせるのに十分な量です。
    クラッシュしたノードは、コントラクトプロトコルのユーザーのトランザクションをタイムリーに処理できない可能性があり、
    資金の損失につながる可能性があります。John Newberyは責任を持って脆弱性を開示し、
    `inv`メッセージ内の任意の数のハッシュに対して単一の`getheaders`メッセージで応答する修正を提供しました。
    この修正はBitcoin Core 0.20.0に含まれていました。

  - [<!--memory-dos-using-low-difficulty-headers-->低難易度のヘッダーを使用したメモリDoS][Memory DoS using low-difficulty headers]:
    Bitcoin Core 0.10以降、ノードは各ピアに _ベストブロックチェーン_
    （最もProof-of-Workが多い有効なブロックチェーン）のブロックヘッダーを送信するよう要求します。
    このアプローチの既知の問題は、悪意あるピアが低難易度のブロック（例えば難易度-1）に属する偽のヘッダーを
    大量にノードにスパム送信できることです。これは最新のASICマイニング機器で簡単に作成できます。
    Bitcoin Coreは当初この問題に対処するために、
    Bitcoin Coreにハードコードされたチェックポイントに一致するチェーン上のヘッダーのみを受け入れていました。
    最後のチェックポイントは2014年のものですが、現代の基準では適度に高難易度であったため、
    そこから偽のヘッダーを作成するにはかなりの労力が必要でした。ただし、Bitcoin Core 0.12に組み込まれたコードの変更により、
    ノードが低難易度のヘッダーをメモリに受け入れるようになり、攻撃者が偽のヘッダーでメモリを埋め尽くす可能性が高まりました。
    これによりノードがクラッシュし、（LNなどの）コントラクトプロトコルのユーザーの資金が失われる可能性があります。
    Cory Fieldsは責任を持ってこの脆弱性を開示し、バージョン0.15.0で修正されました。

  - [<!--cpu-wasting-dos-due-to-malformed-requests-->細工されたリクエストによるCPUを浪費するDoS][CPU-wasting DoS due to malformed requests]:
    Bitcoin Core 0.20.0より前のバージョンでは、攻撃者またはバグのあるピアが不正な`getdata`P2Pメッセージを送信し、
    メッセージの処理スレッドがCPUを100%消費する可能性がありました。また、
    ノードは接続中は攻撃者からのメッセージをそれ以上受信できなくなりますが、正当なピアからのメッセージは引き続き受信できます。
    これはCPUコアが少ないコンピューター上のノードでは問題になる可能性がありますが、それ以外の場合は迷惑なだけです。
    John Newberyは責任を持って脆弱性を開示し、修正を提供しました。
    この修正は、Bitcoin Core 0.20.0に組み込まれました。

  - [BIP72 URIを解析しようとした際のメモリ関連のクラッシュ][Memory-related crash in attempts to parse BIP72 URIs]:
    Bitcoin Core 0.20.0より前のバージョンでは、[BIP70ペイメントプロトコル][topic bip70 payment protocol]をサポートしており、
    [BIP72][]で定義されたパラメーター`r`を付与して[BIP21][]`bitcoin:` URIを拡張していました。
    このURIはHTTP(S) URLを参照します。Bitcoin Coreは、URLのファイルをダウンロードし、
    解析のためにメモリに格納しようとしますが、ファイルが使用可能なメモリよりも大きい場合、
    Bitcoin Coreは最終的に終了します。ダウンロードの試行はバックグラウンドで行われるため、
    クラッシュが発生する前にユーザーがノードをから離れ、クラッシュに気づかずに重要なサービスをすぐに再起動できない可能性があります。
    この脆弱性は、Michael Fordによって責任を持って開示され、
    Bitcoin Core 0.20.0でBIP70のサポートを削除することで修正されました（[ニュースレター #70][news70 bip70]参照）。

  Poinsotの発表によると、Bitcoin Core 22.0で修正された追加の脆弱性が今月後半に発表され、
  23.0で修正された脆弱性は来月発表される予定です。以降のバージョンで修正された脆弱性は、
  以前説明したように（[ニュースレター #306][news306 disclosure]参照）、
  Bitcoin Coreの[新しい開示ポリシー][new disclosure policy]に従って開示されます。

- **BOLT11インボイスにブラインドパス用のフィールドを追加:** Elle Moutonは、
  受信ノードに支払うための[ブラインドパス][topic rv routing]を伝達するために
  [BOLT11][]インボイスに追加できるオプションフィールドのBLIP仕様の提案をDelving Bitcoinに[投稿しました][mouton b11b]。
  たとえば、ビジネスパーソンのボブは、顧客のアリスからの支払いを受け取りたいものの、
  自分のノードやチャネルを共有しているピアのIDは公開したくありません。
  ボブは自分のノードから数ホップ離れたところからのブラインドパスを生成し、
  それをアリスに渡す標準のBOLT11インボイスに追加します。アリスがそのインボイスを解析し、
  ブラインドパスを使用して支払いをルーティングできるソフトウェアを使用している場合、ボブに支払いできます。

  アリスがBLIPをサポートしないソフトウェアを使用している場合は、インボイスに支払うことができず、
  エラーメッセージが表示されます。

  MoutonはBLIPで、BOLT11のブラインドパスは[オファー][topic offers]プロトコルが
  インボイスの通信に広く導入されるまでの間だけ使用することを目的としていると述べています。
  オファープロトコルはブラインドパスをネイティブに使用しており、BOLT11インボイスよりも他の利点があるためです。

  Bastien Teinturierは、このアイディアとオファーインボイス形式を公開するという関連アイディアに[反対しました][teinturier b11b]。
  彼は代わりにオファーの完全な展開に集中することを好み、それによりシステムが最終状態に早く到達し、
  中間的な状態を無期限にサポートする負担がなくなると考えています。
  彼は、ブラインドバスを使用したBOLT11インボイスの支払いを試みた際にエラーコードを受け取るユーザーが、
  開発者にその機能をサポートするように依頼し、オファーの作業から注意が逸れると考えています。

  Olaoluwa Osuntokunは、オファーの他の依存関係とは別にブラインドパスに取り組み、
  可能な限りうまく機能するようにしたいと[応えました][osuntokun b11b]。
  彼は、ブラインドパスを備えたBOLT11インボイスが、
  クライアントが既にサーバーと直接通信している[L402][]などのプロトコルで使用されると
  オファーのメリットの多くが受けられると想像しています。
  オファーが提供するのと同じプライバシーを得るためにブラインドパスを使用するにはこの小さなアップグレードのみが必要です。

  この記事の執筆時点では、議論がまとまったかどうかは明白ではありませんでした。
  BLIPはオプションの仕様であり、議論からこのBLIPはLNDに実装される可能性はあるものの、
  Eclairやlightning-kmp（Phoenixウォレットの基盤）には実装されなさそうです。
  他の実装については議論されませんでした。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.2rc1][]は、Bitcoin Coreの旧リリースシリーズのメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #28167][]では、`bitcoind`の新しい起動オプションとして`-rpccookieperms`が導入され、
  ユーザーはオーナー（デフォルト）、グループ、すべてのユーザーを選択して、
  RPC認証cookieのファイル読み取り権限を設定できます。

- [Bitcoin Core #30007][]では、Ava Chow（achow101）のDNSシーダーが`chainparams`に追加れ、
  ピア検出の信頼できるソースが追加されます。これはRustで書かれたBitcoinの新しいDNSシーダーである
  [Dnsseedrs][dnsseedrs]を使用しており、IPv4、IPv6、Tor v3、I2PおよびCJDNSネットワーク上のノードアドレスをクロールします。

- [Bitcoin Core #30200][]では、新しい`Mining`インターフェースが導入されました。
  `getblocktemplate`や`generateblock`のようなRPCは、すぐにこのインターフェースを使うようになります。
  Bitcoin Coreをテンプレートプロバイダーとして使用する[Stratum V2][topic pooled mining]インターフェースなどの
  将来の作業では、新しいマイニングインターフェースが使用されます。

- [Core Lightning #7342][]は、ブロックチェーンの再編成中に発生する可能性のある、
  `bitcoind`のブロックの高さが後退していることを検出してサービスが中止する起動エッジケースの処理を修正しています。
  ブロックヘッダーの高さが前のレベルに達するまで待機し、新しく受信した（再編成された）ブロックのスキャンを開始します。

- [LND #8796][]は、チャネル開設パラメーターの制限を緩和し、
  ピアが`min_depth`がゼロの非[ゼロ承認][topic zero-conf channels]チャネルを開始できるようになりました。
  ただし、LNDはチャネルが使用可能であると判断する前に、少なくとも1回の承認を待ちます。
  この変更により、これをサポートする他のライトニング実装との相互運用性が向上し、
  [BOLT2][]仕様に沿ったものになります。

- [LDK #3125][]は、[非同期支払い][topic async payments]プロトコルの今後の実装で必要な
  `HeldHtlcAvailable`および`ReleaseHeldHtlc`メッセージのエンコードおよび解析のサポートを導入します。
  また、これらのメッセージに[Onionメッセージ][topic onion messages]のペイロードを追加し、
  `OnionMessenger`に`AsyncPaymentsMessageHandler`traitを追加しています。

- [BIPs #1610][]は、Bitcoin Scriptにコンパイルされるものの、合成やテンプレート化、
  確定的な分析を可能にする言語である[Miniscript][topic miniscript]の仕様を定義した[BIP379][BIP379 md]を追加しています。
  このBIPに関する以前の参照については、[ニュースレター #304][news304 miniscript]をご覧ください。

- [BIPs #1540][]は、BIP[328][bip328]、[390][bip390]、[373][bip373]を追加し、
  [MuSig2][topic musig]の導出スキームの集約鍵（328）、
  アウトプットスクリプト[ディスクリプター][topic descriptors]（390）および、
  MuSig2のデータをあらゆるバージョンのPSBTに含めることを可能にする[PSBT][topic psbt]フィールド（373）の仕様を定義します。
  MuSig2は、[Schnorrデジタル署名][topic schnorr signatures]アルゴリズムの公開鍵と署名を集約するためのプロトコルであり、
  2ラウンドの通信のみを必要とし（MuSig1は3ラウンド必要）、これによりスクリプトベースのマルチシグと大きく変わらない
  署名体験が実現します。この導出スキームにより、[BIP327][]MuSig2集約公開鍵から
  [BIP32][topic bip32]スタイルの拡張公開鍵を構築することができます。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28167,30007,30200,7342,8796,3125,1610,1540,15617" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[mouton b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991
[teinturier b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/5
[osuntokun b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/6
[l402]: https://github.com/lightninglabs/L402
[remote code execution due to bug in miniupnpc]: https://bitcoincore.org/en/2024/07/03/disclose_upnp_rce/
[cve-2015-6031]: https://nvd.nist.gov/vuln/detail/CVE-2015-6031
[node crash dos from multiple peers with large messages]: https://bitcoincore.org/en/2024/07/03/disclose_receive_buffer_oom/
[censorship of unconfirmed transactions]: https://bitcoincore.org/en/2024/07/03/disclose_already_asked_for/
[unbound ban list cpu/memory dos]: https://bitcoincore.org/en/2024/07/03/disclose-unbounded-banlist/
[netsplit from excessive time adjustment]: https://bitcoincore.org/en/2024/07/03/disclose-timestamp-overflow/
[cpu dos and node stalling from orphan handling]: https://bitcoincore.org/en/2024/07/03/disclose-orphan-dos/
[memory dos from large `inv` messages]: https://bitcoincore.org/en/2024/07/03/disclose-inv-buffer-blowup/
[memory dos using low-difficulty headers]: https://bitcoincore.org/en/2024/07/03/disclose-header-spam/
[cpu-wasting dos due to malformed requests]: https://bitcoincore.org/en/2024/07/03/disclose-getdata-cpu/
[news70 bip70]: /ja/newsletters/2019/10/30/#bitcoin-core-17165
[memory-related crash in attempts to parse BIP72 URIs]: https://bitcoincore.org/en/2024/07/03/disclose-bip70-crash/
[cve-2020-14198]: https://nvd.nist.gov/vuln/detail/CVE-2020-14198
[news306 disclosure]: /ja/newsletters/2024/06/07/#bitcoin-core
[upnp]: https://ja.wikipedia.org/wiki/Universal_Plug_and_Play
[nat]: https://ja.wikipedia.org/wiki/ネットワークアドレス変換
[miniupnpc library]: https://miniupnp.tuxfamily.org/
[poinsot disclose]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xsylfaVvODFtrvkaPyXh0mIc64DWMCchxiVdTApFqJ_0Q5v0bOoDpS_36HwDKmzdDO9U2RKMzESEiVaq47FTamegi2kCNtVZeDAjSR4G7Ic=@protonmail.com/
[bcco announce]: https://bitcoincore.org/en/security-advisories/
[new disclosure policy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/rALfxJ5b5hyubGwdVW3F4jtugxnXRvc-tjD_qwW7z73rd5j7lXGNdEHWikmSdmNG3vkSOIwEryZzOZr_DgmVDDmt9qsX0gpRAcpY9CfwSk4=@protonmail.com/T/#u
[CVE-2015-3641]: https://nvd.nist.gov/vuln/detail/CVE-2015-3641
[dnsseedrs]: https://github.com/achow101/dnsseedrs
[news304 miniscript]: /ja/newsletters/2024/05/24/#miniscript-bip
[BIP379 md]: https://github.com/bitcoin/bips/blob/master/bip-0379.md