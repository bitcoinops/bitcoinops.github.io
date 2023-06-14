---
title: 'Bitcoin Optech Newsletter #131'
permalink: /ja/newsletters/2021/01/13/
name: 2021-01-13-newsletter-ja
slug: 2021-01-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しく提案されたBitconのP2Pプロトコルメッセージ、
変更されたbech32アドレスフォーマットのBIPおよび提案されたデュアルファンドLNチャネルにおけるUTXOプロービングを防止するアイディアについて説明します。
また、Bitcoin Core PR Review Clubのミーティングや、リリースおよびリリース候補のリスト、
人気のあるBitcoinのインフラストラクチャソフトウェアの注目すべき変更の解説を含む定期的なセクションも含まれています。

## ニュース

- **`disabletx`メッセージの提案** 2012年に[BIP37][]が公開され、軽量クライアントは、
  クライアントが[bloom filter][topic transaction bloom filtering]をロードするまで、
  未承認トランザクションをクライアントにリレーしないようピアに要求できるようになりました。
  Bitcoin Coreは[その後][bitcoin core #6993]このメカニズムを帯域幅を削減する`-blocksonly`モードに再利用しました。
  このモードでは、ノードは自身のピアに未承認のトランザクションを送信しないよう要求します。
  昨年、デフォルト設定のBitcoin Coreは、帯域幅を大幅に増加させたり、プライバシーを低下させたりすることなく、
  [エクリプス攻撃][topic eclipse attacks]に対する耐性を向上させる効率的な方法として、
  2つのblock-relay-only接続を開くようになりました（[Newsletter #63][news63 bcc15759]参照）。
  しかし、トランザクションリレーを抑制するために使用されているBIP37のメカニズムは、
  開始ノードがいつでも完全なトランザクションリレーを要求することが可能です。
  トランザクションリレーはメモリや帯域幅などのリソースを消費するため、
  ノードはBIP37ベースの低帯域幅のblocks-relay-only接続が突然フルトランザクションリレー接続になる可能性を想定して
  接続制限を設定する必要があります。

    今週、Suhas Daftuarは、接続のネゴシエーション中に送信される可能性のある新しい`disabletx`メッセージの提案を
    Bitcoin-Devメーリングリストに[投稿しました][daftuar disabletx]。このメッセージを理解し、BIPの推奨事項をすべて実装したピアは、
    `disabletx`を要求するノードにトランザクションの通知を送信せず、ノードにトランザクションを要求しません。
    `disabletx`のネゴシエーションは接続が有効な期間持続するため、現在の最大接続数125を超える追加の接続を受け入れるなど、
    無効化されたリレー接続に異なる制限を使用することができます。

- **Bech32m** Pieter Wuilleは、Bitcoin-Devメーリングリストに[bech32][topic bech32]アドレスエンコーディングの
  修正バージョンの[BIPドラフト][bech32m bip]を[投稿しました][wuille bech32m post]。
  修正バージョンでは*bech32m*アドレス内に誤って文字が追加されたり削除されたりした場合に、それが検出される可能性が高くなります。
  この提案に問題がない場合、bech32mアドレスが[taproot][topic taproot]アドレスや将来の新しいスクリプトのアップグレードに使用されることが期待されます。
  bech32mアドレスへの支払いをサポートするウォレットやサービスの実装は、自動的に将来のすべての改善の支払いをサポートします
  （詳細については[Newsletter #45][news45 bech32 upgrade]を参照）。

- **LNデュアルファンディングにおけるUTXOプルービング対策:** LNの長期的な目標は、デュアルファンディングで、
  チャネルを開始したノードとそのリクエストを受信したピアの両方からの資金でチャネルを開くことができます。
  これによりチャネルが完全にオープンした瞬間から、どちらの方向にも支払いができるようになります。
  開設者がデュアルファンディングトランザクションに署名する前に、相手側がトランザクションに追加したいすべてのUTXOのID（OutPoint）を提供する必要があります。
  このため、悪用者は多数の異なるユーザーとデュアル・ファンドチャネルを開始し、彼らのUTXOについて学習した上で、
  ファンディングトランザクションへの署名を拒否することができ、悪用者のコスト負担なくこれらのユーザーのプライバシーが損なわれるというリスクが生じます。

    今週、Lloyd Fournierは、この問題に対処するための２つの以前の提案の評価をLightning-Devメーリングリストに[投稿しました][fournier podle]。
    [１つは][zmn podle]離散対数の等価性の証明(PoDLEs、[Newsletter #83][news83 podle]参照)を使用し、
    [もう１つは][darosior sighash]`SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`を使って半署名されたデュアルファンディングトランザクションを使用します。
    Fournierは以前の半署名された提案を拡張し、それと同等の効果のあるよりシンプルな彼独自の提案を提供しました。
    新しい提案では、開設者は自分のUTXOを自身に戻すトランザクション（グッド・フェイス）を作成し、署名します（ブロードキャストはしません）。
    そしてこのトランザクションを誠実さの証として相手に渡します。開設者が後になって実際のファンディングトランザクションに署名しなかった場合、
    相手はグッド・フェイストランザクションをブロードキャストして、開設者にオンチェーン手数料を負担させることができます。
    Fournierは、異なるアプローチ間のトレードオフをまとめて投稿を締めくくっています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングの回答の要約を確認してください。*

[ノードの排除ロジックの単体テストの追加][review club #20477] は、仮名の貢献者practicalswiftによる、
ノードのインバウンド接続スロットが一杯になった時のBitcoin Coreのピア排除ロジックのテストカバレッジを向上させるためのPR
([#20477][Bitcoin Core #20477]) です。このロジックを使用して、
攻撃者がトリガーするネットワーク分断にノードをさらさないよう注意する必要があります。

議論のほとんどはBitcoin Coreのピア排除ロジックの理解に焦点を当てています。

{% include functions/details-list.md
  q0="<!--q0-->インバウンドとアウトバウンドピアの選択: エクリプス攻撃に対する我々の主な防御はどっちですか？"
  a0="アウトバウンドピアの選択です。攻撃者は、我々が受け入れるインバウンド接続よりも我々が選択するアウトバウンドピアに与える影響が少ないためです。
      インバウンドピアの排除は2次保護で、すべてのノードがインバウンド接続を許可する訳ではありません。"
  a0link="https://bitcoincore.reviews/20477#l-77"

  q1="<!--q1-->なぜBitcoin　Coreはインバウンド接続を排除するんですか?"
  a1="ネットワーク内の正直なピアがインバウンドスロットを利用できるようにすることで、新しいノードがそれらへの良好なアウトバウンド接続を
      確立できるようにします。そうしないと、不正なノードは新しいノードにアウトバウンド接続を利用できるようにし、
      できるだけ多くのインバウンド接続を占有することで、より簡単に新しいノードを攻撃できるようになります。"
  a1link="https://bitcoincore.reviews/20477#l-66"

  q2="<!--q2-->スロットを解放する必要がある場合、Bitcoin Coreはどのインバウンドピアを排除するかどうやって決定するんですか？"
  a2="最大28のピアは、低遅延、ネットワークグループ、新しい有効なトランザクションやブロックの提供、
      その他いくつかの偽造が困難な基準に基づいて排除から保護されています。
      一部のオニオンピアを含め、最も長く接続されている残りの半分が保護され、残っているものの内、
      接続数が最も多いネットワークグループの最年少メンバーが切断対象として選択されます。
      攻撃者がノードを分断するためには、これらの特性のすべてにおいて、正直なピアよりも優れている必要があります。"
  a2link="https://bitcoincore.reviews/20477#l-83"
%}

## リリーとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0]はこのフルノード実装の次のメジャーバージョンと
  それに関連するウォレットと他のソフトウェアのリリース候補（RC）です。
  Jarol Rodriguezはリリースの主な変更点を説明し、テストを支援する方法を提案する[RC testing guide][]を作成しました。

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta]はこのLNノードの次のメージャーバージョンの最新のリリース候補です。
  このリリースでは[anchor output][topic anchor outputs]をコミットメントトランザクションのデフォルトとし、
  そのサポートを[watchtower][topic watchtowers]の実装に追加し、コストを削減し安全性を向上させています。
  このリリースでは、[PSBT][topic psbt]の作成と署名のための一般的なサポートも追加され、いくつかのBug Fixが含まれています。

{% comment %}<!--
- Bitcoin Core 0.20.2rc1 および 0.19.2rc1 はこのニュースレターの公開後、
  いつかの時点でare expected to be[利用可能][bitcoincore.org/bin]になる予定です。
  [Newsletter #110][news110 bcc19620]で説明されている改善などいくつかのBug Fixが含まれており、
  理解できない将来のtaprootトランザクションの再ダウンロードを防ぎます。
-->{% endcomment %}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、
[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #18077][]は、一般的な自動ポートフォワードプロトコル[NAT-PMP][rfc 6886]
  (Network Address Translation Port Mapping Protocol)のサポートを導入しています。
  `-natpmp`設定パラメータを付けて起動されたBitcoin clientは、NAT-PMP対応ルーターのリスニングポートを自動的に開きます。
  NAT-PMPのサポートは、複数のセキュリティ問題によりBitcoin Core 0.11.1以降無効化されていた既存のUPnP (Universal Plug and Play)の
  サポートと並行して追加されています。UPnPとは対照的に、NAT-PMPはXML解析の代わりに固定サイズのUDPパケットを使用するため、
  [リスクが少ない][laanwj natpmp]と考えられています。この変更により、NAT-PMPの後方互換性がある後継である
  [PCP][rfc 6887] (Port Control Protocol)のサポートが追加されます。

- [Bitcoin Core #19055][]は、今後のPRで予定されている機能に使用できるよう[MuHashアルゴリズム][muhash algorithm]を追加しています。
  [newsletter 123][muhash review club]で取り上げたように、MuHashはローリングハッシュアルゴリズムで、
  オブジェクトのセットのハッシュダイジェストを計算し、アイテムが追加・削除された際に効率的に更新することが可能です。
  これは、[2017年にPieter Wuilleによって][muhash mailing list]提案され、[Bitcoin Core #10434][]で実装された
  全UTXOセットのダイジェストを計算するためにMuHashを使用するというアイディアを復活させるものです。
  UTXOセットの統計用のインデックス作成の進捗を追跡し、[assumeUTXO][topic assumeutxo]アーカイブの検証を容易にすることに興味がある人のために、
  メタPR[Bitcoin Core #18000][]にプロジェクトの進捗と今後の手順が記載されています。

- [C-Lightning #4320][]では、`invoice`RPCに`cltv`パラメーターが追加され、ユーザーやプラグインが
  インボイスの`min_final_cltv_expiry`フィールドを設定できるようになりました。

- [C-Lightning #4303][]では、`hsmtool`が標準入力（stdin）でパスフレーズを取得し、
  コマンドラインで指定されたパスフレーズを無視するよう更新されています。

{% include references.md %}
{% include linkers/issues.md issues="18077,19055,4320,4303,6993,20477,18000,10434" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc5
[news63 bcc15759]: /en/newsletters/2019/09/11/#bitcoin-core-15759
[daftuar disabletx]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018340.html
[rfc 6886]: https://tools.ietf.org/html/rfc6886
[rfc 6887]: https://tools.ietf.org/html/rfc6887
[laanwj natpmp]: https://github.com/bitcoin/bitcoin/issues/11902#issue-282227529
[wuille bech32m post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018338.html
[bech32m bip]: https://github.com/sipa/bips/blob/bip-bech32m/bip-bech32m.mediawiki
[news83 podle]: /ja/newsletters/2020/02/05/#podle
[zmn podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002476.html
[darosior sighash]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002475.html
[fournier podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-January/002929.html
[news45 bech32 upgrade]: /en/bech32-sending-support/#automatic-bech32-support-for-future-soft-forks
[rc testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/0.21-Release-Candidate-Testing-Guide
[muhash review club]: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club
[muhash mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash algorithm]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
