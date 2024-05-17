# Globals

abbr -a g git
abbr -a t tig
abbr -a gu gitui

### Ref name abbreviations

    # m⎵ → main
    #
    # A lot of `git` commands take branch arguments, so we allow the expansion for all arguments.
    # But we define it first, so that the expansion of `m` can be superseded for specific commands (e.g. `git commit`)
    # We also explicitly exclude `git commit` as a known conflict, just in case.
    abbr_exceptsubcommand_arg git m main branch commit
    # ms⎵ → master
    abbr_exceptsubcommand_arg git ms master commit

    # b⎵ → (expansion of current branch name)
    # function abbr_git_currentbranch_fn; _abbr_expand_exceptsubcommand_arg (git rev-parse --abbrev-ref HEAD) git; end; abbr -a abbr_git_currentbranch --regex b --position anywhere --function abbr_git_currentbranch_f
    # :b⎵ → :(expansion of current branch name)
    function abbr_git_coloncurrentbranch_fn
        _abbr_expand_subcommand_arg git :b :(git rev-parse --abbrev-ref HEAD) push
    end
    abbr -a abbr_git_coloncurrentbranch --regex :b --position anywhere --function abbr_git_coloncurrentbranch_fn
    function abbr_git_coloncurrentbranch1_fn
        _abbr_expand_subcommand_arg git :b1 :(git rev-parse --abbrev-ref @{-1}) push
    end
    abbr -a abbr_git_coloncurrentbranch1 --regex :b1 --position anywhere --function abbr_git_coloncurrentbranch1_fn
    function abbr_git_coloncurrentbranch2_fn
        _abbr_expand_subcommand_arg git :b2 :(git rev-parse --abbrev-ref @{-2}) push
    end
    abbr -a abbr_git_coloncurrentbranch2 --regex :b2 --position anywhere --function abbr_git_coloncurrentbranch2_fn

    # om⎵ → origin/main
    abbr_exceptsubcommand_arg git om origin/main commit
    # oms⎵ → origin/master
    abbr_exceptsubcommand_arg git oms origin/master commit
    # ob⎵ → origin/(expansion of current branch name)
    function abbr_git_origincurrentbranch_fn
        _abbr_expand_exceptsubcommand_arg git ob origin/(git rev-parse --abbrev-ref HEAD) commit
    end
    abbr -a abbr_git_origincurrentbranch --regex ob --position anywhere --function abbr_git_origincurrentbranch_fn

    # um⎵ → upstream/main
    abbr_exceptsubcommand_arg git um upstream/main commit
    # up⎵ → upstream/production
    abbr_exceptsubcommand_arg git up upstream/production commit
    # ums⎵ → upstream/master
    abbr_exceptsubcommand_arg git ums upstream/master commit
    # ub⎵ → upstream/(expansion of current branch name)
    function abbr_git_upstreamcurrentbranch_fn
        _abbr_expand_exceptsubcommand_arg git ub upstream/(git rev-parse --abbrev-ref HEAD) git
    end
    abbr -a abbr_git_upstreamcurrentbranch --regex ub --position anywhere --function abbr_git_upstreamcurrentbranch_fn

    # b-⎵ → (expansion of last branch name)
    function abbr_git_lastbranch_fn
        _abbr_expand_exceptsubcommand_arg git b- (git rev-parse --abbrev-ref @{-1}) commit
    end
    abbr -a abbr_git_lastbranch --regex b- --position anywhere --function abbr_git_lastbranch_fn
    #  b⎵ → (expansion of current branch name)
    # b1⎵ → (expansion of last branch name)
    # b3⎵ → (expansion of three branch names ago)
    function abbr_git_branchhist_fn; \
        set ref "@"
        if [ "$argv[1]" != "b" ]
            set ref $ref"{-"(string trim --left --chars=b $argv[1])"}"
        end
        set expanded_branch (git rev-parse --abbrev-ref $ref 2>/dev/null); or return 1
        _abbr_expand_exceptsubcommand_arg git _ $expanded_branch commit
    end
    abbr -a abbr_git_branchhist --regex "b[0-9]*" --position anywhere --function abbr_git_branchhist_fn

    #   h⎵ → HEAD
    #  h1⎵ → HEAD~1
    # h12⎵ → HEAD~12
    function abbr_git_HEAD_fn; \
        set str "HEAD"
        if [ "$argv[1]" != "h" ]
            set str $str"~"(string trim --left --chars=h $argv[1])
        end
        _abbr_expand_exceptsubcommand_arg git _ $str commit;
    end
    abbr -a abbr_git_HEAD --regex "h[0-9]*" --position anywhere --function abbr_git_HEAD_fn

### git branch

    # git b⎵ → git branch
    abbr_subcommand git b branch

    # git branch m⎵ → git branch --move
    abbr_subcommand_firstarg git m "--move" branch
    # git branch d⎵ → git branch --delete
    abbr_subcommand_firstarg git d "--delete" branch
    # git branch df⎵ → git branch --delete --force (equivalent to: git branch -D)
    abbr_subcommand_firstarg git df "--delete --force" branch

### git add

    # git a⎵ → git add
    abbr_subcommand git a add

### git checkout

    # git co⎵ → git checkout
    abbr_subcommand git co checkout

### git commit

    # git c⎵ → git commit
    abbr_subcommand git c commit

    # git cm⎵ → git commit -m
    abbr_subcommand git cm "commit -m"

    # git ca⎵ → git commit -am
    abbr_subcommand git ca "commit -am"

    # git commit a⎵ → git commit --amend
    abbr_subcommand_arg git a "--amend" commit

### git diff

    # git d⎵ → git diff
    abbr_subcommand git d diff

    # git diff c⎵ → git diff --cached
    abbr_subcommand_arg git c "--cached" diff
    # git diff no⎵ → git diff --name-only
    abbr_subcommand_arg git no "--name-only" diff

### git fetch

    # git f⎵ → git fetch
    abbr_subcommand git f fetch

    # git fa⎵ → git fetch --all
    abbr_subcommand git fa "fetch --all"

### git log

    # git l⎵ → git log
    abbr_subcommand git l log

### git merge

    # git m⎵ → git merge
    abbr_subcommand git m merge

    # git merge nff⎵ → git merge --no-ff
    abbr_subcommand_arg git nff "--no-ff" merge
    # git merge ffo⎵ → git merge --ff-only
    abbr_subcommand_arg git ffo "--ff-only" merge

### git pull

    # git pl⎵ → git pull
    abbr_subcommand git pl pull

### git push

    # git ps⎵ → git push
    abbr_subcommand git ps push

### git push

    # git r⎵ → git remote -v
    abbr_subcommand git r "remote -v"

### git rebase

    # git rb⎵ → git rebase
    abbr_subcommand git rb rebase

    # git rc⎵ → git rebase --continue
    abbr_subcommand git rc "rebase --continue"

    # git rs⎵ → git rebase --skip
    abbr_subcommand git rs "rebase --skip"

    # git rebase i⎵ → git rebase --interactive
    abbr_subcommand_arg git i "--interactive" rebase

### git cherry-pick

    # git cp⎵ → git cherry-pick -x
    abbr_subcommand git cp "cherry-pick -x"

### git stash

    abbr_subcommand git ss "stash"

    # git stash p⎵ → git stash pop
    abbr_subcommand_arg git p "pop" stash
    # git stash s⎵ → git stash show
    abbr_subcommand_arg git s "show" stash
    # git stash d⎵ → git stash drop
    abbr_subcommand_arg git d "drop" stash

### git status

    # git s⎵ → git status
    abbr_subcommand git s status

### git tag

    # git t⎵ → git tag
    abbr_subcommand git t tag

    # git tag d⎵ → git tag --delete (equivalent to: git tag -D)
    abbr_subcommand_firstarg git d "--delete" tag

