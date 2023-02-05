#!/bin/bash

rocketlaunch_dir=`pwd` #from https://unix.stackexchange.com/a/52919/470623
flouser=$(logname)

unameOutM="$(uname -m)"
case "${unameOutM}" in
    i286)   flofarch="286";;
    i386)   flofarch="386";;
    i686)   flofarch="386";;
    x86_64) flofarch="amd64";;
    arm)    dpkg --print-flofarch | grep -q "arm64" && flofarch="arm64" || flofarch="arm";;
    riscv64) flofarch="riscv64"
esac

is_root=false
if [ "$([ $UID -eq 0 ] || echo "Not root")" = "Not root" ]
   then
      is_root=false
   else
      is_root=true
fi
maysudo=""
if [ "$is_root" = "false" ]
   then
      maysudo="sudo"
   else
      maysudo=""
fi

echo "Installing FantasqueSansMono font (ComicSans haters gonna hate but its cute <3)..."
pkgnm="FantasqueSansMono-Normal"
mkdir "$pkgnm"
cd "$pkgnm"
unzip ../include/nerdyfonts/"$pkgnm".zip
cd TTF
#$maysudo mv *.ttf *.TTF /usr/share/fonts/truetype/
$maysudo mv *.ttf /usr/share/fonts/truetype/
#sudo mv *.otf *.OTF /usr/share/fonts/opentype
#- Font Refresh Tip
#- After you install new fonts on Ubuntu you’re not able to use them in apps until you reboot. To avoid that, run sudo fc-cache -f -v to refresh the font cache, then logout and back in. After doing this any fonts you installed manually will be selectable in apps/extensions such as this one.
fc-cache -f -v
#- from https://www.omgubuntu.co.uk/2022/12/desktop-clock-gnome-extension
cd ../..
rm -r "$pkgnm"

if [ "$flofarch" = "amd64" ]; then
echo "Installing nushell..."
pkgnm="nu-0.74.0-x86_64-unknown-linux-gnu"
tar -xzf include/nu/nushell/"$pkgnm".tar.gz
$maysudo mv -f "$pkgnm"/nu /usr/bin/nu
$maysudo chmod +x /usr/bin/nu
rm -rf "$pkgnm"
echo "/usr/bin/nu" | $maysudo tee -a /etc/shells
#-<- should check if line is already added, before re-adding!
chsh -s /usr/bin/nu
#echo "Testing if nushell works:"
#nu
# introduce in next build
# task: enable plugins
fi

echo "Installing nu-post-install..."
cd include/nu/nu-post-install
if [ ! -e .git ]; then git clone --no-checkout https://github.com/Floflis/nu-post-install.git .; fi
if [ -e .git ]; then git pull; fi
git checkout -f
chmod +x install.sh && $maysudo sh ./install.sh
#rm -f install.sh #use noah to exclude everything except .git
#rm -f nu-script-handler
#rm -f Tasks.txt
#rm -f .gitattributes
#rm -f .gitmeta
#rm -rf rsc
cd "$rocketlaunch_dir"

echo "Installing Witchcraft Candy Colors..."
$maysudo apt-get install dconf-cli
cd include/witchcraft-candy-colors
if [ ! -e .git ]; then git clone --no-checkout https://github.com/Floflis/witchcraft-candy-colors.git .; fi
if [ -e .git ]; then git pull; fi
git checkout -f
chmod +x install.sh && ./install.sh
#rm -f install.sh #use noah to exclude everything except .git
#rm -rf colors
#rm -rf src
#rm -f INSTALL.md
#rm -f LICENSE
#rm -f readme.md
#rm -f screenshot.png
cd "$rocketlaunch_dir"

echo "Installing Starship..."
if [ "$flofarch" = "amd64" ]; then
#shit Qmf1XqY9vjU1yHDwEPj3hFBWJqtwGeUyoWPR77kYA7f65D
#curl -sS https://starship.rs/install.sh | sh
#curl -sS https://gateway.pinata.cloud/ipfs/Qmf1XqY9vjU1yHDwEPj3hFBWJqtwGeUyoWPR77kYA7f65D | sh
#curl -sS https://raw.githubusercontent.com/starship/starship/master/install/install.sh | sh
pkgnm="starship-x86_64-unknown-linux-gnu"
tar -xzf include/starship/"$pkgnm".tar.gz
$maysudo rm -f /usr/local/bin/starship
$maysudo mv -f starship /bin/starship
$maysudo chmod +x /bin/starship
echo 'eval "$(starship init bash)"' > /home/${flouser}/.bashrc # configure Starship for Bash
#-<- should check if line is already added, before re-adding!

#cat >> /home/$flouser/.config/mimeapps.list <<EOF
#
#EOF
## this is continuously adding the same entries to mimeapps.list and have to be fixed

cat >> /home/${flouser}/.config/nushell/env.nu <<EOF
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
EOF
echo 'source ~/.cache/starship/init.nu' >> /home/${flouser}/.config/nushell/config.nu
#-
#https://starship.rs/config/#prompt
#https://starship.rs/presets/pastel-powerline.html
fi
# <---- future task: check against .sha256 file; floflis icons: icon for .sha256 files and file handler for comparing

cp include/starship.svg /usr/share/icons/hicolor/scalable/apps/
$maysudo gtk-update-icon-cache /usr/share/icons/gnome/ -f
