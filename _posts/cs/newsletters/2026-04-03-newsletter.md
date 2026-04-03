---
title: 'Zpravodaj „Bitcoin Optech” č. 399'
permalink: /cs/newsletters/2026/04/03/
name: 2026-04-03-newsletter-cs
slug: 2026-04-03-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje, jak může identifikace peněženek narušovat
soukromí payjoinu, a shrnuje návrh na formát metadat záloh peněženek.
Též nechybí naše pravidelné rubriky se souhrnem návrhů a diskuzí
o změnách pravidel konsenzu, s oznámeními nových vydání a s popisem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Riziko identifikace peněženky použité pro payjoin**: Armin Sabouri
  zaslal do fóra Delving Bitcoin [příspěvek][topic payjoin fingerprinting]
  popisující, jak rozdíly mezi implementacemi payjoinu umožňují detekovat
  [payjoinové][topic payjoin] transakce a mohou tak narušit jejich soukromí.

  Sabouri tvrdí, že i když by payjoinové transakce měly být nerozeznatelné od běžných
  transakcí, mohou obsahovat stopy po spolupráci mezi více účastníky:

  - V rámci transakce

    - Řadí vstupy a výstupy dle vlastníka.

    - Rozdíly v kódování vstupů.

    - Velikost vstupů v bajtech.

  - Mezi transakcemi

    - Zpětně: Každý vstup byl vytvořen předchozí transakcí, která nese své vlastní charakteristiky.

    - Dopředně: Každý výstup může být utracen budoucí transakcí, která charakteristiky odhalí.

  Dále prozkoumal tři implementace payjoinu: Samourai, demo PDK a Cake Wallet
  (posílající do Bull Bitcoin Mobile). V každém z těchto příkladů nalezl několik
  odlišností, které umožňují odhalit použitou implementaci. Mezi těmito znaky
  byly například:

  - Rozdíly v kódování podpisů vstupů.

  - SIGHASH_ALL bajt v jednom vstupu, ale ne v ostatních.

  - Volba výstupní hodnoty.

  Sabouri uzavírá tvrzením, že některé z těchto charakteristik peněženek je možné
  snadno odstranit, jiné jsou svázané s designem peněženky. Vývojáři peněženek
  by si měli být během přidávání podpory pro payjoin do svých peněženek těchto
  vlastností vědomi.

- **Návrh BIPu formátu metadat záloh peněženek**: Pythcoiner zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][wallet bip ml] o novém návrhu
  společných struktur pro metadata záloh peněženek. Návrh BIPu, dostupný
  na [BIPs #2130][], specifikuje standardní způsob ukládání různých druhů
  metadat, jako jsou deskriptory účtů, klíče, [štítky][topic wallet labels],
  [PSBT][topic psbt] a další. Tím dosáhne kompatibility mezi různými
  implementacemi peněženek a jednodušší migrace a obnovy.
  Dle Pythcoinera postrádá současný ekosystém společnou specifikaci a
  jeho návrh se snaží tuto mezeru zaplnit.

  Z technického hlediska se jedná o textový soubor v UTF-8 obsahující
  jediný validní JSON objekt, který reprezentuje strukturu záloh.
  BIP vyjmenovává všechna možná pole, která by tento JSON objekt mohl
  obsahovat, a poznamenává, že implementace peněženek mohou kterákoliv
  z nich ignorovat, pokud pro ně nejsou užitečná.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Úsporné izogenní PQC může nahradit hierarchické peněženky, tweakování klíčů, tiché platby**:
  Conduition zaslal do fóra Delving Bitcoin [příspěvek][c delving ibc hd] o svém
  výzkumu udržitelnosti kryptografie založené na izogenii (Isogeny-Based Cryptography,
  IBC) jako [postkvantového][topic quantum resistance] kryptografického systému
  pro bitcoin. I když problém diskrétního logaritmu nad eliptickými křivkami
  se může v postkvantovém světě stát nezabezpečeným, obecně není na matematice
  eliptických křivek nic rozbitého. Ve stručnosti je izogenie funkcí z jedné
  eliptické křivky na jinou. IBC předpokládá, že je obtížné vypočítat izogenii
  mezi jednou eliptickou křivkou určitého druhu a jednou další. Vytvořit
  izogenii a křivku, na kterou mapuje, je však snadné. Tajné klíče v IBC
  jsou tak izogenie a veřejné klíče jsou křivky, na které mapuje.

  Je možné, stejně jako u ECDLP, spočítat nové soukromé a veřejné klíče nezávisle
  ze stejné soli (např. [BIP32 derivací][topic bip32]) a řádně podepsat výsledným
  soukromým klíčem pro výsledný veřejný klíč. Tato vlastnost, kterou Conduition
  nazývá opakovanou randomizací (rerandomization), umožňuje [BIP32][], [BIP341][]
  a [BIP352][] (pravděpodobně spolu s některými dalšími kryptografickými inovacemi).

  Zatím neexistují pro IBC žádné protokoly agregace podpisů, jako jsou [MuSig][topic musig]
  či [FROST][topic threshold signature], proto conduition vyzývá bitcoinové vývojáře,
  aby prozkoumali možnosti.

  Klíče a podpisy ve známých IBC systémech jsou zhruba dvakrát větší než klíče
  v ECDLP systémech a mnohem menší než systémy založené na hašování nebo mřížkové
  kryptografii. Ověřování je nákladné i na desktopových počítačích (v řádu
  jedné milisekundy na jedno ověření), podobně jako u hašování nebo mřížkové
  kryptografie.

- **Rozpočet varops operací a tapscriptový list 0xc2 („skriptové obrození”) mají BIP 440 a 441**:
  Rusty Russell zaslal do emailové skupiny Bitcoin-Dev [zprávu][rr ml gsr bips],
  že byly odeslány k očíslování první dva BIPy velkého skriptového obrození (GSR, Great
  Script Restoration či Grand Script Renaissance). Následně obdržely čísla 440 a 441.
  [BIP440][news374 varops] obnovuje dříve deaktivované opkódy. Díky systému pro
  hlídání nákladů každé varops operace (opkód, jehož náklady závisí na velikosti
  vstupu) je zaručeno, že náklady na validaci skriptů v bloku
  nepřekročí náklady na validaci bloku obsahujícího nejvyšší možný počet operací
  s podpisy. [BIP441][news374 c2] popisuje validaci nové verze [tapscriptu][topic
  tapscript], která obnovuje opkódy deaktivované Satoshim v roce 2010.

- **SHRIMPS: postkvantový podpis s 2,5 kB napříč více zařízení se stavem**:
  Jonas Nick zaslal do fóra Delving Bitcoin [příspěvek][jn delving shrimps]
  o novém konstruktu podpisů pro postkvantový bitcoin založeném na hašování
  a částečném stavu. SHRIMPS využívá skutečnosti, že velikost podpisů
  [SPHINCS+][news383 sphincs] je úměrná maximálnímu počtu podpisů pro
  daný klíč, které mohou být vytvořeny při zachování dané úrovně zabezpečení.

  Podobně jako [SHRINCS][news391 shrincs] se i SHRIMPS klíče sestávají ze dvou
  klíčů zahašovaných dohromady. V tomto případě jsou oba klíče bezstavovými
  SPHINCS+ klíči, avšak s různými parametry. První klíč je bezpečný pouze
  pro malý počet podpisů a je proto určený pro první podpis (nebo pár prvních
  podpisů) každého podpisového zařízení, které tento klíč používá. Druhý
  klíč je bezpečný pro mnohem větší počet podpisů (v bitcoinu v podstatě
  neomezený) a každé zařízení ho začne používat po určitém počtu (potenciálně
  zvoleném uživatelem) podpisů z tohoto zařízení. V důsledku tak v běžném
  případě, kde každý klíč (kterých může být z jednoho seedu generováno mnoho)
  podepisuje pouze párkrát, mohou téměř všechny podpisy mít méně než 2,5 kB,
  a přitom nemusí být jejich počet omezen ani v případě mnohonásobného
  opakovaného použití za cenu velikosti kolem 7,5 kB. SHRIMPS má částečný
  stav v tom smyslu, že sice není nutné udržovat globální stav, ale každé
  podpisové zařízení musí ukládat pár bitů stavu pro každý klíč, se kterým
  podepisuje (a jen jediný bit, pokud pouze první podpis každého klíče ze
  zařízení využívá výhody malých podpisů).

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 31.0rc2][] je kandidátem na vydání příští hlavní verze
  této převládající implementace plného uzlu. Dostupný je [průvodce
  testováním][bcc31 testing].

- [Core Lightning 26.04rc2][] je kandidátem na vydání příští hlavní verze této
  populární implementace LN uzlu. Přináší další aktualizace splicingu a opravuje
  chyby z předchozích kandidátů.

- [BTCPay Server 2.3.7][] je menším vydáním tohoto platebního procesoru s možností
  vlastního hostování. Migruje projekt na .NET 10, zlepšuje předplatné a
  platby fakturami a přidává několik dalších vylepšení a oprav chyb. Vývojáři
  rozšíření by měli následovat [průvodce migrace na .NET 10][btcpay net10].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #32297][] přidává do `bitcoin-cli` volbu `-ipcconnect`, aby
  se mohl připojit a ovládat `bitcoin-node` instanci přes meziprocesovou
  komunikaci (IPC) přes unixový soket namísto HTTP, pokud je Bitcoin Core
  sestaven s příznakem `ENABLE_IPC` a uzel je spuštěn s `-ipcbind` (viz též
  zpravodaje [č. 320][news320 ipc] a [č. 369][news369 ipc], _angl._). I když je
  volba `-ipcconnect` vynechána, zkusí `bitcoin-cli` nejdřív použít IPC. Pokud
  není dostupné, použije HTTP. Jedná se o součást projektu [oddělení do více
  procesů][multiprocess].

- [Bitcoin Core #34379][] opravuje chybu způsobující selhání, pokud bylo RPC
  `gethdkeys` (viz [zpravodaj č. 297][news297 rpc]) voláno s `private=true`
  a pokud peněženka obsahovala nějaký [deskriptor][topic descriptors], pro který
  měla jen některé, ale ne všechny soukromé klíče. Podobně jako oprava pro
  `listdescriptors` ([zpravodaj č. 389][news389 descriptor]) i toto PR vrací
  dostupné soukromé klíče. Volání `gethdkeys private=true` nad peněženkami
  pouze pro čtení nadále selhává.

- [Eclair #3269][] přidává automatické znovuzískání likvidity z nečinného kanálu.
  Když `PeerScorer` zjistí, že celkový objem plateb kanálu spadne v obou směrech
  pod 5 % jeho kapacity, postupně sníží jeho [poplatky za přeposílání][topic
  inbound forwarding fees] směrem k nastavenému minimu. Pokud jsou poplatky
  v minimu nejméně pět dní a objem nezačne růst, Eclair tento kanál zavře,
  pokud je pro peer spojení nadbytečný. Kanály jsou zavřeny pouze, pokud uzel
  drží alespoň 25 % prostředků a místní zůstatek převyšuje existující nastavení
  `localBalanceClosingThreshold`.

- [LDK #4486][] začleňuje `rbf_channel` do `splice_channel` jako jediného styčného
  bodu pro vytváření nových [spliců][topic splicing] a pro navyšování poplatků pro
  stávající. Pokud splice již probíhá, návratová hodnota `FundingTemplate`
  ze `splice_channel` vrací `PriorContribution`, aby mohli uživatelé
  [navýšit poplatek][topic rbf] splicu bez [výběru mincí][topic coin selection].
  Viz též [zpravodaj č. 397][news397 rbf] pro související chování RBF během splicingu.

- [LDK #4428][] přidává podporu pro otevírání a přijímání kanálů s nulovou rezervou
  pro důvěryhodná peer spojení pomocí nové metody `create_channel_to_trusted_peer_0reserve`.
  Kanály s nulovou rezervou umožňují protistraně kompletně utratit zůstatek kanálu.
  Je to umožněno pro kanály s [anchor výstupy][topic anchor outputs] i pro kanály
  s commitmenty bez poplatků (viz [zpravodaj č. 371][news371 0fc], _angl._).

- [LND #9982][], [#10650][lnd #10650] a [#10693][lnd #10693] zlepšují nakládání
  s [MuSig2][topic musig] noncemi u [taprootových][topic taproot] kanálů:
  do `ChannelReestablish` přidává pole `LocalNonces`, aby mohla spojení
  koordinovat více noncí u aktualizací souvisejících se [splicingem][topic splicing].
  `lnwire` validuje veřejné MuSig2 nonce během dekódování TLV u zpráv, které
  nonce přenášejí, a dekódování `LocalNoncesData` validuje každý vstup.

- [LND #10063][] rozšiřuje kooperativní zavření kanálu s [RBF][topic rbf] na
  [jednoduché taprootové kanály][topic simple taproot channels] použitím [MuSig2][topic musig].
  Zprávy přenášejí nonce a částečné podpisy specifické pro [taproot][topic taproot]
  a stavový automat používá MuSig2 sezení s just-in-time noncemi
  pro `shutdown`, `closing_complete` a `closing_sig` (viz též [zpravodaj č. 347][news347
  rbf coop], který popisuje pozadí kooperativního zavření s RBF).

{% include snippets/recap-ad.md when="2026-04-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2130,32297,34379,3269,4486,4428,9982,10650,10693,10063" %}

[topic payjoin]: /en/topics/payjoin/
[topic payjoin fingerprinting]: https://delvingbitcoin.org/t/how-wallet-fingerprints-damage-payjoin-privacy/2354
[c delving ibc hd]: https://delvingbitcoin.org/t/compact-isogeny-pqc-can-replace-hd-wallets-key-tweaking-silent-payments/2324
[rr ml gsr bips]: https://groups.google.com/g/bitcoindev/c/T8k47suwuOM
[news374 varops]: /en/newsletters/2025/10/03/#first-bip
[news374 c2]: /en/newsletters/2025/10/03/#second-bip
[jn delving shrimps]: https://delvingbitcoin.org/t/shrimps-2-5-kb-post-quantum-signatures-across-multiple-stateful-devices/2355
[news383 sphincs]: /en/newsletters/2025/12/05/#slh-dsa-sphincs-post-quantum-signature-optimizations
[news391 shrincs]: /cs/newsletters/2026/02/06/#shrincs-324bajtove-stavove-postkvantove-podpisy-se-statickymi-zalohami
[wallet bip ml]: https://groups.google.com/g/bitcoindev/c/ylPeOnEIhO8
[news297 rpc]: /cs/newsletters/2024/04/10/#bitcoin-core-29130
[news320 ipc]: /cs/newsletters/2024/09/13/#bitcoin-core-30509
[news347 rbf coop]: /cs/newsletters/2025/03/28/#lnd-8453
[news369 ipc]: /en/newsletters/2025/08/29/#bitcoin-core-31802
[news371 0fc]: /en/newsletters/2025/09/12/#ldk-4053
[news389 descriptor]: /cs/newsletters/2026/01/23/#bitcoin-core-32471
[news397 rbf]: /cs/newsletters/2026/03/20/#ldk-4427
[multiprocess]: https://github.com/bitcoin/bitcoin/issues/28722
[bitcoin core 31.0rc2]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc2/
[Core Lightning 26.04rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc2
[BTCPay Server 2.3.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.7
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[btcpay net10]: https://blog.btcpayserver.org/migrating-to-net10/
