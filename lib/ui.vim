let s:UI = {}
let g:CodeflowUI = s:UI

function! s:UI.New(flowWindow) abort " {{{1
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

    " puts a "blank" line at the top of the buffer
    " call setline(line('.')+1, 'this should be blank')
    " call cursor(line('.')+1, col('.'))

    " TODO(Mitchell): put the proper header for current folder
    " draw the header line
    " let header = "Flows for"
    " call setline(line('.')+1, header)
    " call cursor(line('.')+1, col('.'))

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
