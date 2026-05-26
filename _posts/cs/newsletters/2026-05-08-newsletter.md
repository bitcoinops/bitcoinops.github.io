---
title: 'Zpravodaj „Bitcoin Optech” č. 404'
permalink: /cs/newsletters/2026/05/08/
name: 2026-05-08-newsletter-cs
slug: 2026-05-08-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje možná řešení problému identifikace uzlů a odkazuje na diskuzi
o používání veřejných dokladů o podvodu pro zlepšení incentiv u just-in-time kanálů.
Též nechybí naše pravidelné rubriky s popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Možné ochrany proti identifikaci uzlu**: Naiyoma zaslala do fóra Delving Bitcoin
  [příspěvek][fing del] o možném řešení problému identifikace shodných uzlů napříč sítěmi
  pomocí časového razítka ve zprávě `addr` (viz [zpravodaj č. 360][news360 fing]).

  Od poslední aktualizace získali výzkumníci nové poznatky o problému a identifikovali nové
  faktory, které je třeba vzít v úvahu. Jeden z klíčových poznatků byl spojen s `AddrMan`em
  (kódem, který spravuje adresy). `AddrMan` považuje adresy za nepoužívané, pokud je jejich
  časové razítko starší než 30 dní, obvykle kvůli offline peer spojení. Kvůli tomu hrají důležitou
  roli dva faktory: změna starých časových razítek na novější může způsobit opakované
  šíření starých adres a změna na starší časová razítka může způsobit předčasný konec
  jejich šíření. To vedlo k vyloučení některých dříve uvažovaných řešení a k poskytnutí nových:

  1. **Náhodnost**: Náhodné zkreslení časových razítek v rozsahu mezi −5 až +5 dny.
    Zkreslení se však v průběhu času může zprůměrovat.

  2. **Pevně daná časová razítka napříč sítěmi**: Během odpovídání na požadavek je skutečné
    časové razítko zachováno pro tu konkrétní síť, ale pro ostatní sítě jsou časová razítka
    zvolená náhodně z minulosti. Staré adresy však mohou zůstat v oběhu déle, než je nutné.

  3. **Náhodnost – adresy pouze starší**: Adresy se stávají pouze staršími, nikdy novějšími,
    aplikováním náhodného zkreslení v rozsahu 1 až 10 dní. Adresy však mohou dosáhnout 30denního
    limitu příliš rychle.

  4. **Náhodnost – adresy převážně starší**: Aplikace náhodného zkreslení v rozsahu
    −1 až +5 dní. Adresy se tak stávají hlavně staršími, novějšími pouze s malou pravděpodobností.
    Staré adresy však mohou zůstat v oběhu déle, než je nutné.

  5. **Kombinace**: Poslední možností je zkombinovat předchozí dva přístupy.

  Naiyoma dále požádala o zpětnou vazbu a odkázala na [PR][fing gh], ve kterém testovala řešení č. 2.

- **Just-in-time kanály a veřejné doklady o podvodu**: Thomas Voegtlin zaslal do fóra Delving Bitcoin
  [příspěvek][jit del] o novém návrhu na vylepšení teorie her stojící za [just-in-time (JIT)
  kanály][topic jit channels] použitím veřejných dokladů o podvodu, které mohou prokázat
  nevhodné chování LSP.

  Alice vyjedná otevření JIT kanálu s LSP (Bobem). Až bude Alice potřebovat přijmout
  satoshi od Carol, vytvoří předobraz. Carol pošle Bobovi [HTLC][topic htlc]. Alice Bobovi odhalí
  předobraz s očekáváním, že LSP zveřejní otevírací transakci kanálu. Co se stane, pokud
  Bob nárokuje HTLC, aniž by s Alicí otevřel kanál?

  Voegtlin navrhuje používat řetězec jako veřejný prostor pro rozhodování sporů. Alice by měla
  předobraz zveřejnit v `OP_RETURN`, aby mohl kdokoliv jeho odhalení ověřit a datovat. Na své
  straně by Bob vytvořil závazek pro UTXO platný až na počet bloků `n`. Pokud toto UTXO utratí
  v jiné transakci, než ke které se zavázal, nebo otevírací transakci nezveřejní, nebo pokud se
  pokusí transakci dvojitě utratit, vytvořil by tím doklad o podvodu. Tím by došlo k poškození
  jeho reputace jako LSP, aniž by museli ostatní klienti důvěřovat Alici.

  Voegtlin nabídl [článek][jit paper gist] obsahující podrobné vysvětlení a vyzval ostatní
  vývojáře k poskytnutí zpětné vazby.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33796][] přidává do C API `libbitcoinkernel` (viz [zpravodaj
  č. 380][news380 kernel], _angl._) funkci `btck_check_transaction()`, která
  provede bezkontextové kontroly struktury transakce na úrovni konsenzu.
  Odmítne transakce bez vstupů a výstupů, s neplatnou délkou scriptSig
  v mincetvorné transakci, s duplikovanými vstupy, bez odkazu na
  předchozí výstup v jiné než mincetvorné transakci či s hodnotami výstupů
  mimo platný rozsah. Ke kontrole není třeba mít k dispozici stav řetězce,
  množinu UTXO ani ověřování skriptu.

- [Bitcoin Core #21283][] implementuje podporu pro [PSBTv2][topic psbt] dle
  [BIP370][]. Zpětná kompatibilita s PSBTv0 zůstává zachována. PSBTv2
  ukládá data potřebná ke konstrukci transakce, jako jsou verze, locktime,
  vstupy, výstupy a modifikovatelnost transakce, přímo v PSBT polích namísto
  v kompletní nepodepsané transakci.

- [BIPs #2150][] přidává [BIP451][], specifikaci protokolu pro likvidaci UTXO
  s prachem (Dust UTXO Disposal Protocol). Ten definuje standard pro peněženky,
  jak bezpečně nakládat s nechtěnými UTXO s [prachem][topic uneconomical outputs]:
  utratit je do jediného `OP_RETURN` výstupu s nulovou hodnotou a použít celou hodnotou
  vstupu na transakční poplatky. Protokol obsahuje pravidla konstrukce
  pro zachování soukromí, jako je likvidace potvrzených UTXO po jednotlivých
  adresách a podpisy s `ALL|ANYONECANPAY`, které umožní čekajícím nesouvisejícím
  transakcím likvidujícím prach dávkování pomocí [RBF][topic rbf].

- [Eclair #3144][] aktualizuje [jednoduché taprootové kanály][topic simple taproot
  channels]. Nově používají oficiální feature bit a jsou ve výchozím nastavení
  aktivní (zatím bez odpory jejich oznamování). Byla přidána testovací
  data pro zajištění souladu s BOLT specifikacemi a implementací v LND
  (viz [zpravodaj č. 401][news401 lnd]).

- [Eclair #2887][] přidává podporu oficiálního protokolu [splicingu][topic splicing],
  který je součástí BOLT specifikace (viz [zpravodaj č. 398][news398
  splicing]). Kompatibilita s dřívější experimentální implementací zůstává
  zachována.

- [LDK #4592][] začíná během kontroly, zda má uzel před otevřením nového kanálu
  s [commitmentem s nulovým poplatkem][topic v3 commitments] (0FC) dostatečné rezervy,
  počítat tyto kanály jako [anchor][topic anchor outputs] kanály. Dříve byly
  počítány pouze takové kanály, které používaly starší `anchors_zero_fee_htlc_tx`,
  což uzlům umožňovalo otevřít více 0FC kanálů, než pro kolik mohla peněženka
  bezpečně navýšit poplatky během současných vynucených zavření.

- [LND #9153][] přidává do zprávy `Route` pole `source_pub_key`. Tím umožní
  konstruovat a deserializovat cesty z perspektivy jiného než místního uzlu.
  Pokud toto pole není nastaveno, LND bude i nadále používat místní uzel.

- [Rust Bitcoin #5835][] přidává konstruktor pro `V1MessageHeader`, který počítá
  čtyřbajtový kontrolní součet dat používaný v hlavičkách P2P zpráv. Tím
  je konstrukce síťových zpráv jednodušší, neboť volající mohou dopředu sestavit
  hlavičku serializovaných přenášených dat.

- [BOLTs #995][] přidává rozšiřující BOLT pro [jednoduché taprootové kanály][topic
  simple taproot channels] s feature bity 80/81. Specifikace definuje minimální
  druh kanálu založený na [taprootu][topic taproot], který v otevírací transakci
  používá P2TR výstup s [MuSig2][topic musig] agregací klíčů, v commitmentu a HTLC
  používá taprootové skripty a definuje nová TLV pole pro výměnu částečných podpisů
  a noncí pro MuSig2 během otevírání kanálu, aktualizací commitmentu, kooperativních
  uzavření kanálu a opakovaných připojení. Nonce v `revoke_and_ack` a
  `channel_reestablish` jsou sdružené dle txid, aby bylo možné mít několik aktivních
  commitment transakcí (např. během [splicingu][topic splicing]). Záměrně
  nebyly přidány změny gossip protokolu; [oznamování taprootových kanálů][topic
  channel announcements] tak čeká na vyřešení v budoucnosti.

- [BOLTs #1228][] specifikuje kanály s [commitmenty s nulovými poplatky][topic
  v3 commitments] (0FC) a přiřazuje jim feature bity 40/41. Tento druh kanálů
  má `feerate_per_kw` nastaven na nulu, commitment a [HTLC][topic htlc] transakce
  používají [přeposílání transakcí v3][topic v3 transaction relay] (TRUC) a
  těžební poplatky jsou poskytovány potomky pomocí [CPFP][topic cpfp].
  Commitment transakce obsahují sdílený [pay-to-anchor (P2A)][topic
  ephemeral anchors] výstup financovaný z ořezaných výstupů (max. 240 sat),
  což ve většině případů umožňuje rodičovské transakci neplatit napřímo žádný poplatek.
  Specifikace dále omezuje počet HTLC na 114 kvůli omezení velikosti TRUC transakcí
  (10 kvB).

- [BOLTs #1327][] aktualizuje pravidla navyšování poplatků pomocí [RBF][topic rbf],
  aby byla v souladu s pravidly nahrazování dle [BIP125][] během období s nízkými poplatky.
  Namísto pouhého aplikování stávajícího činitele 25/24 specifikace nově vyžaduje,
  aby byl jednotkový poplatek nahrazující transakce navýšen o vyšší z těchto dvou
  hodnot: zmíněného činitele nebo dodatečných 25 sat/kw. Tím dosáhne chování LDK
  popsaného ve [zpravodaji č. 400][news400 rbf].

{% include snippets/recap-ad.md when="2026-05-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33796,21283,2150,3144,2887,4592,9153,5835,995,1228,1327" %}
[fing del]: https://delvingbitcoin.org/t/fingerprinting-nodes-possible-solutions/2466
[news360 fing]: /cs/newsletters/2025/06/27/#detekce-uzlu-pomoci-zprav-addr
[fing gh]: https://github.com/naiyoma/bitcoin/pull/16
[jit del]: https://delvingbitcoin.org/t/proposal-public-fraud-proofs-for-just-in-time-channels/2451
[jit paper gist]: https://gist.github.com/ecdsa/dfa2d76a5fe845fd283c01b5ed12d274
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news398 splicing]: /cs/newsletters/2026/03/27/#bolts-1160
[news400 rbf]: /cs/newsletters/2026/04/10/#ldk-4494
[news401 lnd]: /cs/newsletters/2026/04/17/#lnd-9985
