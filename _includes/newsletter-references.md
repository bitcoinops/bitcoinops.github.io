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
      {% include functions/podcast-note.md %}
    </p>
  </li>
  {% endfor %}
</ul>
{% endfor %}