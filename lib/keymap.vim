"CLASS: KeyMap
"============================================================
let s:KeyMap = {}
let g:CodeflowKeyMap = s:KeyMap
let s:keyMaps = {}

"FUNCTION: KeyMap.FindFor(key, scope) {{{1
function! s:KeyMap.FindFor(key, scope) abort
    return get(s:keyMaps, a:key . a:scope, {})
endfunction
"}}}

"FUNCTION: KeyMap.BindAll() {{{1
function! s:KeyMap.BindAll() abort
    for keyMap values(s:keyMaps)
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
    exec 'nnoremap <buffer> <silent> '. self.key . premap . ':call g:CodeflowKeyMap.Invoke("'. keymapInvokeString .'")<cr>'
endfunction

"}}}

"FUNCTION: KeyMap.Remove(key, scope) {{{1
function! s:KeyMap.Remove(key, scope) abort
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

" TODO(Mitchell): update the comment
"FUNCTION: KeyMap.Invoke() {{{1
"Find a keymapping for a:key and the current scope invoke it.
"
"Scope is determined as follows:
"   * if the cursor is on a dir node then DirNode
"   * if the cursor is on a file node then FileNode
"   * if the cursor is on a bookmark then Bookmark
"
"If a keymap has the scope of 'all' then it will be called if no other keymap
"is found for a:key and the scope.
" TODO(Mitchell):
function! s:KeyMap.Invoke(key) abort
    "required because clicking the command window below another window still
    "invokes the <LeftRelease> mapping - but changes the window cursor
    "is in first
    "
    " TODO(Mitchell): determine what vim bug this is
    " do you need to do this check
    "TODO: remove this check when the vim bug is fixed
    if !exists('b:flowWindow')
        return {}
    endif

    let node = g:CodeflowWindow.GetSelected()

    if empty(node)
        return
    endif

    if node.isFlow
        "try file node
        let km = s:KeyMap.FindFor(a:key, 'flow')
        if !empty(km)
            return km.invoke(node)
        endif
    elseif node.isStep
    endif
endfunction
" }}}

"FUNCTION: KeyMap.Create(options) {{{1
function! s:KeyMap.Create(options) abort
    let opts = extend({'scope': 'all', 'quickhelpText': ''}, copy(a:options))

    "dont override other mappings unless the 'override' option is given
    if get(opts, 'override', 0) ==# 0 && !empty(s:KeyMap.FindFor(opts['key'], opts['scope']))
        return
    end

    let newKeyMap = copy(self)
    let newKeyMap.key = opts['key']
    let newKeyMap.quickhelpText = opts['quickhelpText']
    let newKeyMap.callback = opts['callback']
    let newKeyMap.scope = opts['scope']

    call s:KeyMap.Add(newKeyMap)
endfunction

"}}}

" function! s:KeyMap.Add(keymap) abort " {{{1
function! s:KeyMap.Add(keymap) abort
    let s:keyMaps[a:keymap.key . a:keymap.scope] = a:keymap
endfunction
" }}}

" vim: set sw=4 sts=4 et fdm=marker:
