---
title: 'Zpravodaj „Bitcoin Optech” č. 263'
permalink: /cs/newsletters/2023/08/09/
name: 2023-08-09-newsletter-cs
slug: 2023-08-09-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden varujeme před závažnou zranitelností v nástroji Libbitcoinu
Bitcoin Explorer (bx), přinášíme souhrn diskuze o návrhu ochrany před
odepřením služby, oznámení plánu na testování a sběr dat HTLC atestací
a popis dvou navrhovaných změn pravidel přeposílání transakcí v
Bitcoin Core. Též nechybí naše pravidelné rubriky se souhrnem sezení
Bitcoin Core PR Review Club, oznámeními o nových verzích a popisem
významných změn v populárních bitcoinových páteřních projektech.

## Upozornění

- **Závažná zranitelnost v Libbitcoin Bitcoin Explorer:** pokud jste
  pomocí příkazu `bx seed` vytvořili  [BIP32][topic BIP32] seed, tajný
  seznam slov podle [BIP39][], soukromé klíče či jiné bezpečnostní
  kódy, zvažte okamžité přesunutí prostředků na jinou, bezpečnou adresu.
  V rubrice Novinky uvádíme další podrobnosti.

## Novinky

- **Návrh na ochranu před odepřením služby (DoS):** Anthony
  Towns zaslal do emailové skupiny Lightning-Dev [odpověď][towns dos]
  k sekci poznámek ze setkání vývojářů LN (viz [zpravodaj č. 261][news261
  jamming]) zabývající se [zahlcením kanálu][topic channel jamming attacks].
  Poznámky tvrdily, že „náklady na odrazení útočníka jsou pro čestného
  uživatele nepřiměřené a náklady, které by byly pro čestného uživatele
  přiměřené, jsou příliš nízké na odrazení útočníka.”

  Towns navrhl jiný směr, než pokoušet se útočníka přeplatit: náklady
  sdílené útočníky i čestnými uživateli by měly odrážet skutečné
  náklady provozovatelů uzlů na poskytování služeb. Tímto způsobem
  by provozovatel uzlu, který vydělává na poskytování služeb čestným
  uživatelům, vydělával, kdyby jeho služeb začali využívat i útočníci.
  Pokud by se útočník pokusil o odepření služeb čestným uživatelům
  nadměrným využíváním zdrojů uzlu, měli by provozovatelé uzlů
  motivaci (vyšší výdělek) navýšit tyto zdroje.

  Jako návrh na fungování tohoto systému oživil Towns několik let
  starou myšlenku (viz [zpravodaj č. 86][news86 hold fees], *angl.*)
  na kombinaci dopředných commitment poplatků a zpětných poplatků za
  držení, které by byly placeny nad rámec běžných poplatků za úspěšnou
  platbu. Během propagace HTLC od Alice (plátce) k Bobovi (přeposílající
  uzel) by Alice zaplatila drobný dopředný commitment poplatek; Bobova
  část tohoto poplatku by odpovídala jeho nákladům na zpracování HTLC
  (např. datový přenos). Bob by po přijetí HTLC začal pravidelně
  platit Alici malé zpětné poplatky za držení až do doby, kdy by bylo
  HTLC vyřízeno. Tím by Alice obdržela kompenzaci za dobu čekání na
  potvrzení či zrušení její platby. Pokud by Bob okamžitě přeposlal
  platbu Carol, zaplatil by jí mírně nižší dopředný commitment
  poplatek, než který obdržel od Alice (rozdíl by byl jeho kompenzací),
  a Carol by mu poskytla mírně vyšší zpětný poplatek za držení
  (rozdíl by byl opět jeho kompenzací). Dokud žádný z přeposílajících
  uzlů nebo příjemce nepozdrží HTLC, byl by jediným nákladem navíc
  oproti běžnému poplatku za úspěšnou platbu onen malý dopředný
  commitment poplatek. Pokud by však příjemce nebo kterýkoliv jiný
  uzel po cestě platbu pozdržel, byl by nakonec zodpovědný za placení
  všech zpětných poplatků za držení.

  Clara Shikhelman [odpověděla][shikhelman dos], že zpětné poplatky
  za držení placené během určité doby by mohly snadno převýšit částku,
  kterou by uzel vydělal za úspěšně dokončenou platbu. Záškodnické uzly
  by tím byly motivovány ke zneužívání tohoto mechanismu k výběru
  poplatků od svých protistran. Popsala obtíže, se kterými by se potýkal
  systém podobný tomu popsanému Townsem. Towns v [odpovědi][towns dos2]
  přinesl protiargumenty a přidal shrnutí: „Věřím, že i když se současná
  implementace zaměřuje na techniky založené na reputaci, finanční odrazování
  od DoS má i nadále šanci stát se v případě zájmu zajímavým předmětem
  výzkumu.”

- **Testování a sběr dat HTLC atestací:** Carla Kirk-Cohen a Clara
  Shikhelman zaslaly do emailové skupiny Lightning-Dev [příspěvek][kcs
  endorsement] s oznámením, že vývojáři spříznění s Eclairem, Core
  Lightningem a LND pracují na implementaci části protokolu [HTLC
  atestací][topic htlc endorsement] („HTLC endorsement”), aby mohli
  začít sbírat relevantní data. Navrhli též soubor dat, jehož sběr
  testovacími uzly by byl pro výzkum užitečný. Mnoho položek bude obsahovat
  náhodná data, aby nemohlo dojít k úniku soukromých informací. Testování
  má proběhnout v několika fázích, v každé se budou účastnící se uzly
  chovat jiným způsobem.

- **Návrhy změn výchozích pravidel přeposílání v Bitcoin Core:** Peter Todd
  otevřel v emailové skupině Bitcoin-Dev dvě vlákna související s jeho
  pull requesty měnící výchozí pravidla přeposílání transakcí v  Bitcoin Core.

  - *Full RBF ve výchozím stavu:* [první vlákno][todd rbf] a [pull
      request][bitcoin core #28132] navrhují v příštích verzích Bitcoin
    Core učinit [full RBF][topic rbf] výchozí volbou. V současnosti
    ve výchozím stavu Bitcoin Core přijímá do mempoolu a přeposílá
    nahrazení nepotvrzených transakcí pouze, obsahuje-li nahrazovaná
    transakce [BIP125][] příznak signalizující volitelnou nahraditelnost
    (a pokud obě transakce, původní i nahrazující, splňují několik dalších
    pravidel). Tato situace se nazývá _opt-in RBF_. Konfigurační volba
    `-mempoolfullrbf` umožňuje provozovatelům uzlů namísto toho nastavit
    přijímání nahrazení jakékoliv nepotvrzené transakce, i těch
    neobsahujících BIP125 příznak. Zde hovoříme o _full RBF_ (viz
    [zpravodaj č. 208][news208 rbf], *angl.*). Dle Toddova návrhu
    by byl full RBF výchozí volbou, avšak provozovatelé uzlů by měli
    možnost zvolit opt-in RBF.

    Peter Todd tvrdí, že tato změna je odůvodněná, protože dle jeho měření
    (které bylo [zpochybněno][towns rbf]) má významná část těžařů nastaveno
    full RBF a existuje také dostatečné množství přeposílajících uzlů
    s touto volbou (aby nahrazení bez příznaku byla přeposlána k
    těžařům). Dále říká, že neví o žádné aktivní službě, která by v
    současnosti přijímala nepotvrzené onchain transakce jako konečnou
    platbu.

  - *Odstranění omezení  `OP_RETURN` výstupů:* [druhé vlákno][todd opr]
    a [pull request][bitcoin core #28130] navrhují odstranit z Bitcoin Core
    omezení transakcí, které obsahují výstupní skripty začínající opkódem
    `OP_RETURN` (_OP_RETURN výstupy_). V současnosti Bitcoin Core ve výchozím
    stavu nepřeposílá ani nepřijímá do mempoolu transakce, které mají více
    než jeden `OP_RETURN` výstup nebo mají `OP_RETURN` výstup se skriptem
    větším než 83 bytů (tedy více než 80 bytů libovolných dat).

    Podnětem umožnění přeposílání a těžení malého množství dat v rámci
    `OP_RETURN` výstupů byly transakce, které předtím obsahovaly data
    v jiných druzích výstupů, které se ukládaly v množině UTXO, většinou
    nadobro. `OP_RETURN` výstupy nemusí být uloženy v množině UTXO, nepřináší
    tedy takové potíže. Od té doby začali někteří lidé ukládat velká množství
    dat ve witnessech transakcí.

    Pull request by ve výchozím stavu povolil jakékoliv množství `OP_RETURN`
    výstupů a jakékoliv množství dat v `OP_RETURN` výstupech. Transakce by
    se i nadále musely řídit dalšími pravidly přeposílání (např. celková
    velikost transakce musí být menší než 100 000 vbytů). V době psaní
    zpravodaje byly názory na pull request smíšené. Někteří vývojáři
    se obávají, že uvolněná pravidla by navýšila množství nefinančních dat
    uložených v blockchainu. Jiní tvrdí, že neexistuje žádný důvod, proč
    bránit lidem ve využívání `OP_RETURN` výstupů, když se již používají
    jiné způsoby ukládání dat v blockchainu.

- **Odhalení bezpečnostní zranitelnosti v Libbitcoin Bitcoin Explorer:**
  několik bezpečnostních výzkumníků vyšetřujících nedávnou ztrátu bitcoinů
  mezi uživateli Libbitcoin [zjistilo][milksad], že příkaz `seed` Bitcoin
  Exploreru (bx) v rámci tohoto programu generuje pouze zhruba čtyři
  miliardy jedinečných hodnot. Útočník, který předpokládal, že byl tento
  program použit pro tvorbu soukromých klíčů nebo peněženek s určitou
  derivační cestou (např. BIP39), mohl potenciálně během jediného dne
  na běžném počítači prohledat všechny možné peněženky a tím ukrást
  prostředky na ně přijaté. Jedna taková krádež se pravděpodobně udála
  12. července 2023 se ztrátou téměř 30 BTC (v té době zhruba 19 miliónů
  korun).

  Několik postupů podobných výše uvedenému bylo [nalezeno][mb milksad] v
  knize _Mastering Bitcoin_, na [domovské stránce dokumentace][bx home]
  Bitcoin Exploreru a mnoha dalších místech dokumentace (např. [1][bx1],
  [2][bx2], [3][bx3]). Nikde v této dokumentaci nebylo jasné varování o
  nebezpečnosti kromě [online dokumentace][seed doc] příkazu `seed`.

  Doporučujeme, aby každý, kdo mohl použít `bx seed` ke generování peněženek
  nebo adres, navštívil [stránku][milksad] s popisem zranitelnosti a zvážil
  použití jejich služby k otestování hashů zranitelných seedů. Pokud jste
  použili shodný postup jako útočník, vaše bitcoiny byly již zřejmě ukradené.
  S variacemi postupu však máte ještě šanci přesunout bitcoiny do bezpečí.
  Pokud se domníváte, že vaše peněženka používá Libbitcoin, informujte prosím
  vývojáře o této zranitelnosti a požádejte je o prošetření.

  Děkujeme výzkumníkům za úsilí vynaložené na přípravu [zodpovědného
  zveřejnění][topic responsible disclosures] zranitelnosti [CVE-2023-39910][].

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Tiché platby: naimplentuj BIP352][review club 28122] je PR od uživatele josibake,
které podniká první kroky v přidání [tichých plateb][topic silent payments]
(„silent payments”) do peněženky Bitcoin Core. Toto PR implementuje pouze logiku
z [BIP352][] a nepřináší žádné změny peněženky.

{% include functions/details-list.md
  q0="Proč PR přidává vlastní ECDH hashovací funkci a nepoužívá tu poskytovanou
       `secp256k1`?"
  a0="Ve skutečnosti _nechceme_ hashovat výsledek ECDH; vlastní funkce
      neaplikuje `sha256` na výsledek ECDH operace. To je potřeba, pokud
      tvůrce transakce nemá pod kontrolou všechny její vstupy. Absence hashování
      výsledku během ECDH umožňuje jednotlivým účastníkům provést ECDH
      pouze s jejich soukromým klíčem a předat částečné ECDH dále. Výsledky
      částečných ECDH mohou být sečteny a poté lze provést zbytek protokolu."
  a0link="https://bitcoincore.reviews/28122#l-126"

  q1="PR přidává funkce pro kódování a dekódování adres tichých plateb. Proč
      nemůžeme jednoduše přidat adresy tichých plateb jako další variantu
      `CTxDestination` a použít existující třídy a funkce?"
  a1="Adresa tiché platby totiž nekóduje žádný konkrétní výstupový skript
      (není to `scriptPubKey`). Kóduje namísto toho veřejné klíče potřebné
      k _odvození_ skutečného výstupového skriptu, který také závisí na
      vstupech vaší transakce tiché platby. Tedy namísto poskytování
      `scriptPubKey` pro přijetí platby (tradiční adresy) vám tichá platba
      dá veřejné klíče pro ECDH a protokol promění tento sdílený tajný
      kód v `scriptPubKey`, který příjemce detekuje a později z něj utratí."
  a1link="https://bitcoincore.reviews/28122#l-153"

  q2="[BIP352][] odkazuje na verzování a dopřednou kompatibilitu. Co je
      dopředná kompatibilita a proč je důležitá?"
  a2="Umožňuje (například) peněžence verze 0 dekódovat a poslat prostředky
      na adresu tiché platby peněženky verze 1 (a verze 2 atd.), i když
      není peněženka schopna vygenerovat adresu verze 1. Je to důležité,
      protože peněženky nemusí upgradovat hned, jakmile se objeví nová
      verze."
  a2link="https://bitcoincore.reviews/28122#l-170"

  q3="A co kdyby nová verze chtěla záměrně porušit kompatibilitu?"
  a3="Verze 31 je vyhraněna pro upgrade, který by kompatibilitu narušil."
  a3link="https://bitcoincore.reviews/28122#l-186"

  q4="Proč stačí vyhradit pouze jednu verzi (31) pro narušení kompatibility?"
  a4="Můžeme odložit na později definici nových pravidel, jak by se mělo nakládat
      s verzemi _po_ této narušující změně."
  a4link="https://bitcoincore.reviews/28122#l-188"

  q5="`DecodeSilentAddress` obsahuje kontrolu verze a velikosti dat. Co tato
      kontrola dělá a proč je důležitá?"
  a5="Přinese-li nová verze do adresy větší množství dat, musíme mít způsob,
      jak obdržet pouze dopředně kompatibilní části. Jinými slovy musíme
      se omezit na parsování první 66 bytů (formát verze 0). Je to důležité
      pro dopřednou kompatibilitu."
  a5link="https://bitcoincore.reviews/28122#l-194"

  q6="Nový kód tichých plateb je umístěn v adresáři peněženky v
      `src/wallet/silentpayments.cpp`. Je to dobré místo? Dokážete
      vymyslet situaci, kdy bychom chtěli použít kód tichých plateb
      mimo kontext peněženky?"
  a6="Není to nejlepší, pokud by někdo chtěl naimplementovat server
      bez peněženek, který by detekoval tiché platby (či prováděl
      relevantní výpočty) pro lehčí peněženky. Lze si představit
      situaci, kdy plný uzel indexuje tweaky transakcí a umožňuje
      lehkým klientům mezi nimi vyhledávat nebo poskytovat tato data
      pomocí filtru podobného [BIP158][]. Avšak dokud tato situace
      nenastane, kód v `src/wallet` je lépe organizován."
  a6link="https://bitcoincore.reviews/28122#l-205"

  q7="Třída `Recipient` je v PR inicializována se dvěma soukromými klíči:
      klíčem pro utracení a klíčem pro prohledávání. Jsou oba tyto klíče
      pro prohledávání potřebné?"
  a7="Ne, pouze klíč pro prohledávání je potřebný. Schopnost prohledávat
      tiché platby bez klíče pro utracení může být implementována v budoucnosti."
  a7link="https://bitcoincore.reviews/28122#l-217"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 0.28.1][] je vydáním této oblíbené knihovny pro budování peněženek.
  Obsahuje opravy chyb a přidává šablonu pro odvozování cest dle [BIP86][]
  pro [P2TR][topic taproot] v [deskriptorech][topic descriptors] .

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27746][] zjednodušuje vztah mezi úložištěm bloků a
  chainstate objekty tím, že přemisťuje rozhodování, zda uložit blok
  na disk, do validační logiky, která je na aktuálním chainstate
  nezávislá. Rozhodnutí, zda uložit blok na disk, souvisí s validačními
  pravidly, která nevyžadují přístup ke stavu UTXO. V předchozích verzích
  používal Bitcoin Core z anti-DoS důvodů heuristiku pro konkrétní
  chainstate, ale s [assumeUTXO][topic assumeutxo] a možností existence
  dvou chainstate najednou byl tento mechanismus přepracován, aby mohl
  být rozdělen.

- [Core Lightning #6376][] a [#6475][core lightning #6475] implementují
  plugin nazývaný `renepay`, který používá Pickhardtovy platby pro
  vytváření optimálních [plateb s více cestami][topic multipath payments]
  (viz [zpravodaj č. 192][news192 pp], *angl.*). Pickhardtovy platby
  předpokládají, že likvidita v každém kanálu je ve směru toku náhodně
  rozdělena mezi 0 a plnou kapacitou. Platby vysokých částek mohou
  selhat, protože cesta nemusí poskytovat dostatečnou likviditu nebo protože
  rozdělení platby do mnoha částí násobí pravděpodobnost selhání. Platba
  je poté namodelována jako tok v lightningové síti mající za cíl nalézt
  střední cestu mezi počtem částí platby a částkami jednotlivých částí.
  Díky tomuto přístupu nacházejí Pickhardtovy platby optimální tok, který
  splňuje omezení daná kapacitami a zůstatky a zároveň maximalizuje
  pravděpodobnost úspěchu. Odpovědi nedokončených plateb jsou použity
  pro aktualizaci předpokládané distribuce likvidity všech zúčastněných
  kanálů. Jelikož by použití základních poplatků dle [BOLT7][] bylo
  výpočetně náročné (viz [zpravodaj č. 163][news163 base], *angl.*),
  budou uzly používající `renepay` nadhodnocovat relativní poplatek
  u kanálů s nenulovým základním poplatkem. Onion balíčky zkonstruované
  pro doručení platby používají skutečné poplatky.

- [Core Lightning #6466][] a [#6473][core lightning #6473] přidávají
  podporu pro zálohu a obnovu [hlavního tajného kódu][topic BIP32]
  peněženky ve formátu [codex32][topic codex32] dle [BIP93][].

- [Core Lightning #6253][] a [#5675][core lightning #5675] přidávají
  experimentální implementaci [splicingu][topic splicing] dle návrhu
  specifikace z [BOLTs #863][]. Pokud obě strany kanálu podporují
  splicing, mohou přidat prostředky do kanálu pomocí onchain transakce
  (splice-in) nebo odebrat prostředky z kanálu platbou onchain
  (splice-out). Ani jedna z těchto operací nevyžaduje uzavření kanálu
  a během čekání na potvrzení onchain splicingové transakce může
  kanál pokračovat ve své obvyklé činnosti. Klíčovou výhodou splicingu
  je možnost LN peněženek držet většinu prostředků offchain a utrácet
  tyto prostředky onchain podle potřeby. Díky tomu mohou peněženky
  ukazovat uživateli jediný zůstatek (a ne offchain a onchain zůstatky
  zvlášť).

- [Rust Bitcoin #1945][] upravuje pravidla projektu stanovující
  minimální počet schválení PR v případě pouhého refaktorování.
  Jiné projekty potýkající se s problémem schvalování malých změn
  dle stejných standardů jako ostatní PR mohou prozkoumat nová
  pravidla Rust Bitcoin.

- [BOLTs #759][] přidává do specifikace LN podporu [onion zpráv][topic
  onion messages]. Onion zprávy umožňují jednosměrné poslání zprávy
  napříč celou sítí. Podobně jako platby (HTLC) používají i tyto
  zprávy onion šifrování, takže každý přeposílající uzel ví pouze,
  odkud zprávu obdržel a kam má zprávu poslat dále. Obsah zprávy
  je také šifrován, pouze konečný příjemce ji může přečíst. Na rozdíl
  od přeposílaných HTLC, které jsou obousměrné (commitment proudí
  směrem k příjemci a předobraz potřebný k nárokování platby teče
  opačným směrem k odesílateli), nemusí být onion zprávy díky své
  jednosměrné povaze ukládány, ač některá navrhovaná opatření proti
  DoS závisí na držení malého množství agregovaných informací
  (viz [zpravodaj č. 207][news207 onion], *angl.*). Obousměrného
  posílání lze dosáhnout přilepením zpáteční cesty ke zprávě. Onion
  zprávy používají [zaslepené cesty][topic rv routing], které byly
  přidány do specifikace před několika měsíci (viz [zpravodaj č.
  245][news245 blinded]), a jsou také využívány vyvíjeným protokolem
  [nabídek][topic offers].

{% include references.md %}
{% include linkers/issues.md v=2 issues="27746,6376,6475,6466,6473,6253,5675,863,1945,759,28132,28130" %}
[news245 blinded]: /cs/newsletters/2023/04/05/#bolts-765
[towns dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004020.html
[news86 hold fees]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[shikhelman dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004033.html
[towns dos2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004035.html
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004034.html
[todd rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021823.html
[towns rbf]: https://github.com/bitcoin/bitcoin/pull/28132#issuecomment-1657669845
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[news261 jamming]: /cs/newsletters/2023/07/26/#navrhy-na-obranu-pred-zahlcenim-kanalu
[todd opr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021840.html
[review club 28122]: https://bitcoincore.reviews/28122
[bip352]: https://github.com/bitcoin/bips/pull/1458
[bip158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[CVE-2023-39910]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-39910
[milksad]: https://milksad.info/
[mb milksad]: https://github.com/bitcoinbook/bitcoinbook/commit/76c5ba8000d6de20b4adaf802329b501a5d5d1db#diff-7a291d80bf434822f6a737f3e564be6a67432e2f3f12669cf0469aedf56849bbR126-R134
[bx home]: https://web.archive.org/web/20230319035342/https://github.com/libbitcoin/libbitcoin-explorer/wiki
[bx1]: https://web.archive.org/web/20210122102649/https://github.com/libbitcoin/libbitcoin-explorer/wiki/How-to-Receive-Bitcoin
[bx2]: https://web.archive.org/web/20210122102714/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-mnemonic-new
[bx3]: https://web.archive.org/web/20210506162634/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-hd-new
[seed doc]: https://web.archive.org/web/20210122102710/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-seed
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[bdk 0.28.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.1
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news163 base]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
