---
title: 'Zpravodaj „Bitcoin Optech” č. 237'
permalink: /cs/newsletters/2023/02/08/
name: 2023-02-08-newsletter-cs
slug: 2023-02-08-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze o ukládání dat ve witnessech
transakcí a poukazujeme na hovor o opatřeních proti zahlcování LN.
Též nechybí naše pravidelné rubriky se souhrnem sezení Bitcoin Core
PR Review Club a popisem významných změn v oblíbených bitcoinových
páteřních projektech.

## Novinky

- **Diskuze o ukládání dat v blockchainu:** uživatelé nového projektu nedávno
  začali ukládat velké množství dat ve witnessech transakcí obsahujících segwit
  vstupy verze 1 ([taproot][topic taproot]). Robert Dickinson [zaslal][dickinson
  ordinal] do emailové skupiny Bitcoin-Dev dotaz, zda by měl být zaveden
  velikostní limit, aby odradil od podobného ukládání dat.

  Andrew Poelstra [odpověděl][poelstra ordinal], že neexistuje žádný účinný
  způsob, který by ukládání dat zabránil. Přidání nových omezení za účelem
  zabránění ukládání nechtěných dat ve witnessech by podlomilo přednosti
  designu taprootu (viz [zpravodaj č. 65][news65 tapscript], *angl.*)
  a pravděpodobně by vyústilo v ukládání dat jinými způsoby. Tyto způsoby
  by mohly zvýšit náklady těm, kteří data generují, ale pravděpodobně ne
  dostatečně na to, aby je ve velké míře od tohoto chování odradily.
  Alternativní metody ukládání dat by také mohly vytvořit nové problémy
  běžným uživatelům bitcoinu.

  V době psaní stále probíhala o tomto tématu živá debata. Příští týden
  poskytneme ve zpravodaji aktualizaci.

- **Souhrn hovoru o opatřeních proti zahlcování LN:** Carla Kirk-Cohen a
  Clara Shikhelman [zaslaly][ckccs jamming] do emailové skupiny Lightning-Dev
  souhrn nedávného videohovoru o snahách adresovat [útoky zahlcením kanálu][topic
  channel jamming attacks]. Mezi probraná témata patří kompromisy během
  upgradu, jednoduchý návrh na předplácení podle nedávného článku (viz
  [zpravodaj č. 226][news226 jam], *angl.*), software CircuitBreaker
  (viz [zpravodaj č. 230][news230 jam]), aktualizace osvědčení o
  reputaci (viz [zpravodaj č. 228][news228 jam]) a související pokrok
  pracovní skupiny pro specifikaci poskytovatelů lightningových služeb (LSP).
  Pro více podrobností a [transkript][jam xs] viz zmíněný příspěvek do
  emailové skupiny.

  Budoucí videohovory jsou plánovány na každé dva týdny. Sledujte
  emailovou skupinu Lightning-Dev, kde budou setkání oznámena.

## Bitcoin Core PR Review Club

[Nechť AddrMan sleduje celkové hodnoty podle sítě a tabulky, zlepšení
přesnosti přidávání fixních seedů][review club 26847] je PR od Martina
Zumsandeho a jeho spoluautora Amitiho Uttarwara, které klientovi Bitcoin
Core umožňuje v určitých situacích spolehlivěji nalézt odchozí spojení.
Činí tak rozšířením komponenty `AddrMan` (správce adres spojení)
sledováním počtu adres podle sítě a typu („vyzkoušená" vs. „nová”), což
v důsledku vylepšuje použití fixních seedů. Tato změna je prvním krokem
v dlouhé cestě za vylepšením výběru odchozích spojení.

{% include functions/details-list.md
  q0="Kdy se síť považuje za dosažitelnou?"
  a0="Síť se považuje za dosažitelnou, dokud si nejsme jisti, že k ní
      nemáme žádný přístup, či dokud naše konfigurace nespecifikuje
      jednu či více _jiných_ sítí pomocí parametru `-onlynet` (poté
      se považují za dosažitelné pouze tyto sítě, i když jsou ve
      skutečnosti dostupné i sítě jiné)."
  a0link="https://bitcoincore.reviews/26847#l-22"

  q1="Jak je nakládáno s adresou obdrženou přes P2P v závislosti
      na tom, je-li síť dosažitelná či nedosažitelná? Ukládáme ji
      (přidáním do `AddrMan`) a/nebo ji přeposíláme dalším spojením?"
  a1="Je-li síť na adrese dosažitelná, přepošleme adresu dvěma
      náhodně vybraným spojením, jinak ji přepošleme jednomu či
      dvěma spojením (jestli jednomu nebo dvěma zvolíme náhodně).
      Ukládáme adresy pouze dosažitelných sítí."
  a1link="https://bitcoincore.reviews/26847#l-51"

  q2="Jak se v současnosti může přihodit, že se uzel zasekne, protože má
      v `AddrMan` pouze nedosažitelné adresy, a tedy nemůže nalézt žádné
      odchozí spojení? Nabízí toto PR řešení?"
  a2="Změnou volby `-onlynet`. Předpokládejme například, že byl uzel
      neustále provozován s volbou `-onlynet=onion`, a tedy nemá žádné I2P
      adresy. Poté je uzel restartován s volbou `-onlynet=i2p`. Fixní
      seedy mají nějaké I2P adresy, avšak před tímto PR je uzel nepoužil,
      neboť `AddrMan` nebyl _zcela_ prázdný (obsahoval nějaké onion
      adresy). S tímto PR je během spouštění několik I2P fixních seedů
      přidáno, jelikož `AddrMan` neobsahuje žádné adresy _tohoto_ typu sítě."
  a2link="https://bitcoincore.reviews/26847#l-98"

  q3="Co se děje s adresou během přidávání do `AddrMan`, pokud
      koliduje s adresou již existující? Je existující adresa vždy nahrazena
      novou?"
  a3="Ne, obecně je uchována pouze existující adresa (a nikoliv adresa nová),
      pokud se však existující adresa nepovažuje za „příšernou” (viz metoda
      `AddrInfo::IsTerrible()`)."
  a3link="https://bitcoincore.reviews/26847#l-100"

  q4="Proč je výhodné být neustále připojen ke každé dostupné síti?"
  a4="Sobeckým důvodem je, že je tak těžší vystavit uzel [útoku zastínením][topic
      eclipse attacks] („eclipse attack”), jelikož by útočník musel provozovat
      uzly na více sítích. Nesobeckým důvodem je, že to pomáhá udržovat
      celou síť propojenou, což pomáhá vyvarovat se štěpení blockchainu
      v důsledku dělení sítě. Pokud by polovina uzlů (včetně těžařů)
      běžela s `-onlynet=x` a druhá polovina (včetně těžařů) s `-onlynet=y`,
      mohly by vyvstat dva blockchainy. I bez tohoto PR mohli provozovatelé
      uzlů manuálně přidat spojení pro každý dostupný typ sítě pomocí
      volby `-addnode` nebo RPC volání `addnode`."
  a4link="https://bitcoincore.reviews/26847#l-114"

  q5="Proč současná logika v metodě `ThreadOpenConnections()` ani s tímto
      PR dostatečně nezaručuje existenci trvalých odchozích spojení do každé
      dostupné sítě?"
  a5="Nic v PR _nezaručuje_ distribuci spojení mezi dostupnými sítěmi.
      Například pokud máme v `AddrMan` 10 000 clearnetových adres a pouze
      50 I2P adres, je velmi pravděpodobné, že všechna naše spojení
      budou do clearnetu (IPv4 nebo IPv6)."
  a5link="https://bitcoincore.reviews/26847#l-123"

  q6="Jaké další kroky by bylo potřeba učinit k dosažení cíle z předchozí
      otázky?"
  a6="Dalším plánovaným krokem je přidání logiky do procesu vytváření
      spojení, která by se pokoušela mít alespoň jedno spojení do každé
      dosažitelné sítě. Toto PR přináší přípravu k tomuto kroku."
  a6link="https://bitcoincore.reviews/26847#l-144"
%}

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25880][] přináší adaptivní timeout zaseknutí během úvodní
  synchronizace. Bitcoin Core posílá požadavky na bloky několika spojením
  najednou. Je-li jedno spojení natolik pomalejší oproti ostatním spojením,
  že se uzel zasekne během čekání na další blok, odpojíme po určité době
  toto zaseknuté spojení. V některých případech to mohlo způsobit, že
  uzel s pomalým připojením odpojil několik spojení v řadě, když
  se pokoušel stáhnout velký blok, který nemohl být stažen před vypršením
  timeoutu. Tato změna přináší dynamické přizpůsobení timeoutu: pokud nepřichází
  bloky, je timeout s každým dalším odpojením navýšen. Jakmile bloky opět
  začnou přicházet, timeout se blok po bloku opět sníží.

- [Core Lightning #5679][] poskytuje plugin pro spouštění SQL dotazů
  nad různými seznamy v rámci CLN. Tento patch také lépe zachází se zastaráváním
  funkcí, neboť může ignorovat všechny funkce, které byly označeny za
  zastaralé před jeho vydáním (viz [Core Lightning #5867][]).

- [Core Lightning #5821][] přidává RPC volání `preapproveinvoice` (předschválit
  fakturu) a `preapprovekeysend` (předschválit keysend), která volajícímu umožní
  odeslat podepisujícímu modulu (`hsmd`) [BOLT11][] fakturu nebo detaily o [keysend][topic spontaneous
  payments] platbě. Podepisující modul tak může ověřit, zda
  platbu může podepsat. Pro některé aplikace, např. takové, kde jsou částky
  rychlostně limitovány, může být snazší požádat o předschválení než
  pokusit se o platbu a poté řešit selhání.

- [Core Lightning #5849][] provádí na backendu změny, které uzlu umožní
  zvládnout přes 100 000 spojení s jedním kanálem. I když tato situace
  není v blízké budoucnosti pravděpodobná (jen k otevření tolika kanálů
  by bylo potřeba přes tucet kompletních bloků), testování chování
  umožnilo vývojářům provést několik výkonnostních vylepšení.

- [Core Lightning #5892][] aktualizuje implementaci protokolu [nabídek][topic
  offers] na základě testování kompatibility provedeném vývojářem
  pracujícím na implementaci Eclair.

- [Eclair #2565][] nyní vyžaduje, aby byly prostředky ze zavřeného kanálu
  zaslány na novou adresu namísto adresy určené během otevírání kanálu.
  To může zvýšit soukromí narušením [vazeb mezi výstupy][topic output linking].
  Výjimkou z tohoto pravidla je situace, kdy uživatel aktivuje volbu
  `upfront-shutdown-script`, což je požadavek druhé straně kanálu
  provedený během jeho otevírání, aby byla použita jen adresa stanovená
  v té době (podrobnosti viz [zpravodaj č. 158][news158 upfront], *angl.*).

- [LND #7252][] přidává podporu pro používání Sqlite jako databáze
  pro LND. V současnosti je Sqlite podporován pouze pro nové instalace
  LND, jelikož neexistuje žádný migrační kód ze stávající databáze.

- [LND #6527][] přidává možnost zašifrovat TLS klíč, který server
  ukládá na disku. LND používá TLS pro autentikaci vzdálených připojení
  ke svému ovládacímu kanálu, tedy k přístupu k API. TLS klíč bude
  zašifrován pomocí dat z peněženky uzlu, takže odemčení peněženky
  též odemkne TLS klíč. Odemčení peněženky je již nyní vyžadováno
  k posílání a přijímání plateb.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25880,5679,5867,5821,5849,5892,2565,7252,6527" %}
[news158 upfront]: /en/newsletters/2021/07/21/#eclair-1846
[dickinson ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021370.html
[poelstra ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021372.html
[news65 tapscript]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[ckccs jamming]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003834.html
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news230 jam]: /cs/newsletters/2022/12/14/#lokalni-zahlceni-k-zamezeni-vzdaleneho-zahlceni
[news228 jam]: /cs/newsletters/2022/11/30/#navrh-na-pouziti-osvedceni-o-reputaci-k-zamezeni-zahlcovani-ln
[jam xs]: https://github.com/ClaraShk/LNJamming/blob/main/meeting-transcripts/23-01-23-transcript.md
[review club 26847]: https://bitcoincore.reviews/26847
