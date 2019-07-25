if get(s:, 'loaded', 0)
    finish
endif

let s:loaded = 1

let g:ncm2_ledger#proc = yarp#py3('ncm2_ledger')
let g:ncm2_ledger#proc.on_load = 'ncm2_ledger#on_load'

let g:ncm2_ledger#accounts_source = extend(
    \ get(g:, 'ncm2_ledger#accounts_source', {}), {
    \ 'name': 'ledger accounts',
    \ 'mark': 'ledger',
    \ 'scope': ['ledger'],
    \ 'ready': 0,
    \ 'priority': 9,
    \ 'complete_length': -1,
    \ 'complete_pattern': ['^ {4}'],
    \ 'word_pattern': '\S+',
    \ 'on_warmup': 'ncm2_ledger#on_warmup',
    \ 'on_complete': 'ncm2_ledger#on_complete_accounts',
\ }, 'keep')

func! ncm2_ledger#init()
    call ncm2#register_source(g:ncm2_ledger#accounts_source)
endfunc

func! ncm2_ledger#on_load()
    let g:ncm2_ledger#accounts_source.ready = 1
endfunc

func! ncm2_ledger#on_warmup(ctx)
    call g:ncm2_ledger#proc.jobstart()
endfunc

func! ncm2_ledger#on_complete_accounts(ctx)
    call g:ncm2_ledger#proc.try_notify('accounts_provider', a:ctx)
endfunc

func! ncm2_ledger#on_event(event)
    call g:ncm2_ledger#proc.try_notify('on_complete', a:ctx)
endfunc
