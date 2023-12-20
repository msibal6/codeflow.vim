
" ============================================================================
" CLASS: Path
"
" The Path class provides an abstracted representation of a file system
" pathname.  Various operations on pathnames are provided and a number of
" representations of a given path name can be accessed here.
" ============================================================================
let s:Path = {}
let g:CodeflowPath = s:Path

" fun Path.AbsolutePathFor(pathStr) {{{1
function! s:Path.AbsolutePathFor(pathStr)
    let l:prependWorkingDir = 0

    if codeflow#runningWindows()
        let l:prependWorkingDir = a:pathStr !~# '^.:\(\\\|\/\)\?' && a:pathStr !~# '^\(\\\\\|\/\/\)'
    else
        let l:prependWorkingDir = a:pathStr !~# '^/'
    endif

    let l:result = a:pathStr

    if l:prependWorkingDir
        let l:result = getcwd()

        if l:result[-1:] == codeflow#slash()
            let l:result = l:result . a:pathStr
        else
            let l:result = l:result . codeflow#slash() . a:pathStr
        endif
    endif

    return l:result
endfunction
" }}}
" fun Path.extractDriveLetter(fullpath) {{{1
"
" If running windows, cache the drive letter for this path
function! s:Path.extractDriveLetter(fullpath)
    if codeflow#runningWindows()
        if a:fullpath =~# '^\(\\\\\|\/\/\)'
            "For network shares, the 'drive' consists of the first two parts of the path, i.e. \\boxname\share
            let self.drive = substitute(a:fullpath, '^\(\(\\\\\|\/\/\)[^\\\/]*\(\\\|\/\)[^\\\/]*\).*', '\1', '')
            let self.drive = substitute(self.drive, '/', '\', 'g')
        else
            let self.drive = substitute(a:fullpath, '\(^[a-zA-Z]:\).*', '\1', '')
        endif
    else
        let self.drive = ''
    endif
endfunction
" }}}
" fun Path.getLastPathComponent(dirSlash) {{{1
"
" Gets the last part of this path.
"
" Args:
" dirSlash: if 1 then a trailing slash will be added to the returned value for
" directory nodes.
function! s:Path.getLastPathComponent(dirSlash)
    if empty(self.pathSegments)
        return ''
    endif
    let toReturn = self.pathSegments[-1]
    if a:dirSlash && self.isDirectory
        let toReturn = toReturn . '/'
    endif
    return toReturn
endfunction
" }}}
" fun Path.New(pathStr) {{{1
function! s:Path.New(pathStr)
    let l:newPath = copy(self)
    call l:newPath.readInfoFromDisk(s:Path.AbsolutePathFor(a:pathStr))

    return l:newPath
endfunction
" }}}
" fun Path.readInfoFromDisk(fullpath) {{{1
"
" Throws Codeflow.Path.InvalidArguments exception.
function! s:Path.readInfoFromDisk(fullpath)
    call self.extractDriveLetter(a:fullpath)

    let fullpath = s:Path.WinToUnixPath(a:fullpath)

    let self.pathSegments = filter(split(fullpath, '/'), '!empty(v:val)')

    "grab the last part of the path (minus the trailing slash)
    let lastPathComponent = self.getLastPathComponent(0)

    "get the path to the new node with the parent dir fully resolved
    let hardPath = s:Path.Resolve(self.strTrunk()) . '/' . lastPathComponent

    "if  the last part of the path is a symlink then flag it as such
    let self.isSymLink = (s:Path.Resolve(hardPath) !=# hardPath)
    if self.isSymLink
        let self.symLinkDest = s:Path.Resolve(fullpath)

        "if the link is a dir then slap a / on the end of its dest
        if isdirectory(self.symLinkDest)

            "we always wanna treat MS windows shortcuts as files for
            "simplicity
            if hardPath !~# '\.lnk$'

                let self.symLinkDest = self.symLinkDest . '/'
            endif
        endif
    endif
endfunction
" }}}
" fun Path.Resolve() {{{1
" Invoke the vim resolve() function and return the result
" This is necessary because in some versions of vim resolve() removes trailing
" slashes while in other versions it doesn't.  This always removes the trailing
" slash
function! s:Path.Resolve(path)
    let tmp = resolve(a:path)
    return tmp =~# '.\+/$' ? substitute(tmp, '/$', '', '') : tmp
endfunction

" fun Path.strTrunk() {{{1
" Gets the path without the last segment on the end.
function! s:Path.strTrunk()
    return self.drive . '/' . join(self.pathSegments[0:-2], '/')
endfunction
" fun s:Path.stringForUI() {{{1
function! s:Path.stringForUI()
    let toReturn = '/' .. join(self.pathSegments, '/')
    if toReturn !=# '/'
        let toReturn  = toReturn .. '/'
    endif
    return toReturn
endfunction
" }}}
" fun Path.WinToUnixPath(pathstr){{{1
" Takes in a windows path and returns the unix equiv
"
" A class level method
"
" Args:
" pathstr: the windows path to convert
function! s:Path.WinToUnixPath(pathstr)
    if !codeflow#runningWindows()
        return a:pathstr
    endif

    let toReturn = a:pathstr

    "remove the x:\ of the front
    let toReturn = substitute(toReturn, '^.*:\(\\\|/\)\?', '/', '')

    "remove the \\ network share from the front
    let toReturn = substitute(toReturn, '^\(\\\\\|\/\/\)[^\\\/]*\(\\\|\/\)[^\\\/]*\(\\\|\/\)\?', '/', '')

    "convert all \ chars to /
    let toReturn = substitute(toReturn, '\', '/', 'g')

    return toReturn
endfunction
" }}}
