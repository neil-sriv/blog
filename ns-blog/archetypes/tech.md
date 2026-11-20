+++
title = "{{ replace .Name "-" " " | title }}"
date = "{{ .Date }}"
# lastmod = "{{ .Date }}"
# description = "An optional description for SEO. If not provided, an automatically created summary will be used."

# tags = ["example"]
+++

This is a page about »{{ replace .Name "-" " " | title }}«.
