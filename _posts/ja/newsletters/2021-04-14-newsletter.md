---
title: 'Bitcoin Optech Newsletter #144'
permalink: /ja/newsletters/2021/04/14/
name: 2021-04-14-newsletter-ja
slug: 2021-04-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターには、Taprootをアクティベートするためのコードの最近の進捗状況のまとめと、
最近のBitcoin Core PR Review Clubミーティングの解説や、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更点など恒例のコーナーが含まれています。

## ニュース

- **<!--taproot-activation-discussion-->Taprootアクティベーションの議論:**
  以前の[ニュースレター #139][news139 activation]で
  [Taproot][topic taproot]のソフトフォークの[アクティベーション方法][topic soft fork activation]に関する議論を紹介して以来、
  アクティベーションに興味のある人たちの間でSpeedy Trialの提案が注目されています。
  これに関して、[BIP9][]のバリエーションを使用する[PR#21377][Bitcoin Core #21377]と、
  [BIP8][]の一部となった変更を使用する[PR#21392][Bitcoin Core #21392]の２種類のPRが公開されました。
  これらのPRの主な技術的な違いは、スタートポイントとストップポイントの指定方法です。
  PR#21377はMedian Time Past ([MTP][])を使用し、PR#21392は現在のブロックの高さを使用します。

    MTPは通常、Bitcoinのメインネットワーク(mainnet)と、testnetやデフォルト[signet][topic signet]および
    さまざまな個別のsignetなどのテストネットワーク間でほぼ均一です。
    これにより、複数のネットワークでブロックの高さが大きく異なっていても、１つのアクティベーションパラメータを共有でき、
    mainnetのコンセンサスの変更に伴う同期について、これらのネットワークのユーザーの作業を最小限に抑えることができます。

    残念ながら、MTPは少数のマイナーによる小さな操作や、大多数のハッシュレートによる大きな操作が容易にできてしまいます。
    またブロックチェーンの再編成の際に、偶然、過去の時間に戻ってしまうこともあります。
    それに比べて、高さは異常な再編成がお起きた場合にのみ減少します[^height-decreasing]。
    このため、通常レビュー担当者は高さは永遠に増加するだけであるという単純化された仮定をたてることができ、
    MTPの仕組みよりも高さベースのアクティベーションの仕組みを分析するのが簡単になります。

    他の懸念の中でもとりわけ、このような２つの提案のトレードオフは、一部の開発者の間で、
    どちらかのPRが追加のレビューを受けられず最終的にいずれかがBitcoin Coreにマージされることを妨げると考えられ、
    行き詰まりをみせました。この行き詰まりは、2つのPRの作成者がが妥協案に合意したことで、
    アクティベーションの議論の一部の参加者が満足する形で解決しました:

    1. ノードがソフトフォークのブロックシグナリングのカウントを開始する時間にMTPを使用し、
       開始時間後の次の2,016ブロックのリターゲット期間の開始時にカウントを開始します。
       これは[BIP9][]のversion bitsと、
       [BIP148][]のUASFがソフトフォークのアクティベートを支援した際のブロックのカウント開始方法と同じです。

    2. ノードがまだロックインされていないソフトフォークのブロックシグナリングのカウントを止める際もMTPを使用します。
       ただし、BIP9とは異なり、MTPのストップ時間はカウントが実行されたリターゲット期間の終了時にのみチェックされます。
       これによりアクティベーションの試行が*started*から*failed*へ直接遷移する機能が削除され、
       分析が簡素化され、マイナーがアクティベーションのシグナルを送信できる完全な2,016ブロックの期間が、
       すくなくとも１回はあることが保証されます。

    3. 最小のアクティベーションパラメータに高さを使用します。これにより分析がさらに簡素化され、
       また複数のテストネットワークでアクティベーションパラメータを共有できるようにする目標とも互換が残ります。
       これらのネットワークで高さが違っていても、MTPで定義された期間内でアクティベートされるため、
       すべてのネットワークで最小のアクティベーションの高さ`0`を使用できます。

    議論の参加者の中には、この妥協案に不満を表す人もいましたが、その[実装][bitcoin core #21377]は現在、
    Bitcoin Coreの10人以上のアクティブなコントリビューターと、
    他の２つのフルノード実装（btcdとlibbitcoin）のメンテナからのレビューや支持の表明を受けています。
    我々はTaprootをアクティベートするためのこの勢いが続くことを願い、
    今後のニュースレターで追加の進展を報告できるようにしたいと考えています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Introduce deploymentstatus][review club #19438]は、
Anthony TownsによるPR ([#19438][Bitcoin Core #19438])で、
ソフトフォークのアクティベーション状態をチェックする[コード・パスをすべて変更せずに将来のデプロイメントを埋め込むための][easier burying]
３つのヘルパー関数を提案しています:
`DeploymentEnabled`はデプロイメントをアクティブにできるかどうかをテストします。
`DeploymentActiveAt`は指定されたブロックでデプロイメントを適用する必要があるかどうかをチェックし、
`DeploymentActiveAfter`は次のブロックでデプロイメントを適用する必要があるかどうか確認します。
3つすべてが、Buriedデプロイメントとversion bitsデプロイメントの両方で機能します。

Review Clubの議論は、変更とその潜在的な利点を理解することにフォーカスしました。

{% include functions/details-list.md
  q0="<!--what-are-the-advantages-of-a-bip90-buried-deployment-over-a-bip9-version-bits-deployment-->
[BIP9][] version bitsデプロイメントに対する[BIP90][] Buriedデプロイメントの利点は何ですか？"
  a0="Buriedデプロイメントは、ソフトフォークの適用を規定するテストを単純な高さのチェックに置き換えることで、
     デプロイメントロジックを簡素化し、コンセンサス変更のデプロイメントに関係する技術的負債を削減します。"
  a0link="https://bitcoincore.reviews/19438#l-132"

  q1="<!--how-many-buried-deployments-are-enumerated-by-this-pr-->このPRで列挙されているBuriedデプロイメントはいくつありますか？"
  a1="コインベースの高さ、CLTV (`CHECKLOCKTIMEVERIFY`)、Strict DER signature、CSV (`OP_CHECKSEQUENCEVERIFY`)およびSegwitの5つです。
     これらは、PRで提案された[src/consensus/params.h#L14-22](https://github.com/bitcoin/bitcoin/blob/e72e062e/src/consensus/params.h#L14-L22)の
    `BuriedDeployment`列挙型にリストされています。
     [Satoshi時代のソフトフォーク](/en/topics/soft-fork-activation/#2009-hardcoded-height-consensus-nlocktime-enforcement)も
     埋めこめられていると言えるでしょう。"
  a1link="https://bitcoincore.reviews/19438#l-75"

  q2="<!--how-many-version-bits-deployments-are-currently-defined-->現在version bitsのデプロイメントはいくつ定義されていますか？"
  a2="testdummyとschnorr/taproot (BIPs 340-342)の２つで、
     [src/consensus/params.h#L25-31](https://github.com/bitcoin/bitcoin/blob/e72e062e/src/consensus/params.h#L25-L31)内のコードベースに列挙されています。"
  a2link="https://bitcoincore.reviews/19438#l-96"

  q3="<!--if-the-taproot-soft-fork-is-activated-and-we-later-want-to-bury-that-activation-method-what-changes-would-need-to-be-made-to-bitcoin-core-if-this-pr-is-merged-->
  Taprootのソフトフォークがアクティベートされ、後でそのアクティベーション方法を埋め込みたい場合、このPRがマージされるとBitcoin Coreにどのような変更が必要ですか？"
  a3="主な変更は、現在のコードと比べて大幅に簡素化されます:
     `DEPLOYMENT_TAPROOT`の行を`DeploymentPos`列挙型から`BuriedDeployment`列挙型に移動します。
     最も重要なのは、[検証ロジックを変更する必要がないということです][burying taproot]。"
  a3link="https://bitcoincore.reviews/19438#l-227"
%}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21594][]では、`getnodeaddresses` RPCに`network`フィールドを追加し、
  さまざまなネットワーク（IPv4、IPv6、I2P、onionなど）上のノードを識別しやすくしています。
  作者は、これは将来の`getnodeaddresses`のパッチで、特定のネットワークの引数を取り、
  そのネットワークのアドレスのみを返すための基礎となることも提案しています。

- [Bitcoin Core #21166][]では、`signrawtransactionwithwallet`RPCが改良され、
  ウォレットが所有していない他の署名済みインプットを持つトランザクションのインプットに署名できるようになりました。
  [以前は][Bitcoin Core #21151]、ウォレットが所有していない署名済みのインプットを持つトランザクションがRPCに渡されると、
  そのインプットのwitnessが壊れたトランザクションが返されてました。
  他で署名されたインプットを持つトランザクションのインプットに署名することは、
  [トランザクション手数料を上げるためにインプット/アウトプットを追加するなど][Bitcoin Core #21151]、
  さまざまな状況で役立ちます。

- [LND #5108][]では、低レベルの`sendtoroute`RPCを使ったSpontaneous [Atomic Multipath Payment][topic multipath payments]
  (*Original AMP*とも呼ばれる) のサポートが追加されました。Original AMPでは、送信者がすべてのプリイメージを選択するため、
  本質的に非対話型（自発的）です。送信者のプリイメージの選択は、
  単一パスのSpontaneous paymentで使用されてきたkeysend形式の[Spontaneous Payment][topic spontaneous payments]の一部でもあります。
  今後のPRでは、高レベルの`sendpayment`RPCでSpontaneous Multipath Paymentを利用できるようにすることが期待されています。

- [LND #5047][]では、ウォレットが[BIP32][]拡張公開鍵(xpubs)をインポートし、
  それをLNDのオンチェーンウォレットへの支払いの受け取りに使用できるようになりました。
  [PSBT][topic psbt]をサポートするLNDの最近のアップデート（[ニュースレター #118][news118 lnd4389]参照）と組み合わせることで、
  LNDはチャネル資金を持たないwatch-onlyウォレットとして機能できるようになります。
  例えば、アリスはコールドウォレットからxpubをインポートし、
  LNDが指定したアドレスを使ってそのウォレットに資金をデポジットし、
  LNDにチャネルの開設を要求し、そのチャネルを開設するPSBTにコールドウォレットで署名し、
  チャネルが閉じられた際はLNDが自動的にコールドウォレットにデポジットした資金を戻すことができます。
  最後の、閉じたチャネルのデポジット資金をコールドウォレットに戻す部分は、
  特に非協力的に閉じた場合に追加の手順が必要になるかもしれませんが、 この変更によりLNDは、
  PSBTと互換性のあるコールドウォレットやハードウェアウォレットとの完全な相互運用に向けて大きく前進しました。

## 脚注

[^height-decreasing]:
    もし、ブロックチェーンのすべてのブロックが同じ個別のProof of Work（PoW）を持っているとしたら、
    最も多くのPoWを持つ有効なチェーンは、最新のブロックの高さが最も高い、最も長いチェーンになります。
    しかし、Bitcoinのプロトコルは、2,016ブロック毎に、新しいブロックに含めるPoWの量を調整し、
    ブロックの間の平均時間を10分前後に保つために作業を増やしたり減らしたりしています。
    つまり、ブロックの数が少ないチェーンが、
    ブロックの数が多いチェーンよりもPoWが多くなる可能性があるということを意味します。

      Bitcoinのユーザーはお金を受け取ったかどうか判断するのに、
      ブロック数ではなくPoWが最も多いチェーンを使用します。ユーザーは、
      そのチェーンで末端のブロックの一部が異なるブロックに置き換えられた異なるチェーンを発見すると、
      現在のチェーンよりもPoWが多ければ、その*再編成された*チェーンを使用します。
      再編成されたチェーンはより多くのPoWが累積しているにもかかわらず、含まれるブロックの数は少ない場合があるので、
      チェーンの高さは減少する可能性があります。

      これは理論上の懸念ですが、通常は実用上の問題ではありません。高さの減少は、
      再編成が2,016ブロックのセットと別の2,016ブロックのセットとの間の*リターゲット*境界の少なくとも１つを超える場合にのみ可能です。
      また、多数のブロックを含む再編成や、必要なPoWの量の直近の大きな変化（直近のハッシュレートの大きな増減、
      もしくはマイナーによる観察可能な操作）を必要とします。[BIP8][]の文脈では、
      高さを減少させる再編成は、典型的な再編成よりもアクティベーション中のユーザーに影響を与えることはないと考えています。

{% include references.md %}
{% include linkers/issues.md issues="21594,21166,5108,5047,21377,21392,19438,21151" %}
[news118 lnd4389]: /en/newsletters/2020/10/07/#lnd-4389
[news139 activation]: /ja/newsletters/2021/03/10/#taproot-activation-discussion-taproot
[mtp]: https://bitcoin.stackexchange.com/a/67622/21052
[easier burying]: https://github.com/bitcoin/bitcoin/pull/11398#issuecomment-335599326
[burying taproot]: https://bitcoincore.reviews/19438#l-230
