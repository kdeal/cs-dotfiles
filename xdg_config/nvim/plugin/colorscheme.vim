function! AdjustHighlights() abort
    highlight MatchParen cterm=bold ctermfg=red ctermbg=darkgrey
    highlight IncSearch ctermfg=lightgreen ctermbg=green guifg=#3c3836 guibg=#fadb2f
    highlight Substitute ctermfg=lightgreen ctermbg=green guifg=#3c3836 guibg=#fadb2f
    highlight Search ctermfg=lightgreen ctermbg=green guifg=#3c3836 guibg=#fadb2f
    highlight link gitcommitSummary GruvboxAqua
    highlight link gitcommitOverflow GruvboxRed

    " Fix Diagnostic theme
    highlight! link DiagnosticSignError GruvboxRedSign
    highlight! link DiagnosticSignWarn GruvboxYellowSign
    highlight! link DiagnosticSignInfo GruvboxBlueSign
    highlight! link DiagnosticSignHint GruvboxPurpleSign

    highlight! link DiagnosticFloatingError GruvboxRed
    highlight! link DiagnosticWarn GruvboxYellow
    highlight! link DiagnosticInfo GruvboxBlue
    highlight! link DiagnosticHint GruvboxPurple
endfunction

augroup AdjustColors
    autocmd!
    autocmd ColorScheme gruvbox call AdjustHighlights()
augroup END

let g:gruvbox_italic = 1
silent! colorscheme gruvbox
