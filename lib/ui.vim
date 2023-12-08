let s:UI = {}
let g:CodeflowUI = s:UI

" FUNCTION: s:UI.new(flowWindow) {{{1
function! s:UI.New(flowWindow)
    let newUI = copy(self)
    let newUI.flowWindow = a:flowWindow
    return newUI
endfunction
" }}}

" TODO(Mitchell):
" FUNCTION: s:UI.render() {{{1
function! s:UI.render()
    setlocal noreadonly modifiable

    " render time {{{3
    setlocal noreadonly modifiable

    " restore the view exactly how it was
    let curLine = line('.')
    let curCol = col('.')
    let topLine = line('w0')

    " delete all lines in the buffer (being careful not to clobber a register)
    silent 1,$delete _

    " delete the blank line before the help and add one after it
    call setline(line('.')+1, 'this should be blank')
    call cursor(line('.')+1, col('.'))

    " draw the header line
    let header = "current flows"
    call setline(line('.')+1, header)
    call cursor(line('.')+1, col('.'))

    " draw the tree
    " TODO(Mitchell): draw the 
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
"    " remember the top line of the buffer and the current line so we can
"    " restore the view exactly how it was
"    let curLine = line('.')
"    let curCol = col('.')
"    let topLine = line('w0')
"
"    " delete all lines in the buffer (being careful not to clobber a register)
"    silent 1,$delete _
"
"    call self._dumpHelp()
"
"    " delete the blank line before the help and add one after it
"    if !self.isMinimal()
"        call setline(line('.')+1, '')
"        call cursor(line('.')+1, col('.'))
"    endif
"
"    if self.getShowBookmarks()
"        call self._renderBookmarks()
"    endif
"
"    " add the 'up a dir' line
"    if !self.isMinimal()
"        call setline(line('.')+1, s:UI.UpDirLine())
"        call cursor(line('.')+1, col('.'))
"    endif
"
"    " draw the header line
"    let header = self.nerdtree.root.path.str({'format': 'UI', 'truncateTo': winwidth(0)})
"    call setline(line('.')+1, header)
"    call cursor(line('.')+1, col('.'))
"
"    " draw the tree
"    silent put =self.nerdtree.root.renderToString()
"
"    " delete the blank line at the top of the buffer
"    silent 1,1delete _
"
"    " restore the view
"    let old_scrolloff=&scrolloff
"    let &scrolloff=0
"    call cursor(topLine, 1)
"    normal! zt
"    call cursor(curLine, curCol)
"    let &scrolloff = old_scrolloff

    setlocal readonly nomodifiable
endfunction
" }}}
