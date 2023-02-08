---
title: 'Bitcoin Optech Newsletter #237'
permalink: /ja/newsletters/2023/02/08/
name: 2023-02-08-newsletter-ja
slug: 2023-02-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、トランザクションwitnessへのデータ保存に関する議論と、
LNのジャミングの緩和に関する会話を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **<!--discussion-about-storing-data-in-the-block-chain-->ブロックチェーンへのデータ保存に関する議論:**
  新しいプロジェクトのユーザーが最近、segwit v1（[Taproot][topic taproot]）のインプットを含むトランザクションの
  witness内に大量のデータを保存し始めました。Robert Dickinsonは、
  そのようなデータ保存を阻止するためにサイズ制限を課すべきかどうかについての質問を
  Bitcoin-Devメーリングリストに[投稿しました][dickinson ordinal]。

    Andrew Poelstraは、データの保存を防ぐ効果的な方法はないと[回答しています][poelstra ordinal]。
    不要なデータの保存を防ぐためにwitnessに新しい制限を加えることは、
    Taprootの設計時に議論された利点（[ニュースレター #65][news65 tapscript]参照）を損なうことになり、
    おそらく別の方法でデータが保存されることになるだけでしょう。
    そのような別の方法は、データを生成するコストを上げるかもしれませんが、
    おそらくその行動を大幅に抑制するほどの効果はなく、
    従来のBitcoinユーザーに対して新たな問題を引き起こすかもしれません。

    この記事を書いている時点では、このトピックについて活発な議論が続いています。
    来週のニュースレターで最新情報をお伝えする予定です。

- **LNのジャミングの緩和に関する会話のまとめ:** Carla Kirk-CohenとClara Shikhelmanは、
  [チャネルジャミング攻撃][topic channel jamming attacks]への対処の試みに関する最近のビデオ会話の概要を
  Lightning-Devメーリングリストに[投稿しました][ckccs jamming]。
  アップグレードメカニズムのトレードオフや、
  最近の論文（[ニュースレター #226][news226 jam]参照）に由来する前払い手数料のシンプルな提案、
  CircuitBreakerソフトウェア（[ニュースレター #230][news230 jam]参照）、
  レピュテーション・クレデンシャル（[ニュースレター #228][news228 jam]参照）に関するアップデート、
  LSP（Lightning Service Provider）の仕様のワーキンググループの関連研究などのトピックが議論されています。
  詳細なまとめや[議事録][jam xs]については、メーリングリストの投稿をご覧ください。

    今後のビデオミーティングは2週間毎に開催される予定です。
    今後のミーティングのアナウンスについては、Lightning-Devメーリングリストをご確認ください。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Track AddrMan totals by network and table, improve precision of adding fixed seeds][review club 26847]は、
Martin ZumsandeとAmiti UttarwarによるPRで、
ある状況下でBitcoin Coreクライアントがより確実にアウトバウンドピアを見つけることができるようにするものです。
これは、`AddrMan`（ピアのアドレスマネージャー）を拡張し、
ネットワークと、"試行済み"タイプと"新規"のタイプ別にアドレスエントリーの数を追跡することで実現しています。
これにより固定シードをより適切に使用できるようになります。
これは、アウトバウンドピアの選択を改善するためのより大きな取り組みの第一歩です。

{% include functions/details-list.md
  q0="<!--when-is-a-network-considered-reachable-->ネットワークはいつ到達可能と判断されますか？"
  a0="アクセスできない場合や、`-onlynet=`設定オプションで1つ以上の他のネットワークが指定されている場合（
      別のネットワークタイプが実際に利用可能であっても、指定されたもののみが到達可能とみなされます）以外は、
      到達可能であるとみなされます。"
  a0link="https://bitcoincore.reviews/26847#l-22"

  q1="<!--how-is-an-address-received-over-the-p2p-network-treated-depending-on-whether-the-address-s-network-is-reachable-vs-non-reachable-do-we-store-it-add-it-to-addrman-and-or-forward-it-to-peers-->
      アドレスのネットワークが到達可能かどうかどうかによって、P2Pネットワーク上で受信したアドレスはどのように扱われますか？
      アドレスを保存（`AddrMan`へ追加）したり、ピアに転送したりしますか？"
  a1="ネットワークが到達可能であればランダムに選択された2つのピアにアドレスをリレーし、
      そうでなければ１つか２つのピアにリレーします（１つか２つかはランダムに選択されます）。
      そしてネットワークが到達可能な場合のみアドレスを保存します。"
  a1link="https://bitcoincore.reviews/26847#l-51"

  q2="<!--how-can-a-node-currently-get-stuck-with-only-unreachable-addresses-in-addrman-finding-no-outbound-peers-how-does-this-pr-fix-it-->
      現在、`AddrMan`内が到達不能なアドレスのみでスタックし、アウトバウンドピアが見つけられないのはどうしてですか？
      このPRはそれをどう修正しているのでしょう？"
  a2="`-onlynet`設定オプションを変更した場合です。たとえば、
      ノードが常に`-onlynet=onion`で実行されており、その`AddrMan`にはI2Pアドレスがないとします。
      その後ノードを`-onlynet=i2p`で再起動します。固定シードは、いくつかのI2Pアドレスを持っていますが、
      このPRがなければ、`AddrMan`が _完全に_ 空ではないため（以前のonionアドレスがあるため）、
      ノードはその固定シードを使用しません。このPRにより、
      `AddrMan`には _その_ ネットワークタイプの（現在到達可能な）アドレスがないため、
      スタートアップコードは、いくつかのI2P固定シードを追加するようになります。"
  a2link="https://bitcoincore.reviews/26847#l-98"

  q3="<!--when-an-address-we-d-like-to-add-to-addrman-collides-with-an-existing-address-what-happens-is-the-existing-address-always-dropped-in-favor-of-the-new-address-->
      `AddrMan`に追加したいアドレスが既存のアドレスと衝突した場合、何が起こりますか？
      新しいアドレスを優先し、既存のアドレスは常に削除されますか？"
  a3="いいえ、既存のアドレスが「ひどい」アドレスと判断されない限り、（新しいアドレスではなく）既存のアドレスが保持されます
      （`AddrInfo::IsTerrible()`参照）。"
  a3link="https://bitcoincore.reviews/26847#l-100"

  q4="<!--why-would-it-be-beneficial-to-have-an-outbound-connection-to-each-reachable-network-at-all-times-->
      なぜ到達可能な各ネットワークへのアウトバウンド接続を常に持っていることが有益なのですか？"
  a4="利己的な理由としては、攻撃者が複数のネットワーク上でノードを実行する必要があるため、
      ノードに対し[エクリプス攻撃][topic eclipse attacks]を行うのが難しくなることです。
      利他的な理由は、ネットワーク全体を維持し、ネットワークの分断によるチェーンの分断を避けることができるためです。
      マイナーを含む半分のノードが、`-onlynet=x`で動作し、マイナーを含む残りの半分が`-onlynet=y`で動作していた場合、
      2つのチェーンが出現する可能性があります。このPRがなくても、ノードオペレーターは、
      `-addnode`設定オプションまたは`addnode` RPCを使用して、利用可能なネットワークタイプ毎に接続を手動で追加することができます。"
  a4link="https://bitcoincore.reviews/26847#l-114"

  q5="<!--why-is-the-current-logic-in-threadopenconnections-even-with-the-pr-insufficient-to-guarantee-that-the-node-has-an-outbound-connection-to-each-reachable-network-at-all-times-->
      このPRがあっても、`ThreadOpenConnections()`の現在のロジックでは、
      ノードが到達可能な各ネットワークへのアウトバウンド接続を常に保証するには不十分なのはなぜですか？"
  a5="このPRには、到達可能なネットワーク間の特定のピアの分布を _保証_ するものはありません。
      たとえば、`AddrMan`に1万個のクリアネットアドレスと50個のI2Pアドレスがある場合、
      すべてのピアがクリアネット（IPv4やIPv6）になる可能性が高くなります。"
  a5link="https://bitcoincore.reviews/26847#l-123"

  q6="<!--what-would-be-the-next-steps-towards-this-goal-see-the-previous-question-after-this-pr-->
      このPRの後、この目標（前の質問を参照）に向けての次のステップは何でしょう？"
  a6="次に計画されているステップは、到達可能な各ネットワークに少なくとも1つの接続の保持を試みるため、
      接続作成プロセスにロジックを追加することです。このPRはそのための準備です。"
  a6link="https://bitcoincore.reviews/26847#l-144"
%}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25880][]は、初期同期中のストールタイムアウトを適応的にしました。
  Bitcoin Coreは、複数のピアに並行してブロックを要求します。
  あるピアが他のピアよりも大幅に遅く、ノードが次のブロック待ちでスタックするようになった場合、
  タイムアウト後にそのピアを切断します。状況によっては、
  大きなブロックをタイムアウト内に転送できなかった場合に、
  低帯域幅接続のノードが連続して複数のピアを切断する可能性があります。
  このコードの変更により、タイムアウトを動的に適応するためにノードの動作が修正されました。
  タイムアウトは、ブロックが受信されない間、切断されたピア毎にインクリメントされ、
  ブロックが再度届き始めると、タイムアウトはブロック毎に縮小されます。

- [Core Lightning #5679][]は、CLNのlistコマンドで、SQLクエリを実行するプラグインを提供します。
  このパッチは、[Core Lightning #5867][]で紹介されているように、
  リリース前に非推奨となったものを無視することができるため、非推奨なものをより適切に処理します。

- [Core Lightning #5821][]は、`preapproveinvoice`（pre-approve invoice）RPCと
  `preapprovekeysend`（pre-approve keysend）RPCを追加しました。
  これにより、呼び出し側がCore Lightningの署名モジュール（`hsmd`）に[BOLT11][]インボイスまたは
  [keysend][topic spontaneous payments]支払いの詳細を送り、
  そのモジュールに支払いに署名する意思があるかどうか確認できるようになりました。
  使用可能な金額がレート制限されているアプリケーションなど、一部のアプリケーションでは、
  事前に承認を求める方が、単に支払いを試行して失敗に対処するよりも問題が少なくなる可能性があります。

- [Core Lightning #5849][]は、バックエンドを変更し、ノードがそれぞれ1つのチャネルを持つ
  100,000以上のピアを処理できるようにしました。近い将来で、
  このようなノードを運用環境で実行する可能性は低いですが（これだけ多くのチャネルを開くだけでも、
  12個以上のブロックを必要とします）、動作のテストをすることで、開発者はいくつかのパフォーマンスを改善することができました。

- [Core Lightning #5892][]は、Eclairの実装に取り組んでいる開発者による互換性テストに基づいて、
  CLNの[Offer][topic offers]の実装を更新しました。

- [Eclair #2565][]は、閉鎖されたチャネルの資金を、
  チャネルに資金が提供された際に生成されたアドレスではなく、新しいオンチェーンアドレスに送信するように要求するようになりました。
  これは、[アウトプットのリンク付け][topic output linking]を削減させ、
  ユーザーのプライバシーを向上させるのに役立つ可能性があります。
  このポリシーの例外は、ユーザーがLNプロトコルの`upfront-shutdown-script`オプションを有効にした場合です。
  これは、資金調達時にチャネルパートナーに送られる要求で、その時に指定したクロージングアドレスのみを使用します
  （詳細は、[ニュースレター #158][news158 upfront]参照）。

- [LND #7252][]は、LNDのデータベースバックエンドとしてSQLiteの使用をサポートしました。
  これは現在、既存のデータベースを移行するコードが無いため、LNDの新規インストール時のみサポートされます。

- [LND #6527][]は、サーバーのディスク上のTLS鍵を暗号化する機能を追加しました。
  LNDはその制御チャネルへのリモート接続、つまりAPIの実行の認証にTLSを使用します。
  TLS鍵はノードのウォレットのデータを使って暗号化されるため、
  ウォレットをアンロックするとTLS鍵もアンロックされます。
  ウォレットのアンロックは、支払いの送受信のために必要です。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25880,5679,5867,5821,5849,5892,2565,7252,6527" %}
[news158 upfront]: /ja/newsletters/2021/07/21/#eclair-1846
[dickinson ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021370.html
[poelstra ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021372.html
[news65 tapscript]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[ckccs jamming]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003834.html
[news226 jam]: /ja/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news230 jam]: /ja/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming
[news228 jam]: /ja/newsletters/2022/11/30/#ln
[jam xs]: https://github.com/ClaraShk/LNJamming/blob/main/meeting-transcripts/23-01-23-transcript.md
[review club 26847]: https://bitcoincore.reviews/26847
