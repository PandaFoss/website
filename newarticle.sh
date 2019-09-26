#!/usr/bin/env bash

check_dependencies() {
    if [[ ! -f /usr/bin/pandoc ]]; then DEPS="$DEPS pandoc "; fi
    if [[ ! -f /usr/bin/git ]]; then DEPS+="git "; fi
    if [[ ! -z "$DEPS" ]]; then
        echo -en "Missing dependencies: ${DEPS}\n\nInstall missing dependencies now? [y/N]: "
        read -r INPUT

        case ${INPUT} in
            y|Y|s|S) sudo pacman -Sy ${DEPS} ;;
            *) echo "Error: Missing dependencies, exiting."
            exit 1
            ;;
        esac
    fi
    echo -e "Dependencies satisfied!\n"
}

new_file() {
    touch /tmp/newpost.html
    TEMP_FILE="/tmp/newpost.html"
}

set_tag() {
    echo -e "Select one of the following tags [1|2]:\n"
    echo -e "1. Releases"
    echo -e "2. News"
    read -p "?> " TAG </dev/tty
    case "$TAG" in
        1|1.)
            echo -e "\t\t\t\t\t\t\t\t\t<div class=\"filterDiv releases\">\n" > $TEMP_FILE
            ;;
        2|2.)
            echo -e "\t\t\t\t\t\t\t\t\t<div class=\"filterDiv news\">\n" > $TEMP_FILE
            ;;
        *) echo "Unknown tag"; exit 1;
            ;;
    esac
}

set_title() {
    read -p "New title: " TITLE </dev/tty
    echo -e "\t\t\t\t\t\t\t\t\t\t<h2 class=\"post\">$TITLE</h2>\n" >> $TEMP_FILE
    echo ""
}

set_subtitle() {
    DATE=$(LC_ALL=C date -u "+%B %d, %Y")
    
    if [[ -f $HOME/.gitconfig ]]; then
        GIT_USER="$(git config user.name)"
    else
        echo "You must log in with your GitHub account before!"
        echo ""
        echo "Try this:"
        echo "$ git config --global user.name \"<your_username_here>\""
        exit 1
    fi
    
    SUBTITLE="${DATE} by ${GIT_USER}"
    echo -e "\t\t\t\t\t\t\t\t\t\t<h6 class=\"post\"><b>$SUBTITLE</b></h6>\n" >> $TEMP_FILE
    echo ""
}

set_article() {
    echo "Select a format to create the article [1|2]:"
    echo ""
    echo "1. HTML"
    echo "2. Markdown"
    echo ""
    read -p "?> " EXT </dev/tty
    case "$EXT" in
        1|1.)
            clear
            echo -e "\n###########################################################"
            echo -e "# Type the article in HTML format and then press Ctrl + D #"
            echo -e "###########################################################\n"
            pandoc -f html -t html --preserve-tabs >> $TEMP_FILE
            ;;
        2|2.)
            clear
            echo -e "\n###############################################################"
            echo -e "# Type the article in Markdown format and then press Ctrl + D #"
            echo -e "###############################################################\n"
            pandoc -f markdown -t html >> $TEMP_FILE
            ;;
        *) exit 1;
    esac
    echo -e "<hr \\>\n</div>" >> $TEMP_FILE
}

welcome() {
    echo -e "\n------------------------------------------------------------";
    echo -e "| Welcome to the Anarchy Linux web article creation wizard |";
    echo -e "------------------------------------------------------------\n";
}

create_new_post() {
    new_file
    set_tag
    set_title
    set_subtitle
    set_article
    POST_FILE="$PWD/temp.html"
    LINE_NUMBER=$(grep -n "<\!-- Mark for script -->" "$POST_FILE" | grep -Eo '^[^:]+')+1
    cp "$POST_FILE" "$POST_FILE".bak
    echo "$(awk 'FNR=='$LINE_NUMBER'{system("cat '$TEMP_FILE'")} 1' "$POST_FILE")" > $POST_FILE
}

finish() {
    echo -e "Post creation completed successfully!\n\n";
    sleep 1;
}

main() {
    welcome
    read -p "Do you want to create a new article? [y/N] " option </dev/tty
    echo ""
    case "$option" in
        y|Y|s|S)
            check_dependencies
            create_new_post
            finish
            ;;
        *) exit 1
            ;;
    esac
}

main
