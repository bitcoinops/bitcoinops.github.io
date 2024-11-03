---
title: 'Zpravodaj „Bitcoin Optech” č. 295'
permalink: /cs/newsletters/2024/03/27/
name: 2024-03-27-newsletter-cs
slug: 2024-03-27-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje odhalení útoku plýtvajícího přenosovým pásmem
Bitcoin Core a jeho spojení, popisuje několik vylepšení myšlenky na sponzorování
poplatků transakcí a shrnuje diskuzi o používání živých dat mempoolu k
vylepšení odhadu poplatků v Bitcoin Core. Též nechybí naše pravidelné rubriky
s vybranými otázkami a odpověďmi z Bitcoin Stack Exchange, oznámeními o
nových vydáních a významnými změnami populárních bitcoinových páteřních
projektů.

## Novinky

- **Odhalení free relay útoku:** Peter Todd zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][todd free relay] s popisem
  útoku plýtvajícího přenosovým pásmem, který předtím [zodpovědně nahlásil][topic
  responsible disclosures] vývojářům Bitcoin Core. Ve zkratce: Mallory
  pošle jednu verzi transakce Alici a jinou verzi Bobovi. Transakce jsou
  navrženy tak, aby Bob neakceptoval Alicinu verzi jako [RBF nahrazení][topic
  rbf] a naopak. Mallory nato odešle Alici nahrazení, které ona akceptuje,
  ale Bob ne. Alice přepošle nahrazení Bobovi, které Bob odmítne, což
  vyústí v plýtvání přenosového pásma (tomuto plýtvání se říká [free relay][topic
  free relay], „přeposílání zdarma”). Mallory může postup opakovat několikrát,
  dokud se jeho transakce nepotvrdí. V každém kole cyklu Alice nahrazení
  akceptuje, pošle ji Bobovi (použití přenosového pásma) a ten ji odmítne.
  Následky útoku mohou být znásobeny, pokud by Mallory paralelně posílal několik
  podobně zkonstruovaných transakcí a Alice měla několik spojení tato nahrazení
  odmítajících.

  Útok je omezen náklady na poplatky, které Mallory zaplatí v případě
  potvrzení některé z transakcí. Peter Todd však poznamenává že náklady mohou
  být v podstatě nulové, pokud by Mallory stejně transakci plánoval odeslat.
  Maximální množství přenosového pásma, kterým lze plýtvat, je omezeno
  stávajícími limity přeposílání transakcí v Bitcoin Core, ačkoliv je možné,
  že mnohonásobné paralelní provádění tohoto útoku by zpozdilo propagaci
  legitimních nepotvrzených transakcí.

  Peter Todd též zmiňuje jiný známý druh plýtvání přenosového pásma uzlu,
  při kterém uživatel zveřejní sadu velkých transakcí a poté ve spolupráci
  s těžařem vytvoří blok, který obsahuje relativně malou transakci kolidující
  se všemi přeposlanými transakcemi. Například transakce o velikost 29 000
  vbyte by mohla z mempoolu každého přeposílajícího uzlu odstranit 200 megabajtů
  transakcí. Říká, že existence útoků umožňujících plýtvání přenosového
  pásma znamená, že povolit určité množství přeposílání zdarma by bylo rozumné,
  jak umožňuje například navrhované nahrazování jednotkovým poplatkem (viz
  [zpravodaj č. 288][news288 rbfr]).


- **Vylepšení sponzorování transakčních poplatků:** Martin Habovštiak
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][habovstiak boost] s nápadem
  umožnit transakci zvýšit prioritu jiné, nesouvisející transakce. Fabian Jahr
  [poznamenal][jahr boost], že v jádru je tato myšlenka podobná [sponzorování
  transakčních poplatků][topic fee sponsorship], které v roce 2020 navrhl
  Jeremy Rubin (viz [zpravodaj č. 116][news116 sponsor], _angl._). V Rubinově
  původním návrhu _sponzorující transakce_ zavazovala _posilované transakci_
  pomocí výstupního skriptu nulové hodnoty o velikosti kolem 42 vbyte za
  jedno sponzorství a kolem 32 vbyte za každé dodatečné sponzorství.
  V Haboštiakově verzi zavazuje sponzorující transakce posilované transakci
  pomocí taprootové přílohy ([annex][topic annex]), která používá 8 vbyte
  za jedno sponzorství a 8 vbyte za každé další.

  Záhy po zveřejnění Habovštiakovy myšlenky zaslal David Harding do fóra
  Delving Bitcoin [příspěvek][harding sponsor] s popisem způsobu navýšení
  efektivity, který s Rubinem v lednu vyvinul. Sponzorující transakce zavazuje
  posilované transakci pomocí signature commitment zprávy, která nikdy nebude
  publikována onchain, nezabírá tedy žádný blokový prostor. Sponzorující
  transakce se však musí objevit v blocích a zprávách [přeposílání balíčků][topic
  package relay] okamžitě po posilované transakci. To umožní ověřujícím plným
  uzlům během ověřování sponzorující transakce odvodit txid posilované transakce.

  V případech, kdy by blok obsahoval více sponzorujících transakcí zavazujících
  stejné posilované transakci, by nebylo možné jednoduše umístit sérii posilovaných
  transakcí přímo před jejich sponzory, proto není možné mít kompletně odvoditelné
  závazky. Harding popisuje jednoduchou alternativu, která zabírá
  pouze 0,5 vbyte za posilovanou transakci. Anthony Towns myšlenku dále
  [vylepšuje][towns sponsor]: v jeho verzi by to nikdy nebylo více než 0,5 vbyte
  za posílení, ve většině případů by používala prostoru méně.

  Habovštiak i Harding poukazují na možnost outsourcingu: každý, kdo plánuje
  tak jako tak zveřejnit nějakou transakci (nebo kdo má nepotvrzenou transakci
  a je ochoten ji [nahradit poplatkem][topic rbf]), může navýšit její
  jednotkový poplatek a posílit jinou transakci. Dodatečné náklady by byly
  nízké, pouze 0,5 vbyte či méně za každé posílení. Pro porovnání: 0,5 vbyte
  je kolem 0,3 % transakce s jedním vstupem a dvěma P2TR výstupy. Bohužel,
  jak oba varují, neexistuje pohodlný způsob, kterým za posílení transakce
  třetí straně zaplatit bez požadavku na důvěru. Avšak jak Habovštiak dodává,
  kdokoliv platící přes LN obdrží [doklad platby][topic proof of payment],
  mohl by tedy prokázat podvod.

  Towns dále poznamenává, že sponzorování transakcí se zdá být kompatibilní
  s návrhem [cluster mempoolu][topic cluster mempool] a že nejefektivnější
  verze sponzorování by představovaly drobné potíže při cachování ověřování
  transakcí. Na závěr ukazuje tabulku srovnávající relativní blokový prostor
  spotřebovávaný současnými i navrhovanými technikami navyšování poplatků.
  Lepší než sponzorování s 0,5 vbyte nebo méně za jedno posílení je pouze
  nejlepší scénář s RBF (0 vbyte) a placení těžařům [stranou][topic
  out-of-band fees]. Jelikož sponzorování poplatků umožňuje dynamické
  navyšování a je téměř tak efektivní jako placení stranou, může pomoci
  vyřešit velký problém protokolů, které závisí na [exogenních poplatcích][topic
  fee sourcing].

  V [probíhající diskuzi][daftuar sponsor] zveřejnil krátce před publikováním
  zpravodaje Suhas Daftuar obavy, že sponzorování by mohlo přinést
  problémy, které cluster mempool snadno řešit neumí a které by mohly dále
  způsobit potíže uživatelům, které sponzorování nepotřebují. Naznačil,
  že pokud by bylo sponzorování poplatků do bitcoinu přidáno, mělo by se týkat
  pouze transakcí, které jej povolí.

- **Odhad poplatků založený na mempoolu:** Abubakar Sadiq Ismail
  zaslal do fóra Delving Bitcoin [příspěvek][ismail fees] s popisem vylepšení
  [odhadu jednotkových poplatků][topic fee estimation] v Bitcoin Core pomocí
  dat z lokálního mempoolu. V současnosti Bitcoin Core odhaduje poplatky
  zaznamenáním výšky bloku, kdykoliv se objeví nepotvrzená transakce,
  výšky bloky, když se transakce potvrdí, a jejího jednotkového poplatku.
  Jsou-li všechny tyto informace známy, je rozdíl mezi výškou během přijetí
  a výškou během potvrzení použit k aktualizaci exponenciálně váženého
  klouzavého průměru v různých přihrádkách jednotkových poplatků. Například
  transakce, která dosáhne potvrzení za 100 bloků s jednotkovým poplatkem
  1,1 sat/vbyte, bude zařazena do průměru v přihrádce 1 sat/vbyte.

  Výhodou tohoto přístupu je jeho odolnost vůči manipulaci: všechny
  transakce musí být přeposlány (jsou tedy dostupné všem těžařům) a
  potvrzeny (neporušují pravidla konsenzu). Nevýhodou je, že k aktualizaci
  dochází pouze jednou za blok a může zaostávat za jinými metodami odhadu,
  které používají aktuální informace z mempoolu.

  Ismail se účastnil [předešlé diskuze][bitcoin core #27995] o
  začlenění dat z mempoolu do odhadu poplatku, předběžně napsal nějaký kód
  a provedl analýzu porovnávající současný algoritmus s novým (bez začlenění
  bezpečnostních kontrol). [Jedna odpověď][harding fees] ve vlákně navíc
  odkázala na [předešlé bádání][alm fees] Kalleho Alma a vedla k diskuzi
  o tom, zda by informace z mempoolu měly být použity pro zvyšování i snižování
  odhadů poplatků nebo pouze pro snižování. Výhodou použití pro obě varianty je, že
  díky tomu bude odhad poplatku užitečnější. Výhodou pouze snižování
  (a zvyšování pomocí stávajících odhadů) je, že by bylo odolnější vůči manipulaci
  cyklů s pozitivní odezvou.

  V době psaní zpravodaje diskuze stále probíhala.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jaká rizika přináší provozování předsegwitového uzlu (0.12.1)?]({{bse}}122211)
  Michael Folkson, Vojtěch Strnad a Murch vyjmenovávají nevýhody provozování
  Bitcoin Core 0.12.1 včetně zvýšeného rizika akceptování nevalidní transakce
  či bloku, zvýšené zranitelnosti vůči útokům dvojího utracení, zvýšené
  závislosti na validaci prováděné ostatními účastníky sítě, výrazně pomalejší
  validace bloků, chybějících vylepšení výkonnosti, nemožnosti používat
  [přeposílání kompaktních bloků][topic compact block relay], nemožnosti přeposílat
  kolem 95 % současných nepotvrzených transakcí a zranitelností způsobených (dnes již opravenými)
  bezpečnostními chybami. Uživatelé peněženky v 0.12.1 by také postrádali novinky
  kolem [miniscriptu][topic miniscript], [deskriptorových][topic descriptors] peněženek
  a úspory na poplatcích a další vylepšení skriptovacích možností, které přinesly
  [segwit][topic segwit], [taproot][topic taproot] a [Schnorrovy podpisy][topic schnorr
  signatures]. Mezi dopady na bitcoinovou síť by v případě širšího nasazení Bitcoin Core
  0.12.1 patřily vyšší pravděpodobnost přijetí nevalidních bloků a s ním spojeného
  rizika reorganizací, tlak na centralizaci těžby a snížené odměny těžařům
  provozujícím tuto verzi.

- [Kdy je OP_RETURN levnější než OP_FALSE OP_IF?]({{bse}}122321)
  Vojtěch Strnad ukazuje, jaké náklady přináší šíření dat v `OP_RETURN`
  a v `OP_FALSE` `OP_IF`. Na závěr vysvětluje, že „`OP_RETURN` je levnější
  pro data menší než 143 bajtů.”

- [Proč BIP-340 používá secp256k1?]({{bse}}122268)
  Pieter Wuille vysvětluje důvody zvolení secp256k1 na úkor Ed25519 pro Schnorrovy
  podpisy dle [BIP340][]. Přidává další důvody: „znovupoužitelnost stávající infrastruktury
  odvozování klíčů” a „zachování bezpečnostních předpokladů.”

- [Jaká kritéria používá Bitcoin Core pro tvorbu šablon bloků?]({{bse}}122216)
  Murch vysvětluje stávající algoritmus Bitcoin Core pro výběr transakcí do kandidáta
  na blok založený na jednotkových poplatcích předků. Dále zmiňuje probíhající
  práce na [cluster mempoolu][topic cluster mempool] přinášející rozličná vylepšení.

- [Jak funguje pole initialblockdownload v RPC volání getblockchaininfo?]({{bse}}122169)
  Pieter Wuille vyjmenovává dvě podmínky, které musí být splněny, aby mělo pole `initialblockdownload`
  po spuštění uzlu hodnotu false:

  1. „Současný aktivní řetězec má alespoň tolik kumulativního PoW jako pevně zakódovaná konstanta”
  2. „Časové razítko současného aktivního vrcholu řetězce není více než 24 hodin v minulosti”

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.1rc2][] je kandidátem na vydání údržbové verze této převládající
  implementace plného uzlu.

- [Bitcoin Core 27.0rc1][] je kandidátem na vydání příští hlavní verze této převládající
  implementace plného uzlu. K dispozici je stručný přehled [navrhovaných témat pro testovaní][bcc
  testing] a sezení [Bitcoin Core PR Review Club][] věnované testování je naplánováno
  na 27. březen od 15:00 UTC.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

*Poznámka: commity do Bitcoin Core uvedené níže se vztahují na jeho vývojovou,
master větev. Nebudou tedy pravděpodobně vydány před uplynutím zhruba
šesti měsíců po vydání nadcházející verze 27.*

- [Bitcoin Core #28950][] přidává do RPC volání `submitpackage` parametry
  `maxfeerate` a `maxburnamount`, které vyvolají chybu, pokud by měl poskytnutý
  balíček agregovaný jednotkový poplatek nad stanoveným maximem nebo pokud
  by posílal více než stanovenou hodnotu známému tvaru neutratitelného
  výstupu.

- [LND #8418][] přidává pravidelné načítání hodnot [BIP133][] `feefilter`
  od připojeného bitcoinového klienta. Zpráva `feefilter` umožňuje uzlu
  informovat spojení o nejnižších jednotkových poplatcích, které akceptuje
  pro přeposílání transakcí. LND použije tuto informaci, aby zabránilo
  odesílání transakcí s příliš nízkým poplatkem. Použity jsou pouze hodnoty pro odchozí
  spojení, protože to jsou spojení vybraná a iniciovaná uzlem,
  je tedy menší pravděpodobnost, že jsou pod kontrolou útočníka.

- [LDK #2756][] přidává do svých zpráv podporu pro pakety [trampolínového routování][topic
  trampoline payments]. Nepřidává tím plnou podporu pro používání trampolínového
  routování nebo poskytování jeho služeb, usnadňuje však přidání podpory
  uživatelům LDK.

- [LDK #2935][] přidává podporu pro posílání [keysend plateb][topic
  spontaneous payments] na [zaslepené trasy][topic rv routing]. Keysend platby
  jsou bezpodmínečné platby poslané bez faktury. Zaslepené trasy skrývají
  poslední skoky platební cesty. Zaslepené trasy jsou obvykle zakódovány
  ve faktuře, nejsou tedy obvykle kombinovány s keysend platbami, avšak
  mohou být užitečné v případech, kdy poskytovatel lightningových služeb
  (LSP) nebo nějaký jiný uzel chtějí poskytnout obecnou fakturu pro
  konkrétního adresáta bez odhalení identifikátoru adresátova uzlu.

- [LDK #2419][] přidává automat (state machine) pro [interaktivní konstrukci
  transakcí][topic dual funding], která je nutná pro kanály s dvojí financováním
  a pro [splicing][topic splicing].

- [Rust Bitcoin #2549][] upravuje API pro práci s relativními [časovými zámky][topic
  timelocks].

- [BTCPay Server #5852][] přidává podporu pro skenování animovaných QR kódů BBQr
  (viz [zpravodaj č. 281][news281 bbqr]) pro [PSBT][topic psbt].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28950,8418,2756,2935,2419,2549,5852,27995" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[news281 bbqr]: /cs/newsletters/2023/12/13/#ohlaseno-kodovaci-schema-bbqr
[todd free relay]: https://gnusha.org/pi/bitcoindev/Zfg%2F6IZyA%2FiInyMx@petertodd.org/
[news288 rbfr]: /cs/newsletters/2024/02/07/#navrh-na-nahrazovani-jednotkovym-poplatkem-jako-reseni-pinningu
[habovstiak boost]: https://gnusha.org/pi/bitcoindev/CALkkCJZWBTmWX_K0+ERTs2_r0w8nVK1uN44u-sz5Hbb-SbjVYw@mail.gmail.com/
[jahr boost]: https://gnusha.org/pi/bitcoindev/45ghFIBR0JCc4INUWdZcZV6ibkcoofy4MoQP_rQnjcA4YYaznwtzSIP98QvIOjtcnIdRQRt3jCTB419zFa7ZNnorT8Xz--CH4ccFCDv9tv4=@protonmail.com/
[harding sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696
[news116 sponsor]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[towns sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/5
[ismail fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703
[harding fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703/2
[alm fees]: https://scalingbitcoin.org/stanford2017/Day2/Scaling-2017-Optimizing-fee-estimation-via-the-mempool-state.pdf
[daftuar sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/6
