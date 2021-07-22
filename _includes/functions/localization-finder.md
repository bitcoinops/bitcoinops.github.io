{% assign baseurl = page.permalink | remove_first: "/" | remove_first: page.lang %}
<div class="localization">
    <a href="{{ '/en' | append:baseurl }}">en</a>
    {% for lang in site.languages %}
        {% assign localization = "/" | append: lang.code | append:baseurl %}
        {% assign locale = site.posts | where:"permalink", localization %}
        {% if locale.size == 0 %}
            | <span title="No {{lang.name}} translation currently available">{{ lang.code }}</span>
        {% else %}
            | <a href="{{ locale[0].url }}">{{lang.code}}</a>
        {% endif %}
    {% endfor %}
</div>