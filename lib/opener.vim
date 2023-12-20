" ============================================================================
" CLASS: Opener
"
" The Opener class defines an API for 'opening' operations.
" ============================================================================

let s:Opener = {}
let g:CodeflowOpener = s:Opener


" func s:Opener.New() {{{1
function! s:Opener.New() abort
    let newOpener = copy(self)
    " where to open is dependent only on the type of codeflow window
    " drawer vs explorer
    let newOpener.codeflowWindow = b:codeflowWindow
    return newOpener
endfunction

" func s:Opener.goToTargetWindow() {{{1
function! s:Opener.goToTargetWindow() abort
    if self.codeflowWindow.isDrawerWindow()
        if winnr("$") ==# 1
            let l:splitLocation = g:CodeflowWinPos ==# 'left'
                        \ || g:CodeflowWinPos ==# 'top' ? 'botright ' : 'topleft '
            let l:splitDirection = g:CodeflowWinPos ==# 'left'
                        \ || g:CodeflowWinPos ==# 'right' ? 'vertical' : ''
            let l:splitSize = g:CodeflowWinSize
            silent! execute l:splitLocation .. l:splitDirection .. ' ' .. ' split'

            silent! execute "wincmd p"
            silent! execute l:splitDirection .. ' resize ' .. l:splitSize
            silent! execute "wincmd p"
        else
            silent! execute "wincmd p"
        endif
    else
    endif
endfunction

" func s:Opener.open(node) {{{1
function! s:Opener.open(node) abort
    let node = a:node
    call self.goToTargetWindow()
    if has_key(node, "isFlow")
        call g:CodeflowFlow.loadFlow(node.name)
        call g:CodeflowWindow.rerender()
        echom "breaks right here"
        if t:currentCodeFlow.currentStep ==# 1
            call g:CodeflowFlow.goToStep(t:currentCodeFlow.currentStep)
        endif
    endif
    if has_key(node, "isStep")
        let t:currentCodeFlow.currentStep = node.stepIndex
        call g:CodeflowWindow.rerender()
        call g:CodeflowFlow.goToStep(t:currentCodeFlow.currentStep)
    endif
endfunction
