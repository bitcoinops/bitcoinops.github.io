---
title: 'Zpravodaj „Bitcoin Optech” č. 322'
permalink: /cs/newsletters/2024/09/27/
name: 2024-09-27-newsletter-cs
slug: 2024-09-27-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje opravenou zranitelnost postihující starší
verze Bitcoin Core, poskytuje aktualizaci hybridní ochrany před zahlcováním
kanálu, shrnuje článek o efektivnější a soukromější validaci na straně klienta
a oznamuje návrh na změnu procesu přijímání BIPů. Též nechybí naše pravidelné
rubriky se souhrnem oblíbených otázek a odpovědí z Bitcoin Stack Exchange,
oznámeními nových vydání a popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Odhalení zranitelnosti postihující Bitcoin Core před verzí 24.0.1:**
  Antoine Poinsot zaslal do emailové skupiny Bitcoin-Dev [příspěvek][poinsot
  headers] s odkazem na oznámení zranitelnosti, která postihovala starší
  verze Bitcoin Core s ukončenou podporou nejméně od prosince 2023.
  Předchozím odhalením starších zranitelností jsme se věnovali ve zpravodajích
  [č. 310][news310 bcc] a [č. 314][news314 bcc].

  Nové odhalení se zaobírá dlouho známou metodou způsobující pád plných
  uzlů Bitcoin Core: poslat jim dlouhé sekvence hlaviček bloků, které se
  budou ukládat v paměti. Každá hlavička bloku má 80 bajtů a bez dalších
  ochran by bylo možné je vytvářet s minimální námahou. Útočník by jich
  mohl s moderními ASIC zařízeními produkovat milióny za sekundu. Bitcoin
  Core je proti tomu již mnoho let chráněn díky vedlejšímu efektu kontrolních
  bodů přidaných v raných verzích. Útočník tak musí vyvinout značné úsilí
  k vytvoření vysokého proof of work, za který by ale mohl být placen,
  pokud by vytvářel validní bloky.

  Avšak poslední kontrolní bod byl přidán před více než deseti lety a vývojáři
  Bitcoin Core se nemají k přidání nových, neboť by to dávalo chybný dojem,
  že konečnost transakcí závisí na vývojářích a kontrolních bodech. Díky
  vývoji těžebního vybavení a nárůstu celkového hashrate v síti se náklady
  na generování falešných řetězců hlaviček snížily. Jak se náklady snižovaly,
  výzkumníci David Jaenson a Braydon Fuller nezávisle útok [zodpovědně
  nahlásili][topic responsible disclosures] vývojářům Bitcoin Core. Vývojáři
  odpověděli, že o problému ví a vybídli v roce 2019 Fullera ke [zveřejnění][fuller
  dos] [článku][fuller paper] o útoku.

  V roce 2022 se náklady na provedení útoku dále snížily a skupina vývojářů
  začala pracovat na řešení, které nevyžadovalo kontrolní body. Bitcoin Core PR
  #25717 (viz [zpravodaj č. 216][news216 checkpoints], _angl._) byl výsledkem
  této snahy. Později Niklas Gögge odhalil v logice opravy chybu a otevřel
  [PR #26355][bitcoin core #26355] s opravou. Obě opravy byly začleněny a vydány
  v Bitcoin Core 24.0.1.

- **Testování a obměna hybridní ochrany před zahlcováním:** Carla Kirk-Cohen
  zaslala do fóra Delving Bitcoin [příspěvek][kc jam] popisující rozličné
  pokusy o proražení této ochrany proti [útokům zahlcením kanálu][topic channel
  jamming attacks], kterou původně navrhli Clara Shikhelman a Sergei Tikhomirov.
  Hybridní ochrana před zahlcením spočívá v kombinaci [HTLC atestací][topic htlc
  endorsement] a drobného _poplatku předem_, který se bezpodmínečně zašle
  bez ohledu na úspěch či selhání platby.

  Několik vývojářů bylo vyzváno k pokusu o [zahlcení kanálu na jednu hodinu][kc
  attackathon], zatímco Kirk-Cohen a Shikhelman zkoumaly slibné druhy útoků.
  Většina útoků selhala; buď proto, že útočník utratil více než s jiným druhem
  útoku, nebo proto, že oběť útoku nakonec obdržela více peněz, než kolik
  by získala běžným přeposíláním.

  Jeden útok byl úspěšný: [sink attack][], který „má za cíl snížit reputaci
  spojení cíleného uzlu. Dosahuje toho vytvářením kratších a levnějších cest
  v síti a sabotováním plateb směrovaných přes jeho kanály. Tím se sníží reputace
  všech uzlů, které ho v cestě předcházejí.” Pro mitigaci útoku přidaly
  Kirk-Cohen a Shikhelman do způsobu evaluace HTLC atestací [obousměrnou
  reputaci][bidirectional reputation]. Když Bob obdrží od Alice
  platbu, která má být přeposlána Carol (např. `A -> B -> C`), Bob jednak zváží,
  zda Alice obvykle posílá HTLC, která jsou rychle urovnána (jako u stávajících
  HTLC atestací), ale  také zda Carol obvykle obdrží HTLC, která jsou rychle
  urovnána (toto je novinka). Nyní když Bob obdrží od Alice HTLC s atestací:

  - Pokud Bob věří, že Alice a Carol jsou spolehlivé, přepošle Carol Alicino HTLC
    spolu s atestací .

  - Pokud si Bob myslí, že pouze Alice je spolehlivá, nepřepošle Alicino HTLC
    s atestací. Okamžitě jej odmítne a umožní propagovat chybu zpět k odesílateli,
    který bude moci provést platbu znova po jiné trase.

  - Pokud si Bob myslí, že pouze Carol je spolehlivá, přijme Alicino HTLC
    s atestací, má-li kapacitu navíc, ale sám atestaci během přeposílání
    směrem ke Carol nepřipojí.

  Jelikož nastala v návrhu tato změna, plánují Kirk-Cohen a Shikhelman
  další experimenty, aby zaručily, že vše funguje dle očekávání. Dále též
  odkázaly na [příspěvek][posen bidir] od Jima Posena z května 2018, který
  popisuje obousměrný systém reputací pro zabránění útoků zahlcením (tehdy
  nazývaných _cyklické útoky_, loop attacks), jako příklad dřívějšího
  uvažování nad řešením tohoto problému.

- **Shielded client-side validation (CSV):** Jonas Nick, Liam Eagen a
  Robin Linus zaslali do emailové skupiny Bitcoin-Dev [příspěvek][nel post]
  o novém protokolu [validace na straně klienta][topic client-side validation].
  Validace na straně klienta umožňuje zabezpečit přenos tokenů bitcoinovým
  proof of work bez nutnosti zveřejňovat jakékoliv informace o těchto
  tokenech či jejich pohybu. Validace na straně klienta je klíčovou
  komponentou protokolů jako [RGB][topic client-side validation] či
  [Taproot Assets][topic client-side validation].

  Nevýhodou existujících protokolů je množství dat, která musí být klientem
  validována. V nejhorším případě to může být až celá historie každého
  transferu daného tokenu plus všech tokenů s ním souvisejících. Jinými
  slovy by u tokenů tak často posílaných jako bitcoiny musel klient validovat
  historii zhruba stejně velkou, jako je celý bitcoinový blockchain.
  Vedle nákladů na přenos těchto dat a na procesorový čas snižuje
  nutnost přenášet plnou historii soukromí předchozích příjemců tokenů.
  Na druhou stranu, Shielded CSV používá důkazy s nulovou znalostí.
  Pro ověření je tak potřeba pevně dané množství zdrojů bez nutnosti
  odhalit předchozí transfery.

  Dalším záporem stávajících protokolů je, že každý transfer tokenu
  vyžaduje přidat data do nějaké bitcoinové transakce. Shielded CSV
  umožňuje sloučit několik přesunů dohromady do 64 bajtů. Díky tomu
  mohou být přidáním 64 bajtů do jediné bitcoinové transakce potvrzeny
  tisíce transferů.

  Článek přináší další podrobnosti. Obzvláště zajímavé jsme shledali
  myšlenky přemostění bitcoinu z hlavního blockchainu na Shielded CSV
  a zpět bez požadavku na důvěru a bez nutnosti změny konsenzu pomocí
  [BitVM][topic acc], používání účtů (sekce 2), diskuzi o dopadech
  reorganizace blockchainu na účty a přenosy (též sekce 2),
  související diskuzi o závislosti na nepotvrzených transakcích (sekce
  5.2) a seznam možných rozšíření (příloha A).

- **Návrh aktualizace procesu přijímání BIPů:** Mark „Murch” Erhardt
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][erhardt post]
  s oznámením dostupnosti [pull requestu][erhardt pr] s návrhem BIPu,
  který popisuje aktualizovaný proces pro repozitář BIPů. Zájemci jsou
  vyzýváni k přečtení a komentování. Pokud komunita návrh akceptuje,
  budou tento proces editoři BIPů používat.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jaké konkrétní verifikace se provádí u čerstvé bitcoinové transakce a v jakém pořadí?]({{bse}}124221)
  Murch vyjmenovává kontroly validity prováděné Bitcoin Core nad novou transakcí v době
  přidání do mempoolu, včetně kontrol prováděných v `CheckTransaction`, `PreChecks`,
  `AcceptSingleTransaction` a jiných souvisejících funkcích.

- [Proč zabírá adresář s bitcoinem více prostoru, než je můj limit ořezaných dat?]({{bse}}124197)
  Pieter Wuille poznamenává, že zatímco volba `prune` omezuje velikost blockchainových
  dat v Bitcoin Core, jiné soubory jako chainstate, index, záloha mempoolu, peněženky a jiné
  tomuto limitu nepodléhají a mohou růst nezávisle.

- [Co musím nastavit, aby `getblocktemplate` fungoval?]({{bse}}124142)
  Uživatel CoinZwischenzug se též [ptá]({{bse}}124160), jak spočítat Merkleův kořen
  a coinbasovou transakci. Odpovědi na obě otázky (od Vojtěcha Strnada, RedGrittyBricka
  a Pietera Wuilleho) podobně naznačují, že zatímco příkaz `getblocktemplate` v Bitcoin
  Core umí sestavit kandidáty na bloky s transakcemi a hlavičkami bloků, coinbasové
  transakce jsou během těžby na netestových sítích vytvářené těžebním softwarem
  nebo softwarem [těžebního poolu][topic pooled mining].

- [Může být adresa tichých plateb spočítána hrubou silou?]({{bse}}124207)
  Josie odkazuje na [BIP352][] a nastiňuje kroky potřebné k odvození adresy
  [tiché platby][topic silent payments]. Uzavírá tvrzením, že použití hrubé síly
  ke kompromitaci tichých plateb není proveditelné.

- [Proč transakce neprojde přes `testmempoolaccept` BIP125 nahrazení, ale je přijata pomocí `submitpackage`?]({{bse}}124269)
  Ava Chow vysvětluje, že `testmempoolaccept` vyhodnocuje transakce pouze jednotlivě
  a v důsledku tak [RBF][topic rbf] příklad z [průvodce testováním][bcc testing rbf]
  Bitcoin Core 28.0 hlásí odmítnutí. Avšak jelikož [`submitpackage`][news272 submitpackage]
  vyhodnocuje rodiče i potomka dohromady jako [balíček][topic package relay],
  rodič i potomek jsou oba přijati.

- [Jak se počítá banovací skóre spojení?]({{bse}}117227)
  Brunoerg odkazuje na [Bitcoin Core #29575][new309 ban score], které změnilo výpočet
  skóre špatného chování spojení v určitých situacích, jež dále vyjmenovává.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 1.0.0-beta.4][] je kandidátem na vydání této knihovny pro budování peněženek
  a jiných bitcoinových aplikací. Původní rustový balíček `bdk` byl přejmenován
  na `bdk_wallet` a moduly nižší úrovně byly extrahovány do samostatných balíčků:
  `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`. Balíček
  `bdk_wallet` „je první verzí nabízející stabilní 1.0.0 API.”

- [Bitcoin Core 28.0rc2][] je kandidátem na vydání příští hlavní verze této převládající
  implementace plného uzlu. K dispozici je [průvodce testování][bcc testing].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Eclair #2909][] přidává do RPC příkazu `createinvoice` parametr `privateChannelIds`,
  který slouží k přidání návrhů tras do BOLT11 faktur. Tím se opravuje
  chyba, která zabránila uzlům majícím pouze [soukromé kanály][topic unannounced channels]
  obdržet jakékoliv platby. Pro zachování soukromí by se měl používat `scid_alias`.

- [LND #9095][] a [LND #9072][] přináší úpravy v modifikátoru [HTLC][topic htlc] a
  otevírání a zavírání doplňkových kanálů a integrují uživatelská data do RPC/CLI.
  Jedná se o součást iniciativy uživatelských kanálů sloužící k vylepšení podpory
  [taproot assets][topic client-side validation]. Toto PR umožní, aby byla uživatelská
  data pro konkrétní aktiva předána RPC příkazy. Dále přidá podporu pro správu
  doplňkových kanálů přes příkazovou řádku.

- [LND #8044][] přidává nové typy zpráv `announcement_signatures_2`,
  `channel_announcement_2` a `channel_update_2` pro podporu nového gossip protokolu
  v1.75 (viz [zpravodaj č. 261][news261 v1.75]). Umožní uzlům [oznamovat][topic channel
  announcements] a ověřovat [taprootové kanály][topic simple taproot channels].
  Dále byly provedeny úpravy v existujících zprávách jako `channel_ready`
  a `gossip_timestamp_range` navyšující efektivitu a bezpečnost v práci s taprootovými
  kanály.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26355,2909,9095,9072,8044" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 checkpoints]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[poinsot headers]: https://mailing-list.bitcoindevs.xyz/bitcoindev/WhFGS_EOQtdGWTKD1oqSujp1GW-v_ZUJemlNePPGaGBgzpmu6ThpqLwJpUVei85OiMu_xxjEzt_SeOWY7547C72BVISLENOd_qrdCwPajgk=@protonmail.com/
[fuller dos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017354.html
[fuller paper]: https://bcoin.io/papers/bitcoin-chain-expansion.pdf
[posen bidir]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001232.html
[erhardt post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/82a37738-a17b-4a8c-9651-9e241118a363@murch.one/
[erhardt pr]: https://github.com/murchandamus/bips/pull/2
[news310 bcc]: /cs/newsletters/2024/07/05/#odhaleni-zranitelnosti-postihujicich-bitcoin-core-verze-pred-0-21-0
[news314 bcc]: /cs/newsletters/2024/08/02/#odhaleni-zranitelnosti-postihujicich-bitcoin-core-verze-pred-0-21-0
[kc jam]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147/
[kc attackathon]: https://github.com/carlaKC/attackathon
[sink attack]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bidirectional reputation]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-bidirectional-reputation-10
[nel post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0afc5f2-4dcc-469d-b952-03eeac6e7d1b@gmail.com/
[nel paper]: https://github.com/ShieldedCSV/ShieldedCSV/releases/latest/download/shieldedcsv.pdf
[news261 v1.75]: /cs/newsletters/2023/07/26/#aktualizovana-oznameni-o-kanalech
[bcc testing rbf]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide#3-package-rbf
[news272 submitpackage]: /cs/newsletters/2023/10/11/#bitcoin-core-27609
[new309 ban score]: /cs/newsletters/2024/06/28/#bitcoin-core-29575
