function gcm
    # Check if llm is installed, if not, install it
    if not type -q llm
        echo "'llm' is not installed. Attempting to install it using pip..."
        if pip install llm
            echo "'llm' installed successfully."
        else
            echo "Failed to install 'llm'. Please install it manually and try again."
            return 1
        end
    end

    # Check if an API key is set up for llm
    # set llm_keys (llm keys)
    # if test "$llm_keys" = "No keys found"
    #     echo "No API key found for 'llm'. You need to set it up."
    #     llm keys set openai
    #     if test $status -ne 0
    #         echo "Failed to set up the OpenAI key. Please try again manually."
    #         return 1
    #     else
    #         echo "OpenAI key set successfully."
    #     end
    # end

    # Function to generate commit message
    function generate_commit_message
        set -l prompt_text "
Below is a diff of all changes, coming from the command:
\`\`\`
git diff --cached
\`\`\`
Write concise, informative commit messages: Start with a summary in imperative mood, explain the 'why' behind changes, keep the summary under 50 characters, use bullet points for multiple changes, avoid using the word refactor, instead explain what was done, and reference related issues or tickets. What you write will be passed to git commit -m \"[message]\""

        if contains -- -a $argv
            git diff HEAD | llm -m llama3:70b $prompt_text
        else
            git diff --cached | llm -m llama3:70b $prompt_text
        end
    end

    # Function to read user input
    function read_input
        set -l prompt $argv[1]
        read -P $prompt reply
        echo $reply
    end

    # Main script
    echo "Generating AI-powered commit message..."
    set commit_message (generate_commit_message)

    while true
        echo -e "Proposed commit message:\n"
        echo $commit_message
        echo -e ""

        set choice (read_input "Do you want to (a)ccept, (e)dit or (r)egenerate? ")

        switch $choice
            case 'a' 'A' ''
                if git commit $argv -m "$commit_message"
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                end
            case 'e' 'E'
                set commit_message (read_input "Enter your commit message: ")
                if [ -n "$commit_message" ] && git commit $argv -m "$commit_message"
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                end
            case 'r' 'R'
                echo "Regenerating commit message..."
                set commit_message (generate_commit_message)
            case 'c' 'C' 'q' 'Q'
                echo "Commit cancelled."
                return 1
            case '*'
                echo "Invalid choice. Please try again."
        end
    end
end
