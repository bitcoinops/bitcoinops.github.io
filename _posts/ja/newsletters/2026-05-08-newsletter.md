---
title: 'Bitcoin Optech Newsletter #404'
permalink: /ja/newsletters/2026/05/08/
name: 2026-05-08-newsletter-ja
slug: 2026-05-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
<script>
(function () {
  var DELAY = 4000;
  var FADE  = 600;

  var style = document.createElement('style');
  style.textContent =
    '#nl404 { font-family: serif; text-align: center; padding: 2em 0; }' +
    '#nl404 h1 { font-weight: normal; font-size: 1.5em; margin-bottom: 0.5em; }' +
    '#nl404 hr { border: 1px solid #000; margin: 0.5em 0; }' +
    '.nl404-hide { display: none !important; }' +
    '@keyframes nl404fi { from { opacity: 0; } to { opacity: 1; } }' +
    '.nl404-show { animation: nl404fi ' + FADE + 'ms ease forwards; }';
  (document.head || document.documentElement).appendChild(style);

  document.addEventListener('DOMContentLoaded', function () {
    var wrap = document.querySelector('.post-content');
    if (!wrap) return;

    var kids = Array.prototype.slice.call(wrap.children);
    kids.forEach(function (el) { el.classList.add('nl404-hide'); });

    var box = document.createElement('div');
    box.id = 'nl404';
    box.innerHTML =
      '<h1>Newsletter Not Found</h1>' +
      '<p>:)</p>';
    wrap.insertBefore(box, wrap.firstChild);

    setTimeout(function () {
      box.remove();
      kids.forEach(function (el) {
        el.classList.remove('nl404-hide');
        el.classList.add('nl404-show');
      });
    }, DELAY);
  });
}());
</script>

今週のニュースレターでは、ノードのフィンガープリンティングに対して考えられるソリューションと、
JITチャネルにおけるインセンティブ向上ために公開Fraud Proofを利用する議論のリンクを掲載しています。
また、人気のBitcoin基盤ソフトウェアの注目すべき更新について解説する、恒例のセクションも含まれています。

<script>
(function () {
  var DELAY = 2500;
  var FADE  = 600;

  var style = document.createElement('style');
  style.textContent =
    '#nl404 { font-family: serif; text-align: center; padding: 2em 0; }' +
    '#nl404 h1 { font-weight: normal; font-size: 1.5em; margin-bottom: 0.5em; }' +
    '#nl404 hr { border: 1px solid #000; margin: 0.5em 0; }' +
    '.nl404-hide { display: none !important; }' +
    '@keyframes nl404fi { from { opacity: 0; } to { opacity: 1; } }' +
    '.nl404-show { animation: nl404fi ' + FADE + 'ms ease forwards; }';
  (document.head || document.documentElement).appendChild(style);

  document.addEventListener('DOMContentLoaded', function () {
    if (sessionStorage.getItem('nl404shown')) return;
    sessionStorage.setItem('nl404shown', '1');

    var wrap = document.querySelector('.post-content');
    if (!wrap) return;

    var kids = Array.prototype.slice.call(wrap.children);
    kids.forEach(function (el) { el.classList.add('nl404-hide'); });

    var box = document.createElement('div');
    box.id = 'nl404';
    box.innerHTML =
      '<h1>Newsletter Not Found</h1>' +
      '<p>:)</p>';
    wrap.insertBefore(box, wrap.firstChild);

    setTimeout(function () {
      box.remove();
      kids.forEach(function (el) {
        el.classList.remove('nl404-hide');
        el.classList.add('nl404-show');
      });
    }, DELAY);
  });
}());
</script>

## ニュース

- **<!--possible-solutions-to-node-fingerprinting-->ノードのフィンガープリンティングに対して考えられるソリューション**:
  Naiyomaは、複数のネットワーク上で同じノードを識別するために`addr`メッセージのタイムスタンプを利用する
  ノードのフィンガープリンティング問題（[ニュースレター #360][news360 fing]参照）についての
  ソリューションをDelving Bitcoinに[投稿しました][fing del]。

  前回の更新から、研究者らはこの問題についてさらに多くの知見を得て、考慮すべき新たな要因を特定しました。
  重要な知見の1つは、アドレスを管理するコード構造である`AddrMan`に関するものです。`AddrMan`は、
  タイムスタンプが30日以上前のアドレスを古くなったアドレスとみなします。これは通常、
  ピアがオフラインになっていることに起因します。したがって、対策を検討する際には、
  2つの重要な要素を考慮する必要があります。古いタイムスタンプを新しいものに更新すると、
  古いアドレスが継続的にゴシップされ続けてしまう可能性があり、逆に古くすると、
  ゴシップが早期に停止してしまう可能性があります。これらの考慮事項から、
  以前検討されていた一部のソリューションは破棄され、新たなソリューションが提示されました:

  1. **シンプルなファジング**: アドレスのタイムスタンプに`[-5, +5]日`の範囲でランダムな歪みを加えます。
    ただし、この歪みは時間の経過とともに平均化される可能性があります。

  2. **ネットワーク別の固定タイムスタンプ**: リクエストに応答する際、特定のネットワークについては実際のタイムスタンプを保持し、
    それ以外のネットワークではタイムスタンプを過去のランダム化された値に設定します。ただし、
    古いアドレスが必要以上に長く流通し続ける可能性があります。

  3. **アドレスを古くする方向のみのファジング**: `[1, 10]日`の範囲のランダムな歪みを適用し、
    アドレスを新しくすることなく古くする方向のみに変化させます。ただし、
    アドレスが30日のしきい値に早く到達してしまう可能性があります。

  4. **経年変化を考慮したタイムスタンプノイズのファジング**: `[-1, +5]日`の範囲でランダムな歪みを適用し、
    アドレスが新しくなる可能性をわずかに残しつつ、主に古くなる方向に変化させます。ただし、
    古いアドレスが必要以上に長く流通し続ける可能性があります。

  5. **ハイブリッドアプローチ**: 最後の選択肢は、上記のアプローチのうち2つを組み合わせるというものです。

  Naiyomaは、関心のある他の開発者からのフィードバックを求めており、
  ソリューション2をテストしている彼女の[PR][fing gh]を共有しています。

- **JITチャネルにおける公開Fraud Proof**: Thomas Voegtlinは、LSPの不正行為を示すために公開Fraud Proofを利用することで、
  [JIT（Just-In-Time）チャネル][topic jit channels]の背後にあるゲーム理論を改善する提案について
  Delving Bitcoinに[投稿しました][jit del]。

  アリスは、LSPであるボブとJITチャネルの開設を交渉します。アリスがキャロルからsatsを受け取る必要がある場合、
  アリスはプリイメージを作成します。キャロルはボブに[HTLC][topic htlc]を送信します。アリスはボブにプリイメージを開示し、
  LSPがチャネルのファンディングトランザクションをブロードキャストすることを期待します。
  ボブがアリスとのチャネルを開設することなくHTLCを請求した場合はどうなるでしょうか？

  Voegtlinは、チェーンをパブリックな調停レイヤーとして利用することを提案しています。
  アリスは`OP_RETURN`を使用してプリイメージを公開し、これにより誰もが開示内容を検証でき、
  特定のブロック高に日付を記録できるようにします。一方ボブは、`n`ブロックまで有効なUTXOコミットメントを作成します。
  もしボブが、コミットしたトランザクションとは異なるトランザクションで同じUTXOを使用したり、
  ファンディングトランザクションをブロードキャストしなかったり、二重使用を試みたりした場合、
  Fraud Proofが生成され、他のクライアントがアリスを信頼する必要なく、LSPとしてのボブの評判が損なわれることになります。

  Voegtlinは、詳細な説明を含む[論文][jit paper gist]も提供しており、
  他の開発者にこの提案のフィードバックを求めています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33796][]は、トランザクションの構造に対するコンテキストフリーなコンセンサスレベルのチェックを実行するための
  `btck_check_transaction()`を`libbitcoinkernel` C API（[ニュースレター #380][news380 kernel]参照）に追加します。
  これには、空のインプットのリストやアウトプットのリスト、不正なコインベースscriptSig長、
  重複したインプット、コインベース以外のトランザクションにおけるnull prevout、
  有効な範囲外のアウトプットの金額の拒否が含まれます。これらのチェックは、chainstate、
  UTXOセットまたはスクリプトの検証を必要としません。

- [Bitcoin Core #21283][]は、PSBTv0との後方互換性を維持しつつ、[BIP370][]
  [PSBTv2][topic psbt]サポートを実装します。PSBTv2は、完全な未署名トランザクションを必要とする代わりに、
  バージョン、ロックタイム、インプット、アウトプット、トランザクションの変更可能性といった
  トランザクション構築データをPSBTフィールドに直接格納します。

- [BIPs #2150][]は、[ダスト][topic uneconomical outputs]UTXOの処分プロトコル用の仕様である[BIP451][]を追加します。これは、
  ウォレットが不要なダストUTXOを単一のゼロ値の`OP_RETURN`アウトプットに使用することで
  安全に処分するための標準を定義しており、インプットの値すべてがトランザクション手数料として支払われます。
  このプロトコルには、承認済みダストUTXOをアドレス毎に処分するなどのプライバシー保護のための構築ルールや、
  mempool内で見つかった無関係なダスト処分トランザクションを[RBF][topic rbf]を介してバッチ処理できるようにする
  `ALL|ANYONECANPAY`署名が含まれています。

- [Eclair #3144][]は、[Simple Taproot Channels][topic simple taproot channels]を
  公式の機能ビットを使用するよう更新し、デフォルトで有効化します。ただし、
  これらのチャネルのアナウンスはまだサポートされていません。BOLT仕様およびLNDの実装（[ニュースレター
  #401][news401 lnd]参照）に揃えるため、テストベクトルが追加されています。

- [Eclair #2887][]は、Eclairの以前の実験的な[スプライシング][topic splicing]実装との後方互換性を維持しつつ、
  BOLT仕様にマージされた（[ニュースレター #398][news398 splicing]参照）公式のスプライシングプロトコルのサポートを追加します。

- [LDK #4592][]は、新しい[ゼロ手数料コミットメント][topic v3 commitments]（0FC）チャネルを開設する前に、
  ノードが十分な準備金を持っているかどうかをチェックするようになりました。これはそれらのチャネルを
  [アンカー][topic anchor outputs]チャネルとしてカウントすることで実現されます。
  これまで、LDKの準備金チェックは古い`anchors_zero_fee_htlc_tx`機能を使用するチャネルのみをカウントしていたため、
  ノードが同時強制閉鎖時にウォレットが安全に手数料を引き上げられる数を超えて0FCチャネルを開設できてしまっていました。

- [LND #9153][]は、ローカルノード以外の視点から経路を構築・デシリアライズするために、
  `Route` protoメッセージに`source_pub_key`フィールドを追加します。
  sourceが提供されていない場合、LNDは従来どおりローカルノードを使用します。

- [Rust Bitcoin #5835][]は、BitcoinのP2Pメッセージのヘッダーで使用される4 byteのペイロードチェックサムを計算する
  `V1MessageHeader`コンストラクタを追加します。これにより、
  呼び出し元はシリアライズされたペイロードとコマンドのヘッダーを構築してからネットワーク経由でメッセージを送信できるため、
  ネットワークメッセージの構築が簡素化されます。

- [BOLTs #995][]は、[Simple Taproot Channels][topic simple taproot channels]用の拡張BOLTが追加され、
  機能ビット80/81が割り当てられています。この仕様では、P2TRファンディングアウトプットと
  [MuSig2][topic musig]鍵集約、[Taproot][topic taproot]コミットメントおよびHTLCスクリプト、
  そしてチャネルの開設、コミットメントの更新、協調閉鎖、
  再接続時にMuSig2部分署名とナンスを交換するための新しいTLVフィールドを使用する、
  最小限のTaprootベースのチャネルタイプが定義されています。`revoke_and_ack`および
  `channel_reestablish`のナンスフィールドは、[スプライシング][topic splicing]時など
  複数のアクティブなコミットメントトランザクションをサポートするために、
  ファンディングtxidをキーとして使用します。この拡張機能は意図的にゴシップの変更を除外しているため、
  [アナウンスされるTaprootチャネル][topic channel announcements]は今後の課題となります。

- [BOLTs #1228][]では、[ゼロ手数料コミットメント][topic v3 commitments]（0FC）チャネルが規定され、
  機能ビット40/41が割り当てられています。このチャネルタイプでは、`feerate_per_kw`は0に設定され、
  コミットメントトランザクションと[HTLC][topic htlc]トランザクションは
  [v3トランザクションリレー][topic v3 transaction relay]（TRUC）を使用し、
  マイニング手数料は[CPFP][topic cpfp]を使用して子トランザクションによって支払われます。
  コミットメントトランザクションには、トリムされたアウトプットと切り捨てられたmillisatoshisから資金が拠出される
  共有の[P2A（pay-to-anchor）][topic ephemeral anchors]アウトプット（240 satsが上限）が含まれており、
  ほとんどの場合、親コミットメントトランザクションが直接手数料を支払う必要はありません。この仕様では、
  TRUCの10 kvBというトランザクションサイズ制限のため、このチャネルタイプにおけるHTLCの最大数を114に制限しています。

- [BOLTs #1327][]は、低手数料率において[BIP125][]置換ルールへの準拠を保証するため、
  [RBF][topic rbf]の手数料率の引き上げルールを更新します。既存の25/24倍の手数料率乗数のみを適用するのではなく、
  この仕様では、置換時の手数料率を、当該乗数または追加で25 sat/kwのいずれか大きい方の値だけ引き上げることが要求されるようになります。
  これは[ニュースレター #400][news400 rbf]で取り上げられたLDKの動作と一致します。

{% include snippets/recap-ad.md when="2026-05-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33796,21283,2150,3144,2887,4592,9153,5835,995,1228,1327" %}
[fing del]: https://delvingbitcoin.org/t/fingerprinting-nodes-possible-solutions/2466
[news360 fing]: /ja/newsletters/2025/06/27/#addr
[fing gh]: https://github.com/naiyoma/bitcoin/pull/16
[jit del]: https://delvingbitcoin.org/t/proposal-public-fraud-proofs-for-just-in-time-channels/2451
[jit paper gist]: https://gist.github.com/ecdsa/dfa2d76a5fe845fd283c01b5ed12d274
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news398 splicing]: /ja/newsletters/2026/03/27/#bolts-1160
[news400 rbf]: /ja/newsletters/2026/04/10/#ldk-4494
[news401 lnd]: /ja/newsletters/2026/04/17/#lnd-9985