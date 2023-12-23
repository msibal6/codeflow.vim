if exists('g:loaded_codeflow_ui_glue_autoload')
    finish
endif
let g:loaded_codeflow_ui_glue_autoload = 1

let s:CommandList = []
let g:CodeflowCommandList = s:CommandList

" fun  s:addCommand(command, functionString, argsNeeded) " {{{1
function! s:addCommand(command, functionString, argsNeeded) abort
    let newCommand = {}
    let newCommand['command'] = a:command
    let newCommand['internalFunction'] = funcref(a:functionString)
    let newCommand['argsNeeded'] = a:argsNeeded
    " add newCommand to the scriptLocal command list
    call add(s:CommandList, newCommand)
endfunction
" }}}
" fun s:activateStepNode(node) abort " {{{1
function! s:activateStepNode(stepNode) abort
    " XXX render speed for the selected steps being highlighted is slow?
    " but is satisfactory for now
    call a:stepNode.activate()
endfunction
"}}}
" fun s:activateFlowNode(node) abort " {{{1
function! s:activateFlowNode(flowNode) abort
    call a:flowNode.activate()
endfunction
"}}}
" fun s:cHotKey(node) abort " {{{1
function! s:cHotKey(node) abort
    if g:CodeflowFlow.IsFlowActive()
        call g:CodeflowFlow.closeFlow()
    endif
endfunction
"}}}
" fun s:commandComplete(lead, line, position) " {{{1
function! s:codeflowComplete(lead, line, position) abort
    let args = split(a:line)
    " return all valid commands
    if len(args) == 1
        return mapnew(s:CommandList, {_,val -> val.command})
    " return matching valid commands
    elseif len(args) == 2
        return matchfuzzy(
                    \ mapnew(s:CommandList, { _, val -> val.command }),
                    \ a:lead)
    endif
endfunction
" }}}
" fun s:deleteFlowNode(node) abort " {{{1
function! s:deleteFlowNode(node) abort
    call system("rm -f " . shellescape(a:node.file))
endfunction
"}}}
" fun s:deleteStepNode(node) abort " {{{1
function! s:deleteStepNode(node) abort
    call g:CodeflowFlow.deleteStep()
endfunction
" }}}
" fun s:moveStepNodeUp(node) abort " {{{1
function! s:moveStepNodeUp(node) abort
    call g:CodeflowFlow.moveStepUp(a:node.stepIndex)
endfunction
" }}}
" fun s:moveStepNodeDown(node) abort " {{{1
function! s:moveStepNodeDown(node) abort
    call g:CodeflowFlow.moveStepDown(a:node.stepIndex)
endfunction
" }}}
" fun s:closeNode(node) abort " {{{1
function! s:closeNode(node) abort
    return
endfunction
" }}}
" fun s:sHotKey(node) abort " {{{1
function! s:sHotKey(node) abort
    if !g:CodeflowFlow.IsFlowActive()
        call g:CodeflowFlow.startFlow()
    endif
endfunction
"}}}
" fun s:SID() abort {{{1
function! s:SID() abort
    if !exists('s:sid')
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun
" }}}

" fun codeflow#ui_glue#createDefaultBindings() abort " {{{1
function! codeflow#ui_glue#createDefaultBindings() abort
    let script_num = '<SNR>' . s:SID() . '_'
    call g:CodeflowKeyMap.create({'key': g:CodeflowcHotkey, 'scope': 'general', 'callback': script_num . 'cHotKey'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowDelete, 'scope': 'flow', 'callback': script_num . 'deleteFlowNode'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowDelete, 'scope': 'step', 'callback': script_num . 'deleteStepNode'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowCustomOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowCustomOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowOpen, 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowOpen, 'scope': 'step', 'callback': script_num . 'activateStepNode'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowUp, 'scope': 'step', 'callback': script_num . 'moveStepNodeUp'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowDown, 'scope': 'step', 'callback': script_num . 'moveStepNodeDown'})
    call g:CodeflowKeyMap.create({'key': g:CodeflowsHotkey, 'scope': 'general', 'callback': script_num . 'sHotKey'})
    call g:CodeflowKeyMap.create({'key': '<2-LeftMouse>', 'scope': 'flow', 'callback': script_num . 'activateFlowNode'})
    call g:CodeflowKeyMap.create({'key': '<2-LeftMouse>', 'scope': 'step', 'callback': script_num . 'activateStepNode'})
endfunction
" }}}
" fun codeflow#ui_glue#invokeKeyMap(key) abort " {{{1
function! codeflow#ui_glue#invokeKeyMap(key) abort
    call g:CodeflowKeyMap.Invoke(a:key)
    " right now this always needs to be done because we are still on the same
    " buffer
    call g:CodeflowWindow.rerender()
endfunction
" }}}
" fun codeflow#ui_glue#setupCommands() {{{1
function! codeflow#ui_glue#setupCommands() abort
    " order of adding commands determines order of completion arguments
    call s:addCommand("start", "g:CodeflowFlow.startFlow",0)
    call s:addCommand("save", "g:CodeflowFlow.saveFlow",0)
    call s:addCommand("close", "g:CodeflowFlow.closeFlow",0)
    call s:addCommand("open", "g:CodeflowFlow.openFlow",0)
    call s:addCommand("openWindow", "g:CodeflowWindow.createDrawerWindow",0)
    call s:addCommand("closeWindow", "g:CodeflowWindow.close",0)
    call s:addCommand("addStep", "g:CodeflowFlow.addStep",0)
    call s:addCommand("insertStep", "g:CodeflowFlow.insertStep",0)
    call s:addCommand("goToStep", "g:CodeflowFlow.goToStep",1)
    call s:addCommand("prevStep", "g:CodeflowFlow.prevStep",0)
    call s:addCommand("nextStep", "g:CodeflowFlow.nextStep",0)
    call s:addCommand("updateStep", "g:CodeflowFlow.updateStep",0)
    call s:addCommand("deleteStep", "g:CodeflowFlow.deleteStep",0)
    command! -nargs=* -bar -bang -complete=customlist,s:codeflowComplete Codeflow call codeflow#execute(<f-args>)
endfunction
" }}}
