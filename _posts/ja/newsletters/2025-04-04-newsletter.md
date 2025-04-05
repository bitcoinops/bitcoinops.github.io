---
title: 'Bitcoin Optech Newsletter #348'
permalink: /ja/newsletters/2025/04/04/
name: 2025-04-04-newsletter-ja
slug: 2025-04-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinのsecp256k1曲線の楕円曲線暗号の教育目的の実装のリンクを掲載しています。
また、コンセンサスの変更に関する議論や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **教育および実験ベースのsecp256k1実装:**
  Sebastian FalbesonerおよびJonas NickとTim Ruffingは、
  Bitcoinで使用される暗号関連のさまざまな機能のPython[実装][secp256k1lab]を
  Bitcoin-Devメーリングリストで[発表][fnr secp]しました。彼らは、この実装は「安全ではなく（原文では大文字）」、
  「プロトタイプの作成や、実験、教育用である」と警告しています。

  また、いくつかのBIP（[340][bip340]、[324][bip324]、[327][bip327]、[352][bip352]）の
  参照コードとテストコードは、既に「secp256k1のカスタム実装と場合によっては微妙に異なる実装」が含まれていることも言及しています。
  彼らは、今後この状況を改善したいと考えています。おそらく、
  今後のChillDKG（[ニュースレター #312][news312 chilldkg]参照）のBIPから始めることになるでしょう。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--multiple-discussions-about-quantum-computer-theft-and-resistance-->量子コンピューターによる盗難と耐性に関する複数の議論:**
  量子コンピューターがビットコインを盗むのに十分な性能を持つようになった場合、
  ビットコイナーはどのような対応ができるかについて検討されました。

  - *<!--should-vulnerable-bitcoins-be-destroyed-->脆弱なビットコインは破棄されるべきか？*
    Jameson Loppは、[量子耐性][topic quantum resistance]へのアップグレードパスが採用され、
    ユーザーが解決策を採用する時間が取れた後、量子コンピューターを利用した盗難に脆弱なビットコインを破棄することについて、
    いくつかの主張をBitcoin-Devメーリングリストに[投稿しました][lopp destroy]。
    いくつかの主張は次のとおりです:

    - *<!--argument-from-common-preference-->一般的な選択の主張:*
      彼は、ほとんどの人が、高速な量子コンピューターを持つ誰かに盗まれるよりも、
      破棄されることを望むと考えています。特に、窃盗犯は「量子コンピューターにいち早くアクセスできる
      数少ない特権階級」の一人だろうからと、彼は主張しています。

    - *<!--argument-from-common-harm-->共通の被害の主張:*
      盗まれるビットコインの多くは、紛失したコインか、長期保有を予定していたコインのいずれかでしょう。
      対照的に、窃盗犯は盗んだビットコインをすぐ使ってしまう可能性があり、
      他のビットコインの購買力を低下させます（マネーサプライのインフレと同様に）。
      ビットコインの購買力が低下すると、マイナーの収入が減少し、ネットワークのセキュリティを低下させ、
      （彼の観察によると）ビットコインを受け入れるマーチャントが少なくなると指摘しています。

    - *<!--argument-from-minimal-benefit-->最小限の利益の主張:*
      盗難を許可すれば量子コンピューターの開発資金を提供できるようになりますが、
      コインを盗むことは、Bitcoinプロトコルの誠実な参加者に直接的な利益はもたらしません。

    - *<!--argument-from-clear-deadlines-->明確な期限の主張:*
      量子コンピューターを持つ誰かがビットコインを盗み始める日を、誰も事前に知ることはできません。
      しかし、量子コンピューターに対して脆弱なコインが破棄される特定の日付は、
      事前に完全に正確に発表できます。その明確な期限により、ユーザーがビットコインを期間内に再保護するインセンティブが高まり、
      失われるコインの総数は減ります。

    - *<!--argument-from-miner-incentives-->マイナーのインセンティブの主張:*
      前述のように、量子コンピューターによる盗難は、マイナーの収入を減らす可能性があります。
      ハッシュレートの過半数を保持する多数派は、量子コンピューターに対して脆弱なビットコインの使用を検閲することができます。
      他のビットコイナーが別の結果を望んだとしても彼らはそのような行動をする可能性があります。

    Loppは、脆弱なビットコインの破棄に反対するいくつかの主張も示していますが、
    破棄を支持する結論を出しています。

    Nagaev Borisは、アップグレードの期限を過ぎて
    [タイムロックされている][topic timelocks]コインも破棄すべきかどうかを[問いました][boris timelock]。
    Loppは、長期のタイムロックの落とし穴を指摘し、個人的には「1，2年以上資金をロックするのは不安だ」と語っています。

  - *SHA256プリイメージを公開することでUTXOの所有を安全に証明する:*
    Martin Habovštiakは、ECDSAや[Schnorr署名][topic schnorr signatures]が安全ではなくなった場合でも（
    高速な量子コンピューターが登場した後など）、誰かがUTXOを管理していることを証明できるようにするアイディアを
    Bitcoin-Devメーリングリストに[投稿しました][habovstiak gfsig]。
    UTXOにこれまで公開されたことのないSHA256コミットメント（または他の量子耐性のあるコミットメント）が含まれていれば、
    そのプリイメージを公開するためのマルチステッププロトコルをコンセンサスの変更と組み合わせることで
    量子コンピューターによる盗難を防ぐことができます。これは、
    Tim Ruffingの[以前の提案][ruffing gfsig]（[ニュースレター #141][news141 gfsig]参照）と基本的に同じで、
    彼はそれが一般的に[Guy Fawkesの署名スキーム][Guy Fawkes signature scheme]として知られていることを知りました。
    これは、マイナーの検閲に対する耐性を向上させるために、Adam Backが2013年に考案した[スキーム][back crsig]のバリエーションでもあります。
    つまり、プロトコルは以下のように機能します:

    1. アリスは何らかの方法でSHA256コミットメントを行うアウトプットへの資金を受け取ります。
       これは、P2PKH、P2SH、P2WPKH、P2WSHのような直接ハッシュされるアウトプット、
       または、スクリプトパスを含む[P2TR][topic taproot]アウトプットにすることができます。

    2. アリスが同じアウトプットスクリプトに対して複数の支払いを受け取った場合、
       それらすべての支払いを使用する準備ができるまで、それらを一切使用しないか（P2PKHおよびP2WSHでは必ず、
       P2SHおよびP2WSHでも実質的に）、または使用する際に少なくとも1つのプリイメージが明らかにならないように
       細心の注意を払う必要があります（P2TRのキーパスとスクリプトパスでは簡単に可能）。

    3. アリスは使用する準備ができると、通常通り支払いトランザクションを非公開で作成しますが、
       ブロードキャストはしません。また、トランザクション手数料を支払うために、
       量子安全な署名アルゴリズムで保護されたビットコインも入手します。

    4. 量子安全なビットコインの一部を使用するトランザクションでは、
       アリスは使用したい量子安全ではないビットコインにコミットし、
       非公開の支払いトランザクションにもコミットします（公開せずに）。
       アリスはこのトランザクションが深く承認されるまで待ちます。

    5. アリスは、トランザクションが実質再編成できないようになったことを確認したら、
       これまで非公開だったプリイメージと量子安全ではない支払いを公開します。

    6. ネットワーク上のノードは、ブロックチェーンを検索して、
       プリイメージにコミットする最初のトランザクションを見つけます。
       そのトランザクションがアリスの量子安全ではない支払いにコミットしている場合、
       アリスの支払いを実行します。そうでない場合は、何もしません。

    これにより、アリスは、自分の支払いトランザクションが
    量子コンピューターのオペレータによる支払いの試みよりも優先されることを確認するまで、
    量子コンピューターに対して脆弱な情報を公開する必要がなくなります。
    プロトコルのより正確な説明については、[Ruffingの2018年の投稿][ruffing gfsig]をご覧ください。
    スレッドでは説明されていませんが、上記のプロトコルはソフトフォークとして展開できると考えています。

    Habovštiakは、このプロトコルを使って安全に使用できるビットコイン（たとえば、
    そのプリイメージがまだ公開されていない）は、
    コミュニティが量子耐性のあるビットコイン全体を破棄すると決定した場合でも破棄すべきではないと主張しています。
    また、緊急時でも一部のビットコインを安全に使用できるため、
    短期的には量子耐性スキームを展開する緊急性が低下すると主張しています。

    Lloyd Fournierは、「このアプローチが受け入れられれば、ユーザーがすぐに実行できる行動は、
    Taprootウォレットに移行することだ思う」と[述べています][fournier gfsig]。
    Taprootウォレットは、現在のコンセンサスの下で、
    [アドレスの再利用][topic output linking]も含めてキーパスでの支払いを許可できるだけでなく、
    キーパス支払いが後に無効にされた場合、量子コンピューターによる盗難に対する耐性もあるからです。

    別のスレッドで（次の項目を参照）、Pieter Wuilleは量子コンピューターによる盗難に対して脆弱なUTXOには、
    公開されていないが、さまざまな形態のマルチシグ（LNや[DLC][topic dlc]、エスクローサービスを含む）など、
    複数の参加者が知っている鍵も含まれると[指摘しています][wuille nonpublic]。

  - *量子安全ではないビットコインを破棄するためのBIPドラフト:* Agustin Cruzは、
    量子コンピューターによる盗難の恐れがある（それが予想されるリスクとなった場合に）ビットコインを破棄する一般的なプロセスについて、
    いくつかの選択肢を説明する[BIPのドラフト][cruz bip]をBitcoin-Devメーリングリストに[投稿しました][cruz qramp]。
    Cruzは、「移行の期限を強制することで、正当な所有者に資金を確保するための明確で譲れない機会を提供します[...]
    十分な通知と堅牢な保護手段を伴う強制的な移行は、現実的でBitcoinの長期的なセキュリティを保護するために必要です」
    と主張しています。

    スレッドの議論のほとんどは、BIPドラフトに焦点をあてたものではありません。
    そのほとんどは、量子安全でないビットコインを破棄することが良いアイディアなのかどうかに焦点を当てており、
    これは後にJameson Loppが始めたスレッド（前述のサブ項目で説明）と同様でした。

- **<!--multiple-discussions-about-a-ctv-csfs-soft-fork-->CTV+CSFSソフトフォークに関する複数の議論:**
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）と
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（CSFS）opcodeのソフトフォークのさまざまな側面について、
  複数の会話で検討されました。

  - *CTVの動機に対する批判:* Anthony Townsは、[BIP119][]に記載されているCTVの動機に対する批判を[投稿しました][towns ctvmot]。
    彼は、この動機は、CTVとCSFSの両方をBitcoinに追加することで損なわれると主張しました。
    議論が始まってから数日後、BIP119は作者によって更新され、
    物議を醸している文言のほとんど（おそらくすべて）が削除されました。
    変更の概要については[ニュースレター #347][news347 bip119]を、
    また参考としてBIP119の[旧バージョン][bip119 prechange]をご覧ください。
    議論されたトピックには次のようなものがありました:

    - *CTV+CSFSにより永久のコベナンツの作成が可能になる:*
      CTVの動機には、「コベナンツは、実装が複雑すぎることと、コベナンツによりロックされたコインの流動性を低下させるリスクがあることから、
      歴史的にビットコインには不向きであると広く考えられてきました。このBIPは、
      *テンプレート*と呼ばれるシンプルなコベナンツを導入し、大きなリスクなしに、
      非常に価値のあるユースケースの限定されたセットを可能にします。
      BIP119のテンプレートは、動的な状態を持たない**非再帰的**な完全列挙型のコベナンツを可能にします。
      （強調は原文のまま）」とあります。

      Townsは、CTVとCSFSの両方を使用するスクリプトを説明し、
      MutinyNet [signet][topic signet]上でそれを使用する[トランザクション][mn recursive]をリンクしています。
      このトランザクションは、スクリプト自体に同じ金額を送る場合のみ使用できます。
      定義については議論がありましたが、CTVの作者は[以前][rubin recurse]、
      機能的に同様の構成を再帰的コベナンツと説明しており、
      Optechはその会話の要約でその慣例に従いました（[ニュースレター #190][news190 recursive]参照）。

      Olaoluwa Osuntokunは、CTVを使用するスクリプトが「完全に列挙され」、
      「動的な状態がない」ままであることに関するCTVの動機を[擁護しました][osuntokun enum]。
      これは、CTVの作者（Jeremy Rubin）が2022年に行った[主張][rubin enumeration]と似ています。
      Rubinは、Townsが設計したpay-to-selfタイプのコベナンツを「再帰的だが完全な列挙型」と呼びました。
      Townsは、CSFSを追加すると、完全列挙の主張されている利点が損なわれると[反論しました][towns enum]。
      彼は、CTVまたはCSFSのBIPを更新し、「CTVとCSFSの組み合わせによって、
      何らかの形で恐ろしく、それでも防止されるユースケース」について記載するよう求めました。
      これは、[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]を使用すると可能になるが、
      CTV+CSFSを使用すると不可能な「自己複製オートマトン（俗にSpookChainsと呼ばれる）」を記載した
      BIP119の最近の更新で[行われた][ctv spookchain]可能性があります。

    - *<!--tooling-for-ctv-and-csfs-->CTVとCSFS用のツール:* Townsは、
      上記の再帰スクリプトを開発するために既存のツールを使うのは難しいと[指摘し][towns ctvmot]、
      これは導入の準備が整っていないことを示唆しています。Osuntokunは、
      彼が使用しているツールは「非常にシンプル」であると[述べています][osuntokun enum]。
      TownsもOsuntokunも、使用したツールについては言及していません。
      Nadav Ivgiは、自身の[Minsc][]言語を使用したサンプルを[示し][ivgi minsc]、
      「Minscを改良して、このような作業を簡単にすることに取り組んでいます。
      Minscは、TaprootやCTV、PSBT、ディスクリプター、Miniscript、スクリプト、BIP32などをサポートしています。」
      と述べています。ただし、「その多くはまだ文書化されていません」と認めています。

    - *<!--alternatives-->代替案:* Townsは、CTV+CSFSを、代替スクリプト言語を提供する
      彼のBasic Bitcoin Lisp Language（[bll][topic bll]）と[Simplicity][topic
      simplicity]と比較しています。Antoine Poinsotは、理解しやすい代替言語は、
      理解しにくい現在のシステムへの小さな変更よりもリスクが少ない可能性があると[示唆しています][poinsot alt]。
      開発者のMoonsettlerは、Bitcoinスクリプトに段階的に新しい機能を導入することで、
      表現力が高まるにつれて予期せぬ自体に遭遇する可能性が低くなるため、
      後でさらに機能を追加しても安全になると[主張しています][moonsettler express]。

      OsuntokunとJames O'Beirneはどちらも、CTVやCSFSと比べて、
      bllやSimplicityの[準備ができている][obeirne readiness]という主張を[批判しています][osuntokun enum]。

  - *<!--ctv-csfs-benefits-->CTV+CSFSの利点:* Steven Rooseは、
    表現力をさらに高める他の変更の第一段階として、CTVとCSFSをBitcoinに追加する提案を
    Delving Bitcoinに[投稿しました][roose ctvcsfs]。
    議論のほとんどは、CTV、CSFS、またはその両方を組み合わせた場合に可能になる利点の認定に焦点が当てられました。
    これには以下が含まれます:

    - *DLC:* CTVとCSFSはどちらも個別に、[DLC][topic dlc]を作成するのに必要な署名の数を減らすことができます。
      特に、大量の契約のバリエーション（1ドル単位のBTC-USD価格の契約など）に署名するDLCにとっては重要です。
      Antoine Poinsotは、BitcoinユーザーがDLCにあまり興味がないことを示す証拠として、
      DLCサービスプロバイダーが閉鎖するという最近の[発表][10101 shutdown]を[リンクし][poinsot ctvcsfs1]、
      数ヶ月前にJonas Nickが述べた「DLCはBitcoinで意味のある採用には至っておらず、
      その限れれた利用はパフォーマンスの制限によるものではないようだ」という[投稿][nick dlc]をリンクしました。
      返信には、まだ機能している他のDLCサービスプロバイダーのリンクがあり、
      その中には、「3,000万ドルの資金調達」を行ったと[主張する][lava 30m]プロバイダーも含まれています。

    - *Vault:* CTVは、署名済みトランザクションと（オプションで）秘密鍵の削除を使用した現在のBitcoinで可能な
      [Vault][topic vaults]（金庫）の実装を簡単にします。Anthony Townsは、
      このタイプのVaultはあまり興味深いものではないと[主張します][towns vaults]。
      James O'Beirneは、CTVまたは同様のものが、彼の[BIP345][] `OP_VAULT` Vaultなどの
      より高度なタイプのVaultを構築するための前提条件であると[反論しています][obeirne ctv-vaults]。

    - *Accountable Computing Contract:* CSFSは、
      スクリプトベースのランポート署名を実行する現在の必要性を置き換えることで、
      BitVMなどの[Accountable Computing Contract][topic acc]の多くの手順を排除できます。
      CTVは、追加の署名演算の一部を削減できる可能性があります。Poinsotは、
      BitVMに大きな需要があるかどうかを再度[尋ねます][poinsot ctvcsfs1]。
      Gregory Sandersは、シールド[Client-side Validation][topic client-side validation]（
      [ニュースレター #322][news322 csv-bitvm]参照）の一部として、トークンの双方向ブリッジが興味深いと[答えています][sanders bitvm]。
      しかし、CTVもCSFSもBitVMのトラストモデルを大幅に改善するものではなく、
      他の変更によってトラストを低下させたり、他の方法でコストのかかる演算の数を減らしたりできる可能性があるとも述べています。

    - *Liquidのタイムロックスクリプトの改善:* James O'Beirneは、
      CTVは「コインを定期的に[移動する]必要がある[Blockstream]のLiquidタイムロックフォールバックスクリプトを大幅に改善する」
      という、Blockstreamの2人のエンジニアからのコメントを[伝えました][obeirne liquid]。
      説明を求めると、元BlockstreamエンジニアのSanket Kanjalkarは、
      そのメリットはオンチェーントランザクション手数料の大幅な節約になる可能性があると[説明しました][kanjalkar liquid]。
      O'Beirneは、Blockstreamの研究ディレクターであるAndrew Poelstraからの追加情報も[共有しました][poelstra liquid]。

    - *LN-Symmetry:* CTVとCSFSを併用すると、[LN-Symmetry][topic eltoo]を実装することができ、
      現在LNで使用されている[LN-Penalty][topic ln-penalty]チャネルの欠点の一部が解消され、
      3人以上の参加者がいるチャネルを作成できるようになり、流動性の管理とオンチェーンの効率が向上する可能性があります。
      [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]（APO）を使用して
      LN-Symmetryの実験バージョン（[ニュースレター #284][news284 lnsym]参照）を実装したGregory Sandersは、
      LN-SymmetryのCTV+CSFSバージョンはAPOほど機能が豊富ではなく、トレードオフが必要になると[指摘しています][sanders versus]。
      Anthony Townsは、SandersのAPOの実験コードを最新のソフトウェアで実行し、
      [TRUC][topic v3 transaction relay]や[エフェメラルアンカー][topic ephemeral anchors]などの
      最近導入されたリレー機能を使用するように更新した人は誰もいないと[付け加えました][towns nonrepo]。
      まして、CTV+CSFSを使用するようにコードを移植した人は誰もいないため、
      その組み合わせのLN-Symmetryを評価する能力は制限されています。

      Poinsotは、ソフトフォークによって可能になった場合、LN開発者にとって
      LN-Symmetryの実装が優先事項になるかどうかを[尋ねています][poinsot ctvcsfs1]。
      2人のCore Lightningの開発者（現在LN-Symmetryと呼んでいるものを紹介した論文の共著者でもある）の発言から、
      それが優先事項であることが示されています。それに対し、LDKのリード開発者であるMatt Coralloは、
      「[LN-Symmetry]は、これを完成させる必要があるという意味ではそれほど興味深いとは思わない」と[語っています][corallo eltoo]。

    - *Ark:* Rooseは、[Ark][topic ark]実装を構築している企業のCEOです。
      彼は、「CTVはArkにとってゲームチェンジャーです。[...]ユーザーエクスペリエンスに対する
      CTVの利点は否定できません。また、CTVが利用可能になり次第、両方の[Ark]実装でCTVが利用されることは間違いありません」と述べています。
      Townsは、APOまたはCTVのいずれかを使ってArkをテスト用に実装した人はいないと[指摘しました][towns nonrepo]。
      Rooseは、その後すぐにそれを実行する[コード][roose ctv-ark]を書き、
      「非常に簡単」で、既存の実装の統合テストをパスしたと述べました。
      彼は、改善点のいくつかを数値化しました。CTVに切り替えた場合、
      「約900行のコードが削除でき、[...]独自のラウンドプロトコルが3から[2]に削減され、
      [さらに]署名nonceと部分署名を渡す必要がなくなるため、帯域幅が改善できます」。

      Rooseは後に、ArkユーザーにとってのCTVの利点について議論する別のスレッドを開始しました（以下の要約を参照）。

  - *ArkユーザーにとってのCTVの利点:* Steven Rooseは、
    現在[signet][topic signet]に導入されている[Ark][topic ark]プロトコル
    （[コベナンツレスArk][clark doc]（clArk）と呼ばれる）の簡単な説明と、
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）opcodeが利用可能になることで、
    最終的にmainnetに導入された際に、プロトコルの[コベナンツ][topic covenants]使用バージョンが
    ユーザーにとってより魅力的になる可能性があることをDelving Bitcoinに[投稿しました][roose ctv-for-ark]。

    Arkの設計目標の1つは、[非同期支払い][topic async payments]（受信者がオフラインの支払い）を可能にすることです。
    clArkでは、これは、支払人とArkサーバーによって支払人の既存の事前署名済みトランザクションチェーンが拡張され、
    最終的に受信者が資金に対する排他的制御を受け入れることができるようにすることで実現しています。
    この支払いは、Ark [out-of-round][oor doc]支払い（_arkoor_）と呼ばれます。
    受信者がオンラインになると、次の操作を選択できます:

    - *<!--exit-after-a-delay-->遅延後の退出:* 事前署名済みトランザクションのチェーン全体をブロードキャストし、
      [Joinpool][topic joinpools]（_Ark_ と呼ばれる）から退出します。
      支払人が同意したタイムロックの期限が切れるまで待つ必要があります。
      事前署名済みトランザクションが適切な深さまで承認されると、
      受信者は資金をトラストレスに制御できることを確信できます。ただし、
      迅速な決済や、UTXOの共有による手数料の削減など、Joinpoolの一部であることのメリットは失われます。
      また、トランザクションチェーンを承認するためにトランザクション手数料を支払う必要がある場合もあります。

    - *<!--nothing-->何もしない:* 通常のケースでは、
      トランザクションチェーン内の事前署名されたトランザクションは最終的に期限切れとなり、
      サーバーが資金を請求できるようになります。これは盗難ではなく、プロトコルの予想される部分で、
      サーバーは請求された資金の一部またはすべてを何らかの方法でユーザーに返すことを選択できます。
      期限が近づくまで、受信者は待つことができます。

      異常ケースでは、サーバーと支払人は（いつでも）共謀して別のトランザクションチェーンに署名し、
      受信者に送信された資金を盗むことができます。注：Bitcoinのプライバシー特性により、
      サーバーと支払人が同一人物になることができるため、共謀が必要ない場合もあります。
      ただし、受信者がサーバーが署名したトランザクションチェーンのコピーを保持している場合は、
      サーバーが資金を盗んだことを証明できるため、他の人がそのサーバーの使用を阻止するのに十分な可能性があります。

    - *<!--refresh-->リフレッシュ:* サーバーの協力により、
      受信者は、支払人が共同で署名したトランザクションの資金の所有権を、
      受信者が共同署名者となった別の事前署名トランザクションにアトミックに移転できます。
      これにより、有効期限が延長され、サーバーと以前の支払人が共謀して以前送信した資金を盗む可能性がなくなります。
      ただし、リフレッシュでは、サーバーがリフレッシュされた資金を期限が切れるまで保持する必要があり、
      サーバーの流動性が低下するため、サーバーは受信者に期限が着れるまで金利を請求します（有効期限は固定されているため、前払い）。

    Arkのもう1つの設計目標は、参加者がLN支払いを受け取れるようにすることです。
    Rooseは元の投稿と[返信][roose ctv-ark-ln]で、Joinpool内に既に資金を持っている既存の参加者は、
    LN支払いを受け取るために必要な対話の実行ができなかった場合、
    オンチェーントランザクションのコストまでペナルティを課せられる可能性があると説明しています。
    ただし、Joinpool内に資金を持っていない参加者は、ペナルティを課せられないため、
    対話型の手順の実行を拒否して、コストをかけずに正直な参加者に問題を引き起こすことができます。
    これにより、Arkユーザーは、使用したいArkサーバーに既に適度な額を預け入れていない限り、
    LN支払いを受け取ることが事実上できなくなるようです。

    Rooseは次に、CTVの利用によってプロトコルがどのように改善できるかを説明しています。
    主な変更点は、Arkラウンドの作成方法です。_Arkラウンド_ は、
    オフチェーントランザクションのツリーにコミットする小さなオンチェーントランザクションで構成されます。
    clArkの場合、これらは事前署名されたトランザクションで、そのラウンドのすべての支払人が署名できる必要があります。
    CTVが利用可能な場合、トランザクションのツリーの各ブランチは、
    署名を必要とせずにCTVを使って子孫にコミットできます。これにより、
    ラウンドの作成時に利用できない参加者に対しても、トランザクションを作成でき、以下の利点があります:

    - *<!--in-round-non-interactive-payments-->ラウンド中の非対話型支払い:*
      Arkのarkoor（out-of-round）支払いの代わりに、次のラウンドまで待つ意思のある支払人は、
      ラウンド中に受信者に支払いができます。受信者にとって、これは大きな利点です。
      ラウンドが適切な深さまで承認されると、受信者は受け取った資金に対するトラストレスな制御を受け取ります（
      有効期限が近づくまで、その時点で退出するか、安価にリフレッシュできます）。
      受信者は、複数の承認を待つ代わりに、サーバーが正直に動作するためにArkプロトコルによって作られたインセンティブを
      すぐに信頼することを選択できます（[ニュースレター #253][news253 ark 0conf]参照）。
      別の点として、Rooseは、これらの非対話型支払いを[バッチ処理して][topic payment batching]、
      一度に複数の受信者に支払うこともできると指摘しています。

    - *ラウンド中のLN支払いの受け入れ:* ユーザーは、
      LN支払い（[HTLC][topic htlc]）をArkサーバーに送信するよう要求できます。
      サーバーは、次のラウンドまで支払いを[保留し][topic hold invoices]、
      CTVを使ってラウンドにHTLCロックされた支払いをユーザーに追加します。
      その後、ユーザーはHTLCのプリイメージを公開して支払いを請求できます。
      ただし、Rooseは、これには依然として「さまざまな不正使用防止対策」が必要であると指摘しています。
      （これは、受信者がプリイメージを公開しないリスクがあるためであり、
      サーバーの資金はArkラウンドの終了までロックされたままになり、2ヶ月以上続く可能性があります。）

      David Hardingは、Rooseに[返信して][harding ctv-ark-ln]詳細を尋ね、
      状況をLNの[JITチャネル][topic jit channels]と比較しました。
      JITチャネルでも、HTLCのプリイメージが公開されないことで、
      ライトニングサービスプロバイダー（LSP）に問題が生じるという同様の問題があります。
      LSPは現在、トラストベースのメカニズムを導入することでこの問題に対処しています（
      [ニュースレター #256][news256 ln-jit]参照）。同じソリューションをCTV-Arkで使用する予定であれば、
      それらのソリューションは、clArkでのLN支払いのラウンド中の受け入れも安全に許可すると思われます。

    - *<!--fewer-rounds-fewer-signatures-and-less-storage-->より少ないラウンド、署名、ストレージ:*
      clArkは[MuSig2][topic musig]を使用し、各参加者は複数のラウンドに参加し、
      複数の部分署名を生成し、完成した署名を保存する必要があります。CTVを使用すると、
      生成して保存する必要のあるデータが少なくなり、必要な対話も少なくなります。

- **OP_CHECKCONTRACTVERIFYセマンティクス:** Salvatore Ingalaは、
  提案中の[OP_CHECKCONTRACTVERIFY][topic matt]（CCV）opcodeのセマンティクス、
  [最初のBIPドラフト][ccv bip]のリンクおよび、Bitcoin Coreへの[実装のドラフト][bitcoin core #32080]のリンクを
  Delving Bitcoinに[投稿しました][ingala ccv]。彼の説明は、CCVの動作の概要から始まります。
  CCVでは、公開鍵が任意のデータにコミットしていることをチェックできます。
  使用される[Taproot][topic taproot]アウトプットの公開鍵と、
  作成されるTaprootアウトプットの公開鍵の両方をチェックできます。
  これを使って、使用されるアウトプットのデータが、作成されるアウトプットに引き継がれるようにすることができます。
  Taprootでは、アウトプットの調整により、[Tapscript][topic tapscript]などの
  Tapleafeにコミットできます。調整が1つ以上のTapscriptにコミットすると、
  アウトプットに制限（使用条件）が設定され、使用されるアウトプットに設定された条件が、
  作成されるアウトプットに転送されるようになります。これは、Bitcoinの専門用語では、
  一般的に[コベナンツ][topic covenants]と呼ばれます（ただし[議論の余地はあります][towns anticov]が）。
  コベナンツによって制限を満たしたり変更が可能になる場合があり、
  これによって（それぞれ）コベナンツが終了するか、将来の反復の条件が変更されます。
  Ingalaは、このアプローチの利点と欠点を次のように説明しています:

  - *<!--benefits-->利点:* Taprootネイティブで、
    UTXOセット内のTaprootのエントリーのサイズが増加せず、
    追加データを必要としない使用条件のため、追加データをwitnessスタックに含める必要がありません（
    したがって、追加のコストが発生しません）。

  - *<!--drawbacks-->欠点:* Taprootのみで機能し、調整を確認するには、
    （たとえば）SHA256の演算よりもコストのかかる楕円曲線の演算が必要です。

  使用条件を使用されるアウトプットから作成されるアウトプットに転送するだけでも便利ですが、
  多くのコベナンツでは、使用されるアウトプット内のビットコインの一部またはすべてが、
  作成されるアウトプットに渡されることを確実にしたいと考えています。Ingalaは、
  CCVの金額の処理に関する3つの選択肢について説明しています。

  - *<!--ignore-->無視:* 金額はチェックしない

  - *<!--Deduct-->控除:* 特定のインデックス（たとえば3つめのアウトプット）で作成されるアウトプットの金額が、
    同じインデックスで使用されるアウトプットの金額から差し引かれ、残った金額が追跡されます。
    たとえば、インデックス3で使用されるアウトプットの金額が100 BTCで、
    インデックス3で作成されるアウトプットの金額が70 BTCの場合、
    コードは残りの30 BTCを追跡します。作成されるアウトプットの金額が使用されるアウトプットの金額よりも多い場合、
    トランザクションは無効としてマークされます（残金が減り、おそらくゼロ未満になります）。

  - *<!--Default-->デフォルト:* 特定のインデックスで作成されるアウトプットの金額が、
    使用されるアウトプットの金額と _デフォルト_ チェックでまだ使用されていない以前の残金の量の合計よりも多い場合を除き、
    トランザクションを無効とマークします。

  アウトプットが _控除_ で複数回チェックされる場合、または同じアウトプットで _控除_ と _デフォルト_ の両方が使用される場合、
  トランザクションは有効です。

  Ingalaは、上記の操作の組み合わせの視覚的な例をいくつか示しています。
  以下は、彼の「部分的な金額の送信」の例のテキストによる説明で、
  [Vault][topic vaults]に役立つかもしれません。トランザクションには、
  100 BTCのインプットが1つ（アウトプットを1つ使用）、アウトプットは2つあり、
  1つは70 BTCでもう1つは30 BTCです。トランザクションの検証中にCCVが2回実行されます:

  1. CCVの _控除_ 操作は、インデックス0で100 BTCを使用し、70 BTCが使用され、
     30 BTCが残金になります。[BIP345][]スタイルのVaultでは、
     CCVは70 BTCを以前保護されていた同じスクリプトに戻します。

  2. 2回めは、インデックス1で _デフォルト_ を使用します。このトランザクションでは、
     インデックス1でアウトプットが作成されていますが、インデックス1で使用されるアウトプットはないため、
     暗黙的な金額`0`が使用されます。そのゼロに、インデックス0の _控除_ 呼び出しによる残金30 BTCが追加され、
     作成されるアウトプットは30 BTC以上である必要があります。BIP345スタイルのVaultでは、
     CCVはアウトプットスクリプトを調整し、[タイムロック][topic timelocks]の期限が切れた後に、
     この金額を任意のアドレスに支払ったり、いつでもユーザーのメインのVaultに戻したりできるようにします。

  Ingalaが検討して却下したいくつかの代替アプローチは、彼の投稿と返信の両方で説明されています。
  彼は、「2つの金額動作（デフォルトと控除）は非常に人間工学的であり、
  実際に望ましい金額チェックの大部分をカバーしていると思います」と書いています。

  また、「`OP_CCV`と[OP_CTV][topic op_checktemplateverify]を使用して、
  [...[BIP345][]...]とほぼ同等のフル機能のVaultを実装しました。さらに、
  `OP_CCV`のみを使用した機能限定バージョンが、`OP_CCV`のBitcoin Core実装の機能テストとして実装されています。」とも述べています。

- **<!--draft-bip-published-for-consensus-cleanup-->コンセンサスクリーンアップ用のBIPドラフトの公開:**
  Antoine Poinsotは、[コンセンサスクリーンアップ][topic consensus cleanup]ソフトフォーク提案用に作成した
  [BIPドラフト][cleanup bip]のリンクをBitcoin-Devメーリングリストに[投稿しました][poinsot cleanup]。
  これには、いくつかの修正が含まれています:

  - ハッシュレートの過半数がブロックを高速に生成するために使用できる2つの異なる
    [タイムワープ][topic time warp]攻撃の修正。

  - 検証に非常に時間がかかるブロックの作成を防ぐために、
    レガシートランザクションに署名操作（sigops）の実行制限を設定。

  - [<!--bip34-->重複トランザクション][topic duplicate transactions]を完全に防止する
    [BIP34][]コインベーストランザクションの一意性の修正。

  - [<!--merkle-->マークルツリーの脆弱性][topic merkle tree vulnerabilities]の一種を防止するため、
    将来の64 byteトランザクション（ストリップサイズを使用して計算）を無効化。

  技術的な回答は、提案の2つの部分を除いてすべてに好意的でした。複数の回答で見られた最初の反対意見は、
  64 byteトランザクションの無効化でした。返信では以前の批判を繰り返しました（[ニュースレター #319][news319 64byte]参照）。
  マークルツリーの脆弱性に対処するためには代替方法もあります。この方法は、
  軽量（SPV）ウォレットでは比較的簡単に使用できますが、Bitcoinと他のシステム間のブリッジなど、
  スマートコントラクトでのSPV検証に課題が生じる可能性があります。
  Sjors Provoostは、オンチェーンで強制可能なブリッジを実装する人が、
  64 byteトランザクションが存在しないと仮定できることと、
  マークルツリーの脆弱性を防ぐために代替方法を使用しなければならないことの違いを示すコードを提供することを
  [提案しました][provoost bridge]。

  2つめの反対意見は、BIPに含まれるアイディアに対する後発の変更に関するもので、
  PoinsotのDelving Bitcoinの[投稿][poinsot nsequence]で説明されています。
  この変更では、コンセンサスクリーンアップの有効化後に作られたブロックに、
  コインベーストランザクションのロックタイムを強制可能にするフラグを設定することが求められます。
  以前提案されたように、有効化後のブロックのコインベーストランザクションは、
  ロックタイムをブロックの高さ（マイナス１）に設定します。この変更により、
  マイナーは有効化後のロックタイムと強制フラグの両方を使用する代替の早期Bitcoinブロックを生成できなくなります（
  なぜなら、そうしたとしても、遠い将来のロックタイムを使用しているため、
  そのコインベーストランザクションは、それを含むブロックでは有効にならないからです）。
  過去のコインベーストランザクションで、将来のコインベーストランザクションで使用されるものとまったく同じ値を使用できないため、
  重複トランザクションの脆弱性が防止されます。この提案に対する反対意見は、
  すべてのマイナーがロックタイム強制フラグを設定できるかどうかは明確ではないというものでした。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BDK wallet 1.2.0][]は、カスタムスクリプトへの支払いの送信の柔軟性が増し、
  コインベーストランザクションに関連するエッジケースが修正され、
  その他の機能やバグ修正もいくつか含まれています。

- [LDK v0.1.2][]は、LN対応アプリケーションを構築するこのライブラリのリリースです。
  いくつかのパフォーマンスの改善とバグ修正が含まれています。

- [Bitcoin Core 29.0rc3][]は、ネットワークの主流のフルノードの次期メジャーバージョンのリリース候補です。
  [バージョン29のテストガイド][bcc29 testing guide]をご覧ください。

- [LND 0.19.0-beta.rc1][]は、この人気のLNノードのリリース候補です。
  おそらくテストが必要な主な改善の1つは、協調クローズにおける新しいRBFベースの手数料引き上げです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31363][]では、トランザクション間の手数料率と依存関係のみを追跡する
  mempoolトランザクションの軽量インメモリモデルである`TxGraph`クラスを導入しました。
  これには、`AddTransaction`や`RemoveTransaction`、`AddDependency`などのミューテーション関数と、
  `GetAncestors`、`GetCluster`、`CountDistinctClusters`などの検査関数が含まれます。
  `TxGraph`は、コミットと中止機能による変更のステージングもサポートします。
  これは[クラスターmempool][topic cluster mempool]プロジェクトの一部であり、
  mempoolからの排除、再編成処理、クラスター対応のマイニングロジックの将来の改善の準備です。

- [Bitcoin Core #31278][]では、`settxfee` RPCコマンドと`-paytxfee`起動オプションが非推奨になりました。
  これらを使用すると、ユーザーはすべてのトランザクションに対して静的な手数料率を設定できます。
  代わりに、ユーザーは手数料推定に頼るか、トランザクション毎に手数料率を設定する必要があります。
  これは、Bitcoin Core 31.0で削除対象としてマークされています。

- [Eclair #3050][]は、受信者が直接接続されたノードである場合に、
  [BOLT12][topic offers]支払いの失敗を中継する方法を更新し、
  読み取り不可能な`invalidOnionBlinding`の失敗で上書きするのではなく、
  常に失敗のメッセージを転送するようになりました。
  失敗に`channel_update`が含まれている場合、Eclairはそれを`TemporaryNodeFailure`で上書きして、
  [非公開チャネル][topic unannounced channels]の詳細が公開されないようにします。
  他のノードが関係する[ブラインドルート][topic rv routing]の場合、
  Eclairは引き続き、`invalidOnionBlinding`で失敗を上書きします。
  すべての失敗のメッセージは、ウォレットの`blinded_node_id`を使って暗号化されます。

- [Eclair #2963][]は、チャネルの強制閉鎖中にBitcoin Coreの`submitpackage`
  RPCコマンドを呼び出して、コミットメントトランザクションとそのアンカーの両方を一緒にブロードキャストすることで
  1P1C[パッケージリレー][topic package relay]を実装します。
  これにより、コミットメントトランザクションは、その手数料率がmempoolの最小値を下回っていても伝播できますが、
  Bitcoin Core 28.0以降に接続する必要があります。この変更により、
  コミットメントトランザクションの手数料率を動的に設定する必要がなくなり、
  ノードが現在の手数料率に同意しない際に強制閉鎖がスタックしなくなります。

- [Eclair #3045][]は、シングルパートの[トランポリンペイメント][topic trampoline payments]の外側の
  Onionペイロードの`payment_secret`フィールドをオプションにします。
  これまでは、[マルチパスペイメント][topic multipath payments]（MPP）が使用されていなくても、
  すべてのトランポリンペイメントに`payment_secret`が含まれていました。
  BOLT11インボイスを処理する際にペイメントシークレットが必要になる可能性があるため、
  Eclairは提供されていない場合は復号時にダミーのシークレットを挿入します。

- [LDK #3670][]は、[トランポリンペイメント][topic trampoline payments]の処理と受け取りのサポートを追加しますが、
  トランポリンルーティングサービスの提供はまだ実装されていません。
  これはLDKが展開を予定する[非同期支払い][topic async payments]の前提条件です。

- [LND #9620][]は、必要なパラメーターとジェネシスハッシュなどのブロックチェーン定数を追加することで、
  [testnet4][topic testnet]のサポートを追加します。

{% include snippets/recap-ad.md when="2025-04-08 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31363,31278,3050,2963,3045,3670,9620,32080" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[back crsig]: https://bitcointalk.org/index.php?topic=206303.msg2162962#msg2162962
[bip119 prechange]: https://github.com/bitcoin/bips/blob/9573e060e32f10446b6a2064a38bdc2047171d9c/bip-0119.mediawiki
[news75 ctv]: /ja/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news190 recursive]: /ja/newsletters/2022/03/09/#script
[modern ctv]: /ja/newsletters/2019/12/18/#proposed-changes-to-bip-ctv
[rubin enumeration]: https://gnusha.org/pi/bitcoindev/CAD5xwhjj3JAXwnrgVe_7RKx0AVDDy4X-L9oOnwhswXAQFoJ7Bw@mail.gmail.com/
[towns ctvmot]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8eUQCfCWjdivIzn@erisian.com.au/
[mn recursive]: https://mutinynet.com/address/tb1p0p5027shf4gm79c4qx8pmafcsg2lf5jd33tznmyjejrmqqx525gsk5nr58
[rubin recurse]: https://gnusha.org/pi/bitcoindev/CAD5xwhjsVA7k7ZQ_QdrcZOxdi+L6L7dvqAj1Mhx+zmBA3DM5zw@mail.gmail.com/
[osuntokun enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-1H2s5Dso0z5CjKcHcPvQjG6PMMXvgkzLwXgCHWxNV_Q@mail.gmail.com/
[towns enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8tes4tXo53_DRpU@erisian.com.au/
[ctv spookchain]: https://github.com/bitcoin/bips/pull/1792/files#diff-aaa82c3decf53fb4312de88fbb3cc081da786b72387c9fec7bfb977ad3558b91R589-R593
[ivgi minsc]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAGXD5f3EGyUVBc=bDoNi_nXcKmW7M_-mUZ7LOeyCCab5Nqt69Q@mail.gmail.com/
[minsc]: https://min.sc/
[poinsot alt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1JkExwyWEPJ9wACzdWqiu5cQ5WVj33ex2XHa1J9Uyew-YF6CLppDrcu3Vogl54JUi1OBExtDnLoQhC6TYDH_73wmoxi1w2CwPoiNn2AcGeo=@protonmail.com/
[moonsettler express]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Gfgs0GeY513WBZ1FueJBVhdl2D-8QD2NqlBaP0RFGErYbHLE-dnFBN_rbxnTwzlolzpjlx0vo9YSgZpC013Lj4SI_WZR0N1iwbUiNze00tA=@protonmail.com/
[obeirne readiness]: https://mailing-list.bitcoindevs.xyz/bitcoindev/45ce340a-e5c9-4ce2-8ddc-5abfda3b1904n@googlegroups.com/
[nick dlc]: https://gist.github.com/jonasnick/e9627f56d04732ca83e94d448d4b5a51#dlcs
[lava 30m]: https://x.com/MarediaShehzan/status/1896593917631680835
[news322 csv-bitvm]: /ja/newsletters/2024/09/27/#client-side-validation-csv
[news253 ark 0conf]: /ja/newsletters/2023/05/31/#making-internal-transfers
[clark doc]: https://ark-protocol.org/intro/clark/index.html
[oor doc]: https://ark-protocol.org/intro/oor/index.html
[lopp destroy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_cF=UKVa7CitXReMq8nA_4RadCF==kU4YG+0GYN97P6hQ@mail.gmail.com/
[boris timelock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAFC_Vt54W1RR6GJSSg1tVsLi1=YHCQYiTNLxMj+vypMtTHcUBQ@mail.gmail.com/
[habovstiak gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJY=dv6cZ_HoUNQybF4-byGOjME3Jt2DRr20yZqMmdJUnQ@mail.gmail.com/
[news141 gfsig]: /ja/newsletters/2021/03/24/#taproot-improvement-in-post-qc-recovery-at-no-onchain-cost-qc-taproot
[guy fawkes signature scheme]: https://www.cl.cam.ac.uk/archive/rja14/Papers/fawkes.pdf
[fournier gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJYaLMciqYxNFa6qT6-WCsSD3P9pP7boYs=k0htAdnAR6g@mail.gmail.com/T/#ma2a9878dd4c63b520dc4f15cd51e51d31d323071
[wuille nonpublic]: https://mailing-list.bitcoindevs.xyz/bitcoindev/pXZj0cBHqBVPjkNPKBjiNE1BjPHhvRp-MwPaBsQu-s6RTEL9oBJearqZE33A2yz31LNRNUpZstq_q8YMN1VsCY2vByc9w4QyTOmIRCE3BFM=@wuille.net/T/#mfced9da4df93e56900a8e591d01d3b3abfa706ed
[cruz qramp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08a544fa-a29b-45c2-8303-8c5bde8598e7n@googlegroups.com/
[news347 bip119]: /ja/newsletters/2025/03/28/#bips-1792
[roose ctvcsfs]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/
[poinsot ctvcsfs1]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/4
[10101 shutdown]: https://10101.finance/blog/10101-is-shutting-down
[towns vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[obeirne ctv-vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/23
[sanders bitvm]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[obeirne liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/24
[kanjalkar liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/28
[poelstra liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/32
[news284 lnsym]: /ja/newsletters/2024/01/10/#ln-symmetry
[sanders versus]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[towns nonrepo]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[roose ctv-ark]: https://codeberg.org/ark-bitcoin/bark/src/branch/ctv
[roose ctv-for-ark]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/
[roose ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/5
[harding ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/8
[news256 ln-jit]: /ja/newsletters/2023/06/21/#jit-just-in-time
[ruffing gfsig]: https://gnusha.org/pi/bitcoindev/1518710367.3550.111.camel@mmci.uni-saarland.de/
[cruz bip]: https://github.com/chucrut/bips/blob/master/bip-xxxxx.md
[towns anticov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[ccv bip]: https://github.com/bitcoin/bips/pull/1793
[ingala ccv]: https://delvingbitcoin.org/t/op-checkcontractverify-and-its-amount-semantic/1527/
[news319 64byte]: /ja/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities
[poinsot nsequence]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/79
[provoost bridge]: https://mailing-list.bitcoindevs.xyz/bitcoindev/19f6a854-674a-4e4d-9497-363af306e3a0@app.fastmail.com/
[poinsot cleanup]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uDAujRxk4oWnEGYX9lBD3e0V7a4V4Pd-c4-2QVybSZNcfJj5a6IbO6fCM_xEQEpBvQeOT8eIi1r91iKFIveeLIxfNMzDys77HUcbl7Zne4g=@protonmail.com/
[cleanup bip]: https://github.com/darosior/bips/blob/consensus_cleanup/bip-cc.md
[news312 chilldkg]: /ja/newsletters/2024/07/19/#frost
[fnr secp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d0044f9c-d974-43ca-9891-64bb60a90f1f@gmail.com/
[secp256k1lab]: https://github.com/secp256k1lab/secp256k1lab
[corallo eltoo]: https://x.com/TheBlueMatt/status/1857119394104500484
[bdk wallet 1.2.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.2.0
[ldk v0.1.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.2
[news341 pr review]: /ja/newsletters/2025/02/14/#bitcoin-core-pr-review-club