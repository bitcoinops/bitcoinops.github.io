---
title: "Průvodce pro peněženky využívající pravidla Bitcoin Core 28.0"
permalink: /cs/bitcoin-core-28-wallet-integration-guide/
name: 2024-10-10-bitcoin-core-28-wallet-integration-guide-cs
type: posts
layout: post
lang: cs
slug: 2024-10-10-bitcoin-core-28-wallet-integration-guide-cs

excerpt: >
  Bitcoin Core 28.0 přináší nová pravidla pro P2P a mempool, která mohou být užitečná pro rozličné druhy peněženek a transakcí. Gregory Sanders v tomto průvodci nahlíží na tato pravidla a ukazuje příklady jejich použití.

---

{:.post-meta}
*napsal [Gregory Sanders][]*

[Bitcoin Core 28.0][bc 28.0] přináší [nová][bc 28.0 release notes] pravidla pro P2P
a mempool, která mohou být užitečná pro rozličné druhy peněženek a transakcí. Gregory
Sanders v tomto průvodci nahlíží na tato pravidla a ukazuje příklady jejich použití.

## Přeposílání balíčků s jedním rodičem a jedním potomkem (1P1C)

Aby byla před Bitcoin Core 28.0 transakce přidána do jeho mempoolu, musel se její
jednotkový poplatek rovnat či převýšit aktuální minimální jednotkový poplatek mempoolu.
Tato hodnota se zvyšuje či snižuje dle aktuálního zatížení, což způsobuje kolísání
minimální hodnoty potřebné pro propagaci platby. To přináší těžkosti peněženkám,
které se potýkají s předem podepsanými transakcemi a kterým nemohou podepsat
[nahrazení pomocí RBF][topic rbf]. Musí proto předpovídat budoucí poplatky, aby
v potřebný čas dosáhly potvrzení transakce. Jedná se o náročný úkol i v řádu minut,
v několikaměsíčním horizontu je zcela neřešitelný.

[Přeposílání balíčků][topic package relay] je dlouho očekávaná funkce, která odstraní
riziko zaseknutí transakce bez možnosti navýšit její poplatek. Po řádném vývoji
a širokém nasazení v síti umožní přeposílání balíčků vývojářům peněženek navýšit
poplatek transakce pomocí jiné, související transakce. Díky tomu bude mít předek
s nízkým poplatkem možnost dostat se do mempoolu.

V Bitcoin Core 28.0 byla implementována omezená varianta přeposílání balíčků týkající
se pouze balíčků s jedním rodičem a jedním potomkem (one parent one child, 1P1C).
1P1C umožňuje jednomu rodiči dostat se do mempoolu bez ohledu na proměnlivý minimální
jednotkový poplatek mempoolu. Využívá k tomu jediného potomka a jednoduché navýšení
poplatku pomocí [Child Pays For Parent (CPFP)][topic cpfp]. Má-li potomek další
nepotvrzené předky, nebude se úspěšně šířit. Toto omezení výrazně zjednodušuje
implementaci a umožňuje nerušeně pokračovat v další práci na mempoolu (např. na
[cluster mempoolu][topic cluster mempool]).

Každá transakce kromě [TRUC transakcí][topic v3 transaction relay] (viz níže)
musí i nadále splňovat podmínku minimálního poplatku jednoho satoshi na virtuální
bajt.

Dalším omezením je, že garance šíření jsou u této verze omezené. Je-li uzel
Bitcoin Core připojen k dostatečně motivovanému nepříteli, může narušit propagaci
tohoto rodiče a jeho potomka. Pokračující práce na [projektu][package relay tracking issue]
učiní přeposílání balíčků robustnějším.

Obecné přeposílání balíčků bude přidáno v budoucnosti. K jeho vývoji se využijí data
z nasazení této omezené formy.

Následují příkazy pro nastavení peněženky za účelem demonstrace přeposílání 1P1C
v regtestu:

```hack
bitcoin-cli -regtest createwallet test
{
  "name": "test"
}
```

```hack
# Načti adresu pro příjem
bitcoin-cli -regtest -rpcwallet=test getnewaddress
bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3
```

```hack
# Vytvoř transakci s nízkým poplatkem převyšujícím "minrelay"
bitcoin-cli -regtest -rpcwallet=test -generate 101
{
  [
    ...
  ]
}

bitcoin-cli -regtest -rpcwallet=test listunspent
[
  {
    "txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b",
    "vout": 0,
    ...
    "amount": 50.00000000,
    ...
  }
]

# Minfee a minrelay mempoolu jsou shodné. Pro snadnější otestování funkce
# použijeme TRUC transakce, aby bylo možné mít transakce s nulovým poplatkem
# vyžadující 1P1C přeposílání. Fullrbf je též aktivní (výchozí v 28.0).
bitcoin-cli -regtest getmempoolinfo
{
  "loaded": true,
  ...
  "mempoolminfee": 0.00001000,
  "minrelaytxfee": 0.00001000,
  ...
  "fullrbf": true,
}

# Začněme s v2 transakcí
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "50.00000000"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Nahraďme úvodní 02 hodnotou 03, což je verze TRUC
03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Podepiš a odešli
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

# Chyba: minimální poplatek přeposílání nebyl naplněn, 0 < 110
error code: -26
error message:
min relay fee not met, 0 < 110

# Potřebujeme přeposlat jako balíček a navýšit pomocí CPFP
bitcoin-cli -regtest decoderawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

{
  "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "hash": "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
  "version": 3,
  "size": 191,
  "vsize": 110,
  ...
  "vout": [
    ...
    "scriptPubKey": {
      "hex": "001400991cdadccdf30cb5a04663b0371cb433a095b4",
    ...
}

# Odečti satoshi na CPFP poplatek
bitcoin-cli -regtest createrawtransaction '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99994375"}]'
0200000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Podepiš TRUC a odešli jako 1P1C balíček
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 0300000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "50.00000000"}]'
{
  "hex": "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf": {
      "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
      "vsize": 110,
      "fees": {
        "base": 0.00000000,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    },
    "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55": {
      "txid": "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de",
      "vsize": 110,
      "fees": {
        "base": 0.00005625,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    }
  },
  "replaced-transactions": [
  ]
}
```
1P1C balíček byl vložen do místního mempoolu s efektivním jednotkovým poplatkem
25,568 satoshi na virtuální bajt, i když byla rodičovská transakce pod minimálním
poplatkem pro přeposílání. Úspěch!

## TRUC transakce

Transakce do potvrzení topologicky omezené (Topologically Restricted Until
Confirmation, TRUC), též známé jako v3 transakce, je nové, volitelné [pravidlo
mempoolu][policy series] zaměřené na poskytování robustního nahrazování
transakcí poplatkem (RBF). Má za cíl zabránit poplatkovému [pinningu][topic
transaction pinning] transakcí i pinningu zneužívajícímu limitů balíčků.
Jeho ústřední filozofií je: **i když určité vlastnosti nejsou pro všechny
transakce aplikovatelné, můžeme je implementovat pro balíčky s omezenou
topologií**. TRUC vedle topologických restrikcí přináší i způsob, jak
používat tuto robustnější sadu pravidel.

Ve zkratce, TRUC transakce je transakce verze 3, která je omezena buď na
samotnou transakci o velikosti až 10 kvB nebo na potomka právě jedné TRUC
transakce omezené na 1 kvB. TRUC transakce nemůže utratit neTRUC transakci
a naopak. Všechny TRUC transakce jsou považované za RBF nahraditelné bez ohledu
na signalizaci dle [BIP125][]. Je-li další, nekonfliktní TRUC potomek přidán
k rodičovské TRUC transakci, bude považována za [konfliktní][topic kindred rbf]
vzhledem k původnímu potomkovi a budou aplikována běžná RBF pravidla včetně
jednotkového a celkového poplatku.

TRUC transakce mohou mít nulový poplatek, pokud potomek dostatečně navyšuje
celkový jednotkový poplatek balíčku.

Omezená topologie dobře zapadá do konceptu 1P1C přeposílání bez ohledu na to,
co dělají protistrany transakce. Předpokladem je, že všechny podepsané transakce
jsou TRUC.

TRUC platby jsou nahraditelné, takže jakákoliv transakce, jejíž vstupy odesílatel
minimálně z části nevlastní, může být znovuutracena. Jinými slovy přijímání
TRUC plateb bez konfirmací není bezpečnější než neTRUC.

## RBF nahrazování balíčků s topologií 1P1C

Rodič z 1P1C balíčku může být v konfliktu s jiným rodičem v mempoolu. To může nastat,
pokud například existuje více předem podepsaných verzí rodičovské transakce.
Dříve byl rodič během RBF nahrazování uvažován samostatně a byl zahozen, pokud
byl poplatek příliš nízký.

S RBF nahrazováním balíčku s topologií 1P1C bude i potomek začleněn do úvah, což
umožní vývojářům peněženek využívat robustního posílání 1P1C balíčků P2P sítí
bez ohledu na verze transakcí v lokálním mempoolu.

Poznamenejme, že v současnosti musí být konfliktní transakce samostatná nebo
v 1P1C balíčku bez dalších závislostí. V opačném případě bude nahrazení odmítnuto.
Jakýkoliv počet takových shluků může být v konfliktu. To bude zvolněno v budoucích
vydáních s cluster mempoolem.

Pokračujme v našem 1P1C příkladu. Provedeme nahrazení nového balíčku oproti
existujícímu 1P1C balíčku, tentokrát s neTRUC balíčkem:

```hack
# TRUC rodič a potomek
bitcoin-cli -regtest getrawmempool
[
  "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
]

# Druhé utracení rodiče novým 1P1C v2 balíčkem, kde poplatky rodiče
# jsou nad minrelay, ale ne dost na RBF balíčku
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99999"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Podepiš a (neúspěšně) odešli
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

# chyba: nedostatečný poplatek, odmítnuté nahrazení,
# menší poplatek než konfliktní transakce; 0,00001 < 0,00005625
error code: -26
error message:
insufficient fee, rejecting replacement f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59, less fees than conflicting txs; 0.00001 < 0.00005625

# Přidej do nového balíčku poplatky skrze potomky,
# přeplať starý balíček
bitcoin-cli -regtest createrawtransaction '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99234375"}]'

020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Podepiš a odešli jako balíček
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "49.99999"}]'
{
  "hex": "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313": {
      "txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59",
      "vsize": 110,
      "fees": {
        "base": 0.00001000,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    },
    "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c": {
      "txid": "858fe07b01bc7c1c1dda50ba16a33b164c0bc03d0eff8f9546558c088e087f60",
      "vsize": 110,
      "fees": {
        "base": 0.00764625,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    }
  },
  "replaced-transactions": [
    "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
    "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
  ]
}

```

## Pay To Anchor (P2A)

[Anchory][topic anchor outputs] jsou definovány jako výstupy určené výhradně pro
nahrazení pomocí CPFP. Jelikož nejsou tyto výstupy skutečnými platbami, mají nízkou
hodnotu (blízkou prachu) a jsou okamžitě utracené.

Byl přidán nový typ výstupního skriptu [Pay To Anchor (P2A)][topic ephemeral anchors],
který přináší optimalizovanou verzi anchorů, která nevyžaduje existenci klíče.
Výstupní skript je `OP_1 <4e73>`. Pro utracení nevyžaduje žádná witnessová data,
což v důsledku znamená redukci poplatku v porovnání s existujícím způsobem.
Též umožňuje, aby CPFP nahrazení transakce provedl kdokoliv.

P2A může být použito nezávisle na TRUC transakcích i 1P1C balíčkách. Transakce
s P2A výstupem a bez potomků může být zveřejněna, ale výstup je možné triviálně
utratit. Aby mohly balíčky a TRUC transakce vyžít nových možností navyšování
poplatků, nemusí mít žádné P2A výstupy.

Tento nový druh výstupu má hodnotu prachu (dust limit) 240 satoshi. P2A výstupy
pod touto hodnotou nebudou šířeny, ani když jsou utráceny v balíčku, neboť
tento limit [ekonomičnosti výstupů][topic uneconomical outputs] je nadále plně
vynucován pravidly. Ač byl tento návrh dříve spojován s dočasným prachem
(ephemeral dust), již tomu tak není.

Příklad vytváření a utrácení P2A:

```hack
# Adresa P2A na regtestu je "bcrt1pfeesnyr2tx", na mainnetu "bc1pfeessrawgf"
bitcoin-cli -regtest getaddressinfo bcrt1pfeesnyr2tx
{
  "address": "bcrt1pfeesnyr2tx",
  "scriptPubKey": "51024e73",
  "ismine": false,
  "solvable": false,
  "iswatchonly": false,
  "isscript": true,
  "iswitness": true,
  "ischange": false,
  "labels": [
  ]
}

# Segwitový výstup typu "anchor"
bitcoin-cli -regtest decodescript 51024e73
{
  "asm": "1 29518",
  "desc": "addr(bcrt1pfeesnyr2tx)#swxgse0y",
  "address": "bcrt1pfeesnyr2tx",
  "type": "anchor"
}

# Minimální hodnota P2WPKH a P2A výstupů
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "0.00000294"}, {"bcrt1pfeesnyr2tx": "0.00000240"}]'
02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000

# Podepiš a odešli transakci s P2A výstupem
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true

# Vypni kontrolu rozumnosti poplatku
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000 "0"
fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b

# Nahrazený předchozí balíček
bitcoin-cli -regtest getrawmempool
[
  "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b"
]

# Propal hodnotu v potomkovi, v 65bajtové transakci s OP_RETURN,
# abychom se vyvarovali stížnostem na příliš malou transakci
bitcoin-cli -regtest createrawtransaction '[{"txid": "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b", "vout": 1}]' '[{"data": "feeeee"}]'
02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000

# Netřeba podepisovat, není vyžadován witness
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000
8d092b61ef3c1a58c24915671b91fbc6a89962912264afabc071a4dbfd1a484e

```

## Aplikace

Pokračujme dále popisem několika běžných vzorců chování peněženek a jak by jim mohly
být tyto novinky užitečné, ať peněženka aktivně provádí změny či ne.

### Prosté platby

Jedním obvyklým problémem je, že uživatelé si nemohou být během RBF jisti, zda
se příjemce bitcoinů nepokusí o vytvoření řetězce transakcí vycházejících ze
samotné platby, čímž by se dopustil pinningu. Pokud si uživatel přeje mít
snadněji predikovatelné RBF chování, je jedním ze způsobů použití TRUC transakce.
Příchozím platbám také mohou být spolehlivě navýšeny poplatky pomocí až 1kvB utracení
příchozího vkladu.

V takových případech by peněženky měly:

- nastavit verzi na 3
- použít pouze potvrzené výstupy
- zůstat v 10kvB limitu (oproti neTRUC limitu 100 kvB)
  - i nadále jsou možné dávkové platby
  - pokud peněženka musí utratit nepotvrzený výstup, musí pocházet z TRUC
    transakce a nová transakce musí být pod 1 kvB

### Coinjoiny

V případě [coinjoinu][topic coinjoin], kde je cílem soukromí a není potřeba
provést skrytý coinjoin, by mohly být TRUC transakce užitečné. Coinjoin
může mít příliš nízký poplatek a tedy může potřebovat jej navýšit.

Vedle TRUC transakcí by mohl být také přidán P2A výstup, který by umožňoval
odděleným peněženkám (např. strážním věžím) zaplatit poplatky za transakci.

Pokud ostatní účastníci utratí své nepotvrzené výstupy, může nastat vyloučení
TRUC sourozenců. Vyloučení sourozenců může zachovat limity na TRUC topologii,
avšak umožňuje přidat poplatek pomocí CPFP: nový potomek může nahradit předchozího
bez utracení konfliktních vstupů. Proto jsou všichni účastníci coinjoinu
vždy schopni navýšit poplatek transakce pomocí CPFP.

Pozor na pinning: účastníci coinjoinu i tak mohou ekonomicky škodit tím, že
podruhé utratí svůj vlastní vstup do coinjoinu, což si vynutí nahradit pomocí
RBF škodičovu první transakci.

### Lightning Network

Transakce generované v Lightning Network protokolu sestávají z několika hlavních
typů:

1. Financující transakce: financovaná jednou nebo oběma stranami pro otevření
   kontraktu; méně časově citlivá.
2. Commitment transakce: transakce, která potvrzuje poslední stav kanálu. Tyto
   transakce jsou asymetrické a v současnosti vyžadují obousměrnou zprávu
   `update_fee` pro úpravu poplatků. Poplatky musí být dostatečně vysoké na
   propagaci sítí do mempoolů těžařů.
3. Předem podepsané HTLC transakce.

Používání 1P1C přeposílání a RBF balíčků výrazně navyšuje bezpečnost Lightning
Network. Jednostranná uzavření kanálů mohou být učiněna s commitment transakcemi
majícími poplatky pod minima mempoolu nebo kolidující s jiným nízkopoplatkovým
balíčkem s commitment transakcí. Tyto transakce by jinak nebyly rychle začleněny
do bloku.

Přinejmenším by mohly lightningové peněženky využít výhody, které jim nabízí
RPC příkaz `submitpackge` v Bitcoin Core:

```hack
bitcoin-cli submitpackage '["<commitment_tx_hex>", "<anchor_spend_hex>"]'
```

Peněženky by měly tento příkaz integrovat pro použití s commitment transakcemi
i utracením anchoru, aby zajistily zařazení do mempoolů těžařů se správným
poplatkem.

Poznámka: RPC vrátí úspěch, pokud odešlete balíček s jedním rodičem a mnoha
potomky, nebude však propagován dle 1P1C pravidel.

Až upgraduje dostatečné množství uzlů v síti, bude moci LN protokol odstranit
zprávu `update_fee`, která je již léta zdrojem zbytečných vynucených uzavření
kanálů během období vysokých poplatků. S odstraněním této zprávy z protokolu
by mohly být commitment transakce nastaveny na statický jednotkový poplatek
1 sat/vbyte. S TRUC transakcemi můžeme zajistit, aby bylo soupeřícím commitment
transakcím s anchory umožněno navýšit si navzájem poplatky, a pokud existují
soupeřící výstupy placené ze stejné commitment transakce, RBF bude moci být
proveden bez ohledu na to, který výstup je právě utrácen. TRUC transakce mohou
mít i nulový poplatek, což by umožnilo snížení složitosti specifikace. S vylučováním
TRUC sourozenců bychom též mohli odstranit jednoblokový CSV časový zámek,
jelikož už by nebylo tak důležité, který nepotvrzený výstup je právě utrácen,
pokud může každá strana sama utratit jediný výstup.

S TRUC a P2A anchory můžeme snížit používání blokového prostoru ze současných
dvou anchorů na jediný anchor bez použití klíče. Tento anchor nevyžaduje žádný
závazek k veřejnému klíči či podpisu, což ušetří další blokový prostor. Navyšování
poplatků může být delegováno na agenty, kteří nemají k dispozici žádné tajné klíče.
Anchory by také mohly místo P2A obsahovat jediný výstup s klíči sdílenými mezi stranami
za cenu vyššího množství virtuálních bajtů v případě jednostranného uzavření.

Podobné strategie by mohly být použité během implementace pokročilých funkcí
jako splicingu ke snížení rizika RBF pinningu. Například splice TRUC kanálu,
který má méně než 1 kvB, by mohl navýšit poplatek pomocí CPFP jednostrannému
uzavření jiného kanálu. Následná navýšení mohou být provedena v sérii nahrazením
pouze splicingové transakce. Nevýhodou by bylo odhalení typu TRUC transakce
během splicingu.

Jak vidno, mohli bychom se s těmito novými schopnostmi vyvarovat nadměrné složitosti
a mohli bychom dosáhnout úspor, pokud by se mohla každá transakce vměstnat do
1P1C schématu.

### Ark

Ne všechny vzorce používání transakcí se vměstnají do 1P1C schématu. Příkladem
nechť jsou [Ark][topic ark] výstupy, které pro rozdělení sdíleného UTXO zavazují
až ke třem předem podepsaným (nebo kovenantovým) transakcím.

Je-li poskytovatel služby Ark (ASP) offline nebo zpracovává-li transakci, může
uživatel jednostranně vystoupit, což si k oddělení jeho větve ze stromu transakcí
od něj vyžádá odeslání série transakcí. Potřeba je O(log n) transakcí.
Potíže mohou nastat, pokud se i další klienti pokouší opustit strom, což může
v mempoolu vyústit v překročení limitů řetězení nebo ve vytvoření konfliktních
transakcí s nedostatečnými poplatky pro včasné zařazení do bloku. Pokud se objeví
výrazně dlouhé období bez začlenění, je ASP schopen si jednostranně všechny prostředky
přisvojit. Uživatelé by o tyto peníze přišli.

Ideálně by úvodní jednostranné uzavření arkového stromu:

1. Bylo publikováno jako kompletní větev Merkleova stromu podkladového
   virtuálního UTXO (vUTXO).
2. Každá z těchto transakcí by měla nulový poplatek, aby nebylo potřeba činit
   předpovídání poplatků nebo dopředu rozhodovat, kdo bude poplatky platit.
3. Konečná transakce v listu stromu by měla anchor s nulovou hodnotou, které
   platí pomocí CPFP za publikaci celého Merkleova stromu.

Pro uskutečnění tohoto ideálu nám ještě pár věcí chybí:

1. Všeobecné přeposílání balíčků. V současnosti neexistuje způsob robustního
   propagování těchto řetězců nízkopoplatkových transakcí P2P sítí.
2. Pokud by bylo mnoho větví publikováno s nízkými poplatky, uživatelé by
   nemuseli být schopni včas publikovat své vlastní větve kvůli omezení počtu
   předků. To by mohlo být katastrofické v případě vysokého počtu protistran,
   což je ideální případ používání Arku.
3. Potřebujeme všeobecné vylučování sourozenců. Nemáme podporu pro výstupy
   nehodnotných anchorů mající nulovou hodnotu.

Zkusme namísto toho požadovanou strukturu transakcí co nejlépe přizpůsobit
schématu s jedním rodičem a jedním potomkem i za cenu dodatečných poplatků.
Všechny transakce arkových stromů, počínaje v kořenu, jsou TRUC transakce
s přidanými P2A výstupy s minimální hodnotou.

Když se účastník rozhodne jednostranně z Arku vystoupit, publikuje
kořenovou transakci spolu s utracením P2A výstupu na poplatky. Poté čeká
na potvrzení. Po potvrzení uživatel odešle další transakci ve své větvi
Merkleova stromu spolu se svým vlastním utracením P2A na poplatky. Cyklus
pokračuje, dokud není celá větev publikována a dokud nejsou prostředky
bezpečně z arkového stromu extrahovány. Ostatní uživatelé stejného Arku
mohou se špatnými úmysly nebo bez nich zveřejnit transakci stejného vnitřního
uzlu s příliš nízkým jednotkovým poplatkem, ale vylučování sourozenců
by zajistilo, že v každém bodě by čestný potomek s méně než 1 kvB mohl
nahradit (RBF) soupeřícího potomka bez nutnosti uzamknout ostatní výstupy
nebo bez požadavku na existenci více anchorů.

Předpokládáme-li binární stromy, přichází toto schéma pro prvního uživatele
s téměř dvojnásobnými náklady oproti ideálnímu Arku a o polovinu vyššími
náklady na celý strom v případě kompletního rozdělení. U 4-stromů klesají
dodatečné náklady za celý strom na čtvrtinu.

### Splicing v Lightning Network

V pokročilejších konstruktech v Lightning Network se objevují i jiné topologie,
které by vyžadovaly trochu úsilí, aby mohly využívat 1P1C přeposílání.

[Splicing][topic splicing] v Lightning Network je vznikající standard již v běžném
používání. Každý splice utrácí výstup původní financující transakce a vkládá prostředky
kontraktu do nového výstupu. Řetězec předem podepsaných transakcí zůstává zachován.
Před nabytím potvrzení jsou podepisovány a sledovány stavy původního i nového kanálu.

V následujícím případě by došlo k překročení schématu 1P1C:

1. Alice a Bob otevřou kanál.
2. Alice splicingem vynese některé prostředky (splice out) na blockchainovou
   adresu ovládanou Carol, která nemůže použít CPFP. Tento splice-out cílí
   na potvrzení během několika hodin.
3. Bobův uzel se stane offline nebo z nějakého důvodu vynutí zavření kanálu.
4. Poplatky vystřelí vzhůru (třeba zrovna spustil nějaký token), což výrazně zpozdí
   potvrzení splice-outové transakce.

Alice chce uskutečnit onchain platbu Carol, nechce tedy do blockchainu odeslat
commitment transakci bez splicu. Znamená to, že aby došlo k úspěšné propagaci,
musí být balíček splicová transakce -> commitment transakce -> utracený anchor.

Zkusme zvážit, jak tuto situaci naroubovat na schéma 1P1C bez zbytečného plýtvání
virtuálními bajty. LN peněženka by mohla namísto jednoho splice-outu na jednu
onchain platbu učinit dva splice-outy, jelikož jsou spolu v konfliktu. Jedna verze
by použila relativně konzervativní odhad poplatku. Druhá verze by obsahovala
P2A výstup s 240 satoshi (nebo v budoucnosti 0 satoshi s [dočasným prachem][topic
ephemeral anchors], ephemeral dust).

Nejdříve by byl zveřejněn splice-out bez anchoru.

Pokud by se nic mimořádného nestalo, byl by potvrzen a Alice by mohla pokračovat
v normálním uzavření kanálu.

V případě vystřelených poplatků by mohl být zveřejněn 1P1C splice s anchorem spolu
s útratou anchoru; RBF nahrazení balíčku by nahradilo první splice-out. Toto navýšení
poplatku by umožnilo potvrzení a platbu Carol. Uzavření kanálu by mohlo následovat.

Jinou možností je vytvoření několika verzí splice-outových transakcí s různými
úrovněmi poplatků. Každá kopie by však vyžadovala dodatečnou sadu podpisů commitment
transakce a nevybavených HTLC.

{% include references.md %}

[Gregory Sanders]: https://github.com/instagibbs
[bc 28.0]: https://github.com/bitcoin/bitcoin/releases/tag/v28.0
[bc 28.0 release notes]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
[package relay tracking issue]: https://github.com/bitcoin/bitcoin/issues/27463
[policy series]: /cs/blog/waiting-for-confirmation/
