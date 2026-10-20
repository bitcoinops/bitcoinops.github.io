---
title: 'Bitcoin Optech Newsletter #361'
permalink: /ja/newsletters/2025/07/04/
name: 2025-07-04-newsletter-ja
slug: 2025-07-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNにおけるOnionメッセージリレーで使用されるネットワーク接続とピア管理を、
HTLCリレーで使用されるものと分離する提案を掲載しています。また、Bitcoinのコンセンサスの変更に関する議論や、
人気のBitcoinインフラストラクチャソフトウェアの最近の更新など、恒例のセクションも含まれています。

## ニュース

- **OnionメッセージとHTLCリレーの分離:** Olaluwa Osuntokunは、
  ノードが[Onionメッセージ][topic onion messages]のリレーと、
  [HTLC][topic htlc]のリレーに、それぞれ別の接続を使用できるようにすることについて
  Delving Bitcoinに[投稿しました][osuntokun onion]。直接リレーの場合のように（
  ニュースレター [#283][news283 oniondirect]および[#304][news304 onionreply]参照）、
  現在でも別々の接続が可能な場合もありますが、Osuntokunは、分離した接続を常にオプションとして利用可能にし、
  ノードが支払いのリレーに使用するピアのセットとは異なるOnionメッセージ用のピアのセットを持てるようにすることを提案しています。
  彼は、この代替アプローチを支持するいくつかの論点を挙げています:
  関心事をより明確に分離できること、ノードはチャネルピアよりも高密度なOnionメッセージピアを安価にサポートできること（
  チャネルの作成にはコストがかかるため）、分離によりプライバシー向上のための鍵ローテションを導入できること、
  HTLCコミットメント通信プロトコルによってブロックされる必要がないためOnionメッセージの配信速度が向上する可能性があること。
  Osuntokunは、提案されたプロトコルについて、詳細な情報を提供しています。

  回答した開発者の何人かが懸念していたのは、Onionメッセージのネットワークが、
  過剰な数のピアによるノードへのフラッディングをどのように防ぐかという点でした。
  現在のOnionメッセージの実装では、各ノードは通常、チャネルパートナーとの接続のみを保持しています。
  チャネルに資金を提供するUTXOの作成には費用（オンチェーン手数料と機会費用）がかかり、
  ノードとチャネルパートナーに固有のものです。つまり、1つのUTXOに対して1つの接続が確立されます。
  仮に、Onionメッセージの接続がオンチェーン資金で裏付けられる場合でも、
  1つのUTXOですべての公開LNノードへの接続を確立できます。つまり、1つのUTXOで数千の接続が確立されるということです。

  少なくとも1人の回答者はOsuntokunの提案を支持していましたが、
  これまでのところ複数の回答者がサービス拒否リスクへの懸念を表明しています。
  この記事の執筆時点では、議論は継続中でした。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **PTLCにおけるCTV+CSFSの利点:** 開発者たちは、さまざまな展開済みおよび想定されるプロトコルにおける
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)と
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS)、
  あるいはその両方による利点について、以前の議論（[ニュースレター #348][news348 ctvstep]参照）を続けました。
  特に興味深いのは、Gregory SandersがCTV+CSFSについて「たとえ
  [LN-Symmetry][topic eltoo]自体が採用されなくても、CTV+CSFSは
  LNを[PTLC][topic ptlc]に更新するのを加速させるでしょう。
  再バインド可能な署名は、プロトコルを積み重ねる際の負担を大幅に軽減します」と[述べています][sanders ptlc]。
  Sjors Provoostが詳細を[尋ねた][provoost ptlc]ところ、Sandersは[返信で][sanders ptlc2]
  PTLCのLNメッセージの変更に関する以前の研究（[ニュースレター #268][news268 ptlc]参照）の[リンク][sanders gist]を提供し、
  「現在のプロトコルでもPTLCは決して不可能ではないが、再バインド可能な署名があれば大幅にシンプルになる」と付け加えました。

  Anthony Townsは、さらに次のように[言及しました][towns ptlc]。
  「PTLCでの開示を[musig][topic musig] 2-of-2（オンチェーンでは効率的）と組み合わせて行うための
  ツールや標準も不足しています。また、（`x CHECKSIGVERIFY y CHECKSIG`のような）
  一般的なトランザクションの署名でさえも同様です。[...]これには、musig2用の[アダプター署名][topic adaptor signatures]が必要ですが、
  それは仕様には含まれておらず、secp256k1の実装から[削除されました][libsecp256k1 #1479]。
  効率は低くなるものの別にアダプター署名として実現することは可能ですが、
  [Schnorr署名][topic schnorr signatures]用の単純なアダプター署名さえsecp256k1では利用できません。
  これらは実験的なsecp256k1-zkpプロジェクトにも含まれていません。[...]
  ツールが準備されていれば、PTLCのサポートが追加される可能性はありますが[...]
  暗号関連の標準化と洗練に注力するほどの優先度が高いと考える人はいないと思います。[...]
  [CAT][topic op_cat]+CSFSが利用可能であればツールの問題は回避できますが、
  オンチェーンの効率性は犠牲になります。[...]CSFSのみが利用可能な場合は、
  相手方が署名に必要なRの値を選択するのを防ぐためアダプター署名を使用する必要があり、
  同様のツールの問題が引き続き発生するでしょう。これらの問題は、
  Gregory Sandersが説明した更新の複雑さやピアプロトコルの更新とは無関係です。」

- **Vaultアウトプットスクリプトディスクリプター:** Sjors Provoostは、
  [Vault][topic vaults]を使用するウォレットのリカバリー情報を
  [アウトプットスクリプトディスクリプター][topic descriptors]を使って指定する方法を
  Delving Bitcoinに[投稿しました][provoost ctvdesc]。特に、James O'Beirneの
  [simple-ctv-vault][]概念実証実装（[ニュースレター #191][news191 simple-ctv-vault]参照）で提供されているような
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)ベースのVaultに焦点を当てました。

  Provoostは、Salvatore Ingalaの「私の見解では、ディスクリプターはこの目的には適用さないツールです」
  という[コメント][ingala vaultdesc]を引用しました。
  Sanket Kanjalkarは現在のスレッドでこの意見に[同意し][kanjalkar vaultdesc1]ましたが、回避策を[発見しました][kanjalkar vaultdesc2]。
  Kanjalkarは、資金をより一般的なディスクリプターにデポジットし、
  そこからCTV Vaultに移動させる、CTVベースのVault版について説明しました。
  これにより、知識の浅いユーザーが資金を失う可能性のある状況を回避できるだけでなく、
  標準的なディスクリプターへのすべての資金が毎回同じ設定でVaultに移動されることを前提とした
  ディスクリプターの作成が可能になります。これによりCTV Vaultディスクリプターは、
  ディスクリプター言語に無理な変更を加えることなく、簡潔で完全なものになります。

- **BitVMにおけるCTV+CSFSの利点に関する議論の続き:** 開発者たちは、
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)および
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) opcodeの利用により、
  「BitVMのトランザクションサイズを約1/10に削減」し、非対話型のペグインを可能にする方法について、
  以前の議論（[ニュースレター #354][news354 bitvm]参照）を続けました。
  Anthony Townsは、当初提案されたコントラクトの脆弱性を[指摘][towns ctvbitvm]し、
  彼と他の開発者たちは回避策を説明しました。CTVではなく提案中の
  [OP_TXHASH][]を使用する利点が追加で議論されました。Chris Stewartは、
  Bitcoin Coreのテストソフトウェアを使って、議論されたアイディアのいくつかを[実装し][stewart ctvimp]、
  議論の該当部分を検証し、レビュー担当者に具体的な例を提供しました。

- **CTVとCSFSに関する公開書簡:** James O'Beirneは、
  Bitcoin-Devメーリングリストに公開書簡を投稿しました。
  これには（本稿執筆時点で）66名の署名が寄せられており、その多くはBitcoin関連プロジェクトのコントリビューターです。
  この書簡は「Bitcoin Coreのコントリビューターに対し、今後6ヶ月以内に
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)と
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS)のレビューと
  統合を優先するよう要請」しています。このスレッドには60件以上の返信が寄せられています。
  いくつかの技術的なハイライトは次のとおりです:

  - *<!--concerns-and-alternatives-to-legacy-support-->レガシーサポートに関する懸念と代替案:*
    [BIP119][]は、witness script v1（[Tapscript][topic tapscript]）と
    レガシースクリプトの両方でCTVを定義しています。Gregory Sandersは、
    「レガシースクリプトのサポートは[...]レビューの対象領域を大幅に拡大する一方で、
    プロトコルの機能向上やコスト削減の効果は不明です」と[述べています][sanders legacy]。
    O'Beirneは、レガシースクリプトのサポートで場合によっては約8vbyteを節約できる可能性があると[返信][obeirne legacy]しましたが、
    Sandersはこの節約をwitness scriptで可能にする彼の以前のP2CTV（pay-to-CTV）提案と
    概念実証の実装を[リンクしました][sanders p2ctv]。

  - *CTVのみのVautlサポートの限界:* 署名者のJameson Loppは、「[Vault][topic vaults]に最も関心がある」と[述べ][lopp ctvvaults]、
    CTV Vaultが提供する特性、現在事前署名トランザクションを使って導入可能なVaultとの比較、
    （特にコンセンサスの変更を必要とする高度なVaultと比較して）セキュリティが実質的に向上するかどうかについて議論を始めました。
    この議論による主な要点は以下のとおりです:

    - *<!--address-reuse-danger-->アドレス再利用の危険性:* 事前署名VaultもCTV Vaultもどちらも、
      ユーザーがVaultアドレスを再利用できないようにする必要があり、そうしないと資金が失われる可能性があります。
      これを実現する方法の1つは、Vaultに資金をデポジットするのに2つのオンチェーントランザクションが必要になる
      2段階のVault手順です。追加のコンセンサスの変更を必要とする高度なVaultはこの問題を持たず、
      再利用されたアドレスへのデポジットも可能です（ただし、当然ながら[プライバシーは低下します][topic output linking]）。

    - *<!--theft-of-staged-funds-->ステージング資金の盗難:* 事前署名VaultもCTV Vaultも
      認可された引き出しの盗難が可能です。たとえば、Vaultユーザーのボブがアリスに1 BTC支払うとします。
      事前署名VaultとCTV Vaultでは、ボブは以下の手順で支払いを行います:

      - 自分のVaultから1 BTC（場合によっては手数料も）をステージングアドレスに引き出します。

      - Vaultで定義された時間待機します。

      - 1 BTCをアリスに送金します。

      マロリーがボブのステージング鍵を盗んだ場合、引き出しが完了してからアリスへのトランザクションが承認されるまでの間に、
      マロリーは1 BTCを盗むことができます。しかしマロリーが引き出し用の鍵を盗んだとしても、
      ボブは保留中の引き出しを中断し、超安全な鍵（または複数の鍵）で保護された安全なアドレスに資金をリダイレクトできるため、
      マロリーはVaultに残っている資金を盗むことはできません。

      より高度なVaultでは、ステージングの手順は不要です。ボブの引き出しは、
      アリスまたは安全なアドレスのいずれかにしか送れません。これにより、
      マロリーは引き出しと支払いの間で資金を盗むことができなくなります。

    - *<!--key-deletion-->鍵の削除:* 事前署名Vaultに対するCTVベースのVaultの利点の1つは、
      事前署名済みのトランザクションセットのみが利用可能なオプションであることを保証するために、
      秘密鍵を削除する必要がないことです。しかし、Gregory Maxwellは、
      トランザクションに署名した直後に鍵を削除し、ユーザーに秘密鍵を公開しないソフトウェアを設計するのは簡単だと
      [指摘しています][maxwell autodelete]。現在、これを直接サポートするハードウェア署名デバイスは確認されていませんが、
      少なくとも1つのデバイスがユーザーの手動操作によりこれをサポートしています。しかし、
      （私たちの知る限り）現在、テスト用であってもCTVをサポートするハードウェアはありません。
      より高度なVaultはCTVのキーレスの利点を共有しますが、ソフトウェアとハーウェアへの統合も必要になります。

    - *<!--static-state-->静的な状態:* 事前署名Vaultに対するCTVベースのVaultの利点の1つは、
      静的バックアップからウォレットを復元するために必要なすべての情報（
      [アウトプットスクリプトディスクリプター][topic descriptors]など）を計算できる可能性があることです。
      しかし、事前署名された状態の非決定論的なパーツをオンチェーントランザクション自体に保存することで
      静的バックアップを可能にする事前署名Vaultに関する研究も既に行われています（[ニュースレター #255][news255 presig vault state]参照）。
      Optechは、より高度なVaultであれば静的な状態から復元できると考えていますが、
      本記事の執筆時点では検証できていません。

  - *Bitcoin Coreコントリビューターからの回答:* この記事の執筆時点で、
    Optechが現在アクティブなBitcoin Coreコントリビューターと認識している4名が、
    メーリングリストの書簡に回答しました。彼らは次のように述べています:

    - [Gregory Sanders][sanders ctvcom]: 「この書簡は技術コミュニティからのフィードバックを求めるものであり、
      これは私からのフィードバックです。何年も更新されていない未展開のBIPは、
      一般的に健全な提案の兆候ではなく、細心の注意を払ってきた人からの技術アドバイスを拒否する根拠にはなりません。
      私はこの枠組み、この提案への変更の基準を重大な破壊のみに引き上げること、
      そしてBIP119を現状のまま期限付きで終了させることに反対します。私は依然として
      （機能的な意味で）CTV＋CSFSは検討に値すると考えていますが、これはBIP119を頓挫させる確実な方法です。」

    - [Anthony Towns][towns ctvcom]: 「私の見解では、
      CTVの議論は重要なステップを逃しており、それらのステップを踏む代わりに、
      推進派は少なくとも3年間、世論の圧力を利用して「早期導入」を強制しようとし続けています。
      私は、CTV推進派が見落としていると思われるステップを踏めるよう支援してきましたが、
      建設的な成果は得られず、沈黙や侮辱を受けるだけでした。少なくとも私の立場からすると、
      これはインセンティブの問題を悪化させているだけで、解決にはつながっていないように思います。」

    - [Antoine Poinsot][poinsot ctvcom]: 「この書簡の影響は、予想どおり、
      この提案（あるいはより広義には、この一連の機能）の進捗に大きな後退をもたらしました。
      この状況からどのように立て直すかは分かりませんが、誰かが立ち上がり、
      コミュニティからの技術的なフィードバックに実際に対応し、
      （実際の）ユースケースを示す作業が不可欠です。前進するには、
      客観的かつ技術的な強力な議論に基づいて合意形成する必要があります。
      多くの人が関心を表明するだけで、誰も行動を起こさず、提案の前進を支援しないという状況ではだめです。」

    - [Sjors Provoost][provoost ctvcom]: 「私自身の動機についても少し触れさせてください。
      Vaultは、この提案によって可能になる機能の中で、個人的に取り組む価値があると感じている唯一の機能のように思います。
      [...]つい最近まで、Vaultの勢いはOP_VAULTにあり、そのためにはOP_CTVが必要になるように思えました。
      しかし、単一の目的のopcodeというのは理想的なではないため、このプロジェクトは進展が無いように思えました。
      [...]一方で、CTV + CSFSには反対しません。これらが有害だという主張は聞いたことがありません。
      MeVilの可能性がほとんどないので、他の開発者がこれらの変更を慎重に開発して展開することも想像できます。
      私はそのプロセスを注視するだけです。私が反対するのは、共同署名者のPaul Sztorcが提案したような、
      Pythonベースの代替実装とアクティベーションクライアントです。」

  - *<!--signatory-statements-->署名者の声明:* 書簡の署名者もその後の声明で彼らの意図を明確にしました:

    - [James O'Beirne][obeirne ctvcom]: 「署名した全員が、CTV+CSFSについて、
      早期のレビュー、統合、そしてアクティベーション計画を明確に確認したいと考えています。」

    - [Andrew Poelstra][poelstra ctvcom]: 「書簡の初期のドラフトでは、
      実際の統合、さらにはアクティベーションまでを求めていましたが、私はいずれの初期ドラフトにも署名しませんでした。
      優先順位と計画に関する表現（そして、ある種の要求ではなく「敬意ある依頼」）へと弱められた後、ようやく署名しました。」

    - [Steven Roose][roose ctvcom]: 「この書簡は単にCoreコントリビューターに対し、
      この提案をある程度の緊急性を持って議題に載せることを求めているだけです。脅しや厳しい言葉もありません。
      これまでこの提案に関する他の議論に参加したCoreコントリビューターはごくわずかだったため、
      Coreコントリビューターにこの議論における立場を表明してほしいという意思を伝えるのが適切な次のステップだと思いました。
      私は、独立したアクティベーションクライアント含むアプローチには強く反対しており、
      このメールの趣旨は、プロトコルアップグレードの展開にCoreが関与することを望むという私たちの考えと一致している思っています。」

    - [Harsha Goli][goli ctvcom]: 「ほとんどの人が署名したのは、次のステップがどうあるべきか全く分からなかったからです。
      トランザクションコミットメントに対するプレッシャーがあまりにも大きかったため、
      （署名付きの書簡という）悪手でも、何もしないよりましだと判断したのです。
      （私の業界調査で促進された）書簡が送られる前の話し合いでは、署名者の多くから、この文書について警告する声しかありませんでした。
      実際、この書簡を明確に良いアイディアだと考えた人は一人もいません。それでも署名しました。そこにシグナルがあるんです。」

- **OP_CATが可能にするWinternitz署名:** 開発者のConduitionは、
  提案中の[OP_CAT][topic op_cat] opcodeと他のスクリプト命令を用いて、
  Winternitzプロトコルを使用した[量子耐性][topic quantum resistance]署名をコンセンサスロジックで検証する
  [プロトタイプ実装][conduition impl]をBitcoin-Devメーリングリストに[投稿しました][conduition winternitz]。
  Conduitionの実装では、鍵、署名、スクリプトで約8,000 byteを必要とします（その大部分はwitnessディスカウントの対象となり、
  オンチェーンweightは約2,000 vbyteになります）。これは、Jeremy Rubinが[以前提案した][rubin lamport]
  `OP_CAT`ベースの別の量子耐性[ランポート署名][Lamport signature]方式よりも、約8,000 vbyte小さいものです。

- **<!--commit-reveal-function-for-post-quantum-recovery-->ポスト量子リカバリーのためのコミット/開示機能:** Tadge Dryjaは、
  高速な量子コンピューターが支払いに使用されようとしているアウトプットをリダイレクト（盗むことが）できる場合でも、
  [量子脆弱][topic quantum resistance]な署名アルゴリズムを使用してUTXOを使用できるようにする方法を
  Bitcoin-Devメーリングリストに[投稿しました][dryja fawkes]。
  これにはソフトフォークが必要で、Tim Ruffingによる以前の提案（[ニュースレター #348][news348 fawkes]参照）の変形版です。

  Dryjaのスキームでアウトプットを使用するには、支払人は3つのデータへのコミットメントを作成します:

  1. 資金を管理する秘密鍵に対応する公開鍵のハッシュ`h(pubkey)`。これを _アドレス識別子_ と呼びます。

  2. 公開鍵と支払人が最終的にブロードキャストしたいトランザクションのtxidとハッシュ`h(pubkey, txid)`。
     これを _シーケンス依存証明_ と呼びます。

  3. 最終的なトランザクションのtxid。これを _コミットメントtxid_ と呼びます。

  これらの情報はいずれも、基礎となる公開鍵を明かすものではありません。この方式では、
  UTXOを管理する人物だけが公開鍵を知っていると仮定します。

  3つのパーツで構成されるコミットメントは、量子安全なアルゴリズムを用いたトランザクション（たとえば、
  `OP_RETURN`アウトプット）でブロードキャストされます。この時点で、
  攻撃者は同じアドレス識別子と異なるコミットメントtxidを使って、
  攻撃者のウォレットに資金を送金する独自のコミットメントをブロードキャストしようとする可能性があります。
  しかし、攻撃者はベースとなる公会鍵を知らないため、有効なシーケンス依存証明を生成することはできません。
  これは完全な検証ノードですぐには分かりませんが、UTXOの所有者が公開鍵を明かした後で、
  攻撃者のコミットメントを拒否することができます。

  コミットメントが適切な深さまで承認された後、支払人はコミットメントtxidと一致する完全なトランザクションを公開します。
  フルノードは、公開鍵がアドレス識別子と一致し、txidと組み合わせてシーケンス依存証明と一致することを検証します。
  この時点で、フルノードはそのアドレス識別子に対する最も古い（最も深く承認された）コミットメント以外をすべて削除します。
  有効なシーケンス依存証明を持つそのアドレス識別子で最初に承認されたtxidのみが、承認済みトランザクションとして解決できます。

  Dryjaは、このスキームをソフトフォークとして展開する方法、
  コミットメントバイトを半分に削減する方法、そして現在のユーザーとソフトウェアがこのスキームの使用に備えてできること、
  そしてスクリプト型および[スクリプトレスマルチシグ][topic multisignature]のユーザーにとっての
  このスキームの制限についてさらに詳しく説明しています。

- **トランザクションスポンサーシップをサポートするOP_TXHASHの変形版:** Steven Rooseは、
  `OP_TXHASH`の変形版である`TXSIGHASH`についてDelving Bitcoinに[投稿しました][roose txsighash]。
  これは、64 byteの[Schnorr署名][topic schnorr signatures]を拡張し、
  署名がトランザクション（または関連トランザクション）のどのフィールドにコミットするかを示すbyteを追加します。
  Rooseは、`OP_TXHASH`に以前提案されたコミットメントフィールドに加えて、
  効率的な形式の[トランザクションスポンサーシップ][topic fee sponsorship]（[ニュースレター #295][news295 sponsor]参照）を使用して
  ブロック内のそれより前のトランザクションに署名をコミットできると指摘しています。
  そして、このメカニズムのオンチェーンコストを既存の[CPFP][topic cpfp]や
  以前のスポンサーシップの提案と比較して分析し、次のように結論づけています: 「
  [`TXSIGHASH`]スタッキングでは、スタックされた各トランザクションの仮想byteコストは、
  スポンサーを含まない元のコストよりもさらに低くなる可能性があります。[...]
  さらに、すべてのインプットは単純なkey-spendであるため、[CISA][topic cisa]が導入されれば集約できます。」

  この記事の執筆時点では、この投稿への返信はありませんでした。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32540][]では、`/rest/spenttxouts/BLOCKHASH` RESTエンドポイントが導入されました。
  このエンドポイントは、指定されたブロックで使用されたトランザクションアウトプット（prevouts）のリストを、
  主にコンパクトなバイナリ（.bin）形式、また.jsonおよび.hex形式で返します。
  これまでも、`/rest/block/BLOCKHASH.json`エンドポイントで同様の処理が可能でしたが、
  この新しいエンドポイントでは、JSONシリアライゼーションのオーバーヘッドが排除されるため、
  外部のインデクサーのパフォーマンスが向上します。

- [Bitcoin Core #32638][]では、ディスクから読み込まれたブロックが
  期待されるブロックハッシュと一致することを確認する検証機能が追加され、
  これまで検出できなかったビット腐敗やインデックスの混同を検出できるようになります。
  [Bitcoin Core #32487][]で導入されたヘッダーハッシュキャッシュのおかげで、
  この追加チェックには実質オーバーヘッドはありません。

- [Bitcoin Core #32819][]および[#32530][Bitcoin Core #32530]は、
  32-bitシステムにおいて、起動パラメーター`-maxmempool`と`-dbcache`の最大値をそれぞれ
  500MBと1GBに設定しました。このアーキテクチャのRAMの総上限は4GBであるため、
  新しい制限を超える値を設定すると、メモリ不足（OOM）が発生する可能性があります。

- [LDK #3618][]は、[非同期支払い][topic async payments]用のクライアント側のロジックを実装し、
  オフラインの受信ノードが常時オンラインのヘルパーLSPノードを使用して[BOLT12
  オファー][topic offers]と静的インボイスを事前に準備できるようにします。
  このPRは、`ChannelManager`内に、オファーとインボイスを構築、保存および永続化する非同期受信オファーキャッシュを導入します。
  また、LSPとの通信に必要な新しいOnionメッセージとフックを定義し、
  ステートマシンを`OffersMessageFlow`に組み込みます。

{% include snippets/recap-ad.md when="2025-07-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32540,32638,32819,3618,32487,32530,1479" %}
[news255 presig vault state]: /ja/newsletters/2023/06/14/#taproot-annex
[news348 ctvstep]: /ja/newsletters/2025/04/04/#ctv-csfs
[news268 ptlc]: /ja/newsletters/2023/09/13/#ptlc-ln
[news191 simple-ctv-vault]: /ja/newsletters/2022/03/16/#ctv
[news354 bitvm]: /ja/newsletters/2025/05/16/#op-ctv-op-csfs-bitvm
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[osuntokun onion]: https://delvingbitcoin.org/t/reimagining-onion-messages-as-an-overlay-layer/1799/
[news283 oniondirect]: /ja/newsletters/2024/01/03/#ldk-2723
[news304 onionreply]: /ja/newsletters/2024/05/24/#core-lightning-7304
[sanders ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[provoost ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/80
[sanders ptlc2]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/81
[sanders gist]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[towns ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/82
[provoost ctvdesc]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/
[simple-ctv-vault]: https://github.com/jamesob/simple-ctv-vault
[ingala vaultdesc]: https://github.com/bitcoin/bips/pull/1793#issuecomment-2749295131
[kanjalkar vaultdesc1]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/3
[kanjalkar vaultdesc2]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/9
[towns ctvbitvm]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/8
[op_txhash]: /ja/newsletters/2022/02/02/#ctv-apo
[stewart ctvimp]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/25
[obeirne letter]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a86c2737-db79-4f54-9c1d-51beeb765163n@googlegroups.com/
[sanders legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b17d0544-d292-4b4d-98c6-fa8dc4ef573cn@googlegroups.com/
[obeirne legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfKEgA0RCvxR=mP70sfvpzTphTZGidy=JuSK8f1WnM9xYA@mail.gmail.com/
[sanders p2ctv]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/72?u=harding
[lopp ctvvaults]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fxwKLdst9tYQqabUsJgu47xhCbwpmyq97ZB-SLWQC9Xw@mail.gmail.com/
[maxwell autodelete]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAAS2fgSmmDmEhi3y39MgQj+pKCbksMoVmV_SgQmqMOqfWY_QLg@mail.gmail.com/
[sanders ctvcom]: https://groups.google.com/g/bitcoindev/c/KJF6A55DPJ8/m/XVhyLCJiBQAJ
[towns ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEu8CqGH0lX5cBRD@erisian.com.au/
[poinsot ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/GLGZ3rEDfqaW8jAfIA6ac78uQzjEdYQaJf3ER9gd4e-wBXsiS2NK0wAj8LWK8VHf7w6Zru3IKbtDU5NM102jD8wMjjw8y7FmiDtQIy9U7Y4=@protonmail.com/
[provoost ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0B7CEBEE-FB2B-41CF-9347-B9C1C246B94D@sprovoost.nl/
[obeirne ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfLc5-=UVpcvYrC=VP7rLRroFviLTjPQfeqMQesjziL=CQ@mail.gmail.com/
[poelstra ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEsvtpiLWoDsfZrN@mail.wpsoftware.net/
[roose ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/035f8b9c-9711-4edb-9d01-bef4a96320e1@roose.io/
[goli ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/mc0q6r14.59407778-1eb1-4e57-bcf2-c781d6f70b01@we.are.superhuman.com/
[conduition winternitz]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uCSokD_EM3XBQBiVIEeju5mPOy2OU-TTAQaavyo0Zs8s2GhAdokhJXLFpcBpG9cKF03dNZfq2kqO-PpxXouSIHsDosjYhdBGkFArC5yIHU0=@proton.me/
[conduition impl]: https://gist.github.com/conduition/c6fd78e90c21f669fad7e3b5fe113182
[lamport signature]: https://ja.wikipedia.org/wiki/ランポート署名
[dryja fawkes]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cc2f8908-f6fa-45aa-93d7-6f926f9ba627n@googlegroups.com/
[news348 fawkes]: /ja/newsletters/2025/04/04/#sha256-utxo
[roose txsighash]: https://delvingbitcoin.org/t/jit-fees-with-txhash-comparing-options-for-sponsorring-and-stacking/1760
[news295 sponsor]: /ja/newsletters/2024/03/27/#transaction-fee-sponsorship-improvements
