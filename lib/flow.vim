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
    " TODO(Mitchell): change name to name
    execute "set statusline+=%10(" . t:currentCodeFlow.name . "%)"
    execute "set statusline+=\\ %2{". t:currentCodeFlow.currentStep . "}/"
    execute "set statusline+=%2{". t:currentCodeFlow.numberSteps. "}"
endfunction
" }}}

" function! s:Flow.startFlow() {{{1
function! s:Flow.startFlow() abort
    " TODO(Mitchell): check if the .flow folder exists in the file system
    " right now only checks if there is something called .flow
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

    " create new code flow
    let t:currentCodeFlow = {}
    " TODO(Mitchell) : check for invalid file names
    let t:currentCodeFlow.name = input("Please give flow name\n")
    let t:currentCodeFlow.file = ".flow/" . t:currentCodeFlow.name . ".flow"
    execute "pedit " . t:currentCodeFlow.file
    " TODO(Mitchell): change flow buffer settings to be unlisted
    " we will stil need a swap file as we do write to it though
    execute "wincmd k"
    silent execute "wq"

    " TODO(Mitchell): find duplicates of new state
    " this means that we are opening a new flow while one is already open
    " we will be saving the one in progress if desired
    " empty list for steps
    let t:currentCodeFlow.steps = []
    let t:currentCodeFlow.currentStep = 0
    let t:currentCodeFlow.numberSteps = 0
    call s:Flow.savePrevStatusLine()
    call s:Flow.updateStatusLine()
endfunction
" }}}

" function! s:Flow.addStep() {{{1
function! s:Flow.checkActiveFlow() abort
    try
        if !exists("t:currentCodeFlow")
            throw "No Active Flow"
        endif
    catch /\v^No/
        throw "No active flow"
    endtry
endfunction
" }}}

" function! s:Flow.addStep() {{{1
function! s:Flow.addStep() abort
    call s:Flow.checkActiveFlow()

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
    call insert(t:currentCodeFlow.steps, copy(newStep), t:currentCodeFlow.currentStep)

    let t:currentCodeFlow.currentStep += 1
    let t:currentCodeFlow.numberSteps += 1
    call s:Flow.updateStatusLine()
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
    " TODO(Mitchell): check if we already have this open and use buffer to
    " prevent reloading the same file that we are already on
    execute "edit " . fnameescape(currentStep[0])
    execute ":" . currentStep[1]
    call s:Flow.updateStatusLine()
endfunction

" }}}

" function! s:Flow.updateStep() {{{1
function! s:Flow.updateStep() abort
    call s:Flow.checkActiveFlow()

    " Update step
    let currentFile = expand("%")
    let currentLineNumber = line(".")
    let stepDesc = input("Please describe this step\n")

    " update new data to current step
    let newStep = t:currentCodeFlow.steps[t:currentCodeFlow.currentStep - 1]
    let newStep[0] = currentFile
    let newStep[1] = currentLineNumber
    let newStep[2] = stepDesc
    call s:Flow.updateStatusLine()
endfunction
" }}}

" function! s:Flow.removeStep() {{{1
function! s:Flow.removeStep() abort
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

" function! s:Flow.saveFlow() {{{1
function! s:Flow.saveFlow() abort
    call s:Flow.checkActiveFlow()

    " clear flow file
    execute "pedit " . t:currentCodeFlow.file
    execute "wincmd k"
    normal! ggVGx
    " write file, line number and description for each step
    " TODO(Mitchell): create hidden buffer to hide buffer listing and it does not have a swap file 
    " TODO(Mitchell): test out put and set line to if they are better
    for step in t:currentCodeFlow.steps
        execute "normal! i" . step[0] . "\n"
        execute "normal! i" . step[1] . "\n"
        execute "normal! i" . step[2] . "\n"
    endfor
    " Delete the last empty line
    normal! Gdd
    execute "wq"
endfunction
" }}}

" function! s:Flow._openFlow(name) {{{1
function! s:Flow._openFlow(name) abort
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
    let numberLines = line("$")
    let currentLine = 1
    " TODO(Mitchell): replace with dictionary to make indexing more clear
    let newStep = []

    while currentLine <= numberLines
        let currentLineText = getline(currentLine)
        call add(newStep, currentLineText)
        if currentLine % 3 == 0
            " TODO(Mitchell): replace deepcopy with copy as test
            call add(t:currentCodeFlow.steps, deepcopy(newStep))
            let newStep = []
        endif
        let currentLine += 1
    endwhile
    execute "wq"

    " Go to first step
    let t:currentCodeFlow.currentStep = 1
    " TODO(Mitchell): replace with step function about number of step
    " MITCHNOTE: this might not work as you implement different levels of
    " steps
    let t:currentCodeFlow.numberSteps = numberLines / 3
    call s:Flow.savePrevStatusLine()
    call s:Flow.updateStatusLine()
    call s:Flow.goToStep(t:currentCodeFlow.currentStep)
endfunction
" }}}

" function! s:Flow.openFlow() {{{1
function! s:Flow.openFlow() abort
    let chosenFlow = input("Please give flow name\n")

    if !len(chosenFlow)
        echoerr "no flow given"
        return
    endif
    " TODO(Mitchell): check if we already have another flow going
    " TODO(Mitchell): add all the checking
    " it is much faster to implement when you know all the input that can be
    " given for a certain function
    " the real world is much harder
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
