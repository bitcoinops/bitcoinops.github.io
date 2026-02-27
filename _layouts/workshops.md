---
type: pages
layout: default
---
<link rel="stylesheet" href="/assets/css/main.css">

<div class="localization">
  <a href="/en/workshops/">en</a>
</div>

<h1 class="post-title">Workshops</h1>

{% if content != ""%}
  <div class="post-content">
    {{ content }}
  </div>
{%- endif -%}

<!-- Info: Show message if no workshops are currently scheduled -->
<p><strong>Currently, no workshops are scheduled. We are evaluating potential future workshop topics and formats based on community feedback and technical developments in the Bitcoin ecosystem.</strong></p>

<!-- Include: Show previous workshops in a collapsible section -->
{% include functions/details-list-workshops.md
  title="Previous Workshops"
  content="
<div id='taproot-workshop'></div>
<h3>Workshops #3, #4 and #5 - Schnorr and Taproot Seminars</h3>
<ul>
  <li>San Francisco, September 24 2019</li>
  <li>New York, September 27 2019</li>
  <li>London, February 5 2020</li>
</ul>
<p><em>Schnorr signatures</em> and <em>Taproot</em> are proposed changes to the Bitcoin protocol that promise greatly improved privacy, fungibility, scalability and functionality.</p>
<p>Bitcoin Optech hosted two seminar format workshops which included a mixture of presentations, coding exercises and discussions, and gave engineers at member companies an understanding of how these new technologies work and how they can be applied to their products and services. The workshops also provided engineers an opportunity to take part in the feedback process while these technologies are still in the proposal stage.</p>
<p><a href='/en/schorr-taproot-workshop/'>All material from the workshops</a> is available on this website, so engineers can learn about the schnorr/taproot proposals at home.</p>
<h3>Workshop #2 - Paris, November 12-13 2018</h3>
<p>Bitcoin Optech held our second roundtable workshop in Paris on November 12-13 2018. The format was the same as the first workshop in San Francisco.</p>
<p>In attendance were 24 engineers from Bitcoin companies and open source projects.</p>
<h4>Topics</h4>
<ul>
  <li>Replace-by-fee vs. child-pays-for-parent as fee replacement techniques</li>
  <li>Partially Signed Bitcoin Transactions (<a href='https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki'>BIP 174</a>)</li>
  <li><a href='https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82'>Output script descriptors</a> for wallet interoperability</li>
  <li>Lightning wallet integration and applications for exchanges</li>
  <li>Approaches to coin selection & consolidation</li>
</ul>
<h4>Thanks</h4>
<p>Thanks to Ledger for hosting the workshop and helping with organization.</p>
<h3>Workshop #1 - San Francisco, July 17 2018</h3>
<p>Bitcoin Optech held our first roundtable workshop in San Francisco on July 17 2018:</p>
<ul>
  <li>Topics were discussed in a roundtable format in which every participant had an equal opportunity to engage.</li>
  <li>Each topic had a moderator and notetaker. The moderator was responsible for a brief introduction of a topic and keeping discussion on track and on time.</li>
  <li>To make sure that participants were comfortable to speak freely, notes and action items were distributed to participants but not beyond. Participants were free to share discussion details internally at their companies and publicly, but did not attribute any particular statement to a given individual (Chatham House Rules).</li>
</ul>
<p>In attendance were 14 engineers from SF Bay Area Bitcoin companies and open source projects.</p>
<h4>Topics</h4>
<ul>
  <li>Coin selection</li>
  <li>Fee estimation, RBF, CPFP best practices</li>
  <li>Optech community and communication</li>
</ul>
<h4>Thanks</h4>
<p>Thanks to Square for hosting the workshop and Coinbase for helping with organization.</p>
"
%}