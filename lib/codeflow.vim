" let s:Codeflow = {}
" let g:Codeflow = s:Codeflow

" TODO(Mitchell): this is a codeflow window function
" function s:Codeflow.ExistsForTab() {{{1
" function! s:Codeflow.ExistsForTab() abort
"     if !exists("t:flowWindowBufferName")
"         return
"     endif
" 
"     return !empty(getbufvar(bufnr(t:flowWindowBufferName), "flowWindow"))
" endfunction
" }}}

" TODO(Mitchell): this is a codeflow window function
" function s:Codeflow.GetWinNumber() {{{1
" function! s:Codeflow.GetWinNumber() abort
"     if exists('t:flowWindowBufferName')
"         return bufwinnr(t:flowWindowBufferName)
"     endif
"     return -1
" endfunction
" }}} 

" TODO(Mitchell): this is a codeflow window function
" function s:Codeflow.IsOpen() {{{1
" function! s:Codeflow.IsOpen() abort
"     return s:Codeflow.GetWinNumber() != -1
" endfunction
" }}}

" TODO(Mitchell): this is a codeflow window function
" function! s:Codeflow.New() {{{1
" function! s:Codeflow.New() abort
"     let newCodeflow = copy(self)
"     let newCodeflow.ui = g:CodeflowUI.New(newCodeflow)
     " TODO(Mitchell): put the file system slash here
"     let newCodeflow.flowFolder = getcwd() . codeflow#slash() . ".flow"
"     return newCodeflow
" endfunction
" }}}
