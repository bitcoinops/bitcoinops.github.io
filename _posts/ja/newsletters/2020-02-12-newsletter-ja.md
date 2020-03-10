---
title: 'Bitcoin Optech Newsletter #84'
permalink: /ja/newsletters/2020/02/12/
name: 2020-02-12-newsletter-ja
slug: 2020-02-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、Bitcoin Coreのリリース候補（RC）のテスト支援の募集、BIP119 `OP_CHECKTEMPLATEVERIFY`提案に関する議論をお送りします。また、Bitcoinのコードとドキュメントの主要な変更についてもお送りします。

## Action items

- **Bitcoin Core 0.19.1rc1のテスト支援:** 今回の[メンテナンス・リリース][bitcoin core 0.19.1]には、いくつかのバグ修正が含まれています。経験豊かなユーザーは、予期した通りに動くか、テストで確認することをお勧めします。

## News

- **`OP_CHECKTEMPLATEVERIFY`（CTV）ワークショップ:** ビデオ（[午前][ctv morning vid]、[午後][ctv afternoon vid]）および[トランスクリプト][ctv transcript]は、[BIP119][] CTVに関する最近のワークショップから入手でます。この提案されたソフトフォークが採用されると、ユーザーは新しいCTVオペコードを使用して、現在のコンセンサスルールを使用する場合よりも少ないやり取りで[契約(covenants)][topic covenants]を作成できます。オペコードを活用したいくつかのアプリケーションが議論されましたが、最も注目されているのは金庫（Vault）と圧縮されたペイメントのバッチ処理です（「輻輳制御トランザクション」と呼ばれることもあります。[Newsletter #48][news48 cc]参照）。ワークショップの大部分は、聴衆からのフィードバックと、そのフィードバックへの回答で構成されていました。最後の議論では、BIP119のアクティベーションを、いつどのように試みるかが取り上げられました。そこではPRをBitcoin Coreリポジトリに送るタイミング、使用するアクティベーションメカニズム（[BIP9][]バージョンビットなど）、およびBIP9などのマイナーアクティベートソフトフォークメカニズムを使用する場合、どのようなアクティベーションの日付の範囲が適切かが議論されています。

    ワークショップに続いて、CTVの提案者Jeremy Rubinは、BIP119の提案の将来のレビューと議論を調整するための[メーリングリスト][ctv mailing list]を発表しました。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案（BIP）][bips repo]、および[Lightning BOLT][bolts repo]の注目すべき変更点*

- [Bitcoin Core #17585][]は、`labels`（複数）フィールドがすでに存在するため、`getaddressinfo` RPCによって返される`label`フィールドを廃止し、同じ機能を提供します。`label`フィールドは0.21で削除される予定です。互換性のために、`-deprecatedrpc=label`を指定して`bitcoind`を起動することにより、暫定的に古い動作を再度有効にできます。この変更は、`getaddressinfo` RPCインターフェイスをクリーンアップするための一連の変更の最後の変更です（[Newsletter #80][news80 label]で説明されているPRを含む）。

- [Bitcoin Core #18032][]は、`createmultisig`および`addmultisigaddress` RPCの結果を拡張して、生成されたmultisigアドレスの[アウトプット・スクリプト・ディスクリプター][topic output script descriptors]を含む`descriptor`フィールドを組み込みます。この変更により、ユーザー（またはこのRPCを呼び出しているプログラム）が必要なすべての情報を取得しやすくなり、作成されたアドレスへの支払いをモニターするだけでなく、支払いプロセスを開始する署名のないトランザクションを後で作成することもできます。

- [C-Lightning #3475][]では、プラグインフックが`{ "result" : "continue" }`を返すことで、`lightningd`にフックを実行せずにアクションを処理するように指示できます。これにより、フックは特別な場合にのみ簡単に実行できます。

- [C-Lightning #3372][]を使用すると、ユーザーはデフォルトのサブデーモンの1つの代わりに使用する代替プログラムを指定できます（C-Lightningシステムは、`lightningd`の*サブデーモン*と呼ばれる複数のインタラクションからなるデーモンで構成されます）。例えば、（PRの説明を参照）：

      # Use remote_hsmd instead of lightning_hsmd for signing:
      lightningd --alt-subdaemon=lightning_hsmd:remote_hsmd ...

このオプションは、代替サブデーモンが使用中の他のデーモンと完全に互換性がない場合は危険ですが、柔軟性が向上し、一部のテストが簡略化されるとされています。

- [C-Lightning #3465][]は、LND実装と同様に、出金取引にアンチ・フィー・スナイピングを実装します（[Newsletter #18][news18 afs]参照）。アンチ・フィー・スナイピングは、nLockTimeフィールドを使用して、トランザクションが生成されたときにブロックチェーンの高さよりも低いブロックにトランザクションが含まれないようにします。これにより、チェーンを再編成（フォーク）しているマイナーが、トランザクションを任意に再配置してフィーの収入を最大化することができなくなります。

- [LND #3957][]は、アトミック・マルチパス・ペイメント (Atomic Multipath Payments / AMP)を追加する今後のPRで使用できるコードを追加しました。AMPは、C-Lightning、Eclair、LNDで既にサポートされている「ベース」または「ベーシック」タイプに類似した別のタイプの[マルチパス・ペイメント][topic multipath payments]です。AMPは、ルーティング・ノードが通常の単一部分の支払いと区別するのが難しく、受信者が支払いのすべての部分を要求するか、いずれも要求しないことを保証できます。

- [BOLTs #684][]は[BOLT7][]を更新して、リモートピアがアナウンスを抑制するフィルターを要求した場合でも、ノードが独自に生成したアナウンスを送信するように提案しています。これによりフィルタリングの動作を変更することなく、ノードが直接ピア経由でネットワークにアナウンスされることを保証できます。

{% include references.md %}
{% include linkers/issues.md issues="18032,3475,3372,3465,3957,684,17585" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[ctv morning vid]: https://twitter.com/JeremyRubin/status/1223672458516938752
[ctv afternoon vid]: https://twitter.com/JeremyRubin/status/1223729378946715648
[news18 afs]: /en/newsletters/2018/10/23/#lnd-1978
[ctv transcript]: https://diyhpl.us/wiki/transcripts/ctv-bip-review-workshop/
[ctv mailing list]: https://mailman.mit.edu/mailman/listinfo/bip-0119-review
[news48 cc]: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
[news80 label]: /ja/newsletters/2020/01/15/#bitcoin-core-17578

