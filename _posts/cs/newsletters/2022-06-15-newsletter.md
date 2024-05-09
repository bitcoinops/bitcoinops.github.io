---
title: 'Zpravodaj „Bitcoin Optech” č. 204'
permalink: /cs/newsletters/2022/06/15/
name: 2022-06-15-newsletter-cs
slug: 2022-06-15-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden shrnujeme pokračování diskuze o přidání přeposílání
balíčků do bitcoinové P2P sítě, přinášíme přehled o nedávném
sezení vývojářů LN a popisujeme argumentaci pro mechanismus, kterým
by mohli plátci a routovací uzly LN optimalizovat spolehlivost i
nízké poplatky způsobem vyhovujícím oběma skupinám.
Nechybí naše pravidelné rubriky se seznamem nových softwarových vydání
a popisem významných změn v populárních bitcoinových infrastrukturních
projektech.

## Novinky

- **Pokračuje debata o přeposílání balíčků:** nedávný návrh BIP pro
  [přeposílání balíčků][topic package relay] („package relay”, viz
  [zpravodaj č. 201][news201 relay]) obdržel v posledních několika
  týdnech další komentáře:

  - *Limity:* Anthony Towns [se ptal][towns relay], zda
        by vyjednávání mezi dvěma spojeními o podpoře přeposílání balíčků
        nemělo obsahovat informace o nastaveních omezení velikosti a hloubky,
        jinak by mohly uzly s nestandardním nastavením plýtvat datovým tokem
        opakovanými oznámeními o balíčcích, které nevyžadovaly. Autorka BIP
        Gloria Zhao [navrhuje][zhao negotiation], aby první verze protokolu
        implikovala maximální velikost balíčku 25 transakcí a 101 000 vbyte.

  - *Zpráva pouze s grafem balíčku:* Eric Voskuil [doporučuje][voskuil graph],
        aby spojení, které se dozví o transakci s vysokým poplatkem, která je
        potomkem transakce s nízkým poplatkem, jen informovalo svá
        spojení o vztahu mezi těmito dvěma transakcemi (tento vztah se nazývá
        graf baličku). Příjemce by si potom mohl vyžádat transakce, které nemá.
        V jiné části tohoto vlákna Towns [poznamenal][towns graph], že graf
        nemůže být validován, dokud nebyly obdrženy všechny transakce. Musí se
        tedy zajistit, aby spojení nemohla o grafu lhát za účelem zabránit
        šíření transakce.

  - *Používání krátkých ID:* několik vývojářů navrhlo používat krátké
        identifikátory ve stylu [BIP152][]. Zhao [vysvětlila][zhao sids],
        že krátká ID by měla smysl pro přeposílání bloků, kde uzly nejdříve
        validují proof of work nového bloku (jehož vytvoření je nákladné),
        aby bylo pro útočníka nákladné zneužít tohoto mechanismu k plýtvání
        zdrojů. Avšak pro přeposílání dat, která lze vytvářet snadno, by
        mohla být krátká ID zneužita znova a znova, což by umožnilo
        DoS útok.

  - *Nestandardní rodiče:* Suhas Daftuar [popisuje][daftuar repeat]
        scénář, ve kterém by mohl uzel implementující přeposílání balíčků
        dokola vyžadovat stejná data. To by se mohlo stát hlavně v případě,
        kdy se pravidla přeposílání liší mezi staršími a novějšími uzly,
        například po aktivaci soft forku.

  - *Těžkosti s oznamováním hashe bloku:* Daftuar také poznamenává,
        že jedna z vlastností návrhu by mohla způsobit potíže jinému software.
        Podle současného návrhu BIP se do každého oznámení o balíčku vkládá
        hash bloku, který je pro uzel nejnovější. Umožňuje to příjemci
        ignorovat balíčky týkající se starších bloků (nebo i jiného
        block chainu). V takovém případě by balíček nemusel správně fungovat
        s příjemcovým mempoolem. Jak však poznamenává Daftuar, pravděpodobně
        existuje množství software, které odesílá transakce (a které by
        nakonec posílalo i balíčky), ale neudržuje si přehled o hashi
        nejnovějšího bloku.

- **Shrnutí sezení vývojářů LN:** Olaoluwa Osuntokun poskytl
  [podrobné shrnutí][osuntokun summary] sezení vývojářů LN, které se konalo
  minulý týden v Oaklandu. Probíraná témata:

  - *Taprootové LN kanály:* účastníci debatovali o první krocích přechodu
        LN k plnému využití schopností [taprootu][topic taproot]. Následovat
        bude zřejmě začlenění podpory pro [PTLC][topic ptlc][^ptlc] (viz též
    [zpravodaj č. 164][news164 taproot ln], *angl.*).

  - *Tapscript a MuSig2[^musig2]:* součástí přechodu na taprootové
        kanály je také převod současných skriptů na taprootové způsobem,
        který by nejefektivněji využíval blokový prostor. Žádoucí by též
        bylo používat [MuSig2][topic musig] pro tvorbu podpisů v místech,
        kde se předpokládá spolupráce obou podepisujících. Obě tyto potřeby musí
        být naimplementovány a řádně otestovány.

  - *Rekurzivní MuSig2:* jednoduchá implementace MuSig2 umožňuje Alici
        a Bobovi se společně podílet na tvorbě podpisu. Rekurzivní MuSig2 by
        například umožnil Alici vytvořit svou část podpisu za použití své
        horké peněženky i hardwarového podepisujícího zařízení, aniž by
        Bob musel učinit jakékoliv zvláštní kroky či vůbec tušil, že Alice
        podepsala více než jedním klíčem. Diskutováno bylo, jak navrhnout
        použití MuSig2 v LN tak, aby byl rekurzivní MuSig2 k dispozici.
        Probírána byla také bezpečnost rekurzivního MuSig2.

  - *BOLT jako rozšíření:* alternativní způsob změn specifikace
    protokolu LN. V současnosti se specifikace mění aplikací patche
        (diff) na existující specifikaci. Avšak někteří vývojáři preferují
        způsob použitý u BIP, kde jsou významné změny protokolu specifikovány
        v jednom či více dedikovaných dokumentech. Tito vývojáři věří, že
        oddělené dokumenty se snáze čtou i píší a mohly by tak
        zjednodušit a zrychlit vývoj.

  - *Aktualizace gossip protokolu:* pokračovalo se v existující
        debatě o aktualizaci LN gossip protokolu (viz [zpravodaj č. 188][news188
    gossip], *angl.*), který se používá pro přeposílání oznámení o nových
        a pozměněných kanálech. Dle shrnutí by účastníci sezení upřednostňovali
        soustředit se v blízké budoucnosti na drobnější změny protokolu:
        podpora taprootových kanálů s MuSig2 a plné využití [TLV][news55 tlv][^tlv].

  - *Efektivní gossip s minisketchem:* jak bylo zmíněno ve [zpravodaji č. 198][news198
        minisketch], pokračuje zkoumání použití knihovny [minisketch][topic minisketch]
        s cílem snížit datové nároky LN gossip protokolu mezi uzly, což
        by také mohlo snížit nejnižší povolenou dobu mezi aktualizacemi.

  - *DoS onion zpráv:* několik implementací LN již podporuje [onion zprávy][topic
        onion messages] jako alternativu k posílání zpráv použitím [keysend][topic
        spontaneous payments] plateb i jako komunikační vrstvu pro navrhovaný
        [BOLT12 protocol][topic offers] pro nabídky. Avšak jak bylo zmíněno
        ve [zpravodaji č. 190][news190 onion] (*angl.*), někteří vývojáři
        se obávají, že onion zprávy mohou být zranitelné vůči několika
        typům DoS útoků. Několik způsobů ochrany proti DoS bylo diskutováno.

  - *Zaslepené cesty:* mechanismus („blinded paths”) navržený před několika
        lety (viz [zpravodaj č. 85][news85 blinded], *angl.*) a dnes používaný
        pro onion zprávy je předmětem experimentů pro použití s běžnými platbami.
        Umožnil by tím přijímat platby, aniž by byla odhalena identita adresátova
        LN uzlu. Výzvou toho přístupu je nutnost komunikace většího množství
        routovacích informací, vyžadovány jsou tedy objemnější faktury. Efektivní
        implementace tak může záviset na novějších protokolech jako BOLT12
        nabídky nebo [LNURL][]. Diskutováno bylo také několik dalších
        obav.

  - *Sondování a sdílení zůstatku:* použitím různých technik je možné
        *vysondovat* zůstatky na kanálech v síti. Toto sondování lze provádět
        v podstatě zdarma, ale může vedle ztráty soukromí způsobit potíže i
        běžným uživatelům sítě. Opatření proti nesouvisejícímu [útoku
        zahlcením kanálu][topic channel jamming attacks] („channel jamming
        attack”) mohou pomoci omezit sondování, ale v současnosti stále
        budí obavy. Účastníci diskutovali o některých rychlých změnách
        nastavení uzlu, které by mohly sondování ztížit.

    Jeden myšlenkový experiment, o kterém se již dříve diskutovalo,
        se zabýval sdílením informací, které by bylo možné získat sondováním.
        Kdyby tak činil každý uzel, datové nároky a ztráta soukromí by
        znegovaly hlavní výhody LN, ale zefektivnilo by to routování
        plateb. Nikdo tuto myšlenku nenavrhuje, ale diskutovalo se o
        dřívějším nápadu, že by každý uzel sdílel tyto informace pouze
        se svými kanály. Někteří tvrdili, že by to mohlo významně navýšit
        podíl úspěšných plateb, například doplněním o [Just-In-Time (JIT)
        vyrovnání zůstatků][topic jit routing].

  - *Trampolínové routování a mobilní platby:*
        [trampolínové routování][topic trampoline payments] umožňuje plátci
        delegovat hledání cesty na jiný uzel v síti bez ztráty soukromí (např.
        odhalením plátce a adresáta). Toto delegování je užitečné především
        pro mobilní LN klienty, které se nesnaží přeposílat jiné platby
        pro jiné uzly. Bylo zmíněno, že trampolínové platby by mohly být
        zkombinovány se *zadržením platby prvním bodem cesty*
    (viz [zpravodaj č. 171][news171 ln offline], *angl.*), kde je
        platba pozastavena uzlem, se kterým má plátce otevřený kanál, do doby,
        než je příjemce online. To by umožňovalo mobilním uzlům, které
        jsou často offline, spolehlivě přijímat platby od jiných mobilních
        uzlů.

  - *LNURL s BOLT12:* LNURL protokol umožňuje uzlu vyžádat si [BOLT11][]
        fakturu z webového serveru. BOLT12 [nabídky][topic offers] umožňují
        vyžádat si fakturu z uzlu sítě. Mezi jinými aspekty těchto protokolů
        diskutovali účastníci, jak by mohly být tyto dva protokoly navzájem
        kompatibilní, aby mohly uzly používat oba dva.

- **Signalizace likvidity routovacími poplatky:** vývojář ZmnSCPxj
  poslal do emailové skupiny Lightning-Dev [příspěvek][zmnscpxj hilolohi]
  s tezí, jak by bylo možné optimálně dosáhnout levných a spolehlivých
  plateb díky aplikaci teorie her na chování plátců a routovacích uzlů:

  - Plátci by měli volit cesty s nižšími routovacími poplatky.

  - Routovací uzly by měly se snižující se kapacitou kanálu žádat
    vyšší poplatky. Například pokud je většina zůstatku kanálu na straně
    Alice, může spolehlivě přeposílat platby Bobovi a tak by nemusela
    žádat vysoké poplatky. Ale jak se zůstatek kanálu přelévá směrem
    k Bobovi, schopnost Alice přeposílat platby se snižuje; měla by
    si tedy nechat platit více na poplatcích.

  ZmnSCPxj argumentuje ekonomií nabídky a poptávky: se zvyšující se
  poptávkou po platbách jedním směrem (např. od Alice k Bobovi) se nabídka
  satoshi, která může být přeposílána tímto směrem, přirozeně
  snižuje. Zvýšení ceny ve formě routovacích poplatků může snížit poptávku
  do doby, než se nabídka opět zvýší díky lidem posílajícím platby v
  opačném směru (tedy od Boba k Alici).

  Plátci již mají přirozené incentivy používat nižší poplatky, proto
  ZmnSCPxj tvrdí, že uzel, který si osvojí strategii vysoká nabídka/nízké poplatky
  a nízká nabídka/vysoké poplatky, bude automaticky udržovat své kanály
  rozumně vyvážené a bude tak schopen provést větší množství úspěšných
  plateb než uzel, který tuto strategii nepoužívá. Protože routovací uzly
  dostávají zaplaceno jen za úspěšnou platbu, mohlo by to tomuto uzlu
  přinést výhody.

  Hlavní výhoda tohoto přístupu spočívá v tom, že usnadňuje platcům
  hledání cesty – potřebují jen následovat cestu nejnižších poplatků.
  Nevýhodou je, že každá změna poplatku routovacího uzlu implikuje
  změnu zůstatku kanálu; indikuje tím tedy velikost plateb, které
  kanálem protékají. Například pokud kanály Alice→Bob, Bob→Carol a
  Carol→Dan všechny právě snížily kapacitu o zhruba 1 BTC, lze se domnívat,
  že buď Alice nebo druhá strana některého z jejích kanálů přeposlaly
  Danovi nebo druhé straně některého z jeho kanálů 1 BTC. Dalším problémem
  je, že každá změna poplatků kanálu musí být rozeslána po celé síti, což
  zvyšuje datové nároky a může také způsobit selhání routování (např.
  pokud Sally ještě neslyšela o Aliciných nově zvýšených poplatcích a
  pokusí se použít kanál od Alice k Bobovi za použití staršího a nižšího
  poplatku, který Alice odmítne).

  Pro snížení rizik těchto problémů nabízí ZmnSCPxj několik strategií, z nichž
  některé nevyžadují změnu LN protokolu a mohou být uzly implementovány již nyní
  a jiné by vyžadovaly drobné úpravy gossip protokolu. V době psaní tohoto článku
  neobdržely ještě tyto strategie žádné komentáře, avšak byly zmíněny ve
  shrnutí Olaoluwy Osuntokuna (které náš zpravodaj popisuje v předchozím bodě).

## Vydání nových verzí

*Vydání nových verzí populárních bitcoinových infrastrukturních projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.15.0-beta.rc6][] je kandidátem na vydání příští verze tohoto oblíbeného LN uzlu.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24171][] upravuje chování prvotního stahování bloků („Initial
  Block Download”, IBD) tak, aby vyžadovalo data bloků z příchozích spojení,
  pokud žádné z odchozích spojení data bloků nenabízí. Dříve uzel žádal data
  od příchozích spojení pouze, neměl-li vůbec žádné odchozí spojení. Toto chování
  mohlo způsobit patovou situaci v případě, kdy žádné z odchozích spojení uzlu
  nenabízelo bloky. Uzly stále budou vyžadovat data pouze od odchozích spojení,
  jakmile některé z nich začne bloky nabízet.

- [BDK #593][] začíná používat [rust bitcoin][rust bitcoin repo] 0.28,
  které obsahuje podporu pro [taproot][topic taproot] a taprootové
  [deskriptory][topic descriptors].

## Poznámky a vysvětlivky

[^ptlc]: [PTLC][topic ptlc] („Point Time Locked Contracts”) jsou podmíněné platby, které by v budoucnu mohly nahradit současné HTLC („Hash Time Locked Contracts”)
[^musig2]: [MuSig2][topic musig] je protokol pro agregaci veřejných klíčů a podpisů za použití Schnorrova algoritmu
[^tlv]: TLV (type, length, value) je volitelné datové pole s flexibilním obsahem. Jelikož každé pole je uvozeno typem, může software ignorovat ty, kterým nerozumí

{% include references.md %}
{% include linkers/issues.md v=2 issues="24171,1505,628,593" %}
[lnd 0.15.0-beta.rc6]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc6
[news201 relay]: /cs/newsletters/2022/05/25/#navrh-na-preposilani-balicku
[towns relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020496.html
[zhao negotiation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020512.html
[voskuil graph]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020518.html
[towns graph]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020520.html
[zhao sids]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020539.html
[daftuar repeat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020542.html
[osuntokun summary]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003600.html
[news164 taproot ln]: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot
[news188 gossip]: /en/newsletters/2022/02/23/#updated-ln-gossip-proposal
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[news198 minisketch]: /cs/newsletters/2022/05/04/#ln-a-zestihleni-gossip-protokolu-gossip
[news190 onion]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[news85 blinded]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[news171 ln offline]: /en/newsletters/2021/10/20/#paying-offline-ln-nodes
[zmnscpxj hilolohi]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003598.html
