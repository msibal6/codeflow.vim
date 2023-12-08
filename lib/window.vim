let s:Window = {}
let g:CodeflowWindow = s:Window

" function! s:Window.New() {{{1
function! s:Window.New() abort
    let newWindow = copy(self)
    return newWindow
endfunction
" }}}

"function! s:Window.createWindow() {{{1
function! s:Window.createWindow() abort
    if !s:Window.ExistsForTab()
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

" function! s:Window.isBufferHidden(bufferNumber) {{{1
function! s:Window.isBufferHidden(bufferNumber) abort
    redir => buffers
    silent ls!
    redir END

    return buffers =~ a:bufferNumber . "..h"
endfunction

" }}}

" function! s:Window.cleanUpFlowWindow() {{{1
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

" function! s:Window.bufferPrefix() {{{1
function! s:Window.bufferPrefix() abort
    return 'flow_window_'
endfunction
" }}}

" function! s:Window.nextBufferNumber() {{{1
function! s:Window.getNextBufferNumber() abort
    if !exists('s:Window.nextBufferNumber')
        let s:Window.nextBufferNumber = 1
    else 
        let s:Window.nextBufferNumber += 1
    endif

    return s:Window.nextBufferNumber
endfunction
" }}}

" function! s:Window.nextBufferName() {{{1
function! s:Window.nextBufferName() abort
    return self.bufferPrefix() . self.getNextBufferNumber()
endfunction
" }}}

" function! s:Window.setCodeflowWindowStatusLine() {{{1
function! s:Window.setCodeflowWindowStatusLine() abort
    let &l:statusline = getcwd()
endfunction
" }}}

" function! s:Window.setCodeflowWindowOptions() {{{1
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

" function! s:Window.getFlows() {{{1
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

" function! s:Window.cursorToFlowWindow() {{{1
function! s:Window.cursorToFlowWindow()
    if !s:Window.IsOpen()
        throw "Codeflow Window not open"
    endif
    execute s:Window.GetWinNumber() . "wincmd w"
endfunction
" }}}

" function! s:Window.Focus {{{1
function! s:Window.Focus()
    if s:Window.IsOpen()
        call s:Window.cursorToFlowWindow()
    else
        call s:Window.CreateCodeflowWindow()
    endif
endfunction
" }}} 

" function s:Window.Render() {{{1
function! s:Window.Render() abort
    if s:Window.IsOpen()
        call s:Window.cursorToFlowWindow()
        let flowWindow = getbufvar(bufnr(t:flowWindowBufferName), "flowWindow")
        " focus it
        call flowWindow.render()
        " go back to the 
        execute "wincmd p"
    endif
endfunction
" }}}

" function s:Window.render() {{{1
function! s:Window.render() abort
    call self.ui.render()
endfunction
" }}}

" function! s:Window.getPathHeader() {{{1
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

" function s:Window.renderToString() {{{1
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

" function s:Window.createWindowData() {{{1
function! s:Window.createWindowData() abort
    let newWindowData = copy(self)
    let newWindowData.ui = g:CodeflowUI.New(newWindowData)
    let newWindowData.flowFolder = getcwd() . codeflow#slash() . ".flow"
    let newWindowData.flows = s:Window.getFlows()
    return newWindowData
endfunction
" }}}

" function s:Window.ExistsForTab() {{{1
function! s:Window.ExistsForTab() abort
    if !exists("t:flowWindowBufferName")
        return
    endif

    return !empty(getbufvar(bufnr(t:flowWindowBufferName), "flowWindow"))
endfunction
" }}}

" function s:Window.GetWinNumber() {{{1
function! s:Window.GetWinNumber() abort
    if exists('t:flowWindowBufferName')
        return bufwinnr(t:flowWindowBufferName)
    endif
    return -1
endfunction
" }}} 

" function! s:Window.Close() {{{1
function! s:Window.Close() abort
    if !s:Window.IsOpen()
        return
    endif

    if winnr('$') !=# 1
        if winnr() ==# s:Window.GetWinNumber()
            execute "wincmd p"
            let l:activeBuffer =  bufnr('')
            execute "wincmd p"
        else
            let l:activeBuffer =  bufnr('')
        endif

        execute s:Window.GetWinNumber() . ' wincmd w'
        close
        execute bufwinnr(l:activeBuffer) . ' wincmd w'
    else
        close
    endif
endfunction
" }}}

" function s:Window.IsOpen() {{{1
function! s:Window.IsOpen() abort
    return s:Window.GetWinNumber() != -1
endfunction
" }}}

" function! s:Window.GetSelected() {{{1
" returns node object for selected step or flow
" returns empty object if there is no node to be selected
function! s:Window.GetSelected() abort
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

" function! s:Window.CloseCodeflowWindow() abort {{{1
function! s:Window.CloseCodeflowWindow() abort
    if s:Window.ExistsForTab()
        call s:Window.Close()
        call s:Window.cleanUpFlowWindow()
    endif
endfunction
" }}}

" function! s:Window.CreateCodeflowWindow() {{{1
function! s:Window.CreateCodeflowWindow() abort
    if !codeflow#checkFlowFolder()
        return
    endif

    if s:Window.ExistsForTab()
        call s:Window.Close()
        call s:Window.cleanUpFlowWindow()
    endif

    call s:Window.createWindow()
    let b:flowWindow = s:Window.createWindowData()
    call b:flowWindow.render()
endfunction
" }}}
