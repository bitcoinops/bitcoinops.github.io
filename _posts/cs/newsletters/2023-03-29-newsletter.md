---
title: 'Zpravodaj „Bitcoin Optech” č. 244'
permalink: /cs/newsletters/2023/03/29/
name: 2023-03-29-newsletter-cs
slug: 2023-03-29-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu na zlepšení efektivity nakládání
s kapitálem v LN použitím nastavitelných pokut. Též nechybí naše pravidelné
rubriky se souhrnem zajímavých otázek a odpovědí z Bitcoin Stack Exchange,
oznámeními o nových vydáních a popisem významných změn v populárních
bitcoinových páteřních projektech.

{% assign S0 = "_S<sub>0</sub>_" %}
{% assign S1 = "_S<sub>1</sub>_" %}

## Novinky

- **Jak předejít uvíznutí kapitálu pomocí kanálů s více stranami a továrnami kanálů:**
  John Law [zaslal][law stranded post] do emailové skupiny Lightning-Dev
  souhrn [studie][law stranded paper], jejíž je autorem. Popisuje, jak mohou
  vždy dostupné uzly přeposílat platby, i když sdílejí kanál s uzlem, který
  je momentálně nedostupný (např. mobilní LN peněženka). Je pro to potřeba
  používat kanály s více stranami („multiparty channels”), které jsou kompatibilní
  s návrhem na továrny kanálů („channel factories”), který Law dříve představil.
  Také připomněl jednu známou výhodu [továren kanálů][topic channel factories]:
  umožňují offchain rebalancování kanálů (tj. bez nutnosti publikovat na
  blockchainu transakci), a tedy efektivnější nakládání s kapitálem. Law popisuje,
  jak využít obou výhod v kontextu svého dalšího návrhu _nastavitelných pokut_ v LN.
  V další části shrneme nastavitelné pokuty, ukážeme, jak mohou být využiti pro
  kanály s více stranami a továrnami kanálů, a vysvětlíme Lawovy závěry.

  Alice a Bob vytvoří (prozatím nepodepsanou) transakci, která od každého utrácí
  50 miliónů sat (dohromady 100 miliónů) na výstup otevírací („funding”) transakce,
  který bude pro utracení vyžadovat spolupráci obou stran. V následujících diagramech
  jsou potvrzené transakce zobrazeny s šedým pozadím.

  {:.center}
  ![Alice a Bob vytváří otevírací transakci](/img/posts/2023-03-tunable-funding.dot.png)

  Dále každý z nich použije odlišný výstup (který sami kontrolují) k vytvoření své
  _stavové transakce_ („state transaction”), kterou prozatím nepublikují. První výstup
  každé stavové transakce zaplatí nízkou částku (např. tisíc sat) jako vstup offchainové
  _commitment transakce_ s časovým zámkem. Relativní časový zámek neumožní commitment
  transakcím potvrzení na blockchainu, dokud neuběhne určitá doba od potvrzení své
  rodičovské stavové transakce. Každá z obou commitment transakcí navíc utrácí shodný
  výstup otevírací transakce, což umožní potvrzení pouze jedné z nich. Jakmile jsou
  všechny transakce vytvořeny, otevírací transakce může být podepsána a publikována.

  {:.center}
  ![Alice a Bob vytváří své commitment transakce](/img/posts/2023-03-tunable-commitment.dot.png)

  Každá z commitment transakcí utrácí aktuální stav kanálu. Ve výchozím stavu
  ({{S0}}) vrátí Alici a Bobovi po 50 miliónech sat (pro jednoduchost neuvažujeme
  poplatky). Alice a Bob mohou započít proces jednostranného uzavření kanálu
  zveřejněním své verze stavové transakce a po nezbytné prodlevě mohou publikovat
  odpovídající commitment transakci. Na příkladu Alice zveřejňuje svou stavovou a
  commitment transakci (která platí jí i Bobovi). Bob po tomto okamžiku svou
  stavovou transakci již zveřejňovat nebude a namísto toho může prostředky
  utratit podle libovůle.

  {:.center}
  ![Alice utrácí prostředky kanálu](/img/posts/2023-03-tunable-honest-spend.dot.png)

  K jednostrannému uzavření kanálu za výchozího stavu existují dvě alternativy.
  V první řadě mohou Alice a Bob spolupracovat na uzavření kanálu utracením otevírací
  transakce, jak se děje běžně v současném LN protokolu. Ve druhém případě mohou
  aktualizovat svůj stav: například navýšením Alicina zůstatku o 10 miliónů sat
  a snížením Bobova zůstatku o stejnou sumu. Stav {{S1}} je podobný výchozímu stavu
  {{S0}}, avšak aby byl použitelný, musí každá strana anulovat předchozí stav tím,
  že pošle protistraně witness[^keychain] pro utracení prvního výstupu stavové transakce
  odpovídající předchozímu stavu {{S0}}. Ani jedna ze stran nemůže použít witness
  protistrany, protože stavové transakce stavu {{S0}} ještě neobsahují witness a nemohou
  tedy být publikovány.

  Existuje-li vícero stavů, je možné nedopatřením či úmyslně zavřít kanál
  v neplatném stavu. Například se může Bob pokusit zavřít kanál ve stavu {{S0}},
  kde měl o 10 miliónů sat více, podepsáním a zveřejněním své stavové transakce
  stavu {{S0}}. Bob však kvůli časovému zámku v commitment transakci musí čekat
  určitou dobu, během které má Alice možnost jeho nekalý pokus odhalit a zabránit
  mu použitím witnessu, který předtím od Boba obdržela. Prostředky ve stavové transakci
  (tj. pokuta) budou zcela či částečně použity k platbě poplatků. Jelikož je tento výstup
  totožný s výstupem, který musí Bob později použít ke zveřejnění commitment transakce
  platící mu 10 miliónů sat navíc, nebude Bob moci si tyto prostředky nárokovat.
  Jelikož bude v tento okamžik Bob blokován, může pouze Alice jednostranně zveřejnit
  poslední stav na blockchain. I tehdy však můžou oba začít spolupracovat na
  řádném zavření kanálu.

  {:.center}
  ![Bob se pokouší podloudně utratit prostředky kanálu, je však Alicí zastaven](/img/posts/2023-03-tunable-dishonest-spend.dot.png)

  Všimne-li si Bob, že se Alice pokouší utratit z jeho předchozí stavové transakce,
  může se pokusit vstoupit s Alicí do bitvy o RBF (nahrazení transakce vyšším
  poplatkem), avšak zde se obzvláště ukáže výhoda _nastavitelnosti_ výše pokuty:
  částka pokuty může být nízká (např. tisíc sat jako v našem příkladu), může
  se rovnat sporné částce (10 miliónů sat) nebo převýšit hodnotu samotného kanálu.
  Rozhodnutí, ke kterému dospějí během aktualizace stavu kanálu, je zcela na Alici a
  Bobovi.

  Další výhoda protokolu s nastavitelnou pokutou (TPP, „Tunable-Penalty Protocol”)
  spočívá ve skutečnosti, že pokuta je zcela placena uživatelem, který se pokouší
  zveřejnit neplatnou stavovou transakci. Nepoužívají se k tomuto účelu žádné
  prostředky z otevírací transakce. To umožňuje sdílení TPP kanálu více uživateli.
  Například si můžeme představit, že Alice, Bob, Carol a Dan sdílí takový kanál
  a každý z nich drží svou vlastní commitment transakci utrácející jejich vlastní
  stavovou transakci:

  {:.center}
  ![Kanál sdílený Alicí, Bobem, Carol a Danem](/img/posts/2023-03-tunable-multiparty.dot.png)

  Mohou jej provozovat jako kanál s více stranami, který vyžaduje, aby byl
  kažý stav anulován každým účastníkem. Jinou možností je použití společné
  otevírací transakce jako továrny kanálů a otevření několika kanálů mezi
  skupinami uživatelů. Před tím, než loni Law představil tento důsledek TPP
  (viz [zpravodaj č. 230][news230 tp]), se věřilo, že praktická implementace
  továrny kanálů nad bitcoinem by vyžadovala nějaký mechanismus jako [eltoo][topic
  eltoo] (který je podmíněn změnou konsenzu jako např. [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout]). TPP nevyžaduje žádnou změnu konsenzu. Následující diagram
  zobrazuje jediný kanál vytvořený továrnou se čtyřmi účastníky. Počet stavů,
  který musí účastníci spravovat, se rovná počtu účastníků v továrně, i když
  Law již [dříve popsal][law factories] alternativní schéma s jediným stavem
  ale vyššími náklady na jednostranné zavření.

  {:.center}
  ![Kanál mezi Alicí a Bobem vytořený z továrny s Alicí, Bobem, Carol a Danem](/img/posts/2023-03-tunable-factory.dot.png)

  Výhodou továren kanálů, jak byly popsány [v původním článku][channel factories
  paper], je možnost účastníků v rámci továrny kooperativně rebalancovat své
  kanály bez nutnosti vytvářet transakce na blockchainu. Mějme například
  továrnu s účastníky Alicí, Bobem, Carol a Danem. Potom může být celková
  hodnota kanálu mezi Alicí a Bobem snížena a hodnota kanálu mezi Carol a Danem
  může být zvýšena o stejnou částku aktualizací offchain stavu továrny.
  Lawovy továrny založené na TPP nabízí stejnou výhodu.

  Tento týden Law poznamenal, že továrny se schopností poskytovat kanály
  s více účastníky (které jsou s TPP možné) mají ještě jednu výhodu:
  umožňují používat kapitál, i když je jedna ze stran kanálu nedostupná.
  Představme si například, že Alice a Bob mají vyčleněné LN uzly, které
  jsou téměř vždy dostupné a schopné přeposílat platby, ale Carol a Dan
  jsou běžní uživatelé, jejichž uzly jsou často nedostupné. Dle původního
  návrhu továren má Alice kanál s Carol ({A,C}) a Danem ({A,D}). Alice
  ale nemůže použít žádné prostředky těchto dvou kanálů, jsou-li Carol
  a Dan nedostupní. Bob má stejný problém ({B,C} a {B,D}).

  V případě továrny založené na TPP mohou Alice, Bob a Carol spolu otevřít kanál
  s více stranami, což bude během aktualizace stavu vyžadovat spolupráci všech tří.
  Jeden z výstupů commitment transakce tohoto kanálu posílá prostředky Carol,
  ale druhý výstup může být utracen jen, když Alice a Bob spolupracují. Je-li
  Carol nedostupná, Alice a Bob mohou offline kooperativně změnit distribuci zůstatku
  jejich společného výstupu, což jim umožní vytvářet nebo přeposílat LN platby,
  pokud mají otevřené i jiné kanály. Zůstává-li Carol nedostupná příliš dlouho,
  může kdokoliv z nich jednostranně kanál uzavřít. Stejné výhody existují,
  i když Alice a Bob sdílí kanál s Danem.

  Alici a Bobovi to umožňuje vydělávat na poplatcích, i když jsou Carol a
  Dan nedostupní. Schopnost rebalancovat kanály offchain odstraňuje Alici a Bobovi
  některé nevýhody spojené s držením prostředků v továrně kanálu po delší dobu.
  Tyto výhody mohou dohromady snížit počet transakcí na blockchainu, zvýšit
  kapacitu bitcoinové sítě a snížit náklady na přeposílání plateb po LN.

  V době psaní zpravodaje neobdržely nastavitelné pokuty a další Lawovy
  návrhy mnoho reakcí.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč není v Bitcoin Core nasazení taprootu trvale usazeno?]({{bse}}117569)
  Andrew Chow vysvětluje důvody, proč není [nasazení][topic soft fork activation]
  soft forku taprootu trvale [usazeno][BIP90] („buried”), jako v případě
  [jiných soft forků][bitcoin buried deployments].

- [Jaká omezení má hodnota verze v hlavičce bloku?]({{bse}}117530)
  Murch poukazuje na nárůst [bloků][explorer block 779960] vytěžených použitím
  [otevřeného ASICBoostu][topic ASICBoost], vyjmenovává omezení hodnoty verze
  a prochází několika příklady [verzí hlavičky bloku][FCAT block header blog].

- [Jaký je vztah mezi daty transakce a jejími identifikátory?]({{bse}}117453)
  Pieter Wuille vysvětluje zastaralý serializační formát transakce (identifikátor
  `txid`), serializační formát rozšířený o witnessy (`hash` a `wtxid`)
  a v [separátní odpovědi][se117577] poznamenává, že přidaná hypotetická
  data by spadala pod identifikátor `hash`.

- [Mohu od ostatních spojení obdržet jednotlivé transakce?]({{bse}}117546)
  Uživatel RedGrittyBrick poukazuje na zdroje vysvětlující důvody –
  [výkonnost][wiki getdata] a [soukromí][Bitcoin Core #18861] – stojící
  za nemožností vyžádat si pomocí Bitcoin Core od spojení konkrétní transakce.

- [Eltoo: Určuje časový zámek prvního UTXO životnost kanálu?]({{bse}}117468)
  Murch potvrzuje, že příklad [eltoo][topic eltoo] kanálu obsažený v otázce
  má omezenou životnost a odkazuje na [eltoo whitepaper][], který uvádí možnosti,
  jak expiracím zamezit.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Rust Bitcoin 0.30.0][] je posledním vydání této knihovny nabízející
  datové struktury pro práci s bitcoinem. [Poznámky k vydání][rb rn]
  zmiňují [novou webovou stránku][rust-bitcoin.org] a velké množství
  změn API.

- [LND v0.16.0-beta.rc5][] je kandidátem na vydání nové hlavní verze
  této oblíbené implementace LN.

- [BDK 1.0.0-alpha.0][] je zkušebním vydáním významných změn BDK
  popsaných v [minulém vydání zpravodaje][news243 bdk]. Vývojáři
  projektů používajících BDK jsou vyzváni, aby započali s testováním
  integrace.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27278][] přidává ve výchozím stavu logování
  obdržených hlaviček nových bloků (pokud neprobíhá prvotní stahování).
  Tato změna byla [inspirována][obeirne selfish] několika provozovateli
  uzlů, kteří si všimli tří bloků obdržených ve velmi těsné blízkosti.
  Poslední dva z těchto bloků způsobily reorganizaci blockchainu a
  tím z něj odstranily první blok. Nazývejme první blok _A_, jeho
  náhradu _A'_ a poslední blok _B_.

  Tato situace naznačuje, že bloky A' a B byly vytvořeny jedním
  těžařem, který záměrně pozdržel jejich zveřejnění do doby, kdy
  byl blok jiného těžaře reorganizací zneplatněn, a tím mu tak odepřel
  odměnu, kterou by jinak za A obdržel. Tento druh útoku se nazývá
  _sobecká těžba_ („selfish mining”). Mohlo by se ale také jednat pouze o náhodu.
  Nicméně jinou možností, na kterou během vyšetřování [poukázali][sanders requests]
  vývojáři, je, že časy možná nebyly tak blízko, jak se původně zdálo.
  Je možné, že Bitcoin Core si vyžádal A' až po obdržení B, jelikož
  blok A' samotný by reorganizaci nespustil.

  Logování času přijetí hlaviček znamená, že pokud by se podobná
  situace znovu opakovala, mohli by provozovatelé uzlu určit, kdy se
  jejich uzel poprvé dozvěděl o existenci bloku A', i když se rozhodl jej
  zatím nestáhnout. Toto logování může přidat až dva řádky na blok
  (i když budoucí PR je může omezit na jediný řádek), což se považuje
  za přijatelné množství, může-li to pomoci odhalit sobeckou těžbu a
  jiné související problémy.

- [Bitcoin Core #26531][] přidává trasovací body pro monitorování
  událostí ovlivňující mempool použitím Extended Berkeley Packet Filter
  (eBPF), jehož podpora byla přidaná dříve (viz [zpravodaj č. 133][news133
  usdt], *angl.*). Též byl přidán skript, který tyto trasovací body
  umí v reálném čase využít pro tvorbu statistiky a monitorování aktivity
  mempoolu.

- [Core Lightning #5898][] aktualizuje svou závislost na [libwally][]
  (viz [zpravodaj č. 238][news238 libwally]), která umožnila přidání
  podpory pro [taproot][topic taproot], [PSBT][topic psbt] verze 2
  (viz [zpravodaj č. 128][news128 psbt2], *angl.*) a má dopad na
  podporu sidechainů ve stylu Elements.

- [Core Lightning #5986][] upravuje RPC volání vracející hodnoty
  v jednotkách msat: tato volání již nebudou ve výsledku obsahovat
  řetězec „msat”. Namísto toho budou všechny výsledky číselné.
  Tato změna značí konec procesu zastarání, který začal před několika
  vydáními, viz [zpravodaj č. 206][news206 msat] (*angl.*).

- [Eclair #2616][] přidává podporu pro příležitostné [zero-conf
  kanály][topic zero-conf channels]. Pošle-li protistrana zprávu
  `channel_ready` ještě před očekávaným počtem konfirmací,
  Eclair ověří, že byla otevírací transakce zcela vytvořena sebou
  samým (aby nemohla protistrana zveřejnit konfliktní transakci)
  a následně umožní kanál používat.

- [LDK #2024][] přináší začleňování návrhů tras („route hints”) pro kanály,
  které byly již otevřeny, ale ještě nebyly veřejně oznámeny, jako jsou
  např. [zero-conf kanály][topic zero-conf channels].

- [Rust Bitcoin #1737][] přidává do projektu [pravidla pro bezpečnostní
  reportování][rb sec].

- [BTCPay Server #4608][] umožňuje pluginům zpřístupnit své funkce jako
  aplikace v rozhraní BTCPay.

- [BIPs #1425][] přisuzuje číslo [BIP93][] schématu codex32 pro kódování
  obnovy seedu podle [BIP32][]. Schéma používá Shamirovo schéma sdílení
  tajných dat (SSSS), kontrolní součet a 32znakovou abecedu. Vše bylo
  popsáno ve [zpravodaji č. 239][news239 codex32].

- [Bitcoin Inquisition #22][] přidává runtime volbu `-annexcarrier`,
  která umožní nastavit 0 až 126 bytů dat pro pole annex taprootového
  vstupu. Autor PR plánuje tuto volbu využít pro umožnění experimentů
  s [eltoo][topic eltoo] (na signetu) za použití forku Core Lightning.

## Poznámky

[^keychain]:
    V tomto náhledu není důležité popisovat obsah witnessu, ale některé
    z uvedených výhod na těchto detailech závisí. Původní protol [nastavitelných
    pokut][Tunable Penalties] navrhuje zveřejnit tajný klíč použitý k
    vygenerování podpisu utracení commitment transakce. Je možné vygenerovat
    tajné klíče sekvenčně tak, aby každý, kdo zná jeden klíč, mohl také
    odvodit následující klíče (ale ne předchozí). To znamená, že vždy,
    když Alice revokuje pozdější stav, může dát Bobovi dřívější klíč, který
    může Bob použít k odvození jakéhokoliv pozdějšího klíče (pro dřívější
    stav). Příklad:

    | Stav kanálu | Stav klíče |
    | 0     | MAX |
    | 1     | MAX - 1 |
    | 2     | MAX - 2 |
    | x     | MAX - x |
    | MAX   | 0 |

    Toto Bobovi umožňuje efektivně ukládat všechny informace, které potřebuje
    k utracení již neplatné stavové transakce (podle našich výpočtů méně
    než 100 bytů). Tyto informace můžou být snadno sdílené se [strážními
    věžemi][topic watchtowers] („watchtowers”). Ty nevyžadují důvěru, jelikož
    každé úspěšné utracení zastaralé stavové transakce zabrání publikování
    zastaralé commitment transakce. Jelikož patří všechny prostředky v této
    zastaralé stavové transakci straně, která porušuje protokol, nepřináší
    sdílení informací o jejím utrácení žádné bezpečnostní riziko.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27278,26531,5898,5986,2616,2024,1737,4608,1425,22,18861" %}
[lnd v0.16.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc5
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[rust bitcoin 0.30.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.30.0
[news230 tp]: /cs/newsletters/2022/12/14/#navrh-na-ln-protokol-pro-tovarny
[channel factories paper]: https://tik-old.ee.ethz.ch/file//a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf
[law factories]: https://raw.githubusercontent.com/JohnLaw2/ln-efficient-factories/main/efficientfactories10.pdf
[news206 msat]: /en/newsletters/2022/06/29/#core-lightning-5306
[rb sec]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/SECURITY.md
[news239 codex32]: /cs/newsletters/2023/02/22/#navrh-bip-pro-kodovani-seedu-codex32
[law stranded post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003886.html
[law stranded paper]: https://github.com/JohnLaw2/ln-hierarchical-channels
[obeirne selfish]: https://twitter.com/jamesob/status/1637198454899220485
[sanders requests]: https://twitter.com/theinstagibbs/status/1637235436849442817
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[libwally]: https://github.com/ElementsProject/libwally-core
[news128 psbt2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[tunable penalties]: https://github.com/JohnLaw2/ln-tunable-penalties
[news238 libwally]: /cs/newsletters/2023/02/15/#vydana-libwally-0-8-8
[rust-bitcoin.org]: https://rust-bitcoin.org/
[rb rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/bitcoin/CHANGELOG.md#030---2023-03-21-the-first-crate-smashing-release
[news243 bdk]: /cs/newsletters/2023/03/22/#bdk-793
[bitcoin buried deployments]: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/params.h#L19
[explorer block 779960]: https://blockstream.info/block/00000000000000000003a337a676b0101f3f7ef7dcbc01debb69f85c6da04dcf?expand
[FCAT block header blog]: https://medium.com/fcats-blockchain-incubator/understanding-the-bitcoin-blockchain-header-a2b0db06b515#b9ba
[se117577]: https://bitcoin.stackexchange.com/a/117577/87121
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[eltoo whitepaper]: https://blockstream.com/eltoo.pdf#page=15
