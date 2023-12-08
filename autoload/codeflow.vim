" FUNCTION: codeflow#runningWindows() {{{1
function! codeflow#runningWindows() abort
    return has('win16') || has('win32') || has('win64')
endfunction
" }}}

"FUNCTION: codeflow#runningCygwin() {{{1
function! codeflow#runningCygwin() abort
    return has('win32unix')
endfunction
" }}}

" function!codeflow#slash() abort {{{1
function!codeflow#slash() abort
    if codeflow#runningWindows()
        if exists('+shellslash') && &shellslash
            return '/'
        endif

        return '\'
    endif

    return '/'
endfunction
" }}}

" TODO(Mitchell): maybe this can run on first all or something
" we see
" FUNCTION: codeflow#loadClassFiles() {{{1
function! codeflow#loadClassFiles() abort
    runtime lib/codeflow.vim
    runtime lib/window.vim
    runtime lib/flow.vim
    runtime lib/ui.vim
    " TODO(Mitchell): put all the class files here
    " if we are going to be doing OOP we might not need it now
    " TODO(Mitchell):
    " flow window
    " flow node
    " step node
endfunction
" }}}

"FUNCTION: codeflow#postSourceActions() {{{1
function! codeflow#postSourceActions() abort
    call codeflow#ui_glue#createDefaultBindings()
endfunction
" }}}

" TODO(Mitchell): delete this if not needed
" function! CodeflowAddKeyMap(options) {{{1
function! CodeflowAddKeyMap(options) abort
    call g:CodeflowKeyMap.Create(a:options)
endfunction
" }}}

" TODO(Mitchell): thsi is a codeflow window function
" function! codeflow#render() {{{1
function! codeflow#render() abort
    echom 'autoload codeflow render'
endfunction
" }}}

" function! codeflow#execute() {{{1
function! codeflow#execute(...) abort
    echom 'in the autoload'
    echo a:000
    if (len(a:000)) == 0
        echoerr "No action"
        return
    endif

    " TODO(Mitchell): put all this in try catch with errors
    " TODO(Mitchell): use flow.vim
    let action = a:000[0]
    if action ==# "start-flow"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call g:CodeflowFlow.startFlow()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "add-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call g:CodeflowFlow.addStep()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "go-to-step"
        if len(a:000) > 2
            echoerr "Too many args"
            return
        endif
        call g:CodeflowFlow.goToStep(a:000[1])
    " TODO(Mitchell): use flow.vim
    elseif action ==# "update-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call g:CodeflowFlow.updateStep()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "remove-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call g:CodeflowFlow.removeStep()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "save-flow"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call g:CodeflowFlow.saveFlow()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "close-flow"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call g:CodeflowFlow.closeFlow()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "open-flow"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call g:CodeflowFlow.openFlow()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "open-window"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call g:CodeflowWindow.CreateCodeflowWindow()
    " TODO(Mitchell): use flow.vim
    elseif action ==# "close-window"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call s:close_flow_window()
    else
        echoerr "Invalid action: " . action
        return
    endif
endfunction
"}}}

" TODO(Mitchell): consider putting all classes in autoload
" if we do not need them, do use them
