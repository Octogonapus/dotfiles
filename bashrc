
# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/salmon/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/salmon/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac
# Tab completion for juliaup and julia channel selection
[ -f "/home/salmon/.julia/juliaup/completions/bash.sh" ] && source "/home/salmon/.julia/juliaup/completions/bash.sh"

# <<< juliaup initialize <<<
