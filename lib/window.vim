let s:Window = {}
let g:CodeflowWindow = s:Window

" fun s:Window.cleanFlowWindowBuffer() {{{1
function! s:Window.cleanFlowWindowBuffer() abort
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
" fun s:Window.createDrawerWindow() {{{1
function! s:Window.createDrawerWindow() abort
    if !codeflow#checkFlowFolder()
        return
    endif

    if s:Window.existsForTab()
        call s:Window.close()
        call s:Window.cleanFlowWindowBuffer()
    endif

    call s:Window.createWindow()
    let b:codeflowWindow = s:Window.createWindowData("drawer")
    call b:codeflowWindow.render()
endfunction
" }}}
" fun s:Window.createExplorerWindow() {{{1
function! s:Window.createExplorerWindow() abort
    let previousBuf = expand('#')

    "we need a unique name for each window tree buffer to ensure they are
    "all independent
    exec 'silent keepalt keepjumps edit ' .. s:Window.nextBufferName()

    let b:codeflowWindow = s:Window.createWindowData("explorer")
    let b:codeflowWindow.previousBuf = bufnr(previousBuf)
    call s:Window.setCodeflowWindowOptions()
    setlocal bufhidden=wipe

    call b:codeflowWindow.render()
endfunction
" }}}
" fun s:Window.createWindow() {{{1
function! s:Window.createWindow() abort
    let l:splitLocation = g:CodeflowWinPos ==# 'left'
                \ || g:CodeflowWinPos ==# 'top' ? 'topleft ' : 'botright '
    let l:splitDirection = g:CodeflowWinPos ==# 'left'
                \ || g:CodeflowWinPos ==# 'right' ? 'vertical' : ''
    let l:splitSize = g:CodeflowWinSize

    if !s:Window.existsForTab()
        let t:flowWindowBufferName = self.nextBufferName()
        silent! execute l:splitLocation . l:splitDirection . ' ' . l:splitSize
                    \ . ' new'
        silent! execute 'edit ' . t:flowWindowBufferName
        silent! execute l:splitDirection . ' resize '. l:splitSize
    else
        silent! execute l:splitLocation . l:splitDirection . ' ' . l:splitSize
                    \ . ' split'
        silent! execute 'buffer ' . t:flowWindowBufferName
    endif

    setlocal winfixwidth

    call self.setCodeflowWindowOptions()
endfunction
" }}}
" fun s:Window.createWindowData(type) {{{1
function! s:Window.createWindowData(type) abort
    let newWindowData = copy(self)
    let newWindowData.ui = g:CodeflowUI.new(newWindowData)
    let newWindowData.type = a:type
    let newWindowData.flowFolderPath = s:Window.getFlowFolderPath()
    " TODO(Mitchell): change all the flow folder stuff to be the root here
    let newWindowData.flows = s:Window.getFlows()
    return newWindowData
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
" fun s:Window.isDrawerWindow() {{{1
function! s:Window.isDrawerWindow() abort
    return self.type ==# "drawer"
endfunction

" }}}
" fun s:Window.New() {{{1
function! s:Window.New() abort
    let newWindow = copy(self)
    return newWindow
endfunction
" }}}
" fun s:Window.nextBufferName() {{{1
function! s:Window.nextBufferName() abort
    return self.nextBufferPrefix() . self.nextBufferNumber()
endfunction
" }}}
" fun s:Window.nextBufferNumber() {{{1
function! s:Window.nextBufferNumber() abort
    if !exists('s:Window.bufferNumber')
        let s:Window.bufferNumber = 1
    else 
        let s:Window.bufferNumber += 1
    endif

    return s:Window.bufferNumber
endfunction
" }}}
" fun s:Window.nextBufferPrefix() {{{1
function! s:Window.nextBufferPrefix() abort
    return 'flow_window_'
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
    set wrap
    set linebreak

    " view options
    set cursorline
    if has('patch-7.4.1925')
        clearjumps
    endif
    call g:CodeflowKeyMap.BindAll()
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
" fun s:Window.getFlowFolderPath() {{{1
function! s:Window.getFlowFolderPath() abort
    let dir = getcwd()
    let path = g:CodeflowPath.New(dir)
    return path
endfunction
" }}}
" fun s:Window.cursorToFlowWindow() {{{1
function! s:Window.cursorToFlowWindow() abort
    if !s:Window.isOpen()
        throw "Codeflow Window not open"
    endif
    execute s:Window.getWinNumber() . "wincmd w"
endfunction
" }}}
" fun s:Window.focus {{{1
function! s:Window.focus() abort
    if s:Window.isOpen()
        call s:Window.cursorToFlowWindow()
    else
        call s:Window.createDrawerWindow()
    endif
endfunction
" }}} 
" fun s:Window.rerender() {{{1
function! s:Window.rerender() abort
    let currentWindow = winnr()
    for w in range(1,winnr('$'))
        if bufname(winbufnr(w)) =~# '^' . g:CodeflowWindow.nextBufferPrefix() . '\d\+$'
            silent execute w .. "wincmd w"
            let b:codeflowWindow.flows = g:CodeflowWindow.getFlows()
            call b:codeflowWindow.render()
        endif
    endfor

    if s:Window.isOpen()
        call s:Window.cursorToFlowWindow()
        let b:codeflowWindow.flows = g:CodeflowWindow.getFlows()
        call b:codeflowWindow.render()
    endif
    silent! execute currentWindow .. "wincmd w"
endfunction
" }}}
" fun s:Window.render() {{{1
function! s:Window.render() abort
    call self.ui.render()
endfunction
" }}}
" fun s:Window.getPathHeader() {{{1
function! s:Window.getPathHeader() abort
    let pathHeader = b:codeflowWindow.flowFolderPath.stringForUI()
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
        let returnString .= "|" . t:currentCodeFlow.name . "\n\n"
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
" fun s:Window.existsForTab() {{{1
function! s:Window.existsForTab() abort
    if !exists("t:flowWindowBufferName")
        return
    endif

    return !empty(getbufvar(bufnr(t:flowWindowBufferName), "codeflowWindow"))
endfunction
" }}}
" fun s:Window.getWinNumber() {{{1
function! s:Window.getWinNumber() abort
    if exists('t:flowWindowBufferName')
        return bufwinnr(t:flowWindowBufferName)
    endif
    " If WindowWindow, there is no t:flowWindowBufferName variable. Search all windows.
    for w in range(1,winnr('$'))
        if bufname(winbufnr(w)) =~# '^' . g:CodeflowWindow.nextBufferPrefix() . '\d\+$'
            return w
        endif
    endfor

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
        let newObject.isGeneral = 1
        return newObject
    endif

    if !exists('t:currentCodeFlow')
        return g:CodeflowFlowNode.GetSelected(b:codeflowWindow)
    else
        return g:CodeflowStepNode.GetSelected(b:codeflowWindow)
    endif

    return newObject
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
                call b:codeflowWindow.render()
            endif
            call b:codeflowWindow.ui.restoreScreenState()
        else
            call s:Window.close()
        endif
    else
        call s:Window.createDrawerWindow()
    endif
endfunction
" }}
