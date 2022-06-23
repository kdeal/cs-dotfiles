# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if command -v fish &> /dev/null
then
    exec fish -l
fi
