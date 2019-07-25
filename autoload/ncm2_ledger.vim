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

let g:ncm2_ledger#tags_source = extend(
    \ get(g:, 'ncm2_ledger#tags_source', {}), {
    \ 'name': 'ledger tags',
    \ 'mark': 'ledger',
    \ 'scope': ['ledger'],
    \ 'ready': 0,
    \ 'priority': 9,
    \ 'complete_length': -1,
    \ 'complete_pattern': ['; '],
    \ 'word_pattern': '\S+',
    \ 'on_warmup': 'ncm2_ledger#on_warmup',
    \ 'on_complete': 'ncm2_ledger#on_complete_tags',
\ }, 'keep')

let g:ncm2_ledger#payees_source = extend(
    \ get(g:, 'ncm2_ledger#payees_source', {}), {
    \ 'name': 'ledger payees',
    \ 'mark': 'ledger',
    \ 'scope': ['ledger'],
    \ 'ready': 0,
    \ 'priority': 9,
    \ 'complete_length': -1,
    \ 'complete_pattern': '; Payee: ',
    \ 'word_pattern': '\S+',
    \ 'on_warmup': 'ncm2_ledger#on_warmup',
    \ 'on_complete': 'ncm2_ledger#on_complete_payees',
\ }, 'keep')

let g:ncm2_ledger#commodities_source = extend(
    \ get(g:, 'ncm2_ledger#commodities_source', {}), {
    \ 'name': 'ledger commodities',
    \ 'mark': 'ledger',
    \ 'scope': ['ledger'],
    \ 'ready': 0,
    \ 'priority': 9,
    \ 'complete_length': -1,
    \ 'complete_pattern': ' {2,}(\d+\.)?\d+ ',
    \ 'word_pattern': '(?: )[^0-9\.,//@]+',
    \ 'on_warmup': 'ncm2_ledger#on_warmup',
    \ 'on_complete': 'ncm2_ledger#on_complete_commodities',
\ }, 'keep')

func! ncm2_ledger#init()
    call ncm2#register_source(g:ncm2_ledger#accounts_source)
    call ncm2#register_source(g:ncm2_ledger#tags_source)
    call ncm2#register_source(g:ncm2_ledger#payees_source)
    call ncm2#register_source(g:ncm2_ledger#commodities_source)
endfunc

func! ncm2_ledger#on_load()
    let g:ncm2_ledger#accounts_source.ready = 1
    let g:ncm2_ledger#tags_source.ready = 1
    let g:ncm2_ledger#payees_source.ready = 1
    let g:ncm2_ledger#commodities_source.ready = 1
endfunc

func! ncm2_ledger#on_warmup(ctx)
    call g:ncm2_ledger#proc.jobstart()
endfunc

func! ncm2_ledger#on_complete_accounts(ctx)
    call g:ncm2_ledger#proc.try_notify('accounts_provider', a:ctx)
endfunc

func! ncm2_ledger#on_complete_tags(ctx)
    call g:ncm2_ledger#proc.try_notify('tags_provider', a:ctx)
endfunc

func! ncm2_ledger#on_complete_payees(ctx)
    call g:ncm2_ledger#proc.try_notify('payees_provider', a:ctx)
endfunc

func! ncm2_ledger#on_complete_commodities(ctx)
    call g:ncm2_ledger#proc.try_notify('commodities_provider', a:ctx)
endfunc
