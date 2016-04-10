name "app"
description "App Server Role"
run_list "recipe[apt]","recipe[golang]","recipe[screeningtest::app]"
