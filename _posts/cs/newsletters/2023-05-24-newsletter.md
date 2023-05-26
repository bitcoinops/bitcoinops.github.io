---
title: Zpravodaj „Bitcoin Optech” č. 252'
permalink: /cs/newsletters/2023/05/24/
name: 2023-05-24-newsletter-cs
slug: 2023-05-24-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme studii o důkazech validity s nulovou znalostí v
bitcoinu a souvisejících protokolech a přinášíme další příspěvek
v naší krátké týdenní sérii o pravidlech mempoolu. Též nechybí
naše pravidelné rubriky popisující aktualizace klientů a služeb,
nová vydání a změny v populárních bitcoinových páteřních projektech.

## Novinky

- **Komprese stavu pomocí důkazů validity s nulovou znalostí:** Robin Linus
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][linus post] o
  [studii][lg paper], jejíž je autorem spolu s Lukasem Georgem.
  Studie pojednává o použití důkazů validity k redukci velikosti stavu,
  který klient musí stáhnout, aby mohl bez požadavku na důvěru
  ověřovat budoucí operace. Tento systém prvně aplikují na bitcoin.
  Oznámili existenci prototypu, který umí podat důkaz o kumulativním
  objemu důkazu práce v řetězci hlaviček bloků a který umožňuje klientovi
  ověřit, zda je konkrétní hlavička bloku součástí tohoto řetězce. To
  umožňuje klientovi, který obdrží několik důkazů, určit, který z nich
  představuje nejvíce práce.

  Též mají (prozatím neoptimální) prototyp dokazující, že všechny změny
  stavu transakcí blockchainu respektovaly pravidla měny (např. kolik
  bitcoinů může být novým blokem vytvořeno, že každá necoinbasová
  transakce nesmí vytvořit UTXO s větší hodnotou, než kolik utrácí,
  a že si těžař může nárokovat rozdíl mezi UTXO utrácenými a vytvářenými).
  Klient může pomocí tohoto důkazu a kopie aktuální množiny UTXO ověřit,
  že množina je přesná a kompletní. Nazývají tento důkaz _assumevalid_,
  stejně jako volitelnou [funkci v Bitcoin Core][assumevalid], která
  přeskakuje verifikaci skriptů starších bloků, na jejichž validitě se
  shodne množství přispěvatelů.

  Pro minimalizaci složitosti důkazu používají verzi [utreexo][topic utreexo]
  s hashovací funkcí optimalizovanou pro tento systém. Navrhují, že kombinace
  jejich důkazu a utreexo klienta umožní začít provozovat plný uzel téměř
  okamžitě po stažení velmi malého množství dat.

  Co se týče použitelnosti prototypu, píší, že „implementovali prototyp důkazu
  řetězce hlaviček a důkazu assumevalid stavu. Ten první je již použitelný,
  druhý ještě vyžaduje vylepšení výkonnosti dokazování objemnějších bloků.”
  Též pracují na validaci kompletních bloků včetně skriptů, ale podle jejich
  slov musí dosáhnout minimálně 40násobného zrychlení.

  Vedle komprese stavu bitcoinového blockchainu též popisují protokol, který
  může být použit pro tokenové protokoly s validací na straně klienta, který
  používají například Taproot Assets od Lightning Labs (viz zpravodaj
  [č. 195][news195 taro], *angl.*) nebo RGB ([č. 247][news247 rgb]). Když
  Alice pošle Bobovi určité množství tokenů, musí Bob ověřit historii
  každého předchozího transferu těchto konkrétních tokenů až zpět k jejich
  vytvoření. V ideálním případě roste historie lineárně s množstvím
  transferů. Ale chce-li Bob zaplatit Carol množstvím větším, než kolik
  obdržel od Alice, bude muset zkombinovat některé z tokenů, které obdržel
  od Alice, s jinými, které obdržel v jiných transakcích. Carol potom bude
  muset ověřit obě historie. Toto se nazývá sloučení („merge”). Objevují-li
  se sloučení často, dosahuje velikost historie, která se musí ověřit,
  velikosti historie každého transferu tokenů mezi kterýmikoliv uživateli.
  V bitcoinu, pro porovnání, ověřuje každý plný uzel každou transakci každého
  uživatele. To není v tokenových protokolech s validací na straně klienta
  nezbytnou nutností, ale jsou-li sloučení běžná, v podstatě se tak děje.

  Znamená to, že protokol přinášející kompresi bitcoinového stavu může být
  upraven ke komprimování stavu historie tokenů, včetně těch s častými sloučeními.
  Autoři popisují, jak by toho bylo možné dosáhnout. Jejich cílem je vytvořit
  důkaz, že každý předchozí transfer tokenu se řídil pravidly tokenu a že
  každý předchozí transfer byl řádně ukotven v bitcoinovém blockchainu. Alice
  by potom mohla poslat Bobovi tokeny a poskytnout mu malý důkaz validity.
  Bob by potom ověřením důkazu potvrdil, že transfer proběhl v určité blokové výšce
  a že byl adresátem transferu.

  Ačkoliv je ve studii často zmiňována nutnost dodatečného výzkumu a vývoje,
  přináší nám nadějný postup směrem ke [CoinWitness][coinwitness], funkci,
  po které bitcoinoví vývojáři touží již více než deset let.

## Čekání na potvrzení 2: incentivy

_Krátká týdenní série o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/02-cache-utility.md %}

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydán firmware verze 2.1.1 pro Passport:**
  [Nejnovější firmware][passport 2.1.1] pro hardwarové podpisové zařízení Passport
  podporuje posílání na [taprootové][topic taproot] adresy, [BIP85][] funkce a
  zlepšuje nakládání s [PSBT][topic psbt] a vícenásobnými podpisy.

- **Vydána MuSig peněženka Munstr:**
  Beta software [Munstr][munstr github] používá [protokol Nostr][nostr protocol]
  pro komunikaci potřebnou pro podepisování [MuSig][topic musig] transakcí
  s vícenásobnými podpisy.

- **Vydán Coffee, správce pluginů pro CLN:**
  [Coffee][coffee github] je správce pluginů pro CLN, který vylepšuje instalaci,
  konfiguraci, správu závislostí a upgradování [CLN pluginů][news22 plugins].

- **Vydáno Electrum 4.4.3:**
  [Nejnovější vydání][electrum release notes] Electra obsahuje vylepšení výběru
  mincí, nástroj pro analýzu soukromí UTXO, podporu krátkých identifikátorů kanálů
  („Short Channel Identifiers,” SCID) a další opravy a vylepšení.

- **Trezor Suite přidává podporu coinjoinů:**
  Trezor Suite [oznámil][trezor blog] podporu [coinjoinů][topic coinjoin] za pomocí
  koordinátora zkSNACKs.

- **Lightning Loop používá MuSig2 ve výchozím nastavení:**
  [Lightning Loop][news53 loop] nyní používá [MuSig2][topic musig] jako výchozí
  protokol pro swap, což přinese nižší poplatky a větší soukromí.

- **Mutinynet oznámil nový signet pro testování:**
  [Mutinynet][mutinynet blog] je signet s 30sekundovými bloky, který poskytuje
  testovací infrastrukturu včetně [prohlížeče bloků][topic block explorers],
  zdroje testovacích bitcoinů a testovacích LN uzlů a LSP.

- **Nunchuk přidává výběr mincí a podporu BIP329:**
  Nejnovější androidová a iOS verze Nunchuku přidává [výběr mincí][nunchuk blog]
  a export štítků peněženky podle [BIP329][].

- **MyCitadel Wallet přidává vylepšenou podporu miniscriptu:**
  Vydání [v1.3.0][mycitadel v1.3.0] přidává pokročilejší možnosti [miniscriptu][topic miniscript]
  včetně [časových zámků][topic timelocks].

- **Oznámen Edge Firmware pro Coldcard:**
  Coinkite [oznámil][coinkite blog] experimentální firmware pro podpisové zařízení
  Coldcard, který umožňuje vývojářům peněženek a pokročilým uživatelům experimentovat
  s novými funkcemi. Prvotní vydání 6.0.0X přináší taprootové keysend platby,
  [tapscriptové][topic tapscript] multisig platby a podporu [BIP129][].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.05][] je vydání nejnovější verze této implementace LN.
  Přináší mimo jiné podporu pro [zaslepené platby][topic rv routing],
  [PSBT][topic psbt] verze 2 a flexibilnější správu poplatků.

- [Bitcoin Core 23.2][] je údržbové vydání předchozí hlavní verze Bitcoin Core.

- [Bitcoin Core 24.1][] je údržbové vydání současné verze Bitcoin Core.

- [Bitcoin Core 25.0rc2][] je kandidátem na vydání příští hlavní verze Bitcoin Core.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #27021][] přidává rozhraní pro kalkulaci tzv. _schodku poplatku_
  („fee deficit”), který udává, kolik by stálo zarovnat výstupy nepotvrzených
  rodičovských transakcí na daný jednotkový poplatek. Když algoritmy [výběru mincí][topic
  coin selection] uvažují nad konkrétním výstupem s určitým jednotkovým
  poplatkem, spočítají schodek poplatku jeho rodičů a výsledek odečtou
  od jeho efektivní hodnoty. To zabraňuje, aby peněženka volila výstupy s příliš
  velkým schodkem, jsou-li k dispozici vhodnější výstupy. V [následném PR][bitcoin
  core #26152] bude toto rozhraní použito také k umožnění plateb s navýšeným poplatkem
  („bump fees”), mají-li tak jako tak být zvoleny výstupy se schodkem. Zaručí to,
  že nová transakce bude platit efektivní jednotkový poplatek vyžádaný uživatelem.

  Algoritmus je schopný vyhodnotit navyšování poplatků ve všech případech
  díky posuzování kompletního souboru nepotvrzených transakcí spojených
  s tímto nepotvrzeným UTXO a neuvažováním transakcí, které by byly s cíleným
  jednotkovým poplatkem začleněny do bloku. Druhá metoda poskytuje agregované
  navýšení poplatku napříč několika nepotvrzenými výstupy pro korigování
  potenciálního překrývání předků.

- [LND #7668][] přidává možnost připojit ke kanálu během otevírání soukromou
  poznámku obsahující až 500 znaků. Tato poznámka může operátorovi připomenout
  důvod otevření kanálu.

- [LDK #2204][] přidává možnost nastavit uživatelský feature bit. Ten bude použit
  při oznamování vlastním spojením nebo během zpracování oznámení od spojení.

- [LDK #1841][] implementuje verzi bezpečnostních doporučení přidaných do
  LN specifikace (viz [zpravodaj č. 128][news128 bolts803], *angl.*), podle které
  by se uzel používající [anchor výstupy][topic anchor outputs] neměl pokoušet
  vytvářet transakce se vstupy několika stran, je-li vyžadováno rychlé
  potvrzení této transakce. To zabrání ostatním stranám konfirmaci
  pozdržet.

- [BIPs #1412][] přidává do [BIP329][] ([export štítků peněženky][topic wallet labels])
  pole pro ukládání informací o původu klíče. Dále specifikace nově doporučuje,
  aby štítky nepřesáhly 255 znaků.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27021,7668,2204,1841,1412,26152" %}
[Core Lightning 23.05]: https://github.com/ElementsProject/lightning/releases/tag/v23.05
[bitcoin core 23.2]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021679.html
[lg paper]: https://zerosync.org/zerosync.pdf
[news128 bolts803]: /en/newsletters/2020/12/16/#bolts-803
[news247 rgb]: /cs/newsletters/2023/04/19/#aktualizace-rgb
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[coinwitness]: https://bitcointalk.org/index.php?topic=277389.0
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[passport 2.1.1]: https://foundationdevices.com/2023/05/passport-version-2-1-0-is-now-live/
[munstr github]: https://github.com/0xBEEFCAF3/munstr
[nostr protocol]: https://github.com/nostr-protocol/nostr
[coffee github]: https://github.com/coffee-tools/coffee
[news22 plugins]: /en/newsletters/2018/11/20/#c-lightning-2075
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[trezor blog]: https://blog.trezor.io/coinjoin-privacy-for-bitcoin-11aaf291f23
[mutinynet blog]: https://blog.mutinywallet.com/mutinynet/
[news53 loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[nunchuk blog]: https://nunchuk.io/blog/coin-control
[mycitadel v1.3.0]: https://github.com/mycitadel/mycitadel-desktop/releases/tag/v1.3.0
[coinkite blog]: https://blog.coinkite.com/edge-firmware/
