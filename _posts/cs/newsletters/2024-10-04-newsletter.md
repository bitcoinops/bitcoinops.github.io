---
title: 'Zpravodaj „Bitcoin Optech” č. 323'
permalink: /cs/newsletters/2024/10/04/
name: 2024-10-04-newsletter-cs
slug: 2024-10-04-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje plánované odhalení bezpečnostní zranitelnosti
a připojuje naše pravidelné rubriky s popisem nových vydání a významných
změn v populárním bitcoinovém páteřním software.

## Novinky

- **Nadcházející odhalení bezpečnostní zranitelnosti btcd:** Antoine Poinsot zaslal do fóra
  Delving Bitcoin [příspěvek][poinsot btcd] s oznámením odhalení chyby
  konsenzu postihující plné uzly btcd plánované na 10. října. Z hrubého
  průzkumu aktivních plných uzlů Poinsot odhaduje, že kolem 36 btcd
  uzlů je stále zranitelných (i když 20 z nich též trpí zranitelností,
  která byla již odhalena, viz [zpravodaj č. 286][news286 btcd vuln]).
  V [odpovědi][osuntokun btcd] potvrdil vývojář btcd Olaoluwa Osuntokun
  existenci zranitelnosti a její opravení ve verzi 0.24.2. Provozovatelé
  starší verze btcd jsou nabádáni k upgradu na [poslední verzi][btcd v0.24.2],
  která byla označena za kritickou opravu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 28.0][] je nová hlavní verze této převládající implementace
  plného uzlu. Jedná se o první vydání podporující [testnet4][topic testnet],
  příležitostné [přeposílání balíčku][topic package relay] s jedním rodičem
  a jedním rodičem (one-parent-one-child package relay, 1p1c). Dále přináší
  aktivované přeposílání transakcí do potvrzení topologicky omezených ([TRUC][topic
  v3 transaction relay]), aktivované přeposílání [pay-to-anchor][topic ephemeral
  anchors] transakcí, omezené [RBF][topic rbf] přeposílání balíčků a aktivovaný
  [full-RBF][topic rbf]. Byly přidány výchozí parametry pro [assumeUTXO][topic
  assumeutxo], což umožní použít RPC příkaz `loadtxoutset` k načtení
  množiny UTXO stažené mimo bitcoinovou síť (např. přes torrent). Vydání též
  obsahuje mnoho dalších vylepšení a oprav chyb. Pro podrobnosti viz
  [poznámky k vydání][bcc 28.0 rn].

- [BDK 1.0.0-beta.5][] je kandidátem na vydání této knihovny pro budování
  peněženek a jiných aplikací s podporou bitcoinu. Tento kandidát „aktivuje
  ve výchozím nastavení RBF a klient bdk_esplora se bude po selhání opakovaně
  zkoušet znovu připojit. Balíček `bdk_electrum` také nově nabízí konfigurační
  příznak `use-openssl`.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #30043][] přináší vestavěnou implementaci [Port Control Protocol
  (PCP)][rfcpcp] s podporou IPv6 pinholingu, který uzlům umožní dostupnost
  bez manuální konfigurace routeru. Tato změna nahrazuje stávající závislost
  `libnatpmp` pro mapování IPv4 portů s PCP a zároveň implementuje záložní
  mechanismus pro [NAT Port Mapping Protocol (NAT-PMP)][rfcnatpmp]. Ačkoliv
  je PCP / NAT-PMP ve výchozím nastavení neaktivní, v budoucích vydáních se
  to může změnit. Viz též [zpravodaj č. 131][news131 natpmp] (_angl._).

- [Bitcoin Core #30510][] přidává k rozhraní `Mining` (viz [zpravodaj č.
  310][news310 stratumv2]) wrapper meziprocesové komunikace (IPC). To
  oddělenému [Stratum v2][topic pooled mining] procesu umožní vytvářet, spravovat
  a odesílat šablony bloků připojením k procesu `bitcoin-node` (viz též
  [zpravodaj č. 320][news320 stratumv2]). [Bitcoin Core #30409][] rozhraní
  `Mining` rozšiřuje o novou metodu `waitTipChanged()`, která detekuje
  nově příchozí blok a pošle tento blok připojeným klientům. RPC metody
  `waitfornewblock`, `waitforblock` a `waitforblockheight` nově tuto metodu
  používají.

- [Core Lightning #7644][] přidává do nástroje `hsmtool` příkaz `nodeid`,
  který pro daný záložní soubor `hsm_secret` vrací identifikátor uzlu.
  Cílem je předejít nejasnostem při párování uzlů a jejich záloh.

- [Eclair #2848][] implementuje rozšiřitelné [inzeráty likvidity][topic
  liquidity advertisements] (liquidity advertisements) dle návrhu v [BOLTs #1153][].
  Umožní prodejcům ve svých zprávách `node_announcement` inzerovat ceny, za kterých
  jsou ochotni prodat likviditu. Kupující se potom k těmto uzlům mohou připojit
  a o likviditu požádat. Použity mohou být též k vytváření [kanálů s oboustranným
  financováním][topic dual funding] či pro přidání likvidity k existujícím kanálům
  pomocí [splicingu][topic splicing].

- [Eclair #2860][] přidává volitelnou zprávu `recommended_feerates`, kterou mohou
  uzly použít k informování svých spojení o poplatcích, které považují za akceptovatelné
  a které si přejí použít pro otevírací transakce. Pokud uzel odmítne žádost
  o otevření, bude zřejmé, že tak bylo na základě nesouladu představ o poplatcích.

- [Eclair #2861][] implementuje financování za běhu dle specifikace v [BLIPs #36][].
  Umožní klientům s nedostatečnou příchozí likviditou požádat o dodatečnou
  likviditu pomocí protokolu [inzerování likvidity][topic liquidity advertisements]
  (viz PR výše) a platbu tak obdržet. Prodejce likvidity platí poplatky za onchain
  transakce u [kanálů s oboustranným financováním][topic dual funding] nebo
  [splicingu][topic splicing], ale později během routování platby je kupující
  zaplatí zpět. Pokud není platba za poplatek dostatečná, prodejce může transakci
  utratit podruhé a použít likviditu jinde.

- [Eclair #2875][] implementuje kredit pro placení poplatku za otevření kanálu
  dle specifikace v [BLIPs #41][]. Umožní klientům s financováním za běhu (viz PR
  výše) přijmout platby, které jsou příliš nízké na pokrytí onchain poplatků.
  Jakmile je nashromážděn dostatečný kredit na poplatky, může být použit k vytvoření
  onchain transakce např. pro financování či [splicing][topic splicing].
  Klienti spoléhají, že poskytovatelé likvidity budou v budoucích transakcích
  tento kredit ctít.

- [LDK #3303][] přidává do příchozí platby nové pole typu `PaymentId`. Záměrem
  je zlepšit idempotenci zpracování událostí, patřičné události během restartu
  uzlu tak budou zpracovány pouze jednou. Dříve se používal haš platby, který
  mohl vést k duplikovaným událostem. `PaymentId` je autentizační kód zprávy
  založený na haši (HMAC) identifikátoru kanálu a [HTLC][topic htlc] obsažených
  v těle platby.

- [BDK #1616][] ve výchozím stavu signalizuje [RBF][topic rbf] v `TxBuilder`.
  Volající může signál změnit patřičným číslem sekvence.

- [BIPs #1600][] přináší několik změn do specifikace [BIP85][], mezi které patří
  např. objasnění, že `drng_reader.read` (pro čtení náhodných čísel) je identifikátor
  funkce a ne její volání, a jasnější je také nakládání s pořadím bajtů. Dále byla přidána
  podpora pro [testnet][topic testnet] (včetně nově referenční implementace v Pythonu),
  upřesněno bylo vysvětlení formátu WIF pro import seedu do [hierarchické deterministické
  peněženky][topic bip32], byl přidán kód pro portugalštinu a opravy se dočkaly
  testovací vektory. Byl též určen nový reprezentant této specifikace.

- [BOLTs #798][] začleňuje specifikaci protokolu [nabídek][topic offers] jako BOLT12.
  Též přináší několik aktualizací [BOLT1][] a [BOLT4][].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30043,30510,7644,2875,2861,2860,2848,3303,1616,1600,798,30409,1153,36,41" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[bitcoin core 28.0]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[poinsot btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177
[osuntokun btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177/3
[news286 btcd vuln]: /cs/newsletters/2024/01/24/#zverejneni-opraveneho-selhani-konsenzu-v-btcd
[btcd v0.24.2]: https://github.com/btcsuite/btcd/releases/tag/v0.24.2
[bcc 28.0 rn]: https://github.com/bitcoin/bitcoin/blob/5de225f5c145368f70cb5f870933bcf9df6b92c8/doc/release-notes.md
[rfcpcp]: https://datatracker.ietf.org/doc/html/rfc6887
[rfcnatpmp]: https://datatracker.ietf.org/doc/html/rfc6886
[news131 natpmp]: /en/newsletters/2021/01/13/#bitcoin-core-18077
[news310 stratumv2]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news320 stratumv2]: /cs/newsletters/2024/09/13/#bitcoin-core-30509
