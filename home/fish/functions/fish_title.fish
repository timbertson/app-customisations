function fish_title
    if [ $_ = 'fish' ]
        if [ $PWD = $HOME ]
          printf '~'
        else
          printf (basename $PWD)' ('(dirname (prompt_pwd))')'
        end
        printf '$'
    else
        printf $_' ('(prompt_pwd)')'
    end
end
