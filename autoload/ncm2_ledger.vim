if get(s:, 'loaded', 0)
    finish
endif

let s:loaded = 1

let g:ncm2_ledger#proc = yarp#py3({
    \ 'module': 'ncm2_ledger',
    \ 'on_load': { -> ncm2#set_ready(g:ncm2_ledger#source)}
\ })

let g:ncm2_ledger#source = extend(get(g:, 'ncm2_ledger#source', {}), {
    \ 'name': 'ledger',
    \ 'mark': 'ledger',
    \ 'scope': ['ledger'],
    \ 'ready': 0,
    \ 'priority': 9,
    \ 'complete_length': -1,
    \ 'complete_pattern': ['^ {4}'],
    \ 'word_pattern': '\S+',
    \ 'on_warmup': 'ncm2_ledger#on_warmup',
    \ 'on_complete': 'ncm2_ledger#on_complete',
\ }, 'keep')

func! ncm2_ledger#init()
    call ncm2#register_source(g:ncm2_ledger#source)
endfunc

func! ncm2_ledger#on_warmup(ctx)
    call g:ncm2_ledger#proc.jobstart()
endfunc

func! ncm2_ledger#on_complete(ctx)
    call g:ncm2_ledger#proc.try_notify('on_complete', a:ctx)
endfunc

func! ncm2_ledger#on_event(event)
    call g:ncm2_ledger#proc.try_notify('on_complete', a:ctx)
endfunc
