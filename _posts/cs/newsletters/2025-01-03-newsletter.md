---
title: 'Zpravodaj „Bitcoin Optech” č. 335'
permalink: /cs/newsletters/2025/01/03/
name: 2025-01-03-newsletter-cs
slug: 2025-01-03-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---

Zpravodaj tento týden odkazuje na informace o dlouhodobé deanonymizační
zranitelnosti v software používajícím centralizované coinjoinové
protokoly a shrnuje aktualizaci návrhu schématu ChillDKG – protokolu
distribuovaného generování klíčů kompatibilního s bezskriptovým prahovým
podepisováním. Též nechybí naše pravidelné rubriky se souhrnem diskuzí
o změnách pravidel bitcoinového konsenzu, oznámeními nových vydání a popisem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Deanonymizační útoky proti centralizovaným coinjoinům:** Yuval Kogman
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][kogman cc] s popisem
  několika zranitelností, které snižují soukromí účastníků centralizovaných
  [coinjoinových][topic coinjoin] protokolů používaných aktuálními verzemi
  peněženek Wasabi a Ginger a předchozími verzemi softwarových peněženek
  Samourai, Sparrow a Trezor Suite. Kogman pomohl navrhnout protokol
  WabiSabi používaný ve Wasabi a Ginger (viz [zpravodaj č. 102][news102
  wabisabi], _angl._), ale „na protest odešel ještě před jeho vydáním.”
  V případě zneužití mohou tyto zranitelnosti umožnit centrálním koordinátorům
  zjistit, který uživatel obdržel které výstupy. Tím by odpadly všechny
  důvody používání sofistikovaného protokolu nad jednoduchým webovým serverem.
  Kogman poskytl důkazy, že tyto zranitelnosti byly několika vývojářům
  peněženek známy několik let. Podobná zranitelnost postihující některé
  z těchto aplikací byla zmíněna ve [zpravodaji č. 333][news333 vuln].

- **Aktualizace návrhu ChillDKG:** Tim Ruffing a Jonas Nick zaslali do
  emailové skupiny Bitcoin-Dev [příspěvek][rn chilldkg] s odkazem na
  [aktuální návrh BIPu na ChillDKG][bip-chilldkg], který popisuje
  protokol pro distribuované generování klíčů. Protokol je kompatibilní
  s bitcoinovými [bezskriptovými prahovými podpisy][topic threshold signature]
  FROST. Po svém prvním oznámení (viz [zpravodaj č. 312][news312 chilldkg])
  opravili bezpečnostní zranitelnost, přidali krok, který může odhalit
  nesprávně fungující účastníky, a zjednodušili provádění záloh a obnov.
  Změny koordinovali spolu se Sivaramem Dhakshinamoorthym a jeho návrhem
  na FROST podepisování kompatibilní s bitcoinem (viz [zpravodaj č.
  315][news315 frost]).

## Diskuze o změnách konsenzu

_Nová měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Opkódy rozšiřující CTV:** vývojář moonsettler zaslal příspěvek do
  emailové skupiny [Bitcoin-Dev][moonsettler ctvppml] i do fóra [Delving
  Bitcoin][moonsettler ctvppdelv] obsahující návrh na dva nové opkódy
  pro použití s navrhovaným [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify]:

  - _OP_TEMPLATEHASH_ převádí vybrané části transakce na haš kompatibilní
    s CTV. Díky tomu mohou zásobníkové operace určit, kolik a které vstupy
    se mají použít, jaký časový zámek, které hodnoty a skripty výstupů,
    jaký počet výstupů a které verze transakce.

  - _OP_INPUTAMOUNTS_ umístí do zásobníku hodnotu všech nebo vybraných vstupů
    v satoshi. Hodnoty potom mohou být použité jako parametr pro
    `OP_TEMPLATEHASH` (vyžadující na příklad hodnotu shodnou s výstupem).

  Tyto dva opkódy mohou spolu vytvořit [úschovny][topic vaults] s podobnými
  vlastnostmi jako v případě `OP_VAULT` z [BIP345][]. Opkódy mohou být mimo
  jiné užitečné pro implementaci [odpovědných výpočtů][topic acc] (accountable
  computing), která by mohla být efektivnější onchain. Diskuze ve fóru Delving
  Bitcoin v době psaní zpravodaje nadále probíhala.

- **Změny složitosti za hranicí 256 bitů:** Anders zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][anders diff] vyjadřující obavy z úprav složitosti
  proof of work (PoW) za hranicí 256 bitů, které jsou dostupné v hlavičce
  bloku. Vyžadovalo by to nepředstavitelné navýšení hashrate (zhruba
  2<sup>176</sup>-krát více, než je dostupno nyní), avšak pokud by se
  tak stalo, mohl by se ve forku přidat sekundární cíl složitosti, jak
  [poznamenává][cassano diff] Michael Cassano. Aby byl blok validní,
  musely by být naplněny oba cíle. Tento způsob je podobný návrhu na
  obranu před útokem zadržováním bloků (viz [zpravodaj č. 315][news315
  withholding]). Tyto druhy forků, včetně návrhů jako _dopředné bloky_
  (forward blocks, viz [zpravodaj č. 16][news16 forward], _angl._),
  jsou sice technicky vzato soft forky, jelikož pouze upevňují stávající pravidla,
  avšak někteří vývojáři od tohoto označení odrazují, neboť kvůli nim
  mohou neaktualizované plné uzly a potenciálně i všechny lehké (SPV)
  klienty snadno uvěřit, že má nějaká transakce stovky či tisíce
  potvrzení, ačkoliv nemá ve skutečnosti žádné nebo je v konfliktu s jinou,
  již potvrzenou transakcí.

- **Přechodné soft forky pro čistící soft forky:** Jeremy Rubin zaslal
  do fóra Delving Bitcoin [příspěvek][rubin transitory] o pouze dočasném
  aplikování pravidel konsenzu navržených k zabraňování nebo opravě
  zranitelností. Myšlenka byla již dříve navržena pro soft forky, které
  přidávají nové funkce (viz [zpravodaj č. 197][news197 transitory], _angl._),
  avšak nesetkal se s podporou zastánců nových funkcí ani nezaujatých členů
  komunity. Rubin navrhuje, že by se tato myšlenka lépe aplikovala na soft
  forky, které se pokouší opravit zranitelnosti, ale u kterých hrozí, že
  by mohly neúmyslně zabránit uživatelům v utracení svých bitcoinů
  (tzv. _hrozba konfiskace_) nebo omezit schopnost snadno opravit budoucí
  zranitelnosti. David Harding [projevil názor][harding transitory], že
  myšlenka dočasných soft forků se nesetkala s podporou, protože
  ani zastánci ani nezaujatí členové nebyli ochotní se každých pár let
  účastnit dohadů o změně konsenzu. Tato námitka platí bez ohledu na to,
  zda změna přidává funkce nebo adresuje zranitelnosti.

- **Jak upgradovat pro kvantové počítače:** Matt Corallo zaslal do
  emailové skupiny Bitcoin-Dev [příspěvek][corallo qc] o přidání
  kvantově odolného opkódu do [tapscriptu][topic tapscript] pro validaci
  podpisů, který by umožnil utratit prostředky, i kdyby byly operace
  pracující s ECDSA a [Schnorrovými][topic schnorr signatures] podpisy
  deaktivovány kvůli hrozbě tvorby padělků rychlými kvantovými počítači.
  Luke Dashjr [poznamenal][dashjr qc], že soft fork není v současné době
  nezbytný, pokud existuje všeobecný souhlas, jak bude kvantově odolný
  opkód v budoucnosti fungovat. Uživatelé se k němu pouze potřebují
  zavázat jako k možnosti, která se může v budoucnosti stát dostupnou.
  Tadge Dryja [navrhl][dryja qc] přechodný soft fork, který by dočasně
  omezil používání kvantově neodolných ECDSA a Schnorrových podpisů,
  pokud by se zdálo, že by kvantové počítače byly blízko schopnosti
  ukrást bitcoiny. Pokud by poté někdo splnil onchain hádanku, která
  by byla řešitelná pouze kvantovým počítačem (nebo díky objevu
  fundamentální kryptografické zranitelnosti), přechodný soft fork
  by se automaticky mohl stát trvalým. V opačném případě by mohl
  být přechodný soft fork obnoven nebo ukončen (čímž by byly bitcoiny
  chráněné ECDSA nebo Schnorrem opět utratitelné).

- **Přechodné období proti ohýbání času v rámci pročištění konsenzu:** Sjors Provoost zaslal
  do fóra Delving Bitcoin [příspěvek][provoost timewarp] s připomínkou
  k návrhu, aby soft fork [pročištění konsenzu][topic consensus cleanup]
  bránil [útoku ohýbáním času][topic time warp] tím, že by zakázal prvnímu
  bloku nové periody mít časové razítko více než 600 sekund před
  posledním blokem předchozí periody. Provoost se obává, že by poctivý
  těžař, který používá modifikace časového razítka k rozšíření prostoru
  nonce (tzv. _time rolling_), mohl neúmyslně vyprodukovat
  blok, který uzly s pomalými hodinami nemusí ihned přijmout. Tím
  by se zpomalila propagace tohoto bloku v porovnání s konkurenčními
  bloky s méně variabilními časovými razítky vyprodukovanými ve stejné
  době. Pokud by konkurenční blok zůstal v nejlepším řetězci, přišel
  by těžař s time rollingem o odměnu. Provoost namísto toho navrhuje
  méně omezující limity, na příklad zákaz na časové razítko jdoucí
  více než 7 200 sekund (dvě hodiny) do minulosti. Antoine Poinsot
  volbu 600 sekund [obhajuje][poinsot timewarp] jako vyhýbající se všem
  známým problémům a poskytující nejsilnější obranu proti ohýbání času
  v budoucnosti.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK wallet-1.0.0][] je prvním hlavním vydáním této knihovny pro budování
  bitcoinových peněženek a jiných podobných aplikací. Původní rustový
  balíček `bdk` byl přejmenován na `bdk_wallet` (jeho API by mělo být
  stabilizované). Nižší vrstvy byly extrahovány do balíčků
  `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`.

- [LND 0.18.4-beta][] je menším vydáním této oblíbené implementace LN,
  které „vedle funkcí pro budování nastavitelných kanálů přináší obvyklé
  opravy chyb a navýšení stability.”

- [Core Lightning v24.11.1][] je menším vydáním, které zlepšuje kompatibilitu
  mezi experimentálním pluginem `xpay` a starším RPC příkazem `pay`. Též
  přináší několik vylepšení pro uživatele xpay.

- [Bitcoin Core 28.1rc2][] je kandidátem na vydání údržbové verze této
  převládající implementace plného uzlu.

- [LDK v0.1.0-beta1][] je kandidátem na vydání této knihovny pro budování
  peněženek a aplikací s podporou LN.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #31223][] mění způsob, kterým uzel odvozuje P2P port
  [torové][topic anonymity networks] onion služby (viz [zpravodaj
  č. 118][news118 tor], _angl._). Nově bude namísto 8334 používat hodnotu
  o jedna vyšší, než kolik je specifikováno volbou `-port` (pokud je poskytnuta).
  Řeší tím problém, kdy se více místních uzlů snažilo poslouchat na portu
  8334, čímž došlo z důvodu kolize k pádu. Kolize může i nadále nastat,
  pokud jsou dvěma místním uzlům pomocí `-port` předány po sobě jdoucí hodnoty.
  Obecně je však moudré se takovým případům vyhýbat.

- [Eclair #2888][] přidává podporu pro protokol [peer storage][topic peer storage]
  dle specifikace v [BOLTs #1110][]. Protokol umožňuje uzlům na žádost ukládat
  zašifrované zálohy (ve výchozím nastavení až 65 kB) svých protistran.
  Tato funkcionalita je zamýšlena pro poskytovatele lightningových služeb (LSP)
  obsluhujících mobilní peněženky. Má konfigurovatelné nastavení, které
  provozovatelům umožňuje určit dobu uložení dat. Po CLN (viz [zpravodaj
  č. 238][news238 storage]) je Eclair druhou implementací s podporou tohoto
  protokolu.

- [LDK #3495][] zpřesňuje model vyhodnocující historickou pravděpodobnost
  úspěšného nalezení cesty v LN vylepšením [hustoty pravděpodobnosti][probability
  density] a souvisejících parametrů na základě reálných dat sesbíraných
  sondami. Změna sbližuje historické a <!-- --> a priori modely se skutečným světem
  a vylepšuje výchozí hodnoty trestů a hledání cest.

- [LDK #3436][] přesouvá balíček `lightning-liquidity` do repozitáře `rust-lightning`.
  Balíček poskytuje typy a primitiva pro integraci LDK uzlu s [LSP][lsp spec].

- [LDK #3435][] přidává do kontextu [zaslepených cest][topic rv routing]
  pole, do kterého může plátce přidat autentizační kód zprávy založený na haši
  (HMAC) spolu s noncem, díky kterým může příjemce odesílatele autentizovat. Opravuje
  tím problém, kdy mohl útočník vzít `payment_secret` z [BOLT11][] faktury
  vydané uzlem oběti a zfalšovat platbu, i když částka neodpovídala [nabídce][topic
  offers]. Změna také pomůže zabránit deanonymizačním útokům používajícím stejnou
  techniku.

- [LDK #3365][] zajistí, aby byl `holder_commitment_point` při upgradech označen
  jako `Available` namísto zanechání jej v předchozím stavu `PendingNext`.
  Změna zabraňuje vynuceným uzavřením kanálu během upgradů uzlu, kdy uzel
  obdrží zprávu `commitment_signed`, která vyžaduje, aby byl příští commitment
  point (bod na eliptické křivce sloužící pro odvozování commitmentů) dostupný.

- [LDK #3340][] přináší [dávkování][topic payment batching] onchain nárokujících
  transakcí s výstupy, které mohou být obětí [pinningu][topic transaction pinning].
  Tím lze dosáhnout redukce použitého blokového prostoru a poplatků během
  vynuceného zavření kanálu. Dříve byly výstupy dávkované pouze, pokud je mohl
  uzel nárokovat exkluzivně, tedy pokud nemohlo dojít k pinningu. Nově je
  každý výstup, který může protistrana utratit do 12 bloků, považován za
  možný cíl pinningu a je dávkován, pokud mohou být [časové zámky][topic timelocks]
  jejich [HTLC][topic htlc] zkombinované.

- [BDK #1670][] přináší nový lineární algoritmus kanonizace transakcí.
  Identifikuje kanonické transakce a odstraňuje z peněženky nepotvrzené konfliktní
  transakce, které se zřejmě nepotvrdí. Algoritmus nahrazuje starší,
  kvadratickou metodu `get_chain_position`, která může v některých případech
  [představovat riziko DoS][canalgo].

- [BIPs #1689][] začleňuje [BIP374][] specifikující standardní způsob generování
  a ověřování [dokladů rovnosti diskrétních logaritmů][topic dleq] (Discrete Log
  Equality Proofs, DLEQ) nad eliptickou křivkou secp256k1. Motivací BIPu je
  možnost vytvářet [tiché platby][topic silent payments] s několika nezávislými
  podepisujícími entitami. DLEQ umožní všem podepisujícím doložit, že je
  jejich podpis validní a nepředstavuje hrozbu ztráty prostředků.

- [BIPs #1697][] přidává do [BIP388][] podporu pro [MuSig][topic musig]
  úpravou gramatiky šablon [deskriptorů výstupních skriptů][topic descriptors].

- [BLIPs #52][] přidává [BLIP50][] specifikující protokol pro komunikaci mezi LSP
  a jejími klienty. Zprávy jsou přenášené v rámci JSON-RPC pomocí peer-to-peer zpráv
  dle [BOLT8][]. Jedná se o součást sady BLIPů pocházejících z [repozitáře specifikace
  LSP][lsp spec]. Jsou považovány za stabilní, neboť jsou nasazeny v produkci
  u několika LSP a v implementacích klientů.

- [BLIPs #54][] přidává [BLIP52][] specifikující protokol pro [JIT kanály][topic
  jit channels], které umožňují klientům bez LN kanálů začít přijímat platby.
  Když LSP přijme příchozí platbu, otevře ke klientovi kanál, jehož náklady
  na otevření jsou odečteny z první platby. Jedná se též o součást sady
  BLIPů pocházejících z [repozitáře specifikace LSP][lsp spec].

{% include snippets/recap-ad.md when="2025-01-07 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31223,2888,3495,3436,3435,3365,3340,1670,1689,1697,54,52,1110" %}
[news315 withholding]: /cs/newsletters/2024/08/09/#utoky-zadrzovanim-bloku-a-mozna-reseni
[news16 forward]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[moonsettler ctvppml]: https://groups.google.com/g/bitcoindev/c/1P1aqkfwE7E
[moonsettler ctvppdelv]: https://delvingbitcoin.org/t/ctv-op-templatehash-and-op-inputamounts/1344/
[anders diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/qR4ucBeMCAAJ
[cassano diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/gPNAMn3ICAAJ
[corallo qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/4cM-7pf4AgAJ
[dashjr qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/YT0fR2j_AgAJ
[dryja qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/8nr6I5NIAwAJ
[rubin transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333
[news197 transitory]: /en/newsletters/2022/04/27/#relayed
[harding transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333/2
[provoost timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326
[poinsot timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/11
[news333 vuln]: /cs/newsletters/2024/12/13/#zranitelnost-zpusobujici-deanonymizaci-ve-wasabi-a-souvisejicim-software
[news315 frost]: /cs/newsletters/2024/08/09/#navrh-bipu-na-bezskriptove-prahove-podpisy
[news312 chilldkg]: /cs/newsletters/2024/07/19/#protokol-pro-distribuovane-generovani-klicu-pro-frost
[kogman cc]: https://groups.google.com/g/bitcoindev/c/CbfbEGozG7c/m/w2B-RRdUCQAJ
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[rn chilldkg]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/Y2VhaMCrCAAJ
[bip-chilldkg]: https://github.com/BlockstreamResearch/bip-frost-dkg
[lnd 0.18.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta
[bitcoin core 28.1rc2]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[bdk wallet-1.0.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.0.0
[core lightning v24.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.1
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[news118 tor]: /en/newsletters/2020/10/07/#bitcoin-core-19991
[news238 storage]: /cs/newsletters/2023/02/15/#core-lightning-5361
[lsp spec]: https://github.com/BitcoinAndLightningLayerSpecs/lsp
[probability density]: https://cs.wikipedia.org/wiki/Hustota_pravd%C4%9Bpodobnosti
[canalgo]: https://github.com/evanlinjin/bdk/blob/e9854455ca77875a6ff79047726064ba42f94f29/docs/adr/0003_canonicalization_algorithm.md
