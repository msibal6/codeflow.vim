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

    if !g:Codeflow.ExistsForTab()
        let t:flowWindowBufferName = self.nextBufferName()
        silent! execute 'topleft  vertical 20 new'
        silent! execute 'edit ' . t:flowWindowBufferName
    else
        silent! execute 'topleft vertical 20 split'
        silent! execute 'buffer ' . t:flowWindowBufferName
    endif

    setlocal winfixwidth

    call self.setCodeflowWindowOptions()
endfunction
" }}}

" function! s:Window.isBufferHidden(bufferNumber) {{{1
function! s:Window.isBufferHidden(bufferNumber)
    redir => buffers
    silent ls!
    redir END

    return buffers =~ a:bufferNumber . "..h"
endfunction

" }}}

" function! s:Window.cleanUpFlowWindow() {{{1
function! s:Window.cleanUpFlowWindow()
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

"TODO(Mitchell):
" do I like the buffer local flowWindow variable
" function s:Window.createWindowData() {{{1
function! s:Window.createWindowData() abort
    let b:flowWindow = g:Codeflow.New()
    let b:flowWindow.test = 'test'
endfunction
" }}}

" function! s:Window.createFlowWindow() {{{1
" TODO(Mitchell): implement
function! s:Window.createFlowWindow() abort
    " TODO(Mitchell): after basic flow window implementation
    " refactor to match basic features needed
    echom "internal create Flow Window"
    if g:Codeflow.ExistsForTab()
        call g:Codeflow.Close()
        call self.cleanUpFlowWindow()
    endif

    call self.createWindow()
    call self.createWindowData()
endfunction
" }}}

" function! s:Window.CreateFlowWindow() {{{1
function! s:Window.CreateFlowWindow() abort
    echom " external create flow Window"
    let window = s:Window.New()
    call window.createFlowWindow()
endfunction
" }}}



