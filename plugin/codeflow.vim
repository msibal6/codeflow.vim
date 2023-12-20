" Copyright (c) 2023 Mitchell Sibal
" MIT License

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

" for line continuation - i.e dont want C in &cpoptions 
let s:old_cpo = &cpoptions
set cpoptions&vim

"SECTION: Initialize variable calls and other constants {{{2
let g:CodeflowcHotkey = get(g:, 'CodeflowcHotkey', 'c')
let g:CodeflowCustomOpen = get(g:, 'CodeflowCustomOpen', '<CR>')
let g:CodeflowOpen = get(g:, 'CodeflowOpen', 'o')
let g:CodeflowClose = get(g:, 'CodeflowClose', 'c')
let g:CodeflowUp = get(g:, 'CodeflowUp', 'K')
let g:CodeflowDown = get(g:, 'CodeflowDown', 'J')
let g:CodeflowDelete = get(g:, 'CodeflowDelete', 'd')
let g:CodeflowsHotkey = get(g:, 'CodeflowsHotkey', 's')

if !codeflow#runningWindows() && !codeflow#runningCygwin()
    let g:CodeflowStepArrowExpandable  = get(g:, 'CodeflowStepArrowExpandable',  '▸')
    let g:CodeflowStepArrowCollapsible = get(g:, 'CodeflowStepArrowCollapsible', '▾')
else
    let g:CodeflowStepArrowExpandable  = get(g:, 'CodeflowStepArrowExpandable',  '+')
    let g:CodeflowStepArrowCollapsible = get(g:, 'CodeflowStepArrowCollapsible', '~')
endif

let g:CodeflowWinPos  = get(g:, 'CodeflowWinPos', 'left')
let g:CodeflowWinSize = get(g:, 'CodeflowWinSize', 31)
" }}}

" Load class files {{{2
call codeflow#loadClassFiles()
" }}}
" }}}1

" User Command Setup {{{1
call codeflow#ui_glue#setupCommands()
" }}}

" Auto commands {{{1
augroup Codeflow
    autocmd!
    "Save the cursor position whenever we close the flow window
    execute "autocmd BufLeave,WinLeave " . g:CodeflowWindow.nextBufferPrefix() ."* if g:CodeflowWindow.isOpen() | call b:codeflowWindow.ui.saveScreenState() | endif"

    "disallow insert mode in the flow window
    execute "autocmd BufEnter,WinEnter " . g:CodeflowWindow.nextBufferPrefix() . "* stopinsert"
augroup END
" }}}

" API {{{1
" }}}

" Post Source {{{1
call codeflow#postSourceActions()
" }}}

" function! TestCodeflow() abort " {{{1
function! TestCodeflow() abort
    execute "set number"
    execute "Codeflow start"
    execute ":10"
    execute "Codeflow addStep"
    execute ":20"
    execute "Codeflow addStep"
    execute ":30"
    execute "Codeflow addStep"
    execute "Codeflow goToStep 1"
    execute ":45"
    execute "Codeflow updateStep"
    execute "Codeflow goToStep 2"
    execute "Codeflow close"
    execute "Codeflow open"
    echom line('.')
endfunction
" }}}
