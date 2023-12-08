let s:Window = {}
let g:CodeflowWindow = s:Window

" function! s:Window.New() {{{1
function! s:Window.New() abort
    echom "window new "
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

    " TODO(Mitchell): active the bindings here
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
        echom "there is no flow window buffer name"
        return
    endif

    let bufferNumber = bufnr(t:flowWwindowBufferName)
    "if &hidden is not set then it will already be gone
    " we have a buffer with this name
    if bufferNumber != -1

        "nerdtree buf may be mirrored/displayed elsewhere
        "why do we need to do this
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

" TODO(Mitchell): change based on active flow 
" function! s:Window.setCodeflowWindowStatusLine() {{{1
function! s:Window.setCodeflowWindowStatusLine() abort
    let &l:statusline = "Flows for " . getcwd()
endfunction
" }}}

" function! s:Window.setCodeflowWindowOptions() {{{1
function! s:Window.setCodeflowWindowOptions() abort
    " control buffer options
    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal filetype=flow

    " TODO(Mitchell): bind the mappings for the opening stuff here
    call self.setCodeflowWindowStatusLine()
endfunction
" }}}

" function! s:Window.getFlows() {{{1
function! s:Window.getFlows() abort
    let globExpression = '.flow/*.flow'
    let flows = glob(globExpression, 0, 1)
    let index = 0
    while index < len(flows)
        let flows[index] = fnamemodify(flows[index], ':t:r')
        let index += 1
    endwhile
    return flows
endfunction
" }}}

" function s:Window.render() {{{1
function! s:Window.render() abort
    call self.ui.render()
endfunction
" }}}

" TODO(Mitchell): check flow state
" function s:Window.renderToString() {{{1
function! s:Window.renderToString() abort
    let returnString = ""
    for flow in self.flows
        let returnString .= flow . "\n"
    endfor
    return returnString
endfunction
"}}} 

" function s:Window.createWindowData() {{{1
function! s:Window.createWindowData() abort
    let newWindowData = copy(self)
    let newWindowData.ui = g:CodeflowUI.New(newWindowData)
    let newWindowData.flowFolder = getcwd() . codeflow#slash() . ".flow"
    let newWindowData.flows = s:Window.getFlows()
    echo newWindowData
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

" TODO(Mitchell):
" function! s:Window.GetSelected() {{{1
function! s:Window.GetSelected() abort
    let newObject = {}
    echom "window get selected"
    if !exists('t:currentCodeFlow')
        echom "window get selected no current code flow"
        " get the file
        let flowFile = ".flow" . codeflow#slash() . getline('.') . ".flow"
        if !empty(glob(flowFile))
            let newObject.isFlow = 1
            let newObject.flowFile = flowFile
            let newObject.flowName = getline('.')
        else 
            let newObject.isFlow = 0
        endif
    else
        " TODO(Mitchell): implement selecting step
        let newObject.isStep = 0
    endif
    return newObject
endfunction
" }}}

" function! s:Window.CloseCodeflowWindow() abort
function! s:Window.CloseCodeflowWindow() abort
    if s:Window.ExistsForTab()
        call s:Window.Close()
        call s:Window.cleanUpFlowWindow()
    endif
endfunction
" TODO(Mitchell): check for existing flow folder
" function! s:Window.CreateCodeflowWindow() {{{1
function! s:Window.CreateCodeflowWindow() abort
    " TODO(Mitchell): after basic flow window implementation
    " refactor to match basic features needed
    echom "internal create Flow Window"
    if s:Window.ExistsForTab()
        call s:Window.Close()
        call s:Window.cleanUpFlowWindow()
    endif

    call s:Window.createWindow()
    let b:flowWindow = s:Window.createWindowData()
    call b:flowWindow.render()
endfunction
" }}}




