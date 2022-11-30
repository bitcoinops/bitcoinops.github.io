---
title: 'Zpravodaj „Bitcoin Optech” č. 228'
permalink: /cs/newsletters/2022/11/30/
name: 2022-11-30-newsletter-cs
slug: 2022-11-30-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
V tomto čísle našeho zpravodaje popisujeme návrh k zamezení útoku
zahlcením kanálu v Lightning Network pomocí osvědčení o reputaci. Dále
přinášíme naše pravidelné rubriky s oznámeními o nových vydáních a významných
změnách oblíbeného bitcoinového páteřního software.

## Novinky

- **Návrh na použití osvědčení o reputaci k zamezení zahlcování LN:**
  Antoine Riard [poslal][riard credentials] do emailové skupiny Lightning-Dev
  [návrh][riard proposal] na systém osvědčení o reputaci jako prostředku
  k předcházení tzv. [útoků zahlcením kanálu][topic channel jamming attacks]
  („channel jamming attacks”). Tento typ útoku způsobuje dočasné zablokování
  platebních slotů ([HTLC][topic htlc]), a znemožňuje tak poctivým uživatelům
  posílat platby.

  V rámci Lightning Network volí odesílatel trasu ze svého uzlu do
  uzlu příjemce za použití několika kanálů provozovaných nezávislými
  prostředníky. Odesílatel generuje sadu instrukcí, které popisují,
  kam má každý prostředník platbu dále přeposlat. Tyto instrukce jsou
  zašifrovány tak, aby se každý z prostředníků dozvěděl pouze informace
  nezbytně nutné k provedení úkolu.

  Riard navrhuje, aby každý prostředník akceptoval pouze takové žádosti
  o přeposlání, které obsahují osvědčení vydané tímto prostředníkem. Tato
  osvědčení sestávají ze [zaslepených elektronických podpisů][blind signature],
  které nedovolují prostředníkům napřímo určit jejich držitele. Identita
  odesílatele tak zůstane před prostředníky utajena. Každý uzel si může stanovit
  svá pravidla vydávání osvědčení, Riard však navrhuje několik způsobů
  jejich distribuce:

    - *Předplatné:* chce-li Alice poslat platbu přes Bobův uzel, může nejdřív
	  od Boba zakoupit osvědčení (přes LN).

    - *Předchozí úspěšná platba:* Bobův uzel může Alici poslat osvědčení
	  (jedno nebo více) za úspěšně provedenou platbu. Díky těmto osvědčením
	  může Alice opět v budoucnu poslat platby přes Bobův uzel.

    - *Důkazy vlastnictví UTXO:* někteří prostředníci mohou experimentovat
	  s vydáváním osvědčení každému, kdo předloží důkaz o vlastnictví bitcoinového
	  UTXO. Lze například udělit více osvědčení za starší nebo hodnotnější
	  UTXO. Jelikož si každý prostředník sám zvolí pravidla
	  udělování osvědčení, mohou být použita i jakákoliv jiná kritéria.

  Clara Shikhelman, která je spoluautorkou podobného návrhu částečně založeného
  na lokální reputaci popsaného ve [zpravodaji č. 226][news226 jam] (*angl.*),
  [se dotázala][shikelman credentials], zda by tato osvědčení byla přenositelná
  mezi uživateli a zda by to mohlo vést k vytvoření trhu s osvědčeními. Též se
  ptala, jak by Riardův návrh fungoval se [zaslepenými trasami][topic rv routing],
  kde odesílatel nezná kompletní trasu k příjemci.

  Riard [odpověděl][riard double spend], že by bylo složité redistribuovat
  osvědčení a vytvořit pro ně trh, neboť by každý přenos vyžadoval důvěru.
  Napříkad chtěla-li by Alice prodat Carol osvědčení vydané Bobovým uzlem,
  neexistuje žádný způsob, kterým by Alice mohla dokázat Carol, že se nebude
  po prodeji snažit osvědčení sama používat.

  Co se týče zaslepených tras, [jeví se][harding paths], že by příjemce mohl
  poskytnout veškerá potřebná osvědčení v zašifrované podobě.

  V příslušném [pull requestu][bolts #1043] obdržel tento návrh další zpětnou vazbu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.15.5-beta.rc2][] je kandidátem na údržbové vydání LND. Podle plánovaných poznámek
  vydání obsahuje pouze opravy drobných chyb.

- [Core Lightning 22.11rc3][] je kandidátem na vydání příští hlavní verze CLN. Tímto vydáním
  přejde CLN na nový model číslování verzí, avšak nadále bude používat [sémantické verzování][semantic
  versioning].

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Core Lightning #5727][] začíná v JSON prosazovat textové identifikátory
  namísto zastaralých číselných. Do [dokumentace][cln json ids] byly přidány
  informace o výhodách textových identifikátorů a o jejich správném vytváření
  a interpretování.

- [Eclair #2499][] umožňuje v žádostech o platbu v rámci [BOLT12 nabídek][topic offers]
  nastavit zaslepenou trasu („blinded route”). Ta spočívá v přidání dodatečných uzlů za
  adresátův uzel, které však nebudou použity. Jejich účelem je ztížení odesílateli
  určit, jak daleko je adresát od posledního nezaslepeného uzlu v trase.

- [LND #7122][] přidává do `lncli` podporu pro zpracování binárních [PSBT][topic
  psbt] souborů. [BIP174][] určuje, že PSBT, neboli *částečně podepsané transakce*,
  mohou být zakódovány buď jako binární soubor nebo pomocí Base64 jako text.
  LND již dříve umožňovalo import PSBT zakódovaných pomocí Base64 ze souboru
  nebo přímo z textu.

- [LDK #1852][] akceptuje navýšení jednotkového poplatku („feerate”) navržené
  jedním z účastníků kanálu, i když není tento poplatek dostatečně vysoký, aby
  v dané chvíli bezpečně udržel kanál otevřený. I když nový jednotkový poplatek
  není zcela bezpečný, jeho vyšší hodnota v porovnání s předchozí hodnotou
  znamená, že je bezpečnější oproti stávající situaci. Je tedy lepší jej akceptovat,
  než pokoušet se zavřít kanál s jeho stávajícím (nižším) jednotkovým poplatkem. Budoucí
  změny LDK mohou zavírat i kanály, které mají poplatky příliš nízké. Navíc díky práci na
  návrzích jako je [přeposílání balíčků][topic package relay] (viz též překlad zpravodaje
  [č. 201][news201 package relay] a [č. 204][news204 package relay]) mohou být
  [anchor výstupy][topic anchor outputs] a podobné techniky dostatečně flexibilní,
  aby zcela odstranily obavy o výši poplatků.

- [Libsecp256k1 #993][] přidává do výchozího nastavení sestavení moduly pro práci s
  extrakeys (funkce pro práci s x-only veřejnými klíči), [ECDH][] a [Schnorrovými
  podpisy][topic schnorr signatures]. Modul pro rekonstrukci veřejného
  klíče z elektronického podpisu není nadále součástí výchozího nastavení,
  „neboť nedoporučujeme, aby nově vznikající protokoly obsahovaly ECDSA obnovu
  kvůli náchylnosti API ke zneužití. Ponouká totiž volajícího, aby přeskočil
  kontrolu veřejného klíče a automaticky jej pokládal za platný.”

{% include references.md %}
{% include linkers/issues.md v=2 issues="5727,2499,7122,1852,993,1043" %}
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc3
[cln json ids]: https://github.com/rustyrussell/lightning/blob/a25c5d14fe986b67178988e6ebb79610672cc829/doc/lightningd-rpc.7.md#json-ids
[riard credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003754.html
[riard proposal]: https://github.com/lightning/bolts/blob/80214c83190836c4f7699af9e8920769607f1a00/www-reputation-credentials-protocol.md
[blind signature]: https://en.wikipedia.org/wiki/Blind_signature
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[shikelman credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003755.html
[riard double spend]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003765.html
[harding paths]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003767.html
[ecdh]: https://cs.wikipedia.org/wiki/Diffieho%E2%80%93Hellman%C5%AFv_protokol_s_vyu%C5%BEit%C3%ADm_eliptick%C3%BDch_k%C5%99ivek
[semantic versioning]: https://semver.org/lang/cs/spec/v2.0.0.html
[news201 package relay]: /cs/newsletters/2022/05/25/#navrh-na-preposilani-balicku
[news204 package relay]: /cs/newsletters/2022/06/15/#pokracuje-debata-o-preposilani-balicku
