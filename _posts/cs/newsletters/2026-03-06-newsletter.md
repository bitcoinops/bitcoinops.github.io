---
title: 'Zpravodaj „Bitcoin Optech” č. 395'
permalink: /cs/newsletters/2026/03/06/
name: 2026-03-06-newsletter-cs
slug: 2026-03-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje standard pro ověřování VTXO v arkových implementacích
a odkazuje na návrh BIPu pro rozšíření prostoru noncí v poli `nVersion` v hlavičce
bloku. Též nechybí naše pravidelné rubriky s popisem diskuzí o změnách konsenzu,
oznámeními nových vydání a souhrnem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Standard pro bezstavové ověřování VTXO**: Jgmcalpine zaslal do fóra Delving
  Bitcoin [příspěvek][vpack del] o svém návrhu na V-PACK, standard pro bezstavové
  ověřování [VTXO][topic ark], který si klade za cíl poskytnout mechanismus na
  nezávislé ověřování a vizualizaci VTXO v ekosystému Arku. Cílem je vyvinout
  lehký software, který by mohl běžet v `no_std` prostředích (např. v hardwarových
  peněženkách), ověřoval offchain stav a udržoval nezávislé zálohy dat
  potřebných pro jednostranné vystoupení.

  Konkrétně V-PACK ověřuje, zda existuje Merkleova cesta vedoucí k validnímu anchor
  výstupu onchain a že předobrazy transakce se shodují s podpisy. Tím je zaručeno,
  že existuje možnost jednostranného vystoupení. Avšak Steven Roose, šéf firmy
  Second, upozornil, že software neověřuje jednoznačnost cesty (tedy že poskytovatel
  služby (ASP) nepřidal backdoor). Jgmcalpine odpověděl, že toto téma bude mít
  ve vývoji prioritu.

  Kvůli významným rozdílům mezi implementacemi Arku (konkrétně Arkade a Bark)
  navrhuje V-PACK vytvořit schéma minimálního použitelného VTXO (Minimal Viable
  VTXO, MVV), které by umožnilo překlad z „dialektů” implementací do společného
  formátu bez nutnosti importovat jejich kód do `no_std` prostředí.

  Implementace V-PACK, [libvpack-rs][vpack gh], je open-source a dostupný je
  též [nástroj][vpack tool] pro vizualizaci VTXO.

- **Rezervace 24 bitů namísto 16 v nVersion pro nonce**: Matt Corallo zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][mailing list nversion] o návrhu
  BIPu na navýšení počtu bitů prostoru noncí v `nVersion` z 16 na 24. V abstraktu
  Corallo uvádí, že 24 bitů v `nVersion` je rezervováno pro těžaře jako
  extra prostor pro nonce. Díky tomu bude možné generovat více kandidátů na
  blok během těžby s hlavičkami bez spoléhání na přetočení `nTime` jednou za
  sekundu.

  Motivací stojící za touto změnou je, že [BIP 320][BIP 320] definoval 16 bitů
  `nVersion` jako dodatečný prostor pro nonce, avšak nakonec se ukázalo, že zařízení
  začala pro tento účel používat 7 bitů z `nTime`. Díky omezené použitelnosti
  16 bitů `nVersion` určených pro signalizaci je možné rezervovat 24 bitů
  jako dodatečný prostor pro nonce.

  Důvodem změny je, že poskytnutí dodatečného prostoru pro nonce
  může zjednodušit design ASIC zařízení. Někteří těžaři navíc začali používat `nTime`,
  i když je vhodnější používat `nVersion`.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Rozšíření standardních nástrojů o podporu TEMPLATEHASH-CSFS-IK:**
  Antoine Poinsot zaslal do emailové skupiny Bitcoin-Dev [příspěvek][ap ml thikcs]
  o své předběžné práci na integraci [návrhu soft forku na taprootový
  `OP_TEMPLATEHASH`][news365 thikcs] do [miniscriptu][topic miniscript] a
  [PSBT][topic psbt].

  Nové opkódy si vyžádají změny vlastností miniscriptu, neboť narušují předpoklad,
  že podpisy a commitmenty transakcí jsou vždy tvořeny spolu. Jeho práce dále
  ukazuje na omezení struktury zásobníku Scriptu, jelikož při použití s miniscriptem
  vyžaduje `OP_SWAP` před každým `OP_CHECKSIGFROMSTACK`. Protože `OP_CHECKSIGFROMSTACK`
  požaduje tři argumenty, z nichž zprávu, klíč nebo oba počítají jiné fragmenty
  skriptu, neexistuje žádné evidentně lepší řazení argumentů, které by
  se ve většině případů vyvarovalo `OP_SWAP`.

  Změny pro PSBT jsou jednodušší, jedná se hlavně o nové pole v každém výstupu,
  které mapuje `OP_TEMPLATEHASH` commitmenty na jejich plné transakce, aby
  mohly být ověřeny.

- **Aktualizace Hourglass V2:** Mike Casey zaslal do emailové skupiny Bitcoin-Dev
  [příspěvek][mk ml hourglass] s aktualizací [protokolu Hourglass][bip draft hourglass2]
  určeného na snížení dopadu na trh v případě [kvantových][topic quantum resistance]
  útoků proti určitým ztraceným mincím. Dřívější návrhy protokolu byly již
  [diskutovány][hb ml hourglass] dříve. Tento soft fork by omezil celkovou hodnotu
  bitcoinů zamčených v P2PK, které lze utratit v jednom bloku, na jeden výstup
  a jeden bitcoin. Tyto hodnoty jsou víceméně náhodné, avšak diskutujícím
  připadají jako rozumné. Diskutující, kteří se kloní na stranu návrhu, se soustředili
  na možné ekonomické dopady, pokud by kvantový záškodník prodal velké množství bitcoinů.
  Odpůrci návrhu namítali, že vlastnictví soukromých klíčů k odemčení některých
  bitcoinů je jediný způsob, kterým může protokol identifikovat majitele; ani
  v případě prolomení kryptografického zabezpečení by protokol neměl aplikovat
  dodatečná omezení na vlastnictví mincí nebo jejich pohyb.

- **Flexibilita výběru algoritmů v bitcoinu:** Ethan Heilman zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][eh ml agility] o potenciální potřebě
  flexibility kryptografických algoritmů ([RFC7696 Cryptographic Algorithm Agility][rfc7696])
  v bitcoinu. Heilman navrhuje, aby byl do P2MR ([BIP360][]) přidán kryptografický
  algoritmus, který by prozatím nebyl určen na utrácení, ale mohl by sloužit
  jako záloha pro případ, kdy by současný primární algoritmus založený na secp256k1
  (nebo jiný budoucí) již nebyl bezpečný. Ústřední myšlenkou je, že pokud by bitcoin
  podporoval dva algoritmy podepisování najednou, případné prolomení jednoho
  z nich by nebylo katastrofické, jak nastiňují aktuální diskuze kolem
  potenciálního prolomení secp256k1.

  Další vývojáři se zapojili do diskuze o rozličných záložních algoritmech, které
  by pravděpodobně v Heilmanově 75letém horizontu nebyly prolomené.

  Též se hovořilo o otázce, zda je lepší BIP360 P2MR, nebo něco podobného [P2TR][topic
  taproot], jemuž by bylo později soft forkem deaktivováno utrácení klíčem.
  V P2MR jsou všechna utrácení skriptem, kde se mezi Merkleovými listy vybírá
  buď levnější primární mechanismus podepisování, nebo nákladnější záložní.
  V P2TR variantě je primárním druhem podepisování levnější utrácení klíčem,
  dokud není kvůli kryptografickému prolomení deaktivováno, a pouze
  záloha musí být Merkleův list. Heilman věří, že uživatelé studených
  peněženek by upřednostňovali P2MR a uživatelé horkých peněženek by mohli
  dle potřeby rychle přepnout na nový druh výstupu. Platba klíčem
  se záložním algoritmem podepisování by tak byla irelevantní u obou
  druhů uživatelů.

- **Omezení kryptografické flexibility v bitcoinu:**
  Pieter Wuille zaslal do emailové skupiny Bitcoin-Dev [příspěvek][pw ml agility]
  o omezeních kryptografické flexibility zmíněné v předchozím bodě.
  Bitcoin je podobně jako všechny peníze založen na víře, a tudíž pokud by bylo
  vlastnictví bitcoinu zabezpečeno několika kryptografickými systémy,
  zastánci každého schématu by prosazovali to své oblíbené a, co je důležité,
  nechtěli by, aby ostatní schémata byla používána, neboť by mohla oslabit
  základy zabezpečení vlastnictví. Wuille předpokládá, že časem
  budou muset být stará schémata podepisování deaktivována v rámci
  migrace z jednoho schématu na druhé.

  Heilman [odpověděl][eh ml agility2], že jelikož je sekundární schéma navržené
  pro flexibilitu výběru algoritmů mnohem nákladnější než současné schéma
  (a snad i budoucí primární schéma), zůstalo by jen záložním řešením a
  používáno by bylo jen pro migraci v případě, kdy by se primární schéma
  ukázalo jako výrazně oslabené. Toto sekundární schéma by proto nemuselo
  být po každé migraci na nové primární schéma deaktivováno.

  John Light je opačného [názoru][jl ml agility] než Wuille. Tvrdí, že deaktivace
  starého – i nezabezpečeného – schématu podepisování by byla větší hrozbou
  sdílené víře v bitcoinový model vlastnictví, než kdyby tyto slabě zabezpečené
  mince vzal kdokoliv, kdo by schéma prolomil. V podstatě říká, že nejdůležitější
  vlastností bitcoinového modelu vlastnictví je neodstranitelnost platnosti
  uzamykacího skriptu od jeho vytvoření až do utracení.

  Conduition [oponuje][c ml agility] Wuilleho předpokladům. Ukazuje, že díky
  flexibilitě Scriptu mohou uživatelé pro odemknutí mincí vyžadovat podpis z několika
  schémat. To jim umožní vyjádřit širší spektrum bezpečnostních předpokladů,
  než které stály za Wuilleho závěrem, že nezabezpečená schémata by musela
  být deaktivována a že uživatelé každého schématu by chtěli, aby téměř
  nikdo jiná schémata nepoužíval.

  Diskuze pokračuje upřesňováním, avšak nedosáhla žádného jednoznačného závěru
  o tom, jak by mohl bitcoin v praxi migrovat z jednoho kryptosystému
  na jiný v reakci na kvantového protivníka nebo z jiných důvodů.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 28.4rc1][] je kandidátem na vydání údržbové aktualizace předchozí
  hlavní verze. Obsahuje hlavně opravy migrace peněženek a odstraňuje nespolehlivý
  DNS seed.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33616][] přeskakuje kontrolu utrácení [dočasného prachu][topic
  ephemeral anchors] (ephemeral dust; `CheckEphemeralSpends`) během reorganizace
  bloků v případě, kdy se transakce vrátí zpět do mempoolu. Dříve pravidla
  přeposílání tyto transakce odmítla, protože se vrátily po jedné namísto
  v rámci jednoho balíčku. Tato změna je podobná [Bitcoin Core #33504][]
  (viz [zpravodaj č. 375][news375 truc], _angl._), která ze stejného důvodu
  přeskakuje kontrolu topologie [TRUC][topic v3 transaction relay] během
  reorganizace.

- [Bitcoin Core #34616][] přináší přesnější nákladový model algoritmu
  linearizace koster grafu (spanning-forest linearization, SFL) v [mempoolu
  clusterů][topic cluster mempool] (viz též [zpravodaj č. 386][news386 sfl]).
  Nový model používá limity nákladů na omezení procesorového času
  stráveného hledáním optimální linearizace každého clusteru. Předchozí
  model pouze sledoval jeden typ interních operací, což znamenalo
  nízkou korelaci mezi nahlášenými náklady a skutečně využitým
  procesorovým časem. Nový model sleduje mnoho operací s váhami kalibrovanými
  na základě výkonnostních testů napříč rozličným hardwarem. Tím nabízí
  mnohem přesnější odhad reálného času.

- [Eclair #3256][] přidává novou událost `ChannelFundingCreated`. Ta je
  vyvolána, když je podepsána otevírací nebo [splicingová][topic splicing]
  transakce a je připravena na zveřejnění. Událost je obzvláště užitečná
  pro kanály s jednostranným financováním, kde protistrana nemá žádnou
  možnost dopředu validovat vstupy a může proto chtít kanál vynuceně
  zavřít ještě před jeho potvrzením.

- [Eclair #3258][] přidává trait `ValidateInteractiveTxPlugin`, který
  umožňuje pluginům před podepsáním prověřit a odmítnout vstupy a výstupy
  protistrany interaktivních transakcí. Týká se otevírání
  [oboustranně financovaných][topic dual funding] a [splicingových][topic
  splicing] transakcí, kde se obě strany účastní jejich konstrukce.

- [Eclair #3255][] opravuje automatický výběr typu kanálu představený
  v [Eclair #3250][] (viz [zpravodaj č. 394][news394 eclair3250]).
  Nově již pro veřejné kanály neobsahuje `scid_alias`. Dle BOLT
  specifikací je `scid_alias` povolen pouze pro [neoznámené kanály][topic
  unannounced channels].

- [LDK #4402][] opravuje časování během nárokování HTLC. Nově používá
  skutečnou CLTV lhůtu z HTLC namísto hodnoty z těla onionu. U
  [trampolínových][topic trampoline payments] plateb, kde je uzel
  zároveň skok i příjemce, je skutečná lhůta vypršení HTLC vyšší, než
  kolik udává onion, protože vnější trampolínová trasa přidala svou
  vlastní [CLTV delta][topic cltv expiry delta]. Kvůli používání hodnoty
  z onionu nastavoval uzel přísnější lhůtu, než bylo nutné.

- [LND #10604][] přidává pro odchozí platby možnost použít SQL databázi
  (SQLite nebo PostgreSQL) jako alternativu ke stávajícímu key-value úložišti
  bbolt. PR samotné slučuje několik podřazených PR, mimo jiné:
  [#10153][LND #10153] (abstraktní rozhraní pro ukládání plateb),
  [#9147][LND #9147] (implementace SQL) a [#10485][LND #10485]
  (experimentální migrace dat z key-value do SQL). [Zpravodaj
  č. 169][news169 lnd-sql] (_angl._) popisuje přidání podpory pro
  PostgreSQL do LND a [zpravodaj č. 237][news237 lnd-sql] popisuje přidání
  SQLite.

- [BIPs #1699][] zveřejňuje [BIP442][], který specifikuje `OP_PAIRCOMMIT`.
  Tento nový [tapscriptový][topic tapscript] opkód vyjímá dva elementy
  ze zásobníku a vloží do něj jejich tagované haše. Tím poskytuje
  funkcionalitu podobnou [OP_CAT][topic op_cat] bez potřeby
  rekurzivních [kovenantů][topic covenants]. `OP_PAIRCOMMIT` je součástí
  návrhu na soft fork [LNHANCE][news383 lnhance] vedle [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] ([BIP119][]), [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]
  ([BIP348][]) a `OP_INTERNALKEY` ([BIP349][]). Viz též [zpravodaj č. 330][news330 paircommit],
  který informoval o úvodní podpoře.

- [BIPs #2106][] přidává do [BIP352][] ([tiché platby][topic silent
  payments]) limit počtu příjemců na skupinu, `K_max` = 2 323,
  čímž snižuje nejhorší možný čas skenování (viz též [zpravodaj č. 392][news392
  kmax]). Toto omezení stanovuje maximální počet výstupů, které musí
  skener v každé skupině příjemců v rámci jedné transakce zkontrolovat.
  Původně byla hodnota navržena na 1 000, avšak byla navýšena na
  2 323, aby se shodovala s maximálním počtem [P2TR][topic taproot] výstupů,
  které je možné vměstnat do transakce se standardní velikostí (100 kvB),
  a tím potlačila možnost identifikace transakcí s tichými platbami.

- [BIPs #2068][] zveřejňuje [BIP128][], který specifikuje standardní JSON
  formát pro ukládání plánů na obnovení s časovým zámkem. Plán na obnovení
  (recovery plan) obsahuje dvě předem podepsané transakce pro obnovu
  prostředků v případě ztráty přístupu k peněžence: výstražnou transakci
  (alert transaction), která konsoliduje UTXO do jediné adresy, a
  obnovující transakci (recovery transaction), která po uplynutí
  [časového zámku][topic timelocks] (2 až 388 dní) pošle tyto prostředky
  do záložní peněženky. Pokud je konsolidující transakce zveřejněna
  předčasně, může ji vlastník jednoduše utratit, čímž obnovu zneplatní.

- [BOLTs #1301][] doporučuje [anchor][topic anchor outputs] kanálům
  vyšší `dust_limit_satoshis`. S `option_anchors` mají předem podepsané
  HTLC transakce nulový poplatek, jejich náklady proto již nejsou
  započítávány do výpočtu prachu. To znamená, že HTLC výstupy, které
  projdou kontrolou prachu, mohou i nadále být pro onchain nárokování
  [neekonomické][topic uneconomical outputs], neboť jejich utracení
  požaduje následnou transakci, jejíž poplatek může překonat hodnotu
  výstupu. Specifikace nově doporučuje, aby uzly nastavily limit prachu,
  který s náklady na tyto transakce počítá, a aby uzly přijímaly
  od svých peer spojení hodnoty vyšší, než je standardní práh prachu.

{% include snippets/recap-ad.md when="2026-03-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33616,33504,34616,3256,3258,3255,3250,4402,10604,10153,9147,10485,1699,2106,2068,1301" %}

[vpack del]: https://delvingbitcoin.org/t/stateless-vtxo-verification-decoupling-custody-from-implementation-specific-stacks/2267
[vpack gh]: https://github.com/jgmcalpine/libvpack-rs
[vpack tool]: https://www.vtxopack.org/
[ap ml thikcs]: https://groups.google.com/g/bitcoindev/c/xur01RZM_Zs
[news365 thikcs]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[mk ml hourglass]: https://groups.google.com/g/bitcoindev/c/0E1UyyQIUA0
[bip draft hourglass2]: https://github.com/cryptoquick/bips/blob/hourglass-v2/bip-hourglass-v2.mediawiki
[hb ml hourglass]: https://groups.google.com/g/bitcoindev/c/zmg3U117aNc
[eh ml agility]: https://groups.google.com/g/bitcoindev/c/7jkVS1K9WLo
[rfc7696]: https://datatracker.ietf.org/doc/html/rfc7696
[pw ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A
[eh ml agility2]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/OXmZ-PnVAwAJ
[jl ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5GnsttP2AwAJ
[c ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5y9GkeXVBAAJ
[news375 truc]: /en/newsletters/2025/10/10/#bitcoin-core-33504
[news386 sfl]: /cs/newsletters/2026/01/02/#bitcoin-core-32545
[news394 eclair3250]: /cs/newsletters/2026/02/27/#eclair-3250
[news169 lnd-sql]: /en/newsletters/2021/10/06/#lnd-5366
[news237 lnd-sql]: /cs/newsletters/2023/02/08/#lnd-7252
[news330 paircommit]: /cs/newsletters/2024/11/22/#aktualizace-navrhu-lnhance
[news383 lnhance]: /en/newsletters/2025/12/05/#lnhance-soft-fork
[news392 kmax]: /cs/newsletters/2026/02/13/#navrh-na-omezeni-poctu-prijemcu-tichych-plateb-ve-skupine
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[mailing list nversion]: https://groups.google.com/g/bitcoindev/c/fCfbi8hy-AE
[BIP 320]: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
