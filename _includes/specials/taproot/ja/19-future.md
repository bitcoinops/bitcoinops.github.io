{% auto_anchor %}

ブロック{{site.trb}}でのTaprootのアクティベーションが近づくにつれ、
開発者がTaproot上に構築したいと以前から表明していたコンセンサスのいくつかの変更を楽しみにするようになりました。

- **<!--cross-input-signature-aggregation-->インプットをまたいだ署名の集約:**
  [Schnorr署名][topic schnorr signatures]は、複数の異なる公開鍵と秘密鍵のペアの所有者が、
  協力して署名を作成したことを証明する単一の署名を簡単に作成することができます。

    将来のコンセンサスの変更により、
    トランザクションで使用されているすべてのUTXOの所有者がその支払いを承認したことを証明する
    単一の署名をトランザクションに含めることができるようになる可能性があります。
    これにより、最初のインプットの後は、keypathでの支払い毎に約16 vbyteが節約され、
    統合や[CoinJoin][topic coinjoin]での大幅な節約につながります。
    これにより、CoinJoinベースによる支払いの方が、自分単独の支払いよりも安くなり、
    より多くのプライベートな支払いを行う緩やかなインセンティブを提供します。

- **SIGHASH_ANYPREVOUT:** 通常のBitcoinのトランザクションには、1つ以上のインプットが含まれており、
  そのインプットのそれぞれがtxidを使って以前のトランザクションアウトプットを参照しています。
  この参照により、Bitcoin Coreのような完全な検証ノードに、トランザクションがどれだけの金額を使用できるか、
  またその支払いが許可されたことを証明するためにどんな条件を満たす必要があるかが伝えられます。
  Bitcoinトランザクションの署名を生成するすべての方法は、Taprootを使用する場合も使用しない場合も、
  prevoutのtxidにコミットするか、prevoutにまったくコミットしないかのいずれかです。

    これは事前に準備された正確な一連のトランザクションを使用したくないマルチユーザー・プロトコルにとって問題となります。
    ユーザーが特定のトランザクションをスキップしたり、witnessデータ以外のトランザクションの詳細を変更したりすると、
    後続のトランザクションのtxidが変更されます。
    txidを変更すると後続のトランザクション用に事前に作成されていた署名が無効になります。
    これによりオフチェーンプロトコルは古いトランザクションを送信したユーザーにペナルティを与える
    （LN-penaltyなど）を実装しなければなりません。

    [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]は、
    署名がprevout txidへのコミットをスキップすることを許可することで、
    この問題を解消することができます。使用される他のフラグによっては、
    prevoutやトランザクションに関する他の詳細（金額やScriptなど）にコミットしますが、
    以前のトランザクションで使用されていたtxidは関係なくなります。
    これにより、LNの[eltoo][topic eltoo]レイヤーの実装や、
    [Vault][topic vaults]や他のコントラクトプロトコルの[改善][p4tr vaults]の両方が可能になります。

- **<!--delegation-and-generalization-->委譲と一般化:**
  （Taprootまたはそれ以外の）Scriptを作成した後は、
  秘密鍵を渡さない限り、そのScriptから支払いをする能力を他の人に委譲する方法は[ほぼ][rubin delegation]ありません
  （[BIP32][]ウォレットを使っている場合は[とても危険です][bip32 reverse derivation]）。
  さらにTaprootは、keypathによる支払いや少数のScriptベースの条件のみを使用したいユーザーにとって、
  より手軽な価格を提供します。Taprootを一般化し、[署名者の委譲][topic signer delegation]を行うことで、
  Taprootを強化する方法がいくつか提案されています:

    - **Graftroot:** Taprootのアイディアが紹介された直後に[提案された][maxwell graftroot]Graftrootは、
      誰もがTaprootのkeypath支払いをできるようにする追加機能を与えるものです。
      keypathの署名者は資金を直接使用する代わりに、資金を使用できる新しい条件を記述したScriptに署名し、
      そのScriptの条件を満たすことができる人に使用権限を委譲することができます。
      署名およびScript、そのScriptを満たすために必要なデータが、支払いトランザクションで提供されます。
      keypathの署名者は、実際に支払いが発生するまで、オンチェーンデータを作成することなく、
      この方法で無制限の数のScriptに委譲することができます。

    - **<!--generalized-taproot-g-root-->一般化されたTaproot (g'root):**
      その数ヶ月後、Anthony Townsは、公開鍵ポイントを使って、
      必ずしも[MAST][topic mast]のような構造を使わずに、
      複数の異なる支払い条件にコミットする方法を[提案しました][towns groot]。
      この*一般化されたTaproot* (g'root) 構造は、「[Taprootの仮定が成立しない][p4tr taproot assumption]場合に、
      より効率的になる可能性がある」としています。
      また、「ソフトフォーク・セーフなインプットをまたぐ集約システムを簡単に構築する方法を[提供する][sipa groot agg]」
      としています。

    - **Entroot:** Graftrootとg'rootを[最近][wuille entroot]合成したもので、
      多くのケースを単純化し、より帯域幅を効率化しています。これは、トップレベルのkeypath支払いを作成できる人だけでなく、
      entrootブランチのいずれかを満たすことができる誰からでも署名者の委譲をサポートすることができます。

- **<!--new-and-old-opcodes-->新旧opcode:** Taprootのソフトフォークには、
  Bitcoinに新しいopcodeを追加するための改良された方法（`OP_SUCCESSx` opcode）を提供する
  [Tapscript][topic tapscript]のサポートが含まれています。
  Bitcoinの初期に追加された`OP_NOPx` (no operation) opcodeと同様に、
  `OP_SUCCESSx` opcodeは、常にsuccessを返すことのないopcodeに置き換えられるよう設計されています。
  提案されている新しいopcodeには次のようなものがあります:

    - **<!--restore-old-opcodes-->旧opcodeの復活:**
      数式や文字列操作のための多くのopcodeが、セキュリティの脆弱性への懸念から2010年に無効化されました。
      多くの開発者は、これらのopcodeがセキュリティレビューを経て再び有効になること、
      そして（場合によっては）より大きな数値が扱えるよう拡張されることを期待しています。

    - **OP_CAT:** 以前無効化されたopcodeの内の１つで、特筆すべきは[OP_CAT][op_cat subtopic]です。
      研究者が、OP_CAT自体でBitcoinのあらゆる[種類][rubin pqc]の[興味深い][poelstra cat]動作を[可能に][keytrees]したり、
      興味深い方法で他の新しいopcodeと[組み合わせる][topic op_checksigfromstack]ことができることを発見しています。

    - **OP_TAPLEAF_UPDATE_VERIFY:** [ニュースレター #166][news166 tluv]に掲載したように、`OP_TLUV` opcodeは、
      Taprootのkeypathとscriptpathの機能を使って特に効率的かつ強力な[Covenants][topic covenants]を可能にします。
      これは、[JoinPool][topic joinpools]や[Vault][topic vaults]および、
      その他のセキュリティやプライバシーの改善を実装するために使用できます。
      また、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]とうまく組み合わせることができます。

上記のアイディアはすべて、まだ提案に過ぎません。どれも成功するとは限りません。
各提案を成熟させるのは研究者や開発者であり、その後Bitcoinに各機能を追加することが、
Bitcoinのコンセンサスルールを変更する労力に値するかどうかをユーザーが判断することになります。

{% endauto_anchor %}

[news166 tluv]: /ja/newsletters/2021/09/15/#covenant-opcode-proposal-covenant-opcode
[wuille entroot]: https://gist.github.com/sipa/ca1502f8465d0d5032d9dd2465f32603
[towns groot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016249.html
[maxwell graftroot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[p4tr multisignatures]: /ja/preparing-for-taproot/#マルチシグの概要
[p4tr vaults]: /ja/preparing-for-taproot/#vaultとtaproot
[rubin delegation]: /ja/newsletters/2021/03/24/#signing-delegation-under-existing-consensus-rules
[p4tr taproot assumption]: /ja/preparing-for-taproot/#協力は常にオプション
[op_cat subtopic]: /en/topics/op_checksigfromstack/#relationship-to-op_cat
[keytrees]: https://blockstream.com/2015/08/24/en-treesignatures/#h.2lysjsnoo7jd
[rubin pqc]: https://rubin.io/blog/2021/07/06/quantum-bitcoin/
[poelstra cat]: https://www.wpsoftware.net/andrew/blog/cat-and-schnorr-tricks-i.html
[bip32 reverse derivation]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#implications
[sipa groot agg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-October/016461.html
