" ============================================================================
" CLASS: StepNode
"
" ============================================================================

let s:StepNode = {}
let g:CodeflowStepNode = s:StepNode
" anytime we are interacting with a node,
" we know that we are in a codeflow window
" fun s:StepNode.GetSelected(codeflowWindow) {{{1
" Returns a new StepNode object
"
" Args:
" codeflowWindow: the tree the node belongs to
function! s:StepNode.GetSelected(codeflowWindow)
    let lineNumber = line('.')
    let newStepNode = s:StepNode.New(a:codeflowWindow)
    let newStepNode.isStep = 1
    let newStepNode.stepIndex = lineNumber - 3
    return newStepNode
endfunction

" fun s:StepNode.New(codeflowWindow) {{{1
" Returns a new StepNode object
"
" Args:
" codeflowWindow: the tree the node belongs to
function! s:StepNode.New(codeflowWindow)
        let newStepNode = copy(self)
        let newStepNode.codeflowWindow = a:codeflowWindow
        return newStepNode
endfunction

" fun s:StepNode.activate() {{{1
function! s:StepNode.activate()
    call self.open()
endfunction

" fun s:StepNode.open() {{{1
function! s:StepNode.open()
    let opener = g:CodeflowOpener.New()
    call opener.open(self)
endfunction

