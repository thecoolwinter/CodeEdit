#  codeedit_shell_integration.fish
#  CodeEdit
#
#  Created by Khan Winter on 2024-08-27.
#
#  This script is used to configure fish shells
#  so the terminal title can be set properly
#  with shell name or program's command name

function __codeedit_preexec --on-event fish_preexec
    builtin printf "\033]0;$argv\007"
end

function __codeedit_postexec --on-event fish_postexec
   builtin printf "\033]0;fish\007"
end
