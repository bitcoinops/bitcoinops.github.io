{:.post-meta}
*[CardCoins][]より*

_"加法的バッチ処理"は、mempool内の未承認トランザクションに追加のアウトプットを追加するスキームです。
このフィールドレポートでは、[CardCoins][]が顧客への支払いワークフローに、
そのようなスキームの再編成およびDoSに対して安全な実装を導入するために行った取り組みを紹介します。_

[Replace By Fee][topic rbf] (RBF、BIP125) と [バッチ処理][payment batching]は、
Bitcoinのmempoolと直接やりとりする企業にとって2つの重要なツールです。
手数料は上がったり下がったりしますが、ビジネスは常に手数料の効率化と戦わなければなりません。

それぞれのツールは、強力ではあるものの、複雑さや微妙な差異があります。例えば、
顧客の引き出しをバッチ処理すると、企業の手数料は節約できますが、取引を迅速にしたい顧客にとっては、
[child pays for parent][topic cpfp] (CPFP)が不経済になる可能性が高いです。
同様に、RBFは手数料を低く抑える戦略をとる企業にとっては便利ですが（最初のトランザクションのブロードキャストは低い手数料で始め、
徐々に高くしていく）、顧客の引き出しトランザクションがウォレットで更新され、顧客を[混乱させる可能性][rbf blog]があります。
また、顧客がこのトランザクションを未承認のまま使用した場合、
企業が親のトランザクションを交換しようとする際に子の支払いをする必要があるため、
顧客が未承認のこのトランザクションを使用するのは面倒なことになります。
さらに悪いことに、企業は、顧客の引き出しを受け取った他のサービスにより[ピン留め][pinning]された引き出しを持っているかもしれません。

これらの2つのツールを組み合わせると、サービスプロバイダーは新しい機能を利用できるようになりますが、
同様に新しい形の複雑さにさらされることになります。基本的なケースでは、
RBFと単一の静的なバッチを組み合わせると、RBFとバッチ処理が個別に持つ複雑さを単純に組み合わせることになります。
ただし、RBFと"加法的バッチ処理"を組み合わせると、新たなエッジケースや危険な障害シナリオが発生します。

加法的RBFバッチ処理では、サービスプロバイダーは新しい顧客の引き出しを未承認のトランザクションに組み込むめに、
mempool内のトランザクションに新しいアウトプット（および承認済みのインプット）を追加します。
これにより、サービスプロバイダーは、顧客の引き出しを一度に大量に処理することで手数料の節約効果を維持しつつ、
ユーザーには即時引き出しを提供できます。各顧客が引き出しを要求すると、mempool内のトランザクションにアウトプットが追加されます。
このトランザクションは、承認されるか、他の局所的な最適値に到達するまで更新され続けます。

このような加法的RBFバッチ処理には多くの戦略があります。[CardCoins][]では、
（[Matthew Zipkin][]の協力を得て）安全第一のアプローチで実装しました。
その詳細はブログ記事[RBF Batching at CardCoins: Diving into the Mempool's Dark Reorg Forest][cardcoins rbf blog]に掲載されています。

{% include references.md %}
[CardCoins]: https://www.cardcoins.co/
[payment batching]: /en/payment-batching/
[rbf blog]: /en/rbf-in-the-wild/#some-usability-examples
[pinning]: /en/topics/transaction-pinning/
[Matthew Zipkin]: https://twitter.com/MatthewZipkin
[cardcoins rbf blog]: https://blog.cardcoins.co/rbf-batching-at-cardcoins-diving-into-the-mempool-s-dark-reorg-forest
