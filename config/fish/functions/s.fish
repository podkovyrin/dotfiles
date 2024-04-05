function s
    if count $argv > /dev/null
        subl $argv
    else
        subl .
    end
end
