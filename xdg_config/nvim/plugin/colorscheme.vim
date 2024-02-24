function! AdjustHighlights() abort
    highlight! MatchParen cterm=bold ctermfg=red ctermbg=darkgrey
    highlight! IncSearch ctermfg=lightgreen ctermbg=green guifg=#3c3836 guibg=#fadb2f
    highlight! Substitute ctermfg=lightgreen ctermbg=green guifg=#3c3836 guibg=#fadb2f
    highlight! Search ctermfg=lightgreen ctermbg=green guifg=#3c3836 guibg=#fadb2f

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

    " Flip foreground/background for diff
    highlight! link DiffAdd GruvboxGreen
    highlight! link DiffDelete GruvboxRed
    highlight! link DiffChange GruvboxAqua

    " tree-sitter highlight groups
    highlight! link @text Normal
    highlight! link @variable Normal
    highlight! link @variable.parameter GruvboxBlue
    highlight! link @attribute GruvboxAqua

    " Fix diff highlighting
    highlight! link @diff.plus DiffAdd
    highlight! link @diff.minus DiffDelete
    highlight! link @diff.delta DiffChange

endfunction

augroup AdjustColors
    autocmd!
    autocmd ColorScheme gruvbox call AdjustHighlights()
augroup END

let g:gruvbox_italic = 1
silent! colorscheme gruvbox
