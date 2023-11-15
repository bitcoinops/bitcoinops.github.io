{:.post-meta}
*[Wizardsardine][]の[Antoine Poinsot][]より*

miniscriptに対する私たちの（実用的な）興味は、2020年初頭に、
当時利用可能なスクリプトプリミティブのみを使用するマルチパーティ[Vault][topic vaults]アーキテクチャである
[Revault][]を設計していた頃に始まりました。

私たちは当初、固定の参加者のセットを使用したRevaultを紹介しました。
運用環境で、より多くの参加者に一般化しようとするとすぐに問題に遭遇しました。


- 実際、デモで使用したスクリプトは安全だろうか？宣伝されているすべての方法で使用可能なのか？
宣伝されている以外の使用方法はないのか？
- たとえそうだとしても、それを様々な数の参加者に一般化し、安全性を保つためにはどうすればいいのか？
いくつかの最適化を適用して、その結果のスクリプトが同じセマンティクスを持つようにするにはどうすればいいか？
- さらに、Revaultは（支払いポリシーを強制するため）事前署名されたトランザクションを使用している。
スクリプトの構成から、手数料の引き上げに割り当てる予算を事前に把握するにはどうしたらいいか？
これらのスクリプトを使用するトランザクションが最も一般的な標準性チェックをパスすることをどうやって確認できるだろうか？
- 最後に、スクリプトが意図されたセマンティクスに対応し、常に使用可能であると仮定しても、
具体的にどのように使用できるだろうか？例えば、考えられるすべての構成について満足のいくwitness（署名）を作成するには
どうすればいいだろうか？ハードウェア署名デバイスと互換性のあるものにするにはどうすればいいか？

miniscriptがなかったら、これらの問いは難題になっていたでしょう。
ガレージにいる2人の男が、[その場でスクリプトを作成する][rekt lost funds]ソフトウェアを書き、
最善を尽くし、その上でそれをセキュリティを強化するBitcoinウォレットと呼ぶつもりはないでしょう。
私たちはRevaultの開発を中心に会社を設立したいと考えていましたが、
安全な製品を市場に投入できるという合理的な保証を投資家に提供しなければ、資金を得ることはできませんでした。
また、資金がなければ、これらのエンジニアリングの課題をすべて解決することはできないでしょう。


[miniscript][sipa miniscript]は、「構造化された方法でBitcoin Script（のサブセット）を記述し、
分析、組み合わせ、汎用署名などを可能にする言語です。[...]合成を可能にする構造を持っています。
さまざまな特性（使用条件、正当性、セキュリティ特性、マリアビリティなど）を静的に分析するのがとても簡単です。」
これはまさに私たちが必要としていたものです。この強力なツールを手に入れたことで、
投資家により良い保証[0]を提供することができ、資金を調達し、Revaultの開発を開始することができました。

当時、miniscriptはBitcoinアプリケーション開発者にとって
すぐに使用できるソリューションにはまだほど遠いものでした（もし、なたが2023年以降にこれを読んでいる新しい
Bitcoin開発者であれば、そう、私たちはBitcoin Scriptを手で書いていた時期がありました）。
私たちは、miniscriptをBitcoin Coreに統合し（PR [#24147][Bitcoin Core #24147]、
[#24148][Bitcoin Core #24148]、[#24149][Bitcoin Core #24149]参照）、
Revaultウォレットのバックエンドとして使用し、署名デバイスメーカーにファームウェアを実装するよう説得する必要がありました。
後者が最も困難でした。

これは鶏と卵の問題でした。ユーザーからの需要がないのに、メーカーがminiscriptを実装するインセンティブは低かったのです。
そして私たちは、署名デバイスのサポートなしにRevaultをリリースすることはできませんでした。
幸運なことに、このサイクルは、2021年3月に[Stepan Snigirev][]によって
[Specter DIY][]にminiscriptディスクリプターの[サポート][github specter descriptors]が
[導入された][github embit descriptors]ことで最終的に解消しました。
しかし、Specter DIYは長い間、単なる「機能的なプロトタイプ」であるみなされ、
[Salvatore Ingala][]は2022年にLedger Nano S(+)用の[新しいBitcoinアプリ][ledger bitcoin app]で初めて
[製品化可能な署名デバイスにminiscriptを導入しました][ledger miniscript blog]。
このアプリは、2023年1月にリリースされ、最も人気のある署名デバイスをサポートした
[Lianaウォレット][Liana wallet]を公開することができました。

miniscriptの旅路を締めくくるには、最後の開発が残っています。
[Liana][github liana]はリカバリーオプションに焦点を当てたBitcoinウォレットです。
このウォレットでは、タイムロックされたリカバリー条件（たとえば、
[通常は資金を使用できないサードパーティのリカバリー鍵][blog liana 0.2 recovery]や、
[減衰/拡大するマルチシグ][blog liana 0.2 decaying]など）を指定できます。
miniscriptは当初、P2WSHスクリプトでのみ利用可能でした。
[Taproot][topic taproot]がアクティベートされてから2年近く経ちますが、
資金を使用する度にリカバリーの支払い条件をオンチェーンで公開しなければならないのは残念なことです。
このため、私たちはminiscriptをTapscriptに移植する作業を行ってきました（
[こちら][github minitapscript]と[こちら][Bitcoin Core #27255]を参照）。

未来は明るいです。ほとんどの署名デバイスがminiscriptのサポートを実装しているか、
実装中（たとえば、最近の[Bitbox][github bitbox v9.15.0]や[Coldcard][github coldcard 227]）なのに加えて、
[Taprootとminiscriptのネイティブフレームワーク][github bdk]が洗練されているため、
安全なプリミティブを使用したBitcoin上のコントラクトはこれまで以上にアクセスしやすくなっています。

オープンソースのツールやフレームワークへの資金提供によって、革新的な企業が競争し、
より一般的にはプロジェクトを実行するための参入障壁がどう低くなるかに注目することは興味深いことです。
ここ数年で加速しているこの傾向は、この分野の未来に希望を抱かせてくれます。

[0] もちろんリスクはまだありました。しかし、少なくともオンチェーンの部分は乗り越えられると確信していました。
オフチェーンの方は（予想どおり）もっと難しいことが分かりました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24147,24148,24149,27255" %}
[Antoine Poinsot]: https://twitter.com/darosior
[Wizardsardine]: https://wizardsardine.com/
[Revault]: https://wizardsardine.com/revault
[rekt lost funds]: https://rekt.news/leaderboard/
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
[Stepan Snigirev]: https://github.com/stepansnigirev
[github embit descriptors]: https://github.com/diybitcoinhardware/embit/pull/4
[github specter descriptors]: https://github.com/cryptoadvance/specter-diy/pull/133
[Specter DIY]: https://github.com/cryptoadvance/specter-diy
[Salvatore Ingala]: https://github.com/bigspider
[ledger miniscript blog]: https://www.ledger.com/blog/miniscript-is-coming
[ledger bitcoin app]: https://github.com/LedgerHQ/app-bitcoin-new
[Liana wallet]: https://wizardsardine.com/liana/
[github liana]: https://github.com/wizardsardine/liana
[blog liana 0.2 recovery]: https://wizardsardine.com/blog/liana-0.2-release/#trust-distributed-safety-net
[blog liana 0.2 decaying]: https://wizardsardine.com/blog/liana-0.2-release/#decaying-multisig
[github minitapscript]: https://github.com/sipa/miniscript/pull/134
[github bitbox v9.15.0]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.15.0
[github coldcard 227]: https://github.com/Coldcard/firmware/pull/227
[github bdk]: https://github.com/bitcoindevkit/bdk