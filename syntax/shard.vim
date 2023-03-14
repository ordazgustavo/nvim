" Vim syntax file
" Language: Shard
" Latest Revision: 2023-03-03

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:shard_syntax_keywords = {
    \   'shardConditional' :["if"
    \ ,                     "else"
    \ ,                     "match"
    \ ,                    ]
    \ , 'shardRepeat' :["while"
    \ ,                "for"
    \ ,                "loop"
    \ ,               ]
    \ , 'shardExecution' :["return"
    \ ,                   "break"
    \ ,                   "continue"
    \ ,                   "throw"
    \ ,                   "yield"
    \ ,                  ]
    \ , 'shardBoolean' :["true"
    \ ,                 "false"
    \ ,                ]
    \ , 'shardKeyword' :["fn"
    \ ,                ]
    \ , 'shardVarDecl' :["let"
    \ ,                ]
    \ , 'shardType' :["String"
    \ ,              "bool"
    \ ,              "void"
    \ ,             ]
    \ , 'shardConstant' :["self"
    \ ,                 ]
    \ , 'shardStructure' :["struct"
    \ ,                   "enum"
    \ ,                   "trait"
    \ ,                   "impl"
    \ ,                  ]
    \ , 'shardVisModifier': ["pub"
    \ ,                    ]
    \ , }

function! s:syntax_keyword(dict)
  for key in keys(a:dict)
    execute 'syntax keyword' key join(a:dict[key], ' ')
  endfor
endfunction

call s:syntax_keyword(s:shard_syntax_keywords)

syntax match shardDecNumber display   "\v<\d%(_?\d)*"
syntax match shardHexNumber display "\v<0x\x%(_?\x)*"
syntax match shardOctNumber display "\v<0o\o%(_?\o)*"
syntax match shardBinNumber display "\v<0b[01]%(_?[01])*"

syntax match shardFatArrowOperator display "\V=>"
syntax match shardRangeOperator display "\V.."
syntax match shardOperator display "\V\[-+/*=^&?|!><%~:;,]"

syntax match shardFunction /\w\+\s*(/me=e-1,he=e-1

syntax match shardEnumDecl /enum\s\+\w\+/lc=4
syntax match shardStructDecl /struct\s\+\w\+/lc=6
syntax match shardClassDecl /class\s\+\w\+/lc=5

syntax region shardBlock start="{" end="}" transparent fold

syntax region shardCommentLine start="//" end="$"

syntax region shardString matchgroup=shardStringDelimiter start=+"+ skip=+\\\\\|\\"+ end=+"+ oneline contains=shardEscape
syntax region shardChar matchgroup=shardCharDelimiter start=+'+ skip=+\\\\\|\\'+ end=+'+ oneline contains=shardEscape
syntax match shardEscape        display contained /\\./

highlight default link shardDecNumber shardNumber
highlight default link shardHexNumber shardNumber
highlight default link shardOctNumber shardNumber
highlight default link shardBinNumber shardNumber

highlight default link shardFatArrowOperator shardOperator
highlight default link shardRangeOperator shardOperator

highlight default link shardStructDecl shardType
highlight default link shardClassDecl shardType
highlight default link shardEnumDecl shardType

highlight default link shardKeyword Keyword
highlight default link shardType Type
highlight default link shardCommentLine Comment
highlight default link shardString String
highlight default link shardStringDelimiter String
highlight default link shardChar String
highlight default link shardCharDelimiter String
highlight default link shardEscape Special
highlight default link shardBoolean Boolean
highlight default link shardConstant Constant
highlight default link shardNumber Number
highlight default link shardOperator Operator
highlight default link shardStructure Structure
highlight default link shardExecution Special
highlight default link shardConditional Conditional
highlight default link shardRepeat Repeat
highlight default link shardVarDecl Define
highlight default link shardFunction Function
highlight default link shardVisModifier Label

delfunction s:syntax_keyword

let b:current_syntax = "shard"

let &cpo = s:cpo_save
unlet! s:cpo_save
