
" function! codeflow#ui_glue#setupCommands() {{{1
function! codeflow#ui_glue#setupCommands() abort
    echom '%#-%'
    command! -n=? -complete=dir -bar CodeflowNew call codeflow#execute(<f-args>)
endfunction
" }}}

" function! s:SID() {{{1
function! s:SID() abort
    if !exists('s:sid')
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun
" }}} 

" function! codeflow#ui_glue#createDefaultBindings() {{{1
function! codeflow#ui_glue#createDefaultBindings() abort
    let script_num = '<SNR>' . s:SID() . '_'
    call CodeflowAddKeyMap({'key': g:CodeflowCustomOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call CodeflowAddKeyMap({'key': g:CodeflowCustomOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
    call CodeflowAddKeyMap({'key': g:CodeflowOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call CodeflowAddKeyMap({'key': g:CodeflowOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
endfunction
" }}}

" function! s:activateFlowNode(node) {{{1
function! s:activateFlowNode(node) abort
    " TODO(Mitchell):
    echom "test activateFlowNode"
endfunction
"}}}

" function! s:activateStepNode(node) {{{1
function! s:activateStepNode(node) abort
    " TODO(Mitchell):
    echom "test activateStepNode"
endfunction
"}}}
