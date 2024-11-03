---
title: 'Zpravodaj „Bitcoin Optech” č. 302'
permalink: /cs/newsletters/2024/05/15/
name: 2024-05-15-newsletter-cs
slug: 2024-05-15-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje vydání beta verze plného uzlu s podporou
utreexo a shrnuje dvě navrhovaná rozšíření BIP119 `OP_CHECKTEMPLATEVERIFY`.
Též nechybí naše pravidelné rubriky s oznámeními nových vydání a popisem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Vydání beta verze utreexod:** Calvin Kim zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][kim utreexo] s oznámením vydání beta verze
  utreexod, plného uzlu s podporou [utreexo][topic utreexo]. Utreexo
  umožňuje uzlu namísto kompletní množiny UTXO ukládat pouze malé
  závazky (commitmenty) jejího stavu. Závazek může mít pouhých 32 bajtů,
  což jej činí při současné velikosti plné množiny kolem 12 GB řádově
  miliardkrát menším. Za účelem snížení používání přenosového pásma
  může utreexo ukládat další dodatečné commitmenty; zvýší se sice
  používání diskového prostoru, ale bude i přesto řádově milionkrát nižší
  než u tradičních plných uzlů. Utreexový uzel, který navíc ořezává
  staré bloky, může být provozován s malým konstantním diskovým prostorem.
  To je výhodné v porovnání s běžným ořezaným plným uzlem, který může
  vyžadovat prostor větší, než je disková kapacita zařízení.

  Kimovy poznámky k vydání naznačují, že uzel je kompatibilní s peněženkami
  založenými na [BDK][bdk repo] a mnoha dalšími, které podporují
  [Electrum personal server][]. Uzel podporuje přeposílání transakcí
  díky rozšíření P2P protokolu, které umožňuje přeposílání utreexo
  důkazů. Podporovány jsou _běžné_ i _přemosťovací_ utreexo uzly; běžné utreexo
  uzly používají utreexo commitmenty za účelem šetření diskovým prostorem,
  přemosťovací uzly ukládají kompletní stav UTXO s dodatečnými daty
  a jsou schopné připojit utreexo důkazy k blokům a transakcím, které
  byly vytvořené uzly bez podpory utreexo.

  Utreexo nevyžaduje změnu konsenzu a utreexo uzly nekolidují s uzly
  bez utreexo podpory, avšak běžné utreexo uzly se mohou spojit pouze
  s jinými utreexo uzly, běžnými či přemosťovacími.

  Kim ke svému oznámení připojuje několik varování: „kód ani protokol
  neprošly důkladnou revizí, […] přijdou změny bez zpětné kompatibility
  […] a utreexod je založen na [btcd][], které může být nekompatibilní
  s konsenzem.”

- **Rozšířený BIP119 s menšími hašemi a závazky libovolným datům:**
  Jeremy Rubin zaslal do emailové skupiny Bitcoin-Dev [příspěvek][rubin
  bip119e] s [návrhem BIPu][bip119e] rozšiřujícího navrhovaný opkód
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (`OP_CTV`) dvěma
  novými možnostmi:

  - *Podpora pro hašovací funkci HASH160:* jedná se o haše používané pro
	P2PKH, P2SH a P2WPKH adresy. Mají 20 bajtů narozdíl od 32bajtových hašů
	používaných v návrhu [BIP119][]. V naivních protokolech s více stranami
	může být [útok hledáním kolize][collision attack] na 20bajtové haše proveden
	zhruba s 2<sup>80</sup> operacemi hrubé síly, což je v dosahu vysoce
	motivovaného útočníka. Z tohoto důvodu moderní bitcoinové opkódy
	obvykle používají 32bajtové haše. Avšak zabezpečení protokolů s jedním
	účastníkem nebo dobře navržených protokolů s více stranami používajících
	20bajtové haše může být navýšeno tak, že jeho kompromitace v méně
	než 2<sup>160</sup> operacích je nepravděpodobná. Díky tomu mohou
	protokoly vyžadovat o 12 bajtů na haš méně. Jedním příkladem, kde to
	může být přínosné, je implementace protokolu [eltoo][topic eltoo]
	(viz [zpravodaj č. 284][news284 eltoo]).

  - *Podpora pro více druhů commitmentů:* `OP_CTV` skončí úspěšně, je-li
	spuštěn v transakci, jejíž vstupy a výstupy jsou zahašovány do stejných
	hodnot jako poskytnuté otisky. Jedním z těchto výstupů by mohl být
	`OP_RETURN`, který zavazuje nějakým datům, která chce autor skriptu
	publikovat na blockchainu, například data nezbytná pro obnovení LN
	kanálu ze zálohy. Avšak umístit tato data ve witnessu by bylo výrazně
	levnější. Navržená rozšířená forma `OP_CTV`umožňuje autorovi skriptu
	požadovat, aby byla během hašování vstupů a výstupů použita i část dat
	ze zásobníku witnessu. Tato data budou porovnána s otiskem poskytnutým
	autorem skriptu. Díky tomu budou mít data publikovaná v blockchainu
	minimální váhu.

  Návrh neobdržel v době psaní tohoto čísla žádné reakce.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK v0.0.123][] je vydáním této knihovny pro budování LN aplikací.
  Obsahuje aktualizaci nastavení [ořezaných HTLC][topic trimmed htlc],
  vylepšení podpory [nabídek][topic offers] a další.

- [LND v0.18.0-beta.rc2][] je kandidátem na vydání příští hlavní verze
  tohoto oblíbeného LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29845][] mění v několika RPC voláních typu `get*info` pole
  `warnings`. Namísto jednoduchého řetězce nově obsahuje pole řetězců, aby
  mohlo vrátit více než jedno varování.

- [Core Lightning #7111][] zpřístupňuje pluginům RPC příkaz `check`. Možnosti
  příkazu byly dále rozšířeny o `check setconfig`, které kontroluje platnost
  konfiguračních voleb, a `check keysend` zjišťující, zda by hsmd danou
  transakci schválilo. Byla přidána předinicializační zpráva s přednastavenými
  vývojovými HSM příznaky. O příkazu `check` jsme se též zmiňovali ve zpravodajích
  [č. 25][news25 cln check] a [č. 47][news47 cln check] (oba _angl._).

- [Libsecp256k1 #1518][] přidává funkci `secp256k1_pubkey_sort`, která kanonicky
  seřadí množinu veřejných klíčů. To je užitečné pro [MuSig2][topic musig], [tiché
  platby][topic silent payments] a zřejmě i mnoho dalších protokolů používajících
  více klíčů.

- [Rust Bitcoin #2707][] upravuje API pro tagované haše představené jako součást
  [taprootu][topic taproot] tím, že ve výchozím stavu očekává otisky v _interním
  pořadí bajtů_. Dříve API očekávalo haše v _pořadí bajtů pro zobrazování_, které
  lze nově vyžádat atributem `#[hash_newtype(backward)]`. Z [historických důvodů][mb3e
  byte order] jsou haše použité jako txid a identifikátory bloků uložené v transakcích
  a blocích v jednom pořadí bajtů (interní), ale zobrazovány jsou v opačném pořadí
  (pořad pro zobrazování). Toto PR se snaží zabránit, aby i další haše měly
  v různých případech různá pořadí bajtů.

- [BIPs #1389][] přidává [BIP388][], které popisuje „pravidla peněženek pro deskriptorové
  peněženky.” Jedná se o sadu šablon [deskriptorů výstupních skriptů][topic descriptors],
  které mohou širokému spektru peněženek usnadnit jejich podporu v kódu a
  uživatelském rozhraní. Deskriptory mohou být náročné na implementaci v hardwarových
  peněženkách s omezenými zdroji a zobrazovacím prostorem. Pravidla dle BIP388
  umožní software i hardware přijmout zjednodušující předpoklady o tom,
  jak budou deskriptory používány. Dosáhnou tak redukce potřebného kódu a množství
  detailů, které musí uživatelé ověřit. Software, který vyžaduje kompletní
  podporu deskriptorů, je může nadále používat nezávisle na BIP388. Další
  podrobnosti přinesl [zpravodaj č. 200][news200 policies].

- [BIPs #1567][] přidává [BIP387][] popisující nové deskriptory `multi_a()` a
  `sortedmultia_a()`, které poskytují možnosti skriptovaných multisig operací
  uvnitř [tapscriptu][topic tapscript]. BIP uvádí příklad fragmentu deskriptoru:
  `multi_a(k,KEY_1,KEY_2,...,KEY_n)` vyprodukuje skript
  `KEY_1 OP_CHECKSIG KEY_2 OP_CHECKSIGADD ... KEY_n OP_CHECKSIGADD OP_k
  OP_NUMEQUAL`.  Dále viz zpravodaje [č. 191][news191 multi_a] (_angl._),
  [č, 227][news227 multi_a] a [č. 273][news273 multi_a].

- [BIPs #1525][] přidává [BIP347][], který navrhuje opkód [OP_CAT][topic op_cat].
  Tento opkód by mohl být v případě [aktivace][topic soft fork activation] v soft forku
  používán v [tapscriptech][topic tapscript]. Dále viz zpravodaje [č, 274][news274 op_cat],
  [č. 275][news275 op_cat] a [č. 293][news293 op_cat].

## Změna času publikace zpravodaje

V následujících týdnech bude Optech experimentovat s alternativním časem publikování.
Nebuďte prosím překvapeni, pokud obdržíte zpravodaj o několik dní dříve či později.
Během krátké doby věnované experimentu budou zpravodaje zaslané emailem obsahovat trasovací
kód, který nám pomůže určit jeho čtenost. Sledování můžete zabránit předchozím zákazem načítání
externích zdrojů. Pokud vyžadujete více soukromí, doporučujeme odebírat náš [RSS feed][]
přes dočasné Tor spojení. Za jakékoliv nesnáze se omlouváme.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1525,1567,1389,2707,1518,7111,29845" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[mb3e byte order]: https://github.com/bitcoinbook/bitcoinbook/blob/6d1c26e1640ae32b28389d5ae4caf1214c2be7db/ch06_transactions.adoc#internal_and_display_order
[news200 policies]: /cs/newsletters/2022/05/18/#prizpusobeni-miniscriptu-miniscript-a-deskriptoru-descriptors-podpisovym-zarizenim-signingdevices
[news191 multi_a]: /en/newsletters/2022/03/16/#bitcoin-core-24043
[news227 multi_a]: /cs/newsletters/2022/11/23/#jak-mohu-vytvorit-taprootovou-adresu-s-vicenasobnym-podpisem
[news273 multi_a]: /cs/newsletters/2023/10/18/#bitcoin-core-27255
[news274 op_cat]: /cs/newsletters/2023/10/25/#navrh-bipu-pro-op-cat
[news275 op_cat]: /cs/newsletters/2023/11/01/#navrh-na-op-cat
[news293 op_cat]: /cs/newsletters/2024/03/13/#bitcoin-core-pr-review-club
[kim utreexo]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d5f47120-3397-4f56-93ca-dd310d845f3cn@googlegroups.com/T/#u
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[btcd]: https://github.com/btcsuite/btcd
[rubin bip119e]: https://mailing-list.bitcoindevs.xyz/bitcoindev/35cba1cd-eb67-48d1-9615-e36f2e78d051n@googlegroups.com/T/#u
[bip119e]: https://github.com/bitcoin/bips/pull/1587
[news284 eltoo]: /cs/newsletters/2024/01/10/#ctv
[collision attack]: https://cs.wikipedia.org/wiki/%C3%9Atok_nalezen%C3%ADm_kolize
[rss feed]: /feed.xml
[ldk v0.0.123]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.123
[news25 cln check]: /en/newsletters/2018/12/11/#c-lightning-2123
[news47 cln check]: /en/newsletters/2019/05/21/#c-lightning-2631
