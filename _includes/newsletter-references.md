{% assign newsletter_sections = page.references | group_by:"header" %}
{% assign header_names = newsletter_sections | map: "name" %}
{% unless header_names contains "News" %}
## News
*No significant news this week was found on the Bitcoin-Dev or Lightning-Dev mailing lists.*
{% endunless %}

{% for section in newsletter_sections %}
## {{ section.name }}
<ul>
  {% for reference in section.items %}
  {% assign podcast_slug = reference.podcast_slug | default: reference.slug %}
  <li id="{{ podcast_slug | slice: 1, podcast_slug.size }}" class="anchor-list">
    <p>
      <a href="{{ podcast_slug }}" class="anchor-list-link">●</a>
      {{ reference.title }}
      (<a title="Play this segment of the podcast" onClick="seek('{{reference.timestamp}}')" class="seek">{{reference.timestamp}}</a><noscript>{{reference.timestamp}}</noscript>)
      <a href="{{page.reference}}{{reference.slug}}">
        <i class="fa fa-link" title="Link to related content"></i>
      </a>
      <!--<a onClick="seek('{{include.timestamp}}')" class="seek"><i class="fa
  fa-headphones" title="Play this segment of the podcast"></i></a>-->
      {% if reference.has_transcript_section %}
      <a href="{{reference.slug}}-transcript">
        <i class="fa fa-file-text-o" title="Read this segment of the transcription"></i>
      </a>
      {% endif %}
    </p>
  </li>
  {% endfor %}
</ul>
{% endfor %}