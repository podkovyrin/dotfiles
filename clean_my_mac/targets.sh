targets() {
  local TRASH_FOLDER="$HOME/.Trash/*"
  local USER_CACHE="$HOME/Library/Caches/*"
  local SYSTEM_CACHE="/Library/Caches/*"
  local USER_LOGS="$HOME/Library/Logs/*"
  local SYSTEM_LOGS="Library/Logs/*"
  local APP_CACHE="$HOME/Library/Containers/*/Data/Library/Caches/*"

  echo "$TRASH_FOLDER:$USER_CACHE:$SYSTEM_CACHE:$USER_LOGS:$SYSTEM_LOGS:$APP_CACHE"
}