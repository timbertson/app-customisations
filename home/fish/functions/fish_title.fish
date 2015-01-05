function fish_title
    #printf 'title'
    if [ $_ = 'fish' ]
        printf '#'
        if [ $PWD = $HOME ]
          printf '~'
        else
          printf '%s (%s)' (basename $PWD) (dirname (prompt_pwd))
        end
    else
        printf '%s (%s)' $_ (prompt_pwd)
    end
end
