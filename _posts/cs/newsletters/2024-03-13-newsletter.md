---
title: 'Zpravodaj „Bitcoin Optech” č. 293'
permalink: /cs/newsletters/2024/03/13/
name: 2024-03-13-newsletter-cs
slug: 2024-03-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje příspěvek o onchain sázení o případném
soft forku bez požadavku na důvěru a odkazuje na podrobný přehled Chia Lispu
pro bitcoinery. Též nechybí naše pravidelné rubriky se souhrnem sezení
Bitcoin Core PR Review Clubu, oznámeními o nových vydáních a popisem významných
změně v populárním bitcoinovém páteřním software.

## Novinky

- **Onchain sázky na případné soft forky bez požadavku na důvěru:** ZmnSCPxj
  zaslal do fóra Delving Bitcoin [příspěvek][zmnscpxj bet] s popisem
  protokolu předávajícího kontrolu nad UTXO straně, která správně předpoví
  aktivaci nějakého konkrétního soft forku. Pro příklad uvažujme, že Alice věří v aktivaci
  konkrétního soft forku a chtěla by získat nějaké bitcoiny. Bob má stejný
  zájem, avšak domnívá se, že soft fork aktivován nebude. Kooperativně shromáždí
  určité množství bitcoinů v předem domluveném poměru (např. 1:1). Pokud by
  soft fork byl aktivován před určitým časovým limitem, Alice by obdržela kombinovanou
  částku. V opačném případě by připadla Bobovi. Pokud by před vypršením časového
  limitu došlo k trvalému štěpení blockchainu (jeden by fork aktivoval, druhý
  zakazoval), obdržela by Alice kombinovanou částku v aktivovaném blockchainu
  a Bob v blockchainu zakazujícím aktivaci.

  Základní myšlenka byla již dříve navržena ([příklad][rubin bet]), avšak
  ZmnSCPxjova verze se umí vypořádat se specifiky očekávanými v minimálně
  jednom případném budoucím soft forku: [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify]. ZmnSCPxj též krátce uvažuje o potížích
  generalizace této myšlenky na jiné navrhované soft forky, obzvláště ty,
  které mění definici opkódu `OP_SUCCESSx`.

- **Chia Lisp pro bitcoinery:** Anthony Towns zaslal do fóra Delving
  Bitcoin [příspěvek][towns lisp] s podrobným přehledem varianty [Lispu][Lisp]
  používané kryptoměnou Chia. Towns již dříve navrhl přidat soft forkem
  do bitcoinu skriptovací jazyk založený na Lispu (viz [zpravodaj č. 191][news191 lisp],
  _angl._). Lidem se zájmem o toto téma doporučujeme si jeho příspěvek
  přečíst.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Opět aktivuj `OP_CAT`][review club bitcoin-inquisition 39] je PR od Armina
Sabouriho (0xBEEFCAF3 na GitHubu), které vrací opkód [OP_CAT][topic op_cat],
avšak pouze na [signetový][topic signet] [Bitcoin Inquisition][bitcoin inquisition
repo] a pro [tapscript][topic tapscript] (taproot script). Satoshi Nakamoto
tento opkód v roce 2010 pravděpodobně z přílišné opatrnosti deaktivoval.
Operace nahrazuje první dva prvky v zásobníku jejich spojením
(„con<ins>**cat**</ins>enation”).

Motivace pro `OP_CAT` diskutovány nebyly.

{% include functions/details-list.md
  q0="Za jakých podmínek může provedení `OP_CAT` vyústit v chybu?"
  a0="Méně než dva prvky v zásobníku, přílišná velikost výsledného
	  prvku, zakázání nastavovacími příznaky (protože například ještě
	  nebyl aktivován soft fork) a pokud se objevuje v netaprootovém
	  skriptu (witness verze 0 nebo zastaralé typy)."
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-46"

  q1="`OP_CAT` mění definici jednoho z `OP_SUCCESSx` opkódů.
	  Proč však nemění definici jednoho z `OP_NOPx` opkódů (které též
	  byly v minulosti používané na soft forky)?"
  a1="Opkódy `OP_SUCCESSx` a `OP_NOPx` mohou být předefinovány za účelem
	  implementace soft forku, protože zpřísňují pravidla validace
	  (volání jsou vždy úspěšná, zatímco po redefinici mohou selhat).
	  Jelikož vykonávání skriptu pokračuje i po `OP_NOP`, nesmí
	  předefinované `OP_NOP` opkódy ovlivňovat zásobník (jelikož
	  by skripty, které dříve selhávaly, mohly končit úspěšně, což
	  by pravidla zmírňovalo). Předefinované opkódy `OP_SUCCESS` mohou
	  zásobník ovlivňovat, jelikož `OP_SUCCESS` vykonávání skriptu
	  okamžitě úspěšně ukončuje. Jelikož `OP_CAT` zásobník mění,
	  nemůže redefinovat `OP_NOP` opkód."
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-33"

  q2="Toto PR přidává `SCRIPT_VERIFY_OP_CAT` i `SCRIPT_VERIFY_DISCOURAGE_OP_CAT`.
	  Proč jsou obě volby potřebné?"
  a2="Umožňují, aby byl soft fork nasazen po částech. Nejprve jsou obě nastavené
	  na `true` (aktivace na úrovni konsenzu, ale žádné přeposílání ani těžba),
	  dokud neupgraduje většina sítě. Poté je `SCRIPT_VERIFY_DISCOURAGE_OP_CAT`
	  nastaven na `false`, aby umožnil používání. Pokud by experiment v Bitcoin
	  Inquisition selhal, může být proces vrácen stejnými kroky v opačném směru.
	  Pokud by byly obě volby nastavené na `false`, byl by `OP_CAT` jen
	  pouhým opkódem `OP_SUCCESS`."
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-60"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning v24.02.1][] je menší aktualizací tohoto LN uzlu přinášející
  „opravy několika drobných chyb a vylepšení nákladové funkce algoritmu
  routování.“

- [Bitcoin Core 26.1rc1][] je kandidátem na vydání údržbové verze této převládající
  implementace plného uzlu.

- [Bitcoin Core 27.0rc1][] je kandidátem na vydání příští hlavní verze této převládající
  implementace plného uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [LND #8136][] přidává do RPC volání `EstimateRouteFee` fakturu a časový limit.
  Když je vybrána trasa pro platbu faktury, zašle se po ní [sonda][topic payment
  probes]. Pokud sonda ukončí činnost před vypršením časového limitu,
  jsou vráceny náklady na vybranou trasu. V opačném případě bude vyvolána
  chyba.

- [LND #8499][] přináší významné změny typů založených na TLV (Type-Length-Value)
  používaných pro [jednoduché taprootové kanály][topic simple taproot
  channels]. Účelem je zlepšení souvisejícího API. Nejsme si vědomi žádné jiné
  implementace, která by v současnosti nabízela jednoduché taprootové kanály,
  ale pokud je někdo používá, vězte, že se může jednat o zpětně nekompatibilní
  změnu.

- [LDK #2916][] přidává jednoduché API pro převod předobrazu platby
  do jejího hashe. LN faktura obsahuje hash platby a aby bylo možné
  platbu nárokovat, musí konečný příjemce odhalit předobraz, který tomuto
  hashi odpovídá. Každý uzel po trase obdrží tento předobraz od uzlu
  po směru toku platby a může s jeho pomocí nárokovat platbu od uzlu
  proti směru toku platby. Jelikož lze hash z předobrazu odvodit (nikoliv
  však naopak), příjemci a přeposílající uzly potřebují ukládat pouze
  předobraz. Díky tomuto API mohou kdykoliv dle potřeby hash odvodit.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8136,8499,2916" %}
[zmnscpxj bet]: https://delvingbitcoin.org/t/economic-majority-signaling-for-op-ctv-activation/635
[rubin bet]: https://blog.bitmex.com/taproot-you-betcha/
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[towns lisp]: https://delvingbitcoin.org/t/chia-lisp-for-bitcoiners/636
[lisp]: https://cs.wikipedia.org/wiki/Lisp
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[Core Lightning v24.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.1
[review club bitcoin-inquisition 39]: https://bitcoincore.reviews/bitcoin-inquisition-39
