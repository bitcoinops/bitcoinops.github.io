---
layout: page
title: Translations
permalink: /translations/
---

The translation for this newsletter is not available yet. If you'd like to help
translate or review, please see our [CONTRIBUTING.md][github contributing] file
for details. For any questions, please email [info@bitcoinops.org][optech
email]. In the meantime, you can view our existing publications.

<ul>
    <li><a href="/en/publications/">English</a></li>
    {% for lang in site.languages %}
        <li><a href="/{{ lang.code }}/publications/">{{lang.name}}</a></li>
    {% endfor %}
</ul>

{% include references.md %}
[github contributing]: https://github.com/bitcoinops/bitcoinops.github.io/blob/master/CONTRIBUTING.md#translations
