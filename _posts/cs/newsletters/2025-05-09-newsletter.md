---
title: 'Zpravodaj „Bitcoin Optech” č. 353'
permalink: /cs/newsletters/2025/05/09/
name: 2025-05-09-newsletter-cs
slug: 2025-05-09-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje nedávno objevenou zranitelnost teoreticky
způsobující selhání konsenzu a odkazuje na navrhovaný způsob bránící
opakovanému používání BIP32 cest v peněženkách. Též nechybí naše pravidelné
rubriky se souhrnem nedávného sezení Bitcoin Core PR Review Clubu, oznámeními
nových vydání a popisem významných změn v populárním bitcoinovém páteřním
software.

## Novinky

- **BIP30 a zranitelnost způsobující selhání konsenzu:** Ruben Somsen zaslal do
  emailové skupiny Bitcoin-Dev [příspěvek][somsen bip30] o teoretickém selhání
  konsenzu, které by mohlo nastat po nedávném odstranění checkpointů z Bitcoin
  Core (viz [zpravodaj č. 346][news346 checkpoints]). Ve stručnosti: mincetvorné
  transakce z bloků 91 722 a 91 812 jsou [opakovaně použité][topic duplicate
  transactions] i v blocích 91 880 a 91 842. [BIP30][] určuje, že tyto dva
  pozdější bloky by měly být zpracovány stejným způsobem jako v roce 2010, tedy
  přepsáním dřívějších záznamů v množině UTXO. Somsen však poznamenává, že
  reorganizace jednoho či obou pozdějších bloků by vyústila v odstranění
  duplikovaných položek z množiny UTXO; tím by v množině nebyla ani jedna ze
  čtyř položek.  Avšak nově spuštěný uzel, který nikdy duplikované transakce
  neviděl, by stále měl dřívější dvě transakce. Tento uzel by tedy měl jinou
  množinu UTXO, což by mohlo vyvolat selhání konsenzu v případě utracení některé
  z těchto transakcí.

  Dokud měl Bitcoin Core checkpointy, nepředstavovalo to problém, neboť
  checkpointy vyžadovaly, aby byly všechny čtyři zmíněné bloky součástí nejlepšího
  řetězce. I dnes se jedná o problém pouze v teoretickém případě, pokud
  by selhal bezpečnostní mechanismus proof-of-work. Bylo diskutováno několik
  možných řešení, mezi nimi například napevno zakódovat zvláštní logiku pro tyto
  dvě výjimky.

- **Jak zabránit opakovanému používání BIP32 cest:** Kevin Loaec započal
  zasláním [příspěvku][loaec bip32reuse] do fóra Delving Bitcoin diskuzi o
  možných způsobech zabraňování opakovaného použití stejných [BIP32][topic bip32]
  cest napříč různými peněženkami, které by mohlo vést ke ztrátě soukromí kvůli
  [vazbám mezi výstupy][topic output linking] a teoreticky i ke ztrátě
  zabezpečení (např. pomocí [kvantových počítačů][topic quantum
  resistance]). Navrhl tři možné přístupy: používání náhodných cest, používání
  cest založených na čase vytvoření peněženky a používání cesty založené na
  inkrementujícím čítači. Doporučil čas vytvoření peněženky.

  Dále též doporučil přestat používat většinu prvků cest dle [BIP48][], neboť
  jsou již kvůli používání [deskriptorových][topic descriptors] peněženek
  nepotřebné, obzvláště u peněženek s vícenásobnými podpisy nebo složitějšími
  skripty.  Salvatore Ingala však [navrhl][ingala bip48] zachovat _typ mince_ z
  BIP48, neboť pomáhá zajistit, aby klíče pro různé kryptoměny zůstaly
  oddělené. Některá hardwarová podpisová zařízení toto oddělení vynucují.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Přidej spustitelnou pomocnou binárku bitcoin][review club 31375] („Add bitcoin
wrapper executable”) je PR od vývojáře [ryanofsky][gh ryanofsky] přinášející nový
spustitelný soubor `bitcoin`, který může být použit pro hledání a spouštění
různých programů v rámci Bitcoin Core.

Bitcoin Core v29 obsahuje sedm binárek (např. `bitcoind`, `bitcoin-qt` a
`bitcoin-cli`), ale jejich počet se [navýší][Bitcoin Core #30983], až se Bitcoin
Core bude dodávat i ve [víceprocesové][multiprocess design] verzi.  Nová binárka
`bitcoin` mapuje příkaz (např. `gui`) na správný monolitický (`bitcoin-qt`) nebo
víceprocesový (`bitcoin-gui`) program. Vedle lepšího přehledu o dostupných
programech poskytne `bitcoin` také kompatibilitu s budoucími verzemi. Programy
tak mohou být reorganizovány, aniž by se muselo změnit uživatelské rozhraní.

S tímto PR může uživatel spustit Bitcoin Core jako `bitcoin daemon` nebo
`bitcoin gui`. Změna nemá žádný dopad na přímé spouštění pomocí `bitcoind` nebo
`bitcoin-qt`.

{% include functions/details-list.md
  q0="Z #30983 byly vyjmenovány čtyři strategie produkce balíčků. Které konkrétní
  slabiny přístupu „s pomocnými binárkami” (side-binaries) toto PR adresuje?"
  a0="Přístup s pomocnými binárkami, který toto PR zaujímá, předpokládá
  vydání nový víceprocesových binárek spolu s existujícími monolitickými
  binárkami. Pro uživatele může být obtížné najít, který z těchto spustitelných
  souborů pro svůj účel potřebují. PR poskytuje jednotný vstupní bod,
  který nabízí seznam možností a nápovědu. Jeden účastník sezení navrhl
  přidání fuzzy hledání."
  a0link="https://bitcoincore.reviews/31375#l-40"

  q1="`GetExePath()` na Linuxu nepoužívá `readlink(\"/proc/self/exe\")`, i když
  by to bylo přímočařejší. Jaké výhody má současná implementace? Které okrajové
  případy mohou zůstat nepokryté?"
  a1="Mohou existovat i jiné newindowsovské platformy, které proc souborový systém
  nemají. Kromě toho nemohli autor ani hosté najít jiné nevýhody používání procfs."
  a1link="https://bitcoincore.reviews/31375#l-71"

  q2="Vysvětlete účel booleovské hodnoty `fallback_os_search` v `ExecCommand`.
  Za jakých okolností je lepší nenechat OS vyhledat binárku v `PATH`?"
  a2="Pokud se zdá, že byl `bitcoin` spuštěn s cestou (např. \"/build/bin/bitcoin\")
  a ne s vyhledáním (tedy jako `bitcoin`), předpokládá se, že uživatel
  chce použít lokální sestavení a `fallback_os_search` je nastaven na
  `false`. Tato booleovská hodnota byla přidána, aby zabránila neúmyslnému
  pomíchání binárek z různých zdrojů. Pokud uživatel na příklad lokálně nesestavil
  `gui`, potom by se `/build/bin/bitcoin gui` nemělo pokusit spustit
  `bitcoin-gui` nainstalovaný v systému. Autor zvažuje zcela odstranit hledání
  v `PATH` a žádá o zpětnou vazbu."
  a2link="https://bitcoincore.reviews/31375#l-75"

  q3="Nově přidaný spustitelný soubor vyhledá `${prefix}/libexec` pouze, pokud detekuje
  spuštění z nainstalovaného adresáře `bin/`. Proč nehledat `libexec` vždy?"
  a3="Měl by být konzervativní ve výběru cest pro spuštění a upřednostňovat
  standardní `PREFIX/{bin,libexec}`. Neměl by vybízet k vytváření balíčků s
  nestandardními cestami a neměl by fungovat, pokud jsou binárky
  rozmístěny neočekávaně."
  a3link="https://bitcoincore.reviews/31375#l-75"

  q4="PR přidává do `security-check.py` výjimku, protože spustitelný soubor
  neobsahuje žádné zabezpečené volání `glibc`. Proč ne? Znamená to, že by
  přidání triviálního `printf` do `bitcoin.cpp` rozbilo reprodukovatelná sestavení?"
  a4="Nová binárka je tak jednoduchá, že neobsahuje žádná volání, která
  by mohla být zabezpečena (fortified). Pokud by v budoucnosti taková
  volání byla potřebná, výjimka by se mohla odstranit."
  a4link="https://bitcoincore.reviews/31375#l-117"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.19.0-beta.rc4][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Core Lightning #8227][] přidává rustové pluginy `lsps-client` a `lsps-service`,
  které implementují komunikační protokol mezi LSP uzly a jejich klienty.
  Protokol používá JSON-RPC a [BOLT8][] peer-to-peer zprávy dle specifikace v
  [BLIP50][] (viz [zpravodaj č. 335][news335 blip50]). Jedná se o základ
  pro implementaci příchozích žádostí o likviditu dle [BLIP51][] a
  [JIT kanálů][topic jit channels] dle [BLIP52][].

- [Core Lightning #8162][] bude nově trvale držet až sto probíhajících procesů
  otevírání kanálů vyžádaných protistranou. Dříve byla nepotvrzená
  otevření kanálů po 2 016 blocích zapomenuta. Dále jsou zavřené kanály
  nově držené v paměti, aby mohl uzel reagovat na zprávu `channel_reestablish`.

- [Core Lightning #8166][] nahrazuje v odpovědi RPC příkazu `wait` jediný
  objekt `details` objektem dle dotčeného podsystému: `invoices`, `forwards`,
  `sendpays` a [`htlcs`][topic htlc]. Dále přidává stránkování do `listhtlcs`
  (pole `created_index`, `updated_index` a parametry `index`, `start`, `end`).

- [Core Lightning #8237][] přidává do RPC příkazu `listpeerchannels` volitelný
  parametr `short_channel_id`, který vrátí pouze konkrétní kanál.

- [LDK #3700][] přidává do události `HTLCHandlingFailed` nové pole `failure_reason`
  s dodatečnými informacemi o důvodech a původu selhání [HTLC][topic htlc].
  Pole `failed_next_destination` je přejmenováno na `failure_type` a varianta
  `UnknownNextHop` je nahrazena obecnější `InvalidForward`.

- [Rust Bitcoin #4387][] refaktoruje chyby v implementaci [BIP32][topic bip32].
  Jediný typ `bip32::Error` nahrazuje výčtovými typy vyhrazenými pro derivaci, parsování
  cest a parsování rozšířených klíčů. Dále přináší variantu `DerivationError::MaximumDepthExceeded`
  pro cesty mající více než 256 úrovní. Změny nejsou zpětně kompatibilní.

- [BIPs #1835][] rezervuje v [BIP48][] (viz [zpravodaj č. 135][news135 bip48], _angl._)
  typ skriptu 3' pro [taproot][topic taproot] (P2TR) v deterministických
  multisig peněženkách s prefixem m/48'. Existující hodnoty jsou 1' pro
  P2SH-P2WSH a 2' pro P2WSH.

- [BIPs #1800][] začleňuje [BIP54][], který specifikuje návrh na [soft fork
  pročištění konsenzu][topic consensus cleanup] opravující několik dlouhodobých
  zranitelností v bitcoinovém protokolu. [Zpravodaj č. 348][news348 cleanup]
  popisuje tento BIP podrobněji.

- [BOLTs #1245][] znemožňuje používat v [BOLT11][] fakturách kódování nemající minimální
  délku: expirační lhůta (`x`), [CLTV expiry delta][topic cltv expiry delta] posledního
  skoku (`c`) a bity s popisem podporovaných funkcí (`9`) musí být nově serializované
  s minimální délkou bez úvodních nul. Příjemci by měli faktury s úvodními nulami
  odmítnout. Změna byla motivována fuzz testováním, které zjistilo, že když LDK
  serializuje neminimální faktury na minimální (odstraní nadbytečné nuly), způsobuje
  to selhání validace ECDSA podpisů.

{% include snippets/recap-ad.md when="2025-05-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8227,8162,8166,8237,3700,4387,1835,1800,1245,50,51,52,30983" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[somsen bip30]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjZTWhgzzdps3vb0YoU3EYJwThDFhNLkf4XmmdfhbORTaw@mail.gmail.com/
[loaec bip32reuse]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644
[ingala bip48]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644/3
[news346 checkpoints]: /cs/newsletters/2025/03/21/#bitcoin-core-31649
[news335 blip50]: /cs/newsletters/2025/01/03/#blips-52
[news135 bip48]: /en/newsletters/2021/07/28/#bips-1072
[news348 cleanup]: /cs/newsletters/2025/04/04/#zverejnen-navrh-bipu-na-procisteni-konsenzu
[review club 31375]: https://bitcoincore.reviews/31375
[gh ryanofsky]: https://github.com/ryanofsky
[multiprocess design]: https://github.com/bitcoin/bitcoin/blob/master/doc/design/multiprocess.md
