#!/bin/bash
#-----------------------------------
# Author: Qingxu (huanruomengyun)
# Description: Termux Tools
# Repository Address: https://github.com/huanruomengyun/Termux-Tools
# Version: 0.1
# Copyright (c) 2020 Qingxu
#-----------------------------------
function blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
function green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
function red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
if [[ $EUID -eq 0 ]]; then
    red "检测到您正在尝试使用 ROOT 权限运行该脚本"
    red "这是不建议且不被允许的"
    red "该脚本不需要 ROOT 权限,且以 ROOT 权限运行可能会带来一些无法预料的问题"
    red "为了您的设备安全，请避免在任何情况下以 ROOT 用户运行该脚本"
    exit 0
fi
blue "为确保脚本正常运行，每次运行脚本都将会强制进行初始化"
blue "给您带来的不便还请见谅"
green "Initializing……"
apt update && apt upgrade -y
green "Completely!!"
clear
green "初始化完成!"
green "确认您的系统信息中……"
date=$(date)
log=log_date.log
mkdir -p $HOME/logs
rm -f $HOME/logs/*log_*.log
touch $HOME/logs/tmp_$log
echo -e "====Device info====\n\n" >> $HOME/logs/tmp_$log
echo "$date" >> $HOME/logs/tmp_$log
echo "<----Props---->" >> $HOME/logs/tmp_$log
getprop >> $HOME/logs/tmp_$log
echo -e "\n\n" >> $HOME/logs/tmp_$log
echo "<----System info---->" >> $HOME/logs/tmp_$log
echo "Logged In users:" >> $HOME/logs/tmp_$log
whoami >> $HOME/logs/tmp_$log
echo -e "\n\n" >> $HOME/logs/tmp_$log
echo "<----Hardware info---->" >> $HOME/logs/tmp_$log
echo "CPU info:"
lscpu >> $HOME/logs/tmp_$log
echo "Memory and Swap info:" >> $HOME/logs/tmp_$log
free -h >> $HOME/logs/tmp_$log
echo "Internet info:" >> $HOME/logs/tmp_$log
ifconfig >> $HOME/logs/tmp_$log
echo "Disk Usages :" >> $HOME/logs/tmp_$log
df -h >> $HOME/logs/tmp_$log
mv -f $HOME/logs/tmp_$log $HOME/logs/$log
green "系统信息确认完毕!!"
green "您马上就可以进入脚本!"
clear
function menu(){
    blue "==================================="
    blue "Termux Configure"
	echo -e "       By Qingxu (huanruomengyun)"  
	blue "==================================="
	echo -e "\n\n"
	blue "月落乌啼霜满天，江枫渔火对愁眠"
	blue "                  姑苏城外寒山寺，夜半钟声到客船"
#	if  [ $(which fortune) = /data/data/com.termux/files/usr/bin/fortune ]; then
#    fortune
#else
#    pkg in fortune -y
#    fortune
#fi
    echo -e "\n\n\n"
	echo -e " 1   更换清华源\n"
	sleep 0.016
	echo -e " 2   底部小键盘扩展\n"
	sleep 0.016
	echo -e " 3   获取存储权限\n"
	sleep 0.016
	echo -e " 4   安装 ZSH\n"
	sleep 0.016
	echo -e " 5   Termux 扩展\n"
	sleep 0.016
	echo -e " 6   实用工具安装\n"
	sleep 0.016
	echo -e " 7   获取手机信息\n"
	sleep 0.016
	echo -e " 8   Linux 发行版安装           99   日志管理\n"
	sleep 0.016
	echo -e "                              0   退出\n\n\n"
	echo -en "\t\tEnter an option: "
    read option
}

function mirrors(){
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
apt update && apt upgrade -y
}

function storage(){
termux-setup-storage
return 0
}

function board(){
if test -d ~/.termux/ ; then
				:
			else
				mkdir -p ~/.termux/
			fi
			echo -e "extra-keys = [['TAB','>','-','~','/','*','$'],['ESC','(','HOME','UP','END',')','PGUP'],['CTRL','[','LEFT','DOWN','RIGHT',']','PGDN']]" > ~/.termux/termux.properties
			termux-reload-settings
green  "请重启终端使小键盘显示正常"
return 0
}

function installzsh(){
            rc=~/.zshrc
            touch ~/.hushlogin
            #Zsh
            pkg in zsh git curl -y
            green "如果下面需要您进行确认，请输入 y 确认"
            chsh -s zsh
            sh -c "$(sed -e "/exec zsh -l/d" <<< $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh))"
            #Plugins
            git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
            git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
            git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
            sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g" $rc
            sed -i "s/plugins=(git)/plugins=(git extract web-search zsh-autosuggestions zsh-completions zsh-syntax-highlighting)/g" $rc
            green "ZSH 配置完成，你可在 ~/.zshrc 中修改主题"
}

function sudoconfig(){
if [ -f "/data/data/com.termux/files/usr/bin/sudo" ];then
  sudostatus=true
  else
  sudostatus=false
fi
echo -e "\n\n"
blue "sudo 安装状态: $sudostatus"
echo -e "\n\n"
echo -e "1 安装 sudo\n"
echo -e "2 修复 sudo\n"
echo -e "0 退出\n"
echo -en "\t\tEnter an option: "
read sudoinstall
case $sudoinstall in
1)
if  [ $sudostatus = true ]; then
    blue "您已安装 sudo,请勿重复安装"
    blue "如果 sudo 使用出现问题,请选择 修复sudo"
    return 0
fi
git clone https://gitlab.com/st42/termux-sudo.git $HOME/termux-sudo
cat $HOME/termux-sudo/sudo > /data/data/com.termux/files/usr/bin/sudo
chmod 700 /data/data/com.termux/files/usr/bin/sudo
if [ -f "/data/data/com.termux/files/usr/bin/sudo" ];then
  green "sudo 已成功安装到了您的 Termux"
  else
  green "脚本运行失败!请检查网络连接或提交日志"
fi
echo "安装脚本运行完毕"
return 0 ;;
2)
echo "脚本开发中,敬请期待"
return 0 ;;
0)
return 0 ;;
*)
red "无效输入,请重试"
sudoconfig ;;
esac
}

function termuxplugin(){
echo -e "1 sudo 安装\n"
sleep 0.016
echo -e "2 图形化界面安装\n"
sleep 0.016
echo -e "0 退出\n"
sleep 0.016
echo -en "\t\tEnter an option: "
read termuxchoose
case $termuxchoose in
1)
sudoconfig ;;
2)
termuxgui ;;
0)
return 0 ;;
*)
red "无效输入,请重试" 
termuxplugin ;;
esac
}

function termuxgui(){
pkg i -y x11-repo
pkg up -y
pkg i -y xfce tigervnc openbox aterm
echo -e "#\!/bin/bash -e\nam start com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity\nexport DISPLAY=:1\nXvnc -geometry 720x1440 --SecurityTypes=None \$DISPLAY&\nsleep 1s\nopenbox-session&\nthunar&\nstartxfce4">~/startvnc
chmod +x ~/startvnc
mv -f ~/startvnc $PREFIX/bin/
if [ -f "$PREFIX/bin/startvnc" ];then
echo "Termux GUI 安装完成!"
green "输入 startvnc 即可启动 VNC 服务"
green "输入 Ctrl+C 即可终止 VNC 服务"
green "在启动 VNC 服务前，请安装 VNC Viewer"
green "下载链接: https://play.google.com/store/apps/details?id=com.realvnc.viewer.android"
else
echo "Termux GUI 安装失败"
fi
return 0
}

function tools(){
echo -e "\n\n"
echo -e "1 Hexo 配置安装"
echo -e "2 ADB 配置安装"
echo -e "3 you-get 配置安装"
echo -e "0 退出"
echo -en "\t\tEnter an option: "
read toolsinstall
case $toolsinstall in
1)
hexo ;;
2)
adbconfig ;;
3)
yougetconfig ;;
0)
return 0 ;;
*)
red "无效输入,请重试" 
tools ;;
esac
return 0
}

function hexo(){
pkg in wget -y
wget https://raw.githubusercontent.com/huanruomengyun/Termux-Hexo-installer/master/hexo-installer.sh && sh hexo-installer.sh
return 0
}

function Linux(){
echo -e "1 Ubuntu\n"
sleep 0.016
echo -e "2 Debian\n"
sleep 0.016
echo -e "3 Kali Linux\n"
sleep 0.016
echo -e "4 CentOS\n"
sleep 0.016
echo -e "5 Arch Linux\n"
sleep 0.016
echo -e "0 退出"
sleep 0.016
echo -en "\t\tEnter an option: "
read installlinux
case $installlinux in
1)
ubuntu ;;
2)
debian ;;
3)
kali ;;
4)
centos ;;
5)
archlinux ;;
0)
return 0 ;;
*)
red "无效输入,请重试"
esac
return 0
}

function ubuntu(){
green "是否安装桌面环境?[y/n]"
echo -en "\t\tEnter an option: "
read ubuntude
case $ubuntude in
y)
ubuntudechoose ;;
n)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu.sh && chmod +x ubuntu.sh && bash ubuntu.sh ;;
t)
echo "Working" ;;
*)
echo "无效输入，请重试" ;;
esac
return 0
}

function ubuntudechoose(){
echo -e "1 XFCE"
sleep 0.016
echo -e "2 LXDE"
sleep 0.016
echo -e "3 LXQT"
sleep 0.016
echo -e "0 取消"
sleep 0.016
echo -en "\t\tEnter an option: "
read udechoose
case $udechoose in
1)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu-xfce.sh && chmod +x ubuntu-xfce.sh && bash ubuntu-xfce.sh ;;
2)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu-lxde.sh && chmod +x ubuntu-lxde.sh && bash ubuntu-lxde.sh ;;
3)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Ubuntu/ubuntu-lxqt.sh && chmod +x ubuntu-lxqt.sh && bash ubuntu-lxqt.sh ;;
0)
return 0 ;;
*)
red "无效输入，请重试" 
ubuntudechoose;;
esac
return 0
}

function debian(){
green "是否安装桌面环境?[y/n]"
echo -en "\t\tEnter an option: "
read debiande
case $debiande in
y)
debiandechoose ;;
n)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Debian/debian.sh && chmod +x debian.sh && bash debian.sh ;;
t)
echo "Working" ;;
*)
echo "无效输入，请重试" ;;
esac
return 0
}

function debiandechoose(){
echo -e "1 XFCE"
sleep 0.016
echo -e "2 LXDE"
sleep 0.016
echo -e "3 LXQT"
sleep 0.016
echo -e "0 取消"
sleep 0.016
echo -en "\t\tEnter an option: "
read ddechoose
case $ddechoose in
1)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Debian/debian-xfce.sh && chmod +x debian-xfce.sh &&  bash debian-xfce.sh ;;
2)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Debian/debian-lxde.sh && chmod +x debian-lxde.sh bash debian-lxde.sh ;;
3)
pkg update -y && pkg install wget curl proot tar -y && wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Installer/Debian/debian-lxqt.sh && chmod +x debian-lxqt.sh bash debian-lxqt.sh ;;
0)
return 0 ;;
*)
red "无效输入，请重试" 
debiandechoose;;
esac
return 0
}

function centos(){
cd $HOME
echo -e "\n\n"
echo -e "1 安装 CentOS\n"
echo -e "2 卸载 CentOS\n"
echo -e "0 退出\n"
echo -en "\t\tEnter an option: "
read centosde
case $centosde in
1)
pkg install wget openssl-tool proot tar -y && hash -r && wget https://raw.githubusercontent.com/EXALAB/AnLinux-Resources/master/Scripts/Installer/CentOS/centos.sh && bash centos.sh ;;
2)
wget https://raw.githubusercontent.com/EXALAB/AnLinux-Resources/master/Scripts/Uninstaller/CentOS/UNI-centos.sh && bash UNI-centos.sh ;;
*)
red "无效输入，请重试" 
centos ;;
esac
return 0
}

function kali(){
pkg install wget
wget -O install-nethunter-termux https://offs.ec/2MceZWr
chmod +x install-nethunter-termux
./install-nethunter-termux
return 0
}

function archlinux(){
echo -e "\n\n"
echo -e "1 安装 Arch Linux\n"
echo -e "2 修复 Arch Linux 安装\n"
echo -e "0 退出"
echo -en "\t\tEnter an option: "
read archlinuxinstall
case $archlinuxinstall in
1)
termuxarch ;;
2)
echo "脚本制作中,敬请期待" ;;
0)
return 0 ;;
*)
red "无效输入，请重试"
archlinux ;;
esac
return 0
}

function termuxarch(){
pkg i bsdtar nano proot wget
wget -c https://raw.githubusercontent.com/TermuxArch/TermuxArch/master/setupTermuxArch.bash 
bash setupTermuxArch.bash
cp ~/arch/startarch $PREFIX/bin/startarch
if [ -f "$PREFIX/bin/startarch" ];then
echo "Arch Linux 安装完成!"
else
echo "Arch Linux 安装失败，请运行修复脚本"
fi
return 0
}


function adbconfig(){
echo -e "\n\n"
echo -e "项目地址: https://github.com/MasterDevX/Termux-ADB"
echo -e "\n\n1 安装 ADB\n"
echo -e "2 卸载 ADB\n"
echo -e "3 查看 ADB 版本\n"
echo -e "0 退出\n"
echo -en "\t\tEnter an option: "
read adbinstall
case $adbinstall in
1)
apt update && apt install wget
wget https://github.com/MasterDevX/Termux-ADB/raw/master/InstallTools.sh
bash InstallTools.sh
return 0 ;;
2)
apt update
apt install wget
wget https://github.com/MasterDevX/Termux-ADB/raw/master/RemoveTools.sh
bash RemoveTools.sh
return 0 ;;
3)
if [ -f "/data/data/com.termux/files/usr/bin/adb" ];then
adb version
else
red "请先安装 ADB"
fi
return 0 ;;
0)
return 0 ;;
*)
red "无效输入,请重试" 
adbconfig ;;
esac
}

function yougetconfig(){
echo -e "\n\n项目地址: https://github.com/soimort/you-get/\n\n"
echo -e "1 安装 you-get\n"
echo -e "2 升级 you-get\n"
echo -e "3 you-get 使用方法\n"
echo -e "4 you-get 简易版(适合超小白用户)\n"
echo -e "5 卸载 you-get\n"
echo -e "0 退出\n"
echo -en "\t\tEnter an option: "
read yougetoption
case $yougetoption in
1)
pip3 install you-get
green "done!"
return 0 ;;
2)
pip3 install --upgrade you-get
green "done!"
return 0 ;;
3)
if [ -f "/data/data/com.termux/files/usr/bin/you-get" ];then
you-get -h
else
red "请先安装 you-get"
fi
yougetconfig ;;
4)
if [ -f "/data/data/com.termux/files/usr/bin/you-get" ];then
yougeteasy
else
red "请先安装 you-get"
yougetconfig
fi
;;
5)
yes | pip uninstall you-get
return 0 ;;
0)
return 0 ;;
*)
red "无效输入,请重试" 
yougetconfig ;;
esac
}

function yougeteasy(){
echo -e "\n\n"
blue "简易版脚本制作非常粗糙"
blue "简易版仅面向极端小白用户/终端无操作能力者"
blue "如果可以,我强烈建议使用原版 you-get 而非简易版"
echo -e "\n\n"
echo -e "1 开始\n"
echo -e "0 退出\n"
echo -en "\t\tEnter an option: "
read tmpyouget
case $tmpyouget in
1)
youget1 ;;
0)
return 0 ;;
*)
red "无效输入,请重试" 
yougeteasy ;;
esac 
}
function youget1(){
echo -e "\n\n"
echo "you-get 支持的链接种类请打开这个链接查看: https://github.com/soimort/you-get/wiki/%E4%B8%AD%E6%96%87%E8%AF%B4%E6%98%8E#%E6%94%AF%E6%8C%81%E7%BD%91%E7%AB%99"
echo "you-get 也可以下载网页上的视频和图片"
echo -e "请输入您的下载链接(必填)"
echo -en "\t\tEnter: "
read yougetlink
echo -e "请输入您的下载路径(选填,路径默认指向内置存储.比如,如果你输入 Download,则文件会下载至内置存储的 Download 文件夹中)"
green "看不懂就直接回车"
echo -en "\t\tEnter: "
read tmpdiryouget
echo -e "如果您输入的链接属于某一播放列表里面的一个,您是否想下载该列表里面的所有视频?(y/n)"
echo -en "\t\tEnter: "
read tmpyougetlist
if  [ $tmpyougetlist = y ]; then
yougetlist=-list
fi
yougetdownloaddir=/sdcard/$tmpdiryouget
blue "下载即将开始..."
you-get -o $yougetdownloaddir $yougetlist $yougetlink
green "下载已停止!"
green "这可能是因为所需下载内容已下载完毕,或者下载中断"
return 0
}

function logsgen(){
date=$(date)
log=log_gen.log
mkdir -p $HOME/logs
touch $HOME/logs/tmp_$log
echo -e "====Device info====\n\n" >> $HOME/lo8gs/tmp_$log
echo -e "$log" >> $HOME/logs/tmp_$log
echo "<----Props---->" >> $HOME/logs/tmp_$log
getprop >> $HOME/logs/tmp_$log
echo -e "\n\n" >> $HOME/logs/tmp_$log
echo "<----System info---->" >> $HOME/logs/tmp_$log
echo "Logged In users:" >> $HOME/logs/tmp_$log
whoami >> $HOME/logs/tmp_$log
echo -e "\n\n" >> $HOME/logs/tmp_$log
echo "<----Hardware info---->" >> $HOME/logs/tmp_$log
echo "CPU info:"
lscpu >> $HOME/logs/tmp_$log
echo "Memory and Swap info:" >> $HOME/logs/tmp_$log
free -h >> $HOME/logs/tmp_$log
echo "Internet info:" >> $HOME/logs/tmp_$log
ifconfig >> $HOME/logs/tmp_$log
echo "Disk Usages :" >> $HOME/logs/tmp_$log
df -h >> $HOME/logs/tmp_$log
mv -f $HOME/logs/tmp_$log $HOME/logs/$log
if [ -f "$HOME/logs/$log" ];then
      green "日志生成成功!"
else
      red "日志生成失败!"
fi
return 0
}

function logs(){
red "请不要在任何非必要的情况下将日志发送给任何人!!"
green "日志会在每次脚本初始化时自动生成"
green "旧的日志会在每次脚本初始化时自动删除"
echo -e "\n\n"
echo -e "1 查看日志\n"
echo -e "2 立即生成日志\n"
echo -e "3 清空日志\n"
echo -e "0 退出\n"
echo -en "\t\tEnter an option: "
read logschoose
case $logschoose in
1)
cat $HOME/logs/$log
return 0 ;;
2)
logsgen ;;
3)
rm -f $HOME/logs/*log_*.log 
return 0 ;;
0)
return 0 ;;
*)
red "无效输入,请重试"
logs ;;
esac
}

while [ 1 ]
do
    menu
    case $option in
    0)
        exit 0 ;;
    1)
        mirrors ;;
    2)
        board ;;
    3)
        storage ;;
    4)
        installzsh ;;
    5)
        termuxplugin ;;
    6)
        tools ;;
    7)
        termuxapi ;;
    8)
        Linux ;;
    99) 
        logs ;;
    *)
        red "无效输入，请重试" ;;
    esac
    echo -en "\n\n\t\t\t点击任意键以继续"
    read -n 1 line
done
clear