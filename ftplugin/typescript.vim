if !exists('g:loaded_vim_ts_plugin')
    finish
endif

command! -buffer TsDefinition               :call ts#definition()

noremap <silent> <buffer> <Plug>(TsDefinition)     :TsDefinition <CR>

if !hasmapto('<Plug>(TsDefinition)')
    map <buffer> <C-]> <Plug>(TsDefinition)
endif

augroup ts_defaults
  autocmd!
  autocmd BufWinEnter * silent! call ts#startServerIfNotRunningForFileBuffer()
augroup END
