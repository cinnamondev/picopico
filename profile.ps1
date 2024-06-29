$ZSH = 0
[]
Get-Content Resolve-Path /etc/shells | ForEach-Object {
  if($_ -match .+zsh){
    $ZSH = 1
  }
  # more shell checking goes here...
}

if (($ZSH -eq 1) -and (-not $(Test-Path $(Resolve-Path ~/.profile)))) {
  touch ~/.zprofile
}


if (-not $(Test-Path $(Resolve-Path ~/.profile))) {
  touch ~/.profile
}

Get-Content Resolve-Path ~/.profile | ForEach-Object {
    if($_ -match ""){

    }

}