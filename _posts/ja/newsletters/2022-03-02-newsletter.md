---
title: 'Bitcoin Optech Newsletter #189'
permalink: /ja/newsletters/2022/03/02/
name: 2022-03-02-newsletter-ja
slug: 2022-03-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しい`OP_EVICT` opcodeの提案と、新しいリリースとリリース候補の概要や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更などの恒例のセクションを掲載しています。

## ニュース

- **UTXOの所有権の共有を簡素化するopcodeの提案:** 開発者であるZmnSCPxjは、
  [以前提案された][news166 tluv]`OP_TAPLEAF_UPDATE_VERIFY` (TLUV) opcodeに代わる`OP_EVICT` opcodeの提案を
  Bitcoin-Devメーリングリストに[投稿しました][zmnscpxj op_evict]。
  TLUVと同様に、`OP_EVICT`は、2人以上のユーザーが1つのUTXOの所有権を共有するユースケース（
  [Joinpool][topic joinpools]や、[Channel Factories][topic channel factories]、特定の[Covenants][topic covenants]など）に
  焦点を当てています。`OP_EVICT`がどのように機能するか理解するために、
  1つのUTXOを4人（Alice、Bob、Carol、Dan）で制御するJoinpoolを想像してみてください。

  現在、これらの4人のユーザーは、全員が署名の作成に参加している場合に、
  [MuSig2][topic musig]などのプロトコルを使用してアウトプットを効率的に使用できる、
  keypathで使用可能なP2TR（Taproot）アウトプットを作成することができます。
  しかしユーザーの1人であるDanが参加できなくなったり悪意あるユーザーである場合、
  AliceとBob、CarolがJoinpoolの残額についてプライバシーと効率の利点を維持する唯一の方法は、
  事前にDanと署名済みのトランザクションツリーを用意しておくことです。
  使用する際にすべては必要ありませんが、完全な障害耐性を確保するためには、そのすべてが使用可能な状態である必要があります。

  {:.center}
  [![Illustration of combinatorial blowup when using presigned
  transactions to ensure trustless withdrawal from a
  joinpool](/img/posts/2022-03-combinatorial-txes.dot.png)](/img/posts/2022-03-combinatorial-txes.dot.png)

  UTXOを共有するユーザーの数が増加すると、作成する必要がある署名済みトランザクションの数が組み合わせで増加し、
  準備がとてもスケーラブルでなくなります（わずか10人のユーザーでも、100万以上のトランザクションに事前署名する必要があります）。
  TLUVや[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]などの提案された他のopcodeは、
  組み合わせの爆発を解消することができます。
  `OP_EVICT`は同じことを実現しますが、ZmnSCPxjは、
  共有されたUTXOの所有権グループのメンバーを削除する際に使用するオンチェーンデータが少ないため、
  （このユースケースでは）それらのopcodeより優れたオプションになる可能性があることを示唆しています。

  `OP_EVICT`がソフトフォークで追加された場合、グループの各メンバーは他のメンバーと、
  公開鍵と一緒に各メンバーに割り当てた金額（例えばAliceに1 BTC、Bobには2 BTCなど）を支払うアウトプットに対してその公開鍵の署名を共有します。
  各メンバーは、他のすべてのメンバーの公開鍵と署名を手に入れると、
  以下の2つの異なる方法のいずれかで資金を使用することができるアドレスをトラストレスに構築することができます:

  1. 上記のようにTaprootのkeypathによる支払いを使用
  2. `OP_EVICT` opcodeを使用した[Tapscript][topic tapscript]のscriptpathによる支払いを使用

  <br>Danを排除する場合、このopcodeは以下のパラメーターを受け取ります:

  - **<!--shared-pubkey-->共有公開鍵:**  グループ全体の共有公開鍵で、テンプレートへの1バイトの参照を使用して効率的に提供できます。

  - **<!--number-of-evictions-->Eviction数:** Joinpoolを抜けるアウトプットの数（今回の例では1）

  - **<!--eviction-outputs-->Evictionアウトプット:** 今回の例ではDanのアウトプット1つで、データはそのインデックスの位置とDanの署名を提供します。
    Danの公開鍵は彼が署名したアウトプットで使用されたものと同じ鍵になります。

  - **<!--unevicted-signature-->未排除の署名:**
    グループ全体からEvictionアウトプットで使用される公開鍵を差し引いた公開鍵に対応する署名。
    言い換えると、グループの残りのメンバー（この例ではAliceとBobとCarol）の署名です。

  これにより、Alice、Bob、Carolは、Danが以前署名したアウトプットを持つトランザクションを作成し、
  そのアウトプットに対するDanの署名と、AliceとBobおよびCarolが
  （手数料をカバーし、残りの資金を彼らが選んだ方法で割り当てた）支払いトランザクション全体に対して
  動的に作成した署名を提供することで、Danの協力なしにいつでもグループのUTXOを使用することができるようになります。

  この記事を書いている時点で、`OP_EVICT`はメーリングリスト上で適度な議論を受けましたが、
  大きな懸念はなく、昨年のTLUVの提案とほぼ同じような熱の入りようでした。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.4.6][]は、このペイメントプロセッサソフトウェアの最新リリースです。
  前回Optechが取り上げたリリース以降、[CPFP][topic cpfp]による手数料の引き上げのサポートや、
  LN URLの追加機能の利用に加えて、複数のUIの改善が行われました。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [HWI #550][]は、Ledgerハードウェア署名デバイス用の最新のロード可能なBitcoinファームウェアのサポートを追加しました。
  これは、バージョン2の[PSBT][topic psbt]と[Output Script Descriptor][topic descriptors]のサブセットをネイティブでサポートします。

{% include references.md %}
{% include linkers/issues.md v=1 issues="550" %}
[btcpay server 1.4.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.6
[zmnscpxj op_evict]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019926.html
[news166 tluv]: /ja/newsletters/2021/09/15/#covenant-opcode-proposal-covenant-opcode
