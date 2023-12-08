let s:commandList =
            \ [
                \ {
                    \ 'action'   : 'start',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.startFlow"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'save',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.saveFlow"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'close',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.closeFlow"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'open',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.openFlow"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'appendStep',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.appendStep"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'insertStep',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.insertStep"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'goToStep',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.goToStep"),
                    \ 'argsNeeded' : 1,
                    \ },
                \ {
                    \ 'action'   : 'prevStep',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.prevOver"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'nextStep',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.stepOver"),
                    \ 'argsNeeded' : 0,
                    \ },
                \ {
                    \ 'action'   : 'updateStep',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.updateStep"),
                    \ 'argsNeeded' : 1,
                    \ },
                \ {
                    \ 'action'   : 'removeStep',
                    \ 'internalFunction' : funcref("g:CodeflowFlow.removeStep"),
                    \ 'argsNeeded' : 0,
                    \ }
                \ ]
let g:CodeflowCommandList = s:commandList

" function! s:commandComplete(lead, line, position) " {{{1
function! s:codeflowComplete(lead, line, position) abort
    let args = split(a:line)
    echom len(args)
    " return all valid commands
    if len(args) == 1
        return mapnew(s:commandList, {_,val -> val.action})
    " return matching valid commands
    elseif len(args) == 2
        return matchfuzzy(
                    \ mapnew(s:commandList, { _, val -> val.action }),
                    \ a:lead)
    endif
endfunction
" }}}

" function! codeflow#ui_glue#setupCommands() {{{1
function! codeflow#ui_glue#setupCommands() abort
    command! -nargs=* -bar -bang -complete=customlist,s:codeflowComplete Codeflow call codeflow#execute(<f-args>)
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
