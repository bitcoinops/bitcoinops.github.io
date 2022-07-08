---
layout: page
title: Applications Enabled by Proposals
permalink: /en/lore/covenants/analysis/enable-table/
nowrap: true

indicators:
  "true":  '<span class="feature-yes"><strong>✓</strong></span>'
  "false": '<span class="feature-no"><strong>✕</strong></span>'
  unknown: '<strong>?</strong>'

---
<style>
th, td { text-align: center; }
h1, h2, h3, h4, h5, h6 { text-align: center; }
</style>

{% assign proposals_sorted = site.covprops | sort: 'shorttitle' %}
{% assign apps_sorted = site.covapps | sort: 'title' %}
<table class="compatibility">
  <tr>
    <th>Applications</th>
    {% for prop in proposals_sorted %}
    <th><a href="{{prop.url}}">{{prop.shorttitle}}</a></th>
    {% endfor %}
  </tr>

  {% for app in apps_sorted %}
  <tr>
    <th><a href="{{app.url}}">{{app.title}}</a></th>
    {% for prop in proposals_sorted %}
      {% assign app_status = prop.covenant_based_apps[app.uid].enabled %}
      <td class="status_{{app_status}}">{{page.indicators[app_status]}}</td>
    {% endfor %}
  </tr>
  {% endfor %}

</table>

<br/>
<br/>
_Contributions and corrections are welcome. Please see the [contibuting
guidelines](https://github.com/bitcoinops/bitcoinops.github.io/blob/master/CONTRIBUTING.md)
for details._
{: style="text-align: center;"}
