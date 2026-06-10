#!/bin/bash
# =============================================================================
# HYPRCTL COMPLETIONS (zsh)
# =============================================================================
# Overrides the broken upstream _hyprctl which contains dispatcher subcommands
# instead of top-level commands.

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  _hyprctl_custom() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a commands
    commands=(
      'activewindow:Gets the active window name and its properties'
      'activeworkspace:Gets the active workspace and its properties'
      'animations:Gets the current config info about animations and beziers'
      'binds:Lists all registered binds'
      'clients:Lists all windows with their properties'
      'configerrors:Lists all current config parsing errors'
      'cursorpos:Gets the current cursor position in global layout coordinates'
      'decorations:Lists all decorations and their info'
      'devices:Lists all connected keyboards and mice'
      'dismissnotify:Dismisses all or up to AMOUNT notifications'
      'dispatch:Issue a dispatch to call a keybind dispatcher with arguments'
      'getoption:Gets the config option status (values)'
      'globalshortcuts:Lists all global shortcuts'
      'hyprpaper:Issue a hyprpaper request'
      'hyprsunset:Issue a hyprsunset request'
      'instances:Lists all running instances of Hyprland with their info'
      'keyword:Issue a keyword to call a config keyword dynamically'
      'kill:Get into a kill mode to kill an app by clicking'
      'layers:Lists all the surface layers'
      'layouts:Lists all layouts available (including plugin ones)'
      'monitors:Lists active outputs with their properties'
      'notify:Send a notification using the built-in Hyprland notification system'
      'output:Allows you to add and remove fake outputs'
      'plugin:Issue a plugin request'
      'reload:Force reload the config'
      'rollinglog:Prints tail of the log'
      'setcursor:Set the cursor theme and reloads the cursor manager'
      'seterror:Set the hyprctl error string'
      'setprop:Set a property of a window'
      'splash:Print the current random splash'
      'switchxkblayout:Set the xkb layout index for a keyboard'
      'systeminfo:Print system info'
      'version:Print the Hyprland version'
      'workspacerules:Get the list of defined workspace rules'
    )

    _arguments -C \
      '(-h --help)'{-h,--help}'[Prints the help message]' \
      '(-j --batch)'{-j,--batch}'[Execute a batch of commands separated by ;]' \
      '(-i --instance)'{-i,--instance}'[Specify the Hyprland instance]:instance: ' \
      '(-q --quiet)'{-q,--quiet}'[Quiet mode]' \
      '-r[Refresh state after issuing the command]' \
      ': :->command' \
      '*:: :->args'

    case "$state" in
      command)
        _describe -t commands 'hyprctl command' commands
        ;;
      args)
        case "$line[1]" in
          dispatch)         _hyprctl_custom_cmd_dispatch         ;;
          keyword)          _hyprctl_custom_cmd_keyword          ;;
          monitors)         _hyprctl_custom_cmd_monitors         ;;
          reload)           _hyprctl_custom_cmd_reload           ;;
          decorations)      _hyprctl_custom_cmd_decorations      ;;
          getoption)        _hyprctl_custom_cmd_getoption        ;;
          dismissnotify)     _hyprctl_custom_cmd_dismissnotify    ;;
          rollinglog)       _hyprctl_custom_cmd_rollinglog       ;;
          setprop)          _hyprctl_custom_cmd_setprop          ;;
          switchxkblayout)  _hyprctl_custom_cmd_switchxkblayout  ;;
          output)           _hyprctl_custom_cmd_output           ;;
        esac
        ;;
    esac
  }

  _hyprctl_custom_cmd_dispatch() {
    _arguments \
      '1: :_hyprctl_custom_dispatchers' \
      '*::dispatcher arguments: '
  }

  _hyprctl_custom_cmd_keyword() {
    _arguments \
      '1:keyword name: ' \
      '2:keyword value: '
  }

  _hyprctl_custom_cmd_monitors() {
    _alternative \
      'all:List all monitors including inactive:()' \
      'monitor:Monitor name:_hyprctl_custom_monitors'
  }

  _hyprctl_custom_cmd_reload() {
    local -a opts
    opts=('config-only:Reload only the config file')
    _describe -t reload_opts 'reload option' opts
  }

  _hyprctl_custom_cmd_decorations() {
    _arguments '1:window regex:_hyprctl_custom_windows'
  }

  _hyprctl_custom_cmd_getoption() {
    _arguments '1:config option: '
  }

  _hyprctl_custom_cmd_dismissnotify() {
    _arguments '1:amount of notifications: '
  }

  _hyprctl_custom_cmd_rollinglog() {
    _arguments '(-f --follow)'{-f,--follow}'[Follow log output]'
  }

  _hyprctl_custom_cmd_setprop() {
    _arguments \
      '1:window address or class:_hyprctl_custom_windows' \
      '2:property name: ' \
      '3:value: '
  }

  _hyprctl_custom_cmd_switchxkblayout() {
    _arguments \
      '1:keyboard device:_hyprctl_custom_keyboards' \
      '2:layout index or name: '
  }

  _hyprctl_custom_cmd_output() {
    local -a actions
    actions=('create:Create a fake output' 'remove:Remove a fake output')
    _describe -t output_actions 'output action' actions
  }

  _hyprctl_custom_dispatchers() {
    local -a dispatchers
    dispatchers=(
      'exec:Execute a shell command'
      'execr:Execute a shell command (raw)'
      'killactive:Kill the active window'
      'closewindow:Close a window'
      'workspace:Change to a workspace'
      'movetoworkspace:Move active window to a workspace'
      'swapactiveworkspaces:Swap active workspaces between monitors'
      'togglespecialworkspace:Toggle a special workspace'
      'fullscreen:Toggle fullscreen state'
      'fullscreenstate:Toggle fullscreen state'
      'fakefullscreen:Toggle fake fullscreen'
      'togglefloating:Toggle floating state of a window'
      'setfloating:Set a window to floating'
      'settiled:Set a window to tiled'
      'pin:Pin a window'
      'movefocus:Move focus in a direction'
      'movewindow:Move a window in a direction'
      'swapwindow:Swap a window with another'
      'centerwindow:Center a window'
      'resizeactive:Resize the active window'
      'movewindowpixel:Move window by pixels'
      'resizewindowpixel:Resize window by pixels'
      'cyclenext:Cycle to next window'
      'splitratio:Change split ratio'
      'togglegroup:Toggle window group'
      'lockactivegroup:Lock the active group'
      'changegroupactive:Change active group'
      'moveintogroup:Move a window into a group'
      'moveoutofgroup:Move a window out of a group'
      'movegroupwindow:Move a group window'
      'movewindoworgroup:Move window or group'
      'denywindowfromgroup:Deny window from group'
      'setignoregrouplock:Set ignore group lock'
      'renameworkspace:Rename a workspace'
      'exit:Exit Hyprland session'
      'submap:Set a submap'
      'togglesplit:Toggle split orientation'
      'toggleopaque:Toggle opaque'
      'dpms:Set DPMS state'
      'pass:Pass key to window'
      'sendshortcut:Send shortcut'
      'global:Global dispatcher'
      'mouse:Mouse dispatcher'
      'movecursortocorner:Move cursor to corner'
      'movecursor:Move cursor to position'
      'setcursor:Set cursor theme'
      'setprop:Set a property'
      'swapnext:Swap with next window'
      'focusmonitor:Focus a monitor'
      'movecurrentworkspacetomonitor:Move current workspace to a monitor'
      'moveworkspacetomonitor:Move a workspace to a monitor'
      'focusworkspaceoncurrentmonitor:Focus workspace on current monitor'
      'focusurgentorlast:Focus urgent or last window'
      'focuscurrentorlast:Focus current or last window'
      'tagwindow:Tag a window'
      'alterzorder:Alter z-order of a window'
      'forcenoblur:Toggle force no blur'
      'forcenoborder:Toggle force no border'
      'forcenoanims:Toggle force no animations'
      'forcenodim:Toggle force no dim'
      'forceopaque:Toggle force opaque'
      'forceopaqueoverriden:Toggle force opaque override'
      'forceallowsinput:Toggle force allows input'
      'windowdancecompat:Toggle window dance compatibility'
      'nomaxsize:Toggle no max size'
      'minsize:Set minimum size'
      'maxsize:Set maximum size'
      'alpha:Set window opacity'
      'alphafullscreen:Set fullscreen opacity'
      'alphainactive:Set inactive opacity'
      'alphafullscreenoverride:Set fullscreen opacity override'
      'alphainactiveoverride:Set inactive opacity override'
      'activebordercolor:Set active border color'
      'inactivebordercolor:Set inactive border color'
      'bordersize:Set border size'
      'rounding:Set rounding'
      'dimaround:Dim around window'
      'keepaspectratio:Keep aspect ratio'
      'nofocus:Set nofocus'
      'lockgroups:Lock groups'
    )
    _describe -t dispatchers 'dispatcher' dispatchers
  }

  _hyprctl_custom_monitors() {
    if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
      local -a monitors
      local line
      while IFS= read -r line; do
        monitors+=("$line")
      done < <(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)
      [[ ${#monitors} -gt 0 ]] && _describe -t monitors 'monitor' monitors
    fi
  }

  _hyprctl_custom_keyboards() {
    if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
      local -a keyboards
      local line
      while IFS= read -r line; do
        keyboards+=("$line")
      done < <(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[].name' 2>/dev/null)
      [[ ${#keyboards} -gt 0 ]] && _describe -t keyboards 'keyboard' keyboards
    fi
  }

  _hyprctl_custom_windows() {
    if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
      local -a windows
      local line
      while IFS= read -r line; do
        windows+=("$line")
      done < <(hyprctl clients -j 2>/dev/null | jq -r '.[].address' 2>/dev/null)
      [[ ${#windows} -gt 0 ]] && _describe -t windows 'window address' windows
    fi
  }

  compdef _hyprctl_custom hyprctl
fi

if [[ -n "$SHELL_DEBUG" ]]; then
  echo "[DEBUG] 25_completions/03_hyprctl.sh loaded - hyprctl completions"
fi
