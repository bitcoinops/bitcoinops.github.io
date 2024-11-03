<li id="{{ include.podcast_slug | slice: 1, include.podcast_slug.size }}" class="anchor-list">
        <p>
          <a href="{{ include.podcast_slug }}" class="anchor-list-link">●</a>
          {{ include.title }}
          {% include functions/podcast-note.md slug=include.slug timestamp=include.timestamp reference=include.reference has_transcript_section=include.has_transcript_section %}
        </p>
      </li>