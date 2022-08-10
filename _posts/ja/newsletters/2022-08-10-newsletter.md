---
title: 'Bitcoin Optech Newsletter #212'
permalink: /ja/newsletters/2022/08/10/
name: 2022-08-10-newsletter-ja
slug: 2022-08-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreや他のノードにおける
デフォルトの最小トランザクションリレー手数料率の引き下げに関する議論を掲載しています。
また、Bitcoin Core PR Review Clubの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **<!--lowering-the-default-minimum-transaction-relay-feerate-->デフォルトの最小トランザクションリレー手数料の引き下げ:**
  Bitcoin Coreは、[1 vbyteあたり少なくとも1 satoshi（1 sat/vbyte）の手数料][topic default minimum transaction relay feerates]を
  支払う個々の未承認トランザクションのみをリレーします。
  ノードのmempoolが少なくとも1 sat/vbyte支払うトランザクションでいっぱいになった場合、
  より高い手数料を支払う必要があります。手数料率の低いトランザクションであっても、
  マイナーによって引き続きブロックに含められ、そのブロックはリレーされます。
  他のノードソフトウェアも同様のポリシーを実装しています。

    デフォルトの最小手数料率を引き下げることは、これまでも議論されてきましたが（[ニュースレター #3][news3 min]参照）、
    Bitcoin Coreには[マージされませんでした][bitcoin core #13922]。
    このトピックは、この数週間で再度[議論されるようになりました][chauhan min]:

    - *<!--individual-change-effectiveness-->個別の変更の有効性:*
      個別のノードオペレーターがポリシーを変更することがどれほど有効か、
      [何人か][vjudeu min]の人々によって[議論されました][todd min]。

    - *<!--past-failures-->過去の失敗:* デフォルトの手数料率を引き下げようとした過去の試みは、
      手数料率を下げることで、いくつかの小さなサービス拒否（DoS）攻撃のコストも削減されるという理由で阻まれたことが[言及されました][harding min]。

    - *<!--alternative-relay-criteria-->代替のリレー基準:*
      特定のデフォルトの基準（デフォルト最小手数料率など）に違反するトランザクションは、
      代わりにDoS攻撃のコストがかかるような別の基準を満たすことが[提案されました][todd min2]。
      たとえば、リレーするトランザクションが適度な量のハッシュキャッシュ形式のProof of Workにコミットするなど。

    この議論は、この記事を書いている時点では明確な結論に至ってはいません。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Decouple validation cache initialization from ArgsManager][review club 25527]は、
Carl DongによるPRで、署名とスクリプトキャッシュの初期化からノードの設定ロジックを切り離すもので、
[libbitcoinkernelプロジェクト][libbitcoinkernel project]の一部です。

{% include functions/details-list.md
  q0="<!--what-does-the-argsmanager-do-why-or-why-not-should-it-belong-in-src-kernel-versus-src-node-->`ArgsManager`は何をするものですか？なぜ、`src/node`ではなく`src/kernel`にあるのですか？"
  a0="ArgsManagerは、設定オプション（`bitcoin.conf`やコマンドライン引数）を処理するためのグローバルなデータ構造です。
コンセンサスエンジンには、パラメーター化可能な値（すなわちキャッシュサイズ）が含まれる場合がありますが、
ノードはコンセンサスを維持するためにこのデータ構造を必要とはしません。
むしろ、Bitcoin Core特有の機能として、これらの設定オプションを処理するコードは`src/node`に含まれます。"
  a0link="https://bitcoincore.reviews/25527#l-35"

  q1="<!--what-are-the-validation-caches-why-would-they-belong-in-src-kernel-versus-src-node-->Validationキャッシュとは何ですか？なぜ、`src/node`ではなく`src/kernel`にあるのですか？"
  a1="新しいブロックが到着した際、検証の中で最も計算量が多いのは、トランザクションのスクリプト（つまり署名）の検証です。
mempoolを保持するノードは、通常これらのトランザクションを既に確認し検証しているため、
ブロックの検証パフォーマンスは、（成功した）スクリプトと署名の検証をキャッシュすることで大幅に向上します。
これらのキャッシュは、コンセンサス・クリティカルなブロック検証コードで必要とされるため、
論理的にはコンセンサスエンジンの一部です。したがって、これらのキャッシュは`src/kernel`にあります。"
  a1link="https://bitcoincore.reviews/25527#l-45"

  q2="<!--what-does-it-mean-for-something-to-be-consensus-critical-if-it-isn-t-a-consensus-rule-does-src-consensus-contain-all-the-consensus-critical-code-->コンセンサスルールでないものがコンセンサス・クリティカルであるというのはどういう意味ですか？
`src/consensus`にはすべてのコンセンサス・クリティカルなコードが含まれていますか？"
  a2="参加者は、署名検証はコンセンサスルールを強制し、キャッシュ化はそうでないことに同意しました。
しかし、キャッシュするコードに無効な署名を保存してしまうバグがある場合、
そのノードはコンセンサスルールを強制していないことになります。
そのため、署名のキャッシュはコンセンサス・クリティカルとみなされます。
コンセンサスのコードは、まだ`src/kernel`や`src/consensus`にはありません。
コンセンサスルールやコンセンサス・クリティカルなコードの多くは、`validation.cpp`にあります。"
  a2link="https://bitcoincore.reviews/25527#l-61"

  q3="<!--what-tools-do-you-use-for-code-archeology-to-understand-the-background-of-why-a-value-exists-->ある値が存在する背景を理解するための「コードの考古学」ではどんなツールを使っていますか？"
  a3="参加者は、`git blame`や`git log`、プルリクエストページに入力するコミットハッシュ、
ファイル表示時のGithubの`Blame`ボタンやGithubの検索バーなど、いくつかのコマンドやツールを挙げました。"
  a3link="https://bitcoincore.reviews/25527#l-132"

  q4="<!--this-pr-changes-the-type-of-signature-cache-bytes-and-script-execution-cache-bytes-from-int64-t-to-size-t-what-is-the-difference-between-int64-t-uint64-t-and-size-t-and-why-should-a-size-t-hold-these-values-->
このPRでは、`signature_cache_bytes`と`script_execution_cache_bytes`の型を`int64_t`から`size_t`に変更しています。
`int64_t`と`uint64_t`、`size_t`の違いは何で、なぜこれらの値に`size_t`を使用するのですか？"
  a4="`int64_t`型と`uint64_t`型はすべてのプラットフォームおよびコンパイラで64-bit（それぞれ符号付きと符号なし）です。
`size_t`型は、符号なし整数で、メモリ上のあらゆるオブジェクトの長さ（バイト）を保持できることが保証されており、
そのサイズはシステムに依存します。そのため、`size_t`は、キャッシュサイズをバイト数として保持するこららの変数に適しています。"
  a4link="https://bitcoincore.reviews/25527#l-163"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 0.12.0rc1][]は、この人気のLNノード実装の次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25610][]では、RPCと`-walletrbf`をデフォルトで[RBF][topic rbf]にオプトインします。
  [ニュースレター #208][news208 core RBF]で言及したアップデートに続いて、
  ノードオペレーターがノードのトランザクションの置換の振る舞いをデフォルトのオプトインRBF（BIP125）からフルRBFに切り替えられるようにするものです。
  デフォルトでのRPCオプトインは、2017年に[Bitcoin Core #9527][]で提案され、
  主な反対意見は当時の目新しさ、トランザクションをバンブできないこと、GUIにRBFを無効にする機能がないことでした。
  これらはその後すべて対処されています。

- [Bitcoin Core #24584][]では、
  単一のアウトプットタイプで構成されるインプットのセットを優先して[コイン選択][topic coin selection]するよう修正されました。
  これは、混合タイプのインプットのセットが、前のトランザクションのお釣り用のアウトプットを明らかにするシナリオに対処するためのものです。
  これは受信者のアウトプットと[お釣りのタイプを常に合わせる][#23789]という、
  関連するプライバシーの改善に続くものです（[ニュースレター #181][news181 change matching]参照）。

- [Core Lightning #5071][]は、bookkeeperプラグインを追加しました。
  このプラグインは、手数料に使われた金額を追跡する機能を含む、プラグインを実行しているノードによるビットコインの移動記録を提供します。
  マージされたPRには、いくつかの新しいRPCコマンドが含まれています。

- [BDK #645][]は、署名する[Taproot][topic taproot]の支払いパスを指定する方法を追加しました。
  以前、BDKは可能であればkeypath支払いに署名し、さらに鍵を持っているscriptpathのリーフにも署名していました。

- [BOLTs #911][]は、LNノードがそのIPアドレスを解決するDNSのホスト名を通知する機能を追加しました。
  このアイディアに関する以前の議論は、[ニュースレター #167][news167 ln dns]で言及されています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25610,24584,5071,645,911,13922,9527" %}
[core lightning 0.12.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc1
[news208 core RBF]: /ja/newsletters/2022/07/13/#bitcoin-core-25353
[news167 ln dns]: /ja/newsletters/2021/09/22/#ln-dns
[news181 change matching]: /ja/newsletters/2022/01/05/#bitcoin-core-23789
[chauhan min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020784.html
[todd min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020800.html
[vjudeu min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020821.html
[harding min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020808.html
[todd min2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020815.html
[news3 min]: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee
[#23789]: https://github.com/bitcoin/bitcoin/issues/23789
[review club 25527]: https://bitcoincore.reviews/25527
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[`ArgsManager`]: https://github.com/bitcoin/bitcoin/blob/5871b5b5ab57a0caf9b7514eb162c491c83281d5/src/util/system.h#L172
