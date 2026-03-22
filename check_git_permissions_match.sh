#!/usr/bin/env bash

# Pre-commit hook to ensure file permissions match between filesystem and git index
# Also checks that .sh files are executable

mismatch_files=()
non_exec_sh_files=()

while IFS= read -r -d '' file; do
    [[ ! -e "$file" ]] && continue
    [[ ! -f "$file" ]] && continue

    git_mode=$(git ls-files -s -- "$file" 2>/dev/null | awk '{print $1}')
    [[ -z "$git_mode" ]] && continue

    fs_mode=$(stat -c '%a' "$file")
    git_mode_short="${git_mode: -3}"

    if [[ -x "$file" ]]; then
        fs_exec=1
    else
        fs_exec=0
    fi

    if [[ "$git_mode" == "100755" ]]; then
        git_exec=1
    else
        git_exec=0
    fi

    if [[ "$fs_exec" -ne "$git_exec" ]]; then
        mismatch_files+=("$file|$fs_mode|$git_mode_short|$fs_exec")
        echo "Mode mismatch: $file"
        echo "  stat:         $fs_mode (executable: $([[ $fs_exec -eq 1 ]] && echo yes || echo no))"
        echo "  ls-files -s:  $git_mode_short (executable: $([[ $git_exec -eq 1 ]] && echo yes || echo no))"
        echo ""
    elif [[ "$file" == *.sh && "$git_exec" -eq 0 ]]; then
        non_exec_sh_files+=("$file")
        echo "Non-executable .sh file: $file"
        echo "  .sh files should have executable permissions"
        echo ""
    fi
done < <(git diff --cached --name-only -z)

has_errors=0

if [[ ${#mismatch_files[@]} -gt 0 ]]; then
    echo "Found ${#mismatch_files[@]} file(s) with permission mismatches."
    echo ""
    echo "To fix, run:"
    for entry in "${mismatch_files[@]}"; do
        IFS='|' read -r f fs_mode git_mode_short fs_exec <<< "$entry"
        if [[ $fs_exec -eq 1 ]]; then
            echo "  git update-index --chmod=+x '$f'"
        else
            echo "  git update-index --chmod=-x '$f'"
        fi
    done
    has_errors=1
fi

if [[ ${#non_exec_sh_files[@]} -gt 0 ]]; then
    [[ $has_errors -eq 1 ]] && echo ""
    echo "Found ${#non_exec_sh_files[@]} .sh file(s) without executable permissions."
    echo ""
    echo "To fix, run:"
    for f in "${non_exec_sh_files[@]}"; do
        echo "  chmod +x '$f' && git update-index --chmod=+x '$f'"
    done
    has_errors=1
fi

if [[ $has_errors -eq 1 ]]; then
    exit 1
fi
