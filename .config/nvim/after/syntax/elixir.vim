" syntax match exNiceOperator "|>" conceal cchar=󰟥
" syntax match exNiceOperator "|>" conceal cchar=󱞪
syntax match exNiceOperator "|>" conceal cchar=
syntax match exNiceOperator "<-" conceal cchar=
syntax match exNiceOperator "->" conceal cchar=
syntax match exNiceOperator "==" conceal cchar=≡
syntax match exNiceOperator "!=" conceal cchar=≢
" syntax match exNiceOperator "=>" conceal cchar=󰋇
syntax match exNiceOperator "=>" conceal cchar=󰧂
syntax match exNiceOperator "<=" conceal cchar=󰥽
syntax match exNiceOperator ">=" conceal cchar=󰥮

hi link exNiceOperator Operator
hi! link Conceal Operator
setlocal conceallevel=1
