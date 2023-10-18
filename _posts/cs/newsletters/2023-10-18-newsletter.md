---
title: 'Zpravodaj „Bitcoin Optech” č. 273'
permalink: /cs/newsletters/2023/10/18/
name: 2023-10-18-newsletter-cs
slug: 2023-10-18-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme stručnou zmínku nedávného zveřejnění bezpečnostního
problému postihujícího uživatele LN, popis článku o platbách podmíněných
výsledkem běhu libovolného programu a oznámení návrhu BIP na přidání polí
pro MuSig2 do PSBT. Též nechybí naše pravidelné rubriky se souhrnem vylepšení
klientů a služeb, oznámeními o nových vydáních a popisem významných změn v
populárním bitcoinovém páteřním software.

## Novinky

- **Zveřejnění bezpečnostního problému postihujícího LN:** Antoine Riard
  zaslal do emailových skupin Bitcoin-Dev a Lightning-Dev [příspěvek][riard cve]
  zveřejňující problém, který předtím sám [zodpovědně nahlásil][topic
  responsible disclosures] vývojářům pracujícím na bitcoinovém
  protokolu a různých populárních implementacích LN. Poslední verze
  Core Lightning, Eclair, LDK a LND činí tento útok hůře proveditelným,
  ačkoliv jádro problému zcela neodstraňují.

  Problém byl zveřejněn po obvyklé uzávěrce našeho zpravodaje, jsme tedy
  schopni tento týden poskytnout pouze odkaz. Příští týden přineseme
  více podrobností.

- **Platby podmíněné libovolným výpočtem:** Robin Linus zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][linus post] odkazující na svůj [článek][linus
  paper] o _BitVM_. Jedná se o kombinaci metod, která umožňuje poslat
  bitcoiny komukoliv, kdo prokáže, že úspěšně spustil nějaký program.
  Popsaný způsob je možné provádět již nyní, nevyžaduje žádnou změnu
  konsenzu bitcoinu.

  Známou vlastností bitcoinu je požadavek, aby odesílatel bitcoinů uspokojil
  určitý programovací výraz (nazývaný _skript_), se kterým jsou odesílané
  bitcoiny svázané. Například skript obsahující veřejný klíč může být
  uspokojen pouze, pokud odpovídající soukromý klíč podepíše utrácející
  transakci. Aby mohly být tyto skripty vynucovány konsenzem, musí být
  napsány v jazyce bitcoinu (nazývaném _Script_), avšak Script je záměrně
  ve svých možnostech omezen.

  Linusův článek některá tato omezení obchází. Pokud by Alice nedůvěřovala Bobovi
  v ničem jiném, než že by Bob učinil nějaké kroky v případě nesprávného
  spuštění programu, mohla by Alice poslat prostředky na [taprootový][topic taproot]
  strom, který by Bobovi umožnil tyto prostředky nárokovat, pokud by prokázal,
  že Alice správně nespustila nějaký program. Pokud by Alice program správně
  spustila, mohla by prostředky sama utratit, i kdyby se ji Bob pokoušel zastavit.

  Aby mohl být použit libovolný program, musí být rozložen na základní
  primitiva ([hradla NAND][NAND gate]) a musí být vytvořen commitment pro
  každé hradlo. To si vyžádá offchain výměnu velkého množství dat, až
  gigabyty i v případě jednoduchých programů. Avšak pokud Bob uzná,
  že Alice program spustila správně, budou potřebovat jedinou onchain
  transakci. V opačném případě bude muset Bob prokázat Alicino selhání
  poměrně malým počtem onchain transakcí. Pokud by tento scénář proběhl
  v platebním kanále mezi Alicí a Bobem, mohlo by několik programů
  běžet paralelně nebo sekvenčně a nebylo by třeba žádných onchain
  transakcí, kromě vytvoření kanálu a buď jeho kooperativního zavření
  nebo vynuceného zavření, v rámci kterého by Bob demonstroval, že
  Alice správně nevykonala logiku tohoto libovolného programu.

  BitVM lze bez požadavku na důvěru používat v případech, ve kterých jsou
  Alice a Bob přirozenými protivníky, jakou je například hra v šachy:
  oba pošlou prostředky na výstup, který bude moci být utracen vítězem partie.
  Mohou potom použít dva (téměř identické) programy, z nichž každý obdrží
  stejnou sekvenci šachových tahů. Jeden program vrátí true v případě
  Alicina vítězství, druhý vrátí true v opačném případě. Jeden z účastníků
  poté zveřejní onchain transakci, která bude tvrdit, že jeho program
  vrátil true (tedy že vyhrál). Druhý účastník to buď uzná (a vzdá se prostředků)
  nebo prokáže podvod (a obdrží prostředky). V případech, ve kterých
  Alice a Bob přirozenými protivníky nejsou, by mohla Alice Bobovi poskytnout
  podněty k ověřování správnosti výpočtu, například nabídkou prostředků,
  pokud by Bob prokázal, že Alice výpočet správně neprovedla.

  Tato myšlenka obdržela v emailové skupině i na Twitteru a různých bitcoinových
  podcastech velké množství komentářů. Očekáváme, že v následujících týdnech
  a měsících bude diskuze pokračovat.

- **Návrh BIPu na přidání polí pro MuSig2 do PSBT:** Andrew Chow zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][chow mpsbt] s [návrhem BIPu][mpsbt-bip],
  částečně založeným na [dřívější práci][kanjalkar mpsbt] Sanketa Kanjalkara,
  na přidání několika polí pro „klíče, veřejná nonce a částečné podpisy
  vyprodukované [MuSig2][topic musig]” do všech verzí [PSBT][topic psbt].

  Anthony Towns [se zeptal][towns mpsbt], zda-li bude navrhovaný BIP též
  obsahovat pole pro [adaptor signatures][topic adaptor signatures], avšak
  probíhající diskuze naznačuje, že budou pravděpodobně definovány ve
  zvláštním BIPu.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydána pythonová knihovna pro BIP-329:**
  [BIP-329 Python Library][] je souborem nástrojů, který umí načítat, zapisovat,
  šifrovat a dešifrovat soubory se štítky peněženek dle [BIP329][].

- **Oznámen nástroj pro testování LN Doppler:**
  [Doppler][], který byl nedávno [oznámen][doppler announced], podporuje definování
  topologie bitcoinových a lightningových uzlů a onchain/offchain platební aktivity
  pomocí doménově specifického jazyka (DSL) a následné testování součinnosti LND, CLN
  a Eclairu.

- **Vydán Coldcard Mk4 v5.2.0:**
  [Aktualizace][coldcard blog] firmwaru obsahuje podporu pro [PSBT][topic psbt] verze 2
  dle [BIP370][], rozšířenou podporu [BIP39][] a možnost používat více seedů.

- **Tapleaf circuits: demo BitVM:**
  [Tapleaf circuits][] je implementací obvodů ve formátu Bristol za použití
  BitVM zmíněného výše. Účelem implementace je ověření konceptu.

- **Vydán Samourai Wallet 0.99.98i:**
  Vydání [0.99.98i][samourai blog] obsahuje rozšířenou podporu PSBT, štítkování UTXO
  a dávkového odesílání.

- **Krux: firmware pro podpisová zařízení:**
  [Krux][krux github] je projektem open source firmware pro budování hardwarových
  podpisových zařízení používající běžně dostupný hardware.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 24.2rc2][] a [Bitcoin Core 25.1rc1][] jsou kandidáty na vydání
  údržbových verzí Bitcoin Core.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27255][] portuje [miniscript][topic miniscript] do [tapscriptu][topic tapscript].
  Tato změna umožňuje používat miniscript v P2TR [deskriptorech výstupu][topic descriptors],
  a tím přidává podporu „tapminiscriptových deskriptorů” umožňujících sledování i podepisování.
  Dříve byl miniscript dostupný pouze pro P2WSH deskriptory výstupu. Autor poznamenává,
  že výhradně pro použití v P2TR deskriptorech byl přidán nový fragment `multi_a` (mající
  sémantiku shodnou s `multi` v P2WSH deskriptorech). Komentář k PR poznamenává,
  že většina úsilí byla věnována řádnému sledování změn spotřeby zdrojů v rámci tapscriptů.

- [Eclair #2703][] odrazuje odesílatele od přeposílání plateb přes místní uzel,
  je-li zůstatek uzlu nízký a hrozí-li jejich odmítnutí. Je tak dosahováno tím,
  že uzel oznámí snížení maximální hodnoty HTLC. Předcházení odmítání plateb
  zvyšuje plátcům komfort a napomáhá vyvarovat se penalizace místního uzlu
  vyhledávači tras, které snižují hodnocení uzlů, jež nedávno nedokázaly
  přeposlat platbu.

- [LND #7267][] umožňuje vytvářet trasy do [zaslepených cest][topic rv routing].
  Díky tomu se LND posunulo výrazně blíže plné podpoře zaslepených plateb.

- [BDK #1041][] přidává modul pro získávání dat o blockchainu z Bitcoin Core
  pomocí jeho RPC rozhraní.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27255,2703,7267,1041" %}
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021984.html
[linus paper]: https://bitvm.org/bitvm.pdf
[nand gate]: https://cs.wikipedia.org/wiki/Logick%C3%BD_%C4%8Dlen#NAND_(Shefferova_funkce)
[Bitcoin Core 24.2rc2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 25.1rc1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[riard cve]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[mpsbt-bip]: https://github.com/achow101/bips/blob/musig2-psbt/bip-musig2-psbt.mediawiki
[kanjalkar mpsbt]: https://gist.github.com/sanket1729/4b525c6049f4d9e034d27368c49f28a6
[chow mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021988.html
[towns mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021991.html
[BIP-329 Python Library]: https://github.com/Labelbase/python-bip329
[Doppler]: https://github.com/tee8z/doppler
[doppler announced]: https://twitter.com/voltage_cloud/status/1712171748144070863
[coldcard blog]: https://blog.coinkite.com/5.2.0-seed-vault/
[Tapleaf circuits]: https://github.com/supertestnet/tapleaf-circuits
[samourai blog]: https://blog.samourai.is/wallet-update-0-99-98i/
[krux github]: https://github.com/selfcustody/krux
