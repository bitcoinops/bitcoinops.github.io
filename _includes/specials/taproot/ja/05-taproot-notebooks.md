約2年前、James ChiangとElichai Turkelは、
開発者に[Taproot][topic taproot]技術をトレーニングするためのOptechワークショップシリーズ用に
Jupyter Notebookの[オープンソースリポジトリ][taproot-workshop]を作成しました。
サンフランシスコ、ニューヨーク市、ロンドンで[開催された][workshops]ワークショップは好評でしたが、
渡航制限により、その後の対面のワークショップはできませんでした。

Jupyter Notebookの公開以来、Taprootにはいくつかの変更が加えられました。
しかし、TaprootのサポートもBitcoin Coreにマージされたため、
NotebookもBitcoin Coreのカスタムブランチへの依存関係を削除できるようになりました。
開発者のElle Moutonは、これらの変更にあわせて[Notebook][notebooks #168]を[更新し][mouton tweet]、
Taprootのアルゴリズムやデータタイプを使ったハンズオンを素早く構築するための優れた方法を再び提供してくれました。

Notebookは、4つのセクションに分かれています:

- **セクション 0**には、環境のセットアップに役立つNotebookが含まれており、
  楕円曲線暗号の基本をカバーし、BIP [340][BIP340]、
  [341][BIP341]および[342][BIP342]全体で使用されているタグ付きハッシュについて学べます。

- **セクション 1**では、[Schnorr署名][topic schnorr signatures]の作成について説明しています。
  これをマスターしたら、[MuSig][topic musig]プロトコルを使って[マルチシグ][topic multisignature]を作成する方法を学びます。

- **セクション 2**では、Taprootのあらゆる側面を体験できます。
  segwit v0トランザクションの原理を確認するところから始まり、
  segwit v1 (taproot)トランザクションの作成、送信を行います。
  セクション 1の知識を応用して、MuSigを使ったTaprootアウトプットを作成、使用します。
  鍵の調整という概念が導入され、Taprootで公開鍵を使ってデータにコミットできることを学びます。
  コミットメントが作成できるようになったので、[Tapscript][topic tapscript]について、
  従来のsegwit v0 scriptとの違いや、Tapscriptのツリーにコミットする方法を学びます。
  最後に短いNotebookで最適なスクリプトツリーを作成するためのハフマンエンコーディングを紹介します。

- **セクション 3**では、アウトプットが使われない期間が長くなるほど、
  必要になる署名が変わるTaprootアウトプットを作成するオプションの演習を用意しています。
  これにより、通常の状況下ではアウトプットを効率的に使用できるだけでなく、
  問題が発生した場合には堅牢なバックアップが提供されます。

Notebookには、比較的簡単ですが提示された資料を実際に学習することを保証するプログラミング演習が多数含まれています。
凄いコーダーではないこのコラムの著者は6時間でNotebookを完了させることができ、
もっと早くこのNotebookで学ぶ時間を取っていればよかったと後悔しました。

{% include references.md %}
[taproot-workshop]: https://github.com/bitcoinops/taproot-workshop
[workshops]: /ja/schorr-taproot-workshop/
[notebooks #168]: https://github.com/bitcoinops/taproot-workshop/pull/168
[mouton tweet]: https://twitter.com/ElleMouton/status/1418108253096095745
