---
title: 'Zpravodaj „Bitcoin Optech” č. 357'
permalink: /cs/newsletters/2025/06/06/
name: 2025-06-06-newsletter-cs
slug: 2025-06-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden sdílí analýzu synchronizace plných uzlů bez
starých witnessů. Též nechybí naše pravidelné rubriky s popisem
diskuzí o změnách konsenzu, oznámeními nových vydání a souhrnem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Synchronizace plného uzlu bez witnessů:** Jose SK zaslal do fóra
  Delving Bitcoin [příspěvek][sk nowit] se souhrnem své [analýzy][sk nowit gist]
  o bezpečnostních kompromisech v prostředí, kde by mohly nově spuštěné plné uzly
  v určité konfiguraci přeskočit některá historická data v blockchainu.
  Ve výchozím nastavení používají uzly Bitcoin Core konfiguraci `assumevalid`,
  která přeskočí validaci skriptů v blocích vytvořených více než měsíc či dva
  před vydáním spouštěné verze Bitcoin Core. Mnoho uživatelů Bitcoin Core
  dále nastaví volbu `prune` (ve výchozím nastavení vypnutou), která smaže
  bloky po určité době od jejich validace (tato doba závisí na velikosti bloků
  a uživatelově nastavení).

  SK tvrdí, že data witnessů, která jsou nezbytná pouze pro validaci skriptů,
  by neměla být ořezanými uzly u assumevalid bloků stahována, protože
  nebudou pro validaci skriptů použita a nakonec budou smazána. Přeskočení
  stahování witnessů může dle něj „snížit využívání šířky pásma o více než
  40 %.”

  Ruben Somsen [tvrdí][somsen nowit], že tento návrh do určité míry mění
  bezpečnostní model. I když nejsou skripty validovány, stahovaná data
  jsou ověřována oproti commitmentu z Merkleova kořene z hlavičky bloku.
  To zajišťuje, že jsou data v době úvodního stahování dostupná a nepoškozená.
  Pokud by nikdo pravidelně existenci dat nevalidoval, mohla by nakonec
  být ztracená, což se již [stalo][ripple loss] nejméně jednomu altcoinu.

  Diskuze v době psaní nadále probíhala.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Zpráva o kvantových počítačích:** Clara Shikhelman zaslala do fóra
  Delving Bitcoin [příspěvek][shikelman quantum] se souhrnem [zprávy][sm
  report], kterou sepsala spolu s Anthonym Miltonem, o hrozbách
  kvantových počítačů bitcoinovým uživatelům, s přehledem několika možných
  cest ke [kvantové odolnosti][topic quantum resistance] a s analýzou
  kompromisů upgradu bitcoinového protokolu. Autoři zjistili, že 4 až 10 miliónů
  BTC jsou potenciálně zranitelné vůči kvantové krádeži, že nějaká opatření
  jsou dnes již možná, že těžbu bitcoinů kvantové počítače v blízké
  i středně vzdálené budoucnosti nejspíše neohrozí a že upgrade bude
  vyžadovat široký souhlas.

- **Váhový limit transakcí s výjimkami zabraňujícími konfiskacím:**
  Vojtěch Strnad zaslal do fóra Delving Bitcoin [příspěvek][strnad limit]
  s návrhem na změnu konsenzu omezující maximální velikost většiny
  transakcí v bloku. Toto jednoduché pravidlo by povolilo transakci
  větší než 400 000 váhových jednotek (100 000 vbyte) v bloku pouze,
  pokud by to byla jediná transakce v bloku (vedle mincetvorné transakce).
  Strnad a další popisují motivace stojící za omezením maximální váhy:

  - _Jednodušší optimalizace šablon bloku:_ čím menší jsou položky v porovnání
    s celkovým limitem, tím snazší je nalézt téměř optimální
    řešení [problému batohu][knapsack problem]. Zčásti je to díky minimalizaci
    prostoru zbylému na konci, neboť menší položky zanechají méně nevyužitého
    prostoru.

  - _Jednodušší pravidla přeposílání:_ pravidla přeposílání nepotvrzených
    transakcí mezi uzly předpovídají, které transakce budou vytěžené, čímž
    zabraňují plýtvání šířkou pásma. Obrovské transakce ztěžují přesné
    předpovídání, neboť i drobná změna horního jednotkového poplatku
    jim může způsobit zpoždění nebo vyloučení.

  - _Obrana před centralizací těžby:_ jsou-li přeposílající plné
    uzly schopné zpracovat téměř všechny transakce, je zajištěno,
    že uživatelé neobvyklých transakcí nemusí platit [poplatky bokem][topic
    out-of-band fees], které mohou vést k centralizaci těžby.

  Gregory Sanders [poznamenal][sanders limit], že by na základě 12 let konzistentních
  pravidel přeposílání Bitcoin Core mohlo být rozumné jednoduše soft forkem
  stanovit maximální váhový limit bez jakýchkoliv výjimek. Gregory Maxwell
  [dodal][maxwell limit], že transakce, které utrácejí pouze UTXO vytvořená
  před soft forkem, by mohla mít udělenou výjimku a že by [přechodný soft fork][topic
  transitory soft forks] těmto restrikcím umožnil expirovat, pokud
  by se komunita rozhodla soft fork neobnovit.

  Další diskuze zkoumala potřeby jednotlivých stran používat velké transakce (hlavně
  uživatelé [BitVM][topic acc]) a zda-li jsou dostupné alternativní přístupy.

- **Odstranění výstupů z množiny UTXO dle hodnoty a doby:** Robin
  Linus zaslal do fóra Delving Bitcoin [příspěvek][linus dust] s návrhem
  soft forku, který by po nějaké době odstraňoval z množiny UTXO výstupy
  s nízkými hodnotami. Bylo diskutováno několik variací této myšlenky,
  mezi které patřilo:

  - _Zničení starých neekonomických prostředků:_ výstupy s malými hodnotami,
    které nebyly dlouho utraceny, by mohly být neutratitelné.

  - _Požadavek, aby staré neekonomické prostředky dodaly při utracení důkaz existence:_
    [utreexo][topic utreexo] nebo podobný systém by mohly být použité k přiložení
    dokladu, že výstupy utrácené transakcí jsou součástí množiny UTXO.
    Staré a [neekonomické výstupy][topic uneconomical outputs] by tento doklad
    musely přiložit, avšak novější nebo hodnotnější výstupy by byly i nadále uložené
    v množině UTXO.

  Kterékoliv z řešení by efektivně omezilo maximální velikost množiny UTXO
  (za předpokladu minimální hodnoty a 21miliónového limitu). Bylo diskutováno
  několik zajímavých technických aspektů návrhu, včetně praktičtějších alternativ
  k utreexo dokladům.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.05rc1][] je kandidátem na vydání příští hlavní verze této oblíbené
  implementace LN uzlu.

- [LND 0.19.1-beta.rc1][] je kandidátem na vydání údržbové verze této populární
  implementace LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #32582][] přidává nové logovací zprávy pro měření výkonnosti
  [rekonstrukce kompaktních bloků][topic compact block relay]. Sleduje celkovou
  velikost transakcí, které uzel od svých spojení vyžádá (`getblocktxn`) a počet
  a celkovou velikost transakcí, které uzel svým spojením posílá (`blocktxn`).
  Dále pro sledování doby vyhledávání v mempoolu přidává časové razítko na
  začátek `PartiallyDownloadedBlock::InitData()`. [Zpravodaj č. 315][news315 compact]
  popisuje zprávu o statistikách rekonstrukce kompaktních bloků.

- [Bitcoin Core #31375][] přidává CLI nástroj `bitcoin -m`, který obaluje a spouští
  [multiprocesové][multiprocess project] binárky `bitcoin node`
  (`bitcoind`), `bitcoin gui` (`bitcoinqt`) a `bitcoin rpc` (`bitcoin-cli
  -named`). V současnosti fungují tyto příkazy stejně jako monolitické binárky
  (kromě aktivované volby `-ipcbind`, viz [zpravodaj č. 320][news320 ipc]), avšak
  budoucí verze umožní spouštět jednotlivé komponenty nezávisle na odlišných
  strojích a v různých prostředích. [Zpravodaj č. 353][news353 pr review]
  popisuje sezení Bitcoin Core PR Review Clubu zabývající se tímto PR.

- [BIPs #1483][] začleňuje [BIP77][], který navrhuje [payjoin v2][topic payjoin].
  V této asynchronní bezserverové verzi odesílatel a příjemce poskytnou
  zašifrovaná PSBT serveru poskytujícímu payjoinový adresář; tento server
  pouze ukládá a přeposílá zprávy. Jelikož adresář nemůže číst ani měnit datový
  obsah zpráv, nemusí ani jedna peněženka hostovat veřejný server ani být současně
  online. Více podrobností o payjoin v2 poskytuje [zpravodaj č. 264][news264 payjoin].

{% include snippets/recap-ad.md when="2025-06-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32582,31375,1483" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ripple loss]: https://x.com/JoelKatz/status/1919233214750892305
[sk nowit]: https://delvingbitcoin.org/t/witnessless-sync-for-pruned-nodes/1742/
[sk nowit gist]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1
[somsen nowit]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1?permalink_comment_id=5597316#gistcomment-5597316
[shikelman quantum]: https://delvingbitcoin.org/t/bitcoin-and-quantum-computing/1730/
[sm report]: https://chaincode.com/bitcoin-post-quantum.pdf
[strnad limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/
[knapsack problem]: https://cs.wikipedia.org/wiki/Probl%C3%A9m_batohu
[sanders limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/2
[maxwell limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/4
[linus dust]: https://delvingbitcoin.org/t/dust-expiry-clean-the-utxo-set-from-spam/1707/
[lnd 0.19.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta.rc1
[news315 compact]: /cs/newsletters/2024/08/09/#statistika-rekonstruovani-kompaktnich-bloku
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news320 ipc]: /cs/newsletters/2024/09/13/#bitcoin-core-30509
[news264 payjoin]: /cs/newsletters/2023/08/16/#bezserverovy-payjoin
[news353 pr review]: /cs/newsletters/2025/05/09/#bitcoin-core-pr-review-club
