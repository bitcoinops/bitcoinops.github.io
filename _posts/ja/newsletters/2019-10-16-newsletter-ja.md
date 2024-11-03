---
title: 'Bitcoin Optech Newsletter #68'
permalink: /ja/newsletters/2019/10/16/
name: 2019-10-16-newsletter-ja
slug: 2019-10-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、LNDの最新リリース発表、Bitcoin CoreとC-Lightningのリリース候補のテスト要求、taprootの提案状況、デフォルトのLNルーティング料金の提案された増加の説明、最近のCryptoeconomic Systems Summitからの3つの講演の要約についてです。また、Bitcoinインフラストラクチャプロジェクトの主な変更点に関する通常のセクションもお届けします。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **LNDがバージョン0.8.0-betaにアップグレード:** [LND's newest release][lnd
  0.8.0-beta]では、 より拡張性の高いパケット形式が使用され、バックアップの安全性が向上し、watchtowerクライアントの統合が強化され、ルーティングが成功する可能性が高くなります。またその他の多くの新機能とバグ修正が含まれています。

- **Eclair 0.3.2へのアップグレード:** [Eclair's newest release][eclair 0.3.2]
 は、バックアップが改善され、ゴシップデータの同期がより帯域幅効率的になります（特にモバイルデバイス上のノードなどの非ルーティングノード用）。またその他の多くの新機能とバグ修正が含まれています。

- **リリース候補（RC）のレビュー:** 2つの主要なBitcoinインフラストラクチャプロジェクトが、ソフトウェアの次のバージョンのリリース候補（RC）を発表しました。一般公開前に問題を発見して修正できるよう、開発者と経験豊富なユーザーはこれらのRCのテストを支援するようお願いします。

  - [Bitcoin Core 0.19.0rc1][bitcoin core 0.19.0]
  - [C-Lightning 0.7.3-rc2][c-lightning 0.7.3]

## News

- **Taprootの更新:** Pieter Wuilleは、提案に対する最近の変更の概要を含む [メール][taproot update] をBitcoin-Devメーリングリストに送信しました。変更点は次のとおりです。

  * 33バイトのキーの代わりに32バイトの公開キー (
    [ニュースレター＃59][32 byte pubkey]に記載)

  * P2SHでラップされたtaprootアドレスのサポートはなし (      [#65][p2sh-wrapped taproot]で説明)

  * 16bit indexではなく32bitのtxinのインデックスを署名ハッシュデータに使用

  * タグ付きハッシュが [bip-schnorr][]で使用される( 以前は、 [bip-taproot][] および [bip-tapscript][]でのみ使用されてた)

  * 10,000バイトのスクリプトサイズおよび201カウントとした非プッシュopcodeの制限は、[bip-tapscript][] から削除( [#65][tapscript resource
    limits]で言及).

  * マークルツリーの最大深度が32レベルから128レベルに増加

  Wuilleのメールと更新されたBIPは、これらの各決定の理論的根拠と、それらに関する以前の議論へのリンクを提供しています。

- **デフォルトのLN feeの引き上げ提案:** Rusty Russellは、ノードが使用するデフォルトのチャネル内feeを、1,000ミリサトシ（msat）+100万分の1（ppm）から5,000 msat+500 ppmに増やすことを提案しました。彼は、現在のデフォルトではユーザーが料金を引き下げる余地があまりなく、現在高い料金を請求しているノードが主流である要因として多くのユーザーが現在料金に敏感ではないことを指摘しています。このメールには、さまざまな金額をUSD単位で10,000ドル/ BTCで送金するための新旧のコストを見積もるチャートが記載されています。

  | Amount |  Before     | After       |
  |--------|-------------|-------------|
  | 0.1c   |  0.0100001c |  0.05005c   |
  | 1c     |  0.010001c  |  0.0505c    |
  | 10c    |  0.01001c   |  0.055c     |
  | $1     |  0.0101c    |  0.1c       |
  | $10    |  0.011c     |  0.55c      |
  | $100   |  0.02c      |  5.05c      |
  | $1000  |  0.11c      |  50.05c     |

  C-LightningのメンテナーであるZmnSCPxjとEclairのメンテナーであるPierre-Marie Padiouは、提案への支持を示しました。LNDのメンテナーであるOlaoluwa Osuntokunは、提案の背後にある要因にはいくつかの欠陥があると考え、代わりに「将来のルーティングノードオペレーターにベストプラクティスへの教育や分析ツール提供などを行い、市場参加者に任せて、安定した経済的合理的な料金にすること」を主張しました。この記事の執筆時点では、このトピックに関する議論は継続中です。

- **<!--mit-->会議概要：暗号経済システムサミット:**MITキャンパスで先週末に開催されたこの会議では、暗号通貨の有用性と安全性の確保に関するさまざまなトピックを取り上げました。  [DCIのYouTubeチャンネル][css vids]にてビデオは視聴可能となっており、いくつかの講演の[トランスクリプト][css ts]はBryan Bishopなどによって提供されました。 [講演の内容][css ts]のうちの次の3つのトピックは、このニュースレターの読者にとって特に技術的な関心があると思われます。

   - *Everything is broken* by Cory Fields ([transcript][fields ts], [video][fields vid])  Bitcoinがそれ自体のソフトウェアバグだけでなく、ライブラリ、オペレーティングシステム、およびそれらに依存するハードウェアに導入されたバグからも危険にさらされている方法を説明する講演。Fieldsは、特定のクラスのバグの多くが別の主要なオープンソースプロジェクトであるMozilla Firefoxに影響を与えていた時代や、強力な自動保証を提供できる新しいプログラミング言語（Rust）の開発を開始することにより、これらの問題のいくつかを明確に排除しようとするプロジェクトが10年前に発足していたことを振り返りました。最後にFieldsは、次の10年間で、Bitcoinユーザーと開発者が現在注意する必要があるいくつかの問題を明確に解消するにあたり役立つことの検討を、今すぐ可能なことから取組むよう聴衆に求めました。

  - *Near misses: What could have gone wrong* by Ethan Heilman
    ([transcript][heilman ts], [video][heilman vid])  ビットコインの過去5つのユーザーの資金やユーザーの信頼を大きく損なう可能性があった問題の調査。調査に続いて、Heilmanは聴衆に、今日のビットコインの最悪のソフトウェア障害がどのように見えるか、または以前に遭遇した問題の1つが攻撃者によって最悪の範囲で悪用された場合にどうなるかを想像するよう投げかけました。この演習を試みることは非常にお勧めです。ビットコインに残っている問題を強調できますが、ビットコインが想定されているものより安全である方法を強調するのにも役立つと思われます。

  - *The quest for practical threshold Schnorr signatures* by Tim
    Ruffing ([transcript][ruffing ts], [video][ruffing vid])  しきい値Schnorr署名の安全でコンパクトで実用的で柔軟なスキームを見つけようとするスピーカーと彼の同僚によって行われた研究の説明。Ruffingはまず、一般化された形式であるしきい値署名とその特定のケースであるマルチシグとの違いについて説明しています。しきい値署名により、グループのサブセットで署名することができます（例：k-of-n）。しきい値署名は、グループ全体（n-of-n）で署名するしきい値署名の特殊なケースです。MuSig ([ニュースレター#35][musig libsecp256k1-zkp]参照）や[MSDL][]などのプロトコルは、 [bip-schnorr][]と互換性のあるマルチシグを提供しますが、前述のしきい値署名によるグループのサブセットでの署名程の効果は見込まれません。

    未解決の問題の例として、Ruffingは、既存の離散対数問題ベースのしきい値署名スキームのセキュリティ証明は、潜在的な署名者の大半が誠実であることを前提としていることを指摘しています。したがって、計画した最悪のケースは1つの不正な署名者（過半数未満）になるため、2-of-3の配置は安全です。6-of-9の配置では、スキームを最大5人の不正な署名者に対して保護する必要がありますが、5人の署名者が過半数を占め、セキュリティ証明の期待を損なうことになります。

    別の潜在的な問題は、前述のプロトコルが、各参加者が他のすべての参加者と通信する安全で信頼できる方法を持っていることを期待していることです。通信を盗聴したり操作したりできる人は、必要な支出に署名できる究極の秘密キーを取得できる可能性があります。この問題は解決可能なように思われますが、提案されている内容にはまだセキュリティ面での証明がありません。

    Ruffingは、いくつかの現状よりストレッチしたゴールを含む、しきい値Schnorr署名スキームの対するウィッシュリストで締め括っています。

## 注目すべきコードとドキュメントの変更

*今週の注目すべき変更は、 [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo]、および [Lightning BOLTs][bolts repo]です。*

- [Bitcoin Core #15437][]は [BIP61][]P2Pプロトコル `reject`メッセージのサポートを削除します。これらはBitcoin Core 0.18.0（2019年5月）で非推奨として以前に[発表][bip61 release note]されており、今後の0.19.0リリースではデフォルトで無効になります。 この変更は、マスター開発ブランチの一部であり、[ニュースレター #13][pr14054]で取り上げられ、ニュースレター [#37][bip61 discussion] および[#38][bip61 decision]でフォローされた廃止の最初の発表から1年以上後の0.20.0でリリースされる予定でした。

- [Bitcoin Core #17056][] は `sortedmulti` [output script descriptor][] を追加します。[BIP67][]で記述の通り、辞書式順に与えられた公開鍵をソートします。これにより、マルチシグモードのColdcardハードウェアウォレットのようなBIP67の使用が必要なウォレットのxpubベースの記述子をインポートできます。

- [LND #3561][] は、チャネルを検証するために使用されるロジックを統合するべく、新しいチャネル検証パッケージを追加します。channel-open dataがサードパーティピアから受信されるとき、またはローカルビットコインノードなどの様にファーストパーティデータソースから受信されるときに、この検証がされます。これは、複数のLN実装に影響した最近の脆弱性のLNDの根本的な原因に対処するのに役立ちます ( [ニュースレター#66][lnd vulns]を参照)。

- [C-Lightning #3129][] は新しいスタートアップオプション`--encrypted-hsm`を追加します。HDウォレットのシードを暗号化（暗号化されていない場合）もしくは復号（暗号化されている場合）するために使用されるパスフレーズの入力をユーザーに促します。

{% include linkers/issues.md issues="15437,17056,3561,1165,3129" %}
[lnd repo doc]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[lnd 0.8.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.0-beta
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3rc2
[32 byte pubkey]: /en/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[p2sh-wrapped taproot]: /en/newsletters/2019/09/25/#comment-if-you-expect-to-need-p2sh-wrapped-taproot-addresses
[tapscript resource limits]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[musig libsecp256k1-zkp]: /en/newsletters/2019/02/26/#musig
[MSDL]: https://eprint.iacr.org/2018/483.pdf
[pr14054]: /en/newsletters/2018/09/18/#bitcoin-core-14054
[bip61 release note]: https://bitcoincore.org/en/releases/0.18.0/#deprecated-p2p-messages
[bip61 discussion]: /en/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[bip61 decision]: /en/newsletters/2019/03/19/#bip61-reject-messages
[lnd vulns]: /en/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[taproot update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017378.html
[fields ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/everything-is-broken/
[fields vid]: https://www.youtube.com/watch?v=UDbl-2gk7n0
[heilman ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/near-misses/
[heilman vid]: https://www.youtube.com/watch?v=VAlq7vt0eIE
[ruffing ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/threshold-schnorr-signatures/
[ruffing vid]: https://www.youtube.com/watch?v=Wy5jpgmmqAg
[css ts]: https://diyhpl.us/wiki/transcripts/cryptoeconomic-systems/2019/
[css vids]: https://www.youtube.com/channel/UCJkYmuzqAnIKn3NPg5lc0Wg/videos
[eclair 0.3.2]: https://github.com/ACINQ/eclair/releases/tag/v0.3.2
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
