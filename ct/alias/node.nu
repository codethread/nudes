export def npc [] {
  rm -rf ./node_modules 
    npm cache clear
    npm i
}

export alias npl = npm -g ls --depth=0

# INVALID multiline
# export alias yy = eval \$(cat package.json | jq -S '.scripts' | sed '1d;$d' | fzf -i --header='[run:]' | sed -E \"s/\\\"(.*)\\\":.*/yarn run \\1/\" )

export def pjs [...deps: string] {
  let search = ($deps | str join "|" | $"\(($in)\)")

  fd package.json
    | lines
    | par-each {|| nuopen $in }
    | where {|| "dependencies" in $in }
    | par-each {|pj|
        let found = ($pj | get dependencies | transpose name version | where name =~ $search)
        if ($found | is-not-empty) {
          $found | insert package $pj.name
        }
    }
    | reduce {|it, acc| $acc ++ $it }
    | move package --before name
}

export def rn-nuke [] {
  gnuke 
    yarn 
    cd ios 
    pod install 
    cd .. 
    yarn run-ios --reset-cache
}

##############################################
# work
##############################################

export def nvm [] {
  volta pin node@14 
    volta pin yarn@1.22.4
}

export def react-native-clean [] { 
  git pull 
    gclean 
    yarn 
    yarn install:app 
    yarn run-ios --simulator "iPhone SE (3rd generation)"
}
