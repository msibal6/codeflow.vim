
" function! codeflow#ui_glue#setupCommands() {{{1
function! codeflow#ui_glue#setupCommands() abort
    echom '%#-%'
    command! -nargs=* -bar -bang -complete=augroup Codeflow call codeflow#execute(<f-args>)
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
    echom g:CodeflowCustomOpen
    echom g:CodeflowOpen
    call g:CodeflowKeyMap.Create({'key': g:CodeflowCustomOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call g:CodeflowKeyMap.Create({'key': g:CodeflowCustomOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
    call g:CodeflowKeyMap.Create({'key': g:CodeflowOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call g:CodeflowKeyMap.Create({'key': g:CodeflowOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
endfunction
" }}}

" FUNCTION: nerdtree#ui_glue#invokeKeyMap(key) {{{1
"this is needed since I cant figure out how to invoke dict functions from a
"key map
" TODO(Mitchell): delete this after implementing mouse to see if we no longer
" need this
function! codeflow#ui_glue#invokeKeyMap(key) abort
    echom "ui glue invoke"
    call g:CodeflowKeyMap.Invoke(a:key)
endfunction
" }}}
" TODO(Mitchell):
" function! s:activateFlowNode(node) {{{1
function! s:activateFlowNode(node) abort
    echo a:node
    echom "test activateFlowNode"
    execute "wincmd p"
    call g:CodeflowFlow._openFlow(a:node.flowName)
endfunction
"}}}

" TODO(Mitchell):
" function! s:activateStepNode(node) {{{1
function! s:activateStepNode(node) abort
    echom "test activateStepNode"
endfunction
"}}}
