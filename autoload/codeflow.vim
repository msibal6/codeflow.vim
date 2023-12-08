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

" function! codeflow#checkFlowFolder() " {{{1
function! codeflow#checkFlowFolder() abort
    let flowFolder = getcwd() . codeflow#slash() . ".flow"
    if getftype(flowFolder) !=# "dir"
        " create .flow folder
        let userResponse = input("Do you want to create flow folder at "
                \ . flowFolder . "?\nPlease enter y/Y if so: ")
        if tolower(userResponse) ==? "y"
            call system ("mkdir "  . shellescape(".flow"))
            return 2
        else
            return 0
        endif
    endif
    return 1
endfunction
" }}}

function! codeflow#loadClassFiles() abort " {{{1
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

function! s:checkArgCount(numArgs, numArgsNeeded) abort " {{{1
    try
        if a:numArgs > a:numArgsNeeded
            throw "Too many arguments"
        elseif a:numArgs < a:numArgsNeeded
            throw "Not enough arguments"
        endif
    catch /Too/
        throw "Too many arguments"
    catch /Not/
        throw "Not enough arguments"
    endtry
endfunction
" }}}

function! codeflow#execute(...) abort " {{{1
    try
        let action = a:1
        try
            let validCommand = filter(copy(g:CodeflowCommandList),
                        \ {_, val -> val.action ==# action})[0]
            call s:checkArgCount(a:0 - 1, validCommand.argsNeeded)
            if len(a:000) == 2
                call validCommand.internalFunction(a:2)
            else
                call validCommand.internalFunction()
            endif
            call g:CodeflowWindow.rerender()
        catch /\vE684/
            echoerr "Invalid action: " . action
        endtry
    catch /\vNo active flow/
        echoerr "No active flow"
    catch /E121/
        echoerr "No action" . v:throwpoint
    catch /\v^Too/
        echoerr "Too many arguments for " . action
    catch /\v^Not enough/
        echoerr "Not enough arguments for " . action
    endtry
endfunction
"}}}
