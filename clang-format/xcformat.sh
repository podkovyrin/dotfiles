#!/bin/bash

CURRENT_DOCUMENT_PATH=$(osascript -e '
tell application "Xcode"
    activate
    --tell application "System Events" to keystroke "s" using {command down}
    --wait for Xcode to remove edited flag from filename
    --delay 0.3
    set last_word_in_main_window to (word -1 of (get name of window 1))
    set current_document to document 1 whose name ends with last_word_in_main_window
    set current_document_path to path of current_document
    --CURRENT_DOCUMENT_PATH is assigned last set value: current_document_path
end tell ')

### during save Xcode stops listening for file changes
# sleep 0.3 

LOGNAME=~/.lastclangformatlog.txt
echo "Filepath: ${CURRENT_DOCUMENT_PATH}" > ${LOGNAME}

clang-format-custom -i -style=file "${CURRENT_DOCUMENT_PATH}" >> ${LOGNAME} 2>&1
