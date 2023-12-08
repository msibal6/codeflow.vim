let s:Codeflow = {}
let g:Codeflow = s:Codeflow

" function s:Codeflow.ExistsForTab() {{{1
function! s:Codeflow.ExistsForTab() abort
    if !exists("t:flowWindowBufferName")
        return
    endif

    return !empty(getbufvar(bufnr(t:flowWindowBufferName), "flowWindow"))
endfunction
" }}}

" function s:Codeflow.GetWinNumber() {{{1
function! s:Codeflow.GetWinNumber() abort
    if exists('t:flowWindowBufferName')
        return bufwinnr(t:flowWindowBufferName)
    endif
    return -1
endfunction
" }}} 

" function s:Codeflow.IsOpen() {{{1
function! s:Codeflow.IsOpen() abort
    return s:Codeflow.GetWinNumber() != -1
endfunction
" }}}

" function s:Codeflow.Close() {{{1
function! s:Codeflow.Close() abort
    if !s:Codeflow.IsOpen()
        return
    endif

    if winnr('$') != -1
        if winnr() == s:Codeflow.GetWinNumber()
            execute "wincmd p"
            let l:activeBuffer = bufnr('')
            execute "wincmd p"
        else
            let l:activeBuffer = bufnr('')
        endif

        execute s:Codeflow.GetWinNumber() . " wincmd w"
        echom " closing " .  expand('%')
        close
        execute bufwinnr(l:activeBuffer) . " wincmd w"
    else 
        close
    endif
endfunction
" }}}
"
" function! s:Codeflow.New() {{{1
function! s:Codeflow.New() abort
    let newCodeflow = copy(self)
    let newCodeflow.test = '1'
    return newCodeflow
endfunction
" }}}
