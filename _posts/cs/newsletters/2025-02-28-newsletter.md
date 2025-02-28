---
title: 'Zpravodaj „Bitcoin Optech” č. 343'
permalink: /cs/newsletters/2025/02/28/
name: 2025-02-28-newsletter-cs
slug: 2025-02-28-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje příspěvek o možnosti plných uzlů ignorovat
transakce, které nejsou dopředu vyžádané. Též nechybí naše pravidelné
rubriky s oblíbenými otázkami a odpověďmi z Bitcoin Stack Exchange,
oznámeními nových vydání a významnými změnami v populárním bitcoinovém
páteřním software.

## Novinky

- **Ignorování nevyžádaných transakcí:** Antoine Riard zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][riard unsol] s návrhem dvou BIPů, které by uzlům
  umožnily signalizovat, že již nebudou přijímat zprávy `tx`, které předtím
  nevyžádaly zprávou `inv`, nazývané _nevyžádané transakce_
  (unsolicited transactions). Riard podobnou myšlenku navrhl již v roce 2021
  (viz [zpravodaj č. 136][news136 unsol], _angl._). První navržený BIP přidává
  mechanismus, kterým by uzly signalizovaly své schopnosti a preference
  přeposílání transakcí. Druhý BIP by pomocí tohoto mechanismu umožnil
  uzlům určit, že uzel bude nevyžádané transakce ignorovat.

  Návrh přináší několik drobných výhod, jak bylo diskutováno v [pull
  requestu][bitcoin core #30572] do Bitcoin Core, ale je v rozporu
  s designem některých starších lehkých klientů a mohl by uživatelům
  tohoto software zabránit ve zveřejňování vlastních transakcí. Nasazení
  by tedy muselo být provedeno opatrně. Ačkoliv Riard zmíněný pull request
  nejprve otevřel, později jej zavřel a naznačil, že plánuje pracovat
  na implementaci vlastního plného uzlu postaveného na libbitcoinkernel.
  Též uvedl, že návrh by mohl pomoci v obraně proti některým útokům,
  které nedávno odhalil ([zpravodaj č. 332][news332 txcen]).

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jaké je zdůvodnění aktuální implementace RPC loadtxsoutset?]({{bse}}125627)
  Pieter Wuille vysvětluje, proč je hodnota reprezentující množinu UTXO pro
  [assumeUTXO][topic assumeUTXO] napevno nastavená ve zdrojovém kódu na
  konkrétní výšku bloku, jaké jsou budoucí způsoby distribuce snapshotů
  assumeUTXO a jaké výhody nabízí assumeUTXO oproti prostému kopírování
  interních datových souborů Bitcoin Core.

- [Existují kategorie pinningových útoků, které RBF pravidlo č. 3 znemožňuje?]({{bse}}125461)
  Murch vysvětluje, že [RBF][topic rbf] pravidlo č. 3 nemá zabraňovat
  [pinningovým][topic transaction pinning] útokům, a dotýká se [pravidel nahrazování][bitcoin
  core replacements] v Bitcoin Core.

- [Nečekané hodnoty časového zámku]({{bse}}125562)
  Uživatel polespinasa vyjmenovává důvody, proč Bitcoin Core nastavuje určité
  hodnoty [nLockTime][topic timelocks]: na výšku bloku pro zabránění [fee snipingu][topic
  fee sniping], v 10 % případů na náhodnou hodnotu nižší než výška bloku
  pro zvýšení soukromí nebo na 0, pokud blockchain není aktuální.

- [Proč je v platbě skriptem nutné odhalit bit a ověřit, že odpovídá paritě y-ové souřadnice klíče Q?]({{bse}}125502)
  Pieter Wuille objasňuje [odůvodnění v BIP341][bip341 rationale] kontroly parity y-ové
  souřadnice v [taprootové][topic taproot] platbě skriptem: umožní potenciální
  budoucí přidání dávkové validace.

- [Proč Bitcoin Core používá checkpoint a ne assumevalid blok?]({{bse}}125626)
  Pieter Wuille vysvětluje historii checkpointů v Bitcoin Core a jejich účel
  a odkazuje na PR a diskuzi o [odstranění checkpointů][Bitcoin Core #31649].

- [Jak Bitcoin Core řeší dlouhé reogranizace řetězce?]({{bse}}105525)
  Pieter Wuille nastiňuje způsob, kterým Bitcoin Core řeší reorganizace
  blockchainu, a dodává, že jednou odlišností dlouhých reorganizací je, že
  „neprovádí opětovné přidání transakcí zpět do mempoolu.”

- [Jaká je definice discard feerate?]({{bse}}125623)
  Murch definuje discard feerate jako maximální jednotkový poplatek pro vzdání se
  drobných po platbě a shrnuje kód počítající discard feerate jako „jednotkový
  poplatek cílený na tisíc bloků ořezaný na 3–10 ṩ/vB, pokud je mimo tento
  rozsah.”

- [Kompilátor pravidel na miniscript]({{bse}}125406)
  Brunoerg poznamenává, že peněženka Liana používá jazyk pravidel a odkazuje na knihovny
  [sipa/miniscript][miniscript github] a [rust-miniscript][rust-miniscript github]
  jako příkladů kompilátorů pravidel.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.02rc3][] je kandidátem na vydání příští hlavní verze tohoto oblíbeného
  LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Core Lightning #8116][] mění způsob nakládání s přerušeným vyjednáváním
  o zavření kanálu. Nově bude proces opakovat, i když to nebude potřeba.
  Změna opravuje problém, kdy se kvůli chybějící zprávě `closing_signed`
  uzel pokusí o opakované připojení, obdrží chybu a zveřejní jednostrannou
  zavírací transakci. Mezitím však je protistrana již ve stavu `CLOSINGD_COMPLETE`,
  a proto zveřejní transakci pro vzájemné uzavření kanálu, což může vést
  k soupeření mezi těmito dvěma transakcemi. Díky opravě může vyjednávání
  pokračovat až do potvrzení transakce vzájemného uzavření kanálu.

- [Core Lightning #8095][] přidává do příkazu `setconfig` (viz též [zpravodaj
  č. 257][news257 setconfig]) příznak `transient`, díky kterému může být
  nastavení aplikováno pouze dočasně, bez změny konfiguračního souboru.
  Takové změny konfigurace nejsou tedy po restartu znovu aplikovány.

- [Core Lightning #7772][] přidává do pluginu `chanbackup` aktualizaci
  záložního souboru `emergency.recover` (viz též [zpravodaj č. 324][news324
  emergency]) při každé revokaci commitmentu (když uzel obdrží nový tajný
  kód pro revokaci). Díky tomu mohou uživatelé zamést (sweep) prostředky
  v rámci trestající transakce poté, co protistrana zveřejnila neplatný,
  revokovaný stav. Tato změna rozšiřuje formát [statických záloh kanálu][topic
  static channel backups] a umožňuje pluginu `chanbackup` serializovat
  do starého i nového formátu.

- [Core Lightning #8094][] přidává do pluginu `xpay` (viz [zpravodaj č. 330][news330
  xpay]) konfigurační volbu `xpay-slow-mode`, která na vrácení výsledku
  počká až do vyřešení všech částí [platby s více cestami][topic multipath payments]
  (multipath payments, MPP). Bez tohoto nastavení mohla být vrácena chybová
  hláška, i když některá [HTLC][topic htlc] stále čekala na vyřízení.
  Pokud se uživatel úspěšně znovu pokusil o platbu z jiného uzlu, mohlo dojít
  k přeplacení, pokud se zároveň urovnala čekající HTLC.

- [Eclair #2993][] umožňuje příjemci zaplatit poplatky asociované se [zaslepenou][topic
  rv routing] částí cesty, zatímco odesílatel pokryje poplatky nezaslepené části.
  Dříve odesílatel platil všechny poplatky, což mu mohlo pomoci odhalit zaslepenou
  cestu.

- [LND #9491][] přidává do příkazu `lncli closechannel` podporu pro kooperativní
  zavření kanálu, i když má stále aktivní [HTLC][topic htlc]. V případě zavolání
  pozastaví LND kanál, aby zabránil tvorbě nových HTLC, a počká na vyřízení
  všech existujících HTLC. Poté započne vyjednávání. Uživatelé musí pro aktivaci
  tohoto chování nastavit příznak `no_wait`; v opačném případě obdrží chybovou
  hlášku. PR dále zajistí, že nastavení `max_fee_rate` je během kooperativního
  zavření kanálu vynuceno pro obě strany (dříve bylo jen pro druhou stranu).

{% include snippets/recap-ad.md when="2025-03-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30572,8116,8095,7772,8094,2993,9491,31649" %}
[riard unsol]: https://mailing-list.bitcoindevs.xyz/bitcoindev/e98ec3a3-b88b-4616-8f46-58353703d206n@googlegroups.com/
[news136 unsol]: /en/newsletters/2021/02/17/#proposal-to-stop-processing-unsolicited-transactions
[news332 txcen]: /cs/newsletters/2024/12/06/#zranitelnost-umoznujici-cenzurovani-transakci
[Core Lightning 25.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v25.02rc3
[news257 setconfig]: /cs/newsletters/2023/06/28/#core-lightning-6303
[news324 emergency]: /cs/newsletters/2024/10/11/#core-lightning-7539
[news330 xpay]: /cs/newsletters/2024/11/22/#core-lightning-7799
[bitcoin core replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md#current-replace-by-fee-policy
[bip341 rationale]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-10
[miniscript github]: https://github.com/sipa/miniscript
[rust-miniscript github]: https://github.com/rust-bitcoin/rust-miniscript
