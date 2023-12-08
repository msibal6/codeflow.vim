let s:Flow = {}
let g:CodeflowFlow = s:Flow

" function! s:Flow.savePrevStatusLine() {{{1
function! s:Flow.savePrevStatusLine() abort
    let t:previousStatusLine =
                \ { 'laststatus':    &laststatus,
                \   'statusline':   &statusline,
                \ }
endfunction
" }}}

" function! s:Flow.updateStatusLine() {{{1
function! s:Flow.updateStatusLine() abort
    " display flow status line
    set statusline=%f
    set statusline+=%=
    silent execute "set statusline+=%10(" . t:currentCodeFlow.name->escape(' ') . "%)"
    silent execute "set statusline+=\\ %2{". t:currentCodeFlow.currentStep . "}/"
    silent execute "set statusline+=%2{". t:currentCodeFlow.numberSteps. "}"
endfunction
" }}}

" function! s:Flow.isValidName(desiredName) {{{1
function! s:Flow.isValidName(desiredName) abort
    for char in a:desiredName
        if char !~# "[0-9A-Za-z _]"
            return 0
        endif
    endfor
    return 1
endfunction
" }}}

" function! s:Flow.startFlow() {{{1
function! s:Flow.startFlow() abort
    let folderStatus = codeflow#checkFlowFolder()
    if folderStatus ==# 0
        return
    endif

    if s:Flow.isFlowActive()
        call s:Flow.closeFlow()
    endif
        
    " create new code flow
    let prompt = folderStatus ==# 1 ? "" : "\n"
    let prompt .= "Please give flow name\n"
    let desiredName = input(prompt)
    if !s:Flow.isValidName(desiredName)
        echo "\nPlease enter valid flow name with alphanumeric, ' ', and '_'
                    \ characters" 
        return
    endif
    let t:currentCodeFlow = {}
    let t:currentCodeFlow.name = desiredName
    let t:currentCodeFlow.file = ".flow". codeflow#slash() . t:currentCodeFlow.name . ".flow"
    let t:currentCodeFlow.steps = []
    let t:currentCodeFlow.currentStep = 0
    let t:currentCodeFlow.numberSteps = 0
    call s:Flow.savePrevStatusLine()
    call s:Flow.updateStatusLine()
endfunction
" }}}

" function! s:isFlowActive() {{{1
function! s:Flow.isFlowActive() abort
    return exists("t:currentCodeFlow")
endfunction
" }}}

" function! s:Flow.checkActiveFlow() {{{1
function! s:Flow.checkActiveFlow() abort
    try
        if !s:Flow.isFlowActive()
            throw "No Active Flow"
        endif
    catch /\v^No/
        throw "No active flow"
    endtry
endfunction
" }}}

" function! s:Flow.insertStep() {{{1
function! s:Flow.insertStep() abort
    call s:Flow.checkActiveFlow()

    " create new step
    let newStep = {}

    let newStep.file = expand("%")
    let newStep.lineNumber = line(".")
    let newStep.description = input("Please describe this step\n")

    " add new step to the current flow
    call insert(t:currentCodeFlow.steps, copy(newStep), t:currentCodeFlow.currentStep)
    let t:currentCodeFlow.currentStep += 1
    let t:currentCodeFlow.numberSteps += 1
    call s:Flow.updateStatusLine()
endfunction
" }}}

" function! s:Flow.addStep() {{{1
function! s:Flow.addStep() abort
    call s:Flow.checkActiveFlow()

    " add new step to the current flow
    let t:currentCodeFlow.currentStep = t:currentCodeFlow.numberSteps
    call s:Flow.insertStep()
endfunction
" }}}

" function! s:Flow.goToStep(stepIndex) {{{1
function! s:Flow.goToStep(stepIndex) abort
    call s:Flow.checkActiveFlow()

    if !a:stepIndex
        echoerr "No flow index given"
        return
    endif

    if a:stepIndex > t:currentCodeFlow.numberSteps
        echoerr "Out of flow range"
        return
    endif

    let t:currentCodeFlow.currentStep = a:stepIndex
    let currentStep = t:currentCodeFlow.steps[t:currentCodeFlow.currentStep - 1]
    if bufnr(currentStep.file) !=# -1
        execute "buffer " . fnameescape(currentStep.file)
    else 
        execute "edit " . fnameescape(currentStep.file)
    endif
    execute ":" . currentStep.lineNumber
    call s:Flow.updateStatusLine()
endfunction

" }}}

" function! s:Flow.updateStep() {{{1
function! s:Flow.updateStep(shouldAdvance) abort
    call s:Flow.checkActiveFlow()

    " Update step
    let currentFile = expand("%")
    let currentLineNumber = line(".")
    let stepDesc = input("Please describe this step\n")

    " update new data to current step
    let newStep = t:currentCodeFlow.steps[t:currentCodeFlow.currentStep - 1]
    let newStep.file = currentFile
    let newStep.lineNumber = currentLineNumber
    let newStep.description = stepDesc
    if a:shouldAdvance ==# 1
        call s:Flow.goToStep(t:currentCodeFlow.currentStep + 1)
    endif
endfunction
" }}}

" function! s:Flow.deleteStep() {{{1
function! s:Flow.deleteStep() abort
    call s:Flow.checkActiveFlow()

    if !t:currentCodeFlow.numberSteps
        echoerr "No flow steps"
        return
    endif

    call remove(t:currentCodeFlow.steps, t:currentCodeFlow.currentStep - 1)
    if t:currentCodeFlow.currentStep == t:currentCodeFlow.numberSteps
        let t:currentCodeFlow.currentStep -= 1
    endif
    let t:currentCodeFlow.numberSteps -= 1
    call s:Flow.updateStatusLine()
endfunction

" }}}

" function! s:Flow.nextStep() {{{1
function! s:Flow.nextStep() abort
    " check for active flow
    " check if we are at the last step
    call s:Flow.checkActiveFlow()
    if t:currentCodeFlow.currentStep == t:currentCodeFlow.numberSteps
        echo "At the last step"
        return
    endif
    " we are not at the last step
    " go to the next one
    call s:Flow.goToStep(t:currentCodeFlow.currentStep + 1)
endfunction

" }}}

" function! s:Flow.prevStep() {{{1
function! s:Flow.prevStep() abort
    " check for active flow
    " check if we are at the last step
    call s:Flow.checkActiveFlow()
    if t:currentCodeFlow.currentStep ==# 1
        echo "At the first step for current flow"
        return
    endif
    " we are not at the last step
    " go to the next one
    call s:Flow.goToStep(t:currentCodeFlow.currentStep - 1)
endfunction

" }}}

" function! s:Flow.saveFlow() {{{
function! s:Flow.saveFlow() abort
    call s:Flow.checkActiveFlow()

    " clear flow file
    execute "pedit " . t:currentCodeFlow.file
    execute "wincmd k"
    normal! ggVGx
    setlocal bufhidden=hide
    setlocal nobuflisted
    " write file, line number and description for each step
    for step in t:currentCodeFlow.steps
        execute "normal! i" . step.file . "\n"
        execute "normal! i" . step.lineNumber . "\n"
        execute "normal! i" . step.description . "\n"
    endfor
    " Delete the last empty line
    normal! Gdd
    execute "wq"
endfunction
" }}}

" function! s:Flow._openFlow(name) {{{1
function! s:Flow._openFlow(name) abort
    if s:Flow.isFlowActive()
        call s:Flow.closeFlow()
    endif

    let file = ".flow" . codeflow#slash() . a:name . ".flow"
    if getftype(file) !=# "file"
        echoerr "No flow with name " . a:name
        return
    endif

    let t:currentCodeFlow = {}
    let t:currentCodeFlow.name = a:name
    let t:currentCodeFlow.file =
                \ ".flow" . codeflow#slash()
                \ . t:currentCodeFlow.name . ".flow"
    let t:currentCodeFlow.steps = []
    let t:currentCodeFlow.currentStep = 0
    let t:currentCodeFlow.numberSteps = 0

    " Read flow file
    execute "pedit " . t:currentCodeFlow.file
    execute "wincmd k"
    setlocal bufhidden=hide
    setlocal nobuflisted

    let numberLines = line("$")
    let currentLine = 1
    if currentLine == numberLines
        silent execute "wq"
        call s:Flow.savePrevStatusLine()
        call s:Flow.updateStatusLine()
        return
    endif

    let newStep = {}
    while currentLine <= numberLines
        let currentLineText = getline(currentLine)
        if currentLine % 3 == 1
            let newStep.file = currentLineText
        elseif currentLine % 3 == 2
            let newStep.lineNumber = currentLineText
        elseif currentLine % 3 == 0
            let newStep.description = currentLineText
            call add(t:currentCodeFlow.steps, copy(newStep))
        endif
        let currentLine += 1
    endwhile
    silent execute "wq"

    " Go to first step
    let t:currentCodeFlow.currentStep = 1
    let t:currentCodeFlow.numberSteps = numberLines / 3
    call s:Flow.savePrevStatusLine()
    call s:Flow.updateStatusLine()
    call s:Flow.goToStep(t:currentCodeFlow.currentStep)
endfunction
" }}}

" function! OpenFlowCompletion() {{{1
" This is global to be in scope for input()
function! OpenFlowCompletion(lead, line, position) abort
    " if user has entered text, complete what they have written
    let flows = glob(".flow" . codeflow#slash() . "*.flow", 0, 1)
    call map(flows, {_, val -> fnamemodify(val, ":t:r")})
    call map(flows, {_, val -> fnameescape(val)})
    if len(a:line)
        return matchfuzzy(flows, a:line)
    else 
        return flows
    endif
endfunction

" }}}

" function! s:Flow.openFlow() {{{1
function! s:Flow.openFlow() abort
    let chosenFlow = input(
                \ "Please give flow name\n",
                \ "",
                \ "customlist,OpenFlowCompletion")
    if !len(chosenFlow)
        echoerr "no flow given"
        return
    endif

    call s:Flow._openFlow(chosenFlow)
endfunction
" }}}

" function! s:Flow.closeFlow() {{{1
function! s:Flow.closeFlow() abort
    call s:Flow.checkActiveFlow()
    call s:Flow.saveFlow()
    " free and unlet to return to inactive flow state
    unlet t:currentCodeFlow.name
    unlet t:currentCodeFlow.file
    unlet t:currentCodeFlow.steps
    unlet t:currentCodeFlow.currentStep
    unlet t:currentCodeFlow.numberSteps
    unlet t:currentCodeFlow

    " Restore previous state
    let &statusline = t:previousStatusLine['statusline']
    let &laststatus = t:previousStatusLine['laststatus']
    unlet t:previousStatusLine
endfunction

" }}}
