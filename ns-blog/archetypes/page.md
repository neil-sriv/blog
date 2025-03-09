+++
title = "{{ replace .Name "-" " " | title }}"
date = "{{ .Date }}"
page_number = {{.Name}}

layout = "subpage"
+++
This is page {{.Name}} of a multipage article.
