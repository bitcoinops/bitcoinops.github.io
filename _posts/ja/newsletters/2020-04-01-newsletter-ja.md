---
title: 'Bitcoin Optech Newsletter #91'
permalink: /ja/newsletters/2020/04/01/
name: 2020-04-01-newsletter-ja
slug: 2020-04-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、コンセンサスの変更なしにビットコイン上でstatechainsをデプロイするための提案、電力差分解析（differential power analysis）からの保護に役立つschnorrのナンス生成機能についての議論のまとめ、BIP322のgeneric`signmessage`更新の提案、ビットコインインフラプロジェクトの注目すべき変更点についてお送りします。

## Action items

*今週は特になし。*

## News

- **schnorrやeltooを使わないstatechainsの実装:**statechainsは、ユーザー（Aliceなど）がUTXOを使用する能力を別のユーザー（Bob）に委任することを可能にする[オフチェーンシステム][statechain overview]であり、そのユーザーはさらにその権利を第3のユーザー（Carol）などに委任することができます。オフチェーンの委任操作はすべて、信頼されたサードパーティーの協力を得て実行されます。サードパーティーは委任された署名者（前の委任者であるAliceやBobなど）と共謀した場合にのみ資金を盗むことができます。委任された署名者は、信頼された第三者の許可を必要とせずに常にUTXOオンチェーンを使用することができます。議論の余地なく、statechainsはフェデレーション化された[サイドチェーン][topic sidechains]よりも信頼されていません。代表者であったことのある人（Alice、Bob、Carol）なら誰でもオンチェーンでの支出をトリガーすることができるため、statechainsはeltooメカニズムを使用して、最新の代表者（Carol）によるオンチェーンでの支出が、以前の代表者（AliceおよびBob）による支出よりも優先されることを保証するように設計されています。

    今週、Tom TrevethanがBitcoin-Devメーリングリストに、[schnorr signatures][topic schnorr signatures]や[SIGHASH_ANYPREVOUT][topic sighash_noinput]のような現状提案されているソフトフォークの変更を待つのではなく、現在のBitcoinプロトコルで使用できるようにするためのstatechainsの設計の2つの修正について投稿しました。

    1. eltooメカニズム(これは、[BIP118][]`SIGHASH_NOINPUT`または[bip-anyprevout][]`SIGHASH_ANYPREVOUT`を必要とする)を、[duplex micropayment channels][]に提案されたものと同様の、徐々に減少するロックタイムで置き換える。例えば、AliceがstatechainsのUTXOの制御を受け取ると、タイムロックは30日間、彼女が一方的にそのUTXOをチェーン上で使うことができないようにする。アリスがUTXOをボブに転送するとき、タイムロックは彼を29日間だけ制限します。これは、ボブによる支出がアリスによる支出よりも優先されます。このアプローチの欠点は、信頼できる第三者の許可なしに資金を使うことができるようになるまで、代表者が長い間待つ必要があるかもしれないということです。

    2. 信頼されたサードパーティと現在のデリゲートとの間の2-of-2 schnorr multisig([adapter signature][scriptless scripts]を使用)を、[secure multiparty computation][mpc]を使用したシングルシグニ ングに置き換える。このアプローチの主な欠点は、複雑さが増してセキュリティレビューが難しくなることです。

    何人かがこのスレッドにコメントと代替案を返信しました。また、徐々に減少するタイムロックとマルチパーティECDSAを使用し、信頼できる第三者によって確保されたオフチェーンの支払いに関連するTrevethanによる以前の[特許出願][trevethan application]について[議論][patent discussion]がされました。

- **schnorr signaturesにおける電力差分解析（differential power analysis）の緩和:**Lloyd Fournierは、[Newsletter #87][news87 bip340 update]に記載されている [BIP340][]の仕様を、 [電力差分解析（differential power analysis）][dpa]からの保護に役立つナンス生成機能を用いたschnorrにアップデートする提案について、Bitcoin-Devメーリングリストの[discussion][fournier dpa]を開始しました。電力解析攻撃には、ハードウェアウォレットが異なる署名を生成する際に使用する電力量を監視することが含まれ、どの秘密鍵が使用されたかを知る(あるいは、ブルートフォースアタックが可能になるほど鍵に関する十分な情報を明らかにする)可能性があります。Fournierは、秘密鍵とランダム性を組み合わせてハッシュ化する標準的な方法ではなく、xor演算を使って秘密鍵とランダム性を組み合わせることの有用性に疑問を投げかけています。

    BIP340の共著者であるPieter Wuilleの[返信][wuille dpa]は、次のような説明をしています。協力しているユーザの秘密鍵の間に数学的な関係が作られる鍵と署名の集約では、攻撃者（もし彼が協力しているユーザの一人であれば）は、他のユーザの秘密鍵を知るために、彼の秘密鍵の知識と他のユーザの署名生成の電力解析から得られた情報を組み合わせることができるかもしれません。SHA256のような比較的複雑なハッシュ関数の消費電力は、xor（二進加算）のような比較的単純な関数と比較して、この攻撃は実行しやすいと考えられています。詳細はWuille自身が他の数人のビットコイン暗号学者との間で行われた[ディスカッション][nonce function discussion]に記載されています。

- **BIP322 generic `signmessage`の更新提案:**数週間前に[generic signmessage][topic generic signmessage]プロトコルの将来について議論([newsletter #88][news88 bip320]参照)を始めたKarl-Johan Almは、その単純化を[提案][alm bip322 update]しました。この単純化は、異なるスクリプト用に複数の署名済みメッセージを束ねる機能や、未使用のabstraction（[BIP127][]プルーフオブリザーブなどのためにプロトコル拡張を容易とするために用意されたもの）を削除するものです。この変更に関する意見をお持ちの方は、メーリングリストのスレッドに返信するか、[PR updated the draft BIP][BIPs #903]に返信することをお勧めします。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]そして[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [LND #4078][]に`estimatemode`コンフィグ設定(`CONSERVATIVE`または`ECONOMICAL`)が追加されました。これは`bitcoind`バックエンドから取得するフィー見積もり方法を調整するものです。

{% include references.md %}
{% include linkers/issues.md issues="903,4078,3865" %}
[trevethan statechains]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017714.html
[statechain overview]: https://medium.com/@RubenSomsen/statechains-non-custodial-off-chain-bitcoin-transfer-1ae4845a4a39
[duplex micropayment channels]: https://tik-old.ee.ethz.ch/file//716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[mpc]: https://en.wikipedia.org/wiki/Secure_multi-party_computation
[scriptless scripts]: https://github.com/ElementsProject/scriptless-scripts
[fournier dpa]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017709.html
[wuille dpa]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017711.html
[news87 bip340 update]: /ja/newsletters/2020/03/04/#bip340-schnorr
[dpa]: https://en.wikipedia.org/wiki/Power_analysis#Differential_power_analysis
[nonce function discussion]: https://github.com/sipa/bips/issues/195
[alm bip322 update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017712.html
[news88 bip320]: /ja/newsletters/2020/03/11/#bip322-generic-signmessage
[patent note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017741.html
[patent discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017742.html
[trevethan application]: https://patents.google.com/patent/US20200074464A1
