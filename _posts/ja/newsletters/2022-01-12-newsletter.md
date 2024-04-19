---
title: 'Bitcoin Optech Newsletter #182'
permalink: /ja/newsletters/2022/01/12/
name: 2022-01-12-newsletter-ja
slug: 2022-01-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinにトランザクション手数料を支払うためのアカウントを追加するアイディアに加えて、
Bitcoin Core PR Review Clubミーティングの概要や、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションを掲載しています。

## ニュース

- **<!--fee-accounts-->手数料アカウント:** Jeremy Rubinは、Bitcoin-Devメーリングリストに、
  LNや他のコントラクトプロトコルで使用されるような事前署名されたトランザクションに対して手数料の追加を容易にする
  ソフトフォークの大まかなアイディアを[投稿しました][rubin feea]。
  このアイディアは、[ニュースレター #116][news116 sponsorship]に掲載した
  彼のトランザクションスポンサーシップのアイディアから発展したものです。

  手数料アカウントの基本的なアイディアは、ユーザーがビットコインを、
  新しいコンセンサスルールを理解するアップグレードされたフルノードによって追跡されるアカウントに預けるトランザクションを作れるようにするというものです。
  その後、ユーザーがトランザクションに手数料を追加したい場合、
  支払いたい手数料額とそのトランザクションのtxidを含む短いメッセージに署名します。
  アップグレードされたフルノードは、トランザクションと署名済みのメッセージの両方を含むブロックに対して、
  そのブロックのマイナーに署名された額の手数料を支払うことを許可します。

  Rubinは、これにより2人以上のユーザーがUTXOの所有権を共有するコントラクトプロトコルについて、
  [CPFP][topic cpfp]と[RBF][topic rbf]による手数料の引き上げの問題や、
  過去にトランザクションに署名した際に現在のネットワーク手数料が分からなかった署名済みトランザクションを使用する他のケースに関する
  多くの問題が解消されることを示唆しています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Erlay support signaling][reviews 23443]は、Gleb NaumenkoによるPRで、
p2pコードにトランザクション・リコンサイルのネゴシエーションを追加するものです。
これはBitcoin Coreに[Erlay][topic erlay]のサポートを追加するための一連のPRの一部です。
Review Clubのミーティングでは、リコンサイルのハンドシェイクプロトコルについて議論し、
大きなプロジェクトを小さな塊に分割することのメリットとデメリットを比較検討しました。

{% include functions/details-list.md
  q0="<!--what-are-the-benefits-of-splitting-prs-into-smaller-parts-are-there-any-drawbacks-to-this-approach-->
PRを小さく分割するメリットは何ですか？また、このアプローチに欠点はありますか？"
  a0="大きなPRを小さな塊に分割することで、レビュー担当者に一度に大きな変更セットについて検討させることなく、
マージ前にPRのより焦点を絞った徹底的なレビューを促進でき、
Githubのスケーラビリティの問題によるレビューの障害に遭遇する可能性も低くなります。
議論の余地のない機械的なコードの変更はより迅速にマージし、議論の余地のある部分はより時間をかけて議論することができます。
しかし、レビュー担当者が完全な変更セットに概念的に同意しない限り、作成者が正しい方向に進んでいることを信頼することになります。
また、マージがアトミックに行われないため、作成者は、中間状態が安全ではないことや、
ノードが実際にリコンサイルを実行できるようになる前にErlayのサポートを発表するような無意味なことをしていないことを確認する必要があります。"
  a0link="https://bitcoincore.reviews/23443#l-29"

  q1="<!--when-are-nodes-supposed-to-announce-reconciliation-support-->
ノードはいつリコンサイルのサポートを通知することになっていますか？"
  a1="ノードは、その接続でトランザクションリレーがオンの場合にのみ、ピアに`sendrecon`を送るべきです。
blocksonlyモードではなく、block-relay-only接続ではなく、ピアが`fRelay=false`を送信していない場合です。
トランザクション・リコンサイルのスケッチはトランザクションのwtxidに基づいているため、
ピアはwitnessトランザクション識別子（wtxid）リレーもサポートする必要があります。"
  a1link="https://bitcoincore.reviews/23443#l-51"

  q2="<!--what-is-the-overall-handshake-and-registration-for-reconciliation-protocol-flow-->
ハンドシェイクと'リコンサイル用の登録'プロトコルの全体的な流れは？"
  a2="`version`メッセージ送信後、`verack`メッセージが送信される前に、
ピアはそれぞれローカルで生成されたsaltなどの情報を含む`sendrecon`メッセージを送信します。
強制的な順序はなく、どちらのピアが先に送信しても構いません。
有効な`sendrecon`メッセージを送信、受信した場合、そのピアとのリコンサイル・ステートを初期化する必要があります。"
  a2link="https://bitcoincore.reviews/23443#l-63"

  q3="<!--what-is-the-overall-handshake-and-registration-for-reconciliation-protocol-flow-->
なぜErlayではp2pプロトコルがバージョンアップされないのですか？"
  a3="この動作には新しいプロトコルバージョンは必要ありません。
Erlayを使用するノードは、既存のプロトコルと互換性がないわけではありません。
`sendrecon`などのErlayのメッセージを理解しない旧ノードは、単にそれを無視し、そのまま正常に動作します。"
  a3link="https://bitcoincore.reviews/23443#l-78"

  q4="<!--what-is-the-reason-for-generating-local-per-connection-salts-how-is-it-generated-->
ローカルで接続毎にsaltを生成する理由は何ですか？まだどのように生成されますか？"
  a4="接続のリコンサイルsaltは両方のピアがローカルで生成したsaltを組み合わせたもので、
各トランザクションのshortidを作成するのに使用されます。shortidの算出に使用されるsalt付きのハッシュ関数は、
コンパクトなIDを効率的に作成するよう設計されていますが、攻撃者がsaltを制御できる場合は、
衝突に対する安全性が保証されません。双方がsaltを提供する場合、第三者がsaltの内容を制御することはできません。
ローカルで、各接続ごとに新しいsaltが生成されるため、この方法でノードのフィンガープリントを採取することはできません。"
  a4link="https://bitcoincore.reviews/23443#l-93"
%}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23882][]には、testnet3の動作に関する`validation.cpp`のドキュメントの更新が含まれています。

  Bitcoinの元のバージョンでは、トランザクションが同じ内容を持ち、その結果txidが衝突する可能性がありました。
  重複の問題は、インプットとアウトプットの構成がすべてのコインベーストランザクションで部分的に同じか、
  ブロックテンプレートの作成者によって決定されるコインベーストランザクションで特に発生する可能性があります。
  mainnetのブロックチェーンには、高さ91,842と91,880に、2つの重複するコインベーストランザクションが含まれています。
  これらのトランザクションは、以前のコインベーストランザクションと同一で、
  使用される前に既存のコインベースアウトプットを上書きし、利用可能な供給量を100 BTC削減しました。
  これらの事件を受けて、重複するトランザクションを禁止する[BIP30][]が導入されました。
  BIP30により、各トランザクションについて、
  それぞれのtxidに対してUTXOが既に存在しているかどうかをチェックするよう[実装されました][bip30-impl]。
  この重複の問題は、コインベーストランザクションのscriptSigの最初の項目としてブロック高を要求する[BIP34]の導入により効果的に防止されました。
  高さは一意であるため、コインベースの内容が異なる高さで同一になることはなくなり、
  これにより帰納的に子孫トランザクションにおける問題も防ぐことができます。
  したがって、重複に対する追加のチェックを実行する必要がなくなりました。

  その後、[BIP34][]には欠陥があり、[BIP34][]の導入前に既に将来のブロック高の高さのパターンに一致する
  コインベーストランザクションが存在していたことが明らかにりました。
  マイナーがBIP30に違反する衝突を発生させることができる最初のブロック高は、
  mainnetで2040年以降と予想される1,983,702です。ただし、testnet3ではその間に、高さ1,983,702を超えています。
  このためBitcoin Coreは、testnetのトランザクション毎に未使用のトランザクションが重複していないかチェックするよう戻しました。

- [Eclair #2117][]は、[Offerプロトコル][topic offers]のサポートに備えて、
  [Onionメッセージ][topic onion messages]の応答処理のサポートを追加しました。

- [LND #5964][]は、指定したUTXOを指定した期間使用しないようウォレットに指示する`leaseoutput` RPCを追加しました。
  これはBitcoin Coreの`lockunspent`など、他のウォレットソフトウェアで提供されているRPCと似たものです。

- [BOLTs #912][]は、受信者が提供するメタデータ用の新しいオプションフィールドを[BOLT11][]インボイスに追加しました。
  インボイスでこのフィールドが使用される場合、支払いノードは、
  ネットワークを介して受信者にルーティングするペイメント・メッセージにメタデータを含める必要があるかもしれません。
  その後、受信者は[ステートレスインボイス][topic stateless invoices]を可能にするため
  [当初提案された][news168 stateless]この情報の使用など、支払い処理の一部としてこのメタデータを使用できます。

- [BOLTs #950][]は、後方互換性のある警告メッセージを[BOLT1][]に導入し、
  致命的なエラーを送信する要件を削減し、不要なチャネルの閉鎖を回避します。
  これは、より標準化され充実するエラーに向けた第一歩です。
  詳細については、
  [BOLTs #834][]およびCarla Kirk-CohenによるLightning-devメーリングリストへの[投稿][Error Codes for LN]を参照してください
  （[ニュースレター #136][news136 warning post]参照）。

{% include references.md %}
{% include linkers/issues.md issues="23882,2117,5964,912,950,834,23443" %}
[rubin feea]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019724.html
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[news168 stateless]: /ja/newsletters/2021/09/29/#stateless-ln-invoice-generation-ln
[reviews 23443]: https://bitcoincore.reviews/23443
[Error Codes for LN]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002964.html
[news136 warning post]: /ja/newsletters/2021/02/17/#c-lightning-4364
[bip30-impl]: https://github.com/bitcoin/bitcoin/pull/915/files
