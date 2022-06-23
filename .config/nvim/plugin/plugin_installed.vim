function! PluginInstalled(plugin_name)
    return v:lua.plugin_installed(a:plugin_name)
endfunction
