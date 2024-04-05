function o
    if count $argv > /dev/null
        open $argv
    else
        open .
    end
end
