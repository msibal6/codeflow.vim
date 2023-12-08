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

"FUNCTION: codeflow#loadClassFiles() {{{1
function! codeflow#loadClassFiles() abort
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

" TODO(Mitchell):
" function! codeflow#render() {{{1
function! codeflow#render() abort
    echom 'autoload codeflow render'
endfunction
" }}}

" function! s:savePrevStatusLine() {{{1
function! s:savePrevStatusLine() abort
    " save previous statusline
    let t:previousStatusLine =
                \ { 'laststatus':    &laststatus,
                \   'statusline':   &statusline,
                \ }
endfunction
" }}}

" function! s:updateStatusLine() {{{1
function! s:updateStatusLine() abort
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
    call s:savePrevStatusLine()
    call s:updateStatusLine()
endfunction
" }}}

" function! s:addStep() {{{1
function! s:addStep() abort
    if !exists("t:isFlowActive")
        echoerr "No active flow"
        return
    endif

    " create new step
    let newStep = []
    " TODO(Mitchell): change this to be relative path from repo root
    let currentFile = expand("%")
    let currentLineNumber = line(".")
    let stepDesc = input("Please describe this step\n")

    call add(newStep, currentFile)
    call add(newStep, currentLineNumber)
    call add(newStep, stepDesc)

    " add new step to the current flow
    call insert(t:currentFlow, copy(newStep), t:currentFlowStep)

    let t:currentFlowStep += 1
    let t:numberFlowSteps += 1
    call s:updateStatusLine()
endfunction

" }}}

" function! s:goToStep(stepIndex) {{{1
function! s:goToStep(stepIndex) abort
    if !a:stepIndex
        echoerr "No flow index given"
        return
    endif

    if a:stepIndex > t:numberFlowSteps
        echoerr "Out of flow range"
        return
    endif

    let t:currentFlowStep = a:stepIndex
    let currentStep = t:currentFlow[t:currentFlowStep - 1]
    " TODO(Mitchell): turn steps into dictionary
    " after getting everything back in this version
    " TODO(Mitchell): check if we already have this open and use buffer to
    " prevent reloading the same file that we are already on
    execute "edit " . fnameescape(currentStep[0])
    execute ":" . currentStep[1]
    call s:updateStatusLine()
endfunction

" }}}

" function! s:updateStep() {{{1
function! s:updateStep() abort
    if !exists("t:isFlowActive")
        echoerr "No active flow"
        return
    endif

    " Update step
    let currentFile = expand("%")
    let currentLineNumber = line(".")
    let stepDesc = input("Please describe this step\n")

    " update new data to current step
    let newStep = t:currentFlow[t:currentFlowStep - 1]
    let newStep[0] = currentFile
    let newStep[1] = currentLineNumber
    let newStep[2] = stepDesc
    call s:updateStatusLine()
    echo t:currentFlow
endfunction
" }}}

" function! s:removeStep() {{{1
function! s:removeStep() abort
    if !exists("t:isFlowActive")
        echoerr "No active flow"
        return
    endif

    if !t:numberFlowSteps
        echoerr "No flow steps"
        return
    endif

    call remove(t:currentFlow, t:currentFlowStep - 1)
    if t:currentFlowStep == t:numberFlowSteps
        let t:currentFlowStep -= 1
    endif
    let t:numberFlowSteps -= 1
    call s:updateStatusLine()
    echo t:currentFlow
endfunction

" }}}

" function! s:saveFlow() {{{1
function! s:saveFlow() abort
    " clear flow file
    execute "pedit " . t:flowFile
    execute "wincmd k"
    normal! ggVGx
    " write file, line number and description for each step
    " TODO(Mitchell): create hidden buffer to hide buffer listing and it does not have a swap file 
    " TODO(Mitchell): test out put and set line to if they are better
    for step in t:currentFlow
        execute "normal! i" . step[0] . "\n"
        execute "normal! i" . step[1] . "\n"
        execute "normal! i" . step[2] . "\n"
    endfor
    " Delete the last empty line
    normal! Gdd
    execute "wq"
endfunction
" }}}

" function! s:openFlow() {{{1
function! s:openFlow() abort
    let chosenFlow = input("Please give flow name\n")

    if !len(chosenFlow)
        echom "no flow given"
        return
    endif
    " TODO(Mitchell): check if we already have another flow going
    " TODO(Mitchell): add all the checking
    " it is much faster to implement when you know all the input that can be
    " given for a certain function
    " the real world is much harder

    let t:isFlowActive = 1
    let t:flowName = chosenFlow
    let t:flowFile = ".flow/". t:flowName . ".flow"
    let t:currentFlow = []
    let t:currentFlowStep = 0
    let t:numberFlowSteps = 0

    " Read flow file
    execute "pedit " . t:flowFile
    execute "wincmd k"
    let numberLines = line("$")
    let currentLine = 1
    " TODO(Mitchell): replace with dictionary to make indexing more clear
    let newStep = []

    while currentLine <= numberLines
        let current_line_text = getline(currentLine)
        call add(newStep, current_line_text)
        if currentLine % 3 == 0
            " TODO(Mitchell): replace deepcopy with copy as test
            call add(t:currentFlow, deepcopy(newStep))
            let newStep = []
        endif
        let currentLine += 1
    endwhile
    execute "wq"

    " Go to first step
    let t:currentFlowStep = 1
    " TODO(Mitchell): replace with step function about number of step
    let t:numberFlowSteps = numberLines / 3
    call s:savePrevStatusLine()
    call s:updateStatusLine()
    call s:goToStep(t:currentFlowStep)
endfunction
" }}}

" function! s:closeFlow() {{{1
function! s:closeFlow() abort
    " TODO(Mitchell): change to function to throw error for no active flow
    if !exists("t:isFlowActive")
        echoerr "No active flow"
        return
    endif

    call s:saveFlow()

    unlet t:isFlowActive
    unlet t:flowName
    unlet t:flowFile
    unlet t:currentFlow
    unlet t:currentFlowStep
    unlet t:numberFlowSteps

    " Restore previous state
    echom t:previousStatusLine['statusline']
    echom t:previousStatusLine['laststatus']
    let &statusline = t:previousStatusLine['statusline']
    let &laststatus = t:previousStatusLine['laststatus']
    unlet t:previousStatusLine
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
        call s:goToStep(a:000[1])
    elseif action ==# "update-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:updateStep()
    elseif action ==# "remove-step"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:removeStep()
    elseif action ==# "save-flow"
        if len(a:000) > 1
            echoerr "Too many args"
            return
        endif
        call s:saveFlow()
    elseif action ==# "close-flow"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call s:closeFlow()
    elseif action ==# "open-flow"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call s:openFlow()
    " TODO(Mitchell):
    elseif action ==# "open-window"
        if len(a:000) > 1
            echoerr "too many args"
            return
        endif
        call s:open_flow_window()
    " TODO(Mitchell):
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

