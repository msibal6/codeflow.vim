"FUNCTION: codeflow#runningWindows() {{{2
function! codeflow#runningWindows() abort
    return has('win16') || has('win32') || has('win64')
endfunction
" }}}

"FUNCTION: codeflow#runningCygwin() {{{2
function! codeflow#runningCygwin() abort
    return has('win32unix')
endfunction
" }}}

"FUNCTION: codeflow#loadClassFiles() {{{2
function! codeflow#loadClassFiles() abort
    " TODO(Mitchell): put all the class files here
    " if we are going to be doing OOP we might not need it now
    " TODO(Mitchell):
    " flow window
    " flow node
    " step node
endfunction
" }}}

"FUNCTION: codeflow#postSourceActions() {{{2
function! codeflow#postSourceActions() abort
    call codeflow#ui_glue#createDefaultBindings()
endfunction
" }}}

" TODO(Mitchell): delete this if not needed
" function! CodeflowAddKeyMap(options) {{{2
function! CodeflowAddKeyMap(options) abort
    call g:CodeflowKeyMap.Create(a:options)
endfunction
" }}}


" function! s:updateStatusLine() {{{1
function! s:updateStatusLine() abort
    " save previous statusline
    let t:previousStatusLine =
                \ { 'laststatus':    &laststatus,
                \   'statusline':   &statusline,
                \ }
    " display flow status line
    set statusline=%f
    set statusline+=%=
    " TODO(Mitchell): decide on a line number status line field
    execute "set statusline+=%10(" . t:flowName . "%)"
    execute "set statusline+=\\ %2{". t:currentFlowStep. "}/"
    execute "set statusline+=%2{". t:numberFlowSteps. "}"
endfunction
" }}}

" function! s:startFlow() {{{1
function! s:startFlow() abort
    if (len(a:000))
        echoerr "too many arguments"
        return
    endif

    " check for .flow folder
    let flowFolder = getcwd() . "/.flow"
    if len(getftype(flowFolder))
    else
        " create .flow folder
        let userResponse = input("Do you want to create flow folder at "
                \ . flowFolder . "?\nPlease enter y/Y if so\n")
        if tolower(userResponse) ==# "y"
            silent execute "!mkdir "  . shellescape(".flow")
        endif
    endif

    " create flow file
    " TODO(Mitchell) : check for invalid file names
    " for now, valid will only include alphanumber, underscore and space
    let t:flowName = input("Please give flow name\n")
    let t:flowFile = ".flow/" . t:flowName . ".flow"
    execute "pedit " . t:flowFile
    execute "wincmd k"
    silent execute "wq"

    " switch to the active flow state
    let t:isFlowActive = 1

    " TODO(Mitchell): find duplicates of new state
    " this means that we are opening a new flow while one is already open
    " we will be saving the one in progress if desired
    let t:currentFlow = []
    let t:currentFlowStep = 0
    let t:numberFlowSteps = 0

    call s:updateStatusLine()
endfunction
" }}}

" function! s:addStep() {{{1
function! s:addStep() abort
    if !exists("#flow")
        echoerr "No active flow"
        return
    endif

    " create new step
    let newStep = []
    " TODO(Mitchell): change this to be relative path from repo root
    let currentFile = expand("%")
    let currentLineNumber = line(".")
    let stepDesc = input("Please describe this step\n")

    call add(new_step, currentFile)
    call add(new_step, currentLineNumber)
    call add(new_step, stepDesc)

    " add new step to the current flow
    call insert(g:current_flow, deepcopy(new_step), g:current_flow_step)

    let g:current_flow_step += 1
    let g:number_flow_step += 1
    call s:updateStatusLine()
endfunction

" }}}

" function! codeflow#execute() {{{2
function! codeflow#execute(...) abort
    echom 'in the autoload'
    if (len(a:000)) == 0
        echoerr "No action"
        return
    endif

    let action = a:000[0]
    if action ==# "start-flow"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:startFlow()
    elseif action ==# "add-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:addStep()
    elseif action ==# "go-to-step"
        if len(a:000) > 2
            echoerr "Too many args"
            return
        endif
        call s:go_to_step(a:000[1])
    elseif action ==# "update-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:update_step()
    elseif action ==# "remove-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:remove_step()
    elseif action ==# "save-flow"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:save_flow()
    elseif action ==# "close-flow"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call s:close_flow()
    elseif action ==# "open-flow"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call s:open_flow()
    elseif action ==# "open-window"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call s:open_flow_window()
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

" TODO(Mitchell):
" function! codeflow#render() {{{2
function! codeflow#render() abort
    echom 'autoload codeflow render'
endfunction
" }}}
