---
title: 'Bitcoin Optech Newsletter #412'
permalink: /ja/newsletters/2026/07/03/
name: 2026-07-03-newsletter-ja
slug: 2026-07-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinのコンセンサスルールの変更に関する議論のまとめや、
新しいリリースおよびリリース候補の発表、人気のBitcoinイ基盤ソフトウェアの注目すべき更新など、
恒例のセクションを掲載しています。

## ニュース

*今週は、どの[情報源][sources]からも重要なニュースは見つかりませんでした。*

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **SLH-DSAのSTARK集約のベンチマーク**: Remix7531は、多数の[SPHINCS][news383 sphincs]署名検証を
  単一のSTARK証明に集約したベンチマーク結果をBitcoin-Devメーリングリストに[投稿しました][rs ml starkbench]。
  これは、STARKを使って[ポスト量子][topic quantum resistance]ブロックをスケーリングするという
  Ethan Heilmanの以前の[提案][eh ml starkagg]に続くものです。このベンチマークスイート(RISC ZeroのzkVM上に構築)では、
  証明時間は署名数にほぼ線形にスケールし(RTX 5090上で1署名あたり約3.1秒)、
  証明サイズは署名数に対して劣線形に増加し(署名1件で218KiB、署名512件で454KiB、素の署名なら3.8 MiB)、
  検証時間はバッチサイズにかかわらず12〜15ミリ秒程度に留まります。
  ブロック全体を1台のGPUで証明するには依然として数時間かかりますが、
  Remixは専用のAIR回路(汎用zkVMではなく署名検証に特化した多項式制約)、mempoolでの前処理、
  マルチGPUでの証明によりこれを改善できる可能性があると示唆しています。
  また、このベンチマークは、よりコンパクトなBitcoin向けに最適化された[SPHINCS+][news386 jn hash]バリアントではなく、
  標準のSPHINCSを使用しています。

- **Bird of Prey 2(BoP-2): 非マリアブルなSchnorr + PQ署名**:
  Pieter Wuilleは、[Schnorr][topic schnorr signatures]系の署名方式と任意の
  [ポスト量子][topic quantum resistance]署名方式からハイブリッドな強偽造不可能な署名方式を構築することに関する
  EuroCrypt 2026の論文について、Delving Bitcoinに[投稿しました][pw delving bop2]。
  両方式の署名を単純に連結するだけでも、少なくとも一方が安全であれば偽造不可能ではありますが、強偽造不可能ではありません。
  どちらかの方式が破られると、攻撃者は署名全体としては有効なまま、破られた方式の部分署名を差し替えることができます。
  論文のBoP-2構成は、Schnorr署名のチャレンジハッシュにポスト量子署名へのコミットメントを含めることで、これを回避します。

  Adam GibsonとConduitionは、[Segwit][topic segwit]以降はwitnessがtxidに影響しなくなったため、
  強偽造不可能性が依然として重要なのかどうかを議論しました。
  Wuilleは、量子的あるいは古典的な暗号の破壊によって、
  誰でも破られた方式の署名要素をマリアブル化(改変)できるようになることが懸念点だと説明しました。
  Conduitionは、この構成をBoris Nagaevの省スペースなハイブリッドハッシュベースの設計(下記の格子ベース署名の項を参照)と比較し、
  BoP-2の方がより強力な統合ハイブリッド方式の有力候補に見えると結論づけましたが、
  WuilleとConduitionはどちらも、個別の[BIP360][]（[P2MR][news393 p2mr]）リーフや
  単純なスクリプトの組み合わせで同様の結果を達成できる場合に、
  統合ハイブリッド方式がその複雑さに見合う価値があるのかについては疑問を呈しました。

- **<!--lattice-based-signatures-->格子ベース署名**: Nikita Karetnikovは、ポスト量子署名ファミリーを比較する
  Blockstreamの[ブログ記事][bs blog lattice]について、Delving Bitcoinに[投稿し][nk delving lattice]、
  Bitcoin-Devメーリングリストにも[クロスポストしました][nk ml lattice]。この比較では、
  格子ベースの方式がサイズと機能性の面で有利に見えます。彼は、
  なぜBitcoinのポスト量子関連の作業がハッシュベース署名に焦点を当てているのか尋ねました。

  Conduitionは、より弱いセキュリティ仮定、実装のシンプルさ、高速な検証、
  そして長期的なフォールバックとしての適性ゆえに、ハッシュベース署名はBitcoinにとって依然として魅力的だと[返信しました][c ml lattice]。
  Mikhail Kudinovは、素朴に実装すると格子ベース署名は浮動小数点演算を必要とすることが多いが、
  Falconの浮動小数点演算は整数でシミュレートできると指摘しました。
  ConduitionとJesse Posnerは、統合ハイブリッドSchnorr+格子方式が必要なのか、
  それとも別々の[BIP360][](P2MR)リーフで同様のセキュリティを達成できるのかを議論しました。
  一方、Boris Nagaevは、ハイブリッド署名を複数の署名方式の単純な連結としてではなく単一の構成として扱うことによる
  スペースの節約について説明しました。たとえば、各方式が必要とする特定のランダム化パラメータを共有できる可能性があります。

- **P2MRのECリーフの公開鍵復元**: stariusは、
  [BIP360][](P2MR)に復元可能な楕円曲線(EC)鍵のリーフタイプを追加する提案をDelving Bitcoinに[投稿しました][st delving recover]。
  このアイデアは、[Schnorr][topic schnorr signatures]署名からEC公開鍵を復元するというものです。
  公開鍵はスクリプトの代わりにP2MRのマークルツリーにコミットされ、
  Schnorr署名のチャレンジは公開鍵そのものの代わりにマークルルートとコントロールブロックを含むように変更されます。
  マークルルートとコントロールブロックは署名時と検証時の両方で既知であるため、公開鍵を知らなくても署名を検証でき、
  その後コントロールブロックを介して公開鍵がマークルルートに含まれていることを検証できます。
  この手法を使うと、深さ1のSchnorrリーフのwitnessは135 byteから100 byteに縮小され、
  [P2TR][topic taproot]のkey-spendと[P2WPKH][topic segwit]の支出の中間のサイズになりますが、
  その代償としてBIP340のバッチ検証を諦めることになります。stariusとConduitionは、
  コントロールブロックをチャレンジに含めることで、
  複数のこうしたリーフが1つのツリーを共有する場合の関連鍵攻撃を防げると説明しました。
  Pieter Wuilleはこの構成を好意的にレビューしました。Anthony Towns、Pieter Wuille、
  Conduitionは、[BIP32][topic bip32]導出への影響、バッチ検証によるディスカウント、
  そしてConduitionの深さゼロツリー禁止案との相互作用について議論しました(深さゼロの復元可能リーフは、
  ポスト量子フォールバックなしの[P2TR][topic taproot]のwitnessサイズに匹敵し得る)。
  stariusは、witnessの解析ルールを変更するため、これはアクティベーション前にBIP360に組み込まれるべきだと説明しました。

- **P2MRにおけるプライバシーインセンティブの調整**: Conduitionは、
  すべてのP2MRコントロールブロックに少なくとも1つの32 byteのマークル認証パスを含めることを必須とする
  [BIP360][](P2MR)の変更案をBitcoin-Devメーリングリストに[投稿しました][c ml p2mrdepth]
  (つまり深さゼロのスクリプトツリーを禁止します)。深さゼロのツリーは、
  単一のスクリプトパスのみを必要とする一部のプロトコルが[P2TR][topic taproot]よりもP2MRで効率的になり、
  協調的な署名パスを省略する誤ったインセンティブが生じ、
  一部のコントラクトプロトコルをオンチェーンで識別しやすくなります。

  Antoine Poinsotは、この変更がそのプライバシー上の懸念に対処することには同意しましたが、
  典型的な単一鍵のP2MR支払いはP2TRv2よりもコストが約15%高いため(前述の鍵復元を使えばもっと少なくなる可能性あり)、
  大規模な移行には依然として[P2TRv2][news403 pqout]を選好しています。Pieter Wuilleは、
  長期的なポスト量子効率よりも量子以前の導入インセンティブの方が重要であり、
  P2TRv2の方が移行コストを最小化できると主張しました。また、P2MRは、
  将来のソフトフォークでP2MR内の楕円曲線パスが無効化されることをユーザーが当てにできる場合にのみ意味を持つとも指摘しました。
  Conduitionは、どちらの設計でも自発的な移行率は同様に低いと予測し、一般的な楕円曲線支払いに対する
  今後のwitnessサイズの最適化(次の項を参照)に言及しました。Hayashiは、コスト差をさらに縮めるために、
  P2MRのSchnorrリーフに追加のwitnessディスカウントを与えることを[提案しました][h ml p2mrdepth]。

- **<!--prohibit-merkle-internal-node-preimages-that-encode-minimal-64-byte-transactions-->最小の64 byteトランザクションをエンコードするマークル内部ノードのプリイメージの禁止**:
  Jeremy Rubinは、witnessを除いた64 byteのトランザクションをコンセンサス上無効とする
  [コンセンサスクリーンアップ][topic consensus cleanup]([BIP54][])のルールに代わる案を提案するドラフトBIPを
  Bitcoin-Devメーリングリストに[投稿しました][jr ml merkle64]。Rubinのルールは、
  トランザクション自体を禁止するのではなく、トランザクションマークルツリー内に、
  1インプット1アウトプット、witnessを除いたトランザクションのbyteレイアウトを持つノードプリイメージが含まれるブロックを無効とします。
  これは、潜在的に有用な64 byteトランザクションを維持しつつ([ニュースレター #408][news408 64byte] 参照)、
  同じ[マークルツリーの脆弱性][topic merkle tree vulnerabilities]に内部ノードの境界で対処するものです。
  SPV検証者は、ブランチのプリイメージが禁止パターンに一致する証明を拒否する必要があります。
  このドラフトには、マイナー向けの復旧ガイダンス(問題のあるトランザクションの並べ替えまたは除外)が含まれており、
  偶発的な違反は稀なはずだと述べています。

  複数の返信では、BIP54のよりシンプルな64バイトトランザクションの全面禁止の方が支持されました。
  Antoine Poinsotは、価値を守るシステムはすでにこれらのトランザクションを適切に検証しているため、
  Rubinの提案する区別は実用上ほとんど意味がないと主張しました。Matt Coralloは、この案では、
  マイナーはブロック構築ソフトウェアを変更するか、無効なブロックを生成するリスクを負うことになると指摘しました。
  Murchは、時折1バイトのパディングを追加する方が、ブロック検証時にすべてのノードで数千のハッシュを
  チェックさせるよりも負担が小さいと指摘しました。Sjors Provoostは、よりクリーンな修正は
  将来のブロックヘッダーフォーマット変更まで先送りすることを提案しました。

- **NUMSポイント支払いまたはハッシュレート過半数によるEC無効化のトリガー**: Pieter Wuilleは、
  [BIP360][](P2MR)や[P2TRv2][news403 pqout]などの
  新しい[ポスト量子][topic quantum resistance]アウトプットタイプ内の楕円曲線(EC)支払いパスについて、
  将来予想されている無効化を成文化することについてBitcoin-Devメーリングリストに[投稿しました][pw ml p2xx]。
  コンセンサスで強制されるトリガーがなければ、ユーザーはEC支払いが実際に無効化されると確信できず、
  当初は安価なEC支払いを許容するアウトプットタイプの耐量子性のストーリーが損なわれてしまいます。

  Wuilleは、導入するソフトフォークにバンドルする2つのメカニズムを提案しました。
  トリップワイヤー(P2XX-T)は、`<NUMS> OP_CHECKSIG`の支払いが成功し
  secp256k1が破られたことが証明された後、新しいアウトプットタイプ内のECパスを無効化するもので、ECの利用可能期間に没収を伴わない上限を設けます。
  そしてマイナーロックダウン(P2XX-ML)は、非常に長いアクティベーション期間を持つ別途シグナリングされるソフトフォークを通じて、
  ハッシュレートの過半数が同じ無効化を発動できるようにするものです。
  Boris Nagaevはトリップワイヤーを支持しましたが、
  大規模な古典的窃盗の後にマイナーロックダウンが誤検知を起こす懸念を提起しました。
  Sjors Provoostは、その対策として長い遅延と[P2TR][topic taproot]へのユーザーの再移行を提案しました。
  Conduitionはトリップワイヤーを支持し、証明はオンチェーンでマイニングされる必要はないと指摘するとともに、
  早期のマイナーロックダウンには手数料面のインセンティブが働き得ると警告しました。
  Wuilleは、無効化はそのアウトプットタイプ内のすべてのEC利用(key-pathだけでなく)を対象にしなければならないこと、
  そしてEC無効化後の支払い可能性を保証するために、ハイブリッド署名は任意のスクリプトの組み合わせではなく
  専用のopcodeを使うべきであることを明確にしました。

## リリースとリリース候補

_人気の Bitcoin インフラプロジェクトの新しいリリースとリリース候補です。
新しいリリースへのアップグレードやリリース候補のテストへの協力をご検討ください。_

- [Bitcoin Core 31.1rc1][]は、主要なフルノード実装のメンテナンスバージョンのリリース候補です。
  [トランザクションの発信元プライバシー][topic transaction origin privacy]を損なう可能性のあった
  `-privatebroadcast`のIPアドレス漏洩を修正し([ニュースレター #409][news409 privatebroadcast] 参照)、
  chainstateの圧縮、ウォレットの移行、
  インプットサイズの推定、[MuSig2][topic musig]の鍵集約、
  [v2 P2Pトランスポート][topic v2 p2p transport]再接続時のプロキシ処理に関する修正が含まれています。

- [Bitcoin Core 30.3rc1][]は、主要なフルノード実装のメンテナンスバージョンのリリース候補です。
  通常動作中に過剰なディスク読み書きを引き起こす可能性のあったchainstateデータベースの問題を修正し、
  ウォレット、[PSBT][topic psbt]、[miniscript][topic miniscript]、ネットワーキング、ビルド、テスト、
  ドキュメントの修正が含まれています。

- [Bitcoin Core 29.4rc1][]は、主要なフルノード実装のメンテナンスバージョンのリリース候補です。
  30.3rc1と同じchainstateデータベースの書き換え問題を修正し、選択された検証、ウォレット、ビルド、テスト、
  ドキュメント、CI、互換性の修正が含まれています。

- [Core Lightning v26.06.2][]は、TLSルート証明書がインストールされていない最小限のOSや
  Docker環境での`cln-currencyrate`を修正するメンテナンスリリースです。

- [LND v0.20.2-beta.rc1][]は、この人気のLNノード実装のメンテナンスリリースのリリース候補です。
  DNSフォールバックのパニックとオンチェーンのフォワードインターセプター決済のバグを修正し、
  下記の注目すべきコードのセクションで説明されている最終ホップの[HTLC][topic htlc] CLTV有効期限の検証を追加します。

- [LND v0.21.1-beta][]は、この人気のLNノード実装のメンテナンスリリースです。
  新規にTorを有効化したノードでの[Tor][topic anonymity networks] v3オニオンサービスの作成、
  DNSフォールバックのパニック、オンチェーンのフォワードインターセプター決済のバグを修正し、
  最終ホップのHTLC CLTV有効期限の検証を厳格化します。

- [LDK v0.2.4][]は、LN 対応のウォレットやアプリケーションを構築するためのこのライブラリのメンテナンスリリースです。
  `lightning`クレートの最小サポートRustバージョンを引き上げてしまったv0.2.3のリグレッションを修正し、
  このクレートは再び`rustc` 1.63でコンパイルできるようになりました。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35266][]は、`migratewallet` RPCに`load_wallet`引数 (デフォルトは true)を追加し、
  レガシーウォレットを[ディスクリプター][topic descriptors]ウォレットに移行する際、
  移行後のウォレットを即座に読み込むことなく移行処理を行えるようにします。
  これは、chainstateがウォレットの誕生日より前までプルーニングされているノード上で、
  レガシーウォレットを移行するユーザーの助けになります。この場合、移行自体には不要であるにもかかわらず、
  移行後のウォレットを読み込むには利用不可能なブロックデータが必要になるためです。

- [Bitcoin Core #35550][]は、[コンパクトブロックリレー][topic compact block relay]のネゴシエーション処理を更新し、
  [BIP152][]で規定されているとおり、`sendcmpct`メッセージ内のブール値のアナウンスフィールドが厳密に
  `0`または`1`でない場合は拒否するようにします。これまでのBitcoin Coreは
  このフィールドを直接C++の`bool`としてデコードしていたため、0以外の任意の値がtrueとして受け入れられていました。
  このPRでは、フィールドを整数として読み取り、1より大きい値をピアの不正行為として扱い、そのピアを切断します。

- [Bitcoin Core #35610][]は、`bitcoin-util`に`netmagic`コマンドを追加します。
  これは、カスタム[signet][topic signet]を含む、選択されたチェーンのBitcoin P2Pメッセージで使用される
  4 byteのネットワーク識別子を出力します。このコマンドは、提案されているマルチsignet対応のデータディレクトリサポートに有用です。
  この機能では、カスタムsignetはネットワーク識別子をサフィックスとするデータディレクトリに保存されます。
  これにより、スクリプトが`bitcoind`を起動する前に正しいディレクトリを選択できるようになります。

- [BIPs #2196][]は、Testnet 4を置き換えることを意図した新しいテストネットワーク
  である[Testnet 5][topic testnet]のドラフト仕様[BIP95][]を追加します([ニュースレター #409][news409 testnet5] 参照)。
  Testnet 4には、ブロック生成の間隔が長く空いた後に最小難易度のブロックを許容する難易度に関する例外規定があります。
  しかし、この例外は執拗に悪用され、頻繁な小規模の再編成を引き起こし、テスト用途でのネットワークの利用を困難にしています。
  Testnet 5はこの例外を削除し、最小難易度を約1,048,561に引き上げ、
  ブロック1から[BIP54][]の[コンセンサスクリーンアップ][topic consensus cleanup]ルールを適用します。
  このドラフトはまた、メッセージ開始バイト`0x46495645`(`FIVE`)とデフォルトP2Pポート`18335`
  を規定していますが、ジェネシスブロックの値は今のところプレースホルダーのままです。

- [BIPs #2165][]は、[ニュースレター #181][news181 bip52]で紹介された「Optical Proof-of-Work」の提案である
  [BIP52][]を更新し、そのステータスをDraftからClosedに変更します。BIP52は、
  マイニングコストを電気代や運用から専用の光学マイニング機器へと移すと主張するハードフォークを提案していました。
  数年間進展がなく、最近になって著者への連絡も試みられたものの成功しなかったため、この提案はクローズされました。

- [BIPs #2201][]は、Reduced Data Temporary Softfork提案である[BIP110][]を
  Completeステータスに進めます([ニュースレター #392][news392 bip110] 参照)。
  この更新は、アクティベーション前に作成されたUTXOには旧ルールが適用され、
  デプロイ期間中も旧ルールの下で支払いできることを強調しています。
  また、リファレンス実装のテストカバレッジとトランザクションレベルのテストベクターを追加します。
  さらに、[tapscript][topic tapscript]リーフでの`OP_IF`および`OP_NOTIF`の実行を一時的に禁止することの影響を明確にしています。
  既存のUTXOは対象外ですが、これらのopcodeを使う新しい構成には、別々のリーフを使うなどの代替手段が必要になります。

- [LND #10900][]は、1P1Cの[トランザクションパッケージ][topic package relay]を
  LNDのチェーンバックエンドに送信するための`WalletKit.SubmitPackage` RPCと
  `lncli wallet submitpackage`コマンドを追加します。bitcoindバックエンドの場合、
  LNDはパッケージをBitcoin Coreの`submitpackage` RPCに転送し、
  [エフェメラルアンカー][topic ephemeral anchors]を持つ
  手数料ゼロの[v3トランザクションリレー][topic v3 transaction relay]の親トランザクションを、
  [CPFP][topic cpfp]で手数料を支払う子トランザクションと一緒に受け入れられるようにします。
  他のバックエンドは同様のパッケージ送信を提供していません。btcdはunimplementedを返し、
  neutrinoはトランザクションを個別にブロードキャストします。

- [LND #10927][]は、最終ホップの[HTLC][topic htlc] CLTV有効期限の検証を厳格化します。
  これまでは、最終ホップのHTLCは、転送用のCLTVデルタはすでに制限されていたにもかかわらず、
  受信者のポリシーが許容するよりもはるかに先の有効期限を指定でき、過剰な期間にわたって流動性を拘束する可能性がありました。
  LNDは、受信者のCLTVポリシーの範囲外の最終HTLCを`incorrect_or_unknown_payment_details`で拒否し、
  関連する設定の境界を検証し、プリイメージを使ってHTLCをオンチェーンで請求するかどうかを決定する前に
  チャネルが強制閉鎖された場合にも同じチェックを適用するようになりました。

- [LDK #4748][]と[#4751][ldk #4751]は、遅延メッセージが関係する
  2つの[スプライシング][topic splicing]ステートマシンのエッジケースを修正します。
  [LDK #4748][]は、無関係な[HTLC][topic htlc]プリイメージのチャネルモニター更新が保留中の間に、
  遅延したスプライスの`tx_signatures`が到着し、LDKが誤ってスプライスフローの完了をブロックしてしまうケースを修正します。
  LDKは現在、保留中のモニター更新が、先に永続的に保存されなければならないスプライス関連の更新である場合にのみ待機します。
  [#4751][ldk #4751] は、ローカルユーザーが自身の資金拠出をキャンセルした後に、
  ピアの送信中だったスプライスの`commitment_signed`が到着し、
  LDKが古くなったスプライスのファンディングトランザクションに対する署名を検証してしまい、
  まだ有効なチャネルを強制閉鎖してしまう可能性のあるケースを修正します。
  LDKは現在、`commitment_signed`のオプションの`funding_txid`をチェックし、
  古くなったスプライスのファンディングトランザクションに対する署名を無視します。

{% include snippets/recap-ad.md when="2026-07-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2165,2196,2201,35266,35550,35610,10900,10927,4748,4751" %}

[rs ml starkbench]: https://groups.google.com/g/bitcoindev/c/0IdqdnlC4Og
[eh ml starkagg]: https://groups.google.com/g/bitcoindev/c/wKizvPUfO7w
[pw delving bop2]: https://delvingbitcoin.org/t/bird-of-prey-2-non-malleable-schnorr-pq-signatures/2514
[c ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA
[h ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA/m/D3hERI8wCwAJ
[st delving recover]: https://delvingbitcoin.org/t/public-key-recovery-for-ec-leaves-in-p2mr-bip-360/2603
[nk ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc
[nk delving lattice]: https://delvingbitcoin.org/t/pqc-lattice-based-signatures/2522
[c ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc/m/XFpCuylPCQAJ
[bs blog lattice]: https://blog.blockstream.com/schnorr-but-with-vectors-lattice-based-signatures-explained/
[jr ml merkle64]: https://groups.google.com/g/bitcoindev/c/ZVDEzxG6Sq8
[pw ml p2xx]: https://groups.google.com/g/bitcoindev/c/aWYtPLVPZ3U
[news383 sphincs]: /ja/newsletters/2025/12/05/#slh-dsa-sphincs
[news386 jn hash]: /ja/newsletters/2026/01/02/#bitcoin
[news393 p2mr]: /ja/newsletters/2026/02/20/#bips-1670
[news403 pqout]: /ja/newsletters/2026/05/01/#discussion-of-a-post-quantum-output-type
[news408 64byte]: /ja/newsletters/2026/06/05/#bip54-64-byte
[Core Lightning v26.06.2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.2
[LND v0.20.2-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta.rc1
[LND v0.21.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.1-beta
[LDK v0.2.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.4
[Bitcoin Core 31.1rc1]: https://bitcoincore.org/bin/bitcoin-core-31.1/test.rc1/
[Bitcoin Core 30.3rc1]: https://bitcoincore.org/bin/bitcoin-core-30.3/test.rc1/
[Bitcoin Core 29.4rc1]: https://bitcoincore.org/bin/bitcoin-core-29.4/test.rc1/
[news181 bip52]: /ja/newsletters/2022/01/05/#bips-1126
[news392 bip110]: /ja/newsletters/2026/02/13/#bips-2017
[news409 testnet5]: /ja/newsletters/2026/06/12/#testnet5-bip
[news409 privatebroadcast]: /ja/newsletters/2026/06/12/#bitcoin-core-35410
[sources]: /ja/internal/sources/
