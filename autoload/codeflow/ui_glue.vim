
" TODO(Mitchell): command completion
" function! codeflow#ui_glue#setupCommands() {{{1
function! codeflow#ui_glue#setupCommands() abort
    command! -nargs=* -bar -bang -complete=augroup Codeflow call codeflow#execute(<f-args>)
endfunction
" }}}

" function! s:SID() abort {{{1
function! s:SID() abort
    if !exists('s:sid')
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun
" }}} 


" TODO(Mitchell): do we want this to be in autoload
function! codeflow#ui_glue#createDefaultBindings() abort " {{{1
    let script_num = '<SNR>' . s:SID() . '_'
    call g:CodeflowKeyMap.Create({'key': g:CodeflowCustomOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call g:CodeflowKeyMap.Create({'key': g:CodeflowCustomOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
    call g:CodeflowKeyMap.Create({'key': g:CodeflowOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call g:CodeflowKeyMap.Create({'key': g:CodeflowOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
endfunction
" }}}

" TODO(Mitchell): determine if this is necessary after implementing all key
" and mouse presses
" Why do you call it all the way from ui_glue
function! codeflow#ui_glue#invokeKeyMap(key) abort " {{{1
    call g:CodeflowKeyMap.Invoke(a:key)
endfunction
" }}}

" TODO(Mitchell):
function! s:activateFlowNode(node) abort " {{{1
    execute "wincmd p"
    call g:CodeflowFlow._openFlow(a:node.name)
endfunction
"}}}

" TODO(Mitchell):
function! s:activateStepNode(node) abort " {{{1
    echom "test activateStepNode"
endfunction
"}}}
