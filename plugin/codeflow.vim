" Copyright (c) 2023 Mitchell Sibal

" MIT License
" TODO(Mitchell): figure out the MIT license
" Codeflow Initialization

" Script Init {{{1
scriptencoding utf-8

if exists('loaded_codeflow')
    finish
endif

if v:version < 703
    echoerr "Codeflow: this plugin requires vim >= 7.3. DOWNLOAD IT! You'll thank me later!"
    finish
endif
let loaded_codeflow = 1

"for line continuation - i.e dont want C in &cpoptions 
let s:old_cpo = &cpoptions
set cpoptions&vim

"SECTION: Initialize variable calls and other constants {{{2
" TODO(Mitchell): initialize the constants for mappings
let g:CodeflowCustomOpen = get(g:, 'CodeflowCustomOpen', '<CR>')
let g:CodeflowOpen = get(g:, 'CodeflowOpen', 'o')
" }}}


if !codeflow#runningWindows() && !codeflow#runningCygwin()
    let g:CodeflowStepArrowExpandable  = get(g:, 'CodeflowStepArrowExpandable',  '▸')
    let g:CodeflowStepArrowCollapsible = get(g:, 'CodeflowStepArrowCollapsible', '▾')
else
    let g:CodeflowStepArrowExpandable  = get(g:, 'CodeflowStepArrowExpandable',  '+')
    let g:CodeflowStepArrowCollapsible = get(g:, 'CodeflowStepArrowCollapsible', '~')
endif

" Load class files {{{2
call codeflow#loadClassFiles()
" }}}
"}}}

" User Command Setup {{{1
call codeflow#ui_glue#setupCommands()
" }}}

" Auto commands {{{1
" TODO(Mitchell): determine if there are any autocommands that we need
" }}}

" API {{{1
" TODO(Mitchell): put all the public commands here
" }}}

" Post Source {{{1
" TODO(Mitchell): implement the binding for the keys for the flows and steps
" in the flow window
call codeflow#postSourceActions()
" }}}

" function! InputTest() abort " {{{1
function! InputTest() abort
    let text = input("prompt\n", "prefill", "customlist,CompleteThis")
endfunction
" }}}

" function! TestCodeflow() abort " {{{1
function! TestCodeflow() abort
    execute "set number"
    execute "Codeflow start"
    execute ":10"
    execute "Codeflow appendStep"
    execute ":20"
    execute "Codeflow appendStep"
    execute ":30"
    execute "Codeflow appendStep"
    execute "Codeflow goToStep 1"
    execute ":45"
    execute "Codeflow updateStep 0"
    execute "Codeflow goToStep 2"
    execute "Codeflow close"
    execute "Codeflow open"
    echom line('.')
endfunction
" }}}
