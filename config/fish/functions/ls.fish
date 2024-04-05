function ls
    if type --quiet eza
      eza $argv
    else
      command ls --color=auto $argv
    end
end