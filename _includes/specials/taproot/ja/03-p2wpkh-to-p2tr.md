既にv0 segwit P2WPKHアウトプットの受け取りと使用をサポートしているウォレットにとって、
シングルシグ用のv1 segwit P2TRへのアップグレードは簡単です。
主な手順は次のとおりです:

- **新しいBIP32鍵導出パスの使用:** [BIP32][] 階層的決定性 (HD)コードを変更する必要はなく、
  ユーザーはシードを変更する必要もありません。[^electrum-segwit]
  ただし、P2TR公開鍵用の新しい導出パス（[BIP86][]で定義されているような）を使用することを強く推奨します。
  そうしないと、ECDSAと[Schnorr署名][topic schnorr signatures]
  の両方で同じ鍵を使用した場合に発生する[攻撃を受ける可能性][bip340 alt signing]があります。

- **ハッシュによる公開鍵の調整:** シングルシグでは技術的には必須ではありませんが、
  特にすべての鍵がランダムに選択されたBIP32シードから導出されている場合、
  BIP341では鍵を使用不可能なscripthashツリーにコミットすることを[推奨しています][bip341 cite22]。
  これは公開鍵とその鍵のハッシュの曲線の点を加算する楕円曲線の加算操作を使用するという簡単なものです。
  この推奨事項に従うことのメリットは、後でスクリプトレスな[マルチシグ][topic multisignature]のサポートや、
  [`tr()` descriptor][`tr()` descriptors]のサポートを追加する場合に、同じコードを使用できることです。

- **アドレスの作成と監視:** [bech32m][topic bech32]を使ってアドレスを作成します。
  支払いは、scriptPubKey `OP_1 <tweaked_pubkey>`に送られます。
  P2WPKHなどのv0 segwitアドレスのスキャンに使用する方法を使って、
  スクリプトに支払いをするトランザクションをスキャンできます。

- **使用トランザクションの作成:** Taprootのすべての非witnessフィールドは、
  P2WPKHと同じため、トランザクションのシリアライゼーションの変更について心配する必要はありません。

- **署名メッセージの作成:** これは使用トランザクションのデータに対するコミットメントです。
  データのほとんどは、P2WPKHトランザクションに署名するのと同じものですが、
  フィールドの順番が[変更され][BIP341 sigmsg]、いくつかの追加項目が署名されています。
  これを実装するのは、さまざまなデータをハッシュしシリアライズするだけなので、
  コードを書くのは簡単です。

- **署名メッセージのハッシュに署名:** Schnorr署名を作成するには、さまざまなな方法があります。
  最善の方法は、「独自の暗号を使う」のではなく、信頼できる十分レビューされたライブラリの関数を使用することです。
  ただ、何らかの理由によりそれができない場合は、
  [BIP340][]は、ECDSA署名を作成するためのプリミティブが利用可能であれば、
  簡単に実装できるアルゴリズムを提供します。署名ができたら、
  インプットのwitnessデータに入れ、使用トランザクションを送信します。

ブロック{{site.trb}}でTaprootがアクティベートされる前でも、
testnetやパブリックなデフォルト[signet][topic signet]、
Bitcoin Coreのプライベートなregtestモードを使ってコードをテストできます。
オープンソースのウォレットにTaprootのサポートを追加する場合、
他の開発者があなたのコードから学べるように、
Bitcoin Wikiの[taproot uses][wiki taproot uses]ページや
[bech32m adoption][wiki bech32 adoption]ページにその実装のPRへのリンクを追加することをお勧めします。

[^electrum-segwit]:
    Electrumがsegwit v0にアップグレードされた際、
    bech32アドレスで受け取りたい人は誰でも新しいシードを生成する必要がありました。
    これは技術的には必要ありませんでしたが、
    Electrumの作者は自分たちのカスタムシードの導出方法にいくつかの新しい[機能][electrum seeds]を導入することができました。
    その１つがシードのバージョン番号で、シードを使用するスクリプトを指定する機能です。
    これにより古いスクリプトを安全に非推奨にできます（例えば、将来リリースされるElectrumのバージョンでは、
    従来のP2PKHアドレスへの受信がサポートされなくなる可能性があります）。

    Electrumの開発者がバージョン付きのシードを展開していたのと同時期に、
    Bitcoin Coreの開発者は、[output script descriptor][topic descriptors]を使用して、
    （他の問題の解決に加えて）スクリプトの非推奨を可能にするという同じ問題を解決し始めました。
    次の表は、Electrumのバージョン付きのシードとBitcoin Coreのdescriptorを、
    以前両方のウォレットで使用され、
    現在も多くの他のウォレットで一般的に使用されている*implicit scripts*方式と比較したものです。

    <table>
      <tr>
        <th>スクリプト管理</th>
        <th>初期バックアップ</th>
        <th>新しいスクリプトの導入</th>
        <th>スキャン（帯域幅/CPUコスト）</th>
        <th>非推奨スクリプト</th>
      </tr>

      <tr>
        <th markdown="1">Implicit scripts (例：[BIP44][])</th>
        <td>シードワード</td>
        <td>自動（ユーザー操作は不要）</td>
        <td>サポートされているすべてのスクリプトをスキャン、O(n)</td>
        <td>サポートされていないスクリプトを使用していることをユーザーに警告する方法はありません</td>
      </tr>

      <tr>
        <th>Explicit scripts（バージョン付きシード）</th>
        <td>シードワード（バージョンビットを含む）</td>
        <td>ユーザーは新しいシードのバックアップが必要。
        資金は2つの別々のウォレットに分割されるか、ユーザーは旧ウォレットから新しいウォレットに資金を送信する必要があります</td>
        <td>単一のスクリプトテンプレートのみをスキャン、O(1)</td>
        <td>サポートされていないスクリプトに関するユーザーへの警告</td>
      </tr>

      <tr>
        <th markdown="1">Explicit scripts ([descriptor][topic descriptors])</th>
        <td>シードワードとdescriptor</td>
        <td>ユーザーは新しいdescriptorのバックアップが必要</td>
        <td>実際に使用されたスクリプトテンプレートのみをスキャン、O(n); 新しいウォレットの場合はn=1</td>
        <td>サポートされていないスクリプトに関するユーザーへの警告</td>
      </tr>
    </table>

{% include linkers/issues.md issues="" %}
[electrum seeds]: https://electrum.readthedocs.io/en/latest/seedphrase.html#motivation
[bip340 alt signing]: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki#alternative-signing
[bip341 cite22]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-22
[`tr()` descriptors]: /ja/preparing-for-taproot/#taproot-descriptor
[bip341 sigmsg]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#common-signature-message
[wiki bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[wiki taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
