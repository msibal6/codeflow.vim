if exists('g:loaded_codeflow_autoload')
    finish
endif
let g:loaded_codeflow_autoload = 1

" codeflow#checkFlowFolder() " {{{1
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
" s:checkArgCount(numArgs, numArgsNeeded) abort " {{{1
function! s:checkArgCount(numArgs, numArgsNeeded) abort
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
" codeflow#execute(...) {{{1
function! codeflow#execute(...) abort
    try
        let command = a:1
        try
            let validCommand = filter(copy(g:CodeflowCommandList),
                        \ {_, val -> val.command ==# command})[0]
            call s:checkArgCount(a:0 - 1, validCommand.argsNeeded)
            if len(a:000) == 2
                call validCommand.internalFunction(a:2)
            else
                call validCommand.internalFunction()
            endif
            call g:CodeflowWindow.rerender()
        catch /\vE684/
            echoerr "Invalid command: " . command
        endtry
    catch /\vNo active flow/
        echoerr "No active flow"
    catch /E121/
        echoerr "No command" . v:throwpoint
    catch /\v^Too/
        echoerr "Too many arguments for " . command
    catch /\v^Not enough/
        echoerr "Not enough arguments for " . command
    catch /\v^Invalid buftype/
        echoerr "Invalid buftype for step"
    endtry
endfunction
"}}}
" codeflow#loadClassFiles() {{{1
function! codeflow#loadClassFiles() abort
    runtime lib/flow.vim
    runtime lib/flow_node.vim
    runtime lib/keymap.vim
    runtime lib/opener.vim
    runtime lib/path.vim
    runtime lib/step_node.vim
    runtime lib/ui.vim
    runtime lib/window.vim
endfunction
" }}}
" codeflow#postSourceActions() {{{1
function! codeflow#postSourceActions() abort
    call codeflow#ui_glue#createDefaultBindings()
endfunction
" }}}
" codeflow#runningWindows() {{{1
function! codeflow#runningWindows() abort
    return has('win16') || has('win32') || has('win64')
endfunction
" }}}
" codeflow#runningCygwin() {{{1
function! codeflow#runningCygwin() abort
    return has('win32unix')
endfunction
" }}}
" codeflow#slash() " {{{1
function! codeflow#slash() abort
    if codeflow#runningWindows()
        if exists('+shellslash') && &shellslash
            return "\/"
        endif

        return "\\"
    endif
    return "\/"
endfunction
" }}}

