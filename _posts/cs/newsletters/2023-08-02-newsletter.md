---
title: 'Zpravodaj „Bitcoin Optech” č. 262'
permalink: /cs/newsletters/2023/08/02/
name: 2023-08-02-newsletter-cs
slug: 2023-08-02-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme odkazy na přepisy nedávného setkání o specifikaci
LN a souhrn diskuze o bezpečnosti zaslepeného MuSig2 podepisování.
Též nechybí naše pravidelné rubriky s popisem nových vydání, kandidátů
na vydání a významných změn v populárních bitcoinových páteřních
projektech.

## Novinky

- **Přepisy pravidelných setkání o specifikaci LN:** Carla
  Kirk-Cohen zaslala do emailové skupiny Lightning-Dev [příspěvek][kc scripts]
  s oznámením, že byly pořízeny přepisy několika posledních videokonferencí,
  ve kterých se diskutovaly změny specifikace LN. Přepisy jsou nyní
  [dostupné][btcscripts spec] na webové stránce Bitcoin Transcripts.
  A ještě jedna související informace: jak bylo diskutováno před několika
  týdny během osobního setkání vývojářů LN, IRC skupina `#lightning-dev` na
  [Libera.chat][] zaznamenala v poslední době významný vzestup aktivity.

- **Bezpečnost zaslepeného podepisování v MuSig2:** Tom Trevethan zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][trevethan blind] se žádostí
  o posouzení kryptografického protokolu zamýšleného jako součást nasazení
  [statechainů][topic statechains]. Cílem je nasazení služby, která by
  používala své klíče k vytváření částečných [MuSig2][topic musig]
  elektronických podpisů, aniž by se mohla cokoliv dozvědět o předmětu
  či účelu podepisování. Služba by jen oznamovala, kolik podpisů s
  konkrétními klíči vytvořila.

  Přispěvatelé do diskuze ze zabývali úskalími různých konstruktů
  souvisejících s tímto problém či [obecně s vytvářením zaslepených
  Schnorrových podpisů][generalized blind schnorr]. Zmíněn byl též
  loňský [gist][somsen gist] od Rubena Somsena o protokolu zaslepené
  [Diffieho-Hellmanovy (DH) výměny klíčů][dhke], který může být použit pro
  zaslepený ecash. Předchozími implementacemi tohoto schématu jsou
  například [Lucre][] a [Minicash][], další související implementací
  je [Cashu][], která navíc integruje podporu bitcoinu a LN. Zájemcům
  o kryptografii může tato diskuze přinést podnětné informace o
  kryptografických technikách.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 1.11.1][] je nejnovějším vydáním tohoto platebního procesoru.
  Vydání přináší vylepšení ve vykazování faktur a pokladních procesech a
  přináší nové funkce pro platební terminály.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26467][] umožňuje uživatelům při použití `bumpfee`
  určit, který výstup transakce je určen pro zůstatek. Peněženka během
  vytváření [nahrazující transakce][topic rbf] pro navýšení poplatků
  odečítá hodnotu z tohoto výstupu. Ve výchozím stavu se peněženka pokouší
  výstup pro drobné určit automaticky a pokud jej nenalezne, vytváří nový.

- [Core Lightning #6378][] a [#6449][core lightning #6449] bude označovat
  offchain příchozí [HTLC][topic htlc] za neúspěšné, je-li uzel neschopen
  (či neochoten kvůli poplatkům) dosáhnout zrušení příslušného onchain HTLC.
  Příklad: Alicin uzel přepošle Bobovu uzlu HTLC s expirací 20 bloků
  a Bobův uzel přepošle Carol HTLC se stejným platebním kódem s expirací
  10 bloků. Nato je kanál mezi Bobem a Carol nuceně uzavřen onchain.

  Po expiraci po 10 blocích nastane situace, která by se však často přihodit
  neměla: Bobův uzel se buď bude snažit o refundaci, ale tato transakce
  se nepotvrdí, nebo se rozhodne, že náklady na získání refundace by byly
  vyšší než její výsledek a refundační transakci nevytvoří. Před touto
  změnou by Bobův uzel nevytvořil offchain zrušení HTLC od Alice, protože
  by to umožnilo Alici nechat si peníze, které mu přeposlala, a Carol
  nárokovat peníze přeposlané jí Bobem. Bob by tak přišel o hodnotu HTLC.

  Avšak po expiraci HTLC od Alice po 20 blocích může Alice nuceně uzavřít
  kanál a tím se pokusit obdržet refundaci částky, kterou přeposlala
  Bobovi. Její software tak může učinit automaticky, aby zabránil
  ztrátě Aliciných prostředků nárokováním od uzlů ležících dále v platební
  cestě. Pokud ale nuceně uzavře kanál, může se ocitnout ve stejné
  situaci jako Bob: buď není schopna refundaci nárokovat nebo se o ní z
  ekonomických důvodů ani nepokusí. Znamená to, že kanál mezi Alicí
  a Bobem by byl zavřen zcela bezdůvodně. Tento problém by se mohl opakovat
  několikrát po cestě dále od Alice. Jeho výsledkem by byl řetězec
  nechtěně zavřených kanálů.

  V rámci tohoto PR je problém řešen tak, že Bob bude čekat co nejdelší
  rozumnou dobu před tím, než bude refundaci nárokovat. Pokud se mu to
  nepodaří, vytvoří offchain zrušení HTLC od Alice, což jim umožní pokračovat
  v provozování kanálu, i když tím Bob může přijít o hodnotu HTLC.

- [Core Lightning #6399][] přidává podporu pro příkaz `pay`, který
  zaplatí faktury vytvořené lokálním uzlem. Může se díky němu zjednodušit
  kód software, který spravuje účty a volá CLN. Podrobnosti lze
  nalézt v nedávném [vlákně][fiatjaf custodial] v emailové skupině.

- [Core Lightning #6389][] přidává volitelnou službu CLNRest, „jednoduchý
  plugin napsaný v Pythonu, který překládá RPC volání na REST. Díky
  generování endpointů REST API umožňuje v pozadí volat RPC metody Core
  Lightningu a vracet odpovědi v JSON.” [Dokumentace][clnrest doc]
  obsahuje další informace.

- [Core Lightning #6403][] a [#6437][core lightning #6437] přemisťují
  mechanismus autorizace a autentizace (pomocí protokolu _runes_, tedy „runy”) z
  pluginu commando (viz [zpravodaj č. 210][news210 commando], *angl.*)
  do samotného jádra. Díky tomu bude moci být používán i dalšími pluginy.
  Dále bylo aktualizováno i několik příkazů souvisejících s vytvářením,
  rušením a přejmenováním run.

- [Core Lightning #6398][] rozšiřuje RPC volání `setchannel` o novou volbu
  `ignorefeelimits`, díky které nebude bráno v potaz nastavení minimálního
  onchain poplatku kanálu. Umožní to druhé, vzdálené straně nastavit jednotkový
  poplatek pod minimum místního uzlu. Volba může být použita pro obcházení
  potenciálních chyb v jiných implementacích LN uzlů či pro urovnání sporů
  o poplatky v případě problémů s částečně důvěryhodnými kanály.

- [Core Lightning #5492][] přidává staticky definované uživatelské trasovací
  body (User-level Statically Defined Tracepoints, USDT). Umožní uživatelům
  sledovat operace uvnitř uzlu za účelem ladění, aniž by významně
  utrpěla výkonnost. [Zpravodaj č. 133][news133 usdt] (*angl.*) informuje
  o předešlém začlenění USDT do Bitcoin Core.

- [Eclair #2680][] přidává podporu pro protokol _quiescence_, který je vyžadován
  pro [splicing ][topic splicing] podle návrhu v [BOLTs #863][].
  Protokol quiescence („chvíle ticha”) dočasně zabraňuje oběma uzlům sdílejícím
  kanál posílat si navzájem nová [HTLC][topic htlc], dokud se neukončí nějaká
  operace, jako je například vyjednávání o parametrech splicingu a kooperativní
  podepisování onchain transakcí pro splice-in a splice-out. HTLC přijatá
  během vyjednávání o splicingu a podepisování by mohla zneplatnit předchozí
  vyjednávání a podpisy, je tedy jednodušší pozastavit přeposílání HTLC po
  nezbytnou dobu. Eclair již splicing podporuje, ale tato změna
  jej přináší blíže k protokolu ostatních implementací LN uzlů.

- [LND #7820][] přidává do RPC volání `BatchOpenChannel` všechna pole, která
  jsou obsažena v nedávkovém volání `OpenChannel` s dvěma výjimkami:
  `funding_shim` (není pro dávkové otvírání kanálů potřebné) a `fundmax`
  (neboť při otevírání většího množství kanálů nelze alokovat všechny prostředky
  jedinému z nich).

- [LND #7516][]  rozšiřuje RPC volání `OpenChannel` o nový parametr `utxo`,
  který umožní určit jedno či více UTXO, která by měla být použita pro
  financování kanálu.

- [BTCPay Server #5155][] přidává do administrace stránku s výkazy o platbách
  a onchain peněženkách a možnost exportovat je do CSV. Její funkčnost lze rozšířit
  pluginy.

{% include references.md %}
{% include linkers/issues.md v=2 issues="863,26467,6378,6449,6399,6389,6403,6437,6398,5492,2680,7820,7516,5155" %}
[clnrest doc]: https://github.com/rustyrussell/lightning/blob/02c2d8a9e3b450ce172e8bc50c855ac2a16f5cac/plugins/clnrest/README.md
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[kc scripts]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004025.html
[btcscripts spec]: https://btctranscripts.com/lightning-specification/
[libera.chat]: https://libera.chat/
[trevethan blind]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021792.html
[generalized blind schnorr]: https://gist.github.com/moonsettler/05f5948291ba8dba63a3985b786233bb
[somsen gist]: https://gist.github.com/RubenSomsen/be7a4760dd4596d06963d67baf140406
[lucre]: https://github.com/benlaurie/lucre
[minicash]: https://github.com/phyro/minicash
[cashu]: https://github.com/cashubtc/cashu
[fiatjaf custodial]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004008.html
[news210 commando]: /en/newsletters/2022/07/27/#core-lightning-5370
[dhke]: https://cs.wikipedia.org/wiki/Diffieho%E2%80%93Hellmanova_v%C3%BDm%C4%9Bna_kl%C3%AD%C4%8D%C5%AF
[btcpay server 1.11.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.11.1
