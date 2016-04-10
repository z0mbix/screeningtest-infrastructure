name "web"
description "Web Server Role"
run_list "recipe[apt]","recipe[screeningtest::web]"

