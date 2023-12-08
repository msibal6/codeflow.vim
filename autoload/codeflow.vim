function! codeflow#runningWindows() abort " {{{1
    return has('win16') || has('win32') || has('win64')
endfunction
" }}}

function! codeflow#runningCygwin() abort " {{{1
    return has('win32unix')
endfunction
" }}}

" function! codeflow#slash() " {{{1
function! codeflow#slash() abort
    if codeflow#runningWindows()
        if exists('+shellslash') && &shellslash
            return '/'
        endif

        return '\'
    endif

    return '/'
endfunction
" }}}

function! codeflow#loadClassFiles() abort " {{{1
    " TODO(Mitchell): determine if this will be going as part of autoload
    runtime lib/codeflow.vim
    runtime lib/window.vim
    runtime lib/flow.vim
    runtime lib/ui.vim
    runtime lib/keymap.vim
endfunction
" }}}

function! codeflow#postSourceActions() abort " {{{1
    call codeflow#ui_glue#createDefaultBindings()
endfunction
" }}}

function! s:checkArgLimit(args, limit) abort " {{{1
    try
        if len(a:args) > a:limit
            throw "Too many arguments"
        endif
    catch /\v^Too/
        throw "Too many arguments"
    endtry
endfunction
" }}}

function! codeflow#execute(...) abort " {{{1
    try 
        let action = a:1
        if action ==# "start-flow"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowFlow.startFlow()
        elseif action ==# "add-step"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowFlow.addStep()
        elseif action ==# "go-to-step"
            call s:checkArgLimit(a:000, 2)
            call g:CodeflowFlow.goToStep(a:2)
        elseif action ==# "update-step"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowFlow.updateStep()
        elseif action ==# "remove-step"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowFlow.removeStep()
        elseif action ==# "save-flow"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowFlow.saveFlow()
        elseif action ==# "close-flow"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowFlow.closeFlow()
        elseif action ==# "open-flow"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowFlow.openFlow()
        elseif action ==# "open-window"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowWindow.CreateCodeflowWindow()
            " TODO(Mitchell): use flow.vim
        elseif action ==# "close-window"
            call s:checkArgLimit(a:000, 1)
            call g:CodeflowWindow.CloseCodeflowWindow()
        else
            throw "Invalid action"
        endif
    catch /\vNo active flow/
        echoerr "No active flow" 
    catch /\v^E121/
        echoerr "No action" 
    catch /\v^Invalid action/
        echoerr "Invalid action: " . action
    catch /\v^Too/
        echoerr "Too many arguments for " . action
    catch 
        echoerr v:exception
    endtry
endfunction
"}}}

