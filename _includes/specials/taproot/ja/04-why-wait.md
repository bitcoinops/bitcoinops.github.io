{% capture /dev/null %}

<!-- Tested the following on regtest:
  - according to getblockchaininfo, taproot becomes active at min_lockin_height
  - a tx with nlocktime x can't be sent at height x-1 and can be sent at height x

Not tested:
  - Actually spending a P2TR tx at min_lockin_height
-->

<!-- last block before taproot rules enforced -->
{% assign ante_trb = "709,631" %}

<!-- Conservatively reorg safe block after activation (+144 blocks) -->
{% assign safe_trb = "709,776" %}
{% endcapture %}

これまでの連載では、ウォレットやサービスの開発者に対して[Taproot][topic taproot]がアクティベートされた時に備えて、
Taprootのアップグレードを今から実装するよう呼びかけてきました。
しかし、サービスやユーザーが損失を被る可能性があるため、
ブロック{{site.trb}}より前にP2TR用のアドレスを生成しないよう警告しました。

事前にアドレスを生成しない理由は、P2TRスタイルのアウトプットへの支払いは、
ブロック{{site.trb}}より前では*誰でも*使用できるためです。
お金は完全に安全ではなくなります。
しかし、そのブロックになると何千ものフルノードが[BIP341][]および[BIP342][]
（そして関連する[BIP340][]）のルールの適用を開始します。

ブロックチェーンの再編成がないことが保証されているのであれば、
最後のTaproot前のブロック（ブロック{{ante_trb}}）が確認できた時点でP2TRアドレスの生成を始めても安全でしょう。
しかし、ブロックチェーンの再編成については懸念すべき理由があります。
偶然の再編成だけでなく、初期のP2TR支払いからお金を奪うために意図的に作られる再編成もあるためです。

P2TRの支払いを最初に受け取ろうとする大勢の人々を想像してみてください。
ブロック{{ante_trb}}が確認できるとすぐに彼らは単純にいくらかのお金を送信します。[^timelocked-trb]
これらの支払いは、ブロック{{site.trb}}では安全ですが、
ブロック{{ante_trb}}に代わるブロックを作成したマイナーによって盗まれる可能性があります。
P2TRアウトプットへ送られるお金の価値が十分に大きければ、
1つのブロックではなく2つのブロックをマイニングしようとする方が簡単に利益を得られる可能性があります
（詳細はトピック[フィー・スナイピング][topic fee sniping]を参照）。

この理由から、再編成のリスクが効果的に解消されたと思われるまでは、
ソフトウェアやサービスでP2TR用のアドレスを生成することはお勧めしません。
アクティベーションから144ブロック（約1日）待つことは、
あなたやあなたのユーザーがTaprootの利点を利用するのを大幅に遅らせることなく、
リスクを最小限に抑えることができる、適度に保守的なマージンだと考えています。

まとめると:

- {{ante_trb}}: P2TRスタイルのアウトプットに送信されたお金を誰でも使うことができる最後のブロック
- {{site.trb}}: P2TRアウトプットが[BIP341][]と[BIP342][]のルールを満たす場合にのみ使用できる最初のブロック
- {{safe_trb}}: ウォレットがユーザーにP2TRアウトプット用の[bech32m][topic bech32]受信アドレスを提供し始めるのに適したブロック

上記はいずれも、できるだけ早くbech32mアドレスへの支払いを可能にするという、
このシリーズの[最初のパート][taproot series 1]で提供されたアドバイスを変更するものではありません。
安全だと思う前にP2TR用のアドレスを要求した場合、それは彼らのリスクです。

[^timelocked-trb]:
    最初のTaprootブロックでP2TR支払いを受けたいユーザーは、
    誰にも教えずにアドレスを生成し、そのアドレス宛にnLockTimeを{{ante_trb}}に設定したトランザクションを作成してください。
    このトランザクションは、ブロック{{ante_trb}}を受信するとすぐにブロードキャストできます。
    nLockTimeは、そのトランザクションがTaprootのルールが提供される{{site.trb}}より前のブロックに含まれないことを保証します。
    新しいスクリプトタイプやカスタムlocktimeに手を出すのは、
    それが何をしているのか分からない場合には危険なので気をつけてください。

[news139 st]: /ja/newsletters/2021/03/10/#taproot-activation-discussion
[taproot series 1]: /ja/preparing-for-taproot/#bech32m送信のサポート
