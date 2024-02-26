{% capture /dev/null %}
<!--
recap-ad.md: creates an advertisement for the next recap
-->

  Input:
    - when: UTC time of next recap in any format supported by the `date`
      filter, e.g. YYYY-MM-DD HH:MM

  Output:
    A div with a paragraph announcing the next recap and how to
    participate in it.

  Example:
    Input:
      % include linkers/issues.md issues="123,456" %
    Output
      ... at HOUR on DAY ...
-->
{% assign current_epoch_time = site.time | date: "%s" %}
{% assign when_epoch_time = include.when | date: "%s" %}
{% assign recap_formatted_date_utc = include.when | date: "%B %-d" %}
{% assign recap_formatted_time_utc = include.when | date: "%H:%M" %}
{% endcapture %}{% capture recap_ad_text %}
<div markdown="1" class="callout">
{% case page.lang %}
{% when "cs" %}

## Chcete víc?

Další diskuze o tématech zmíněných v tomto zpravodaji proběhnou v týdenním
Bitcoin Optech Recap na [Twitter Spaces][@bitcoinoptech] ve čtvrtek (den po
vydání zpravodaje) v {{recap_formatted_time_utc}} UTC. Diskuze jsou nahrávány a zpřístupněny
na stránce našeho [podcastu][podcast].
{% when "fr" %}

## Vous en voulez plus?

Pour plus de discussions sur les sujets mentionnés dans ce bulletin,
rejoignez-nous pour le récapitulatif hebdomadaire Bitcoin Optech sur [Twitter
Spaces][@bitcoinoptech] à {{recap_formatted_time_utc}} UTC le jeudi (le jour suivant la publication de
la newsletter). La discussion est également enregistrée et sera disponible sur
notre page de [podcasts][podcast].
{% when "ja" %}

## もっと知りたいですか？

このニュースレターで言及されたトピックについてもっと議論したい方は、
（ニュースレターが公開された翌日の）木曜日の{{recap_formatted_time_utc}} UTCから[Twitter
Spaces][@bitcoinoptech]で毎週開催されているBitcoin Optech Recapにご参加ください。
この議論は録画もされ、[ポッドキャスト][podcast]ページからご覧いただけます。

{% when "zh" %}

## 想了解更多？

想了解更多本周报中提到的内容，请加入我们每周的比特币 Optech 回顾的 [Twitter
Space][@bitcoinoptech]，时间为每周四 {{recap_formatted_time_utc}} UTC（即周报发布后的一天）。讨论内容会
被录制下来，也将在我们的[播客][podcast]页面上提供。

{% else %}
## Want more?

For more discussion about the topics mentioned in this newsletter, join
us for the weekly Bitcoin Optech Recap on [Twitter
Spaces][@bitcoinoptech] at {{recap_formatted_time_utc}} UTC on
{{recap_formatted_date_utc}}.  The discussion is also recorded and will
be available from our [podcasts][podcast] page.
{% endcase %}

</div>
{% endcapture %}
{% if when_epoch_time > current_epoch_time %}{{recap_ad_text}}{% endif %}
