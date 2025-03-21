---
title: 'Zpravodaj „Bitcoin Optech” č. 346'
permalink: /cs/newsletters/2025/03/21/
name: 2025-03-21-newsletter-cs
slug: 2025-03-21-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší souhrn diskuze o novém systému v LND
pro dynamickou úpravu poplatků. Též nechybí naše pravidelné rubriky
s popisem nedávných změn ve službách a klientském software, oznámeními
nových vydání a souhrnem změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Diskuze o dynamickém nastavování poplatků v LND:** Matt
  Morehouse zaslal do fóra Delving Bitcoin [příspěvek][morehouse sweep]
  s popisem nově přepsaného _sweeperu_ v LND (nástroj pro „zametení”
  UTXO zpět do vlastní peněženky, zejména po vynuceném uzavření kanálu),
  který stanovuje poplatky pro onchain transakce včetně navýšení pomocí
  [RBF][topic rbf]. Na úvod stručně vysvětluje hlediska správy poplatků,
  které jsou pro LN uzel kritické z pohledu bezpečnosti i přirozené touhy
  vyvarovat se přeplácení. Dále vyjmenovává dvě obecné strategie používané
  v LND:

  - Dotázat se externího systému odhadování poplatků, jako je místní Bitcoin Core
    uzel nebo třetí strana. Tohoto se používá hlavně pro výběr úvodního poplatku
    a pro navyšování poplatků neurgentních transakcí.

  - Exponenciální zvyšování poplatku, které se použije s přibližujícím se koncem lhůty.
    Tím LND zajistí, aby problémy s mempoolem uzlu nebo s jeho systémem [odhadování
    poplatků][topic fee estimation] nezabránily včasnému potvrzení. Na příklad
    Eclair začne používat exponenciální zvyšování, když lhůta vyprší za šest bloků.

  Morehouse dále popisuje, jak jsou tyto dvě strategie spolu používané v novém
  sweeperu: „transakce nárokující [HTLC][topic htlc] s odpovídajícími lhůtami
  jsou sloučené do jediné [dávkové transakce][topic payment batching]. Rozpočet
  pro tuto transakci je spočítán jako součet rozpočtů jednotlivých HTLC v transakci.
  Na základě rozpočtu a lhůty transakce se vygeneruje funkce, která určí, jaká část
  rozpočtu se bude utrácet s blížícím se koncem lhůty. Ve výchozím nastavení se používá
  lineární funkce, která začíná s nízkým poplatkem (určeným minimálním poplatkem
  pro přeposílání nebo externím odhadem) a končí alokací celého rozpočtu, když
  je jeden blok před vypršením lhůty.”

  Příspěvek též popisuje, jak nová logika pomáhá chránit proti útokům
  [cyklickým nahrazováním][topic replacement cycling] (replacement cycling):
  „s výchozími parametry v LND by musel útočník zaplatit minimálně 20× více, než je
  hodnota HTLC, aby útok úspěšně provedl.” Dodává, že nový systém také zlepšuje
  obranu proti [pinningovým útokům][topic transaction pinning].

  Na závěr sdílí množství odkazů na chyby a zranitelnosti v LND, které
  byly díky nové logice opraveny. Abubakar Sadiq Ismail [reagoval][ismail sweep]
  několika návrhy na efektivnější používání odhadů poplatků v Bitcoin Core všemi
  LN implementacemi i jiným software. Další vývojáři ve svých odpovědích přístup
  chválili a zpřesňovali.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydána Wally 1.4.0:**
  Vydání [libwally-core 1.4.0][wally 1.4.0] přidává podporu pro [taproot][topic
  taproot], odvozování RSA klíčů pomocí [BIP85][] a další funkce pro
  [PSBT][topic psbt] a [deskriptory][topic descriptors].

- **Ohlášen Bitcoin Core Config Generator:**
  Projekt [Bitcoin Core Config Generator][bccg github] je rozhraní pro příkazovou řádku
  pro vytváření konfiguračních souborů Bitcoin Core `bitcoin.conf`.

- **Kontejner s regtestovým vývojovým prostředím:**
  Repozitář [regtest-in-a-pod][riap github] poskytuje kontejner pro [Podman][podman
  website] nakonfigurovaný se službami Bitcoin Core, Electrum a Esplora. Podrobnosti
  přináší blogový příspěvek [Using Podman Containers for Regtest Bitcoin Development][podman
  bitcoin blog].

- **Nástroj pro vizualizaci transakcí Explora:**
  [Explora][explora github] je prohlížeč založený na webu pro vizualizaci a navigaci
  mezi vstupy a výstupy transakcí.

- **Hashpool v0.1 otagován:**
  [Hashpool][hashpool github] je [těžební pool][topic pooled mining] založený na
  [referenční implementaci Stratum v2][news247 sri], kde jsou vytěžená share reprezentována
  jako [ecashové][topic ecash] tokeny (viz [zpravodaj č. 337][pod337 hashpool]).

- **DMND spouští těžbu v poolu:**
  [DMND][dmnd website] spouští těžbu v poolu s protokolem Stratum v2. Rozšiřuje tím své
  předchozí [ohlášení][news281 demand] sólové těžby.

- **Krux přidává taproot a miniscript:**
  [Krux][news273 krux] přidává podporu pro [miniscript][topic miniscript] a taproot
  díky knihovně [embit][embit website].

- **Ohlášen secure element s dostupnými zdroji:**
  [TROPIC01][tropic01 website] je secure element postaven na RISC-V s [otevřenou
  architekturou][tropicsquare github] pro auditovatelnost.

- **Nunchuk spouští Group Wallet:**
  [Group Wallet][nunchuk blog] podporuje [multisig][topic
  multisignature] podepisování, taproot, výběr mincí, [Musig2][topic musig] a
  bezpečnou komunikaci mezi účastníky využitím výstupních deskriptorů v [BIP129][]
  Bitcoin Secure Multisig Setup (BSMS) souboru.

- **Ohlášen protokol FROSTR:**
  [FROSTR][frostr github] používá [schéma prahového podepisování][topic
  threshold signature] FROST pro _k_​-z-​_n_ podepisování a správu klíčů pomocí nostru.

- **Bark spuštěn na signetu:**
  [Bark][new325 bark], implementace [Arku][topic ark], je nyní [dostupný][second blog]
  na [signetu][topic signet] i se zdrojem mincí a testovacím úložištěm.

- **Ohlášena peněženka Cove Bitcoin:**
  [Cove Wallet][cove wallet github] je open-source bitcoinová mobilní peněženka založená
  na BDK, která podporuje technologie jako PSBT, [štítky][topic wallet labels],
  hardwarová podpisová zařízení a další.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 29.0rc2][] je kandidátem na vydání příští hlavní verze tohoto převládajícího
  plného uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31649][] kompletně odstraňuje logiku checkpointů, která již není
  po přidání fáze předsynchronizace hlaviček před několika lety (viz [zpravodaj č.
  216][news216 presync], _angl._) zapotřebí. Předsynchronizace umožňuje během
  úvodního stahování bloků (IBD) určit platnost řetězce hlaviček porovnáním
  jejich proof of work s předurčeným prahem `nMinimumChainWork`. Za validní jsou
  považované pouze takové řetězce, jejichž proof of work převyšuje tuto hodnotu.
  Tím lze zabránit DoS útokům hlavičkami s nízkým proof of work. Změna odstraňuje
  potřebu checkpointů, které jsou často považované za centralizující prvek.

- [Bitcoin Core #31283][] přináší do rozhraní `BlockTemplate` novou metodu `waitNext()`,
  která vrátí novou šablonu bloku pouze, pokud se změní vrchol řetězce nebo se
  zvýší poplatky v mempoolu nad prahovou hodnotu `MAX_MONEY`. Dříve obdrželi těžaři
  po každém požadavku novou šablonu, což vyústilo v nadbytečné generování šablon.
  Změna je v souladu se specifikací protokolu [Stratum V2][topic pooled mining].

- [Eclair #3037][] vrátí v odpovědi na příkaz `listoffers` (viz [zpravodaj č.
  345][news345 offers]) všechna relevantní data [nabídek][topic offers] včetně
  časových razítek `createdAt` a `disabledAt`. Dříve vracel pouze syrová
  Type-Length-Value (TLV) data. Dále PR opravuje chybu způsobující pád uzlu během
  opakovaného pokusu o registraci stejné nabídky.

- [LND #9546][] přidává do příkazu `lncli constrainmacaroon` (viz [zpravodaj č.
  201][news201 constrain], _angl._) parameter `ip_range`, který umožní autentizačním
  tokenům (macaroon) nastavit přístup na určitý rozsah IP adres. Dříve mohly být použité
  pouze konkrétní adresy.

- [LND #9458][] přináší pro některá spojení omezený přístup konfigurovatelný pomocí
  `--num-restricted-slots`. Spojením je přiřazena úroveň přístupu na základě historie
  jejich kanálů: s potvrzeným kanálem obdrží chráněný přístup, s nepotvrzeným kanálem
  obdrží dočasný přístup a ostatní obdrží omezený přístup.

- [BTCPay Server #6581][] přidává podporu pro [RBF][topic rbf], což umožní navýšit poplatek
  transakcím bez potomků, jejichž všechny vstup pochází z vlastní peněženky. Uživatelé
  mohou během navyšování poplatků nově zvolit mezi RBF a [CPFP][topic cpfp]. Pro
  funkčnost je vyžadován NBXplorer verze 2.5.22 nebo vyšší.

- [BDK #1839][] přidává detekci a zpracování zrušených (dvojitě utracených) transakcí.
  Přidává do `TxUpdate` nové pole `evicted_ats` s aktualizacemi časových razítek
  `last_evicted` v `TxGraph`. Transakce jsou považované za vyloučené (evicted), pokud
  jejich časová razítka `last_evicted` překročí `last_seen`. Algoritmus kanonizace
  (viz [zpravodaj č. 335][news335 algorithm]) byl upraven, aby ignoroval vyloučené
  transakce kromě tranzitivních kanonických potomků.

- [BOLTs #1233][] upravuje chování uzlu, aby nikdy nevyvolalo selhání [HTLC][topic htlc]
  proti směru toku, pokud uzel zná jeho předobraz. Díky tomu uzel zajistí řádné urovnání
  tohoto HTLC. Dříve bylo doporučováno vyvolat selhání takového HTLC, pokud chybělo v
  potvrzené commitment transakci, i když byl předobraz znám. Chyba v LND verzích před 0.18
  přinutila uzly pod DoS útokem, aby po restartu vyvolaly selhání čekajících HTLC i přes
  znalost jejich předobrazů. To způsobilo ztrátu hodnoty HTLC (viz též [zpravodaj č. 344][news344
  lnd]).

{% include snippets/recap-ad.md when="2025-03-25 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31649,31283,3037,9546,9458,6581,1839,1233" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[morehouse sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512
[ismail sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512/3
[news216 presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[news345 offers]: /cs/newsletters/2025/03/14/#eclair-2976
[news201 constrain]: /cs/newsletters/2022/05/25/#lnd-6529
[news344 lnd]: /cs/newsletters/2025/03/07/#odhaleni-opravene-zranitelnosti-v-lnd-umoznujici-kradez
[news335 algorithm]: /cs/newsletters/2025/01/03/#bdk-1670
[wally 1.4.0]: https://github.com/ElementsProject/libwally-core/releases/tag/release_1.4.0
[bccg github]: https://github.com/jurraca/core-config-tui
[riap github]: https://github.com/thunderbiscuit/regtest-in-a-pod
[podman website]: https://podman.io/
[podman bitcoin blog]: https://thunderbiscuit.com/posts/podman-bitcoin/
[explora github]: https://github.com/lontivero/explora
[hashpool github]: https://github.com/vnprc/hashpool
[news247 sri]: /cs/newsletters/2023/04/19/#aktualizace-referencni-implementace-protokolu-stratum-v2
[pod337 hashpool]: /en/podcast/2025/01/21/#continued-discussion-about-rewarding-pool-miners-with-tradeable-ecash-shares-transcript
[news281 demand]: /cs/newsletters/2023/12/13/#spusten-tezebni-pool-se-stratum-v2
[dmnd website]: https://www.dmnd.work/
[embit website]: https://embit.rocks/
[news273 krux]: /cs/newsletters/2023/10/18/#krux-firmware-pro-podpisova-zarizeni
[tropic01 website]: https://tropicsquare.com/tropic01
[tropicsquare github]: https://github.com/tropicsquare
[nunchuk blog]: https://nunchuk.io/blog/group-wallet
[frostr github]: https://github.com/FROSTR-ORG
[new325 bark]: /cs/newsletters/2024/10/18/#ohlasena-implementace-arku-bark
[second blog]: https://blog.second.tech/try-ark-on-signet/
[cove wallet github]: https://github.com/bitcoinppl/cove
