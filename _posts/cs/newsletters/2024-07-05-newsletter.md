---
title: 'Zpravodaj „Bitcoin Optech” č. 310'
permalink: /cs/newsletters/2024/07/05/
name: 2024-07-05-newsletter-cs
slug: 2024-07-05-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje odhalení deseti zranitelností postihujících
staré verze Bitcoin Core a popisuje návrh na možnost přidání zaslepené cesty
do BOLT11 faktury. Též nechybí naše pravidelné rubriky s oznámeními nových
vydání a souhrnem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Odhalení zranitelností postihujících Bitcoin Core verze před 0.21.0:**
  Antoine Poinsot zaslal do emailové skupiny Bitcoin-Dev [příspěvek][poinsot
  disclose] s odkazem na [odhalení][bcco announce] deseti zranitelností
  postihujících verze Bitcoin Core, které jsou téměř dva roky za ukončením
  životního cyklu. Níže přinášíme jejich souhrn:

  - [Vzdálené spuštění kódu kvůli chybě v miniupnpc][Remote code execution due to bug in miniupnpc]:
	před Bitcoin Core 0.11.1 (vydaným v říjnu 2015) měly uzly ve výchozím nastavení
	aktivní [UPnP][], aby mohly přijímat spojení přes [NAT][]. Bylo toho dosaženo
	použitím [knihovny miniupnpc][miniupnpc library], ve které objevil Aleksandar Nikolic
	zranitelnosti vůči několika vzdáleným útokům ([CVE-2015-6031][]). Zranitelnosti byly
	v knihovně opravené a oprava byla začleněna do Bitcoin Core. Dále bylo UPnP
	ve výchozím nastavení deaktivováno. Během zkoumání chyby objevil vývojář
	Wladimir J. Van Der Laan další zranitelnost vůči vzdálenému spuštění kódu
	ve stejné knihovně. Zranitelnost byla [zodpovědně nahlášena][topic responsible disclosures],
	opravena v knihovně a oprava začleněna do Bitcoin Core 0.12 (vydáno v únoru 2016).

  - [Pád způsobený velkými zprávami od více spojení][Node crash DoS from multiple peers with large messages]:
	před Bitcoin Core 0.10.1 akceptovaly uzly P2P zprávy až do velikosti 32 megabajtů.
	Uzly dále ve výchozím nastavení umožňovaly až kolem 130 spojení. Pokud každé ze spojení
	poslalo ve stejný okamžik největší možnou zprávu, alokoval by uzel kolem 4 gigabajtů
	paměti (nad rámec běžného paměťového prostoru), což bylo více, než kolik mělo
	mnoho uzlů k dispozici. Zranitelnost byla zodpovědně nahlášena uživatelem Evil-Knievel na
	fóru BitcoinTalk.org, bylo jí přiřazeno [CVE-2015-3641][] a opravena byla v Bitcoin Core
	0.10.1 omezením maximální velikosti	zprávy na 2 megabajty (což bylo pro segwit později
	navýšeno na 4 megabajty).

  - [Cenzurování nepotvrzených transakcí][Censorship of unconfirmed transactions]:
	nové transakce jsou obvykle oznamovány spojeními, které uzlu pošlou txid
	nebo wtxid. Když uzel spatří txid či wtxid poprvé, požádá o kompletní transakci
	první spojení, které ji oznámilo. Během čekání na transakci si uzel zapamatuje,
	která další spojení ohlásí stejné txid či wtxid. Pokud první spojení před vypršením
	časového limitu transakci nepošle, požádá uzel druhé spojení (a pak třetí atd.).

	Před Bitcoin Core 0.21.0 si dokázal uzel zapamatovat pouze 50 000 požadavků.
	To umožnilo prvnímu spojení, aby po oznámení txid pozdrželo svou odpověď
	na požadavek na plnou transakci, počkalo, až všechny ostatní spojení uzlu transakci
	oznámí a na to poslalo 50 000 oznámení dalších txid (nejspíše všech falešných).
	Když původnímu požadavku prvnímu spojení vypršel časový limit, uzel už se dalších
	spojení neptal. Útočník (první spojení) mohl tento útok opakovat donekonečna a tím
	natrvalo zabránit uzlu transakci získat. Cenzurování nepotvrzených transakcí
	může zabránit řádné konfirmaci transakce, což může vést v případě kontraktových
	protokolů jako LN ke ztrátě prostředků. John Newbery se spoluautorem Amiti
	Uttarwarem zranitelnost zodpovědně nahlásil. Oprava byla součástí vydání
	Bitcoin Core 0.21.0.

  - [Neomezený seznam zakázaných IP adres vedoucí k DoS][Unbound ban list CPU/memory DoS]:
	do Bitcoin Core byl v [PR #15617][bitcoin Core #15617] (prvně obsaženo ve verzi 0.19.0)
	přidán kód, který až 2500krát zkontroloval každou IP adresu zakázanou místním uzlem,
	kdykoliv uzel obdržel P2P zprávu `getaddr`. Velikost seznamu zakázaných adres
	nebyla omezená a mohl narůst do velkých rozměrů, pokud měl útočník k dispozici
	velký počet IP adres (například IPv6 adres). V případě, kdy tento seznam obsahoval
	velké množství položek, spotřebovalo vyřízení každé `getaddr` zprávy nadměrné množství
	procesoru a paměti, což mohlo vést k nepoužitelnému uzlu či k pádu. Zranitelnosti
	bylo přiřazeno [CVE-2020-14198][], byla odstraněna v Bitcoin Core 0.20.1.

  - [Štěpení sítě kvůli přílišnému časovému rozdílu][Netsplit from excessive time adjustment]:
	starší verze Bitcoin Core umožňovaly, aby byl jejich čas upraven průměrem časů
	reportovaných prvními 200 spojeními. Dle kódu bylo možné se odchýlit maximálně
	o 70 minut. Všechny verze Bitcoin Core dále dočasně ignorují všechny bloky, jejichž
	časová razítka jsou více než dvě hodiny v budoucnosti. Kombinace dvou chyb
	umožňovala, aby útočník obětem způsobil odchýlení hodin o více než dvě hodiny
	do minulosti, kvůli čemuž mohly být ignorovány bloky s přesnými časovými razítky.
	Zranitelnost zodpovědně nahlásil vývojář practicalswift, opravena byla
	v Bitcoin Core 0.21.0.

  - [CPU DoS a zaseklý uzel kvůli zpracování sirotků][CPU DoS and node stalling from orphan handling]:
	uzel Bitcoin Core udržuje v mezipaměti až 100 transakcí nazývaných
	_osiřelé transakce_ (sirotci), jejichž rodičovské transakce nemá uzel
	ani v mempoolu, ani v množině UTXO. Po validaci nově příchozí transakce uzel
	zkontroluje, zda již může být některý ze sirotků zpracován. Před Bitcoin Core
	verzí 0.18.0 se uzel během každé kontroly mezipaměti sirotků pokoušel validovat
	všechny osiřelé transakce oproti aktuálnímu mempoolu a stavu UTXO.
	Pokud bylo všech 100 sirotků v mezipaměti zkonstruováno tak, že vyžadovaly
	k validaci nadměrné množství procesoru, uzel plýtval procesorovým časem
	a nebyl schopen zpracovávat nové bloky a transakce po dobu několika hodin.
	Tento útok bylo možné provést v podstatě zdarma: osiřelé transakce lze vytvořit
	zdarma, protože mohou odkazovat na neexistující rodičovské transakce.
	Zaseklý uzel nebyl schopen generovat šablony bloků a tím mohl bránit
	těžařovi ve vydělávání. Též mohl bránit konfirmaci transakcí, což u
	kontraktových protokolů typu LN mohlo znamenat ztrátu peněz. Vývojář sec.eine
	zranitelnost zodpovědně nahlásil, opravena byla v Bitcoin Core 0.18.0.

  - [DoS způsobený velkými `inv` zprávami][Memory DoS from large `inv` messages]:
	P2P zpráva `inv` může obsahovat seznam až 50 000 hašů hlaviček bloků. Novější
	uzly Bitcoin Core před verzí 0.20.0 na tuto zprávu odpovídaly P2P zprávou
	`getheaders` pro každý neznámý haš zvlášť. Velikost každé zprávy byla kolem
	jednoho kilobajtu, uzel tedy v paměti držel kolem 50 megabajtů zpráv na spojení.
	Každé spojení (ve výchozím nastavení až kolem 130) mohlo provést totéž, což si
	vyžádalo nad rámec běžného provozu až 6,5 gigabajtů paměti, dostatečné množství
	na způsobení pádu mnoha uzlů. Postižené uzly nemusely včas zpracovat transakce
	kontraktových protokolů, což vedlo ke ztrátě peněz. John Newbery zranitelnost
	zodpovědně nahlásil a poskytl opravu, po které uzel na libovolné množství hašů
	ve zprávě `inv` odpověděl jedinou zprávou `getheaders`. Oprava byla začleněna
	do Bitcoin Core 0.20.0.

  - [DoS kvůli hlavičkám s nízkou obtížností][Memory DoS using low-difficulty headers]:
	od Bitcoin Core verze 0.10 požaduje uzel po každém svém spojení, aby mu zaslalo
	hlavičky bloků ze svého _nejlepšího blockchainu_ (tj. validního blockchainu
	s největším proof of work). Známým problémem tohoto přístupu je, že by mohlo
	záškodnické spojení zaplavit uzel velkým množstvím falešných hlaviček patřících
	blokům s nízkou obtížností (např. difficulty-1), které je snadné na moderním ASIC
	zařízení vytvořit. Bitcoin Core původně tento problém řešil tím, že akceptoval
	pouze hlavičky v řetězci, který odpovídal _checkpointům_ napevno zakódovaným
	v Bitcoin Core. Poslední checkpoint, ač z roku 2014, má dle současného standardu
	středně vysokou obtížnost; vytvářet nad ním falešné hlavičky by vyžadovalo
	významné množství úsilí. Avšak jedna změna kódu začleněná do Bitcoin Core 0.12
	umožňovala, aby uzel začal do paměti akceptovat hlavičky s nízkou obtížností,
	což útočníkovi umožňovalo zaplnit paměť falešnými hlavičkami. To mohlo vést
	až k pádu uzlu a ke ztrátě peněz uživatelů kontraktových protokolů (např. LN).
	Cory Fields zranitelnost zodpovědně nahlásil, opravena byla ve verzi 0.15.0.

  - [DoS plýtvající CPU kvůli znetvořenému požadavku][CPU-wasting DoS due to malformed requests]:
	před Bitcoin Core 0.20.0 mohl útočník nebo chybně fungující spojení poslat
	deformovanou P2P zprávu `getdata`, kvůli které spotřebovávalo vlákno zpracovávající
	zprávy 100 % procesoru. Uzel nato nebyl schopen po dobu trvání spojení přijímat
	od útočníka žádné další zprávy, ač byl i nadále schopen přijímat
	zprávy od čestných spojení. To přinášelo problémy uzlům běžícím s nízkým počtem
	procesorových jader, avšak jinak se jednalo pouze o nepříjemnost. John
	Newbery zranitelnost zodpovědně nahlásil a poskytl opravu, která byla
	začleněna do Bitcoin Core 0.20.0.

  - [Pád kvůli paměti při pokusu dekódovat BIP72 adresy][Memory-related crash in attempts to parse BIP72 URIs]:
	Bitcoin Core před verzí 0.20.0 podporoval [BIP70 platební protokol][topic bip70
	payment protocol], který rozšiřoval [BIP21][] URI typu `bitcoin:` o parametr
	`r` obsahující HTTP(S) URL a definovaný v [BIP72][]. Bitcoin Core
	se pokusil stáhnout soubor na adrese a uložit jej v paměti pro další
	zpracování. Pokud však byl soubor větší než dostupná paměť, byl Bitcoin Core
	časem ukončen. Jelikož se pokus o stažení udával na pozadí, mohl uživatel
	před pádem od uzlu odejít, aniž by si pádu všiml a měl možnost rychle restartovat
	potenciálně důležitou službu. Zranitelnost zodpovědně nahlásil Michael Ford
	a odstraněním podpory BIPu 70 ji v Bitcoin Core 0.20.0 opravil (viz [zpravodaj č.
	70][news70 bip70], _angl._).

  Poinsot dále oznámil, že později tento měsíc budou zveřejněné další zranitelnosti
  opravené v Bitcoin Core 22.0 a o další měsíc později totéž s Bitcoin Core 23.0.
  Zranitelnosti opravené v pozdějších verzích budou odhaleny dle [nových pravidel][new
  disclosure policy] Bitcoin Core (viz [zpravodaj č. 306][news306 disclosure]
  informující o relevantní diskuzi).

- **Přidání pole pro zaslepené cesty do BOLT11 faktur:** Elle Mouton
  zaslala do fóra Delving Bitcoin [příspěvek][mouton b11b] s návrhem BLIP specifikace
  volitelného pole, které by mohlo být přidáno do [BOLT11][] faktur, aby
  stanovilo [zaslepenou cestu][topic rv routing] pro platbu. Kupříkladu
  obchodník Bob chce od zákaznice Alice obdržet platbu, ale nechce sdělit identitu
  svého uzlu ani svých spojení, se kterými sdílí kanály. Vygeneruje zaslepenou cestu
  začínající pár skoků před svým uzlem a přidá ji do jinak standardní BOLT11 faktury,
  kterou následně předá Alici. Pokud Alicin software umí fakturu dekódovat a platbu
  nasměrovat, může Bobovi zaplatit. Pokud její software tento BLIP nepodporuje,
  nebude schopna fakturu uhradit a obdrží chybovou hlášku.

  Mutton v BLIPu poznamenává, že zaslepené cesty se mají v BOLT11 používat jen,
  dokud nebude široce nasazen protokol [nabídek][topic offers], jelikož ten
  zaslepené cesty nativně používá a nabízí oproti BOLT11 fakturám i další výhody.

  Bastien Teinturier [se vyslovil][teinturier b11b] proti tomuto nápadu i proti
  související myšlence na zpřístupňování faktur nabídek uživatelům. Raději by
  upřednostnil zaměřit se na úplné nasazení nabídek, neboť věří, že by tím systém
  dospěl do konečného stavu rychleji a nebylo by potřeba na neurčitou dobu podporovat
  různé mezistavy. Věří, že by uživatelé, kteří při pokusu zaplatit BOLT11 faktury
  se zaslepenými cestami obdrží chybové hlášky, požadovali po vývojářích přidat
  pro tuto schopnost podporu, čímž by je rušili od práce na nabídkách.

  Olaoluwa Osuntokun [odpověděl][osuntokun b11b], že by raději pracoval na zaslepených
  cestách odděleně od dalších závislostí na nabídkách, aby fungovaly co nejlépe.
  Představuje si, že by mohly být BOLT11 faktury se zaslepenými cestami používány
  v protokolech jako [L402][], kde klienti se servery již přímo komunikují.
  Nabízejí uživatelům mnoho výhodných vlastností nabídek, potřebovaly by tak
  jen tento drobný upgrade a mohly by používat zaslepené cesty za zachování
  stejného stupně soukromí, jako poskytují nabídky.

  V době psaní zpravodaje nebylo zřejmé, zda diskuze skončila. BLIPy jsou volitelné
  specifikace. Z diskuze se zdálo, že by tento BLIP mohl být implementován
  v LND, ale nikoliv v Eclair nebo lightning-kmp (základ peněženky Phoenix).
  Plány pro jiné implementace nebyly diskutovány.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.2rc1][] je kandidátem na vydání údržbové verze starší série
  Bitcoin Core.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #28167][] přidává do příkazu `bitcoind` novou volbu `-rpccookieperms`,
  která uživateli umožní nastavit práva pro čtení autentizačního souboru s cookie.
  Na výběr je možnost zpřístupnění vlastníkovi (výchozí nastavení), skupině nebo všem
  uživatelům.

- [Bitcoin Core #30007][] přidává do `chainparams` DNS seeder Avy Chow (achow101).
  Poskytne tím další důvěryhodný zdroj pro hledání uzlů. Její seeder používá
  [Dnsseedrs][dnsseedrs], nový open source bitcoinový DNS seeder napsaný v Rustu,
  který hledá adresy uzlů v sítích IPv4, IPv6, Tor v3, I2P a CJDNS.

- [Bitcoin Core #30200][] přináší nové rozhraní `Mining`. Existující RPC příkazy pro těžbu
  (např. `getblocktemplate` či `generateblock`) jej začnou používat okamžitě. V budoucnu
  bude toto rozhraní používat také [Stratum V2][topic pooled mining], které bude Bitcoin
  Core používat jako poskytovatele šablon.

- [Core Lightning #7342][] opravuje řešení situace během spouštění, při které byla
  služba ukončena, pokud `bitcoind` snížil výšku bloku (např. kvůli reorganizaci).
  Nově bude čekat, až výška bloku dosáhne předchozí úrovně, a začnou se tak
  skenovat nově obdržené (reorganizované) bloky.

- [LND #8796][] snižuje požadavky na parametry otevírání kanálu tím, že nově
  umožní iniciovat kanály, které nejsou [zero-conf][topic zero-conf channels],
  s `min_depth` nastaveným na nulu. LND ale i tak počká na přinejmenším jednu
  konfirmaci, než začne kanál používat. Tato změna přináší soulad se specifikací
  [BOLT2][] a zlepšuje spolupráci s ostatními lightningovými implementacemi jako LDK.

- [LDK #3125][] přináší podporu pro kódování a dekódování zpráv `HeldHtlcAvailable`
  a `ReleaseHeldHtlc`, které budou potřebné pro nadcházející implementaci protokolu
  [asynchronních plateb][topic async payments]. Dále přidává do těchto zpráv data
  [onion zpráv][topic onion messages] a do `OnionMessenger`u trait `AsyncPaymentsMessageHandler`.

- [BIPs #1610][] přidává [BIP379][BIP379 md] se specifikací [Miniscriptu][topic miniscript],
  jazyka, který se kompiluje do bitcoinového Scriptu, který ale umožňuje kompozici,
  šablony a konečnou analýzu. [Zpravodaj č. 304][news304 miniscript] již dříve tento
  BIP zmínil.

- [BIPs #1540][] přidává BIPy [328][bip328], [390][bip390] a [373][bip373] se specifikacemi
  komponent [MuSig2][topic musig]: schématu derivace pro agregované klíče (328), [deskriptorů][topic
  descriptors] výstupních skriptů (390) a nových [PSBT][topic psbt] polí pro MuSig2 data (373).
  MuSig2 je protokol pro agregování veřejných klíčů a [Schnorrových podpisů][topic schnorr signatures],
  který vyžaduje pouze dvě kola komunikace (MuSig1 vyžaduje tři), díky čemuž se výrazně
  neliší od multisig schémat založených na skriptech. Schéma derivace umožňuje z MuSig2 agregovaných
  veřejných klíčů (dle [BIP327][]) konstruovat rozšířené veřejné klíče ve stylu [BIP32][topic bip32].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28167,30007,30200,7342,8796,3125,1610,1540,15617" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[mouton b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991
[teinturier b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/5
[osuntokun b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/6
[l402]: https://github.com/lightninglabs/L402
[dnsseedrs]: https://github.com/achow101/dnsseedrs
[news304 miniscript]: /cs/newsletters/2024/05/24/#navrh-bipu-pro-miniscript
[remote code execution due to bug in miniupnpc]: https://bitcoincore.org/en/2024/07/03/disclose_upnp_rce/
[cve-2015-6031]: https://nvd.nist.gov/vuln/detail/CVE-2015-6031
[node crash dos from multiple peers with large messages]: https://bitcoincore.org/en/2024/07/03/disclose_receive_buffer_oom/
[censorship of unconfirmed transactions]: https://bitcoincore.org/en/2024/07/03/disclose_already_asked_for/
[unbound ban list cpu/memory dos]: https://bitcoincore.org/en/2024/07/03/disclose-unbounded-banlist/
[netsplit from excessive time adjustment]: https://bitcoincore.org/en/2024/07/03/disclose-timestamp-overflow/
[cpu dos and node stalling from orphan handling]: https://bitcoincore.org/en/2024/07/03/disclose-orphan-dos/
[memory dos from large `inv` messages]: https://bitcoincore.org/en/2024/07/03/disclose-inv-buffer-blowup/
[memory dos using low-difficulty headers]: https://bitcoincore.org/en/2024/07/03/disclose-header-spam/
[cpu-wasting dos due to malformed requests]: https://bitcoincore.org/en/2024/07/03/disclose-getdata-cpu/
[news70 bip70]: /en/newsletters/2019/10/30/#bitcoin-core-17165
[memory-related crash in attempts to parse BIP72 URIs]: https://bitcoincore.org/en/2024/07/03/disclose-bip70-crash/
[cve-2020-14198]: https://nvd.nist.gov/vuln/detail/CVE-2020-14198
[news306 disclosure]: /cs/newsletters/2024/06/07/#nadchazejici-odhaleni-zranitelnosti-postihujicich-stare-verze-bitcoin-core
[upnp]: https://cs.wikipedia.org/wiki/Universal_Plug_and_Play
[nat]: https://cs.wikipedia.org/wiki/Network_address_translation
[miniupnpc library]: https://miniupnp.tuxfamily.org/
[poinsot disclose]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xsylfaVvODFtrvkaPyXh0mIc64DWMCchxiVdTApFqJ_0Q5v0bOoDpS_36HwDKmzdDO9U2RKMzESEiVaq47FTamegi2kCNtVZeDAjSR4G7Ic=@protonmail.com/
[bcco announce]: https://bitcoincore.org/en/security-advisories/
[new disclosure policy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/rALfxJ5b5hyubGwdVW3F4jtugxnXRvc-tjD_qwW7z73rd5j7lXGNdEHWikmSdmNG3vkSOIwEryZzOZr_DgmVDDmt9qsX0gpRAcpY9CfwSk4=@protonmail.com/T/#u
[CVE-2015-3641]: https://nvd.nist.gov/vuln/detail/CVE-2015-3641
[BIP379 md]: https://github.com/bitcoin/bips/blob/master/bip-0379.md
