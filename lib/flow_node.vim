" ============================================================================
" CLASS: FlowNode
"
" ============================================================================


let s:FlowNode = {}
let g:CodeflowFlowNode = s:FlowNode

" fun s:FlowNode.GetSelected(codeflowWindow) {{{1
" Returns a new FlowNode object
"
" Args:
" codeflowWindow: the tree the node belongs to
function! s:FlowNode.GetSelected(codeflowWindow) abort
    " check for a flow node
    let file = ".flow" . codeflow#slash() . getline('.') . ".flow"
    " get the file
    let newFlowNode = {}
    if !empty(glob(file))
        let newFlowNode = s:FlowNode.New(a:codeflowWindow)
        let newFlowNode.isFlow = 1
        let newFlowNode.file = file
        let newFlowNode.name = getline('.')
    endif
    return newFlowNode
endfunction

" fun s:FlowNode.New(codeflowWindow) {{{1
" Returns a new FlowNode object
"
" Args:
" codeflowWindow: the tree the node belongs to
function! s:FlowNode.New(codeflowWindow) abort
        let newFlowNode = copy(self)
        let newFlowNode.codeflowWindow = a:codeflowWindow
        return newFlowNode
endfunction

" fun s:FlowNode.activate() {{{1
function! s:FlowNode.activate() abort
    call self.open()
endfunction

" fun s:FlowNode.open() {{{1
function! s:FlowNode.open() abort
    let opener = g:CodeflowOpener.New()
    call opener.open(self)
endfunction

