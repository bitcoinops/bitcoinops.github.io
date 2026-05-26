---
title: 'Bitcoin Optech Newsletter #353'
permalink: /ja/newsletters/2025/05/09/
name: 2025-05-09-newsletter-ja
slug: 2025-05-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、最近発見された理論上のコンセンサス障害の脆弱性と、
BIP32ウォレットパスの再利用を回避するための提案のリンクを掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、新しいリリースおよびリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点など恒例のセクションも含まれています。

## ニュース

- **BIP30コンセンサス障害の脆弱性:** Ruben Somsenは、
  Bitcoin Coreからチェックポイントが削除された（[ニュースレター #346][news346 checkpoints]参照）ことで
  発生する可能性がある理論上のコンセンサス障害についてBitcoin-Devメーリングリストに[投稿しました][somsen bip30]。
  簡単に言うと、ブロック91722と91812のコインベーストランザクションが、
  ブロック91880と91842で[重複][topic duplicate transactions]している点です。[BIP30][]では、これらの2つのブロックは、
  2010年のBitcoin Coreの旧バージョンで処理された方法、
  つまりUTXOセット内で前のコインベースエントリーを重複する後続のエントリーで上書きする方法で処理するよう規定しています。
  しかし、Somsenは、後続ブロックのいずれか、または両方が再編成されると、
  重複エントリーがUTXOセットから削除され、上書きにより以前のエントリーも失われてしまうと指摘しています。
  しかし、重複トランザクションを一度も確認したことのない新規ノードは、
  以前のトランザクションを保持した状態で異なるUTXOセットを作成し、
  いずれかのトランザクションが使用された場合にコンセンサス障害につながる可能性があります。

  Bitcoin Coreにチェックポイントがあった頃は、上記の4つのブロックがすべてベストブロックチェーンの一部である必要があったため、
  これは問題になりませんでした。現在は、BitcoinのProof of Workのセキュリティメカニズムが理論上破綻しない限り、
  実際には問題にはなりません。これらの2つの例外に対して、追加の特殊ケースロジックをハードコードするなど、
  いくつかの解決策が議論されています。

- **BIP32パスの再利用の回避:** Kevin Loaecは、
  同じ[BIP32][topic bip32]ウォレットパスが異なるウォレットで使われるのを防ぐ方法について
  Delving Bitcoinに[投稿しました][loaec bip32reuse]。
  これは、[アウトプットのリンク][topic output linking]によるプライバシーの損失や、
  （[量子コンピューター][topic quantum resistance]などによる）理論的なセキュリティの損失につながる可能性があります。
  彼は、ランダムパスの使用、ウォレットの誕生日に基づくパスの使用、
  インクリメントカウンターに基づくパスの使用という3つのアプローチを提案し、
  誕生日ベースのアプローチを推奨しました。

  また、[ディスクリプター][topic descriptors]ウォレット、特にマルチシグや複雑なスクリプトの普及に伴い、
  [BIP48][]のパス要素のほとんどを不要として削除することを推奨しました。
  しかし、Salvatore Ingalaは、一部のハードウェア署名デバイスによって強制されているように、
  異なる暗号通貨で使用される鍵が分離された状態を保つのに役立つため、
  BIP48のパスの _coin type_ 部分は維持するよう[提案しました][ingala bip48]。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Add bitcoin wrapper executable][review club 31375]は、
[ryanofsky][gh ryanofsky]によるPRで、さまざまなBitcoin Coreバイナリを検出して起動するのに
使える新しい`bitcoin`バイナリを導入します。

Bitcoin Core v29は7つのバイナリ（`bitcoind`、`bitcoin-qt`、`bitcoin-cli`など）と一緒にリリースされましたが、
将来[マルチプロセス][multiprocess design]バイナリもリリースされると、
その数は[増えていきます][Bitcoin Core #30983]。新しい`bitcoin`ラッパーは、
コマンド（`gui`など）を正しいモノリシック（`bitcoin-qt`）またはマルチプロセス（`bitcoin-gui`）バイナリにマッピングします。
検出機能に加えて、ラッパーはユーザーインターフェースを変更することなくバイナリを再編成できるように前方互換性も提供します。

このPRにより、ユーザーは`bitcoin daemon`または`bitcoin gui`でBitcoin Coreを起動できます。
`bitcoind`や`bitcoin-qt`で直接起動することも引き続き可能で、このPRによる影響はありません。

{% include functions/details-list.md
  q0="Issue #30983では、4つのパッケージ戦略がリストアップされています。
  このPRは「サイドバイナリ」アプローチの具体的な欠点のうち、どのような点に対処しているのでしょうか？"
  a0="このPRで想定されているサイドバイナリアプローチでは、
  新しいマルチプロセスバイナリを既存のモノリシックバイナリと並行してリリースします。
  多数のバイナリがあると、ユーザーは自分の目的のバイナリを見つけて理解するのが難しくなります。
  このPRは、オプションの概要とヘルプ文言を含む単一のエントリーポイントを提供することで、
  こうした混乱を大幅に軽減します。あるレビュアーは、これをさらに簡単にするためにあいまい検索の追加を提案しました。"
  a0link="https://bitcoincore.reviews/31375#l-40"
  q1="`GetExePath()`は、Linuxではより直接的な方法であるにもかかわらず、
  `readlink(\"/proc/self/exe\")`を使用しません。現在の実装にはどんな利点があるのでしょうか？
  どのようなエッジケースが見落とされる可能性があるのでしょうか？"
  a1="procファイルシステムを持たない他の非Windowsプラットフォームが存在する可能性があります。
  それ以外に、作者もゲストもprocfsを使用することの欠点は特定できませんでした。"
  a1link="https://bitcoincore.reviews/31375#l-71"
  q2="`ExecCommand`における`fallback_os_search`ブール値の目的を説明してください。
  OSが`PATH`上のバイナリを検索させないほうが良い状況はどのような場合ですか？"
  a2="ラッパー実行ファイルが検索（例：\"bitcoin\"）ではなくパス（例：\"/build/bin/bitcoin\"）で呼び出されるように見える場合、
  ユーザーがローカルビルドを使用していると想定され、`fallback_os_search`には`false`がセットされます。
  たとえば、ユーザーが`gui`をローカルでビルドしていない場合、
  `/build/bin/bitcoin gui`はシステムインストールされた`bitcoin-gui`にフォールバックするべきではありません。
  作者は、`PATH`検索を完全に削除することを検討しており、ユーザーからのフィードバックが役立つでしょう。"
  a2link="https://bitcoincore.reviews/31375#l-75"
  q3="ラッパーは、インストールされた`bin/`ディレクトリから実行されていることを検知した場合のみ、
  `${prefix}/libexec`を検索します。なぜ、常に`libexec`を検索しないのでしょうか？"
  a3="ラッパーは、実行しようとするパスについて保守的であるべきで、
  標準の`PREFIX/{bin,libexec}`レイアウトを推奨すべきです。
  パッケージの作成者が非標準のレイアウトを作成したり、
  予期しない方法で配置されたバイナリで動作したりすることを推奨すべきではありません。"
  a3link="https://bitcoincore.reviews/31375#l-75"
  q4="PRでは、ラッパーにFORTIFYが有効になった`glibc`呼び出しが含まれていないため、
  `security-check.py`に例外を追加しています。なぜそれらが含まれていないのでしょうか。
  また、`bitcoin.cpp`に単純な`printf`を追加すると、現在のルールでは再現可能なビルドが機能しなくなるのでしょうか？"
  a4="ラッパーバイナリは非常に単純なため、FORTIFYが有効になった呼び出しは含まれていません。
  将来的にそのような呼び出しが含まれるようになった場合は、`security-check.py`の例外を削除できます。"
  a4link="https://bitcoincore.reviews/31375#l-117"
%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.19.0-beta.rc4][]は、この人気のLNノードのリリース候補です。
  おそらくテストが必要な主な改善の1つは、協調クローズにおける新しいRBFベースの手数料引き上げです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Core Lightning #8227][]は、[BLIP50][]で定義されているように（ニュースレター [#335][news335 blip50]参照）、
  [BOLT8][]ピアツーピアメッセージ上でJSON-RPC形式を用いて、
  LSPノードとそのクライアント間の通信プロトコルを実装するRustベースの
  `lsps-client`および`lsps-service`プラグインを追加します。これは、
  [BLIP51][]で定義されている流動性リクエストの受信と
  [BLIP52][]で定義されている[JITチャネル][topic jit channels]の実装の基盤となります。

- [Core Lightning #8162][]は、ピアによって開始された保留中のチャネル開設の処理を更新し、
  最新100件まで無期限に保持するようにしました。これまでは、未承認のチャネル開設は2016ブロック後に消去されていました。
  さらに、ノードがピアの`channel_reestablish`メッセージに応答できるように、
  閉じられたチャネルはメモリに保持されるようになりました。

- [Core Lightning #8166][]は、`wait` RPCコマンドを強化し、
  単一の`details`オブジェクトをサブシステム別のオブジェクト
  `invoices`、`forwards`、`sendpays`および[`htlcs`][topic htlc]に置き換えました。
  さらに、`listhtlcs` RPCは現在、新しい`created_index`と`updated_index`フィールドおよび、
  `index`、`start`、`end`パラメーターによるページネーションをサポートします。

- [Core Lightning #8237][]は、`listpeerchannels` RPCコマンドに
  `short_channel_id`パラメーターを追加し、提供された場合に指定されたチャネルのみを返します。

- [LDK #3700][]は、[HTLC][topic htlc]が失敗した理由と、
  原因がローカルか下流かについての追加情報を提供するために`HTLCHandlingFailed`イベントに
  新しい`failure_reason`フィールドを追加します。`failed_next_destination`フィールドは、
  `failure_type`に名前が変更され、`UnknownNextHop`バリアントは非推奨となり、
  より汎用的な`InvalidForward`に置き換えられました。

- [Rust Bitcoin #4387][]は、[BIP32][topic bip32]のエラー処理をリファクタリングし、
  単一の`bip32::Error`を、導出、子番号/パスのパース、拡張鍵のパース毎に別々の列挙型に置き換えました。
  このPRでは、256階層を超えるパスに対して、新しく`DerivationError::MaximumDepthExceeded`バリアントも導入されています。
  これらのAPIの変更により後方互換性が損なわれます。

- [BIPs #1835][]は、[BIP48][]（ニュースレター [#135][news135 bip48]参照）を更新し、
  m/48'プレフィックスを持つ決定論的マルチシグウォレットにおいて、
  既存のP2SH-P2WSH (1′)およびP2WSH (2′)スクリプトタイプに加えて、
  [Taproot][topic taproot] (P2TR)導出用のスクリプトタイプ値3を予約しました。

- [BIPs #1800][]は、Bitcoinプロトコルに長年存在していた複数の脆弱性を修正するための
  [コンセンサスクリーンアップソフトフォーク][topic consensus cleanup]提案を定義した
  [BIP54][]をマージしました。このBIPの詳細については、ニュースレター[#348][news348 cleanup]をご覧ください。

- [BOLTs #1245][]は、インボイスにおける非最小長エンコーディングを禁止することで
  [BOLT11][]を厳格化します。有効期限（x）、最終ホップの[CLTV有効期限delta][topic cltv
  expiry delta]（c）および機能ビット（9）の各フィールドは、
  先頭にゼロを付けずに最小の長さでシリアライズする必要があり、
  読み取り側は先頭にゼロを含むインボイスを拒否する必要があります。
  この変更は、LDKが最小長以外のインボイスを最小長に再シリアライズ（余分なゼロを削除）すると、
  インボイスのECDSA署名が署名の検証に失敗するというファジングテストの結果に基づいています。

{% include snippets/recap-ad.md when="2025-05-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8227,8162,8166,8237,3700,4387,1835,1800,1245,30983,50,51,52" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[somsen bip30]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjZTWhgzzdps3vb0YoU3EYJwThDFhNLkf4XmmdfhbORTaw@mail.gmail.com/
[loaec bip32reuse]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644
[ingala bip48]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644/3
[news346 checkpoints]: /ja/newsletters/2025/03/21/#bitcoin-core-31649
[news335 blip50]: /ja/newsletters/2025/01/03/#blips-52
[news135 bip48]: /ja/newsletters/2021/07/28/#bips-1072
[news348 cleanup]: /ja/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup-bip
[review club 31375]: https://bitcoincore.reviews/31375
[gh ryanofsky]: https://github.com/ryanofsky
[multiprocess design]: https://github.com/bitcoin/bitcoin/blob/master/doc/design/multiprocess.md
