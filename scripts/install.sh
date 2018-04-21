#!/bin/bash

# Config
CLAYMORE_MINER_GZIP='claymore_11.6._quickfix'
MINER_COOLDOWN=15
MINER_COOLDOWN=30
WELCOME_MESSAGE="${CYAN}Welcome to the johnnyhuy/ubuntu-etheruem-miner installer${RESET}"

# Colors
RESET='\033[0m'
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

if [[ $EUID > 0 ]]; then
    echo -e $WELCOME_MESSAGE
    echo -e "${RED}Permission denied, please run this script in root/sudo${RESET}"
    exit 1
fi

echo -e $WELCOME_MESSAGE
echo -e "${YELLOW}Running this script in root/sudo"

echo -e "${YELLOW}\nUpdating/Upgrading Ubuntu packages"
add-apt-repository ppa:graphics-drivers/ppa -y
apt-get update
# apt-get upgrade -y

echo -e "${YELLOW}\nInstalling Ubuntu utilities (git, vim etc.)"
apt-get install git vim screen openssh-server -y

echo -e "${YELLOW}\nDisabling nouveau"
touch '/etc/modprobe.d/blacklist-nouveau.conf'
echo -e "blacklist nouveau\noptions nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf

echo -e "${YELLOW}\nInstalling Nvidia drivers"
apt-get install nvidia-390

echo -e "${YELLOW}\nUnlocking Nvidia overclocking setting"
nvidia-xconfig -a --cool-bits=28 --allow-empty-initial-configuration

echo -e "${YELLOW}\nInstalling Claymore Miner to ~/claymore"
echo -e "#!/bin/bash\n~/claymore/ethdcrminer64 -epool [POOL] -ewal [ETH WALLET ADDR].[WORKER NAME]/[EMAIL] -epsw x -mode 1 -ftime 10" >> ~/miner.sh
gunzip "./${CLAYMORE_MINER_GZIP}.gz"
mv $CLAYMORE_MINER_GZIP ~/claymore

echo -e "${YELLOW}\nCopying template miner start script"
echo -e "${WHITE}WARNING: Change to appropriate miner settings after you run this script${YELLOW}"
touch ~/miner.sh

echo -e "${YELLOW}\nCreating crontab to start miner at boot"
crontab -l ~/.cron
echo -e "@reboot sleep ${MINER_COOLDOWN} && screen -dmS claymore sh ~/miner.sh" >> ~/.cron
echo -e "@reboot sleep ${OVERCLOCK_COOLDOWN} && sh ~/overclock.sh" >> ~/.cron
crontab ~/.cron
rm ~/.cron

echo -e "${GREEN}\nInstallation complete, restarting in 5 seconds (manual reboot if required)"

@sleep 5 reboot
