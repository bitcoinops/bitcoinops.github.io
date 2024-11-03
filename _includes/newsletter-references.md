{% assign newsletter_sections = page.references | group_by:"header" %}
{% assign header_names = newsletter_sections | map: "name" %}
{% unless header_names contains "News" or header_names contains "January" %}
## News
*No significant news this week was found on the Bitcoin-Dev or Lightning-Dev mailing lists.*
{% endunless %}
<div>
{% for section in newsletter_sections %}
  <h2 id="{{ section.name | slugify: 'latin'}}"> {{ section.name }}
    {% if page.special_sections contains section.name %}

    <!-- Special sections are section that do not have list items, therefore
    we display the timestamp and transcript links in the header -->
      {% assign reference = section.items | first %}
      <span style="font-size:0.5em">{% include functions/podcast-note.md slug=reference.slug timestamp=reference.timestamp reference=page.reference has_transcript_section=reference.has_transcript_section %}</span>
    {% endif %}
  </h2>
  {% unless page.special_sections contains section.name %}
    <ul>
      {% for reference in section.items %}
      {% assign podcast_slug = reference.podcast_slug | default: reference.slug %}
      {% include functions/podcast-bullet.md slug=reference.slug timestamp=reference.timestamp reference=page.reference podcast_slug=podcast_slug title=reference.title has_transcript_section=reference.has_transcript_section %}
      {% endfor %}
    </ul>
  {% endunless %}
{% endfor %}
</div>
