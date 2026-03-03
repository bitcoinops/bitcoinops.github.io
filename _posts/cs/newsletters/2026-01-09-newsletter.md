---
title: 'Zpravodaj „Bitcoin Optech” č. 387'
permalink: /cs/newsletters/2026/01/09/
name: 2026-01-09-newsletter-cs
slug: 2026-01-09-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden varuje před chybou v migraci peněženek v Bitcoin Core,
shrnuje příspěvek o používání protokolu Ark jako továrny LN kanálů a odkazuje
na návrh BIPu pro deskriptory tichých plateb. Též nechybí naše pravidelné
rubriky s popisem kandidátů na vydání a významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Chyba v migraci peněženky v Bitcoin Core**: Bitcoin Core zveřejnil
  [poznámku][bitcoin core notice] o chybě v procesu migrace zastaralého druhu
  peněženek ve verzích 30.0 a 30.1. Pokud se uživatelé zastaralých peněženek v Bitcoin
  Core, kteří používají nepojmenovanou peněženku a dosud nemigrovali
  na deskriptorovou peněženku, pokusí o migraci v těchto verzích, mohl
  by jejich adresář s peněženkami být smazán, což by mohlo vést až ke ztrátě
  prostředků. Tito uživatelé by se neměli pokoušet o migraci prostřednictvím
  grafického rozhraní či RPC, dokud nebude vydána verze 30.2 (viz [Bitcoin Core
  30.2rc1](#bitcoin-core-30-2rc1) níže). Uživatelé, kteří se na migraci
  zastaralého druhu peněženky nechystají, mohou nadále bez obav tyto verze používat.

- **Ark jako továrna kanálů**:
  René Pickhardt [popsal][rp delving ark cf] ve fóru Delving Bitcoin své myšlenky a
  diskuzi nad otázkou, zda [Ark][topic ark] není vhodnější jako flexibilní
  [továrna kanálů][topic channel factories] než jako řešení poskytující platby
  přímo koncovým uživatelům. Pickhardtův dřívější výzkum se soustředil na optimalizaci
  úspěšnosti plateb v Lightning Network pomocí [hledání tras][news333 rp routing] a
  [rebalancování kanálů][news359 rp balance]. Struktury ve stylu Arku obsahující
  lightningové kanály byly již dříve popsané např. v [1][optech superscalar],
  [2][news169 jl tt] a [3][news270 jl cov].

  Pickhardtovy myšlenky se soustředí na možnost dávkově provádět množství operací
  měnících likviditu kanálů (tedy otevření a zavření kanálů a splicing)
  používáním struktury vTXO jako způsobu výrazného snížení onchain nákladů na
  provozování Lightning Network. Cenou by byly vyšší nároky na likviditu v čase mezi
  zřeknutím se jednoho kanálu a kompletní expirací jeho arkové dávky.
  Používáním arkových dávek jako efektivních továren kanálů by mohli poskytovatelé
  lightningových služeb (LSP) účinněji poskytovat likviditu více konečným uživatelům.
  Vestavěná expirace těchto dávek by zaručila, že LSP může získat zpět
  likviditu z nepoužívaného kanálu bez nutnosti provést nákladný onchain
  proces vynuceného zavření kanálu. Pro routovací uzly by byla výhodná možnost
  v pravidelných dávkách přesouvat likviditu mezi jednotlivými kanály bez nutnosti
  provádět jednotlivé splicingové operace.

  Greg Sanders se v [odpovědi][delving ark hark] vyjádřil, že se zabývá podobnými možnostmi,
  konkrétně jak pomocí [hArku][sr delving hark] provádět (převážně) online
  přesuny stavu lightningového kanálu mezi dávkami. hArk by vyžadoval [CTV][topic
  op_checktemplateverify], `OP_TEMPLATEHASH`nebo podobný opkód.

- **Návrh BIPu pro deskriptory tichých plateb**: Craig Raw zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][sp ml] s [návrhem BIPu][BIPs #2047], který definuje `sp()`,
  nový deskriptor pro výstupní skripty nejvyšší úrovně pro [tiché platby][topic silent
  payments]. Dle Rawa poskytuje standardizovaný způsob reprezentace výstupů
  tichých plateb v rámci výstupních deskriptorů.

  Výraz `sp()` vyžaduje jako argument jeden ze dvou výrazů určujících klíč:

  - `spscan1q..`: Soukromý klíč pro skenování a veřejný klíč pro utrácení kódované
    pomocí [bech32m][topic bech32]; znak `q` reprezentuje tiché platby verze `0`.

  - `spspend1q..`: Soukromý klíč pro skenování a soukromý klíč pro utrácení kódované
    pomocí bech32m;  znak `q` reprezentuje tiché platby verze `0`.

  Volitelně lze do `sp()` přidat další argumenty: `BIRTHDAY`, definovaný jako kladné
  celé číslo reprezentující výšku bloku, při které by skenování mělo začít
  (musí být vyšší než 842 579, tj. výška, při které byl [BIP352][] začleněn),
  a libovolné množství argumentů `LABEL` jako celých čísel používaných peněženkou.

  Výstupní skripty vytvořené deskriptorem `sp()` tvoří taprootové výstupy dle [BIP341][]
  specifikované v BIP352.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 30.2rc1][] je kandidátem na vydání menší verze opravující
  chybu (viz [Bitcoin Core #34156](#bitcoin-core-34156)), která mohla během
  migrace nepojmenované zastaralé peněženky smazat celý adresář `wallets`
  (viz [výše](#chyba-v-migraci-penezenky-v-bitcoin-core)).

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #34156][] a [Bitcoin Core #34215][] opravují chybu ve verzích 30.0
  a 30.1, která mohla způsobit nezamýšlené smazání celého adresáře `wallets`.
  Pokud migrace zastaralé, nepojmenované peněženky selže, měla by čisticí funkce
  odstranit pouze nově vytvořený adresář [deskriptorové][topic descriptors]
  peněženky. Jelikož je však nepojmenovaná peněženka uložena na nejvyšší
  úrovni v adresáři `wallets`, je smazán celý adresář. Druhá změna se týká podobné
  chyby v případě použití příkazu `createfromdump` nástroje `wallettool`
  (viz též zpravodaje [č. 45][news45 wallettool] a [č. 130][news130 createfrom],
  oba _angl._), je-li název peněženky prázdný řetězec a soubor má
  nesprávný kontrolní součet. Obě opravy zajišťují, že jsou smazány pouze
  nově vytvořené soubory.

- [Bitcoin Core #34085][] integruje dosud samostatnou funkci `FixLinearization()`
  do `Linearize()`. `TxGraph` nově odloží fixaci clusterů (tedy úpravu linearizace tak,
  aby respektovala topologický řád) až do doby jejich první relinearizace.
  Počet volání `PostLinearize` se tak sníží, neboť algoritmus linearizace koster
  grafu (spanning-forest linearization, SFL; viz též [zpravodaj č. 386][news386 sfl])
  provádí během načítání stávající linearizace podobnou operaci. Jedná se o
  součást projektu [mempoolu clusterů][topic cluster mempool].

- [Bitcoin Core #34197][] odstraňuje z RPC odpovědi na `getpeerinfo` pole
  `startingheight`, čímž ho prakticky zastarává. Toto pole je možné opět
  zobrazit přidáním volby `deprecatedrpc=startingheight`. Pole `startingheight`
  nastavuje druhá strana na výšku řetězce v okamžiku navázání spojení. Toto zastarání
  je založeno na myšlence, že počáteční výška uvedená ve zprávě `VERSION`
  od peer spojení je nespolehlivá. V příští hlavní verzi bude pole zcela odstraněno.

- [Bitcoin Core #33135][] přidává varování, pokud je příkaz `importdescriptors`
  volán s [miniscriptovým][topic miniscript] [deskriptorem][topic descriptors],
  který v `older()` (určujícím [časový zámek][topic timelocks]) obsahuje hodnotu,
  jež v rámci konsenzu dle [BIP68][] (relativní časové zámky) a [BIP112][] (OP_CSV)
  nedává smysl. Ačkoliv některé protokoly, jako je např. Lightning Network,
  záměrně přiřazují nestandardním hodnotám nový význam, je tato praxe považována
  za riskantní, neboť taková hodnota se může jevit jako dlouhodobý časový zámek,
  ačkoliv ve skutečnosti neznamená žádné zdržení.

- [LDK #4213][] přidává výchozí nastavení pro [zaslepené cesty][topic rv routing].
  Při sestavování zaslepené cesty, která není určena pro [nabídky][topic offers],
  je použita nekompaktní zaslepená cesta se zarovnáním na čtyři skoky (včetně příjemce)
  pro co nejvyšší soukromí. Pokud je zaslepená cesta určena pro nabídku, cílem je
  sestavit kompaktní zaslepenou cestu se sníženým zarovnáním minimalizující velikost
  v bajtech.

- [Eclair #3217][] přidává signál odpovědnosti (accountability) za [HTLC][topic
  htlc], čímž nahrazuje mechanismus experimentálních [HTLC atestací][topic htlc endorsement]
  (HTLC endorsements). Tento krok je v souladu s poslední aktualizací specifikace
  [BOLTs #1280][] bránící před [zahlcením kanálu][topic channel jamming attacks].
  Nový návrh pokládá tento signál za příznak odpovědnosti během používání
  omezených zdrojů; indikuje, že je používána chráněná HTLC kapacita a že
  následné uzly mohou zodpovídat za včasné vyřízení.

- [LND #10367][] přejmenovává experimentální signál `endorsement` ([BLIP4][])
  na `accountable` v souladu s posledním návrhem z [BLIPs #67][] založeným
  na [BOLTs #1280][].

- [Rust Bitcoin #5450][] přidává do dekodéru transakcí validaci, která
  na základě pravidel konsenzu odmítne běžnou transakci (tedy ne mincetvornou)
  mající `null` jako předchozí výstup.

- [Rust Bitcoin #5434][] přidává do dekodéru transakcí validaci, která
  odmítne mincetvornou (coinbase) transakci se `scriptSig` o délce mimo rozsah
  2–100 bajtů.

{% include snippets/recap-ad.md when="2026-01-13 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2047,34156,34215,34085,34197,33135,4213,3217,1280,10367,67,5450,5434" %}
[rp delving ark cf]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179
[news333 rp routing]: /cs/newsletters/2024/12/13/#zjisteni-o-vycerpani-kanalu
[news359 rp balance]: /cs/newsletters/2025/06/20/#vyzkum-rebalancovani-kanalu
[optech superscalar]: /en/podcast/2024/10/31/
[news169 jl tt]: /en/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[news270 jl cov]: /cs/newsletters/2023/09/27/#kovenanty-pro-navyseni-skalovatelnosti-ln
[delving ark hark]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/2
[delving ark poc]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/4
[sr delving hark]: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
[bitcoin core notice]: https://bitcoincore.org/en/2026/01/05/wallet-migration-bug/
[Bitcoin Core 30.2rc1]: https://bitcoincore.org/bin/bitcoin-core-30.2/test.rc1/
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 createfrom]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news386 sfl]: /cs/newsletters/2026/01/02/#bitcoin-core-32545
[sp ml]:https://groups.google.com/g/bitcoindev/c/bP6ktUyCOJI
