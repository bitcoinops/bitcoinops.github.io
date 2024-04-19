---
title: 'Zpravodaj „Bitcoin Optech” č. 288'
permalink: /cs/newsletters/2024/02/07/
name: 2024-02-07-newsletter-cs
slug: 2024-02-07-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme oznámení o veřejném odhalení chyby v Bitcoin Core
postihující LN, popis bezpečného otevírání nových 0-conf kanálů v souladu
s omezenou topologií navrhovaných transakcí verze 3, popis pravidla, kterým
se musí řídit mnohé protokoly umožňující třetím stranám přispět vstupem
do transakce, souhrn několika diskuzí o návrhu nových pravidel nahrazování
transakcí eliminující pinning transakcí a aktualizaci migrace emailové
skupiny Bitcoin-Dev.

## Novinky

- **Zveřejnění chyby v Bitcoin Core způsobující pozdržení bloků a postihující LN:**
  Eugene Siegel [odhalil][siegel stall] na fóru Delving Bitcoin chybu
  v Bitcoin Core, kterou [zodpovědně nahlásil][topic responsible
  disclosures] před téměř třemi lety. Bitcoin Core 22 a vyšší obsahují opravy
  této chyby, ale mnoho lidí stále provozuje dotčené verze a někteří z nich
  mohou provozovat i LN implementace či jiný podobný software, který by
  mohl být zranitelný vůči zneužití chyby. Důrazně se doporučuje upgradovat
  na Bitcoin Core 22 či vyšší. Pokud víme, nikdo kvůli tomuto útoku
  nepřišel o prostředky.

  Útočník nalezne přeposílající LN uzel, který je napojený na bitcoinový
  uzel s Bitcoin Core verze starší než 22. Dále útočník otevře k bitcoinovému uzlu
  oběti velké množství spojení. Poté se snaží oběti doručit nově nalezené
  bloky rychleji než jiná, čestná spojení. Uzel oběti nato automaticky
  přiřadí spojením kontrolovaným útočníkem veškeré sloty se širokým pásmem
  pro [přeposílání kompaktních bloků][topic compact block relay].

  Poté, co útočník získá kontrolu nad mnoha sloty uzlu oběti, začne používat
  kanály, které ovládá na obou stranách oběti, k přeposílání jím vytvořených plateb.
  Například:

  ```
  Útočník-plátce –> Oběť-přeposílající –> Útočník-příjemce
  ```

  Útočník ve spolupráci s těžařem vytvoří blok, který jednostranně uzavírá kanál
  na příjemcově straně, aniž by prvně přeposlal transakci v nepotvrzeném stavu
  (tato těžařova asistence je potřebná pouze během útoků na implementace LN,
  které monitorují mempool). Tento blok (nebo jiný vytvořený tímto těžařem)
  též nárokuje platbu uvolněním předobrazu [HTLC][topic htlc]. V běžné situaci
  by bitcoinový uzel oběti tento blok viděl, poskytl by jej LN uzlu a LN uzel by
  předobraz extrahoval. Díky tomu by mohl částku platby nárokovat a udržet
  tak přeposílání v rovnováze.

  V tomto případě však útočník zneužije této odhalené chyby, kvůli které
  se uzel s Bitcoin Core o bloku obsahujícím předobraz nedozví. Starší verze
  Bitcoin Core byly ochotné čekat až deset minut na doručení oznámeného bloku od
  jednoho spojení, než si ho vyžádaly od spojení jiného. Jelikož je průměrná doba
  mezi dvěma bloky deset minut, mohl by útočník kontrolující _x_ spojení pozdržet
  uzel od obdržení bloku zhruba po dobu odpovídající _x_ blokům. Pokud musí
  být přeposílaná platba nárokovaná během 40 bloků, má útočník kontrolující
  50 spojení nemalou možnost, že se mu podaří zabránit uzlu spatřit blok
  s předobrazem. Pokud by se tak stalo, útočníkův odesílající uzel by neplatil
  nic a útočníkův přijímající uzel by obdržel částku extrahovanou od uzlu
  oběti.

  Dle Siegela byly pro zabránění útoku provedeny dvě změny v Bitcoin Core:

  * [Bitcoin Core #22144][] přidává náhodnost do pořadí, ve kterém jsou
    spojení ve vlákně zpracovávajícím zprávy obsloužena. Viz [zpravodaj č.
    154][news154 stall] (_angl._).

  * [Bitcoin Core #22147][] udržuje alespoň jedno odchozí spojení se širokým
    pásmem pro kompaktní bloky, i když mají příchozí spojení lepší
    výkonnost. Místní uzel si svá odchozí spojení sám vybírá, mají tedy
    nižší pravděpodobnost dostat se pod kontrolu útočníka. Z bezpečnostních
    důvodů je výhodné udržovat alespoň jedno odchozí spojení.

- **Bezpečné otevírání 0-conf kanálů s transakcemi verze 3:**
  Matt Corallo zaslal do fóra Delving Bitcoin [příspěvek][corallo 0conf], aby
  zahájil diskuzi o bezpečném [otevírání 0-conf kanálů][topic zero-conf
  channels], jakmile začnou být používána navrhovaná [pravidla přeposílání
  transakcí verze 3][topic v3 transaction relay]. 0-conf kanály jsou nové
  kanály financované jednou stranou, kde zakládající strana věnuje část
  nebo všechny počáteční prostředky straně druhé. Tyto prostředky nejsou
  zabezpečené, dokud otevírající transakce neobdrží dostatečné množství
  konfirmací, avšak útrata těchto prostředků přes zakládající stranu
  nepřináší příjemci kanálu žádné riziko. Původní návrh pravidel přeposílání
  transakcí verze 3 umožňoval, aby měla nepotvrzená v3 transakce v mempoolu
  maximálně jednoho potomka. Očekávalo se, že by tento jediný potomek
  v případě potřeby navýšil rodičovské transakci poplatek pomocí [CPFP][topic
  cpfp].

  Tato pravidla nejsou v souladu s možností obou stran 0-conf kanálů navýšit
  poplatek: zakládající transakce, která kanál vytváří, je rodičem v3 transakce,
  která kanál zavírá, a prarodičem v3 transakce pro navýšení poplatku.
  Jelikož v3 pravidla povolují pouze jednoho rodiče a jednoho potomka, neexistuje
  způsob navýšení poplatku zakládající transakce, aniž by byl změněn způsob,
  kterým je tvořena. Bastien Teinturier [poznamenává][teinturier splice],
  že [splicing][topic splicing] trpí podobným problémem.

  V době psaní zpravodaje se hlavním řešením zdá býti přidat extra výstup
  pro CPFP navyšování nyní, počkat, až bude [cluster mempool][topic cluster
  mempool] shovívavější i vůči jiným topologiím (tedy více než jeden
  rodič a jeden potomek), a potom opět extra výstup zahodit.

- **Požadavky na ověření, že vstupy v protokolech citlivých na poddajnost txid používají segwit:**
  Bastien Teinturier zaslal do fóra Delving Bitcoin [příspěvek][teinturier segwit]
  s popisem snadno přehlédnutelného požadavku na protokoly, ve kterých třetí strana
  přispívá vstupem transakce, aby se nemohlo změnit txid poté, co jiný uživatel
  transakci podepíše. Například během [otevření LN kanálu s oboustranným
  financováním][topic dual funding] mohou Alice i Bob přispět vstupem.
  Aby zajistili, že každý z nich obdrží refundaci, pokud by druhá strana později
  přestala spolupracovat, vytvoří a podepíší utracení financující transakce,
  které prozatím ponechají offchain. Poté, co oba refundovací transakci podepíší,
  mohou bezpečně podepsat a zveřejnit rodičovskou, financující transakci.
  Jelikož závisí potomek (refundovací transakce) na txid rodiče (financující
  transakce), je tento process bezpečný pouze, pokud není možné txid změnit.

  Segwit brání poddajnosti txid jen, pokud všechny vstupy transakce utrácejí
  segwitové výstupy předchozích transakcí. Segwit v0 nabízí Alici pouze jednu
  možnost, jak zaručit, že Bob utrácí segwitový výstup: Bob musí Alici
  poskytnout celou předchozí transakci. Pokud by Alice Bobův vstup neověřila,
  mohl by Bob o utrácení segwitového výstupu lhát a namísto toho utrácet
  zastaralý výstup, který by mu umožnil pozměnit txid. Tím by mohl zneplatnit
  refundovací transakcí a odmítat vrátit Alici prostředky, dokud by nesouhlasila
  s platbou výkupného.

  U segwitu v1 ([taproot][topic taproot]) je každý `SIGHASH_ALL` podpis zavázán
  všem předchozím utráceným výstupům (viz [zpravodaj č. 97][news97 spk], _angl._),
  Alice tedy může od Boba vyžadovat odhalení jeho scriptPubKey (které by se stejně
  dozvěděla z jiných informací, které jí Bob musí sdělit, aby mohli vytvořit
  sdílenou transakci). Alice ověří, že scriptPubKey používá segwit (v0 nebo v1) a
  zaváže mu svůj podpis. Nyní, pokud by Bob lhal a ve skutečnosti přispěl
  nesegwitovým výstupem, závazek Alicina podpisu by nebyl platný, a tedy podpis
  by nebyl validní, financující transakce by se nepotvrdila a nebyla by žádná
  potřeba refundace.

  To vede ke dvěma pravidlům, kterými se pro zajištění bezpečnosti musí protokoly
  závisející na předem podepsaných refundacích řídit:

  1. Pokud přispíváte vstupem, upřednostňujte vstup, který utrácí segwit v1
	 výstup, získejte předchozí výstupy všech ostatních vstupů v transakci,
	 ověřte, že všechny používají segwitové scriptPubKey a zavažte vůči nim
	 svůj podpis.

  2. Pokud nepřispíváte vstupem nebo neutrácíte segwitový v1 výstup, získejte
	 kompletní předchozí transakce všech vstupů, ověřte, že všechny výstupy
	 utrácené v této transakci jsou segwitové výstupy a zavažte vůči těmto
	 transakcím svůj podpis. Tuto možnost lze aplikovat ve všech případech,
	 avšak v nejhorším případě spotřebuje až téměř 20 000× více šířky
	 pásma než první možnost.

- **Návrh na nahrazování jednotkovým poplatkem jako řešení pinningu:** Peter Todd
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][todd rbfr] s návrhem na
  skupinu pravidel [nahrazování transakcí][topic rbf], která by mohla být
  použita, i když stávající pravidla nahrazování poplatkem (RBF) nahrazení transakce
  nepovolují. Jeho návrh obsahuje dvě varianty:

  - *Ryzí nahrazení jednotkovým poplatkem („pure replace by feerate“, „pure RBFr”):*
	transakce v mempoolu může být nahrazena konfliktní transakcí, která platí
	výrazně vyšší jednotkový poplatek (například dvojnásobně vyšší).

  - *Jednorázové nahrazení jednotkovým poplatkem („one-shot replace by feerate”, „one-shot RBFr”):*
	transakce v mempoolu může být nahrazena konfliktní transakcí, která platí
	mírně vyšší jednotkový poplatek (např. 1,25×), pokud by byl jednotkový
	poplatek nahrazující transakce dostatečně vysoký na zařazení mezi
	nejvyšších 1 000 000 vbyte mempoolu (tedy nahrazovaná transakce by
	byla vytěžena, pokud by byl blok nalezen ihned po přijetí transakce).

  Mark Erhardt popsal ([1][erhardt rbfr1], [2][erhardt rbfr2]), jak by mohla být
  tato navrhovaná pravidla zneužita k plýtvání nekonečného množství šířky
  pásma uzlu s minimálními náklady pro útočníka. Peter Todd pravidla upravil,
  aby tuto konkrétní možnost zneužití eliminoval, ale Gregory Sanders a
  Gloria Zhao nadnesli ve [vlákně fóra][sz rbfr] další obavy:

	- „Přemýšlet o tomto před cluster mempoolem je hodně těžké. Peterova
	  první iterace této myšlenky byla rozbitá, protože umožňovala neomezené
	  přeposílání zdarma. Tvrdí, že to opravil přidáním dalších RBF restrikcí,
	  ale jako obvykle je velmi náročné o současných pravidlech uvažovat,
	  možná i nemožné. Myslím, že by se úsilí mělo raději soustředit na
	  nastavení správných incentiv pro RBF než na kompletní zahození
	  ochrany proti přeposílání grátis.”  ---Sanders

	- „Mempool v současnosti kvůli neomezené velikosti clusteru nepodporuje
	  efektivní způsob výpočtu ‚těžařova skóre’ nebo souladu ekonomických podnětů.
	  […] Jednou z výhod cluster mempoolu je možnost spočítat věci jako
	  těžařovo skóre a soulad ekonomických podnětů napříč mempoolem. Podobně
	  je jednou z výhod v3 možnost to díky omezené topologii dělat i před cluster
	  mempoolem. Dřív, než lidé začali navrhovat a implementovat cluster mempool,
	  hovořila jsem o v3 jako o ‚cluster limitech’ bez nutnosti cluster limity
	  implementovat, protože je to jedna z mála možností, jak kodifikovat
	  cluster limit (počet=2) pomocí stávajících limitů balíčků (předkové=2,
	  potomci=2. Při navýšení na 3 bychom opět měli neomezené clustery). Další
	  výhodou v3 je, že může pomoci odblokovat cluster mempool, což je podle
	  mého názoru bez debat. Abych to shrnula, nemyslím si, že návrh na
	  One-Shot Replace by Feerate funguje (tj. netrpí problémem přeposílání
	  zdarma) a je možné ho přesně implementovat.”
	  ---Zhao

  V době psaní nedosáhly diskuze urovnání. Peter Todd uvolnil experimentální
  [implementaci][libre relay] pravidel nahrazování jednotkovým poplatkem.

- **Aktualizace migrace emailové skupiny Bitcoin-Dev:** v době psaní již emailová
  skupina Bitcoin-Dev přestala akceptovat nové příspěvky v rámci migrace k jinému
  provozovateli skupiny (viz [zpravodaj č. 276][news276 ml]). Až bude migrace
  dokončena, poskytneme další aktualizaci.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.17.4-beta][] je údržbovým vydáním této oblíbené implementace LN
  uzlu. Jeho poznámky k vydání uvádějí: „jedná se o opravné vydání, které
  opravuje několik chyb: otevírání kanálu uvízlé až do restartu, únik paměti
  při použití dotazovacího režimu pro `bitcoind`, ztracená synchronizace
  s ořezanými uzly a REST proxy nefungující se zapnutým šifrováním s TLS
  certifikáty.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29189][] zastarává libconsensus. Libconsensus byl pokus sdílet
  logiku konsenzu Bitcoin Core s jiným software. Avšak knihovna se nesetkala
  s významným použitím a začala být během udržování Bitcoin Core přítěží.
  Plán je „nemigrovat ji na CMake a ukončit ji s v27. V budoucnosti by měla
  všechny zbývající případy použití zvládnout knihovna [libbitcoinkernel][].”

- [Bitcoin Core #28956][] odstraňuje z Bitcoin Core čas upravený dle sítě a varuje
  uživatele, pokud není čas jejich počítače v souladu se zbytkem sítě. Čas
  upravený dle sítě („adjusted time”) byla automatická úprava času místního
  uzlu založená na času jeho spojení. To mohlo pomoci uzlu s mírně nepřesnými
  hodinami se o problému dozvědět a předejít tak zbytečnému odmítání bloků a dát
  produkovaným blokům přesnější čas. Avšak upravený čas vedl v minulosti k některým
  problémům a v současné síti neposkytuje žádné významné výhody. Tímto PR
  jsme se zabývali ve [zpravodaji č. 284][news284 adjtime].

- [Bitcoin Core #29347][] ve výchozím stavu zapíná [P2P přenos verze 2][topic v2 p2p
  transport]. Nová spojení mezi dvěma uzly podporujícími v2 protokol budou používat
  šifrování.

- [Core Lightning #6985][] přidává do `hsmtool` volbu, která mu umožní vrátit
  soukromé klíče pro onchain peněženku. Ty mohou být nato importovány do jiné
  peněženky.

- [Core Lightning #6904][] přináší několik aktualizací kódu správy spojení
  a gossip zpráv. Viditelnou změnou je přidání pole, které ukazuje, kdy mělo
  nějaké spojení stabilní připojení k místnímu uzlu na více než minutu. Díky
  tomu mohou být nestabilní spojení ukončena.

- [Core Lightning #7022][] odstraňuje z testovací infrastruktury `lnprototest`.
  [Zpravodaj č. 145][news145 lnproto] (_angl._) popisuje jeho přidání.

- [Core Lightning #6936][] přidává infrastrukturu napomáhající se zastaráváním
  funkcí CLN. Funkce jsou nyní v kódu zastarávány automatickou deaktivací ve
  výchozím nastavení dle verze programu. Uživatelé mohou funkci aktivovat
  i po této verzi, dokud kód funkce stále existuje. Zabraňuje to občasným
  problémům, kdy byla funkce CLN označena za zastaralou, ale ve výchozím
  nastavení nadále po dlouhou dobu fungovala i po plánovaném odstranění.
  Kvůli tomu mohli na funkci uživatelé nadále záviset a tím tak reálné odstranění
  ztížit.

- [LND #8345][] počíná před samotným zveřejněním testovat, zda bude transakce
  pravděpodobně rozeslána. Používá k tomu volání `testmempoolaccept`, pokud
  je dostupné. To umožní uzlu odhalit případné problémy s transakcí dříve, než
  je cokoliv odesláno třetím stranám, urychlit odhalení problémů a omezit
  jejich dopady. Varianty volání `testmempoolaccept` jsou dostupné v Bitcoin
  Core, jeho nejnovějších odnožích a v btcd.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29189,28956,29347,6985,6904,7022,6936,7022,6936,8345,22144,22147" %}
[news154 stall]: /en/newsletters/2021/06/23/#bitcoin-core-22144
[news145 lnproto]: /en/newsletters/2021/04/21/#c-lightning-4444
[siegel stall]: https://delvingbitcoin.org/t/block-stalling-issue-in-core-prior-to-v22-0/499/
[corallo 0conf]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/
[teinturier splice]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/2
[teinturier segwit]: https://delvingbitcoin.org/t/malleability-issues-when-creating-shared-transactions-with-segwit-v0/497
[news97 spk]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[todd rbfr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022298.html
[erhardt rbfr1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022302.html
[erhardt rbfr2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022316.html
[sz rbfr]: https://delvingbitcoin.org/t/replace-by-fee-rate-vs-v3/488/
[libre relay]: https://github.com/petertodd/bitcoin/tree/libre-relay-v26.0
[libbitcoinkernel]: https://github.com/bitcoin/bitcoin/issues/27587
[news284 adjtime]: /cs/newsletters/2024/01/10/#bitcoin-core-pr-review-club
[news276 ml]: /cs/newsletters/2023/11/08/#hosting-emailove-skupiny
[lnd v0.17.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.4-beta
