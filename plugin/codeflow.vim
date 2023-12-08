" Copyright (c) 2023 Mitchell Sibal
"
" MIT License
" I do not know what the MIT license even is actually
" Second start for Codeflow

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
let g:CodeflowOpen = get(g:, 'CodeflowCustomOpen', '<CR>')
" }}}


if !codeflow#runningWindows() && !codeflow#runningCygwin()
    let g:NERDTreeDirArrowExpandable  = get(g:, 'NERDTreeDirArrowExpandable',  '▸')
    let g:NERDTreeDirArrowCollapsible = get(g:, 'NERDTreeDirArrowCollapsible', '▾')
else
    let g:NERDTreeDirArrowExpandable  = get(g:, 'NERDTreeDirArrowExpandable',  '+')
    let g:NERDTreeDirArrowCollapsible = get(g:, 'NERDTreeDirArrowCollapsible', '~')
endif

" Load class files{{{2
call codeflow#loadClassFiles()
" }}}
"}}}

" Commands {{{1
call codeflow#ui_glue#setupCommands()
" }}}

" Auto commands {{{1
" TODO(Mitchell): determine if there are any autocommands that we need
" }}}

" API {{{1
" TODO(Mitchell): put all the public commands here
" function! CodeflowAddKeyMap(options) {{{2
function! CodeflowAddKeyMap(options) abort
    call g:CodeflowKeyMap.Create(a:options)
endfunction
" }}}

" function! CodeflowRender() {{{2
function! CodeflowRender() abort
    call codeflow#render()
endfunction
" }}}

" }}}

" Post Source {{{1
" TODO(Mitchell): implement the binding for the keys for the flows and steps
" in the flow window
call codeflow#postSourceActions()
" }}}

function! TestCodeflow() abort
    execute "Codeflow start-flow"
    execute ":10"
    execute "Codeflow add-step"
    execute ":20"
    execute "Codeflow add-step"
    execute ":30"
    execute "Codeflow add-step"
    execute "Codeflow go-to-step 1"
    execute ":45"
    execute "Codeflow update-step"
endfunction
