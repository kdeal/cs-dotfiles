# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if ! command -v fish &> /dev/null
then
    echo "Fish not installed, installing via apt..."
    sleep 2
    sudo apt update
    sudo apt install fish
fi

exec fish -l
