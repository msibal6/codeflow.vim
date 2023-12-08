let s:Window = {}
let g:CodeflowWindow = s:Window

" fun s:Window.cleanUpFlowWindow() {{{1
function! s:Window.cleanUpFlowWindow() abort
    if !exists(t:flowWindowBufferName)
        return
    endif

    let bufferNumber = bufnr(t:flowWwindowBufferName)
    "if &hidden is not set then it will already be gone
    " we have a buffer with this name
    if bufferNumber != -1
        "codeflow window buf may be mirrored/displayed elsewhere
        if self.isBufferHidden(bufferNumber)
            exec 'bwipeout ' . bufferNumber
        endif
    endif

    unlet t:flowWindowBufferName
endfunction
" }}}

" fun s:Window.createWindow() {{{1
function! s:Window.createWindow() abort
    if !s:Window.existsForTab()
        let t:flowWindowBufferName = self.nextBufferName()
        silent! execute 'topleft  vertical 20 new'
        silent! execute 'edit ' . t:flowWindowBufferName
    else
        silent! execute 'topleft vertical 20 split'
        silent! execute 'buffer ' . t:flowWindowBufferName
    endif

    setlocal winfixwidth

    call g:CodeflowKeyMap.BindAll()
    call self.setCodeflowWindowOptions()
endfunction
" }}}

" fun s:Window.new() {{{1
function! s:Window.new() abort
    let newWindow = copy(self)
    return newWindow
endfunction
" }}}

" fun s:Window.isBufferHidden(bufferNumber) {{{1
function! s:Window.isBufferHidden(bufferNumber) abort
    redir => buffers
    silent ls!
    redir END

    return buffers =~ a:bufferNumber . "..h"
endfunction

" }}}

" fun s:Window.nextBufferPrefix() {{{1
function! s:Window.nextBufferPrefix() abort
    return 'flow_window_'
endfunction
" }}}

" fun s:Window.bufferNumber() {{{1
function! s:Window.nextBufferNumber() abort
    if !exists('s:Window.bufferNumber')
        let s:Window.bufferNumber = 1
    else 
        let s:Window.bufferNumber += 1
    endif

    return s:Window.bufferNumber
endfunction
" }}}

" fun s:Window.nextBufferName() {{{1
function! s:Window.nextBufferName() abort
    return self.nextBufferPrefix() . self.nextBufferNumber()
endfunction
" }}}

" fun s:Window.setCodeflowWindowStatusLine() {{{1
function! s:Window.setCodeflowWindowStatusLine() abort
    let &l:statusline = getcwd()
endfunction
" }}}

" fun s:Window.setCodeflowWindowOptions() {{{1
function! s:Window.setCodeflowWindowOptions() abort
    " control buffer options
    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal filetype=codeflow
    if has('patch-7.4.1925')
        clearjumps
    endif
    call self.setCodeflowWindowStatusLine()
endfunction
" }}}

" fun s:Window.getFlows() {{{1
function! s:Window.getFlows() abort
    let globExpression = ".flow" . codeflow#slash() . "*.flow"
    let flows = glob(globExpression, 0, 1)
    let index = 0
    while index < len(flows)
        let flows[index] = flows[index]->fnamemodify(":t:r")
        let index += 1
    endwhile
    return flows
endfunction
" }}}

" fun s:Window.cursorToFlowWindow() {{{1
function! s:Window.cursorToFlowWindow()
    if !s:Window.isOpen()
        throw "Codeflow Window not open"
    endif
    execute s:Window.getWinNumber() . "wincmd w"
endfunction
" }}}

" fun s:Window.focus {{{1
function! s:Window.focus()
    if s:Window.isOpen()
        call s:Window.cursorToFlowWindow()
    else
        call s:Window.createCodeflowWindow()
    endif
endfunction
" }}} 

" fun s:Window.rerender() {{{1
function! s:Window.rerender() abort
    if s:Window.isOpen()
        call s:Window.cursorToFlowWindow()
        let b:flowWindow.flows = g:CodeflowWindow.getFlows()
        call b:flowWindow.render()
        execute "wincmd p"
    endif
endfunction
" }}}

" fun s:Window.render() {{{1
function! s:Window.render() abort
    call self.ui.render()
endfunction
" }}}

" fun s:Window.getPathHeader() {{{1
function! s:Window.getPathHeader() abort
    let pathHeader = getcwd()
    let limit = winwidth(0) - 1
    if strdisplaywidth(pathHeader) > limit
        while strdisplaywidth(pathHeader) > limit && strchars(pathHeader) > 0
            let pathHeader = substitute(pathHeader, '^.', '', '')
        endwhile
        if len(split(pathHeader, '/')) > 1
            let pathHeader = '</' . join(split(pathHeader, '/')[1:], '/') . '/'
        else
            let pathHeader = '<' . pathHeader
        endif
    endif
    return pathHeader
endfunction
" }}}

" fun s:Window.renderToString() {{{1
function! s:Window.renderToString() abort
    let returnString = ""
    if !exists("t:currentCodeFlow")
        let returnString .= "Flows for\n"
        let returnString .= s:Window.getPathHeader() . "\n\n"
        for flow in self.flows
            let returnString .= flow . "\n"
        endfor
    else
        let returnString .= "Steps for\n"
        let returnString .= t:currentCodeFlow.name . "\n\n"
        let steps = t:currentCodeFlow.steps
        let index = 0
        while index < len(steps)
            if (t:currentCodeFlow.currentStep ==# index + 1)
                let returnString .= "+"
            endif

            let returnString .= (index + 1) . ") ". steps[index].description . "\n"
            let index += 1
        endwhile
    endif
    return returnString
endfunction
"}}}

" fun s:Window.createWindowData() {{{1
function! s:Window.createWindowData() abort
    let newWindowData = copy(self)
    let newWindowData.ui = g:CodeflowUI.new(newWindowData)
    let newWindowData.flowFolder = getcwd() . codeflow#slash() . ".flow"
    let newWindowData.flows = s:Window.getFlows()
    return newWindowData
endfunction
" }}}

" fun s:Window.existsForTab() {{{1
function! s:Window.existsForTab() abort
    if !exists("t:flowWindowBufferName")
        return
    endif

    return !empty(getbufvar(bufnr(t:flowWindowBufferName), "flowWindow"))
endfunction
" }}}

" fun s:Window.getWinNumber() {{{1
function! s:Window.getWinNumber() abort
    if exists('t:flowWindowBufferName')
        return bufwinnr(t:flowWindowBufferName)
    endif
    return -1
endfunction
" }}} 

" fun s:Window.close() {{{1
function! s:Window.close() abort
    if !s:Window.isOpen()
        return
    endif

    if winnr('$') !=# 1
        if winnr() ==# s:Window.getWinNumber()
            execute "wincmd p"
            let l:activeBuffer =  bufnr('')
            execute "wincmd p"
        else
            let l:activeBuffer =  bufnr('')
        endif

        execute s:Window.getWinNumber() . ' wincmd w'
        close
        execute bufwinnr(l:activeBuffer) . ' wincmd w'
    else
        close
    endif
endfunction
" }}}

" fun s:Window.isOpen() {{{1
function! s:Window.isOpen() abort
    return s:Window.getWinNumber() != -1
endfunction
" }}}

" fun s:Window.getSelected() {{{1
" returns node object for selected step or flow
" returns empty object if there is no node to be selected
function! s:Window.getSelected() abort
    let newObject = {}
    let lineNumber = line('.')

    if lineNumber < 4
        return {}
    endif

    if !exists('t:currentCodeFlow')

        " check for a flow node
        let file = ".flow" . codeflow#slash() . getline('.') . ".flow"
        " get the file
        if !empty(glob(file))
            let newObject.isFlow = 1
            let newObject.file = file
            let newObject.name = getline('.')
        endif
    else
        let newObject.isStep = 1
        let newObject.stepIndex = lineNumber - 3
    endif

    return newObject
endfunction
" }}}

" fun s:Window.createCodeflowWindow() {{{1
function! s:Window.createCodeflowWindow() abort
    if !codeflow#checkFlowFolder()
        return
    endif

    if s:Window.existsForTab()
        call s:Window.close()
        call s:Window.cleanUpFlowWindow()
    endif

    call s:Window.createWindow()
    let b:flowWindow = s:Window.createWindowData()
    call b:flowWindow.render()
endfunction
" }}}

" fun s:Window.toggle() {{{1
function! s:Window.toggle() abort
    " we exists for the the tab
    if s:Window.existsForTab()
        " we are not open 
        if !s:Window.isOpen()
            call s:Window.createWindow()
            " we are not hidden
            if !&hidden
                call b:flowWindow.render()
            endif
            call b:flowWindow.ui.restoreScreenState()
        else
            call s:Window.close()
        endif
    else
        call s:Window.createCodeflowWindow()
    endif
endfunction
" }}}
