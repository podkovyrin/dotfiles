# Reads a list file: one name per line. `#` starts a comment; blank lines are
# ignored. `./n add` appends lines and `./n remove` deletes them, so keep each
# name on its own line.
lib: file:
lib.filter (name: name != "") (
  map (line: lib.trim (lib.head (lib.splitString "#" line))) (
    lib.splitString "\n" (builtins.readFile file)
  )
)
