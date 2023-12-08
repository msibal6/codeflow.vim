let s:UI = {}
let g:CodeflowUI = s:UI

function! s:UI.new(flowWindow) abort " {{{1
    let newUI = copy(self)
    let newUI.flowWindow = a:flowWindow
    return newUI
endfunction
" }}}

" FUNCTION: s:UI.render() {{{1
function! s:UI.render() abort
    setlocal noreadonly modifiable

    " remember the top line of the buffer and the current line so we can
    " restore the view exactly how it was
    let curLine = line('.')
    let curCol = col('.')
    let topLine = line('w0')

    " delete all lines in the buffer (being careful not to clobber a register)
    " we are deleting top line in the buffer
    silent 1,$delete _

    " draw the tree
    silent put =self.flowWindow.renderToString()

    " delete the blank line at the top of the buffer
    silent 1,1delete _

    " restore the view
    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(topLine, 1)
    normal! zt
    call cursor(curLine, curCol)
    let &scrolloff = old_scrolloff

    setlocal readonly nomodifiable
endfunction
" }}}

" FUNCTION: s:UI.restoreScreenState() {{{1
"
" Sets the screen state back to what it was when nerdtree#saveScreenState was last
" called.
"
" Assumes the cursor is in the NERDTree window
function! s:UI.restoreScreenState()
    if !has_key(self, '_screenState')
        return
    endif
    execute "silent vertical resize " . self._screenState["oldWindowSize"]

    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(self._screenState['oldTopLine'], 0)
    normal! zt
    call setpos('.', self._screenState['oldPos'])
    let &scrolloff=old_scrolloff
endfunction
" }}}

" FUNCTION: s:UI.saveScreenState() {{{1
" Saves the current cursor position in the current buffer and the window
" scroll position
function! s:UI.saveScreenState()
    let win = winnr()
    let self._screenState = {}
    try
        call g:CodeflowWindow.cursorToFlowWindow()
        let self._screenState['oldPos'] = getpos('.')
        let self._screenState['oldTopLine'] = line('w0')
        let self._screenState['oldWindowSize'] = winnr('$') == 1 ? 20 : winwidth('')
        execute win .. "wincmd w"
    catch
    endtry
endfunction

