---
title: 'Zpravodaj „Bitcoin Optech” č. 253'
permalink: /cs/newsletters/2023/05/31/
name: 2023-05-31-newsletter-cs
slug: 2023-05-31-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu nového protokolu spravovaného
joinpoolu a souhrn nápadu na přeposílání transakcí pomocí protokolu
Nostr. Též nechybí další příspěvek do naší krátké týdenní série
o pravidlech mempoolu a naše pravidelné rubriky se souhrnem zajímavých
otázek a odpovědí z Bitcoin Stack Exchange, seznamem nových softwarových
vydání a popisem významných změn v populárních páteřních bitcoinových
projektech.

## Novinky

- **Návrh na spravovaný joinpool protokol:** tento týden zaslal
  Burak Keceli do emailové skupiny Bitcoin-Dev [příspěvek][keceli ark]
  s popisem nápadu na _Ark_ („Archa”), nový protokol ve stylu
  [joinpoolů][topic joinpools], ve kterém mohou vlastníci bitcoinů
  volitelně využít protistranu jako spolu-podpisovatele všech transakcí
  v rámci určitého časového úseku. Vlastníci mohou své bitcoiny buď
  po uplynutí časového zámku jednostranně vybrat na blockchainu, nebo
  je mohou okamžitě a bez požadavku na důvěru poslat offchain protistraně
  před uplynutím časového zámku.

  Protistrana může, stejně jako jakýkoliv uživatel bitcoinu, kdykoliv
  zveřejnit transakci utrácející pouze její prostředky. Je-li výstup
  této transakce použit jako vstup offchainové transakce přenášející
  prostředky od vlastníka protistraně, bude offchain transfer zneplatněn,
  pokud se onchain transakce nepotvrdí během rozumně stanovené doby.
  V tomto případě by protistrana nepodepsala svou onchain transakci,
  dokud by neobdržela podepsanou offchain transakci. Tento způsob
  poskytuje protokol pro atomický transfer od vlastníka k protistraně
  v jednom směru, s jedním skokem a bez požadavku na důvěru. Keceli
  popisuje tři možnosti použití tohoto protokolu pro atomický transfer:

    - *Míchání mincí:* několik uživatelů v rámci joinpoolu může
      spolu vytvořit atomické výměny svých offchain prostředků za
      novou offchain hodnotu o stejné výši. Jelikož jakákoliv chyba
      v onchain komponentě jednoduše celou výměnu revokuje a všechny
      prostředky vrátí, je tato operace rychlá. Zaslepovací protokol
      podobný protokolu v některých existujících implementacích
      [coinjoinu][topic coinjoin] může zamezit, aby mohl kdokoliv
      spočítat uživateli držené bitcoiny.

    - *Vnitřní transfery:* uživatel může poslat své offchain prostředky
      jinému uživateli v rámci stejné protistrany. Atomicita zajišťuje,
      že buď příjemce dostane své peníze nebo se vrátí odesílateli.
      Příjemci, kteří nedůvěřují ani odesílateli, ani protistraně, budou
      muset čekat na stejné množství konfirmací jako v případě běžné
      onchain transakce.

      Keceli a jeden z diskutujících [odkázali][keceli reply0] na
      [předchozí][harding reply0] výzkum popisující, jak neekonomické
      může být dvojí utrácení zero-conf plateb, pokud jsou spojeny
      s finančním závazkem, který si těžař může v případě dvojího
      utrácení přisvojit. Díky tomu by mohli příjemci akceptovat
      platbu za méně než sekundu i v případě nulové důvěry.

    - *Platba LN faktur:* uživatel se může rychle zavázat k platbě
      offchainových prostředků protistraně, pokud protistrana zná
      tajný kód, což umožní uživateli pomocí protistrany platit
      [HTLC][topic HTLC] faktury podobné LN.

      Ani zde, podobně jako v případě vnitřních transferů, nemůže uživatel
      obdržet prostředky bez požadavku na důvěru, takže by neměl odhalit
      tajný kód, dokud platba neobdrží dostatečné množství potvrzení
      nebo není zabezpečena dostatečným finančním závazkem.

  Keceli tvrdí, že základní protokol může být nad bitcoinem implementován
  již dnes s využitím časté interakce mezi členy joinpoolu. Pokud by byl
  implementován nějaký návrh na [kovenanty][topic covenants] jako např.
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify],
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] nebo [OP_CAT +
  OP_CHECKSIGFROMSTACK][topic op_checksigfromstack], členové joinpoolu
  by museli interagovat s protistranou pouze v coinjoinu, posílání
  platby nebo obnově časového zámku offchainových prostředků.

  Každý coinjoin, platba nebo obnova vyžadují zveřejnění commitmentu
  v onchainové transakci, avšak jedna malá transakce může obsahovat
  v podstatě neomezené množství operací. K zajištění včasného dokončení
  operací navrhuje Keceli, aby byly onchainové transakce posílány každých
  pět sekund. Uživatelé by tak nemuseli čekat déle než tuto dobu. Každá
  transakce je oddělená, není možné zkombinovat commitmenty z několika
  transakcí pomocí [RBF][topic rbf] bez porušení těchto commitmentů
  nebo spolupráce všech uživatelů přítomných v předchozích kolech, a tedy
  přes 6,3 miliónů transakcí by mohlo být potřeba potvrdit každý rok
  pro každou protistranu. Jednotlivé transakce jsou však malé.

  Některé z komentářů zaslaných do emailové skupiny:

    - *Požadavek na dokumentaci:* [přinejmenším][stone reply] dva
      [diskutující][dryja reply] si vyžádali dodatečnou dokumentaci
      o fungování systému. Kvůli úrovni popisu v emailové skupině jej
      nedokázali dostatečně analyzovat. Keceli mezitím začal publikovat
      [návrhy specifikací][arc specs].

    - *Obavy o pomalost v porovnání s LN:* [několik][dryja
      reply] lidí [poznamenalo][harding reply1], že není v prvotním
      designu možné přijímat platbu z joinpoolu bez požadavku na
      důvěru (offchain ani onchain) bez čekání na dostatečné množství
      konfirmací. To může trvat hodiny, kdežto mnoho LN plateb
      je uzavřeno za méně než sekundu. I s finanční pojistkou by byla
      LN obecně rychlejší.

    - *Obavy o dopad na blockchain:* jeden [komentující][jk_14]
      poznamenal, že v případě jedné transakce každý pět sekund by zhruba
      200 protistran zabralo celý prostor v každém bloku. Jiná
      [odpověď][harding reply0] předpokládala, že každá z onchain
      transakcí protistran by byla podobně veliká jako otevírací
      či uzavírací transakce LN. Protistrana s miliónem uživatelů,
      která by vytvářela 6,3 miliónů onchain transakcí za rok, by zabrala
      stejné množství prostoru jako otevírací a zavírací transakce
      6,3 kanálů každého z těchto uživatelů za rok. Onchain náklady
      na LN by tedy byly nižší, avšak pouze do určitého bodu.

    - *Obavy o velikost horké peněženky a kapitálu:* jedna [reakce][harding
      reply0] se zamýšlela nad nutností protistrany držet k dispozici,
      zřejmě v horké peněžence, množství bitcoinů rovné částce, kterou
      mohou uživatelé utratit v dohledné budoucnosti. Dle současného designu
      by po utracení protistrana těmito bitcoiny nemusela disponovat
      až po dobu 28 dní. Pokud by protistrana účtovala nízkou úrokovou
      sazbu 1,5 % za rok, rovnalo by se to 0,125% poplatku z každé transakce
      zprostředkované protistranou (včetně coinjoinů, interních transferů
      a LN plateb). Pro porovnání, [veřejné statistky][1ml stats] dostupné
      v době psaní (poskytnuté 1ML) ukazují, že medián jednotkového
      poplatku za jeden skok LN transferů je 0,0026 %, téměř 50krát nižší.

  Několik komentářů projevilo nad návrhem nadšení a těšilo se na budoucí
  průzkum.

- **Přeposílání transakcí po Nostru:** Joost Jager zaslal do emailové
  skupiny [příspěvek][jager nostr] se žádostí o poskytnutí zpětné vazby
  k nápadu Bena Carmana navrhující použít protokol [Nostr][] k přeposílání
  transakcí, které mají potíže s propagací v bitcoinové P2P síti.

  Konkrétně se Jager zamýšlí nad možností použít Nostr pro přeposílání
  balíčků transakcí, jako je například přeposílání rodičovské transakce
  s příliš nízkým jednotkovým poplatkem spolu s jejím potomkem, který by
  svým poplatkem rodiče kompenzoval. To by učinilo [CPFP][topic cpfp]
  spolehlivějším a efektivnějším pro navyšování poplatků. Tato schopnost
  se nazývá [přeposílání balíčků][topic package relay] („package relay”)
  a vývojáři Bitcoin Core již pracují na její implementaci pro P2P síť.
  Revizi návrhu a implementace přeposílání balíčků ztěžuje nutnost ujistit
  se, že nepřinesou nové možnosti odepření služby (DoS) jednotlivým uzlům
  ani těžařům (nebo obecně celé síti).

  Jager též poznamenal, že přeposílající servery Nostru mají možnost snadno
  používat jiné druhy ochrany proti DoS, jako např. požadavek malé platby.
  To by mohlo učinit přeposílání balíčků či jiných alternativních transakcí
  praktické, i kdyby zlomyslné transakce nebo balíčky vedly k drobnému plýtvání
  zdroji.

  V Jagerově příspěvku nechybí odkaz na [video][jager video], ve kterém
  tuto funkci předvádí. Jeho příspěvek obdržel v době psaní pouze
  několik reakcí, byť pozitivních.

## Čekání na potvrzení 3: aukce blokového prostoru

_Krátká týdenní [série][policy series] o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/03-bidding-for-block-space.md %}

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Testování ořezávací logiky s bitcoind]({{bse}}118159)
  Lightlike poukazuje na debugovací volbu `-fastprune`, která pro testovací
  účely používá menší soubory bloků a nižší minimální ořezávací výšku.

- [Jaká je hlavní motivace existence omezení počtu potomků?]({{bse}}118160)
  Sdaftuar vysvětluje, že jelikož těžba i algoritmy vyloučení z mempoolu
  (viz [zpravodaj č. 252][news252 incentives]) mají kvadratický čas 0(n²)
  závislý na počtu předků nebo potomků, byly zavedeny tyto [konzervativní
  limity][morcos limits].

- [Jak prospívá bitcoinové síti, provozuji-li uzel s větším než výchozím mempoolem?]({{bse}}118137)
  Andrew Chow a Murch poznamenávají potenciální nevýhody mempoolu s větší
  kapacitou než je výchozí nastavení. Mezi ně patří zhoršení propagace
  znovu posílaných transakcí a propagace nahrazovaných transakcí bez signalizace.

- [Jaký je nejvyšší možný počet vstupů a výstupů transakce?]({{bse}}118452)
  Murch poskytuje počty vstupů a výstupů po aktivaci taprootu:
  maximálně 3 223 (P2WPKH) výstupů nebo 1 738 (P2TR keypath) vstupů.

- [Mohou být 2-ze-3 multisig prostředky obdrženy bez jednoho z xpubů?]({{bse}}118201)
  Murch vysvětluje, že multisig sestavy, které nepoužívají holý („bare”) multisig
  nebo které nebyly dříve použité ve stejném multisig výstupním skriptu, musí dát
  pro utracení k dispozici všechny veřejné klíče. Poznamenává, že „zálohy
  multisig peněženek musí zachovat jak soukromé klíče, tak i výstupní skripty“ a
  doporučuje pro skripty používat [deskriptory][topic descriptors].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 25.0][] je vydáním další hlavní verze Bitcoin Core. Vydání
  přidává nové RPC volání `scanblocks`, zjednodušuje používání `bitcoin-cli`,
  přidává do volání `finalizepsbt` podporu [miniscriptu][topic miniscript],
  ve výchozím nastavení snižuje paměťové nároky s aktivovanou volbou `blocksonly`
  a zrychluje reskenování peněženky po aktivaci [kompaktních filtrů bloků][topic
  compact block filters] a další nové funkce, zlepšení výkonnosti a opravy
  chyb. Další podrobnosti lze najít v [poznámkách k vydání][bcc rn].

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27469][] zrychluje prvotní stahování bloků (IBD, „Initial Block
  Download”), pokud jsou používány peněženky. S touto změnou budou transakce
  peněženky v bloku skenovány jen, pokud byl blok vytěžen po vzniku peněženky.

- [Bitcoin Core #27626][] povoluje spojení, které náš uzel požádalo o poskytování
  [přeposílání kompaktních bloků][topic compact block relay] ve velkokapacitním
  režimu, vyžádat až tři transakce z posledního bloku, o kterém jsme toto
  spojení informovali. Náš uzel pošle odpověď, i když jsme jim kompaktní blok
  neposkytli. To umožní spojení, které obdrží kompaktní blok od jiného svého
  spojení, vyžádat od nás kteroukoliv chybějící transakci. To může být užitečné,
  pokud ono jiné spojení nereaguje. Naše spojení může díky tomu validovat blok
  rychleji, a tak jej může dříve použít v časově kritických funkcích, jako je
  těžba.

- [Bitcoin Core #25796][] přidává nové volání `descriptorprocesspsbt`,
  které může být použito k přidání informací do [PSBT][topic psbt],
  které jim později usnadní podepsání nebo finalizování. [Deskriptor][topic
  descriptors] předaný tomuto volání se použije k získání informací z
  mempoolu a množiny UTXO (a také kompletní potvrzené transakce, pokud má
  uzel aktivovánu volby `txindex`). Obdržené informace budou posléze
  použity k doplnění PSBT.

- [Eclair #2668][] zabraňuje Eclairu pokoušet se zaplatit za nárokování [HTLC][topic
  htlc] větší poplatky, než kolik činí hodnota tohoto HTLC.

- [Eclair #2666][] umožňuje vzdálenému spojení přijímajícímu [HTLC][topic htlc]
  jej akceptovat, i kdyby potřebný poplatek za transakci snížil zůstatek na straně
  spojení pod minimální rezervu kanálu. Rezerva kanálu existuje, aby spojení
  ztratilo alespoň malé množství peněz v případě pokusu o zavření kanálu
  se starým stavem. Avšak akceptuje-li spojení HTLC, které mu v případě
  úspěšného vyřešení platí, budou mít více než je rezerva. A v případě
  neúspěchu budou mít stejně jako před HTLC.

  Jedná se o řešení problému uvízlých prostředků, který se objevuje,
  když by strana zodpovědná za placení poplatku musela platit větší
  hodnotu, než je její aktuální zůstatek, i když je tato strana příjemcem
  prostředků. Předchozí diskuzi o tomto problému lze nalézt ve [zpravodaji
  č. 85][news85 stuck funds].

- [BTCPay Server 97e7e][] počíná nastavovat [BIP78][] parametr `minfeerate`
  (minimální jednotkový poplatek) pro [payjoin][topic payjoin] platby.
  Viz též [hlášení o chybě][btcpay server #4689], které vedlo k této změně.

- [BIPs #1446][] činí drobou změnu a několik přídavků do [BIP340][],
  specifikace [Schnorrových podpisů][topic schnorr signatures] pro bitcoinové
  protokoly. Změna povoluje, aby podepisovaná zpráva měla libovolnou
  délku (předchozí verze vyžadovaly 32 bytů). Viz související změna v knihovně
  Libsecp256k1 popsaná ve [zpravodaji č. 157][news157 libsecp]. Změna nemá dopad
  na způsob používání BIP340 v aplikacích, neboť podpisy používané v
  [taprootu][topic taproot] i [tapscriptu][topic tapscript] (BIP
  [341][bip341], resp. [342][bip342]) používají 32bytové zprávy.

  Přidán byl popis efektivního použití zpráv o libovolné délce a doporučení
  o používání hashovaných tagovaných prefixů. Též poskytuje doporučení
  pro zvýšení bezpečnosti během používání stejného klíče v různých doménách
  (např. podepisování transakcí vs. podepisování prostého textu).

{% include references.md %}
{% include linkers/issues.md v=2 issues="27469,27626,25796,2668,2666,4689,1446" %}
[policy series]: /cs/blog/waiting-for-confirmation/
[bitcoin core 25.0]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[1ml stats]: https://1ml.com/statistics
[arc specs]: https://github.com/ark-network/specs
[keceli ark]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021694.html
[keceli reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021720.html
[harding reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021721.html
[harding reply1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021714.html
[stone reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021708.html
[dryja reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021713.html
[jk_14]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021717.html
[jager nostr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021700.html
[jager video]: https://twitter.com/joostjgr/status/1658487013237211155
[news85 stuck funds]: /en/newsletters/2020/02/19/#c-lightning-3500
[btcpay server 97e7e]: https://github.com/btcpayserver/btcpayserver/commit/97e7e60ceae2b73d63054ee38ea54ed265cc5b8e
[news157 libsecp]: /en/newsletters/2021/07/14/#libsecp256k1-844
[bcc rn]: https://bitcoincore.org/en/releases/25.0/
[news252 incentives]: /cs/newsletters/2023/05/24/#čekání-na-potvrzení-2-incentivy
[morcos limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-October/011401.html
