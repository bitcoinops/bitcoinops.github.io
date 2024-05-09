---
title: 'Zpravodaj „Bitcoin Optech” č. 285'
permalink: /cs/newsletters/2024/01/17/
name: 2024-01-17-newsletter-cs
slug: 2024-01-17-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme odhalení nedávné zranitelnosti postihující
Core Lightning a oznámení o dvou nových návrzích na soft fork. Dále
poskytujeme přehled návrhu cluster mempoolu, předáváme informaci
o aktualizované specifikaci a implementaci komprese transakcí a
shrnujeme diskuzi o těžaři extrahovatelné hodnotě (MEV) v nenulových
dočasných anchorech. Též nechybí naše pravidelné rubriky s oznámeními
nových vydání a popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Odhalení nedávné zranitelnosti v Core Lightning:** Matt Morehouse
  [oznámil][morehouse delving] na fóru Delving Bitcoin zranitelnost,
  kterou před tím [zodpovědně nahlásil][topic responsible disclosures].
  Zranitelnost postihovala Core Lightning verze 23.02 až 23.05.2.
  Novější verze 23.08 a vyšší postiženy nejsou.

  Morehouse tuto zranitelnost objevil, když pokračoval v práci na falešném
  financování (viz [zpravodaj č. 266][news266 lnbugs]). Když znovu testoval
  uzly s opravami, podařilo se mu vyvolat [souběh][race condition] („race
  condition”), který po zhruba 30 sekundách CLN shodil. Je-li uzel offline,
  nemůže bránit uživatele proti zlomyslným nebo porouchaným protistranám,
  které uživatelovy prostředky vystavují riziku. Analýza ukázala, že CLN
  opravilo původní zranitelnost falešného financování, ale než stačilo
  opravu řádně otestovat, zranitelnost byla zveřejněna a jeden z pluginů
  začlenil zneužitelný souběh. Po Morehouseově nahlášení byl připraven
  patch, aby souběh nezpůsobil pád uzlu.

  Pro více informací doporučujeme přečíst Morehouseův skvělý blogový
  příspěvek s [odhalením][morehouse full].

- **Návrh nového soft forku LNHANCE:** Brandon Black [zaslal][black lnhance]
  do fóra Delving Bitcoin detaily o soft forku, který kombinuje předchozí
  návrhy [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) a
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) s novým
  návrhem `OP_INTERNALKEY`, který do zásobníku umisťuje [taprootový
  interní klíč][taproot internal key]. Než budou moci zaplatit na výstup,
  musí znát autoři skriptů interní klíč, aby ho mohli umístit
  přímo do skriptu. `OP_INTERNALKEY` je zjednodušenou verzí [staršího
  návrhu][rubin templating] původního autora CTV Jeremy Rubina. Nová
  verze ušetří několik vbyte a díky ní budou skripty snadněji znovupoužitelné,
  neboť hodnota klíče bude moci být načtena od interpretru skriptu.

  Ve vlákně popsali Black i jiní některé protokoly, které by tato kombinace
  změn konsenzu umožňovala: [LN-Symmetry][topic eltoo] (eltoo),
  [joinpooly][topic joinpools] ve stylu [Ark][topic ark], zjednodušená
  [DLC][topic dlc] a [úschovny][topic vaults] bez předem podepsaných
  transakcí. Další výhody přináší pro protokoly nižší úrovně jako
  kontrola zahlcení ve stylu CTV či delegace podpisů ve stylu CSFS.

  V době psaní zpravodaje se technická diskuze omezovala na žádosti
  o vysvětlení, které protokoly by tento návrh umožnil.

- **Návrh na soft fork pro 64bitovou aritmetiku:** Chris Stewart
  zaslal do fóra Delving Bitcoin [příspěvek][stewart 64] s [návrhem BIPu][bip
  64] na přidání 64bitových aritmetických operací do bitcoinu v budoucím
  soft forku. Bitcoin [v současnosti][script wiki] umožňuje pouze 32bitové
  operace (celá čísla se znaménkem, čísla přes 31 bitů tedy nemohou být
  použita). Podpora pro 64bitové hodnoty by byla obzvláště výhodná v
  jakýchkoliv konstruktech, které potřebují pracovat s částkou v satoshi
  placenou na výstup. Ta je specifikována jako 64bitové celé číslo.
  Například výstupovým protokolům [joinpoolu][topic joinpools] by
  se introspekce částky hodila; viz zpravodaje [č. 166][news166 tluv] (_angl._)
  a [č. 283][news283 exits].

  V době psaní zpravodaje se diskuze soustředila na podrobnosti návrhu,
  jak celá čísla kódovat, jaký způsob upgradu [taprootu][topic taproot]
  použít a zda-li je lepší představit nové aritmetické opkódy či
  využít stávající.

- **Přehled návrhu cluster mempoolu:** Suhas Daftuar zaslal do fóra
  Delving Bitcoin [souhrn][daftuar cluster] návrhu [cluster mempoolu][topic
  cluster mempool]. Optech zpravodaj se pokusil shrnout současný stav
  diskuze o cluster mempoolu ve [zpravodaji č. 280][news280 cluster], avšak
  důrazně doporučujeme přečíst si tento přehled. Daftuar je jedním z
  architektů návrhu. Jedna drobnost, kterou jsme před tím nepopsali,
  upoutala naši pozornost:

  - *CPFP carve out musí být odstraněno:* pravidlo mempoolu
    [CPFP carve out][topic cpfp carve out], které bylo do Bitcoin Core
    [přidáno][news56 carveout] v roce 2019, adresuje CPFP verzi [pinningu
    transakcí][topic transaction pinning]. V této obdobě protistrana-útočník
    zneužívá omezení v Bitcoin Core na počet a velikost souvisejících transakcí,
    aby pozdržel operace nad dceřinou transakcí patřící čestnému spojení.
    Pravidlo carve out umožňuje, aby jedna transakce tato omezení mírně
    překročila. V cluster mempoolu jsou související transakce umístěny
    do clusteru a omezení jsou aplikována na cluster, nikoliv na jednotlivé
    transakce. S tímto pravidlem není možné zajistit, aby cluster obsahoval
    maximálně jeden carve out, aniž bychom začali omezovat vztahy mezi
    přeposílanými transakcemi daleko za hranicí dnešních omezení.
    Cluster s několika carve out by mohl výrazně překročit limity,
    načež by musel být pro ně protokol přestavěn. To by sice vyhovovalo
    uživatelům carve out, ale omezovalo by to možnosti během běžného
    zveřejňování transakcí.

    Navržené řešení nekompatibility mezi carve out pravidlem a cluster
    mempoolem je [přeposílání transakcí verze 3][topic v3 transaction
    relay]. To by umožňovalo běžným uživatelům transakcí verzí 1 a 2
    pokračovat obvyklým způsobem, ale zároveň by mohli uživatelé
    protokolů jako LN zvolit použití v3 transakcí, které vynucují
    omezení sady vztahů mezi transakcemi (_topologie_). Tato omezená
    topologie by bránila pinningu transakcí a mohla by být zkombinována
    s náhradami carve out transakcí jakou jsou [dočasné anchory][topic ephemeral
    anchors].

  Je důležité, že tato velká změna správy mempoolu Bitcoin Core bere
  do úvahy všechny současné i možné budoucí způsoby používání bitcoinu.
  Proto četbu Daftuarova popisu doporučujeme vývojářům pracujícím na těžebním
  software, peněženkách či kontraktových protokolech. V případě jakýchkoliv
  nejasností nebo obav o možných negativních dopadech na bitcoin a jeho
  interakci s cluster mempoolem se můžete zapojit do diskuze.

- **Aktualizace specifikace a implementace komprese bitcoinových transakcí:**
  Tom Briar zaslal do emailové skupiny Bitcoin-Dev [příspěvek][briar compress]
  s aktualizovaným [návrhem specifikace][compress spec] a [implementace][bitcoin
  core #28134] komprimovaných bitcoinových transakcí. Menší transakce by
  byly praktičtější pro přeposílání omezenými médii, jakou jsou satelity
  či steganografie (např. zakódování transakce do bitmapového obrázku).
  Ve [zpravodaji č. 267][news267 compress] uvádíme popis původního návrhu.
  Briar popisuje významné změny: „odstranění hledání nLocktime ve prospěch
  relativní výšky bloků, která je používána všemi komprimovanými vstupy,
  a použití druhého typu celého čísla s proměnlivou délkou.”

- **Diskuze o těžaři extrahovatelné hodnotě v nenulových dočasných anchorech:**
  Gregory Sanders zaslal do fóra Delving Bitcoin [příspěvek][sanders mev]
  vyjadřující obavy o výstupech [dočasných anchorů][topic ephemeral anchors],
  které obsahují více než 0 satoshi. Dočasný anchor platí na standardizovaný
  výstupní skript, který může být utracen kýmkoliv.

  Jedním způsobem použití dočasných anchorů by bylo mít nulovou výstupní
  hodnotu, což je rozumné vzhledem k pravidlům, která vyžadují, aby byly
  doprovázeny dceřinou transakcí utrácející tento anchor výstup. Avšak
  v současném LN protokolu chce-li jedna ze stran vytvořit [neekonomické][topic
  uneconomical outputs] HTLC, je jeho částka použita na přeplacení
  onchain poplatků commitment transakce. Takové HTLC se nazývá _ořezané_
  („trimmed HTLC”). Je-li ořezávání HTLC v commitment transakci učiněno
  použitím dočasných anchorů, mohlo by být pro těžaře výdělečné, kdyby
  potvrdil transakci bez dceřiné transakce utrácející výstup dočasného
  anchoru. Po potvrzení commitment transakce není nikdo motivován k
  utracení nulového výstupu dočasného anchoru, bude tedy navždy
  okupovat prostor množiny UTXO v plných uzlech.

  Navrženou alternativou je nastavit hodnoty výstupů dočasných anchorů
  rovnající se částkám ořezaných HTLC. Bude tak výhodné těžit commitment
  transakci i utracení výstupu dočasného anchoru. Ve svém příspěvku
  Sanders tuto možnosti analyzuje. Shledává, že tento způsob může přinést
  několik bezpečnostních problémů. Ty mohou být vyřešeny těžaři, kteří
  transakce analyzují a určí, kdy by bylo výhodnější, aby sami utratili
  výstup dočasných anchorů nově vytvořenými transakcemi. Jedná se o druh
  [těžaři extrahovatelné hodnoty][news201 mev] (MEV, „miner extractable value”).
  Bylo navrženo několik dalších alternativních řešení:

  - *Přeposílání pouze takových transakcí, které jsou kompatibilní se záměry těžařů:*
    pokud by se někdo pokusil utratit dočasný anchor způsobem, který nemaximalizuje
    těžařovy příjmy, taková transakce by nebyla přeposlána.

  - *Spálení ořezané hodnoty:* namísto přeměny hodnoty ořezaného HTLC do poplatku
    může být částka utracena na `OP_RETURN` výstup. Tím by byly satoshi
    navždy neutratitelné. To by bylo možné pouze, pokud by byla commitment
    transakce s ořezaným HTLC poslána do blockchainu. V běžném případě
    jsou ořezané HTLC vyřešeny offchain a jejich hodnota je přesunuta
    od jedné strany k druhé.

  - *Zajištění snadné propagace MEV transakcí:* namísto toho, aby těžaři
    používali zvláštní kód maximalizující jejich hodnotu, usnadněme propagaci
    těchto transakcí sítí, ať může kdokoliv spustit MEV kód a přeposlat
    výsledky k těžařům způsobem, který zaručí, že všichni těžaři a
    přeposílající uzly obdrží stejnou sadu transakcí.

  V době psaní zpravodaje nebylo dosaženo jasného závěru.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK 0.0.119][] je novým vydáním této knihovny pro budování aplikací
  nabízející LN. Bylo přidáno několik nových funkcí včetně přijímání plateb
  na [zaslepené cesty][topic rv routing] s několika skoky. Vydání dále obsahuje
  opravy několika chyb a další vylepšení.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #29058][] je přípravným krokem k aktivaci [P2P přenosu
  verze 2 (BIP324)][topic v2 p2p transport] ve výchozím nastavení.
  Změna přidává podporu pro v2transport v konfiguračních argumentech
  `-connect`, `-addnode` a `-seednode`, pokud je nastaven `-v2transport`.
  Pokud spojení nepodporuje v2, použije se v1. Dále tento update
  přidává do dashboardu `netinfo` (`bitcoin-cli`) sloupeček s verzí
  přenosového protokolu.

- [Bitcoin Core #29200][] umožňuje, aby [podpora sítě I2P][topic
  anonymity networks] používala spojení šifrované pomocí „ECIES-X25519
  a ElGamal (typ 4 a 0, respektive). To umožní připojit se k I2P uzlům
  kteréhokoliv druhu. Novější a rychlejší ECIES-X25519 bude upřednostňováno.”

- [Bitcoin Core #28890][] odstraňuje konfigurační parameter `-rpcserialversion`,
  který byl dříve označen za zastaralý (viz [zpravodaj č. 269][news269 rpc]).
  Tato volba byla představena během přechodu na v0 segwit, aby umožnila
  starším programům nadále přistupovat k blokům a transakcím bez segwitových
  polí. Dnes by již všechny programy měly segwitovým transakcím rozumět
  a tato volba již nadále není zapotřebí.

- [Eclair #2808][] přidává do příkazu `open` parametr
  `--fundingFeeBudgetSatoshis`, který definuje maximální částku, jakou
  je uzel ochoten platit na onchain poplatcích za otevření kanálu. Výchozí
  hodnota je nastavena na 0,1 % částky posílané do kanálu. Eclair se pokusí
  zaplatit nižší poplatek, pokud je to možné, ale v případě nutnosti jej
  navýší až na uvedenou částku. Do příkazu `rbfopen` byl přidán totožný
  parametr, který definuje maximální částku na utracení za [RBF
  navýšení poplatku][topic rbf].

- [LND #8188][] přidává několik nových RPC volání pro rychlé získání
  debugovacích informací. Ty jsou zašifrované nějakým veřejným klíčem
  a mohou tedy být patřičným soukromým klíčem rozšifrovány. Jak je v PR
  vysvětleno, „myšlenkou je, že bychom v šabloně chybového hlášení na GitHubu
  uvedli veřejný klíč a požádali uživatele, aby spustil příkaz `lncli encryptdebugpackage`.
  Výstup potom může nahrát na GitHub a tím nám poskytnout informace, které
  normálně pro debugování potřebujeme.“

- [LND #8096][] přidává „nárazníkovou zónu pro případ vysokých poplatků.”
  V současném LN protokolu je strana, která sama financuje kanál, zodpovědná
  za placení jakýchkoliv onchain poplatků přímo obsažených v commitment
  transakci a předem podepsaných transakcích HTLC-Success a HTLC-Timeout
  (HTLC-X). Nemá-li tato strana v kanálu příliš mnoho prostředků a poplatky
  vzrostou, nemusí být schopna přijmout nové příchozí platby, neboť nemají
  dostatek peněz na zaplacení poplatků, ačkoliv právě přijímají peníze.
  Pro vyvarování se tohoto druhu problému se zaseknutými kanály doporučuje
  [BOLT2][] (jak do něj bylo před několika lety přidáno v [BOLTs #740][])
  financující straně držet rezervu, aby mohly být platby přijímány i za
  zvýšených poplatků. LND nyní také implementuje toto řešení, které je již
  obsaženo v Core Lightning i Eclair (viz zpravodaje [č. 85][news85 stuck] a
  [č. 89][news89 stuck], _angl._).

- [LND #8095][] a [#8142][lnd #8142] přidávají dodatečnou logiku do částí kódu
  LND, které zpracovávají [zaslepené trasy][topic rv routing]. Jedná se o součást
  práce na plné podpoře zaslepených tras v LND.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28134,29058,29200,28890,2808,8188,8096,8095,8142,740" %}
[morehouse delving]: https://delvingbitcoin.org/t/dos-disclosure-channel-open-race-in-cln/385
[morehouse blog]: https://morehouse.github.io/lightning/cln-channel-open-race/
[script wiki]: https://en.bitcoin.it/wiki/Script#Arithmetic
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[news283 exits]: /cs/newsletters/2024/01/03/#davkovani-plateb-pri-odchodu-z-poolu-pomoci-dokladu-o-podvodu
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[news280 cluster]: /cs/newsletters/2023/12/06/#diskuze-o-cluster-mempoolu
[news267 compress]: /cs/newsletters/2023/09/06/#komprimovane-bitcoinove-transakce
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022274.html
[compress spec]: https://github.com/bitcoin/bitcoin/blob/7e8511c1a8229736d58bd904595815636f410aa8/doc/compressed_transactions.md
[news201 mev]: /cs/newsletters/2022/05/25/#debata-o-tezari-extrahovatelne-hodnote
[news266 lnbugs]: /cs/newsletters/2023/08/30/#zverejneni-probehle-zranitelnosti-ln-spojene-s-falesnym-financovanim
[race condition]: https://cs.wikipedia.org/wiki/Soub%C4%9Bh
[morehouse full]: https://morehouse.github.io/lightning/cln-channel-open-race/
[black lnhance]: https://delvingbitcoin.org/t/lnhance-bips-and-implementation/376/
[stewart 64]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[sanders mev]: https://delvingbitcoin.org/t/ephemeral-anchors-and-mev/383/
[bip 64]: https://github.com/bitcoin/bips/pull/1538
[taproot internal key]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[news56 carveout]: /en/newsletters/2019/07/24/#bitcoin-core-15681
[news269 rpc]: /cs/newsletters/2023/09/20/#bitcoin-core-28448
[news85 stuck]: /en/newsletters/2020/02/19/#c-lightning-3500
[news89 stuck]: /en/newsletters/2020/03/18/#eclair-1319
[ldk 0.0.119]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.119
[rubin templating]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-24#24661606;
