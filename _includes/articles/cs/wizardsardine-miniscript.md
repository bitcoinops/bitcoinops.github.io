{:.post-meta}
*napsal [Antoine Poinsot][] z [Wizardsardine][]*

Z praktického hlediska jsme se o miniscript začali zajímat počátkem roku 2020
během navrhování [Revault][]. Jedná se o systém [úschovny][topic vaults] s více
účastníky využívající pouze tehdy dostupná skriptová primitiva.

V první fázi jsme pracovali s pevně daným počtem účastníků. Když jsme se pokoušeli
o generalizaci našeho přístupu na více účastníků, narazili jsme na překážky.

- Jsme si opravdu _jisti_, že skript, který jsme používali během předvádění, je
bezpečný? Je možné jej opravdu utratí všemi inzerovanými způsoby? Neexistuje i
jiná, nám neznámá možnost utracení?
- A i kdyby existovala, jak zaručit bezpečnost při generalizaci na různé
počty účastníků? Jak můžeme provádět optimalizace a přitom zajistit, aby se neměnila
sémantika výsledného skriptu?
- Revault používá předem podepsané transakce (by mohl vynutit pravidla utracení).
Jak můžeme dopředu vědět, jaký rozpočet v závislosti na nastavení skriptu je
potřeba alokovat na navyšování poplatků? Jak můžeme zajistit, aby _jakákoliv_
transakce utrácející tyto skripty splňovala základní pravidla standardnosti?
- A konečně, i kdybychom předpokládali, že naše skripty fungují, jak bylo
zamýšleno, a lze je vždy utratit, jak _konkrétně_ je možné je utratit? Jak můžeme
sestavit witness, který bude uspokojovat každou možnou konfiguraci? A jak
zajistit kompatibilitu hardwarových podpisových zařízení s našimi skripty?

Bez existence miniscriptu bychom se přes tyto otázky nedostali. Dva chlápci v garáži
by nebyli schopni napsat software, který [by za běhu vytvořil nějaký skript, doufali by,
že se nic nestane][rekt lost funds], a navrch by jej mohli označovat za bezpečnou
bitcoinovou peněženku. Naším záměrem bylo založit kolem vývoje Revault firmu, ale
bez poskytnutí nějaké záruky investorům, že jsme schopni dodat na trh bezpečný produkt,
bychom na prostředky nedosáhli.

Pohleďte na [miniscript][sipa miniscript], „jazyk pro psaní (podmnožiny) bitcoinových
skriptů strukturovaným způsobem, umožňující analýzu, kompozici, generické podepisování
 a další. […] Má strukturu umožňující kompozici. Je jednoduché staticky analyzovat
různé jeho vlastnosti (platební podmínky, správnost, bezpečnost, poddajnost atd.).”
Přesně to jsme potřebovali. S tímto mocným nástrojem jsme mohli nabídnout našim
investorům silnější garance [0], vybrat finance a začít Revault vyvíjet.

V té době nebyl miniscript ještě zdaleka tím řešením, po kterém by se vývojáři
bitcoinových aplikací otáčeli. (Čtete-li tento text jako čerstvý bitcoinový vývojář
po roce 2023, věřte, že bývaly doby, kdy jsme psali bitcoinové skripty RUČNĚ.) Museli
jsme začlenit miniscript do Bitcoin Core (viz PR [#24147][Bitcoin Core #24147],
[#24148][Bitcoin Core #24148] a [#24149][Bitcoin Core #24149]), který jsme pro
peněženku Revault používali jako backend, a přesvědčit výrobce podpisových
zařízení, aby přidali podporu do svých firmware. To druhé se ukázalo jako
nejtěžší.

Byl to problém slepice a vejce: malá poptávka od uživatelů nepřinášela výrobcům
k implementaci miniscriptu dostatečně silný podnět. A bez podporu podpisových
zařízení jsme Revault vydat nemohli. Naštěstí byla nakonec tato smyčka přerušena,
když v březnu 2021 [přinesl][github embit descriptors] [Stepan Snigirev][]
[podporu][github specter descriptors] pro miniscriptové deskriptory do [Specter DIY][].
Specter DIY byl však po dlouhou dobu prezentován jako pouhý „funkční prototyp.”
Byl to v roce 2022 až [Salvatore Ingala][], který přinesl [miniscript do produkčního
podpisového zařízení][ledger miniscript blog] Ledger Nano S(+) v rámci
[nové bitcoinové aplikace][ledger bitcoin app]. Ta byla vydána v lednu 2023
a umožnila nám zveřejnit [peněženku Liana][Liana wallet] s podporou nejpopulárnějšího
podpisového zařízení.

Zbývá ještě pokrýt náš poslední vývoj. [Liana][github liana] je bitcoinová peněženka
zaměřená na možnosti obnovy. Umožňuje uživatelům specifikovat podmínky obnovy s
časovým zámkem (například [obnovovací klíč poskytnutý třetí stranou][blog liana 0.2
recovery], který nemůže prostředky normálně utratit, nebo [multisig][blog liana 0.2 decaying]
měnící počet potřebných podpisů během času). Miniscript byl na počátku dostupný pouze
pro P2WSH skripty. Téměř dva roky po aktivaci [taprootu][topic taproot] je bohužel nutné
s každou platbou publikovat onchain své obnovovací skripty. Pracujeme proto na
portování miniscriptu do tapscriptu (viz [jedno][github minitapscript] PR a [druhé][Bitcoin
Core #27255] PR).

Budoucnost je nadějná. Většina podpisových zařízení již podporu miniscriptu obsahuje,
další pracují na její implementaci (nedávno například [Bitbox][github bitbox v9.15.0]
a [Coldcard][github coldcard 227]). Tvorba bitcoinových kontraktů s bezpečnými primitivy
je dostupnější než kdykoliv předtím.

Je zajímavé pozorovat, jak financování open source nástrojů a frameworků snižuje
inovativním společnostem vstupní bariéry. Tento trend, který v posledních letech
zrychluje, nám může v této oblasti přinést naději.

[0] Pochopitelně stále existují rizika. Ale přinejmenším jsme věřili, že se
dostaneme přes tento onchain milník. Offchain bude, nepřekvapivě, mnohem náročnější.

{% include references.md %}
{% include linkers/issues.md v=2 issues="24147,24148,24149,27255" %}
[Antoine Poinsot]: https://twitter.com/darosior
[Wizardsardine]: https://wizardsardine.com/
[Revault]: https://wizardsardine.com/revault
[rekt lost funds]: https://rekt.news/leaderboard/
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
[Stepan Snigirev]: https://github.com/stepansnigirev
[github embit descriptors]: https://github.com/diybitcoinhardware/embit/pull/4
[github specter descriptors]: https://github.com/cryptoadvance/specter-diy/pull/133
[Specter DIY]: https://github.com/cryptoadvance/specter-diy
[Salvatore Ingala]: https://github.com/bigspider
[ledger miniscript blog]: https://www.ledger.com/blog/miniscript-is-coming
[ledger bitcoin app]: https://github.com/LedgerHQ/app-bitcoin-new
[Liana wallet]: https://wizardsardine.com/liana/
[github liana]: https://github.com/wizardsardine/liana
[blog liana 0.2 recovery]: https://wizardsardine.com/blog/liana-0.2-release/#trust-distributed-safety-net
[blog liana 0.2 decaying]: https://wizardsardine.com/blog/liana-0.2-release/#decaying-multisig
[github minitapscript]: https://github.com/sipa/miniscript/pull/134
[github bitbox v9.15.0]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.15.0
[github coldcard 227]: https://github.com/Coldcard/firmware/pull/227
[github bdk]: https://github.com/bitcoindevkit/
