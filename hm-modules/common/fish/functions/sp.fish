function sp --description "Run previous command as root"
  if count $argv > /dev/null
    if [ $history[$argv[1]] = "sp" ]
      sp (math $argv[1] + 1)
    else
      eval command sudo $history[$argv[1]]
    end
  else
    sp 1
  end
end
