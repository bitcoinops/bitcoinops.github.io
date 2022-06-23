---
title: 'Zpravodaj „Bitcoin Optech” č. 205'
permalink: /cs/newsletters/2022/06/22/
name: 2022-06-22-newsletter-cs
slug: 2022-06-22-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme návrh možnosti Bitcoin Core, která by
usnadnila nahrazování transakcí i bez BIP125 signalizace, odkazujeme
na informace o zranitelnosti Hertzbleed, shrnujeme závěr diskuze
o návrhu systémů pro timestamping a zkoumáme nový anti-sybil protokol
používající UTXO. Též nechybí naše pravidelné rubriky s popisem
nových zajímavých funkcí v bitcoinových klientech a službách,
oznámeními o nových vydáních a souhrnem významných změn v populárních
bitcoinových infrastrukturních projektech.

## Novinky

- **Plné replace by fee:** v Bitcoin Core byly otevřeny [dva][bitcoin core #25353]
  pull [requesty][bitcoin core #25373], které přidávají možnost plného Replace By Fee
  ([RBF][topic rbf]). Tato možnost je ve výchozím nastavení vypnuta. Pokud je
  aktivována, nepotvrzené transakce mohou být v mempoolu nahrazeny alternativní
  verzí, která platí vyšší poplatky (mimo jiná pravidla).

  V současnosti umožňuje Bitcoin Core RBF, má-li verze transakce, která má být
  nahrazena, aktivován signalizační bit podle [BIP125][]. To však přináší
  těžkosti systémům s kontrakty s více stranami jako LN nebo [DLCs][topic dlc],
  kde někdy může jedna strana odstranit BIP125 signál z transakce a tím
  zabránit druhé straně použít nahrazování transakcí. To může vést ke zpožděním
  a v nejhorších případech i ztrátě prostředků, pokud protokol závisí na včasném
  potvrzení (např. [HTLC][topic htlc]).

  [Jedno z PR][bitcoin core #25353] rychle obdrželo velkou podporu vývojářů,
  protože pouze přidává novou schopnost, ale ve výchozím nastavení ji neaktivuje;
  nemění tedy výchozí chování Bitcoin Core. V delším časovém horizontu budou
  zřejmě někteří vývojáři volat po aktivaci plného RBF i ve výchozím nastavení,
  proto tento týden [začala][rbf discussion] diskuze v emailové skupině Bitcoin-Dev,
  aby dala vývojářům služeb, aplikací a alternativních uzlů možnost vyjádřit
  se proti tomuto směřování.

- **Hertzbleed:** nedávno [odhalená][hertzbleed] bezpečnostní zranitelnost,
  která postihuje mnoho (možná všechny) populární laptopy, desktopy a
  serverové procesory, může pomoci útočníkům zjistit soukromé klíče,
  jsou-li používány pro podepisování bitcoinových transakcí (nebo pro
  podobné operace). Důležitým aspektem tohoto útoku je, že se může týkat
  kódu generujícího podpisy, který byl speciálně navržen, aby vždy
  používal stejný typ a počet CPU instrukcí (zabránění úniku
  informací).

  Zneužití této zranitelnost by vyžadovalo, aby mohl útočník měřit
  buď spotřebu energie procesoru nebo trvání operací podepisování.
  Pro útočníka by bylo nejlépe, kdyby mohl tato měření provést
  během mnoha podepisování stejným soukromým klíčem. Zranitelnost
  tedy může spíše postihnout často používané horké peněženky, např.
  ty používané hostovanými službami nebo routovacími LN uzly,
  a [znovupoužívání adres][topic output linking]. Peněženky, které
  jsou většinou nebo stále offline, by měly být vůči útokům mnohem
  odolnější.

  V době psaní tohoto článku není zcela zřejmé, nakolik bude tato
  zranitelnost postihovat uživatele bitcoinu. O mnoha současných
  peněženkách včetně několika populárních hardwarových podepisujících
  zařízení již dnes víme, že používají k podepisování kód zranitelný
  vůči analýzám spotřeby a časování; pro tyto uživatele se tedy
  snad nic nezmění. Je možné, že pro uživatele bezpečnějšího kódu
  přidají vývojáři nové formy ochrany. Máte-li otázky či obavy
  ohledně software, který používáte, kontaktujte prosím vývojáře
  relevantními komunikačními kanály (jako je např.
  [Bitcoin Stack Exchange][]).

- **Design timestampingu:** zdá se, že vleklá debata v emailové skupině
  Bitcoin-Dev o designu systému [Open Timestamps][] (OTS) postaveném na
  Bitcoinu dospěla tento týden ke svému [závěru][poelstra timestamping].
  Zdrojem debaty byla existence dvou rozdílných designů systémů pro
  vytváření časových značek („timestamping”):

    - *Důkaz existence časovou značkou (Time Stamped Proofs of Existence, TSPoE)*:
	  bitcoinová transakce se zavazuje k hashi, který se zavazuje k nějakému
	  dokumentu. Když je tato transakce potvrzena v bloku, může tvůrce
	  závazku („commitment”) dokázat třetí straně, že zmíněný dokument
	  existoval v čase vytvoření bloku. Všimněte si, že každá transakce
	  s časovou značkou je zcela nezávislá na jiné takové transakci.
	  Znamená to, že je možné vytvořit časovou značku stejného dokumentu
	  opakovaně bez jakéhokoliv spojení mezi nimi.

    - *Řazení událostí (Event Ordering, EO):* v série transakcí navzájem
	  spojených předepsaným způsobem se každá zavazuje k dokumentům tak,
	  že komukoliv umožňuje shlédnout všechny tyto závazky.
	  Je možné určit, kdy získal kterýkoliv z těchto dokumentů časovou
	  značku poprvé.

  Systém TSPoE, jak byl implementován v OTS, je v podstatě dokonale efektivní.
  Využívá stejné množství globálního prostoru k uložení časových značek
  neomezeného počtu dokumentů. Každý, kdo by chtěl vytvořit časovou
  značku je zodpovědný za uložení jejího důkazu. Tento systém je také
  výhodný svou jednoduchostí konceptu i implementace.

  Systém EO vyžaduje po všech řádných účastnících ukládat závazky
  ke všem dokumentům. To může být mnohem méně efektivní a přidává na složitosti.
  Na druhou stranu umožňuje účastníkům ověřit, kdy byl dokument v systému
  poprvé publikován.

  Diskuze nevedla k oznámení změn v žádném systému nebo návrhu, jako
  Open Timestamps nebo sponzorování transakcí (což bylo původní
  téma diskuze, viz [zpravodaj č. 116][news116 sponsorship], *angl.*).
  Několik účastníků diskuze bylo překvapeno, že každý má jinou představu,
  co se skrývá pod pojmem „timestamping.”

- **RIDDLE – nový systém proti sybil útokům:** Adam „Waxwing” Gibson
  poslal do emailové skupiny Bitcoin-Dev [příspěvek][gibson riddle post]
  s [návrhem][gibson riddle gist] mechanismu proti [sybil útokům][sybil],
  který používá množinu UTXO a který v rozumné míře zachovává soukromí.
  Uživatel může vygenerovat seznam UTXO, z nichž jeden UTXO patří jemu a
  zbytek jiným uživatelům. Uživatel pak vytvoří podpis, který prokazatelně
  pochází od vlastníka jednoho z vyjmenovaných UTXO, ale kdo přesně je
  jeho vlastníkem, zůstává skryto.

  Záškodník by mohl vygenerovat mnoho takových důkazů, ale byl by jich
  pouze konečný počet, než by vyčerpal množinu všech možností; jeho schopnost
  nadměrně spotřebovávat vzácné síťové zdroje je tak omezena. Záškodník
  by také mohl používat UTXO tak dlouho, jak by to bylo možné, a pak jej
  utratit, aby získal nové UTXO, ale toto by si vyžádalo transakční poplatek.
  Tato nákladnost by také omezovala zneužívání. Služby by dále mohly
  určovat, které UTXO by si mohl uživatel zvolit. Například nějaká
  služba by mohla akceptovat pouze UTXO s více než 1 BTC, který nebyl
  utracen více než rok.

  Gibson navrhuje, aby důkazy členství přicházely ve dvou formách:
  globální a lokální důkazy. Globální důkazy by byly sdíleny mezi
  ověřovateli tak, že za ideálních podmínek by uživatel mohl vytvořit
  pouze jediný důkaz na každý UTXO. Například by si mohl vytvořit
  jen jediný účet na svůj rok starý UTXO s 1 BTC.

  Lokální důkazy by byly specifické jednomu ověřovateli (nebo skupině,
  např. v případě decentralizované směnárny). Například by uživatel mohl použít
  UTXO k přístup k API služby A a poté použít to stejné UTXO i pro službu B.

  UTXO s vysokou hodnotou by také mohly být považovány za vícero UTXO
  s nižšími hodnotami, takže 10BTC UTXO by mohl umožnit uživatelovi
  vytvořit 10 různých účtů u různých služeb, z nichž každá požaduje
  1 BTC kapitálu v globálním kontextu.

  I když protokol RIDDLE nabízí oproti jiným mechanismům výhody zachování
  soukromí, Gibson varuje, že informace z používání systému by mohla být
  zkombinována s jinými dostupnými informacemi za účelem redukce soukromí
  uživatelů. Píše, že „není možné, aby takový systém nabídl neprůstřelné
  garance soukromí. Je-li ochrana identifikace podepisujícího UTXO otázkou
  života a smrti, za žádných okolností nepoužívejte takový systém.”

  Vývojář ZmnSCPxj v emailové skupině Lightning-Dev [navrhl][zmnscpxj riddle],
  že by RIDDLE mohl být volbou pro oddělení antisybilového mechanismu v LN
  od identifikátorů kanálů založených na UTXO, které v době [taprootu][topic
  taproot] a [agregace podpisů][topic musig] zbytečně odhalují, které
  transakce otevírají a zavírají LN kanály.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Zeus přidává podporu pro taproot:**
  [Zeus v0.6.5-rc1][] přidává podporu [taproot][topic taproot] pro posílání a přijímání
  s LND v0.15+ backendy.

- **Vydána Wasabi Wallet 2.0:**
  Toto [vydání][wasabi 2.0] software pro [coinjoin][topic coinjoin] implementuje mimo
  jiná vylepšení [WabiSabi protokol][news194 wabisabi].

- **Sparrow přidává podporu hardware pro taproot podepisování:**
  Upgradem na [HWI 2.1.0][] přidává Sparrow [1.6.4][sparrow 1.6.4] některým hardwarovým
  podepisujícím zařízením podporu pro taproot.

## Vydání nových verzí

*Vydání nových verzí populárních bitcoinových infrastrukturních projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.15.0-beta.rc6][] je kandidátem na vydání příští verze tohoto oblíbeného LN uzlu.

- [LDK 0.0.108][] a 0.0.107 jsou vydání, která přidávají podporu pro [velké kanály][topic
  large channels] a [zero-conf kanály][topic zero-conf channels]. Dále nabízí mobilním klientům
  možnost obdržet informace o routování (*gossip protokol*) ze serveru a několik nových
  funkcí a oprav.

- [BDK 0.19.0][] přidává experimentální podporu pro [taproot][topic taproot]
  v [deskriptorech][topic descriptors], [PSBT][topic psbt] a dalších subsystémech.
  Také přidává nový [algoritmus výběru mincí][topic coin selection].

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core GUI #602][] zapisuje nastavení změněná v GUI do souboru,
  který je načítán také negrafickým démonem (`bitcoind`). Změněná nastavení
  jsou tady používána bez ohledu, jak uživatel startuje Bitcoin Core.

- [Eclair #2224][] přidává podporu pro aliasy krátkých identifikátorů kanálů
  (Short Channel Identifier, SCID) a pro typ [zero-conf kanálů][topic zero-conf channels].
  Aliasy SCID mohou zvýšit soukromí a také umožnit uzlům odkazovat se na kanály
  před tím, než jsou dostatečně potvrzené. Zero-conf kanály umožňují dvěma uzlům
  dohodnout se na používání kanálu před tím, než je dostatečně potvrzen, což může
  být za jistých okolností bezpečné.

- [HWI #611][] přidává podporu jednoduchých podpisů pro [bech32m adresy][topic
  bech32] pro hardwarové podepisující zařízení BitBox02.

{% include references.md %}
{% include linkers/issues.md v=2 issues="602,2224,611,25353,25373" %}
[lnd 0.15.0-beta.rc6]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc6
[ldk 0.0.108]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.108
[bdk 0.19.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.19.0
[rbf discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020557.html
[hertzbleed]: https://www.hertzbleed.com/
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[poelstra timestamping]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020569.html
[gibson riddle post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020555.html
[gibson riddle gist]: https://gist.github.com/AdamISZ/51349418be08be22aa2b4b469e3be92f
[bitcoin stack exchange]: https://bitcoin.stackexchange.com/
[open timestamps]: https://opentimestamps.org/
[sybil]: https://en.wikipedia.org/wiki/Sybil_attack
[zmnscpxj riddle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003607.html
[Zeus v0.6.5-rc1]: https://github.com/ZeusLN/zeus/releases/tag/v0.6.5-rc1
[wasabi 2.0]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.0.0
[news194 wabisabi]: /en/newsletters/2022/04/06/#wabisabi-alternative-to-payjoin
[HWI 2.1.0]: /en/newsletters/2022/03/23/#hwi-2-1-0-rc-1
[sparrow 1.6.4]: https://github.com/sparrowwallet/sparrow/releases/tag/1.6.4
