---
title: 'Zpravodaj „Bitcoin Optech” č. 239'
permalink: /cs/newsletters/2023/02/22/
name: 2023-02-22-newsletter-cs
slug: 2023-02-22-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden představujeme návrh BIP pro opkód `OP_VAULT`, přinášíme
souhrn diskuze o umožnění LN uzlům nastavit na svých kanálech příznak
vysoké dostupnosti, přeposíláme žádost o zpětnou vazbu k ohodnocování
sousedů LN uzlů a popisujeme návrh BIP pro zálohu a obnovu seedů bez
nutnosti používat jakoukoliv elektroniku. Též nechybí naše pravidelné
rubriky se souhrnem oblíbených otázek a odpovědí z Bitcoin StackExchange,
oznámeními o nových verzích a popisem významných změn oblíbených
páteřních bitcoinových projektů.

## Novinky


- **Návrh BIP pro OP_VAULT:** James O'Beirne [zaslal][obeirne op_vault]
  do emailové skupiny Bitcoin-Dev odkaz na [návrh BIP][bip op_vault] pro
  opkód `OP_VAULT`, který dříve navrhl (viz [zpravodaj č. 234][news234
  vault]). Též oznámil, že se pokusí začlenit kód do Bitcoin Inquisition,
  projektu pro testování významných návrhů změn konsenzu bitcoinu
  a síťového protokolu.

- **Příznak vysoké dostupnosti pro LN:** Joost Jager [zaslal][jager qos]
  do emailové skupiny Lightning-Dev návrh na umožnění uzlům signalizovat,
  že je kanál „vysoce dostupný,” tedy že operátor věří v jeho schopnost
  přeposílat platby bez selhání. Pokud však k selhání dojde, odesílatel
  by mohl přestat tento uzel používat na dobu mnohem delší, než v případě
  uzlů, které by tento příznak nastaven neměly. Odesílatelé plateb
  cílící na maximální rychlost (spíše než na nízké poplatky) by mohli
  dávat přednost trasám obsahující uzly s příznakem.

  Christian Decker [odpověděl][decker qos] výtečným shrnutím problémů
  reputačních systémů, včetně případů samozvané reputace. Jednou
  z jeho obav je, že běžný odesílatel nebude zdaleka posílat tolik
  plateb, aby v rámci rozsáhlé sítě kanálů opakovaně použil stejné uzly.
  Hrozba dočasného odmítnutí poskytnutí dalších služeb není příliš
  vážná v případě, kdy se jen zřídka vyžadují další služby.

  Antoine Riard [připomněl][riard boomerang] účastníkům alternativní
  přístup k urychlení plateb: přeplácení s vrácením, dříve zvané
  bumerangové platby („boomerang payments,” viz [zpravodaj č. 86][news86
  boomerang], *angl.*) či vratné přeplatky („refundable overpayments,”
  viz [zpravodaj č. 92][news192 pp], *angl.*). V tomto schématu
  by odesílatel vzal svou platbu, přidal peníze navíc, rozdělil na
  několik [částí][topic multipath payments] a odeslal je po několika
  trasách. Když příjemce obdrží dostatečné množství částí, které
  fakturu zaplatí, nárokuje si pouze tyto části a ostatní odmítne.
  Vyžaduje to, aby měl odesílatel ve svém kanálu prostředky navíc,
  avšak funguje to, i když některé trasy vybrané odesílatelem selžou.
  Snižuje to také nutnost, aby byl odesílatel schopen snadno vyhledat
  vysoce dostupné kanály. Složitost přístupu tkví ve vytvoření
  mechanismu, který by příjemcům zabránil nárokovat i přeplatky.

- **Žádost o zpětnou vazbu k hodnocení dobrých sousedů v LN:** Carla Kirk-Cohen
  a Clara Shikhelman [zaslaly][ckc-cs reputation] do emailové skupiny
  Lightning-Dev žádost o komentáře k doporučeným parametrům, které by
  umožnily uzlům posoudit, zda jsou druhé strany jejich kanálů dobrými
  zdroji přeposlaných plateb. Navrhují několik kritérií a pro každé
  z nich uvádí doporučené výchozí parametry. Rády by obdržely zpětnou
  vazbu ke zvoleným nastavením.

  Usoudí-li uzel, že jedno z jeho spojení je dobrým sousedem, a tento soused
  označí přeposlané platby za jím schválené, může tento uzel poskytnout
  platbě přístup k více zdrojům než platbám nekvalifikovaným. Mohl by platbu
  během přeposílání dalším uzlům také sám schválit. Tento mechanismus
  je součástí návrhu na zabránění [útoků zahlcením kanálu][topic channel
  jamming attacks], jak bylo popsáno v předchozím článku, jehož spoluautorkou
  byla Shikhelman (viz [zpravodaj č. 226][news226 jam], *angl.*).

- **Návrh BIP pro kódování seedů Codex32:** Russell O'Connor
  a Andrew Poelstra [publikovali][op codex32] (pod přesmyčkami svých jmen)
  návrh na BIP nového schématu pro zálohu a obnovu [BIP32][] seedů. Schéma
  může volitelně, podobně jako [SLIP39][], vytvořit několik dílů pomocí
  [Shamirova schématu pro sdílení tajných dat][Shamir's Secret Sharing Scheme]
  („Shamir's Secret Sharing Scheme”, SSSS), které pro obnovení seedu vyžádá
  použití přednastaveného minimálního počtu dílů. Útočník, který by
  obdržel nižší než stanovený počet dílů, by se o seedu nic nedozvěděl.
  Na rozdíl od obnovovacích kódů BIP39, Electrum, Aezeed či SLIP39, které
      používají sadu slov, Codex32 používá stejnou abecedu jako [bech32][topic
  bech32] adresy. Příklad jednoho takového dílu z návrhu BIP:

  ```text
  ms12namea320zyxwvutsrqpnmlkjhgfedcaxrpp870hkkqrm
  ```

  Hlavní výhodou Codex32 oproti všem existujícím schématům je, že
  všechny operace lze provést pouhým použitím tužky, papíru, instrukcí
  a výstřižků, včetně generování seedu (lze použít hrací kostku),
  jeho ochrany pomocí kontrolního součtu, generování dílů s kontrolními
  součty, jejich ověření a obnovy. Možnost manuálně ověřit kontrolní
  součet záloh seedu nebo jeho dílů nám připadá jako obzvláště mocný
  koncept. Jedinou v současnosti dostupnou metodou ověření záloh
  je vložení seedu do důvěryhodného počítače a ověření odvozených
  veřejných klíčů. Avšak stanovení, zda lze zařízení věřit, není často
  jednoduchou záležitostí. Co je horší, aby mohl uživatel ověřit
  integritu existujících SSSS dílů (např. podle SLIP39), musí přinést
  dohromady každý díl, který chtějí ověřit, spolu s dostatečným
  množství ostatních dílů a poté je vložit do důvěryhodného počítače.
  To znamená, že ověření integrity dílů potírá hlavní výhodu celého
  schématu, tedy možnost uložit informace bezpečně a odděleně napříč
  několika místy či lidmi. S Codex32 může uživatel pravidelně ověřovat
  integritu každého dílu odděleně pouze pomocí papíru a pera, několika
  vytištěných papírů a pár minut času.

  Diskuze v emailové skupině se hlavně soustředila na rozdíly mezi
  Codex32 a SLIP32, které je v produkci používáno již několik let.
  Doporučujeme každému zájemci o Codex32 pročíst jeho [webovou
  stránku][codex32 website] nebo shlédnout [video][codex32 video] od
  jednoho z autorů. Autoři doufají, že díky návrhu BIP začnou peněženky
  přidávat podporu pro seedy kódované pomocí Codex32.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*


{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč se během úvodního stahování v ořezaném režimu stahují witnessy?]({{bse}}117057)
  Pieter Wuille píše o případu uzlů běžících v [ořezaném
  režimu][prune mode]: „jsou-li witnessy (a) před ‚assumevalid’ bodem a (b)
  dostatečně hluboko za bodem ořezávání, skutečně nedává smysl je mít uložené.”
  Existuje otevřený [návrh změny][Bitcoin Core #27050], která tuto situaci adresuje,
  a [PR Review Club][pr review 27050] o této navrhované změně.

- [Může bitcoinová P2P síť posílat komprimovaná data?]({{bse}}116999)
  Pieter Wuille odkazuje na dvě emailové diskuze o kompresi (jedna je o
  [kompresi pro výměnu hlaviček][specialized compression for headers sync],
  druhá o [obecné kompresi založené na LZO][general LZO-based compression])
  a poznamenává, že satelity Blockstreamu používají pro transakce svá vlastní
  kompresní schémata.

- [Jak se stát DNS seedem pro Bitcoin Core?]({{bse}}116931)
  Uživatel Paro vysvětluje požadavky pro [DNS seed][news66 dns seed],
  které poskytuje novým uzlům prvotní spojení.

- [Kde mohu nalézt otevřená témata výzkumu bitcoinu?]({{bse}}116898)
  Michael Folkson poskytuje množství zdrojů, mimo jiné [Chaincode Labs
  Research][] a [Bitcoin Problems][].

- [Jaká největší transakce bude přeposlána bitcoinovým uzlem ve výchozím nastavení?]({{bse}}117277)
  Pieter Wuille poukazuje na pravidlo standardnosti, které uvádí 400 000 [váhových
  jednotek][weight unit], nastavení však není konfigurovatelné. Dále vysvětluje
  důvody limitu včetně ochrany proti zahlcení.

- [Jak fungují Ordinals v bitcoinu? Co přesně se v blockchainu ukládá?]({{bse}}117018)
  Vojtěch Strnad vysvětluje, že Ordinals Inscriptions nepoužívají `OP_RETURN`,
  ale vkládají data do nespuštěné větve skriptu pomocí `OP_PUSHDATAx` opkódů:

  ```
  OP_0
  OP_IF
  <tady jsou data>
  OP_ENDIF
  ```

- [Proč protokol neumožňuje expiraci nepotvrzených transakcí v dané výšce?]({{bse}}116926)
  Larry Ruane odkazuje na Satoshiho, proč by nebylo moudré, aby transakce
  měly zdánlivě užitečnou schopnost stanovit expirační výšku, tj. výšku,
  po které nebude transakci nadále platná.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 0.27.1][] je bezpečnostní aktualizací opravující zranitelnost, která
  „někdy způsobuje přetečení, když se do SQLite funkce printf strčí velký
  řetězec.” Pouze software, který používá BDK s volitelnou SQLite databází,
  musí být aktualizován. Detaily jsou obsaženy ve [zprávě o
  zranitelnosti][RUSTSEC-2022-0090].

- [Core Lightning 23.02rc3][] je kandidátem na vydání nové údržbové verze
  této oblíbené implementace LN.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*


- [Bitcoin Core #24149][] přidává podporu pro podepisování [deskriptorů
  výstupů][topic descriptors] založených na [miniscriptech][topic miniscript]
  založených na P2WSH. Bitcoin Core bude schopen podepisovat vstup jakéhokoliv
  miniscriptového deskriptoru, jsou-li přístupné všechny předobrazy a klíče
  a jsou-li časové zámky platné. Některé možnosti pro úplnou podporu
  zatím chybí: peněženka zatím neumí odhadnout váhu vstupu v případě některých
  deskriptorů a neumí v některých případech podepsat [PSBT][topic PSBT].
  Na podpoře miniscriptu pro P2TR výstupy se též pracuje.

- [Bitcoin Core #25344][] aktualizuje RPC volání `bumpfee` a `psbtbumpfee`
  pro navyšování poplatků pomocí [Replace By Fee][topic rbf] (RBF).
  Aktualizace umožňuje specifikovat výstupy nahrazující transakce.
  Nahrazující transakce může obsahovat jinou sadu výstupů než transakce
  nahrazovaná. Lze takto přidat nové výstupy (např. v případě iterativního
  [dávkování][topic payment batching]) nebo výstupy odebrat (např.
  chceme-li zrušit nepotvrzenou platbu).

- [Eclair #2596][] omezuje, kolikrát se může spojení pokusit navýšit poplatek
  pomocí [RBF][topic rbf] během otevírání kanálu s [oboustranným vkladem][topic dual
  funding]. Je-li počet překročen, žádné další pokusy o změnu nebudou přijaty.
  Důvodem této změny je, že uzel musí ukládat data o každé verzi otevírací
  transakce, mohl by tedy být problém, pokud by bylo možné navýšit poplatek
  bez omezení. Běžně je počet navýšení poplatku prakticky omezen potřebou
  za každý pokus platit poplatky. V případě oboustranného vkladu se však očekává,
  že budou uzly ukládat všechny pokusy, i takové, které nemohou validovat.
  Útočník by tak mohl vytvořit neomezené množství nevalidních transakcí
  navyšujících poplatek bez nutnosti za ně platit jakékoliv poplatky.

- [Eclair #2595][] pokračuje v práci na přidání podpory [splicingu][topic splicing],
  v tomto případě aktualizací konstruktorů transakcí.

- [Eclair #2479][] přidává podporu platby [nabídek][topic offers]
  následujícím způsobem: uživatel obdrží nabídku, řekne Eclairu, aby ji zaplatil,
  Eclair pomocí nabídky stáhne od příjemce fakturu, ověří parametry faktury
  a zaplatí ji.

- [LND #5988][] přidává novou volitelnou funkci odhadu pravděpodobnosti
  pro hledání platebních cest. Je částečně založen na dřívějším výzkumu
  (viz [zpravodaj č. 192][news192 pp], *angl.*) s použitím závěrů
  jiných přístupů.

- [Rust Bitcoin #1636][] přidává funkci `predict_weight()` pro odhad váhy.
  Vstupem funkce je vzor transakce, výstupem její očekávaná váha. To je obzvláště
  užitečné pro správu poplatků: aby bylo možné určit, které vstupy mají být
  přidány do transakce, musí být známa výše poplatku, ale aby byla známa výše
  poplatku, musí být známa velikost transakce. Funkce poskytuje odhad velikosti,
  aniž by se transakci pokusila sestavit.

{% include references.md %}
{% include linkers/issues.md v=2 issues="24149,25344,2596,2595,2479,5988,1636,27050" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news92 overpayments]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[codex32 website]: https://secretcodex32.com/
[codex32 video]: https://www.youtube.com/watch?v=kf48oPoiHX0
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021465.html
[bip op_vault]: https://github.com/jamesob/bips/blob/jamesob-23-02-opvault/bip-vaults.mediawiki
[news234 vault]: /cs/newsletters/2023/01/18/#navrh-na-nove-opkody-pro-uschovny
[jager qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003842.html
[decker qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003844.html
[riard boomerang]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003852.html
[ckc-cs reputation]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003857.html
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[shamir's secret sharing scheme]: https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing
[prune mode]: https://bitcoin.org/en/full-node#reduce-storage
[pr review 27050]: https://bitcoincore.reviews/27050
[specialized compression for headers sync]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015851.html
[general LZO-based compression]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-November/011837.html
[news66 dns seed]: /en/newsletters/2019/10/02/#bitcoin-core-15558
[Chaincode Labs Research]: https://research.chaincode.com/research-intro/
[Bitcoin Problems]: https://bitcoinproblems.org/
[weight unit]: https://en.bitcoin.it/wiki/Weight_units
[op codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021469.html
[RUSTSEC-2022-0090]: https://rustsec.org/advisories/RUSTSEC-2022-0090
[bdk 0.27.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.1
