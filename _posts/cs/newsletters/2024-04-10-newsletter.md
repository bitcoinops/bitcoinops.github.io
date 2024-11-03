---
title: 'Zpravodaj „Bitcoin Optech” č. 297'
permalink: /cs/newsletters/2024/04/10/
name: 2024-04-10-newsletter-cs
slug: 2024-04-10-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje nový doménově specifický jazyk pro
experimenty s kontrakty, shrnuje diskuzi o úpravě zodpovědností
editorů BIPů a popisuje návrh na restart a změny testnetu. Též nechybí
naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review Clubu,
oznámeními nových vydání a popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **DSL pro experimenty s kontrakty:** Kulpreet Singh zaslal do
  fóra Delving Bitcoin [příspěvek][singh dsl], ve kterém popisuje
  doménově specifický jazyk (DSL) pro bitcoin, který vyvíjí. Jazyk
  umožňuje popsat operace, které by měl protokol kontraktu vykonávat.
  Díky němu bude možné rychle spouštět kontrakt v testovacím prostředí,
  aby se zajistilo, že se chová dle očekávání. Výsledkem bude možnost
  rychleji vyvíjet nové protokoly a poskytnout základ, oproti kterému
  může být později vyvíjen plnohodnotný software.

  Robin Linus ve své [odpovědi][linus dsl] odkázal na podobný projekt
  používající vysoko-úrovňový jazyk k popisu protokolu, který lze
  přeložit na nízkoúrovňový kód a nezbytné operace. Těmi je potom možné
  protokol vykonat. Tento projekt je součástí práce na [BitVM][topic acc].

- **Aktualizace BIP2:** Tim Ruffing zaslal do emailové skupiny Bitcoin-Dev
  [příspěvek][ruffing bip2] o aktualizaci [BIP2][], který stanovuje současný
  proces přidávání nových BIPů a údržbu stávajících. Ruffing i další zmínili
  několik problémů, kterými současný proces trpí, například:

	- *Redakční zásahy a osobní postoje:* kolik úsilí by měli editoři
	  u nových BIPů vynakládat, aby zajistili jejich vysokou kvalitu a zaměření
	  na bitcoin? A jakou roli by měli hrát jejich osobní postoje při
	  odmítání nových BIPů? Ruffing spolu s několika dalšími diskutujícími
	  zmínili, že by preferovali minimalizaci redakčních požadavků a privilegií.
	  Ideálně by editoři měli za úkol pouze bránit zneužívání (např. spamu).
	  Samozřejmě by mohli editoři BIPů stejně jako ostatní členové komunity
	  dobrovolně navrhovat vylepšení návrhů, které jsou dle nich zajímavé.

	- *Licence:* některé povolené licence BIPů jsou navržené pro software a
	  nemusí pro dokumentaci dávat smysl.

	- *Komentáře:* jednou změnou mezi [BIP1][] a BIP2 byl pokus poskytnout
	  u každého BIPu prostor pro zpětnou vazbu komunity. Této možnosti nebylo
	  často využíváno a výsledky byly kontroverzní.

  V době psaní zpravodaje byla myšlenka na aktualizace BIP2 stála diskutována.

  Jiná, avšak související diskuze, kterou jsme zmínili [v minulém čísle][news296 editors],
  se zabývala volbou nových editorů BIPů. Termín nominací a obhajoby byl [rozšířen][erhardt
  editors] do konce pátku 19. dubna. Noví editoři by měli obdržet přístup
  do repozitáře do konce následujícího pondělí.

- **Diskuze o restartu a úpravě testnetu:** Jameson Lopp zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][lopp testnet] s popisem problémů se současnou
  veřejnou bitcoinovou testovací sítí (testnet3). Dále navrhl její restart,
  případně s upravenými pravidly konsenzu pro okrajové případy.

  Předchozí verze testnetu byly restartovány, když někdo začal přisuzovat
  testovacím mincím ekonomickou hodnotu. Kvůli tomu se mince staly hůře
  dostupné lidem, kteří chtěli provádět skutečné testování. Lopp poskytl
  důkazy, že se tak znovu děje. Dále popsal známý problém se zneužíváním
  testnetového algoritmu výpočtu obtížnosti (difficulty), kvůli kterému dochází
  k záplavě bloků. Několik účastníků diskutovalo případné změny, které
  by adresovaly tyto i jiné problémy testnetu. Přinejmenším jeden
  diskutující [by preferoval][kim testnet], aby popsané problémy nadále
  pokračovaly, neboť umožňují zajímavé testování.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Přidej do interpretru Scriptu opkódy pro 64bitovou aritmetiku][review
club 29221] je PR od Chrise Stewarta (Christewart na GitHubu), které přináší
nové opkódy umožňující v Bitcoin Scriptu provádět aritmetické operace na větších
(64bitových) operandech, než kolik je umožněno nyní (32 bitů).

Tato změna by v kombinaci s nějakým jiným existujícím návrhem na soft fork
(např. [OP_TLUV][ml OP_TLUV] přinášející introspekci transakcí) umožnila
používat skriptovací logiku založenou na výstupních částkách uvedených
v satoshi, které mohou snadno v 32bitových celočíselných datových typech přetéct.

Diskuze o přístupu, např. zda-li změnit existující opkódy či vytvořit nové
(např. `OP_ADD64`), nadále probíhá.

Více informací lze nalézt v rozpracovaném [BIPu][bip 64bit arithmetic]
a ve [vlákně][delving 64bit arithmetic] fóra Delving Bitcoin.

{% include functions/details-list.md

  q0="Jakou roli má parametr `nMaxNumSize` v `CScriptNum`?"
  a0="Představuje maximální velikost v bajtech, kterou může mít právě vykonávaný
  prvek (typu `CScriptNum`) zásobníku. Ve výchozím stavu je nastavena
  na čtyři bajty."
  a0link="https://bitcoincore.reviews/29221#l-34"

  q1="Které dva opkódy akceptují pětibajtové číselné vstupy?"
  a1="`OP_CHECKSEQUENCEVERIFY` a `OP_CHECKLOCKTIMEVERIFY` používají pro
  reprezentaci časového razítka celá čísla se znaménkem. Pokud by byly použity
  čtyři bajty, byl by rozsah možných dat omezen rokem 2038. Z tohoto
  důvodu byla těmto dvěma opkódům učiněna výjimka, aby mohly používat
  pět bajtů. Vše je řádně [dokumentováno][docs 5byte carveout] v kódu."
  a1link="https://bitcoincore.reviews/29221#l-45"

  q2="Proč byl do `CScriptNum` přidán příznak `fRequireMinimal`?"
  a2="`CScriptNum` je kódován s proměnlivou délkou. Jak je popsáno v
  [BIP62][] (pravidlo 4), způsobuje toto kódování poddajnost (malleability).
  Například nula může být kódována jako `OP_0`, `0x00`, `0x0000`, apod.
  [Bitcoin Core #5065][] opravil tento problém u standardních transakcí
  tím, že stanovil [minimální požadavky][doc SCRIPT_VERIFY_MINIMALDATA] na reprezentaci
  dat a čísel přidávaných do zásobníku."
  a2link="https://bitcoincore.reviews/29221#l-57"

  q3="Je implementace v tomto PR odolná vůči poddajnosti? Proč?"
  a3="Současná implementace vyžaduje přesně osmibajtovou reprezentaci
  operandů 64bitových opkódů, díky čemuž je odolná vůči poddajnosti. Tento
  přístup je zdůvodněn jednodušší logikou implementace na úkor většího
  zabraného blokového prostoru. Autor [v jiné větvi][64bit arith cscriptnum]
  též zkoumal možnost používat `CScriptNum` s kódováním s proměnlivou délkou."
  a3link="https://bitcoincore.reviews/29221#l-67"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [HWI 3.0.0][] je vydáním nové verze tohoto balíčku poskytujícího
  společné rozhraní několika hardwarovým podpisovým zařízením. Jedinou
  významnou změnou je, že emulované hardwarové peněženky již nebudou
  automaticky detekovány. [HWI #729][] obsahuje podrobnosti.

- [Core Lightning 24.02.2][] je údržbovým vydáním, které opravuje
  „[drobnou nekompatibilitu][core lightning #7174]“ mezi Core Lighting
  a LDK v jedné konkrétní části gossip protokolu.

- [Bitcoin Core 27.0rc1][] je kandidátem na vydání příští hlavní verze
  této převládající implementace plného uzlu. Testeři jsou vyzýváni, aby
  shlédli seznam [navržených témat k testování][bcc testing].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

*Poznámka: commity do Bitcoin Core uvedené níže se vztahují na jeho vývojovou,
master větev. Nebudou tedy pravděpodobně vydány před uplynutím zhruba
šesti měsíců po vydání nadcházející verze 27.*

- [Bitcoin Core #29648][] odstraňuje libconsensus po nedávnem zastarání
  (viz [zpravodaj č. 288][news288 libconsensus]). Libconsensus byl pokusem
  poskytnout logiku konsenzu Bitcoin Core i jinému software. Avšak knihovna
  se nesetkala s významným používáním a stala se v údržbě Bitcoin Core přítěží.

- [Bitcoin Core #29130][] přidává dvě nová RPC volání. První z nich na základě
  uživatelových nastavení vygeneruje deskriptor a přidá jej do peněženky.
  Například následující příkaz přidá podporu pro [taproot][topic taproot] do staré
  peněženky, která jej dříve nepodporovala:

  ```
  bitcoin-cli --rpcwallet=mywallet createwalletdescriptor bech32m
  ```

  Druhým voláním je `gethdkeys` pro načtení [hierarchických deterministických][topic
  bip32] klíčů. RPC vrátí každý xpub (rozšířený veřejný klíč) používaný peněženkou
  a (volitelně) též každý xpriv (rozšířený soukromý klíč). Obsahuje-li peněženka
  více xpub, je možné během volání `createwalletdescriptor` zvolit, který z nich
  má být použit.

- [LND #8159][] a [#8160][lnd #8160] přidávají experimentální (ve výchozím
  nastavení deaktivovanou) podporu pro odesílání plateb na [zaslepené cesty][topic
  rv routing]. Očekává se, že [následné PR][lnd #8485] se kompletně vypořádá
  s chybami neúspěšných zaslepených plateb.

- [LND #8515][] přidává do několika RPC volání možnost určit název použité
  [strategie výběru mincí][topic coin selection]. Toto PR staví na předchozím
  navýšení flexibility výběru mincí, které bylo popsáno ve [zpravodaji č. 292][news292
  lndcs].

- [LND #6703][] a [#6934][lnd #6934] přidávají podporu pro příchozí routovací
  poplatky. Uzel již nyní může ohlásit cenu, za kterou bude určitým odchozím
  kanálem přeposílat platby. Například Carol může oznámit, že bude kanálem
  k Danovi přeposílat platby za 0,1 % přeposílané částky. Pokud tento poplatek
  sníží průměrné množství satoshi za minutu, které Carol přeposílá směrem
  k Danovi, pod průměrnou částku, kterou on posílá směrem k ní, skončí
  nakonec veškerý zůstatek na Carolině straně. Dan tak nebude moci směrem
  ke Carol nic posílat a oba budou kráceni na výdělcích. Aby tomu zabránila,
  může Carol snížit poplatek za použití kanálu směrem k Danovi na 0,05 %.
  Podobně pokud je Carolin odchozí poplatek příliš nízký, v průměru bude posílat
  více satoshi za minutu směrem k Danovi a celý zůstatek nakonec skončí
  na jeho straně. V takovém případě může Carol odchozí poplatek zvýšit.

  Odchozí poplatky se ovšem týkají pouze odchozích kanálů. Carol si účtuje
  stejný poplatek bez ohledu na kanál, ze kterého platbu obdrží. Například
  požaduje stejný poplatek, ať již obdrží platbu od Alice nebo od Boba:

  ```
  Alice -> Carol -> Dan
  Bob -> Carol -> Dan
  ```

  Je to pochopitelné, neboť LN protokol neplatí Carol nic za to, že obdrží
  od Alice či Boba požadavek na přeposlání. Alice a Bob na svých
  kanálech ke Carol poplatky stanovit mohou a je na nich, jak budou
  nastavením poplatků udržovat likviditu kanálů. Podobně může Carol
  nastavovat poplatky za použití kanálů směrem k Alici a Bobovi (např.
  `Dan -> Carol -> Bob`), aby zajistila likviditu kanálů.

  Nicméně Carol může chtít mít více kontroly nad pravidly, které se jí
  týkají. Například pokud Alice špatně spravuje svůj uzel, může často
  přeposílat směrem ke Carol platby, aniž by později někdo chtěl posílat
  platby i v opačném směru. To by nakonec vyústilo v nahromadění veškerého
  zůstatku na Carolině straně, čímž by bylo znemožněno přeposílání dalších
  plateb v tomto směru. Před tímto PR nebylo nic, co mohla Carol učinit,
  kromě včasného zavření kanálu s Alicí před vyplýtváním přílišného množství
  Carolina kapitálu.

  Díky tomuto PR může Carol nově účtovat _poplatek za příchozí žádost_,
  který lze určit pro každý kanál. Například může požadovat vysoký poplatek
  za platby přicházející z Alicina problematického uzlu, ale nižší poplatek
  za platby přicházející z Bobova vysoce likvidního uzlu. Zprvu
  budou příchozí poplatky vždy negativní, aby byla zaručena kompatibilita
  se staršími uzly, které příchozím poplatkům nerozumí. Například by mohla
  Carol nastavit 10% slevu na platby přicházející od Boba a 0% slevu
  na platby přicházející od Alice.

  Tyto poplatky jsou posuzovány zároveň s poplatky odchozími. Například
  pokud Alice nabídne Carol platbu, aby ji přeposlala Danovi, spočítá
  Carol původní poplatek `odchozí_k_danovi`, spočítá nový poplatek
  `příchozí_od_alice` a ujistí se, že přeposílaná platba jí na poplatku
  nabídne nejméně součet obou. V opačném případě [HTLC][topic htlc]
  odmítne. Jelikož se očekává, že budou zpočátku příchozí poplatky
  negativní, nebude Carol odmítat žádné platby, které platí dostatečný
  odchozí poplatek, avšak každý uzel, který příchozím poplatkům rozumí,
  bude moci obdržet slevu.

  Příchozí routovací poplatky byly poprvé [navrženy][bolts #835] před
  třemi lety, o rok později se o nich [diskutovalo][jager inbound] v
  emailové skupině Lightning-Dev a ve stejné době byly zdokumentovány
  v navrhovaném [BLIP #18][BLIPs #18]. Od doby prvního návrhu se několik
  vývojářů jiných implementací LN stavělo proti němu. Někteří z
  [principiálních důvodů][teinturier bolts835], jiní mu vyčítali
  [příliš těsnou vazbu na LND][corallo overly specific] namísto lokální
  a obecné změny, která by okamžitě umožňovala používat kladné příchozí
  poplatky za přeposílání a nevyžadovala za každý kanál globální inzerování
  dalších detailů o poplatcích. Alternativní přístup byl navržen v
  [BLIP #22][BLIPs #22]. Víme pouze o jednom vývojáři mimo tým LND, který
  [naznačil][corallo free money], že funkcionalitu implementují shodně s LND.
  A to pouze v případě, že budou nabízeny záporné příchozí poplatky, neboť
  „jsou to peníze zdarma pro naše uživatele.”

- [Rust Bitcoin #2652][] mění, který veřejný klíč je vrácen po podepsání
  [taprootového][topic taproot] vstupu během zpracování [PSBT][topic psbt].
  Dříve byl vrácen veřejný klíč podepisujícího soukromého klíče, avšak jak
  PR poznamenává, „běžně se interní klíč považuje za ten, který podepisuje,
  i když to technicky není pravda. Tento interní klíč je navíc v PSBT
  již obsažen.” Nyní po začlenění PR bude vrácen interní klíč.

- [HWI #729][] přestává automaticky vypisovat a používat emulátory zařízení.
  Emulátory jsou převážně používány vývojáři HWI a hardwarových peněženek,
  avšak jejich automatická detekce může přinést problémy běžným uživatelům.
  Vývojáři pracující s emulátory musí nově přidat volbu `--emulators`.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 16:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="729,29648,29130,8159,8160,8485,8515,6703,6934,835,18,22,2652,7174,5065" %}
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[HWI 3.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0
[Core Lightning 24.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.2
[news292 lndcs]: /cs/newsletters/2024/03/06/#lnd-8378
[news288 libconsensus]: /cs/newsletters/2024/02/07/#bitcoin-core-29189
[teinturier bolts835]: https://github.com/lightning/bolts/issues/835#issuecomment-764779287
[corallo free money]: https://github.com/lightning/blips/pull/18#issuecomment-1304319234
[corallo overly specific]: https://github.com/lightningnetwork/lnd/pull/6703#issuecomment-1374694283
[jager inbound]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-July/003643.html
[singh dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748
[linus dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748/4
[ruffing bip2]: https://gnusha.org/pi/bitcoindev/59fa94cea6f70e02b1ce0da07ae230670730171c.camel@timruffing.de/
[news296 editors]: /cs/newsletters/2024/04/03/#vyber-novych-editoru-bipu
[erhardt editors]: https://gnusha.org/pi/bitcoindev/c304a456-b15f-4544-8f86-d4a17fb0aa8c@murch.one/
[lopp testnet]: https://gnusha.org/pi/bitcoindev/CADL_X_eXjbRFROuJU0b336vPVy5Q2RJvhcx64NSNPH-3fDCUfw@mail.gmail.com/
[kim testnet]: https://gnusha.org/pi/bitcoindev/950b875a-e430-4bd8-870d-f9a9fab2493an@googlegroups.com/
[review club 29221]: https://bitcoincore.reviews/29221
[delving 64bit arithmetic]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[bip 64bit arithmetic]: https://github.com/bitcoin/bips/pull/1538
[64bit arith cscriptnum]: https://github.com/Christewart/bitcoin/tree/64bit-arith-cscriptnum
[docs 5byte carveout]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.cpp#L531-L544
[doc SCRIPT_VERIFY_MINIMALDATA]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.h#L69-L73
[ml OP_TLUV]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
