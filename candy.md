---
layout: page
title: Candy
---

{% for source in site.data.stock %}
  {% if source['slug'] %}
  <h2> ({{forloop.index}}) <a href="/candy/{{ source['slug'] }}">/images/stock/{{ source['slug'] }}.jpg</a></h2>
  <img src="/images/stock/{{ source['slug'] }}.jpg" />
  {% endif %}
{% endfor %}

