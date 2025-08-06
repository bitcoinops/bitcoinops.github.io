---
title: 'Bitcoin Optech Newsletter #365'
permalink: /ja/newsletters/2025/08/01/
name: 2025-08-01-newsletter-ja
slug: 2025-08-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、コンパクトブロックリレーのプレフィリングテストの結果と、
mempoolベースの手数料推定ライブラリのリンクを掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する議論のまとめや、
新しいリリースおよびリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **<!--testing-compact-block-prefilling-->コンパクトブロックのプレフィリングのテスト:**
  David Gumbergは、（以前ニュースレター[#315][news315 cb]と[#339][news339 cb]で取り上げた）
  コンパクトブロックの再構築率に関するDelving Bitcoinのスレッドに、
  [コンパクトブロックリレー][topic compact block relay]の _プレフィリング_
  をテストして得られた結果の概要を[返信しました][gumberg prefilling]。
  プレフィリングとは、ノードが新しいブロック内のトランザクションの一部または全部を、
  ピアがまだそれらのトランザクションを持っていない可能性があると判断した場合に、
  事前にピアにリレーすることです。Gumbergの投稿は詳細で、他の人が自分で実験できるように
  Jupyter Notebookのリンクも含まれています。主なポイントは以下のとおりです:

  - ネットワーク転送を考慮しない場合、どのトランザクションをプレフィリングするか決定する単純なルールにより、
    ブロック再構築の成功率が約62%から約98%に向上しました。

  - ネットワーク転送を考慮した場合、一部のプレフィリングにより追加のラウンドトリップが発生する可能性があり、
    その場合は利点が打ち消され、パフォーマンスがわずかに低下する可能性があります。
    しかし、この問題を回避するために多数のプレフィリングを行うことで、
    再構築率は93%にまで向上し、さらなる改善の余地も残しています。

- **mempoolベースの手数料推定ライブラリ:** Lauren Shareshianは、
  Block社が開発した[手数料推定][topic fee estimation]ライブラリを
  Delving Bitcoinで[発表しました][shareshian estimation]。他の手数料推定ツールとは異なり、
  このライブラリはノードのmempoolへのトランザクションフローのみを推定基準にしています。
  投稿では、この「Augur」ライブラリを複数の手数料推定サービスと比較し、
  Augurはミス率（トランザクションの85%以上が想定された時間内で承認される）が低く、
  平均過大推定率（トランザクションが必要以上に支払う手数料が約16%程度）も低いことが示されました。

  Abubakar Sadiq Ismailは、Delvingのスレッドに[返信し][ismail estimation]、
  Augurのリポジトリで、このライブラリで使用されているいくつかの仮定について検証する有益な[issue][augur #3]を公開しました。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--migration-from-quantum-vulnerable-outputs-->量子脆弱なアウトプットからの移行:**
  Jameson Loppは、[量子脆弱なアウトプット][topic quantum resistance]の使用を段階的に廃止するための
  3段階の提案をBitcoin-Devメーリングリストに[投稿しました][lopp qmig]。

  - 3年後
    [BIP360][]量子耐性署名スキーム（または代替スキーム）のコンセンサスの有効化から、
    ソフトフォークにより量子脆弱なアドレスに支払いをするトランザクションを拒否します。
    量子耐性のあるアウトプットへの支払いのみが許可されます。

  - 2年後、2回めのソフトフォークにより、量子脆弱なアウトプットからの支払いが拒否されます。
    これにより、量子脆弱なアウトプットに残っている資金は使用できなくなります。

  - オプションで、その後のコンセンサスの変更により、
    耐量子証明スキームを用いて（たとえば[ニュースレター #361][news361 pqcr]の内容など）
    量子脆弱なアウトプットからの支払いが許可される可能性があります。

  スレッドでの議論の大部分は、量子脆弱なビットコインを盗むのに十分な速度の量子コンピューターが存在することが判明するまで、
  量子コンピューターに脆弱なビットコインの使用を阻止する必要があるかどうかという、
  以前の議論の繰り返しでした（[ニュースレター #348][news348 destroy]参照）。
  双方から合理的な議論がなされ、この議論は今後も続くと予想されます。

- **Taprootネイティブな`OP_TEMPLATEHASH`提案:** Greg Sandersは、
  [Tapscript][topic tapscript]に3つのopcodeを追加する提案を
  Bitcoin-Devメーリングリストに[投稿しました][sanders th]。
  そのうち2つは、以前提案された[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]と
  `OP_INTERNALKEY`（[ニュースレター #285][news285 ik]参照）です。3つめのopcodeは`OP_TEMPLATEHASH`で、
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (`OP_CTV`)のTaprootネイティブ版で、
  以下の違いが強調されています:

  - （segwit以前の）レガシースクリプトは変更しません。この代替案に関する以前の議論については、
    [ニュースレター #361][news361 ctvlegacy]をご覧ください。

  - ハッシュされるデータ（およびハッシュされる順序）は、
    [Taproot][topic taproot]で署名でコミットするためにハッシュされるデータと似ているため、
    既にTaprootをサポートしているソフトウェアの実装を簡単にします。

  - `OP_CTV`とは異なり、Taprootの
    [annex][topic annex]にコミットします。
    これを使用する1つの方法は、
    古い状態の公開によりカウンターパーティがリカバリーできるようにコントラクトプロトコルで使用されるデータなど、
    一部のデータがトランザクションの一部として公開されることを保証することです。

  - `OP_NOPx` opcodeではなく、`OP_SUCCESSx` opcodeを再定義します。
    `OP_NOPx` opcodeを再定義するソフトフォークは、
    opcodeの評価が失敗した場合にトランザクションを無効としてマークする`VERIFY` opcodeである必要があります。
    `OP_SUCCESSx` opcodeの再定義は、実行後にスタックに`1`（成功）または`0`（失敗）のいずれかを配置するだけで済みます。
    これにより、再定義された`OP_NOPx` opcodeが`OP_IF`などの条件句でラップする必要がある場合でも、
    直接使用できるようになります。

  - 「... `scriptSig`で予期しない入力を防止します
   （[<!--news-->ニュースレター #361][news361 bitvm]参照）。

  Brandon Blackは、この提案を以前のLNHANCEバンドル提案（[ニュースレター #285][news285 ik]参照）と[比較し][black th]、
  ほとんどの点で同等であると評価しましたが、オンチェーンスペースにおける
  _輻輳制御_ （遅延[支払いバッチ処理][topic payment batching]）の効率性が低いと指摘しました。

- **<!--proposal-to-allow-longer-relative-timelocks-->より長い相対タイムロックを許可する提案:**
  開発者のPythは、[BIP68][]の相対タイムロックを現在の最大約1年から最大約10年に延長する提案を
  Delving Bitcoinに[投稿しました][pyth timelock]。これにはソフトフォークと、
  トランザクションインプットの _sequence_ フィールドから追加bitの使用が必要になります。

  Fabian Jahrは、あまりに遠い将来の[タイムロック][topic timelocks]は、量子コンピューターの開発（あるいは、
  前述したJameson Loppの提案のような量子防御プロトコルの導入）などによる
  資金の損失につながる可能性があると懸念を[示しました][jahr timelock]。
  Steven Rooseは、他のタイムロックメカニズム（事前署名トランザクションや[BIP65 CLTV][bip65]など）を使用することで、
  遠い将来のタイムロックは既に可能だと[指摘し][roose timelock]、Pythは、
  望ましいユースケースはウォレットのリカバリーパスであり、
  プライマリーパスが利用できなくなった場合にのみ長いタイムロックを使用し、
  代替手段がなければ資金の永久的な損失となる状況での利用を想定していると付け加えました。

- **コミットメントスキームとしてTaprootを用いた量子コンピューターに対するセキュリティ:**
  Tim Ruffingは、量子コンピューターによる改竄に対する[Taproot][topic taproot]コミットメントの
  安全性を分析した[論文][ruffing paper]のリンクを[投稿しました][ruffing qtr]。
  彼は、Taprootコミットメントが、従来のコンピューターに対して持つ _拘束性（binding）_ と
  _秘匿性（hiding）_ を今後も維持できるかどうかを検証しています。
  彼は次のように結論づけています:

  > 量子攻撃者がTaprootアウトプットを作成し、
  > それを1/2の確率で予期しないマークルルートに展開することができるようにするには、
  > 少なくとも2^81回のSHA256を実行する必要があります。
  > 攻撃者がSHA256計算の最長シーケンスが2^20に制限された量子マシンしか持っていない場合、
  > 攻撃者は1/2の成功確率を得るために少なくとも2^92台のマシンが必要です。

  Taprootコミットメントが量子コンピューターによる改竄に対して安全であれば、
  keypath支払いを無効化し、[Tapscript][topic tapscript]に量子耐性のある署名検証opcodeを追加することで、
  Bitcoinに量子耐性を追加できます。Ethan HeilmanがBitcoin-Devメーリングリストに[投稿した][heilman bip360]
  [BIP360][] pay-to-quantum-resistant-hashの最近のアップデートでは、まさにこの変更が行われています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 29.1rc1][]は、主要なフルノードソフトウェアのメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29954][]は、`getmempoolinfo` RPCを拡張し、
  レスポンスオブジェクトに2つのリレーポリシーフィールド：`permitbaremultisig`
  （ノードがベアマルチシグをリレーするかどうか）と`maxdatacarriersize`（
  mempool内のトランザクションのOP_RETURNアウトプットで許可される最大byte数）を追加しました。
  [`fullrbf`][topic rbf]や`minrelaytxfee`などの他のポリシーフラグは既に公開されているため、
  これらの追加によりリレーポリシーの完全なスナップショットが可能になります。

- [Bitcoin Core #33004][]は、`-natpmp`オプションをデフォルトで有効にし、
  [PCP（ポート制御プロトコル）][pcp]による自動ポート転送と、
  [NAT-PMP（NAT Port Mapping Protocol）][natpmp]へのフォールバックを可能にします（ニュースレター
  [#323][news323 natpmp]参照）。PCPまたはNAT-PMPをサポートするルーターの配下にある待受ノードは、
  手動設定なしでアクセス可能になります。

- [LDK #3246][]は、オファーの`signing_pubkey`を宛先として使用することで、
  [ブラインドパス][topic rv routing]なしで[BOLT12 オファー][topic offers]と払い戻しを作成できるようにします。
  `create_offer_builder`関数と`create_refund_builder`関数は、ブラインドパスの作成を
  `MessageRouter::create_blinded_paths`に委譲するようになりました。
  これにより、呼び出し元は、`DefaultMessageRouter`でコンパクトパスを生成したり、
  `NodeIdMessageRouter`で完全な長さの公開鍵パスを生成したり、
  `NullMessageRouter`でパスを生成しないようにすることができます。

- [LDK #3892][]は、[BOLT12][topic offers]インボイスのマークルツリー署名を公開し、
  開発者がCLIツールやその他のソフトウェアを構築して、インボイスを再作成できるようにします。
  このPRはまた、元のオファーを追跡するためにBOLT12インボイスに`OfferId`フィールドを追加します。

- [LDK #3662][]は、（LSPS05としても知られる）[BLIPs #55][]を実装し、
  クライアントがLSPからプッシュ通知を受け取るためにエンドポイント経由でウェブフックを登録する方法を定義しています。
  APIは、クライアントがすべてのウェブフックをリストしたり登録したり、特定のウェブフックを削除したりできる
  追加のエンドポイントを公開します。これは、クライアントが[非同期支払い][topic
  async payments]を受信する際に通知を受け取るのに便利です。

{% include snippets/recap-ad.md when="2025-08-05 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29954,33004,3246,3892,3662,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[augur #3]: https://github.com/block/bitcoin-augur/issues/3
[news315 cb]: /ja/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 cb]: /ja/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news323 natpmp]: /ja/newsletters/2024/10/04/#bitcoin-core-30043
[pcp]: https://datatracker.ietf.org/doc/html/rfc6887
[natpmp]: https://datatracker.ietf.org/doc/html/rfc6886
[gumberg prefilling]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[shareshian estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/
[ismail estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/2
[news361 pqcr]: /ja/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[sanders th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/26b96fb1-d916-474a-bd23-920becc3412cn@googlegroups.com/
[news285 ik]: /ja/newsletters/2024/01/17/#lnhance
[news361 ctvlegacy]: /ja/newsletters/2025/07/04/#concerns-and-alternatives-to-legacy-support
[pyth timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/
[jahr timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/2
[roose timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/3
[ruffing qtr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bee6b897379b9ae0c3d48f53d40a6d70fe7915f0.camel@real-or-random.org/
[ruffing paper]: https://eprint.iacr.org/2025/1307
[heilman bip360]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W=rtU2PLmHve6pUVkMQQmqT67KOg=9hp5oMspuHrgMow@mail.gmail.com/
[lopp qmig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fpv-aXBxX+eJ_EVTirkAJGyPRUNqOCYdz5um8zu6ma5Q@mail.gmail.com/
[news348 destroy]: /ja/newsletters/2025/04/04/#should-vulnerable-bitcoins-be-destroyed
[black th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aG9FEHF1lZlK6d0E@console/
[news361 bitvm]: /ja/newsletters/2025/07/04/#bitvm-ctv-csfs