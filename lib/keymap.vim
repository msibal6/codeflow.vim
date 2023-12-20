" CLASS: KeyMap
"============================================================
let s:KeyMap = {}
let g:CodeflowKeyMap = s:KeyMap
let s:keyMaps = {}

"FUNCTION: KeyMap.findFor(key, scope) {{{1
function! s:KeyMap.findFor(key, scope) abort
    return get(s:keyMaps, a:key . a:scope, {})
endfunction
"}}}

"FUNCTION: KeyMap.BindAll() {{{1
function! s:KeyMap.BindAll() abort
    for keyMap in values(s:keyMaps)
        call keyMap.bind()
    endfor
endfunction
"}}}

"FUNCTION: KeyMap.bind() {{{1
function! s:KeyMap.bind() abort
    " If the key sequence we're trying to map contains any '<>' notation, we
    " must replace each of the '<' characters with '<lt>' to ensure the string
    " is not translated into its corresponding keycode during the later part
    " of the map command below
    " :he <>
    let specialNotationRegex = '\m<\([[:alnum:]_-]\+>\)'
    " create the mapping
    if self.key =~# specialNotationRegex
        let keymapInvokeString = substitute(self.key, specialNotationRegex, '<lt>\1', 'g')
    else
        let keymapInvokeString = self.key
    endif
    " escape the name 
    let keymapInvokeString = escape(keymapInvokeString, '\"')

    let premap = self.key ==# '<LeftRelease>' ? ' <LeftRelease>' : ' '

    " MITCHNOTE: each keymap creates its own mapping in the buffer
    exec 'nnoremap <buffer> <silent> '. self.key . premap . ':call codeflow#ui_glue#invokeKeyMap("'. keymapInvokeString .'")<cr>'
endfunction

"}}}

"FUNCTION: KeyMap.remove(key, scope) {{{1
function! s:KeyMap.remove(key, scope) abort
    return remove(s:keyMaps, a:key . a:scope)
endfunction

"}}}

" function! s:KeyMap.invoke(...) {{{1
" Call the KeyMaps callback function
function! s:KeyMap.invoke(...) abort
    let l:Callback = type(self.callback) ==# type(function('tr')) ? self.callback : function(self.callback)
    if a:0
        call l:Callback(a:1)
    else
        call l:Callback()
    endif
endfunction

"}}}

"FUNCTION: KeyMap.Invoke() {{{1
"Find a keymapping for a:key and the current scope invoke it.
"
"Scope is determined as follows:
"   * if the cursor is on a flow then flow
"   * if the cursor is on a step then step
"   * if the cursor is on nothing then general
"
"If a keymap has the scope of 'general' then it will be called if no other keymap
"is found for a:key and the scope.
function! s:KeyMap.Invoke(key) abort
    "required because clicking the command window below another window still
    "invokes the <LeftRelease> mapping - but changes the window cursor
    "is in first

    " TODO: remove this check when the vim bug is fixed
    " maybe this is already fixed
    " this is only called on a buffer that has this keymaps
    " this should never happen
    if !exists('b:codeflowWindow')
        return {}
    endif

    let node = g:CodeflowWindow.getSelected()

    if empty(node)
        return
    endif

    if has_key(node, "isFlow")
        let km = s:KeyMap.findFor(a:key, 'flow')
        if !empty(km)
            return km.invoke(node)
        endif
    endif

    if has_key(node, "isStep")
        let km = s:KeyMap.findFor(a:key, 'step')
        if !empty(km)
            return km.invoke(node)
        endif
    endif

    let km = s:KeyMap.findFor(a:key, 'general')
    if !empty(km)
        return km.invoke(node)
    endif
endfunction
" }}}

"FUNCTION: KeyMap.create(options) {{{1
function! s:KeyMap.create(options) abort
    let opts = extend({'scope': 'all', 'quickhelpText': ''}, copy(a:options))

    "dont override other mappings unless the 'override' option is given
    if get(opts, 'override', 0) ==# 0 && !empty(s:KeyMap.findFor(opts['key'], opts['scope']))
        return
    end

    let newKeyMap = copy(self)
    let newKeyMap.key = opts['key']
    let newKeyMap.quickhelpText = opts['quickhelpText']
    let newKeyMap.callback = opts['callback']
    let newKeyMap.scope = opts['scope']

    let s:keyMaps[newKeyMap.key . newKeyMap.scope] = newKeyMap
endfunction
"}}}

