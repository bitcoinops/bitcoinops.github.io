---
title: 'Zpravodaj „Bitcoin Optech” č. 236'
permalink: /cs/newsletters/2023/02/01/
name: 2023-02-01-newsletter-cs
slug: 2023-02-01-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu na bezserverový payjoin a nápadu na
posílání důkazu asynchronních LN plateb. Také nechybí naše pravidelná
rubrika s výčtem významných změn v populárních bitcoinových páteřních
projektech.

## Novinky

- **Návrh na bezserverový payjoin:** Dan Gould [poslal][gould payjoin] do
  emailové skupiny Bitcoin-Dev návrh a [implementaci na ověření konceptu][payjoin
  impl] bezserverové verze [BIP78][], protokolu pro [payjoin][topic payjoin].

  Bez použití payjoinu obsahuje typická bitcoinová platba pouze vstupy
  utrácející strany, což umožňuje slídilským organizacím použití [heuristiky
  na základě společného vlastnictví vstupů][common input ownership heuristic],
  která předpokládá, že všechny vstupy transakce patří stejné peněžence.
  Payjoin tuto heuristiku prolamuje tím, že umožňuje příjemci přispět
  platbě svými vstupy. Tato technika nabízí okamžité zlepšení soukromí
  uživatelům payjoinu i obecně všem uživatelům bitcoinu snížením
  spolehlivosti zmíněné heuristiky.

  Avšak flexibilita payjoinu nedosahuje flexibility typické bitcoinové platby.
  Většina běžných plateb může být odeslána, i když je příjemce offline,
  ale payjoin vyžaduje, aby byl příjemce online a podepsal své vstupy.
  Existující protokol payjoinu také vyžaduje, aby byl příjemce schopný
  akceptovat HTTP požadavky na síťové adrese přístupné odesílateli,
  čehož příjemce většinou dosáhne provozováním webového serveru na veřejné
  IP adrese, na které poslouchá příslušný software. Jak bylo zmíněno ve
  [zpravodaji č. 132][news132 payjoin] (*angl.*), jednou z možností
  pro navýšení použití payjoinu by bylo provozovat jej více P2P mezi
  běžnými peněženkami.

  Gould navrhuje přidat do peněženek se schopností payjoinu lehký HTTP
  server se šifrováním pomocí [protokolu Noise][noise protocol] a možností
  použít [protokol TURN][TURN protocol] k překonání [NATu][NAT].
  To by umožnilo dvěma peněženkám interaktivně komunikovat během krátké
  doby, která je potřeba pro vytvoření payjoinové platby, bez nutnosti
  dlouhodobě provozovat webový server. To by však stále neumožnilo
  vytvářet payjoin, když je příjemce offline. Gould navrhuje prozkoumat
  možnosti [protokolu NOSTR][nostr protocol] pro případné použití s
  asynchronním payjoinem.

  V době psaní neobdržel návrh v emailové skupině žádné odpovědi.

- **Důkaz asynchronní LN platby:** jak bylo zmíněno [v minulém čísle
  zpravodaje][news235 async], vývojáři LN hledají způsob posílání
  [asynchronních plateb][topic async payments], které poskytují plátci
  důkaz o přijetí platby. Asynchronní platba umožňuje plátci (Alici)
  poslat LN platby příjemci (Bobovi) běžným způsobem přeposíláním
  mezi uzly, mezi kterými je i LSP (poskytovatel lightningové služby),
  který platbu Bobovi pozdrží, je-li zrovna offline. Jakmile Bob
  LSP oznámí, že je opět online, LSP přepošle platbu dále na cestu
  směrem k Bobovi.

  Jelikož je Bob offline, nemůže tímto způsobem v současném LN
  (založeném na [HTLC][topic htlc]) poskytnout Alici fakturu obsahující
  tajný kód podle svého výběru. Namísto toho může Alice použít jí zvolený
  tajný kód a začlenit ho do asynchronní platby, kterou odešle Bobovi
  (tento způsob se nazývá [keysend][topic spontaneous payments] platba).
  Ale jelikož zná Alice tento tajný kód, nemůže jeho znalost použít jako
  důkaz platby Bobovi. Jinou možností je, že Bob dopředu vygeneruje několik
  standardních faktur a poskytne je svému LSP, který by je mohl doručit
  případným plátcům, jako je Alice. Platba takových faktur by vygenerovala
  důkaz, že Bob platbu přijal. Avšak tento způsob by nezabránil LSP
  odeslat stejnou fakturu několika plátcům, což by vyústilo v několik plateb
  za stejný tajný kód. V okamžiku, kdy se LSP dozví tajný kód v důsledku
  provedení první platby, mohl by LSP ukrást prostředky zbývajících plateb
  za přepoužité faktury. To by bylo bezpečné pouze v případě, že by Bob
  mohl zcela důvěřovat svému LSP.

  Tento týden [navrhl][towns async] Anthony Towns řešení založené na
  [signature adaptors][topic adaptor signatures]. To by záviselo na
  plánovaném upgradu LN pro používání [PTLC][topic ptlc]. Bob by dopředu
  vygeneroval sérii nonce čísel pro podepisování a předal je svému LSP.
  Ten by poslal nonce číslo Alici, Alice by zvolila zprávu pro potvrzení platby
  (např. „Alice zaplatila Bobovi 1 000 sat 2023-02-01 12:34:56Z”) a použila
  by Bobovo nonce číslo a tuto zprávu k vygenerování signature adaptor pro
  svůj PTLC. Až bude Bob opět online, LSP mu přepošle platbu a Bob ověří,
  že nonce nebylo nikdy předtím použito, že souhlasí se zprávou, že platba
  je validní a že výpočet signature adaptor je správný. Poté platbu přijme
  a až Alice obdrží dokončené PTLC, obdrží tím svou zprávu podepsanou Bobem.

  Townsovo řešení také vyžaduje, aby LSP obdržel od Boba dopředu vygenerované
  faktury, avšak je oproti HTLC bezpečné a nevyžaduje důvěru, protože každá
  platba od různých plátců (jako je např. Alice) používá odlišný bod
  veřejného klíče PTLC a Bob má možnost zabránit znovupoužití nonce. Každý bod
  PTLC je odlišný, protože je odvozen od jedinečné zprávy zvolené každým
  plátcem. Bob může zabránit znovupoužití nonce jeho zkontrolováním před
  přijmutím platby.

  Ve svém příspěvku [odkazuje][towns sa1] Towns na dva [předešlé][towns sa2]
  příspěvky, které napsal o důkazech LN platby pomocí signature adaptors.
  V době psaní nebyly do emailové skupiny poslány žádné odpovědi.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26471][] snižuje výchozí kapacitu mempoolu z 300 MB na 5 MB,
  aktivuje-li uživatel režim `-blocksonly`. Jelikož je nepoužitá paměť
  mempoolu sdílena s dbcache, snižuje tato změna také výchozí velikost
  dbcache v `-blocksonly` režimu. Uživatelé mohou i nadále zvolit větší
  kapacitu mempoolu pomocí volby `-maxmempool`.

- [Bitcoin Core #23395][] přidává do `bitcoind` volbu `-shutdownnotify`,
  která spustí volitelný příkaz, když se `bitcoind` ukončuje.

- [Eclair #2573][] přináší přijímání [keysend][topic spontaneous
  payments] plateb, které neobsahují [skrytá data][topic payment
  secrets], ani když je Eclair obecně požaduje. Dle popisu změny
  posílají LND i Core Lightning keysend platby bez těchto skrytých dat.
  Skrytá data („payment secrets”) byla navržena na podporu [plateb s více
  cestami][topic multipath payments], Eclair tedy očekává, že ostatní
  implementace budou posílat keysend platby pouze s jedinou cestou.

- [Eclair #2574][] v souvislosti s předchozí změnou přestává posílat
  skrytá data v keysend platbách. Dle popisu LND odmítá keysend platby,
  které skrytá data obsahují, i přesto, že toto není specifikováno
  v [BLIP3][].

- [Eclair #2540][] mění způsob ukládání dat o otevíracích a commitment
  transakcích v přípravě na pozdější přidání podpory pro [splicing][topic
  splicing]. Viz změnu [#2584][eclair #2584], která obsahuje návrh podpory
  splicingu.

- [LND #7231][] přidává RPC volání a volbu `lncli` pro podepisování
  a ověřování zpráv. Formát pro P2PKH je kompatibilní s RPC voláním
  `signmessage`, které bylo přidáno do Bitcoin Core v roce 2011.
  Pro P2WPKH a P2SH-P2WPKH (též zvaný vnořený či nested P2PKH) je
  použit shodný formát. Tento formát očekává, že podpis bude
  ve formátu ECDSA, a ověření vyžaduje možnost odvození veřejného
  klíče z podpisu. V případě P2TR, které by byly použity s [Schnorrovými
  podpisy][topic schnorr signatures], není možné odvodit veřejný
  klíč z podpisu. Namísto toho jsou pro P2TR adresy generovány a
  ověřovány ECDSA podpisy.

  Poznámka: Optech obecně [doporučuje nepoužívat][p4tr new hd] ECDSA
  podpisy s klíči určenými pro použití se Schnorrovými podpisy, avšak
  aby se vyhnuli potížím, učinili vývojáři LND [mimořádné kroky][osuntokun
  sigs].

- [LDK #1878][] přidává vedle globálního nastavení možnost stanovit
  `min_final_cltv_expiry` i za jednotlivé platby. Tato hodnota určuje
  nejvyšší počet bloků, během kterého musí příjemce platbu nárokovat,
  než expiruje. Standardní výchozí volba je 18 bloků, avšak příjemci
  mohou nastavením parametru v [BOLT11][] faktuře požádat o prodloužení.

  Aby mohl LDK v kombinaci se svou unikátní implementací [bezestavových
  faktur][topic stateless invoices] tuto schopnost podporovat, kóduje hodnotu
  do [skrytých dat][topic payment secrets], která musí odesílatel začlenit.
  Poskytuje pro tuto volbu 12 bitů, což umožňuje nastavit až 4 096 bloků
  (zhruba čtyři týdny).

- [LDK #1860][] přidává podporu pro kanály používající [anchor výstupy][topic
  anchor outputs].

{% include references.md %}
{% include linkers/issues.md v=2 issues="26471,23395,2573,2574,2584,2540,1878,1860,7231" %}
[common input ownership heuristic]: https://en.bitcoin.it/wiki/Privacy#Common-input-ownership_heuristic
[news132 payjoin]: /en/newsletters/2021/01/20/#payjoin-adoption
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021364.html
[payjoin impl]: https://github.com/chaincase-app/payjoin/pull/21
[noise protocol]: http://www.noiseprotocol.org/
[turn protocol]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT
[nat]: https://cs.wikipedia.org/wiki/Network_address_translation
[nostr protocol]: https://github.com/nostr-protocol/nostr
[news235 async]: /cs/newsletters/2023/01/25/#pozadavek-dukazu-ze-asynchronni-platba-byla-prijata
[towns async]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003831.html
[towns sa1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001034.html
[towns sa2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001490.html
[osuntokun sigs]: https://github.com/lightningnetwork/lnd/pull/7231#issuecomment-1407138812
[p4tr new hd]: /en/preparing-for-taproot/#use-a-new-bip32-key-derivation-path
