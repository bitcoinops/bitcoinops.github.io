---
title: 'Zpravodaj „Bitcoin Optech” č. 299'
permalink: /cs/newsletters/2024/04/24/
name: 2024-04-24-newsletter-cs
slug: 2024-04-24-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh na přeposílání slabých bloků za účelem
vylepšení výkonnosti kompaktních bloků v síti s rozmanitými pravidly mempoolu
a oznamuje přidání pětice editorů BIPů. Též nechybí naše pravidelné rubriky
s vybranými otázkami a odpověďmi z Bitcoin Stack Exchange, oznámeními o nových
vydáních a souhrnem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Implementace ověření konceptu slabých bloků:** Greg Sanders zaslal do fóra
  Delving Bitcoin [příspěvek][sanders weak] o použití _slabých bloků_
  (weak blocks) za účelem vylepšení [přeposílání kompaktních bloků][topic
  compact block relay], obzvláště ve stavu roztříštěnosti těžby a pravidel
  pro přeposílání transakcí. Slabý blok je blok po všech stránkách validní,
  který však nemá dostatečný proof of work (PoW) na to, aby se stal příštím blokem.
  Těžaři produkují slabé bloky poměrně k procentu požadovaného PoW každého
  bloku. Například těžař vyprodukuje v průměru devět slabých bloků
  při požadovaných deseti procentech PoW na každý jím vyprodukovaný blok s
  plným PoW.

  Těžaři neví, kdy vyprodukují slabý blok. Každý jejich kandidát na blok
  má shodnou šanci dosáhnout plného PoW; některé z těchto kandidátů se namísto
  toho stanou slabými bloky. Jediným způsobem, jak slabý blok vytvořit, je provádět
  stejnou práci nutnou pro blok s plným PoW. Slabý blok tedy přesně odráží,
  které transakce se těžař pokoušel vytěžit v čase, kdy byl slabý blok vytvořen.
  Například jedinou možností, jak zahrnout nevalidní transakci do slabého bloku,
  je riskovat vytvoření bloku s plným PoW se stejnou nevalidní transakcí.
  Tento nevalidní blok by plné uzly odmítly a těžař by neobdržel odměnu.
  Samozřejmě těžař, který by nechtěl publikovat, jaké transakce se pokoušel
  vytěžit, může jednoduše odmítnout své slabé bloky zveřejnit.

  Díky vysoké obtížnosti vytváření desetiprocentních slabých bloků a vysokým nákladům
  na vytváření slabých bloků s nevalidními transakcemi by byly slabé bloky
  silně odolné vůči útokům odepřením služby, které by se mohly pokusit o plýtvání
  velkého množství šířky pásma uzlu, procesoru a paměti.

  Jelikož jsou slabé bloky standardními bloky s mírně nedostatečným PoW, mají i stejnou
  velikost jako běžné bloky. Když bylo přeposílání slabých bloků před deseti lety
  poprvé popsáno, znamenalo to, že by přeposílání desetiprocentních slabých bloků
  zvýšilo objem dat potřebných pro přeposílání bloků až desetkrát. Avšak před mnoha
  lety začal Bitcoin Core používat přeposílání kompaktních bloků, které v rámci bloku
  nahrazuje transakce krátkými identifikátory. To umožňuje přijímajícímu uzlu vyžádat
  si pouze ty transakce, které zatím neviděl. V běžném případě to snižuje objem přenášených
  dat o více než 99 %. Sanders poznamenává, že by to stejným způsobem fungovalo i
  v případě slabých bloků.

  U bloků s plným PoW nejenže přeposílání kompaktních bloků snižuje nároky na
  přenosové pásmo, ale též výrazně urychluje propagaci bloků. Čím méně dat
  (tedy méně kompletních transakcí) je potřeba poslat, tím rychleji mohou být
  zbývající data poslána. Rychlejší propagace nových bloků je důležitá pro
  decentralizaci těžby: těžař, který nalezne nový blok, může na jeho následníkovi
  začít pracovat okamžitě, ale ostatní těžaři musí čekat, až ze sítě nový blok obdrží.
  To dává výhodu velkým těžařským poolům a vytváří to nezamýšlený druh útoku,
  sobecké těžby (viz [zpravodaj č. 244][news244 selfish]). Tento problém byl před
  příchodem přeposílání kompaktních bloků běžný a vedl k centralizaci těžby do
  velkých poolů a k používání problematických technik, jako je podloudná těžba vedoucí
  v červenci 2015 k [štěpením blokchainu][July 2015 chain forks].

  Přeposílání kompaktních bloků šetří přenosové pásmo a urychluje propagaci
  bloků pouze, pokud příjemce nového bloku již viděl většinu jeho transakcí.
  Avšak jak Sanders poznamenává, někteří těžaři v současnosti vytváří bloky s
  mnoha transakcemi, které se mezi uzly nešíří. To snižuje účinnost přeposílání
  kompaktních bloků a zvyšuje riziko výskytu stejných problémů, které existovaly
  před příchodem kompaktních bloků. Jako řešení navrhuje přeposílání slabých bloků:

  - Těžaři, kteří vytvoří slabé bloky (např. desetiprocentní), by je příležitostně
    přeposlali uzlům. Příležitostně znamená, že by byl přenos považován za
    běžný P2P síťový provoz, podobně jako přeposílání nových, nepotvrzených transakcí,
    a nikoliv jako prioritní provoz, který využívají například nové bloky.

  - Uzly by příležitostně tyto slabé bloky přijaly a validovaly. Ověření PoW
    je triviální a nastalo by okamžitě. Poté by byl blok dočasně uložen v paměti,
    zatímco by byly ověřovány jeho transakce. Validní transakce
    z tohoto slabého bloku by byly přidány do mempoolu. Transakce, které validací
    neprojdou, by byly uloženy do vyhrazené mezipaměti. Podobné mezipaměti již
    Bitcoin Core používá k dočasnému uložení transakcí, které do mempoolu přidány
    být nemohou (např. mezipaměť osiřelých transakcí).

  - Další příchozí slabé bloky by mempool a mezipaměť aktualizovaly.

  - Když uzel pomocí kompaktního přeposílání obdrží blok s plným PoW, mohl
    by využít transakce uložené v mempoolu a mezipaměti slabých bloků.
    Potřeba další prodlevy a přenosového pásma by tak byla minimalizovaná.
    Díky tomu by mohla síť, ve které se vyskytuje mnoho uzlů s roztříštěnými
    pravidly, i nadále využívat výhod kompaktních bloků.

  Dále Sanders poukazuje na předchozí diskuzi o slabých blocích (viz
  [zpravodaj č. 173][news173 weak], _angl._) popisující, jak by mohly slabé
  bloky pomoci v boji proti [pinningovým útokům][topic transaction pinning]
  a ve vylepšení [odhadu poplatků][topic fee estimation]. Používání slabých bloků
  bylo též dříve zmíněno v diskuzi o přeposílání transakcí protokolem Nostr
  (viz [zpravodaj č. 253][news253 weak]).

  Sanders napsal „základ [ověření konceptu][sanders poc] s jednoduchými testy,
  které ukazují jádro myšlenky.“ Diskuze v době psaní zpravodaje nadále
  probíhala.

- **Aktualizace o editorech BIPů:** po veřejné diskuzi (viz zpravodaje
  [č. 292][news292 bips], [č. 296][news296 bips] a [č. 297][news297 bips]) byli
  [představeni][chow editors] noví editoři BIPů: Bryan „Kanzure“ Bishop,
  Jon Atack, Mark „Murch” Erhardt, Olaoluwa „Roasbeef” Osuntokun a
  Ruben Somsen.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Kde přesně je ve výpočtu obtížnosti off-by-one chyba?]({{bse}}20597)
  Antoine Poinsot vysvětluje off-by-one chybu (o jedničku vedle) ve výpočtu
  nové hodnoty obtížnosti, která umožňuje [útok ohýbáním času][topic time warp]
  („time warp attack”). Tuto chybu se snaží adresovat návrh na [pročištění konsenzu][topic consensus
  cleanup] (viz [zpravodaj č. 296][news296 cc]).

- [Jak je z vývojářova pohledu v používání opkódů odlišné P2TR oproti P2PKH?]({{bse}}122548)
  Murch usuzuje, že by skript z příkladu použitý jako P2PKH výstup byl nestandardní
  a dražší než P2TR, ale validní z pohledu konsenzu.

- [Jsou nahrazující transakce větší než jejich předchůdci a neRBF transakce?]({{bse}}122473)
  Vojtěch Strnad poznamenává, že transakce signalizující [RBF][topic rbf] mají stejnou
  velikost jako nesignalizující transakce. Dále uvádí scénáře, ve kterých by nahrazující
  transakce mohla být buď stejně velká, větší či menší než původní, nahrazovaná transakce.

- [Jsou bitcoinové podpisy stále zranitelné opakovaným používáním nonce?]({{bse}}122621)
  Pieter Wuille potvrzuje, že [Schnorrovy podpisy][topic schnorr signatures] i ECDSA
  podpisy – včetně jejich [multisig][topic multisignature] variant – jsou zranitelné
  vůči opakovanému používání nonce.

- [Jak těžaři ručně přidávají transakce do šablony bloku?]({{bse}}122725)
  Ava Chow nastiňuje odlišné přístupy, kterých by těžař mohl využít k začlenění
  transakcí do bloku, které by v něm po použití volání Bitcoin Core `getblocktemplate`
  jinak chyběly:

  - voláním `sendrawtransaction` přidat transakci do těžařova mempoolu a nato
    upravit její [zjevný absolutní poplatek][prioritisetransaction fee_delta]
    pomocí `prioritisetransaction`
  - použít upravenou implementaci `getblocktemplate` nebo zvláštní software pro
    tvorbu bloků

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.17.5-beta][] je údržbovým vydáním, které přináší kompatibilitu s
  Bitcoin Core 27.x.

  Jak bylo vývojářům LND [reportováno][lnd #8571], starší verze LND závisející
  na starší verzi [btcd][] zamýšlela nastavit maximální jednotkový
  poplatek na 10 miliónů sat/kB (0,1 BTC/kB). Avšak Bitcoin Core vyžaduje
  jednotkové poplatky v BTC/kvB; maximální jednotkový poplatek byl tedy
  nastaven na 10 miliónů BTC/kvB. Bitcoin Core 27.0 obsahuje [PR][bitcoin core #29434],
  které omezuje maximální jednotkový poplatek na 1 BTC/kvB, aby předešel
  některým problémům. Předpokládá, že pokud by někdo nastavoval vyšší
  hodnotu, pravděpodobně by to bylo kvůli chybě (pokud by opravdu vyšší hodnotu
  zamýšlel, mohl by nastavit parametr na 0 a tím kontrolu obejít). V tomto případě
  LND (via btcd) opravdu chybu činilo, ale změna v Bitcoin Core zabraňovala LND
  v odesílání onchain transakcí. To může být pro LN uzel nebezpečné, neboť někdy
  spoléhá na časově citlivé transakce. Toto údržbové vydání správně nastavuje
  maximální hodnotu na 0,1 BTC/kvB v souladu s novými verzemi Bitcoin Core.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29850][] omezuje maximální počet IP adres akceptovaný od jednoho
  DNS seedu na 32 na dotaz. Při dotazování DNS přes UDP omezuje maximální velikost
  paketu tento počet na 33, avšak alternativní dotazování DNS přes TCP může nyní
  vrátit mnohem vyšší počet výsledků. Aby posbíraly IP adresy, připojují se nové uzly
  k několika DNS seedům. Poté náhodně vyberou některé z těchto adres a připojí
  se k nim. Pokud tento uzel obdrží od každého seedu zhruba stejný počet IP adres,
  je nepravděpodobné, že by všechny zvolené uzly, ke kterým se připojí, pocházely
  od stejného seedu. To napomáhá zajisti, aby měl uzel rozmanitý pohled na síť
  a nebyl náchylný k [útokům zastíněním][topic eclipse attacks].

  Avšak pokud by některý ze seedů vrátil mnohem větší počet IP adres než ostatní,
  existovala by vysoká pravděpodobnost, že by tento uzel náhodně zvolil množinu
  IP adres pocházejících právě od toho seedu. Pokud by měl tento seed zlé úmysly,
  mohl by uzel izolovat od čestné sítě. [Testování][bitcoin core #16070] ukázalo,
  že všechny seedy v té době vracely 50 či méně výsledků, ačkoliv byl maximální
  povolený počet 256. Toto začleněné PR omezuje maximální počet na podobnou velikost,
  kterou současné seedy vrací.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8571,29434,29850,16070" %}
[sanders weak]: https://delvingbitcoin.org/t/second-look-at-weak-blocks/805
[news173 weak]: /en/newsletters/2021/11/03/#feerate-communication
[news253 weak]: /cs/newsletters/2023/05/31/#preposilani-transakci-po-nostru
[sanders poc]: https://github.com/instagibbs/bitcoin/commits/2024-03-weakblocks_poc/
[july 2015 chain forks]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[selfish mining attack]: https://bitcointalk.org/index.php?topic=324413.msg3476697#msg3476697
[news244 selfish]: /cs/newsletters/2023/03/29/#bitcoin-core-27278
[btcd]: https://github.com/btcsuite/btcd/pull/2142
[chow editors]: https://gnusha.org/pi/bitcoindev/CAMHHROw9mZJRnTbUo76PdqwJU==YJMvd9Qrst+nmyypaedYZgg@mail.gmail.com/T/#m654f52c426bd5696d88668b3bff25197846e14af
[news292 bips]: /cs/newsletters/2024/03/06/#diskuze-o-pridani-dalsich-editoru-bipu
[news296 bips]: /cs/newsletters/2024/04/03/#vyber-novych-editoru-bipu
[news297 bips]: /cs/newsletters/2024/04/10/#aktualizace-bip2
[LND v0.17.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.5-beta
[news296 cc]: /cs/newsletters/2024/04/03/#navrat-k-tematu-procisteni-konsenzu
[prioritisetransaction fee_delta]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html#argument-3-fee-delta
[taproot nonces]: /en/preparing-for-taproot/#multisignature-nonces
