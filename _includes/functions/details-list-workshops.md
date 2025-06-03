<!--
  This include renders a collapsible <details> section.
  Usage: Pass 'title' and 'content' as parameters.
-->
<details>
  <summary><h2 style="display:inline">{{ include.title }}</h2></summary>
  {{ include.content | markdownify }}
</details>
