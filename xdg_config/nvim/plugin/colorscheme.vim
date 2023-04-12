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

    " Fix noice colors. By default it uses DiagnosticSign colors, but in
    " gruvbox that has a different background. Switch them to the non-sign
    " versions to make the background the same
    highlight! link NoiceCmdlineIcon DiagnosticInfo
    highlight! link NoiceCmdlinePopupBorder DiagnosticInfo
    highlight! link NoiceCmdlineIconSearch DiagnosticWarn
    highlight! link NoiceCmdlinePopupBorderSearch DiagnosticWarn
    highlight! link NoiceConfirmBorder DiagnosticInfo
endfunction

augroup AdjustColors
    autocmd!
    autocmd ColorScheme gruvbox call AdjustHighlights()
augroup END

let g:gruvbox_italic = 1
silent! colorscheme gruvbox
