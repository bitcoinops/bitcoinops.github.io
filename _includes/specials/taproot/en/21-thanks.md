Taproot will activate at block {{site.trb}}, which is anticipated a few
days after the publication of this column.  As the final entry in this
series, we would like to thank some of the many people who helped develop
and activate taproot---and who will soon begin enforcing it.  Many
others not mentioned below are also deserving of thanks---we apologize
for all such omissions.

{:#mailing_list_discussion}
**Bitcoin-dev mailing list discussions**

The key idea behind taproot [originated][good morning] on the morning of
22 January 2019 <!-- UTC-6 --> at a meeting between several cryptographers.  It was
[posted][maxwell taproot post] to the Bitcoin-Dev mailing list later the
same day.  Each of the people named below contributed to a thread with
"taproot" in its name.

<!-- in my maildir: grep -lir '^Subject:.*taproot' | xargs cat | grep
^From: | sed 's/^From: //; s/ via.*//; s/ <.*//; s/"//g'

Deleted LORD HIS EXCELLENCY JAMES HRMH,
Added "Rubin" to "Jeremy"
-->

<i>
Adam Back,
Andrea Barontini,
Andreas Schildbach,
Andrew Chow,
Andrew Poelstra,
Anthony Towns,
Antoine Riard,
Ariel Lorenzo-Luaces,
Aymeric Vitte,
Ben Carman,
Ben Woosley,
Billy Tetrud,
BitcoinMechanic,
Bryan Bishop,
Carlo Spiller,
Chris Belcher,
Christopher Allen,
Clark Moody,
Claus Ehrenberg,
Craig Raw,
Damian Mee,
Daniel Edgecumbe,
David A. Harding,
DA Williamson,
Elichai Turkel,
Emil Pfeffer,
Eoin McQuinn,
Eric Voskuil,
Erik Aronesty,
Felipe Micaroni Lalli,
Giacomo Caironi,
Gregory Maxwell,
Greg Sanders,
Jay Berg,
Jeremy Rubin,
John Newbery,
Johnson Lau,
Jonas Nick,
Karl-Johan Alm,
Keagan McClelland,
Lloyd Fournier,
Luke Dashjr,
Luke Kenneth Casson Leighton,
Mark Friedenbach,
Martin Schwarz,
Matt Corallo,
Matt Hill,
Michael Folkson,
Natanael,
Oleg Andreev,
Pavol Rusnak,
Pieter Wuille,
Prayank,
R E Broadley,
Riccardo Casatta,
Robert Spigler,
Ruben Somsen,
Russell O'Connor,
Rusty Russell,
Ryan Grant,
Salvatore Ingala,
Samson Mow,
Sjors Provoost,
Steve Lee,
Tamas Blummer,
Thomas Hartman,
Tim Ruffing,
Vincent Truong,
vjudeu,
yancy,
yanmaani---,
and
ZmnSCPxj.
</i>

However, many of the ideas included in taproot, such as [schnorr
signatures][topic schnorr signatures] and [MAST][topic mast], predate
taproot by years or even decades.  It's beyond our capacity to list the
many contributors to those ideas, but we owe them our thanks
nonetheless.

{:#taproot-bip-review}
**Taproot BIP review**

Starting in November 2019, a large number of users and developers
participated in an [organized review][news69 review] of taproot and
related developments.

<!--
wget -mirror https://gnusha.org/taproot-bip-review/
cat *.log | sed 's/>//g; s/<//' | awk '{print $2}' | sed 's/_$//' | sort -u

Removed some obvious duplicates and bots -harding
-->

<i>
achow101,
afk11,
aj,
alec,
amiti,
_andrewtoth,
andytoshi,
ariard,
arik,
b10c,
belcher,
bjarnem,
BlueMatt,
bsm1175321,
cdecker,
chm-diederichs,
Chris_Stewart_5,
cle1408,
CubicEarth,
Day,
ddustin,
devrandom,
digi_james,
dr-orlovsky,
dustinwinski,
elichai2,
evoskuil,
fanquake,
felixweis,
fjahr,
ghost43,
ghosthell,
gmaxwell,
harding,
hebasto,
instagibbs,
jeremyrubin,
jnewbery,
jonatack,
justinmoon,
kabaum,
kanzure,
luke-jr,
maaku,
mattleon,
michaelfolkson,
midnight,
mol,
Moller40,
moneyball,
murch,
nickler,
nothingmuch,
orfeas,
pinheadmz,
pizzafrank13,
potatoe_face,
pyskell,
pyskl,
queip,
r251d,
raj_149,
real_or_random,
robert_spigler,
roconnor,
sanket1729,
schmidty,
sipa,
soju,
sosthene,
stortz,
taky,
t-bast,
theStack,
Tibo,
waxwing,
xoyi-,
and
ZmnSCPxj.
</i>

{:#github-prs}
**GitHub pull requests**

The main implementation of taproot in Bitcoin Core was submitted for
review starting in January 2020 in [two][bitcoin core #17977] pull
[requests][bitcoin core #19953].  The following people left a GitHub
review on those PRs.  <!-- in addition to sipa, who opened the PRs -->

<i>
Andrew Chow (achow101),
Anthony Towns (ajtowns),
Antoine Riard (ariard),
Ben Carman (benthecarman),
Ben Woosley (Empact),
Bram (brmdbr),
Cory Fields (theuni),
Dmitry Petukhov (dgpv),
Elichai Turkel (elichai),
Fabian Jahr (fjahr),
Andreas Flack (flack),
Gregory Maxwell (gmaxwell),
Gregory Sanders (instagibbs),
James O'Beirne (jamesob),
Janus Troelsen (ysangkok),
Jeremy Rubin (JeremyRubin),
João Barbosa (promag),
John Newbery (jnewbery),
Jon Atack (jonatack),
Jonathan Underwood (junderw),
Kalle Alm (kallewoof),
Kanon (decryp2kanon),
kiminuo,
Luke Dashjr (luke-jr),
Marco Falke (MarcoFalke),
Martin Habovštiak (Kixunil),
Matthew Zipkin (pinheadmz),
Max Hillebrand (MaxHillebrand),
Michael Folkson (michaelfolkson),
Michael Ford (fanquake),
Adam Ficsor (nopara73),
Pieter Wuille (sipa)
Sjors Provoost (Sjors),
Steve Huguenin-Elie (StEvUgnIn),
Tim Ruffing (real-or-random),
and
Yan Pritzker (skwp).
</i>

This doesn't count several other related PRs to Bitcoin Core as well as
the work of implementing taproot in other software, including schnorr
support in libsecp256k1 (used by Bitcoin Core) or alternative node software.

{:#taproot-activation-discussion}
**Taproot activation discussion**

As the taproot implementation was merged into Bitcoin Core, it fell on
the community to decide how it would be activated.  This led to several
months of discussion, with the most active conversations on the taproot
activation IRC channel between the following users, developers, and
miners:

<i>
_6102bitcoin,
AaronvanW,
achow101,
aj,
alec,
Alexandre_Chery,
Alistair_Mann,
amiti,
andrewtoth,
andytoshi,
AnthonyRonning,
ariel25,
arturogoosnargh,
AsILayHodling,
averagepleb,
bcman,
belcher,
benthecarman,
Billy,
bitcoinaire,
bitentrepreneur,
bitsharp,
bjarnem,
blk014,
BlueMatt,
bobazY,
brg444,
btcactivator,
btcbb,
cato,
catwith1hat,
cguida,
CodeShark___,
conman,
copumpkin,
Crash78,
criley,
CriptoLuis,
CubicEarth,
darbsllim,
darosior,
Day,
DeanGuss,
DeanWeen,
debit,
Decentralizedb,
devrandom,
DigDug,
dome,
dr_orlovsky,
duringo,
dustinwinski,
eeb77f71f26eee,
eidnrf,
elector,
elichai2,
Emcy,
emzy,
entropy5000,
eoin,
epson121,
erijon,
eris,
evankaloudis,
faketoshi,
fanquake,
fedorafan,
felixweis,
fiach_dubh,
fjahr,
friendly_arthrop,
GeraldineG,
gevs,
gg34,
ghost43,
ghosthell,
giaki3003,
gloved,
gmaxwell,
graeme1,
GreenmanPGI,
gr-g,
GVac,
gwillen,
gwj,
gz12,
gz77,
h4shcash,
harding,
hebasto,
hiro8,
Hotmetal,
hsjoberg,
huesal,
instagibbs,
Ironhelix,
IT4Crypto,
ja,
jaenu,
JanB,
jeremyrubin,
jimmy53,
jnewbery,
jonatack,
jonny100051,
jtimon,
kallewoof,
kanon,
kanzure,
Kappa,
keblek,
ksedgwic,
landeau,
lucasmoten,
luke-jr,
maaku,
Majes,
maybehuman,
mblackmblack,
mcm-mike,
Memesan,
michaelfolkson,
midnight,
MikeMarzig,
mips,
mol,
molz,
moneyball,
mrb07r0,
MrHodl,
murch,
naribia,
newNickName,
nickler,
nikitis,
NoDeal,
norisgOG,
nothingmuch,
occupier,
OP_NOP,
OtahMachi,
p0x,
pinheadmz,
PinkElephant,
pox,
prayank,
prepaid,
proofofkeags,
provoostenator,
prusnak,
qubenix,
queip,
r251d,
rabidus,
Raincloud,
raj,
RamiDz94,
real_or_random,
rgrant,
riclas,
roasbeef,
robert_spigler,
rocket_fuel,
roconnor,
rovdi,
rubikputer,
RusAlex,
rusty,
sanket1729,
satosaurian,
schmidty,
sdaftuar,
setpill,
shesek,
shinobiusmonk,
snash779,
solairis,
somethinsomethin,
stortz,
sturles,
sugarpuff,
taPrOOteD,
TechMiX,
TheDiktator,
thomasb06,
tiagocs,
tomados,
tonysanak,
TristanLamonica,
UltrA1,
V1Technology,
vanity,
viaj3ro,
Victorsueca,
virtu,
walletscrutiny,
wangchun,
warren,
waxwing,
Whatisthis,
whuha,
willcl_ark,
WilliamSantiago,
windsok,
wumpus,
xxxxbtcking,
yanmaani,
yevaud,
ygrtiugf,
Yoghurt11411,
zmnscpxj,
and
zndtoshi.
</i>

**Miner signaling**

We also thank all of the miners since block 681,408 that have signaled
their readiness to enforce taproot's rules.

**Side projects**

Activation of taproot is only the start.  It will now be up to
developers and users to begin using the new features made available.
Some have been preparing for this for years, working on projects such as
[MuSig][topic musig] and others.  There's no convenient way to get a list
of such developers, but we thank all of them any way.

**Node operators**

Most importantly, we all owe thanks to the thousands of operators of
Bitcoin full verification nodes that have upgraded to Bitcoin Core
0.21.1 or later (or compatible software) and who use their nodes for
receiving payments, ensuring that they will only accept transactions in
blocks that obey taproot's rules starting with block {{site.trb}}.  This
provides an economic incentive for every other Bitcoin user to also only
accept taproot-compliant blocks, making it safe for everyone to use
taproot's features.

{% include linkers/issues.md issues="17977,19953" %}
[maxwell taproot post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[good morning]: /en/preparing-for-taproot/#a-good-morning
[news69 review]: /en/newsletters/2019/10/23/#taproot-review
