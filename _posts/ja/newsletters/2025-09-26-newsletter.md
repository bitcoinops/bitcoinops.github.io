---
title: 'Bitcoin Optech Newsletter #373'
permalink: /ja/newsletters/2025/09/26/
name: 2025-09-26-newsletter-ja
slug: 2025-09-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Eclairの旧バージョンに影響を与える脆弱性と、
フルノードの手数料率設定に関する調査結果に関するまとめを掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **Eclairの脆弱性:** Matt Morehouseは、Eclairの旧バージョンに影響する脆弱性の
  [責任ある開示][topic responsible disclosures]をDelving Bitcoinで[発表しました][morehouse eclair]。
  すべてのEclairユーザーは、バージョン0.12以降へのアップグレードが推奨されます。
  この脆弱性により、攻撃者は古いコミットメントトランザクションをブロードキャストすることで、
  チャネルから現在の資金をすべて盗むことができました。この脆弱性の修正に加えて、
  Eclairの開発者は、同様の問題を検出するための包括的なテストスイートを追加しました。

- **<!--research-into-feerate-settings-->手数料率設定の調査:**
  Daniela Brozzoniは、着信接続を受け付けている約3万台のフルノードをスキャンした結果を
  Delving Bitcoinに[投稿しました][brozzoni feefilter]。各ノードに対して、
  [BIP133][]のfeefilterをクエリし、リレーされる未承認トランザクションを受け入れる現在の最低手数料率を取得します。
  ノードのmempoolがいっぱいになっていない場合、これはノードの
  [デフォルト最小トランザクションリレー手数料率][topic default minimum transaction relay feerates]です。
  彼女の調査結果によると、ほとんどのノードは、Bitcoin Coreで長年デフォルトとなっている
  1 sat/vbyte (s/v)というデフォルト値を使っていました。約4%のノードが、
  Bitcoin Coreの次期バージョン30.0のデフォルト値である0.1 s/vを使っていました。
  また、約8%のノードはクエリに応答しませんでした。これらは、スパイノードである可能性があります。

  少数のノードが9,170,997（10,000 s/v）という、feefilter値を使用していましたが、
  開発者の0xB10Cに[よると][0xb10c feefilter]、これはノードがチェーンの先端から100ブロック以上遅れており、
  後のブロックで承認される可能性のあるトランザクションよりも、ブロックデータの受信にフォーカスしている場合に、
  Bitcoin Coreの内部処理によって設定される値です。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoin Coreバージョン30.0におけるOP_RETURNの変更の影響は？]({{bse}}127895)
  Pieter Wuilleは、マイニングされるブロックの内容に影響を与えるために
  [mempoolとリレーポリシー][policy series]を使用することの有効性と欠点について、彼の見解を説明しています。

- [OP_RETURNリレー制限が効果的でないなら、なぜデフォルトの抑止策として残すのではなく、安全策を削除するのでしょうか？]({{bse}}127904)
  Antoine Poinsotは、Bitcoin Coreにおける現在のOP_RETURNのデフォルト制限値によって生じる悪影響と、
  それを削除した理由について説明しています。

- [Bitcoin Core v30でOP_RETURNの上限が設定されていない場合、最悪のストレスシナリオとはどのようなものですか？]({{bse}}127914)
  Vojtěch StrnadとPieter Wuilleは、OP_RETURN制限ポリシーのデフォルト設定の変更によって発生する可能性のある
  一連の極端なシナリオを回答しています。

- [OP_RETURNがより多くの容量を必要とするなら、なぜ80 byteの上限を160 byteに引き上げるのではなく削除したのですか？]({{bse}}127915)
  Ava ChowとAntoine Poinsotは、OP_RETURNのデフォルト値を160 byteにした場合の考慮事項を概説しています。
  具体的には、上限を継続的に設定し続けることへの抵抗、既に上限を回避している大規模マイナーの存在、
  将来のオンチェーン活動を予測できないリスクなどが含まれます。

- [任意のデータが避けられないなら、OP_RETURN制限の削除は需要をより有害な保存方法（UTXOを膨張させるアドレスなど）にシフトさせるのでは？]({{bse}}127916)
  Ava Chowは、OP_RETURN制限を撤廃することで、特定の状況において、
  アウトプットデータの保存により害の少ない代替手段を使用するインセンティブを与えると指摘しています。

- [<!--if-op-return-uncapping-doesn-t-increase-the-utxo-set-how-does-it-still-contribute-to-blockchain-bloat-and-centralization-pressure-->OP_RETURNの上限解除によってUTXOセットが増加しない場合、ブロックチェーンの肥大化と中央集権化の圧力にどのような影響を与えますか？]({{bse}}127912)
  Ava Chowは、OP_RETURNの使用の増加がBitcoinノードのリソース利用にどのように影響するかを説明しています。

- [<!--how-does-uncapping-op-return-impact-long-term-fee-market-quality-and-security-budget-->OP_RETURNの上限解除は、長期的な手数料市場の品質とセキュリティ予算にどのような影響を与えますか？]({{bse}}127906)
  Ava Chowは、OP_RETURNの仮定的な使用と将来のBitcoinマイニング収益への影響について、
  一連の質問に回答しています。

- [<!--assurance-blockchain-will-not-suffer-from-illegal-content-with-100kb-op-return-->100KBのOP_RETURNでブロックチェーンが違法コンテンツに悩まされないという保証はありますか？]({{bse}}127958)
  ユーザーjb55は、データのエンコード方式の例をいくつか挙げ、「つまり、
  検閲耐性のある分散型ネットワークでは、一般的にこのような行為を実際に阻止することはできない」と結論づけています。

- [<!--what-analysis-shows-op-return-uncapping-won-t-harm-block-propagation-or-orphan-risk-->OP_RETURNの上限撤廃がブロックの伝播やオーファンリスクに悪影響を与えないことを示す分析はありますか？]({{bse}}127905)
  Ava Chowは、大きなOP_RETURNを具体的に分離したデータセットは存在しないものの、
  [コンパクトブロック][topic compact block relay]とステイルブロックに関する過去の分析では、
  それらが異なる動作をすると予想する理由はないと指摘しています。

- [Bitcoin Coreは、ブロックデータファイルとLevelDBインデックスの両方のXOR難読化鍵をどこに保管していますか？]({{bse}}127927)
  Vojtěch Strnadは、chainstateの鍵はLevelDB内の"\000obfuscate_key"キーの下に保管され、
  ブロックとundoデータの鍵は、blocks/xor.datファイルに保管されていると述べています。

- [Bitcoin Core 28.0における1P1Cトランザクションリレーはどの程度堅牢ですか？]({{bse}}127873)
  Glozowは、オリジナルの楽観的な[1P1C（one parent one child）リレー][28.0 1p1c]のプルリクエストで言及されている非堅牢性は、
  「特に敵対者が存在する場合や、トランザクション量が非常に多いために見逃してしまうような場合には、
  動作が保証されない」という意味だと明確に述べています。

- [getblocktemplateで1 sat/vbyte未満のトランザクションを含めるためにはどうすればいいですか？]({{bse}}127881)
  ユーザーinershaは、1 sat/vbyte未満のトランザクションをリレーするだけでなく、
  候補ブロックテンプレートに含めるために必要な設定を発見しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

-  [Bitcoin Core 30.0rc1][]は、この完全な検証ノードソフトウェアの次期メジャーバージョンのリリース候補です。
   [バージョン30リリース候補のテストガイド][bcc30 testing]をご覧ください。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33333][]は、ノードの`dbcache`設定がノードのシステムRAMから算出された上限を超えた場合、
  メモリ不足エラーや過剰なスワップを防止するために、起動時に警告メッセージを出力します。
  RAMが2GB未満のシステムの場合、`dbcache`警告の閾値は450MBです。それ以外の場合、
  閾値はRAMの総容量の75%です。`dbcache`の16GB制限は、2024年9月に撤廃されました（ニュースレター[#321][news321 dbcache]参照）。

- [Bitcoin Core #28592][]は、ネットワーク上で小さなトランザクションが増加したことに伴い、
  インバウンドピアのピア毎のトランザクションリレーレートを7から14に増やしました。
  アウトバウンドピアのレートは、2.5倍の1秒あたり35トランザクションになりました。
  トランザクションリレーのレート制限は、ノードがピアに送信するトランザクション数を制限します。

- [Eclair #3171][]は、チャネル残高の均一性を前提とする経路探索手法である`PaymentWeightRatios`を削除し、
  過去の支払いの試行履歴に基づく新たに導入した確率的アプローチ（ニュースレター[#371][news371 path]参照）に置き換えます。

- [Eclair #3175][]は、`offer_chains`、`offer_paths`、`invoice_paths`および
  `invoice_blindedpay`の各フィールドが存在するものの空の場合、
  支払い不可能な[BOLT12][][オファー][topic offers]を拒否するようになりました。

- [LDK #4064][]は、署名検証ロジックを更新し、`n`フィールド（受取人の公開鍵）が存在する場合は、
  署名がそのフィールドに対して検証されるようにします。そうでない場合は、
  受取人の公開鍵は、high-Sまたはlow-S署名を持つ[BOLT11][]インボイスから抽出されます。
  このPRは、署名チェックを[BOLTs #1284][]やEclair（ニュースレター[#371][news371 pubkey]参照）などの他の実装と合わせます。

- [LDK #4067][]は、[手数料ゼロのコミットメントトランザクション][topic v3 commitments]の
  [P2Aエフェメラルアンカー][topic ephemeral anchors]アウトプットの使用をサポートし、
  チャネルピアがオンチェーンで資金の返還を請求できるようにします。
  ゼロ手数料コミットメントチャネルのLDKの実装については、ニュースレター[#371][news371 p2a]をご覧ください。

- [LDK #4046][]は、頻繁にオフラインになる送信者が、頻繁にオフラインになる受信者に
  [非同期支払い][topic async payments]を送信できるようにします。送信者は、
  受信者がオンラインに戻り、支払いを請求するための`release_held_htlc`
  [オニオンメッセージ][topic onion messages]を送信するまで、
  LSPが[HTLC][topic htlc]を保持することを示すフラグを`update_add_htlc`メッセージにセットします。

- [LDK #4083][]は、重複する[BIP353][] HRN支払いAPIを削除するため、
  `pay_for_offer_from_human_readable_name`を非推奨にします。
  ウォレットは、[BIP353][] HRN（例：satoshi@nakamoto.com）からの[オファー][topic
  offers]に支払うために、`pay_for_offer_from_hrn`を呼び出す前に、
  `bitcoin-payment-instructions`クレートを使用して支払い指示をパースし解決することが推奨されます。

- [LND #10189][]は、`sweeper`システムを更新し（ニュースレター[#346][news346 sweeper]参照）、
  `ErrMinRelayFeeNotMet`エラーコードを正しく認識し、ブロードキャストが成功するまで[手数料を引き上げる][topic rbf]ことで、
  ブロードキャストに失敗したトランザクションを再試行します。これまでは、
  エラーが一致せず、トランザクションは再試行されませんでした。
  このPRには、LNDの[Taproot Assets][topic client-side validation]を強化するために使用される
  [Taproot][topic taproot]オーバーレイチャネルに関連する、追加のお釣りアウトプットを考慮することで、
  ウェイトの推定も改善します。

- [BIPs #1963][]は、[コンパクトブロックフィルター][topic compact block filters]を定義する
  BIP（[BIP157][]および[BIP158][]）のステータスを、`Draft`から`Final`に更新します。
  これは2020年以降、Bitcoin Coreおよびその他のソフトウェアで展開されたことを受けたものです。

{% include snippets/recap-ad.md when="2025-09-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33333,28592,3171,3175,4064,4067,4046,4083,10189,1963,1284" %}
[morehouse eclair]: https://delvingbitcoin.org/t/disclosure-eclair-preimage-extraction-exploit/2010
[brozzoni feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989
[0xb10c feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989/3
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[news321 dbcache]: /ja/newsletters/2024/09/20/#bitcoin-core-28358
[news371 path]: /ja/newsletters/2025/09/12/#eclair-2308
[news371 pubkey]: /ja/newsletters/2025/09/12/#eclair-3163
[news371 p2a]: /ja/newsletters/2025/09/12/#ldk-4053
[news346 sweeper]: /ja/newsletters/2025/03/21/#lnd
[policy series]: /ja/blog/waiting-for-confirmation/
[28.0 1p1c]: /ja/bitcoin-core-28-wallet-integration-guide/#1p1cone-parent-one-childリレー
