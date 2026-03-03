---
title: 'Zpravodaj „Bitcoin Optech” č. 350'
permalink: /cs/newsletters/2025/04/18/
name: 2025-04-18-newsletter-cs
slug: 2025-04-18-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší naše pravidelné rubriky s popisem nedávných
změn ve službách a klientském software, oznámeními nových vydání
a popisem významných změn v populárním páteřním bitcoinovém software.
Dále přidáváme korekci některých detailů v popisu SwiftSyncu z minulého týdne.

## Novinky

*V našich [zdrojích][sources] jsme tento týden nenašli žádné významné novinky.*

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydán Bitcoin Knots ve verzi 28.1.knots20250305:**
  Toto [vydání][knots 28.1] Bitcoin Knots obsahuje mimo jiné podporu [podepisování
  zpráv][topic generic signmessage] pro segwitové i taprootové adresy a jejich
  ověřování dle [BIP137][], [BIP322][] a ve stylu podepsaných zpráv v Electru.

- **Ohlášen průzkumník PSBTv2:**
  [Bitcoin PSBTv2 Explorer][bip370 website] nahlíží do [PSBT][topic psbt] zakódovaných
  do datového formátu verze 2.

- **Vydán LNbits v1.0.0:**
  Software [LNbits][lnbits github] přidává k různým lightningovým peněženkám
  účetnictví a další funkce.

- **Vydán The Mempool Open Source Project® v3.2.0:**
  [Vydání v3.2.0][mempool 3.2.0] přidává mimo jiné podporu [v3 transakcí][topic v3 transaction
  relay], anchor výstupů, zveřejňování [1p1c balíčků][topic package relay] a
  vizualizaci jednotek práce v těžebních poolech používajících Stratum.

- **Vydána knihovna Coinbase MPC:**
  Projekt [Coinbase MPC][coinbase mpc blog] je [C++ knihovnou][coinbase mpc
  github] pro zabezpečování klíčů pro použití ve schématech výpočtů s více stranami
  (multi-party computation, MPC) včetně vlastní implementace secp256k1.

- **Vydán nástroj pro práci s likviditou v Lightning Network:**
  [Hydrus][hydrus github] používá stav LN sítě včetně výkonnosti v minulosti,
  aby automaticky otevíral a zavíral lightningové kanály v LND. Podporuje také
  [dávkování][topic payment batching].

- **Ohlášen Versioned Storage Service:**
  Framework [Versioned Storage Service (VSS)][vss blog] je opensourcovým
  cloudovým úložištěm pro stavová data z lightningových a bitcoinových peněženek
  zaměřující se na nekustodiální peněženky.

- **Nástroj pro fuzz testování bitcoinových uzlů:**
  [Fuzzamoto][fuzzamoto github] je framework pro používání fuzz testování pro
  hledání chyb v různých implementacích bitcoinového protokolu používající
  externí rozhraní jako P2P a RPC.

- **Opensourcovány komponenty Bitcoin Control Board:**
  Braiins [ohlásil][braiins tweet], že některé hardwarové a softwarové komponenty
  jejich řídící desky pro těžení BCB100 mají dostupné zdrojové kódy.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 29.0][] je nejnovější hlavní verzí tohoto převládajícího plného
  uzlu. Jeho [poznámky k vydání][bcc rn] popisují několik významných vylepšení:
  nahrazení UPnP (zodpovědné za několik minulých bezpečnostních zranitelností)
  volbou NAT-PMP (obě jsou ve výchozím nastavení vypnuté), vylepšené získávání
  rodičů osiřelých transakcí, což může navýšit spolehlivost současného
  [přeposílání balíčků][topic package relay] v Bitcoin Core, mírné navýšení
  prostoru ve výchozích šablonách bloků (potenciálně může zlepšit příjem
  těžařů), těžaři se mohou lépe vyhnout nahodilému [ohýbání času][topic time warp],
  které by mohlo vyústit ve ztrátu příjmů, pokud by bylo ohýbání času
  [budoucím soft forkem][topic consensus cleanup] zakázáno, a migraci systému
  pro sestavování z autotools na cmake.

- [LND 0.19.0-beta.rc2][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [LDK #3593][] umožňuje uživatelům poskytnout [BOLT12][topic offers] doklad o
  platbě začleněním BOLT12 faktury do události `PaymentSent`. Stará se o to
  nové pole `bolt12` ve výčtovém typu `PendingOutboundPayment::Retryable`,
  které může být začleněno do `PaymentSent`.

- [BOLTs #1242][] začíná vyžadovat [tajný kód platby][topic payment secrets]
  u [BOLT11][] plateb. Po plátcích se nově vyžaduje vynucené selhání, pokud chybí
  pole `s` (tajný kód platby, payment secret). Dříve ho specifikace vyžadovala
  pouze u příjemců a plátcům dovolovala pole ignorovat, pokud mělo nesprávnou
  délku (viz [zpravodaj č. 163][news163 secret], _angl._). PR dále mění [BOLT9][]
  status této funkce na `ASSUMED`.

## Korekce

[Novinka][news349 ss] v minulém čísle o SwiftSyncu obsahovala několik chyb a
zmatečných tvrzení.

- *Nepoužívá akumulátor*: o SwiftSyncu jsme napsali, že používá kryptografický
  akumulátor, což je nesprávné. Kryptografický akumulátor by umožnil otestovat,
  zda je jednotlivý výstup transakce součástí nějaké množiny nebo není. SwiftSync
  to nepotřebuje. Namísto toho přičte hodnotu reprezentující výstup do součtu
  (agregovaného stavu), když je výstup vytvořen, a odečte z něj stejnou hodnotu,
  když je výstup zničen (utracen). Poté, co jsou tyto operace provedeny pro všechny
  výstupy, které měly být před dosažením terminálního bloku utraceny, by se měl součet
  rovnat nule: všechny vytvořené výstupy byly tedy později i utracené.

- *Paralelní validace bloků nevyžaduje assumevalid:* popsali jsme jeden způsob
  fungování paralelní validace se SwiftSyncem, u kterého nejsou skripty až do
  dosažení terminálního bloku validovány. To je podobné dnešnímu fungování
  Bitcoin Core s _assumevalid_. Avšak se SwiftSyncem by předchozí skripty
  validovány být mohly, i když by to pravděpodobně vyžadovalo přidat do P2P
  protokolu k blokům volitelná data navíc. Uzly s Bitcoin Core již tato data
  vedle bloků ukládají, nemyslíme si proto, že by rozšíření P2P zprávy
  bylo obtížné, pokud by lidé ve významném počtu chtěli SwiftSync bez
  assumevalid používat.

- *Paralelní validace bloků je z jiných důvodů než v Utreexo:*
  napsali jsme, že SwiftSync umí validovat bloky paralelně z podobných důvodů
  jako Utreexo, avšak jiným způsobem. Utreexo na počátku validace bloku
  (nebo pro vyšší efektivitu série bloků) vytvoří závazek množině UTXO,
  provede všechny změny množiny UTXO a vytvoří závazek této nové množině.
  To umožňuje rozdělit validaci podle počtu dostupných vláken procesoru.
  Na příklad jedno vlákno validuje prvních tisíc bloků a jiné vlákno validuje
  druhých tisíc bloků. Na konci validování uzel zkontroluje, že závazek
  na konci první tisícovky bloků je stejný jako na počátku druhé tisícovky.

  SwiftSync používá agregovaný stav, který umožňuje odečítat ještě před
  přičítáním. Představte si, že je výstup transakce vytvořen v bloku 1
  a utracen v bloku 2. Pokud zpracováváme blok 2 jako první, odečteme
  hodnotu reprezentující tento výstup z agregovaného stavu. Až později
  zpracujeme i blok 1, přičteme odpovídající hodnotu k agregovanému stavu.
  Výsledkem je nula, tedy přesně to, co získáme na konci celé validace
  pomocí SwiftSyncu.

Našim čtenářům se za naše chyby omlouváme a děkujeme Rubenovi Somsenovi
za nahlášení.

{% include snippets/recap-ad.md when="2025-04-22 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3593,1242" %}
[bitcoin core 29.0]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[sources]: /en/internal/sources/
[news349 ss]: /cs/newsletters/2025/04/11/#swiftsync-urychlujici-uvodni-stahovani-bloku
[bcc rn]: https://bitcoincore.org/en/releases/29.0/
[knots 28.1]: https://github.com/bitcoinknots/bitcoin/releases/tag/v28.1.knots20250305
[bip370 website]: https://bip370.org/
[lnbits github]: https://github.com/lnbits/lnbits
[mempool 3.2.0]: https://github.com/mempool/mempool/releases/tag/v3.2.0
[coinbase mpc blog]: https://www.coinbase.com/blog/innovation-matters-coinbase-breaks-new-ground-with-mpc-security-technology
[coinbase mpc github]: https://github.com/coinbase/cb-mpc
[hydrus github]: https://github.com/aftermath2/hydrus
[vss blog]: https://lightningdevkit.org/blog/announcing-vss/
[fuzzamoto github]: https://github.com/dergoegge/fuzzamoto
[braiins tweet]: https://x.com/BraiinsMining/status/1904601547855573458
[news163 secret]: /en/newsletters/2021/08/25/#bolts-887
