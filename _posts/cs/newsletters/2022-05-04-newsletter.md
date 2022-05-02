---
title: 'Zpravodaj „Bitcoin Optech” č. 198'
permalink: /cs/newsletters/2022/05/04/
name: 2022-05-04-newsletter
slug: 2022-05-04-newsletter
type: newsletter
layout: newsletter
lang: cs
---
Tento týden shrnujeme obsah příspěvku o implementaci MuSig2, informujeme
o odpovědném zveřejnění zranitelnosti postihující některé starší implementace
Lightning Network, diskutujeme o návrhu na měření podpory změn konsenzu skrze
signalizování v transakcích a zamýšlíme se nad možností efektivnějšího
gossip protokolu LN. Též nechybí naše pravidelné rubriky shrnující vydání nových
verzí a významné změny v populárních bitcoinových infrastrukturních projektech.

## Novinky

- **Poznámky k implementaci MuSig2[^musig2]:** Olaoluwa Osuntokun poslal
  [odpověď][osuntokun musig2] k návrhu BIPu pro [MuSig2][topic musig],
  jež byl zmíněn ve [zpravodaji č. 195][news195 musig2] *(angl.)*. Připojil
  několik postřehů z implementace, na které on a další pracovali pro BTCD a LND:

    - *Interakce s BIP86:* klíče vytvořené podle [BIP32][topic bip32][^bip32]
	  peněženkou, která též implementuje [BIP86][][^bip86], se řídí doporučením
	  z [BIP341][][^bip341], aby byly klíče pro platbu klíčem vytvořeny tweaknutím[^tweak]
	  s hashem sebe sama. Napomáhá to zabránit situacím, ve kterých by mohl
	  účastník vícenásobného podpisu ([multisignature][topic multisignature])
	  ukrást všechny prostředky tajným včleněním další platební podmínky.
	  Chtějí-li však účastníci vícenásobného podpisu tuto podmínku záměrně začlenit,
	  musejí sdílet verze svých klíčů před tweaknutím („interní klíč”).

      Osuntokun doporučuje, aby implementace BIP86 vracely jak původní,
	  interní klíč, tak i klíč tweaknutý. Uživatelé těchto implementací
	  by si potom mohli vybrat podle potřeby.

    - *Interakce s platbami skriptem:* Klíče určené pro platbu skriptem mají
	  podobný problém jako v předchozím odstavci: kdo utrácí, musí znát interní klíč.
	  I zde by napomohlo, kdyby implementace vracely také interní klíč.

    - *Zkratka pro posledního podepisujícího:* Osuntokun také požadoval
	  objasnění části návrhu, která umožňuje poslednímu podepisujícímu (a pouze
	  poslednímu) použít pro generování nonce[^nonce] deterministický zdroj
	  náhodných čísel nebo zdroj nižší kvality. Brandon Black v [odpovědi][black musig2]
	  popsal situaci, která stála za tímto návrhem: měli účastníka vícenásobného
	  podpisu, který neměl snadný přístup k bezpečnému prostředí, který ale
	  mohl pokaždé podepisovat až jako poslední.

- **Jak mezi uživateli měřit podporu změny konsenzu:** Keagan McClelland
  ve svém [příspěvku][mcclelland measure] do emailové skupiny Bitcoin-Dev navrhuje,
  podobně jako jiné [předchozí návrhy][bishop signal], aby byla
  [podpora či nepodpora][topic soft fork activation] konkrétní snahy na změnu
  pravidel konsenzu signalizována v transakcích. Ve stejném vlákně se diskutovaly
  i další možnosti měření podpory, ale všechny trpěly problémy: [technické potíže][aronesty signal parse scripts],
  velký [zásah][grant signal chainalysis] do soukromí uživatelů, [upřednostňování][tetrud signal favor]
  jedné části bitcoinové ekonomiky před dalšími nebo [znevýhodňování][ivgi signal hodl voting]
  prvních voličů před těmi, kteří čekali na vytvoření konsenzu.

  Stejně jako v předchozích případech, kdy se toto téma probíralo, nezdá se,
  že by některá z navrhovaných metod získala dostatečnou podporu většinou
  diskutujících.

- **Bezpečnostní problém anchor[^anchor] výstupů v LN:** Bastien Teinturier
  v emailové skupině Lightning-Dev [oznámil][teinturier security] objevení
  bezpečnostního problému, o kterém předtím informoval vývojáře LN implementací
  v rámci odpovědného zveřejnění zranitelností. Problém se týkal starších verzí
  Core Lightning (s aktivovanou experimentální funkcionalitou) a LND. Používá-li
  stále někdo verze zmíněné v Teinturierově příspěvku, měl by upgradovat.

  Než byly implementovány [anchor výstupy][topic anchor outputs], obsahovaly revokované
  [HTLC][topic HTLC] transakce jediný výstup. Mnoho implementací tedy
  nárokovalo pouze tento jediný výstup. Nový design anchor výstupů umožňuje kombinovat
  výstupy několika revokovaných HTLC do jediné transakce. Toto je ovšem
  bezpečné pouze tehdy, pokud implementace nárokuje všechny relevantní výstupy
  v transakci. Prostředky, které nejsou nárokovány před vypršením HTLC, mohou být
  ukradnuty tou stranou, která zveřejní revokované HTLC. Teinturierova implementace
  anchor výstupů pro Eclair mu umožnila otestovat ostatní implementace LN a odhalit
  tak tuto zranitelnost.

  Podobně jako u předchozích útoků spojených s anchor výstupy ([zpravodaj č. #115][news115 fee stealing],
  *angl.*), i zde se problém zdá být spojený s přidanou podporou pro podepisování s
  `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` a zároveň ponechanou podporou pro původní způsob
  podepisování s `SIGHASH_ALL`.

- **LN a zeštíhlení gossip protokolu[^gossip]:** Alex Myers [informoval][myers recon]
  emailovou skupinu Lightning-Dev o svém výzkumu použití metody synchronizace množin
  („set reconciliation”) založené na knihovně [minisketch][topic minisketch] k dosažení
  redukce datového přenosu, který uzly v síti Lightning Network potřebují k udržení povědomí
  o topologii sítě. Jeho metoda předpokládá, že všechny uzly mají téměř kompletní přehled
  o téměř všech veřejných kanálech (tj. hranách grafu). Uzel potom může ze svého kompletního
  grafu veřejné sítě vygenerovat minisketch a odeslat jej všem svým spojením (peer). Ta z
  něj mohou vypočítat změny od poslední synchronizace. Zde se tato metoda liší od protokolu
  [erlay][topic erlay], který navrhuje použít minisketch v bitcoinové síti k
  podobnému účelu; erlay by však měl odesílat pouze změny (tj. nové, nepotvrzené
  transakce) z posledních několika sekund.

  Problémem synchronizace grafu všech veřejných kanálů je požadavek,
  aby všechny uzly v Lightning Network měly stejnou informaci. Jakýkoliv filtr,
  který by zapříčinil trvalý rozpor mezi uzly v pohledu na graf sítě, by
  vyústil buď v nárůst datového přenosu nebo selhání protokolu. Matt Corallo
  [navrhl][corallo recon] inspirovat se protokolem erlay: pokud by se posílaly
  pouze změny, neshody v informacích držených jednotlivými uzly by nehrály roli.
  Velké rozdíly v pravidlech filtrování by však stále mohly způsobit
  přílišný datový přenos nebo selhání synchronizace. Myers vyjádřil obavu,
  že sledování stavu poslaných zpráv by v tomto případě bylo příliš náročné;
  aby se Bitcoin Core vyhnul přeposílání stejných zpráv, udržuje stav pro každé
  své spojení. Synchronizace kompletního grafu nevyžaduje sledování stavu
  pro každé spojení, zjednodušuje tím tedy implementaci.

  Debata o výhodách a nevýhodách těchto metod v době psaní textu
  stále probíhala.

## Vydání nových verzí

*Vydání nových verzí populárních bitcoinových infrastrukturních projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 1.5.1][] je nové vydání oblíbeného self-hosted serveru
  pro zpracování plateb. Obsahuje nový dashboard, novou funkci
  [„Transfer Processors”][btcpay server #3476] pro zpracování odchozích
  plateb a možnost zapnout automatické schvalování pull plateb a vracení peněz.

- [BDK 0.18.0][] je nové vydání knihovny pro programování peněženek. Obsahuje
  [opravu kritické chyby][minimalif bug] jedné závislosti (rust-miniscript)
  a nechybí také několik vylepšení a oprav drobných chyb.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18554][] znemožňuje ve výchozí konfiguraci sdílet soubor
  s peněženkami napříč různými blockchainy. Když Bitcoin Core hledá v novém
  bloku transakce, které by se týkaly jedné z jeho peněženek, zaznamenává
  v peněžence hash onoho bloku. Tato změna přidává kontrolu, zda poslední
  zaznamenaný blok vychází ze stejného [základního (genesis) bloku][genesis block]
  jako právě používaný blockchain. Pokud nevychází a pokud není zapnuta
  volba `-walletcrosschain`, je vrácena chybová hláška. Tato kontrola
  zabraňuje peněžence určené pro použití v jedné síti (např. mainnet) použití
  v síti jiné (např. testnet). Snižuje tím tak riziko ztráty peněz nebo soukromí.
  Změna se týká pouze uživatelů peněženky vestavěné v Bitcoin Core.

- [Bitcoin Core #24322][] je součástí rozsáhlé snahy extrahovat z Bitcoin Core kód
  vyhodnocující konsenzus, vytvořit z něj knihovnu a následně tuto knihovnu postupně zeštíhlit.
  Konkrétně přináší tato změna novou knihovnu `libbitcoinkernel`, která bude obsahovat
  všechny zdrojové soubory potřebné k sestavení spustitelného souboru `bitcoin-chainstate`
  představeného v [Bitcoin Core #24304][]. Mezi těmito soubory jsou i takové,
  které logický vztah ke konsenzu nemají; ilustruje to stav závislostí uvnitř Bitcoin Core.
  V budoucnu se konsenzus vyčlení od zbytku kódu, který bude moci být z `libbitcoinkernel` odstraněn.

- [Bitcoin Core #21726][] přidává možnost indexovat data pro coinstats[^coinstats] i ořezaným
  (pruned) uzlům. Coinstats obsahují hash stavu UTXO každého bloku, což umožňuje
  validaci stavu [assumeUTXO][topic assumeutxo][^assumeUTXO]. Dříve bylo možné toto
  zajistit pouze u plných (full) uzlů, které ukládají všechny bloky. S touto změnou
  mohou i ořezané uzly (ukládají jen část posledních bloků) nabídnout
  coinstats, je-li volba `-coinstatsindex` aktivována.

- [BDK #557][] přidává nový algoritmus pro výběr mincí „Oldest First” (nejstarší má přednost).
  Knihovna nyní obsahuje čtyři algoritmy: „Branch and Bound (BnB)” (metoda větví a mezí),
  „Single Random Draw (SRD)” (náhodný výběr), „Oldest First” a „Largest First”
  (největší má přednost). Ve výchozím nastavení použije BDK nejdříve BnB a pokud žádné
  řešení nenalezne, SRD bude použit jako záložní algoritmus.

- [LDK #1425][] přidává podporu pro [velké kanály][topic large channels]
  („wumbo channels”) s kapacitou přesahující 0,16777216 BTC, což je původní limit
  dohodnutý vývojáři.

- [LND #6064][] přidává nové volby  `bitcoind.config` a `bitcoind.rpccookie`
  pro nastavení vlastních cest konfiguračních a RPC cookie souborů.

- [LND #6361][] upravuje metodu `signrpc`, aby byla schopna vytvářet podpisy
  pomocí protokolu [MuSig2][topic musig]. Součástí změny je i [dokumentace][lnd6361 doc]
  s podrobnostmi. Podpora MuSig2 je experimentální a může dojít ke změně, zvláště
  bude-li navrhovaný BIP pro MuSig2 pozměněn (viz [zpravodaj č. 195][news195 musig2], *angl.*).

- [BOLTs #981][] ze specifikace odstraňuje možnost komprimovat dotazy
  a jejich výsledky týkající se grafu LN sítě. Předpokládá se, že
  tato funkce nebyla používána a její odstranění zjednoduší LN implementace.

## Poznámky a vysvětlivky

[^anchor]: Anchor výstupy jsou výstupy v commitment transakcích, které umožňují v případě potřeby zvýšit transakční poplatek. To může být potřeba, protože tyto transakce mohou být odeslány v daleké budoucnosti
[^bip32]: BIP32 popisuje deterministickou derivaci hierarchie klíčů
[^bip86]: BIP86 popisuje derivaci klíčů pro Taproot
[^bip341]: BIP341 popisuje dva způsoby Taproot platby: buď klíčem („keypath spend”) nebo skriptem („scriptpath spend”)
[^gossip]: Gossip (v překladu „drby”) protokol je metoda, kterou si uzly v decentralizované síti navzájem posílají zprávy o stavu sítě
[^musig2]: MuSig2 je protokol pro agregaci veřejných klíčů a podpisů za použití Schnorrova algoritmu
[^nonce]: nonce je náhodné či pseudonáhodné číslo, které smí být použito pouze jednou („number once”) v kryptografické komunikaci
[^tweak]: tweakování je úprava kryptografických klíčů matematickou operací
[^coinstats]: coinstats (coin statistics) je optimalizace, která umožňuje rychlejší výpočet statistik UTXO, včetně např. celkového počtu existujících bitcoinů
[^assumeUTXO]: assumeUTXO je návrh, který umožní novým uzlům odložit validaci blockchainu na později a začít tak přijímat nové transakce rychleji

{% include references.md %}
{% include linkers/issues.md v=2 issues="18554,24322,24304,21726,6064,557,981,6361,1425,3476" %}
[tetrud signal favor]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020350.html
[ivgi signal hodl voting]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020364.html
[aronesty signal parse scripts]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020354.html
[grant signal chainalysis]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020355.html
[bishop signal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020346.html
[news115 fee stealing]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[osuntokun musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020361.html
[news195 musig2]: /en/newsletters/2022/04/13/#musig2-proposed-bip
[black musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020371.html
[mcclelland measure]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020344.html
[teinturier security]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003561.html
[myers recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003551.html
[corallo recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003556.html
[genesis block]: https://en.bitcoin.it/wiki/Genesis_block
[btcpay server 1.5.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.5.1
[minimalif bug]: https://bitcoindevkit.org/blog/miniscript-vulnerability/
[bdk 0.18.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.18.0
[lnd6361 doc]: https://github.com/guggero/lnd/blob/93e069f3bd4cdb2198a0ff158b6f8f43a649e476/docs/musig2.md
