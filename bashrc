# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

exec $HOME/.local/bin/fish -l
