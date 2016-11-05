let s:save_cpo = &cpo
set cpo&vim

" PARAMS: opts = {
"   dir: ''   // optional. defaults to buffer directory
"   tsserverCmd: ''  // optional. defaults to tsserver
" }
function! ts#tssClient#new(opts)
    let obj = {
        \ 'opts': {
            \ 'dir': '',
            \ 'tsserverCmd': ''
        \ },
        \ '_seq': 0
    \ }

    if has_key(a:opts, 'dir')
        let obj.opts.dir = a:opts.dir
    endif

    if obj.opts.dir == ''
        let obj.opts.dir = ts#buffer#getCurrentBufferDir()
    endif

    if has_key(a:opts, 'tsserverCmd')
        let obj.opts.tsserverCmd = a:opts.tsserverCmd
    endif

    if obj.opts.tsserverCmd == ''
        let obj.opts.tsserverCmd = 'tsserver'
    endif

    function! obj._out_cb(jobid, data)
        let l:split = split(a:data, "\r\n")
        let l:json = json_decode(join(l:split[1:], "\r\n"))
        if l:json.type == 'response'
            call self._onResponse(l:json)
        endif
        if has_key(self.opts, 'on_stdout')
            self.opts.on_stdout(self, a:data)
        endif
    endfunction

    function! obj._exit_cb(jobid, status)
        if has_key(self, '_job')
            call remove(self, '_job')
        endif
        if has_key(self, '_channel')
            call remove(self, '_channel')
        endif
        if has_key(self.opts, 'on_exit')
            self.opts.on_exit(self, a:status)
        endif
    endfunction

    function! obj._onResponse(res)
        " echom json_encode(a:res)
        if a:res.success && a:res.request_seq == self._seq " only care about the last response
            if a:res.command == 'definition'
                call self._processTsDefinition(a:res)
            endif
        endif
    endfunction

    function! obj.start()
        let l:cmd = ['cmd', '/c', 'cd /d ' . self.opts.dir, ' && ' . self.opts.tsserverCmd]
        let self._job = job_start(l:cmd, {
            \ 'out_cb': self._out_cb,
            \ 'exit_cb': self._exit_cb,
            \ 'mode': 'raw'
        \})
        let self._channel = job_getchannel(self._job)
        echom 'TS Server started: ' . self._job
    endfunction

    function! obj.startIfNotRunning()
        if !self.isRunning()
            call self.start()
        endif
    endfunction

    function! obj.stop()
        call job_stop(self._job)
    endfunction

    function! obj.stopIfRunning()
        if self.isRunning()
            call self.stop()
        endif
    endfunction

    function! obj.isRunning()
        return has_key(self, '_job')
    endfunction

    function! obj.sendRequest(command, arguments)
        let l:request = self._createRequest(a:command, a:arguments)
        let l:jsonStringRequest = json_encode(l:request) . "\r\n"
        call ch_sendraw(self._channel, l:jsonStringRequest)
        return l:request.seq
    endfunction

    function! obj._createRequest(command, arguments)
        let l:request = {
            \ 'seq': self._getNextSeq(),
            \ 'type': 'request',
            \ 'command': a:command
        \ }

        if type(a:arguments) == v:t_dict && !empty(a:arguments)
            let l:request.arguments = a:arguments
        endif

        return l:request
    endfunction

    function! obj._getNextSeq()
        let self._seq = self._seq + 1
        return self._seq
    endfunction

    function! obj.flushCurrentBuffer()
        let l:result = {
            \ 'file': ts#buffer#getCurrentBufferFilename(),
        \}
        if !empty(l:result.file)
            let l:result.seq = self.tsOpen(l:result.file)
        endif
        return l:result
    endfunction

    " strongly typed methods for sending requests prefixed with ts {{{

    function! obj.tsOpen(file)
        return self.sendRequest('open', { 'file': a:file })
    endfunction

    function! obj.tsDefinition(file, line, offset)
        return self.sendRequest('definition', { 'file': a:file, 'line': a:line, 'offset': a:offset })
    endfunction

    function! obj._processTsDefinition(res)
        if !empty(a:res.body)
            let l:definition = a:res.body[0]
            if l:definition.file == ts#buffer#getCurrentBufferFilename()
                " we are in the same file so just move the cursor
                call cursor(l:definition.start.line, l:definition.start.offset)
            else
                execute 'edit +call\ cursor('.l:definition.start.line.','.l:definition.start.offset.') '.l:definition.file
            endif
        endif
    endfunction

    function! obj.definition()
        let l:flushResult = self.flushCurrentBuffer()
        return self.tsDefinition(l:flushResult.file, ts#buffer#getCurrentBufferLine(), ts#buffer#getCurrentBufferCol())
    endfunction

    " }}}

    return obj
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim sw=4 ts=4 et
