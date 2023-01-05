---
title: 'Zpravodaj „Bitcoin Optech” č. 232'
permalink: /cs/newsletters/2023/01/04/
name: 2023-01-04-newsletter-cs
slug: 2023-01-04-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme varování o kompromitaci podepisovacích klíčů Bitcoin Knots,
oznámení o vydání dvou softwarových forků Bitcoin Core a souhrn pokračující diskuze
o pravidlech nahrazování transakcí. Též nechybí naše pravidelné rubriky s oznámeními
o softwarových vydáních a popisem významných změn populárního bitcoinového páteřního
software.

## Novinky

- **Klíče podepisující Bitcoin Knots kompromitovány:** vývojář implementace
  plného uzlu Bitcoin Knots oznámil, že PGP klíč, který používá k podepisování
  vydání Knots, byl kompromitován. Dále řekl: „Nestahujte Bitcoin Knots a
  nedůvěřujte mu, dokud se to nevyřeší. Pokud jste tak již v minulých několika
  měsících učinili, zvažte dočasné vypnutí.” Jiné implementace plného uzlu
  nejsou poznamenány.

- **Softwarové forky Bitcoin Core:** minulý měsíc byly vydány dvě modifikace
  Bitcoin Core:

    - *Bitcoin Inquisition:* Anthony Towns [oznámil][towns bci] v emailové
	skupině Bitcoin-Dev novou verzi [Bitcoin Inquisition][], softwarového
	forku Bitcoin Core navrženého k testování soft forků a jiných změn protokolu
	na [signetu][topic signet]. Tato verze obsahuje podporu pro navrhované
	[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] a [OP_CHECKTEMPLATEVERIFY][topic
	op_checktemplateverify]. Townsův email dále obsahuje dodatečné informace pro
	každého, kdy bych se chtěl tohoto testování zúčastnit.

    - *Uzel pro full RBF spojení:* Peter Todd [oznámil][todd rbf node]
      patch Bitcoin Core 24.0.1, který nastavuje [full-RBF service bit][]
	  během oznamování síťových adres dalším uzlům, avšak pouze má-li
	  uzel nastavenu volbu `mempoolfullrbf`. Uzly běžící s tímto patchem
	  se navíc připojují až k čtyřem dalším uzlům oznamujícím podporu pro
	  full RBF. Peter Todd poznamenává, že Bitcoin Knots, jiná implementace
	  plného uzlu, také oznamuje tento service bit, i když neobsahuje obdobný
	  kód pro připojování. Patch je založen na Bitcoin Core pull requestu
	  [#25600][bitcoin core #25600].

- **Pokračuje diskuze o RBF:** v pokračující diskuzi o aktivaci [full-RBF][topic
  rbf] na mainnetu se minulý měsíc v emailové skupině rozvíjelo několik
  paralelních debat:

    - *Uzly s full RBF:* Peter Todd prozkoumal plné uzly, které oznamovaly,
	  že provozovaly Bitcoin Core 24.x a akceptovaly spojení na IPv4 adrese.
	  [Zjistil][todd probe], že kolem 17 % přeposílalo full RBF nahrazení:
	  transakce, které nahradily transakce bez [BIP125][] signálu.
	  Může to znamenat, že tyto uzly měly aktivovánu volbu `mempoolfullrbf`,
	  i když je ve výchozím stavu vypnuta.

    - *Nové úvahy o RBF-FSS:* Daniel Lipshitz [zaslal][lipshitz
      fss] do emailové skupiny Bitcoin-Dev nápad na druh nahrazování
	  transakcí nazývaný First Seen Safe (FSS), kde by nahrazující transakce
	  platila původním výstupům minimálně stejnou částku jako původní transakce.
	  To by zaručilo, že by mechanismus nahrazování nemohl být použit
	  ke krádeži prostředků od příjemce původní transakce. Yuval Kogman ve
	  své [odpovědi][kogman fss] připojil odkaz na [ranější verzi][rbf-fss]
	  stejné myšlenky sdílené v roce 2015 Peterem Toddem. Todd v
	  [následující odpovědi][todd fss] popsal, proč je tento způsob
	  méně preferovaný než opt-in nebo full RBF.

    - *Motivace k full RBF:* Anthony Towns zaslal do vlákna [příspěvek][towns
	  rbfm] s výčtem motivací různých skupin k používání full RBF. Towns
	  analyzuje, co znamená a neznamená ekonomická racionalita v kontextu
	  výběru transakcí těžařem. Těžaři optimalizující pro krátkodobý profit
	  by přirozeně preferovali full RBF. Avšak, poznamenává Towns, těžaři,
	  kteří učinili dlouhodobé kapitálové investice do zařízení, mohou namísto
	  toho optimalizovat příjem z poplatků napříč několika bloky a nemusí
	  tak nezbytně nutně upřednostňovat full RBF. Navrhuje k úvaze tři různé
	  scénáře.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Eclair 0.8.0][] je hlavním vydáním této oblíbené implementace LN uzlu.
  Přidává podporu pro [zero-conf kanály][topic zero-conf channels] a aliasy
  pro krátké identifikátory kanálu (SCID). Pro více informací o těchto
  funkcích a dalších změnách viz [poznámky k vydání][eclair 0.8 rn].

- [LDK 0.0.113][] je novou verzí této knihovny pro tvorbu peněženek a aplikací
  s Lightning Network.

- [BDK 0.26.0-rc.2][] je kandidátem na vydání této knihovny pro tvorbu peněženek.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26265][] snižuje požadavky na minimální povolenou velikost
  serializované transakce bez witnessů v rámci pravidel přeposílání transakcí
  z 82 bytů na 65 bytů. Například transakce s jedním vstupem a jedním výstupem
  se 4 byty OP_RETURN, která byla v předchozích verzích odmítáná z důvodu
  příliš malé velikosti, by nyní byla do mempoolu přijata a přeposílána dále.
  Pro informace o pozadí a motivaci viz [zpravodaj č. 222][min relay size ml]
  (*angl.*).

- [Bitcoin Core #21576][] umožňuje peněženkám používajícím externí podpisová zařízení
  navýšit poplatek pomocí [RBF][topic rbf], a to v GUI i RPC volání `bumpfee`.

- [Bitcoin Core #24865][] umožňuje, aby byla peněženka obnovena ze zálohy
  též na ořezaných uzlech. Je však nutné, aby byly k dispozici bloky
  vzniklé po vytvoření peneženky. Bloky jsou potřebné při hledání všech
  transakcí, které mají vliv na stav peněženky. Záloha peněženky vytvořená
  z Bitcoin Core obsahuje datum vytvoření peněženky.

- [Bitcoin Core #23319][] přidavá do odpovědi RPC volání `getrawtransaction`
  dodatečné informace, je-li parametr `verbose` nastaven na `2`. Tyto
  nové informace obsahují poplatek za transakci a detaily o každém z
  předchozích výstupů, které jsou utráceny v této transakci. Pro podrobnosti
  o metodě získání těchto informací viz [zpravodaj č. 172][news172 prevout]
  (*angl.*).

- [Bitcoin Core #26628][] odmítne RPC požadavky, obsahují-li opakovaný název
  parametru. Dříve byl v takovém případě uvažován pouze poslední z opakovaných
  parametrů, např. z `{"foo"="bar", "foo"="baz"}` byl použit pouze `{"foo"="baz"}`.
  Takový požadavek bude nově odmítnut a bude vrácena chybová hláška.  `bitcoin-cli`
  používání opakovaných paramterů nemění; požadavek odmítnut nebude, avšak bude
  odeslán pouze poslední výskyt opakovaného parametru.

- [Eclair #2464][] přidává možnost spustit událost, jakmile je spojení uzlu
  připravené přijímat platby. To je obzvláště užitečné v případě [asynchronních
  plateb][topic async payments], kdy uzel dočasně zadržuje platbu pro vzdálené
  spojení, čeká, až se připojí, a pak platbu doručí.

- [Eclair #2482][] umožňuje posílání platby pomocí [zaslepených tras][topic
  rv routing], což jsou cesty, jejichž několik posledních uzlů je
  zvoleno příjemcem. Příjemce zakryje informace o uzlech pomocí onion šifrování
  a pošle tato zašifrovaná data plátci spolu s identitou prvního uzlu
  zaslepené trasy. Plátce poté vytvoří cestu k tomuto prvnímu uzlu a
  připojí zašifrované údaje pro operátory posledních několika uzlů.
  Tento způsob umožňuje příjemci obdržet platbu, aniž by odhalil identitu
  svého uzlu nebo kanálů vedoucích k plátci, čímž zvušuje své soukromí.

- [LND #2208][] počíná volit odlišné cesty podle poměru kapacity
  kanálu a částky platby. S částkou blížící se kapacitě kanálu klesá
  pravděpodobnost zařažení kanálu do cesty. Tento přístup je podobný
  hledání cesty v Core Lightning a LDK.

- [LDK #1738][] a [#1908][ldk #1908] přidávají nové funkce pro nakládání s
  [nabídkami][topic offers].

- [Rust Bitcoin #1467][] přidává vstupům a výstupům metody pro výpočet
   velikosti ve [váhových jednotkách][weight units].

- [Rust Bitcoin #1330][] odstraňuje datový typ `PackedLockTime`, jehož
  náhradou je téměř shodný typ `absolute::LockTime`. Rozdíl mezi těmito
  dvěma typy, který může mít vliv na použití, je, že `PackedLockTime`
  poskytoval implementaci traitu `Ord`, avšak `absolute::LockTime` ji
  neposkytuje. Locktime však bude i tak při řazení transakcí brán do úvahy.

- [BTCPay Server #4411][] aktualizuje verzi závislosti Core Lightning na
  22.11 (viz [zpravodaj č. 229][news229 cln]). Uživatelé, kteří chtějí
  do [BOLT11][] faktury zahrnout hash popisky objednávky, již nemusí k tomuto
  účelu používat plugin `invoiceWithDescriptionHash`, ale postačí nastavit
  pole `description` a volbu `descriptionHashOnly`.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26265,21576,24865,23319,26628,2464,2482,2208,1738,1908,1467,1330,4411,25600" %}
[news172 prevout]: /en/newsletters/2021/10/27/#bitcoin-core-22918
[weight units]: https://en.bitcoin.it/wiki/Weight_units
[towns bci]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021275.html
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[todd probe]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021296.html
[lipshitz fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021272.html
[kogman fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021274.html
[todd fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021286.html
[rbf-fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-May/008248.html
[towns rbfm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021276.html
[todd rbf node]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021270.html
[news229 cln]: /cs/newsletters/2022/12/07/#core-lightning-22-11
[full-rbf service bit]: https://github.com/petertodd/bitcoin/commit/c15b8d70778238abfa751e4216a97140be6369af
[eclair 0.8.0]: https://github.com/ACINQ/eclair/releases/tag/v0.8.0
[eclair 0.8 rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.8.0.md
[ldk 0.0.113]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.113
[bdk 0.26.0-rc.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0-rc.2
[min relay size ml]: /en/newsletters/2022/10/19/#minimum-relayable-transaction-size
