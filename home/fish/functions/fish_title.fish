function fish_title
    if [ $_ = 'fish' ]
        printf '#'
        if [ $PWD = $HOME ]
          printf '~'
        else
          printf (basename $PWD)' ('(dirname (prompt_pwd))')'
        end
    else
        printf $_' ('(prompt_pwd)')'
    end
end
