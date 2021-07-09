[Output script descriptor][topic descriptors]は、
ウォレットがアドレスを作成し、そのアドレスに支払われるアウトプットを効率的にスキャンし、
後でそのアドレスから支払うために必要な情報を保存するための汎用的な方法を提供します。
さらに、descriptorは、適度にコンパクトで基本的なチェックサムを含んでいるため、
アドレスの情報をバックアップしたり、異なるウォレット間でコピーしたり、
複数の署名を提供するために協力するウォレット間で共有したりするのに便利です。

descriptorは、現在いくつかのプロジェクトでしか使われていませんが、
descriptorと関連する[Miniscript][topic miniscript]プロジェクトは、
異なるウォレットやツール間のインターオペラビリティを大幅に向上させる可能性があります。
これは、より多くのユーザーがTaprootの利点を活用して、
[マルチシグ][topic multisignature]によるセキュリティとバックアップの使用条件によるリカバリーを向上させるにつれて、
ますます重要になるでしょう。

その前に、Taprootで動作するようにdescriptorを更新する必要があります。
それが最近マージされた[Bitcoin Core #22051][]のプルリクエストの主題でした。
単一のdescriptorテンプレートで、P2TRのkeypathによる使用と、
scriptpathによる使用の両方を使用するために必要なすべての情報を提供できるように設計されています。
単純なシングルシグの場合は、以下の記述で十分です:

    tr(<key>)

同じ構文をマルチシグや[閾値署名][topic threshold signature]にも使用することができます。
例えば、アリスとボブ、キャロルは[MuSig][topic musig]を使って鍵を集約し、
`tr(<combined_key>)`に支払います。

直感的には、`tr(<key>)`で指定された`key`はアドレスにエンコードされる鍵にはなりません。
`tr()` descriptorは、BIP341の[安全上の推奨事項][bip341 safety]に従い、
使用不可能なスクリプトツリーにコミットする内部鍵を使用しています。
これにより、簡易的な鍵集約方式のユーザーに対する攻撃がなくなります
（[MuSig][topic musig]やMuSig2などのより高度な方式は影響を受けません）。

scriptpathによる使用については、バイナリツリーの内容を指定できる新しい構文が追加されました。
例えば、`{ {B,C} , {D,E} }`は次のようなツリーを指定します:

    Internal key
        / \
       /   \
      / \ / \
      B C D E

ツリーは、前述したdescriptorテンプレートのオプションの2つめのパラメーターとして指定できます。
例えば、アリスがkeypathを介して使用できるようにしたいが、
ボブ、キャロル、ダン、エドモンドが彼女の監査証跡を生成するscriptpathを介して使用できるようにしたい場合
（ただし、サードパーティのチェーン監視用のためのものではない）、アリスは次のdescriptorを使用できます:

    tr( <a_key> , { {pk(<b_key>),pk(<c_key>)} , {pk(<d_key>),pk(<e_key>)} )

上記の機能は、Taproot用のdescriptorを使用するために必要なことですが、
PR #22051では、descriptorが期待されるポリシーを完全に記述するために追加できるものがまだいくつか欠けていると指摘しています:

- **keypathの無効化:** ユーザーによっては、scriptpathによる使用を強制するために、
  keypathの使用を防止したい場合があります。これは現在、
  `tr()`の最初のパラメーターに使用不可能な鍵を使用することで可能ですが、
  ウォレットがこの設定をdescriptor自体に保存し、
  プライバシーを保護した使用不可能なkeypathを計算させることができると良いでしょう。

- **Tapscriptのマルチシグ:** レガシーおよびv0 segwitでは、
  `multi()`および`sortedmulti()`descriptorが`OP_CHECKMULTISIG`opcodeをサポートしています。
  Taprootではバッチ検証を可能にするため、スクリプトベースのマルチシグはTapscriptでは少し違った方法で処理されるため、
  `tr()` descriptorでは現在必要なマルチシグopcodeを`raw()`スクリプトで指定する必要があります。
  Tapscript用に`multi()`および`sortedmulti()`の更新版があると良いでしょう。

- **MuSigベースのマルチシグ:** この記事の前半で、
  アリスとボブ、キャロルが`tr()` descriptorを使用するために手動で鍵を集約する説明をしました。
  `tr(musig(<a_key>, <b_key>, <c_key>))`のように指定して、元の鍵情報をすべて保持し、
  それを使って協力して署名する際に使用する[PSBT][topic psbt]フィールドに入力できるようにする関数があると理想的です。

- **タイムロック、ハッシュロック、ポイントロック:** LNや[DLC][topic dlc]、
  [Coinswap][topic coinswap]およびその他の多くのプロトコルで使用されるこれらの強力な構造は、
  今のところ`raw()`関数でしか記述できません。これらのサポートをdescriptorに直接追加することは可能ですが、
  代わりにdescriptorの兄弟プロジェクトである[Miniscript][topic miniscript]を介してサポートが追加されることになるかもしれません。
  Bitcoin CoreへのMiniscriptの統合はまだ進行中のプロジェクトですが、
  PSBTやdescriptorのようなツールが既にそうであるように、
  その革新性が他のウォレットにも広がることを期待しています。

ウォレットは、Taprootを使い始めるためにdescriptorを実装する必要はありませんが、
実装したウォレットは、後でより高度なTaprootの機能を使用するためのより良い基盤を得ることができます。

{% include linkers/issues.md issues="22051" %}
[bip341 safety]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-22
