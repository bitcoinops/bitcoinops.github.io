---
title: 'Zpravodaj „Bitcoin Optech” č. 255'
permalink: /cs/newsletters/2023/06/14/
name: 2023-06-14-newsletter-cs
slug: 2023-06-14-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze o umožnění přeposílání transakcí
obsahující data v taprootové příloze a odkazujeme na návrh BIP na
tiché platby. Též nechybí další příspěvek v naší krátké týdenní sérii
o pravidlech mempoolu a pravidelné rubriky se souhrnem sezení Bitcoin
Core PR Review Clubu, oznámeními o nových vydáních a popisem významných
změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Diskuze o taprootových přílohách:** Joost Jager zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][jager annex] s žádostí o změnu v
  pravidlech přeposílání transakcí a těžby v Bitcoin Core, aby umožnily
  ukládání libovolných dat v rámci přílohy („annex”) v [taprootu][topic
  taproot]. Toto pole je volitelnou součástí dat witnessu taprootových
  transakcí. Je-li přítomno, musí se podpisy v taprootu a [tapscriptu][topic
  tapscript] týkat i jeho dat (aby je nemohla třetí strana změnit,
  přidat nebo odebrat), ale v současnosti nemá definovaný žádný další
  význam. Je rezervováno pro budoucí upgrady protokolu, obzvláště
  soft forky.

  I když se v minulosti objevily [návrhy][riard annex] na definování
  formátu přílohy, nedočkaly se obecného přijetí ani implementace. Jager
  navrhuje dva formáty ([1][jager annex], [2][jager annex2]), které
  by mohly být použity k přidání libovolných dat způsobem, jež by
  výrazně nekomplikoval pozdější pokusy o standardizaci svázanou
  s případným soft forkem.

  Greg Sanders se v [odpovědi][sanders annex] tázal, jaká data by chtěl
  Jager konkrétně v příloze ukládat, a popsal své vlastní využívání
  přílohy v rámci testování protokolu [LN-Symmetry][topic eltoo]
  s návrhem soft forku [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
  pomocí Bitcoin Inquisition (viz [zpravodaj č. 244][news244 annex]).
  Sanders také popsal problém s přílohami: v protokolech s více stranami
  (jako je [coinjoin][topic coinjoin]) zavazuje každý podpis k příloze
  vstupu obsahující tento podpis a ne k přílohám ostatních vstupů ve stejné
  transakci. To znamená, že pokud by Alice, Bob a Mallory spolu podepsali
  coinjoin, nemohou Alice ani Bob zabránit Mallorymu ve zveřejnění verze
  transakce s větší přílohou, která by zpozdila konfirmaci. Jelikož Bitcoin
  Core a ostatní implementace plných uzlů v současnosti nepřeposílají
  transakce obsahující přílohy, nepředstavuje to zatím žádný problém.
  Jager [odpověděl][jager annex4], že chce ukládat podpisy dočasných
  klíčů pro druh [úschoven][topic vaults], který nevyžaduje soft fork,
  a [navrhl][jager annex3], že tento problém s přeposíláním příloh
  v některých protokolech s více stranami by mohl řešit [předchozí pokus][bitcoin
  core #24007] v Bitcoin Core.

- **Návrh BIP na tiché platby:** Josie Baker a Ruben Somsen [zaslali][bs sp]
  do emailové skupiny Bitcoin-Dev návrh BIP na [tiché platby][topic silent
  payments] („silent payments”), druh znovupoužitelného platebního kódu,
  který při každém použití vygeneruje jedinečnou onchain adresu zabraňující
  [linkování výstupů][topic output linking]. Linkování výstupů může výrazně
  snížit soukromí uživatelů (včetně uživatelů, kteří se transakce přímo
  neúčastní). Návrh obsahuje podrobnosti o svých výhodách, kompromisech
  a možnostech využití. Pod [PR][bips #1458] se již objevilo několik
  podnětných komentářů.

## Čekání na potvrzení 5: pravidla pro ochranu zdrojů uzlů

_Krátká týdenní [série][policy series] o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/05-dos.md %}

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Umožni příchozím whitebind spojením agresivněji vyhazovat spojení
během plných slotů][review club 27600] je PR od Matthew Zipkina (pinheadmz),
které zlepšuje možnosti provozovatele uzlu v určitých případech nastavit
žádoucí spojení uzlu. Konkrétně pokud operátor explicitně povolí potenciální
příchozí spojení (například lehkého klienta pod jeho kontrolou), mohlo by se
bez tohoto PR stát, že by mu byl v určitém stavu odepřen pokus o připojení.

Toto PR zvyšuje pravděpodobnost, že by bylo toto žádoucí spojení úspěšně navázáno.
Činí tak tím, že by vyhodilo jiné příchozí spojení, které bylo před PR nevyhoditelné.

{% include functions/details-list.md
  q0="Proč se toto PR týká pouze žádostí o příchozí připojení?"
  a0="Náš uzel _iniciuje_ odchozí spojení; toto PR mění způsob, kterým
      uzel _reaguje_ na žádost o příchozí spojení. Odchozí uzly mohou
      být též vyhozeny, ale to má na starosti zcela odlišný algoritmus."
  a0link="https://bitcoincore.reviews/27600#l-33"

  q1="Jaký dopad na návratovou hodnotu funkce  `SelectNodeToEvict()` má
      parametr `force`?"
  a1="Nastavení `force` na `true` zajišťuje, že je vráceno příchozí spojení
      bez `noban`, pokud existuje, i když by bylo jinak před vyhozením chráněno.
      Bez tohoto PR by funkce nevrátila nic, pokud jsou všechna spojení před
      vyhozením chráněna."
  a1link="https://bitcoincore.reviews/27600#l-70"

  q2="Jak se tímto PR mění signatura funkce `EraseLastKElements()`?"
  a2="Místo `void` vrací funkce poslední položku, která byla ze seznamu
      kandidátů pro vyhození _odstraněna_. (Tento „chráněný” uzel
      může být v případě potřeby vyhozen.) Avšak v důsledku diskuze
      pod sezením review clubu bylo toto PR později zjednodušeno a tato
      funkce zůstala nakonec nezměněna."
  a2link="https://bitcoincore.reviews/27600#l-126"

  q3="`EraseLastKElements` bývalo template funkcí, toto PR však odstraňuje dva
      template argumenty. Proč? Jaké jsou zápory této změny?"
  a3="Tato funkce byla a (tímto PR) je volána s jedinečnými template argumenty,
      není tedy potřeba, aby zůstala template. Nakonec byly změny této funkce
      revertovány, neboť byly mimo rámec PR."
  a3link="https://bitcoincore.reviews/27600#l-126"

  q4="Předpokládejme, že předáme funkci `SelectNodeToEvict()` seznam 40 kandidátů
      na vyhození. Jaký je před a po PR teoretický maximální počet Tor uzlů, které
      mohou být chráněny před vyhozením?"
  a4="Před i po PR je počet 34 ze 40 za předpokladu, že nejsou příchozí a nemají
      `noban`."
  a4link="https://bitcoincore.reviews/27600#l-156"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.05.1][] je údržbovým vydáním této implementace LN.
  Poznámky k vydání udávají: „vydání obsahuje pouze opravy chyb způsobující
  několik pádů. Doporučuje se upgrade z v23.05.”

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27501][] přidává RPC volání `getprioritisedtransactions`,
  které vrací mapu všech fee delta vytvořených uživateli pomocí
  `prioritisetransaction` s txid jako klíči. Mapa též ukazuje, jsou-li
  transakce v mempoolu. Viz též [zpravodaj č. 250][news250 getprioritisedtransactions].

- [Core Lightning #6243][] mění RPC volání `listconfigs`. Nově budou všechny
  konfigurační informace obsaženy v jediném slovníku. Dále bude stav všech
  konfiguračních voleb předávat restartovaným pluginům.

- [Eclair #2677][] navyšuje výchozí `max_cltv` z 1 008 bloků (zhruba jeden
  týden) na 2 016 bloků (zhruba dva týdny). Rozšiřuje tím maximální povolený
  počet bloků před tím, než platba expiruje. Změna byla motivována uzly
  rozšiřujícími svá rezervovaná časová okna, aby řešily HTLC expirující
  (`cltv_expiry_delta`) kvůli vysokým onchain poplatkům. Podobné
  změny byly začleněny do [LND][lnd max_cltv] i CLN.

- [Rust bitcoin #1890][] přidává metodu pro spočítání operací s podpisy (sigops)
  v netapscriptových skriptech. Počet sigops v bloku je omezen a kód výběru
  transakcí během těžby v Bitcoin Core zachází s transakcemi s vysokým poměrem
  sigops a velikosti (váhy), jakoby byly větší, čímž v důsledku snižuje jejich
  jednotkový poplatek. Tato metoda může být důležitá pro všechny, kdo
  vytváří nové transakce.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27501,6243,2677,1890,1458,24007" %}
[policy series]: /cs/blog/waiting-for-confirmation/
[jager annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021731.html
[riard annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020991.html
[jager annex2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021756.html
[sanders annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021736.html
[news244 annex]: /cs/newsletters/2023/03/29/#bitcoin-inquisition-22
[jager annex3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021743.html
[bs sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021750.html
[review club 27600]: https://bitcoincore.reviews/27600
[jager annex4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021737.html
[lnd max_cltv]: /en/newsletters/2019/10/23/#lnd-3595
[news250 getprioritisedtransactions]: /cs/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[Core Lightning 23.05.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.1
