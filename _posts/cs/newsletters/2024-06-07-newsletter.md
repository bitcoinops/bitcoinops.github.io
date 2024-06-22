---
title: 'Zpravodaj „Bitcoin Optech” č. 306'
permalink: /cs/newsletters/2024/06/07/
name: 2024-06-07-newsletter-cs
slug: 2024-06-07-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje nadcházející odhalení zranitelností postihujících
starší verze Bitcoin Core, popisuje návrh BIPu pro novou verzi testnetu, shrnuje
návrh na kovenanty založené na funkcionálním šifrování, zkoumá aktualizaci
návrhu na provádění 64bitové aritmetiky v bitcoinovém Scriptu, odkazuje na skript
validující proof of work na signetu pomocí opkódu `OP_CAT` a nahlíží na
navrhovanou aktualizaci specifikace BIP21 URI ve tvaru `bitcoin:`. Též nechybí
naše pravidelné rubriky s oznámeními nových vydání a souhrnem významných změn
v populárním bitcoinovém páteřním software.

## Novinky

- **Nadcházející odhalení zranitelností postihujících staré verze Bitcoin Core:**
  několik členů projektu Bitcoin Core [diskutovalo][irc disclose] na IRC o
  [navrhovaných pravidlech][disclosure policy] pro odhalování zranitelností,
  které postihovaly starší verze Bitcoin Core. V případě zranitelností s nízkou
  závažností budou podrobnosti odhaleny dva týdny po vydání první verze Bitcoin
  Core, která zranitelnost odstraňuje či dostatečně zmírňuje její dopad. Většina
  ostatních zranitelností bude s podrobnostmi odhalena poté, co poslední verze
  Bitcoin Core postižená zranitelností dosáhne end-of-life (což je zhruba 1,5 roku
  po vydání). U výjimečných kritických zranitelností budou členové bezpečnostního
  týmu Bitcoin Core soukromě diskutovat nejvhodnější postup odhalení.

  Po dostatečném prodiskutování těchto pravidel je záměrem projektu začít odhalovat
  zranitelnost postihující Bitcoin Core 24.x a nižší. **Důrazně se doporučuje**, aby
  během následujících dvou týdnů všichni uživatelé a správci upgradovali na Bitcoin
  Core 25.0 nebo vyšší. V ideálním případě (pokud je to možné) by měly být používány
  poslední verze, ať již absolutně poslední verze (v době psaní 27.0) nebo poslední
  verze konkrétní série (např. 25.2 u série 25.x nebo 26.1 u série 25.x).

  Jak je naší politikou, Optech poskytne souhrn všech významných bezpečnostních
  odhalení postihujících páteřní projekty, které monitorujeme (včetně Bitcoin Core).

- **BIP a experimentální implementace testnet4:** Fabian Jahr zaslal do
  emailové skupiny Bitcoin-Dev [příspěvek][jahr testnet4] s oznámením
  [návrhu BIPu][bips #1601] pro testnet4, novou verzi [testnetu][topic
  testnet] navrženou na odstranění některých problémů se stávajícím
  testnet3 (viz [zpravodaj č. 297][news297 testnet]). Jahr též odkazuje
  na [pull request][bitcoin Core #29775] Bitcoin Core s návrhem implementace.
  Testnet4 se od testnet3 odlišuje ve dvou významných aspektech:

  - *Méně často difficulty-1:* bývalo snadné (nahodile či záměrně)
	redukovat složitost (difficulty) celé periody 2 016 bloků na její
	minimum (difficulty-1). Postačovalo k tomu vytěžit poslední blok periody
	s časovým razítkem o více než 20 minut vyšším, než měl předposlední blok.
	Nově se může složitost snížit pouze stejným způsobem jako na mainnetu,
	ačkoliv je stále možné vytěžit všechny jednotlivé bloky (kromě prvního
	bloku periody) s difficulty-1, mají-li časová razítka o více než 20
	minut vyšší než přecházející blok.[^testnet-fixup]

  - *Ohýbání času opraveno:* zneužitím [útoku ohýbáním času][topic time warp]
	(time warp attack) bylo na testnet3 (i na mainnetu) možné produkovat bloky
	výrazně rychleji než jednou za 10 minut, aniž by byla zvýšena složitost.
	Testnet4 nově implementuje řešení ohýbání času, které bylo navrženo v rámci
	mainnetového soft forku [pročištění konsenzu][topic consensus cleanup].

  Návrh BIPu též zmiňuje dodatečné a alternativní nápady určené pro testnet4,
  o kterých se diskutovalo, avšak nakonec použity nebyly.

- **Kovenanty s použitím funkcionálního šifrování:** Jeremy Rubin zaslal do fóra
  Delving Bitcoin [příspěvek][rubin fe post] s myšlenkou na přidání celého souboru
  [kovenantů][topic covenants] do bitcoinu pomocí [funkcionálního šifrování][functional
  encryption] a bez nutnosti změn konsenzu. Toto řešení by po uživatelích kovenantů
  požadovalo důvěřovat třetí straně, ačkoliv tato důvěra by mohla být distribuována mezi
  několik jednotek a stačilo by, aby jen jeden z nich jednal v daný čas čestně.

  V zásadě by funkcionální šifrování umožnilo vytvořit veřejný klíč, který by
  odpovídal určitému programu. Strana, která by program dokázala úspěšně spustit,
  by byla schopna vytvořit podpis odpovídající tomuto veřejnému klíči (a odpovídající
  soukromý klíč by se nikdy nedozvěděla).

  Rubin poznamenává, že má toto schéma oproti existujícím návrhům na kovenanty
  výhodu v tomu, že všechny operace (kromě ověření výsledného podpisu) se dějí
  offchain a žádná data (kromě veřejného klíče a podpisu) nemusí být publikována
  onchain. To vždy znamená více soukromí a méně zabraného prostoru. Jeden skript
  může obsahovat více kovenantových programů tím, že provede více ověření podpisů.

  Kromě potřeby důvěryhodné strany popisuje Rubin i další významnou nevýhodu
  funkcionálního šifrování jako „nevyvinutou kryptografii, která není v současnosti
  prakticky použitelná.”

- **Změny navrhovaného soft forku pro 64bitovou aritmetiku:** Chris Stewart zaslal
  do fóra Delving Bitcoin [příspěvek][stewart 64bit] oznamující aktualizaci jeho
  návrhu na přidání schopnosti pracovat v bitcoinovém Scriptu s 64bitovými čísly
  (viz zpravodaje [č. 285][news285 64bit] a [č. 290][news290 64bit]). Hlavním změnami
  jsou:

  - *Aktualizace stávajících opkódů:* namísto přidání nových opkódů jako
	`OP_ADD64` byly stávající opkódy (např. `OP_ADD`) aktualizovány, aby
	fungovaly s 64bitovými čísly. Jelikož se kódování velkých čísel od
	současného liší, budou muset být části skriptů, které mají nově velká
	čísla používat, revidovány. Stewart jako příklad uvádí `OP_CHECKLOCKTIMEVERIFY`,
	která by nově vyžadovala osmibajtový parametr namísto pětibajtového.

  - *Výsledek přidává booleovou hodnotu:* úspěšná operace nejen, že umístí do
	zásobníku výsledek, ale navíc přidá i boolevou hodnotu indikující, zda
	operace proběhla úspěšně. Častým důvodem selhání operace může být výsledek
	mající větší než 64 bitů, čímž by přetekla velikost pole. Kód může pro
	zajištění úspěšného dokončení použít `OP_VERIFY`.

  Anthony Towns ve své [reakci][towns 64bit] volal po alternativním přístupu, kde
  by opkódy v případě přetečení selhaly. Skripty by tak nemusely provádět
  nadbytečné ověření úspěšného provedení. Pro případy, kde by bylo testování
  přetečení výsledku užitečné, by mohly být zpřístupněny nové opkódy jako například
  `ADD_OF`.

- **Skript s `OP_CAT` validující proof of work:** Anthony Towns
  zaslal do fóra Delving Bitcoin [příspěvek][towns powcat] o [signetovém][topic
  signet] skriptu používajícím [OP_CAT][topic op_cat], který umožní komukoliv
  pomocí proof of work (PoW) utratit mince zaslané na tento skript. Může to být
  použito jako decentralizovaný zdroj pro signetové mince: má-li těžař
  nebo uživatel nepotřebné signetové mince, může je poslat na tento skript.
  Chce-li někdo získat více signetových mincí, může mezi UTXO nalézt platby
  na tento druh skriptu, vygenerovat PoW a vytvořit transakci, která tento
  PoW používá jako doklad nároku na mince.

  Townsův příspěvek popisuje zmíněný skript a důvody stojící za některými
  rozhodnutími.

- **Návrh změn BIP21:** Matt Corallo zaslal do emailové skupiny Bitcoin-Dev
  [příspěvek][corallo bip21] o aktualizaci specifikace [BIP21][] pro adresy
  ve tvaru `bitcoin:`. Jak bylo již dříve diskutováno (viz [zpravodaj č. 292][news292
  bip21]), téměř všechny bitcoinové peněženky používají tato schémata
  adres odlišně od specifikace. Další změny v používání BIP21 nejspíše
  přinesou budoucí úpravy fakturovacích protokolů. Mezi hlavní [navrhované][bips
  #1555] změny patří:

  - *Nejen base58check:* BIP21 očekává, že bude každá adresa kódována pomocí
	base58check, ale to se používá jen u zastaralých adres pro P2PKH a P2SH
	výstupy. Moderní výstupy používají [bech32][topic bech32] a bech32m. Budoucí
	platby budou přijímány na adresy [tichých plateb][topic silent payments]
	a protokol LN [nabídek][topic offers] – i tyto budou téměř jistě používány
	s BIP21.

  - *Prázdné tělo:* BIP21 v současnosti vyžaduje, aby byla v jeho těle poskytnuta
	bitcoinová adresa a další informace (např. částka) byly předány jako query
	parametry. Platební protokoly přicházející v minulosti, jako byl například
	[platební protokol BIP70][topic bip70 payment protocol], specifikovaly nové
	query parametry (viz [BIP72][]), avšak klient, který parametrům nerozuměl,
	mohl použít adresu z těla. V některých případech si ale příjemci nepřejí
	použít jako alternativu základní typ adresy (base58check, bech32 či bech32m),
	například uživatelé dbající o soukromí a používající tiché platby.
	Navrhovaná změna umožňuje, aby tělo BIP21 adresy bylo prázdné.

  - *Nové query parametry:* návrh popisuje tři nové klíče:
	`lightning` pro [BOLT11][] faktury (v současnosti používané), `lno` pro LN
	nabídky (návrh) a `sp` pro tiché platby (návrh).  Též popisuje, jak
	by měly být nazývány klíče budoucích parametrů.

  Corallo ve svém příspěvku poznamenává, že změny jsou bezpečné pro všechen
  známý používaný software, neboť peněženky, které neumí `bitcoin:` adresy
  úspěšně zpracovat, je ignorují či odmítají.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.05rc2][] je kandidátem na vydání příští hlavní verze této
  populární implementace LN uzlu.

- [Bitcoin Core 27.1rc1][] je kandidátem na vydání údržbové verze této převládající
  implementace plného uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Core Lightning #7252][] mění chování `lightningd`, aby během kooperativního zavírání
  kanálu ignoroval nastavení `ignore_fee_limits`. Odstraňuje tím problém, kdy CLN uzel,
  který otevře kanál s LDK, přeplácí na poplatcích. V tomto scénáři CLN uzel Bob otevřel
  kanál k LDK uzlu Alici. Když Alice zahájí kooperativní zavření kanálu a započne vyjednávání
  o poplatku, Bob kvůli `ignore_fee_limits` akceptuje cokoliv mezi `min_sats` a
  `max_channel_size`. LDK „vždy [vybere][ldk #1101] nejvyšší možnou částku” (v rozporu s BOLT
  specifikací), proto Bob zvolí horní hranici a Alice ji přijme, načež Alice transakci zveřejní
  s výrazným přeplatkem.

- [LDK #2931][] přidává do logování během hledání cest více dat o přímých kanálech, např. zda
  chybí či jaká je jejich minimální a maximální částka [HTLC][topic htlc]. Cílem je snazší
  hledání příčin chyb routování.

- [Rust Bitcoin #2644][] přidává do `bitcoin_hashes` HKDF, funkci pro derivování klíčů pomocí
  HMAC, která je potřebná pro implementaci [BIP324][]. HKDF se používá pro bezpečné standardní
  odvozování kryptografických klíčů z nějakého zdroje dat. BIP324 ([v2 P2P transport][topic v2
  p2p transport]) je způsob pro vzájemnou komunikaci uzlů šifrovaným spojením (v Bitcoin Core
  je ve výchozím nastavení aktivní).

- [BIPs #1541][] přidává [BIP431][] se specifikací do potvrzení topologicky omezených transakcí
  (Topologically Restricted Until Confirmation, [TRUC][topic v3 transaction relay], též v3 transakce),
  které jsou podmnožinou standardních transakcí s dodatečnými pravidly určenými k umožnění
  [nahrazování transakcí][topic rbf] a minimalizaci nákladů na obranu před [pinningovými][topic
  transaction pinning] útoky.

- [BIPs #1556][] přidává [BIP337][] se specifikací _komprimovaných transakcí_, serializačního
  protokolu pro kompresi bitcoinových transakcí, který sníží jejich velikost až o polovinu.
  Komprese je vhodná pro úzká přenosová pásma, jako je satelit, HAM rádio či steganografie.
  Navrženy jsou dva RPC příkazy: `compressrawtransaction` a `decompressrawtransaction`.
  [Zpravodaj č. 267][news267 bip337] obsahuje podrobnější vysvětlení.

- [BLIPs #32][] přidává [BLIP32][] popisující, jak mohou být navrhované čitelné bitcoinové platební
  instrukce založené na DNS (viz [zpravodaj č. 290][news290 omdns]) použité s [onion zprávami][topic onion
  messages] pro posílání plateb na adresy jako `bob@example.com`. Například Alice chce pomocí svého
  LN klienta zaplatit Bobovi. Její klient není schopen bezpečně přeložit DNS adresy přímo, ale může
  pomocí onion zprávy kontaktovat jednoho ze svých spojení inzerujících tuto službu. Spojení obdrží
  DNS TXT záznam pro položku `bob` v `example.com` a vrátí výsledek Alici spolu s [DNSSEC][] podpisem.
  Alice výsledek ověří a pomocí něj a protokolu [nabídek][topic offers] požádá Boba o fakturu.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}

## Poznámky

[^testnet-fixup]:
	Tento odstavec byl upraven po zveřejnění. [Korekci][murch correction] navrhl Mark „Murch”
	Erhardt, děkujeme.

{% include references.md %}
{% include linkers/issues.md v=2 issues="7252,2931,2644,1541,1556,32,1601,29775,1555,1101" %}
[rubin fe paper]: https://rubin.io/public/pdfs/fedcov.pdf
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news290 omdns]: /cs/newsletters/2024/02/21/#citelne-bitcoinove-platebni-instrukce-zalozene-na-dns
[dnssec]: https://cs.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[jahr testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a6e3VPsXJf9p3gt_FmNF_Up-wrFuNMKTN30-xCSDHBKXzXnSpVflIZIj2NQ8Wos4PhQCzI2mWEMvIms_FAEs7rQdL15MpC_Phmu_fnR9iTg=@protonmail.com/
[news297 testnet]: /cs/newsletters/2024/04/10/#diskuze-o-restartu-a-uprave-testnetu
[rubin fe post]: https://delvingbitcoin.org/t/fed-up-covenants/929
[functional encryption]: https://en.wikipedia.org/wiki/Functional_encryption
[stewart 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/49
[towns 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/50
[news285 64bit]: /cs/newsletters/2024/01/17/#navrh-na-soft-fork-pro-64bitovou-aritmetiku
[news290 64bit]: /cs/newsletters/2024/02/21/#pokracujici-diskuze-o-64bitove-aritmetice-a-opkodu-op-inout-amount
[towns powcat]: https://delvingbitcoin.org/t/proof-of-work-based-signet-faucet/937
[corallo bip21]: https://mailing-list.bitcoindevs.xyz/bitcoindev/93c14d4f-10f3-48af-9756-7e39d61ba3d4@mattcorallo.com/
[news292 bip21]: /cs/newsletters/2024/03/06/#aktualizace-bip21-pro-uri-typu-bitcoin
[irc disclose]: https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2024-06-06#1031717;
[disclosure policy]: https://gist.github.com/darosior/eb71638f20968f0dc896c4261a127be6
[Bitcoin Core 27.1rc1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news289 v3]: /cs/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /cs/newsletters/2024/04/03/#bitcoin-core-29242
[news305 v3]: /cs/newsletters/2024/05/31/#bitcoin-core-29873
[news267 bip337]: /cs/newsletters/2023/09/06/#komprimovane-bitcoinove-transakce
[murch correction]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1714#discussion_r1630230324
