{% auto_anchor %}

- **<!--what-is-a-taproot-->Taprootとは？** [ウィキペディアによると][wikipedia taproot]、
  「Taprootとは、大きく、中央にあり、そこから他の根が横方向に発芽する主要な根です。
  一般的には、やや直線的で非常に太く、先細りの形状をしており、真下に向かって伸びています。
  人参などの一部の植物では、Taprootは非常によく発達した貯蔵器官であるため、野菜として栽培されます。」

    これはBitcoinにどう当てはまるでしょう？

    - 「名前の由来は'taps into the Merkle root'だと思っていましたが、
      Gregory Maxwellの考えがどうだったかは実は知りません。」  ---Pieter Wuille ([出典][wuille taproot name])

    - 「"私はもともと言葉を調べる必要がありました。しかし、
      key pathが'taproot'になるのは、それが人参スープを作る美味しいものであるためで、
      マークル化されたScriptは、無視したいと願う他の少ない根だろうと受け取りました。」
      ---Anthony Towns ([出典][towns taproot name])

    - 「名前の由来は、タンポポの根っこのような太い中心部を持つ木を視覚化したものです。
      この技術は、高確率のパスが１つあり、残りはファジーなはぐれ者であるという仮定から、
      ほとんどの場合役に立ちます。そして、
      根っこに隠されたコミットメントを利用してscript-pathの支払いを検証するという面白い事実も良いと考えました。

      [...]残念ながら、ソートされた内部ノードを持つハッシュツリーを'Myrtle tree'と呼んでも流行りませんでした。
      （ハッシュルートが等しいポリシーのセットは、T-functionで定義できる順列によって順序の異なるものであるため、
      Myrtle treeです。そして、Myrtleとは、お茶の木であるメラレウカを含む科であること、
      そして'merkle'に聞こえることからきてます。:p）」 ---Gregory Maxwell ([出典][maxwell taproot name])

- **<!--schnorr-signatures-predate-ecdsa-->Schnorr署名はECDSAより前から存在:**
  [Schnorr署名][topic schnorr signatures]について、さまざまな暗号トリックの実装が簡単になるため、
  Bitcoinの元のECDSA署名のアップグレードとして説明していますが、
  Schnorr署名のアルゴリズムはECDSAのベースであるDSAアルゴリズムよりも前からあったものです。
  実際、DSAはClause Schnorrの[Schnorr署名の特許][schnorr patent]を回避するために作られたものですが、
  Schnorrはそれでも「[私の]特許は、その種の離散対数署名のさまざまな実装に適用されており、
  したがって、これらの事例であるNyberg-RueppelおよびDSA署名の使用をカバーしている。」と[主張しています][schnorr letter]。
  Schnorrの主張を支持した裁判所は知られておらず、彼の特許は2011年に失効しました。

- **<!--unsure-what-name-to-use-->どんな名前を使用するか:**
  うまくいきまんせんでしたが、Schnorr署名をBitcoinに適用する開発の初期段階で、
  Claus Schnorrの名前を署名に関連して使うべきではないという[提案][dryja bn sigs]がありました。
  これは、彼の特許が20年以上にわたって貴重な暗号技術の普及を妨げていたためです。
  Pieter Wuilleは、「[BIP340][]を'Discrete Logarithm Signatures'から'DLS'と呼ぶことを検討したが、
  Schnorrという名前がすでに話題になっていたため、最終的にそうならなかった」と[書いています][wuille dls]。

- **<!--schnorr-signatures-for-twisted-edwards-curves-->ツイストEdwards曲線のSchnorr署名:**
  楕円曲線を使用したSchnorr署名のアプリケーションが2011年に公開されました。<!-- https://ed25519.cr.yp.to/papers.html -->
  スキーム[EdDSA][]は、現在いくつかの標準の基礎となっています。
  Bitcoinのコンセンサスでは使用されていませんが、他のシステムのコンテキストでの参照は、
  Optechが追跡している多くのBitcoinリポジトリで見られます。
  <!-- source: quick git grep -i -->

- **Pay to contract:** Ilja GerhardtとTimo Hankeは、支払いがその契約のハッシュにコミットすることを可能する、
  2013年のSan JoseのBitcoinカンファレンスでHankeによって紹介された[プロトコル][gh p2c]を作成しました。
  <!-- source: Wuille; I found some independent confirmation in dead links on Google -harding -->
  契約のコピーと、特定の攻撃を回避するために使用されるnonceを持っている人であればコミットメントを検証できますが、
  それ以外の人にとってはその支払いは他のBitcoinの支払いと同じように見えます。

    この*pay-to-contract* (P2C)プロトコルを少し改良したものが、
    [サイドチェーン][topic sidechains]に関する[2014年の論文][sidechains.pdf]に含まれており、
    <!-- Algorithm 1: GenerateCrossChainAddress -->
    コミットメントには支払いのための元の公開鍵も含まれるようになっています。
    Taprootはこれと同じ構造を採用していますが、オフチェーン契約の条項にコミットする代わりに、
    アウトプットの作成者は、受信したビットコインをオンチェーンで使用する方法について、
    受信者が選んだコンセンサス適用条件にコミットします。

- **A Good Morning:** P2Cを利用することで、Scriptへの支払いが公開鍵への支払いとチェーン上で同一に見えるようにするアイディアは、
  2018年1月22日にカリフォルニア州ロス・アルトスのダイナー「A Good Morning」で考案されました。
  Pieter Wuilleは、このアイディアは「私が短時間テーブルを離れている間に… !$%@」[sic]
  Andrew PoelstraとGregory Maxwellによって開発されたと書いています。
  <!-- personal correspondence with Wuille -harding -->

<!-- weird comment below because HTML has silly rules about anchor ids -->
- **<!--x-->2.5年を1.5日で:** [bech32m][topic bech32]に最適な定数を選択するのには、
  [約][wuille matrix elimination]2.5年のCPU時間が必要でしたが、
  Gregory Maxwellが所有するCPUクラスタを使用してわずか1.5日で実行されました。

*このコラムに関連して楽しい会話をしてくださたAnthony Towns、Gregory Maxwell、Jonas Nick、
Pieter WuilleおよびTim Ruffingに感謝します。誤りがあった場合それは筆者の責任です。*

{% endauto_anchor %}

[wikipedia taproot]: https://en.wikipedia.org/wiki/Taproot
[dryja bn sigs]: https://diyhpl.us/wiki/transcripts/discreet-log-contracts/
[bitcoin.pdf]: https://www.opencrypto.org/bitcoin.pdf
[schnorr patent]: https://patents.google.com/patent/US4995082
[ed25519]: https://ed25519.cr.yp.to/ed25519-20110926.pdf
[eddsa]: https://en.wikipedia.org/wiki/EdDSA
[gh p2c]: https://arxiv.org/abs/1212.3257
[sidechains.pdf]: https://www.blockstream.com/sidechains.pdf
[wuille matrix elimination]: https://twitter.com/pwuille/status/1335761447884713985
[wuille dls]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731372937
[wuille taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731371163
[towns taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731523855
[schnorr letter]: https://web.archive.org/web/19991117143502/http://grouper.ieee.org/groups/1363/letters/SchnorrMar98.html
[maxwell taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r732189216
