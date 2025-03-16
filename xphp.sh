#!/bin/bash
# Shell script for switching between Brew-installed PHP versions (Nginx version)
#
# Based on the Apache version by Phil Cook and Andy Miller
# Modified for Nginx
#
# Released under the MIT License

# Supported PHP versions
brew_php_versions=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
homebrew_path=$(brew --prefix)
target_version=$1

if [[ -z "$target_version" ]]; then
    echo "PHP-FPM Switcher for Nginx - v$script_version"
    echo "Switch between Brew-installed PHP-FPM versions."
    echo
    echo "usage: $(basename "$0") version"
    echo "    version    one of:" "${brew_php_versions[@]}"
    echo
    exit
fi

php_version="php@$target_version"

for version in ${brew_php_versions[*]}; do
    if [[ -d "$homebrew_path/etc/php/$version" ]]; then
        php_installed_array+=("$version")
    fi
done

if [[ " ${brew_php_versions[*]} " == *"$target_version"* ]]; then
    if [[ " ${php_installed_array[*]} " == *"$target_version"* ]]; then
        echo "Switching to $php_version"

        current_version=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)

        if [ "$current_version" != "$target_version" ]; then
            echo "Switching from PHP $current_version to $target_version"

            brew services stop "php@$current_version" 2>/dev/null
            brew unlink "php@$current_version" 2>/dev/null
            brew link --force "$php_version" 2>/dev/null

            echo "$current_version" > /tmp/xphp-last-version
        else
            echo "Already using PHP $target_version"
        fi

        echo
        php -v
        echo

        echo "All done!"
    else
        echo "Sorry, but $php_version is not installed via brew. Install by running: brew install $php_version"
    fi
else
    echo "Unknown version of PHP. PHP Switcher can only handle versions:" "${brew_php_versions[@]}"
fi

