*[Revault][]開発者[Antoine Poinsot][darosior]の寄稿*

Bitcoinの[Vault][topic vaults]は、コントラクトの一種で、
ユーザーが自分のウォレットのお金を使用するのに、2つの連続したトランザクションを必要とします。
このようなプロトコルは数多く提案されているため（シングルもしくはマルチパーティ、[Covenant][topic covenants]あり、なし）、
それらの共通する点にフォーカスします。

1つのオンチェーントランザクションで複数の支払いを実行する[バッチ支払い][topic payment batching]とは対照的に、
Vaultは1つの支払いを実行するために複数のトランザクションを使用します。
最初のトランザクションである*Unvault*は、以下のいずれかに支払いをします:

1. 相対的なタイムロックの後で公開鍵のセットに、もしくは
2. タイムロックのない単一の公開鍵に

最初の支払いのパスは、メインケースで、ホットキーの使用が予想されます。2つめの支払いのパスでは、
トランザクションのキャンセル（*クローバック、リカバリー、再Vault化*トランザクションと呼ばれることもあります）を可能にします。

このように、BitcoinのVaultは、ほとんどのコントラクトがすべての参加者が署名に協力するハッピーパス（
そしてタイムロックが含まれる紛争解決パス）を持っている[Taproot][topic taproot]の洞察とは対照的で、むしろ逆です。
*支払い*トランザクションは、相対的なタイムロック[^0]により妨げられているため、
taprootのscriptpathを使用しなければなりませんが、*キャンセル*トランザクションは理論的にはkeypathを使用できます。

マルチパーティのVaultは、実際には既に多くの対話を必要としているため、
理論的には[Musig2][topic musig]のような[BIP340][]によって可能になった[マルチシグ][topic multisignature]や
[閾値署名][topic threshold signature]スキームの恩恵を受けることができます。
しかし、これらのスキームには、新たな安全性の課題があります。
Vaultのプロトコルは、コールドストレージに使用することを目的としているため、
設計上の選択はより保守的で、Vaultはおそらくこれらの新しい技術を使用する最後の場になるでしょう。

Taprootに切り替えることで、Vaultはマークルブランチと（特にマルチパーティの場合）より短いBIP340署名の使用により、
若干のプライバシーと効率性の向上の恩恵を受けることにになるでしょう。
例えば、6個の「コールド」キーと3個の「アクティブ」キーを持つ（閾値を2とした）マルチパーティのセットアップにおける
*Unvault*のアウトプットスクリプトは、深さ2のリーフを持つTaprootで表現できます:

- `<X> CSV DROP <active key 1> CHECKSIG <active key 2> CHECKSIGADD 2 EQUAL`
- `<X> CSV DROP <active key 2> CHECKSIG <active key 3> CHECKSIGADD 2 EQUAL`
- `<X> CSV DROP <active key 3> CHECKSIG <active key 1> CHECKSIGADD 2 EQUAL`
- `<cold key 1> CHECKSIG <cold key 2> CHECKSIGADD <cold key 3> CHECKSIGADD <cold key 4> CHECKSIGADD <cold key 5> CHECKSIGADD <cold key 6> CHECKSIGADD 6 EQUAL`

<!-- TODO: recalculate spending costs
This is about xxxx vbytes for the cheapest (happy) spending path and about xxxx vbytes for the costliest (dispute) one.
Compared to the roughly xxxx vbytes (happy) and xxxx vbytes (dispute) by using the following P2WSH: -->

Taprootでは、アウトプットを使用するために使用するリーフのみを明かすため、
トランザクションweightは、P2WSHスクリプトの場合よりもかなり小さくなります:

```text
IF
  6 <cold key 1> <cold key 2> <cold key 3> <cold key 4> <cold key 5> <cold key 6> 6 CHECKMULTISIG
ELSE
  <X> CSV DROP
  2 <active key 1> <active key 2> <active key 3> 3 CHECKMULTISIG
ENDIF
```

失効ブランチは、支払いが成功した場合には隠すことができますが（そしてマルチシグの閾値を使用する場合、
その存在と参加者の数を難読化できます）、Vaultの使用パターンはオンチェーンで簡単に識別できるため、
プライバシーの向上は最小限となります。

最後に、Vaultプロトコルは、ほとんどの事前署名されたトランザクションプロトコルと同様に、
[BIP118][]の[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]のようなTaprootを基に提案されたBitcoinのアップグレードから大きな恩恵を受けるでしょう。
さらなる注意とプロトコルの調整が必要ですが、`ANYPREVOUT`や`ANYPREVOUTANYSCRIPT`は、再バインド可能な*キャンセル*署名を可能にします。
これにより、対話を大幅に減らすことができ、0(1)の署名の保存が可能になります。
これは、DoS攻撃の対象を大幅に削減することができるため、[Revaultプロトコル][Revault protocol]の*緊急*署名にとって特に興味深いものになります。
アウトプットに`ANYPREVOUTANYSCRIPT`署名を含めることにより、
このコインを使用するトランザクションがアウトプットを作成する方法を制限するCovenantを効果的に作成します。
さらにカスタマイズ可能な将来の署名ハッシュにより、より柔軟な制限が可能になります。

[^0]:
    事前に分かっていれば、特定のnSequenceを持つ*支払い*トランザクションに事前署名することができますが、
    そうすると「アクティブ」なキーを使った別の支払いパスはまったく必要ありません。
    また、通常コインを受け取った時点で、そのコインをどう使うかはわかりません。

[darosior]: https://github.com/darosior
[revault]: https://github.com/revault
[revault protocol]: https://github.com/revault/practical-revault
