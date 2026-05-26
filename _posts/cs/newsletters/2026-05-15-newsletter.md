---
title: 'Zpravodaj „Bitcoin Optech” č. 405'
permalink: /cs/newsletters/2026/05/15/
name: 2026-05-15-newsletter-cs
slug: 2026-05-15-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje odhalení zranitelnosti, která mohla útočníkovi
s dostatečným proof of work dovolit shodit Bitcoin Core uzly, a popisuje návrh
BIPu pro sdílení množiny UTXO po P2P síti. Též nechybí naše pravidelné rubriky
s oznámeními nových vydání a popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Odhalení vzdáleného pádu interpretru skriptu v Bitcoin Core:**
  Niklas Gögge zaslal do emailové skupiny Bitcoin-Dev [příspěvek][topic cve mailing list]
  s odhalením [CVE-2024-52911][topic cve disclosure], zranitelnosti
  postihující verze Bitcoin Core po 0.14.0 a před 29.0. Po verzi 0.14.0
  (vydané v březnu 2017) může validování speciálně vytvořeného bloku způsobit
  přístup do již uvolněné paměti. Během validace jsou data potřebná pro kontrolu
  vstupů transakce uložena v mezipaměti. Zmíněná chyba se objevila kvůli pořadí
  životních cyklů objektů během paralelní validace skriptů, kdy mohla být předem
  spočítaná data transakce uvolněna z paměti ještě před tím, než byla dokončena
  vlákna kontrolující na pozadí skripty. U speciálně vytvořených nevalidních
  bloků bylo možné tato data uvolnit, zatímco byla vlákny na pozadí stále používána.

  Útočník s dostatečným proof of work by mohl takový nevalidní blok zkonstruovat a tím
  způsobit pád uzlu oběti. Kvůli povaze tohoto druhu chyb je možné na uzlu
  oběti provést vzdálené spuštění libovolného kódu, avšak vykonání takového útoku
  je nepravděpodobné kvůli obtížím s vytvořením bloku, který by toho byl schopen.

  Zranitelnost objevil a [zodpovědně nahlásil][topic responsible disclosures]
  Cory Fields, který též poskytl ověření konceptu a návrh na opatření. Chyba
  byla opravena v Bitcoin Core 29.0.

- **Návrh BIPu na sdílení množiny UTXO po P2P síti**: Fabian Jahr
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][p2p share ml] o
  [návrhu BIPu][BIPs #2137] na sdílení množiny UTXO přes P2P vrstvu.
  Cílem návrhu je zlepšit výkonnost [assumeUTXO][topic assumeutxo]. Umožní
  novým uzlům stáhnout množinu UTXO přímo od svých peer spojení namísto
  z externích zdrojů. Konkrétně návrh definuje rozšíření P2P protokolu o nový
  servisní bit, čtyři P2P zprávy a kořen Merkleova stromu množiny UTXO,
  který má uzel posílající požadavek k dispozici, aby mohla být správnost
  poskytnuté množiny UTXO ověřena.

  Návrh obdržel zpětnou vazbu. Antoine Riard navrhl vystavit současnou pracovní
  verzi BIPu nad [BIP434][], který definuje vyjednávání peer spojení o dostupné
  funkcionalitě (viz [zpravodaj č. 386][news386 feat negot]), a nadnesl některé
  obavy o záškodnických uzlech rozesílajících falešné množiny UTXO. Eric Voskuil
  autora varoval před dlouhodobými riziky takového BIPu, která by mohla vést
  k novým návrhům zavazování těžařů ke stavu UTXO. Dle Voskuila by oslabilo
  bezpečnostní model bitcoinu, pokud by uzly věřily těžařům namísto ověřování
  celého řetězce od počátečního bloku.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 26.06rc1][] je kandidátem na vydání příští hlavní verze
  tohoto oblíbeného LN uzlu. Vydání obsahuje nová RPC volání
  `graceful`, `sendamount` a `xkeysend`, postupně zastarává `pay` ve
  prospěch `xpay` a přidává podporu pro generování dokladů o BOLT12 platbě.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #35209][] nově konstruuje vektor `txsdata` před objektem
  `CCheckQueueControl`. Tím řeší jádro problému [CVE-2024-52911][topic cve disclosure]
  (viz rubriku s novinkami v tomto čísle). Jelikož C++ odstraňuje lokální
  objekty v opačném pořadí, než v jakém je konstruuje, tato změna zajišťuje,
  že je fronta kontroly skriptů dokončena před odstraněním předem vypočítaných
  dat transakce, na která odkazují objekty `CScriptCheck`. Tím zabraňuje
  vláknům kontrolujícím skripty na pozadí v přistupování do již uvolněné
  paměti. Zranitelnost byla již dříve skrytě opravena v Bitcoin Core 29.0
  (viz [zpravodaj č. 333][news333 fix]).

- [BIPs #2116][] zveřejňuje [BIP323][], který navrhuje rozšíření počtu bitů
  dostupných v `nVersion` pro nonce používaná těžaři z 16 na 24. Tím překonává
  [BIP320][]. Rezervuje bity 5 až 28 pro těžbu hlavičkami bez nutnosti měnit `nTime`
  více než jednou za sekundu. Viz též [zpravodaj č. 395][news395 nversion].

- [BIPs #2141][] a [BIPs #2155][] upravují a rozšiřují [BIP322][], který původně
  v roce 2018 navrhoval [obecný formát podepsaných zpráv][topic generic signmessage].
  Tato aktualizace řeší dlouhodobě nezodpovězené otázky a zpětnou vazbu, rozpracovává
  konstrukci navrhovaných dokladů o dostupných prostředcích a přidává proces
  podepisování PSBT. PR přináší změny nekompatibilní s předchozí specifikací,
  včetně přidání čitelné části před podpis, či změny formátu podpisu dokladu
  o dostupných prostředcích. Podrobnější referenční implementace je založená
  na btcd. Do BIPu jsou přidána testovací data. Stav BIPu byl změněn na
  Complete a formálně navržen k přijetí.

- [Core Lightning #9116][] přidává experimentální podporu pro doklady o platbě
  [BOLT12][topic offers] nabídek, čímž implementuje poslední verzi návrhu
  z [BOLTs #1295][]. Doklady o platbě jsou formátem BOLT12 účtenek, které
  plátci umožňují [doložit][topic proof of payment], že zaplatil fakturu.
  Používají předobraz platby, podpis vydavatele faktury a podpis plátce
  `invreq_payer_id`. Vybraná pole z faktury mohou být vynechána pro zachování
  soukromí. PR přidává funkce pro vytváření a validaci dokladů, upravuje
  `bolt12-cli` a přidává experimentální RPC volání `createproof`. Formát
  zůstává experimentální a může se změnit.

- [Core Lightning #9110][] zastarává RPC volání `pay`, `paystatus`, `keysend`,
  `getroute`, `renepay` a `renepaystatus` pro verzi 26.06, s úplným
  odstraněním plánovaným na vydání 27.03. Volání `xpay` RPC (viz
  [zpravodaj č. 330][news330 xpay]) nově zařizuje většinu plateb, volání
  `xkeysend` bylo přidáno pro zachování funkcionality [keysend][topic spontaneous payments].
  PR dále rozšiřuje `xpay` o parametry `label` a `localinvreqid`,
  CLTV shadow routing, vylepšuje nakládání s opakovanými platbami a
  chybami v `channel_update`. Též upravuje výstup `getroutes` (jasnější
  údaje v jednotlivých skocích, jako jsou částka, uzel a CLTV) a umožňuje `sendpay`
  určit cesty pomocí těchto polí.

- [LDK #4598][] zajišťuje, aby byl příznak `pending_sweep` v `OutputSweeper`u
  vynulován, i když je pokus o sweep (transakce nárokující prostředky z výstupů,
  zejména z uzavřených kanálů, do vlastní peněženky) přerušen před jeho dokončením.
  Příznak zabraňuje více současným pokusům o sweep. Pokud však zůstal nastaven
  po přerušeném sweepu, pozdější pokusy byly nesprávně přeskočeny. Tím mohl
  zabránit nárokování časově citlivých [HTLC][topic htlc] výstupů, dokud
  nebyl uzel restartován. PR tento příznak nuluje pomocí hlídacího objektu,
  který je spuštěn po normálním návratu, po chybě a po přerušení.

- [LDK #4528][] zavazuje BOLT11 `payment_metadata` (viz
  [zpravodaj č. 182][news182 metadata], _angl._) k HMAC příchozí platby.
  Jsou-li součástí faktury metadata, vyžaduje nově LDK před přijetím platby,
  aby poslední onion vrátil stejná metadata. Tím zabrání změnám nebo vynechání
  na straně plátce. Navíc nově tvůrce faktury ve výchozím nastavení přítomnost
  metadat vyžaduje. Uživatelé se však v případě potřeby (např. pro zachování
  kompatibility) mohou povinnosti vyhnout použitím `optional_payment_metadata()`.

- [LND #10612][] přidává grafové hledání cesty pro [onion zprávy][topic onion
  messages]  (viz [zpravodaj č. 396][news396 onion]). LND nyní umí nalézt cestu
  k cíli přes uzly, které inzerují podporu onion zpráv feature bity 38/39.
  Jelikož onion zprávy nejsou platbami, hledání nezohledňuje likviditu ani poplatky.

- [BTCPay Server #7354][] opravuje problém s odhalováním klíče horké peněženky,
  který se objevil poté, co [BTCPay Server #7329][] přidal systém podrobných oprávnění
  pro peněženky. Uživatelům s oprávněním podepisovat peněženkou, ale bez oprávnění
  vidět seed peněženky nebo modifikovat nastavení úložiště, mohl být odhalen odvozený
  soukromý klíč peněženky během podepisování [PSBT][topic psbt]. PR přináší
  pomocnou funkci `HotwalletSafe`, která centralizuje přístup k horké peněžence,
  odděluje oprávnění k podepisování od oprávnění k prohlížení seedu a upravuje
  proces podepisování tak, aby horkou peněženku používal pouze na serverové
  části a neposílal podepisující klíče přes HTTP formulář.

- [BDK #2195][] opravuje synchronizaci z Electrum serverů v případě, kdy není
  první výstup transakce indexovaný (např. `OP_RETURN` výstup). Dříve funkce
  `BdkElectrumClient::populate_with_txids` používala pro získání historie
  konfirmací skript prvního výstupu, který však mohl vrátit prázdnou historii.
  Nově BDK používá skript prvního indexovaného výstupu. Není-li žádný z výstupů
  indexovaný, bude použit předchozí výstupní skript vstupu.

- [Bitcoin Inquisition #100][] implementuje opkód `OP_TEMPLATEHASH` dle [BIP446][]
  pro otestování navržené změny konsenzu na [signetu][topic signet].
  `OP_TEMPLATEHASH` je [tapscriptový][topic tapscript] opkód, který přidá
  do zásobníku haš utrácené transakce (viz [zpravodaj č. 397][news397 templatehash]).
  PR dále přidává rámec pro testování.

- [BINANAs #20][] přiřazuje BIN-2026-0002 budoucí implementaci opkódu
  [OP_CHECKCONTRACTVERIFY][topic matt] (OP_CCV) dle [BIP443][] v Bitcoin Inquisition.
  Zpravodaje [č. 348][news348 op_ccv] a [č. 356][news356 op_ccv] již
  dříve o tomto navrhovaném [kovenantu][topic covenants] informovaly.

{% include snippets/recap-ad.md when="2026-05-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2137,20,100,1295,2116,2141,2155,2195,4528,4598,7329,7354,9110,9116,10612,35209" %}
[topic cve mailing list]: https://groups.google.com/g/bitcoindev/c/e1UEdViSYkU
[topic cve disclosure]: https://bitcoincore.org/en/2026/05/05/disclose-cve-2024-52911/
[Core Lightning 26.06rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc1
[news333 fix]: /cs/newsletters/2024/12/13/#bitcoin-core-31112
[news330 xpay]: /cs/newsletters/2024/11/22/#core-lightning-7799
[news182 metadata]: /en/newsletters/2022/01/12/#bolts-912
[news396 onion]: /cs/newsletters/2026/03/13/#lnd-10089
[news395 nversion]: /cs/newsletters/2026/03/06/#rezervace-24-bitu-namisto-16-v-nversion-pro-nonce
[news397 templatehash]: /cs/newsletters/2026/03/20/#bips-1974
[news348 op_ccv]: /cs/newsletters/2025/04/04/#semantika-op-checkcontractverify
[news356 op_ccv]: /cs/newsletters/2025/05/30/#bips-1793
[p2p share ml]: https://groups.google.com/g/bitcoindev/c/rThmyI8ZN3Q
[news386 feat negot]: /cs/newsletters/2026/01/02/#vyjednavani-o-schopnostech-peer-spojeni
