---
title: 'Zpravodaj „Bitcoin Optech” č. 409'
permalink: /cs/newsletters/2026/06/12/
name: 2026-06-12-newsletter-cs
slug: 2026-06-12-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh BIPu nahrazující testnet4 novou verzí.
Též nechybí naše pravidelné rubriky s oznámeními nových vydání
a popisem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Pracovní verze BIPu pro testnet5**: Pol Espinosa zaslal do emailové skupiny Bitcoin-Dev
  [příspěvek][testnet5 ml] o nové [pracovní verzi BIPu][testnet5 BIP], na kterém pracuje
  spolu s Fabianem Jahrem a který by měl nahradit [testnet4][topic testnet] novou verzí.
  Potřeba založit nový testnet vyvstala po mnoha stížnostech na nízkou spolehlivost současné
  testovací sítě, způsobenou setrvalým zneužíváním takzvané výjimky z obtížnosti (též známé
  jako 20minutové pravidlo). Ta povoluje procesorovým těžařům vytěžit blok s obtížností `1` po
  20 minutách od posledního vytěženého bloku a tím umožňuje provádět „přívaly bloků”, kdy může
  být v krátkém čase vytěžené velké množství bloků s nízkou obtížností (viz též [zpravodaj č. 311][news311
  block storm]).

  Pracovní verze BIPu navrhuje odstranit tuto výjimku, aby byl testnet v souladu
  s mainnetem co nejvíce. Testnet5 by se řídil stejnými pravidly konsenzu jako
  mainnet kromě dvou změn: aktivace [BIP54][] ([soft fork pročištění konsenzu][topic
  consensus cleanup]) od bloku `1` a nastavení nejvyššího cíle pro proof of work
  na `0x1a0fffff` (nižší maximum než testnet4, tedy vyšší minimální obtížnost).

  Espinosa vyzval ostatní vývojáře k poskytnutí zpětné vazby. Diskuze v emailové
  skupině se točila kolem nápravy testnet4 namísto zakládání nového,
  možnosti vytěžení mincí předem a nejlepší minimální obtížnosti sítě.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.21.0-beta][] je vydáním příští hlavní verze této populární implementace
  LN uzlu. Přidává základní přeposílání [onion zpráv][topic onion messages],
  produkční jednoduché [taprootové][topic taproot] kanály s podporou [RBF][topic rbf]
  kooperativního zavírání, ochranu zavírání kanálu před reorganizacemi řetězce,
  rychlejší úvodní synchronizaci u uzlů používajících [Neutrino][topic compact block filters],
  volitelnou migraci na úložiště s nativním SQL a opravuje několik chyb.

- [Core Lightning 26.06.1][] je údržbové vydání současné hlavní verze tohoto
  oblíbeného LN uzlu. Opravuje chybu registrace pluginu `bwatch` po volání
  `make install`.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #35410][] opravuje chybu, kvůli které mohl být opakovaný
  pokus o [soukromé zveřejnění transakce][topic transaction origin privacy]
  učiněn přímo přes IPv4 nebo IPv6 namísto [Toru nebo I2P][topic anonymity networks].
  Když se zavolá příkaz `sendrawtransaction` s `-privatebroadcast=1` (viz
  [zpravodaj č. 388][news388 private broadcast]), Bitcoin Core odvysílá
  transakci spojením přes Tor nebo I2P. Pokud se některé spojení pokusí o
  v2 transport dle [BIP324][] a selže, provede opakovaný pokus přes v1 transport.
  Dříve mohl být tento opakovaný pokus proveden přes přímé IPv4/IPv6 spojení
  bez Tor/I2P proxy. Tato chyba je nyní opravena.

- [Bitcoin Core #34779][] implementuje [BIP323][], čímž pro těžaře rezervuje bity 5 až 28
  v `nVersion` jako dodatečný prostor pro nonce (viz [zpravodaj č. 405][news405 bip323]).
  Dříve byly tyto bity částí, která byla sledována pro [BIP9][] signalizaci neznámých
  soft forků. Bitcoin Core již tyto bity pro tento účel nesleduje. Těžaři,
  kteří tento bitový rozsah používají pro nonce, tak nevyvolají varování o
  neznámém soft forku.

- [Bitcoin Core #32150][] přepisuje algoritmus [větví a mezí][Branch-and-Bound]
  (branch-and-bound) používaný pro [výběr mincí][topic coin selection] tak, aby
  se nevracel po částech vyhledávacího stromu, které pouze reprodukují
  stejné vstupní množiny. Namísto opakovaného zpětného vyhledávání a testování
  stejných prefixů výběru sleduje upravený algoritmus další UTXO k vyzkoušení,
  ořezává větve, které cíle dosáhnout nemohou, přesouvá se přímo k dalšímu
  užitečnému kandidátovi a přeskakuje duplikované nebo nákladnější UTXO
  se stejnou efektivní hodnotou. To vše umožňuje peněžence zabývat se více jedinečnými
  výběry kandidátů.

- [LDK #4647][] přestává pro [BOLT12][topic offers] [trasy zaslepených
  zpráv][topic rv routing] používat vzdálené úvodní uzly. Tím odstraňuje
  nekompatibilitu s volitelnou podporou [onion zpráv][topic onion messages]
  v LND, které od spojení, se kterými nemá otevřený kanál, zprávy přijímá,
  ale nepřeposílá. LDK nově používá samotného oznámeného příjemce jako úvodní
  bod, čímž zlepšuje interoperabilitu za cenu snížení soukromí příjemce.

- [BTCPay Server #7218][] přidává průvodce nastavením multisig peněženek.
  Majitelé obchodů mohou zvolit pravidla podepisování, vyzvat uživatele
  obchodů k předání klíčů (manuálně či přes BTCPay Server Vault), ověřit
  vygenerované adresy a po získání všech klíčů vytvořit samotnou peněženku.

- [BIPs #2186][] přidává do [BIP77][] specifikaci, jak mají příjemci
  [Payjoin v2][topic payjoin] odpovídat na požadavky odesílatelů kompatibilních
  s [BIP78][]. Dle [BIP77][] se v odpovědi používá klíč pro odpověď poskytnutý
  odesílatelem k zašifrování navrhovaného [PSBT][topic psbt] a doručí se
  do schránky. Dle [BIP78][] ovšem odesílatelé neposkytují klíč pro odpověď.
  Namísto toho příjemce zašle navrhovaný PSBT zpět do své schránky, kam
  odesílatel zaslal původní PSBT. Příjemce dále použije PUT request do
  adresáře zapouzdřený do OHTTP.

{% include snippets/recap-ad.md when="2026-06-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35410,34779,32150,4647,7218,2186" %}

[testnet5 ml]:https://groups.google.com/g/bitcoindev/c/kGUMTxOvdJA/m/Eyx5FxQeAAAJ
[testnet5 BIP]: https://github.com/fjahr/bips/pull/2
[news311 block storm]: /cs/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[LND 0.21.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta
[Core Lightning 26.06.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.1
[news388 private broadcast]: /cs/newsletters/2026/01/16/#bitcoin-core-29415
[news405 bip323]: /cs/newsletters/2026/05/15/#bips-2116
[Branch-and-Bound]: https://cs.wikipedia.org/wiki/Metoda_v%C4%9Btv%C3%AD_a_mez%C3%AD
