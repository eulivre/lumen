NONE='\033[00m'
GREEN='\033[01;32m'

echo -e "${GREEN}Installing swap file ${NONE}";

fallocate -l 3000M /mnt/3000MB.swap
dd if=/dev/zero of=/mnt/3000MB.swap bs=1024 count=3072000
mkswap /mnt/3000MB.swap
swapon /mnt/3000MB.swap
chmod 600 /mnt/3000MB.swap
echo '/mnt/3000MB.swap none swap sw 0 0' >> /etc/fstab

echo -e "${GREEN}Installing dependencies ${NONE}";

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install git -y
sudo apt-get install nano -y
sudo apt-get install curl -y
sudo apt-get install pwgen -y
sudo apt-get install wget -y
sudo apt-get install build-essential libtool automake autoconf -y
sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -y
sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -y
sudo apt-get install libzmq3-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

echo -e "${GREEN}Dependencies installed.${NONE}";

echo -e "${GREEN}Getting lumen client from github... Installation will take a while.${NONE}";

cd $HOME
sudo mkdir $HOME/lumen
git clone https://github.com/eulivre/lumen.git lumen
cd $HOME/lumen
chmod +x autogen.sh
./autogen.sh
./configure --with-incompatible-bdb
chmod +x share/genbuild.sh
sudo make
sudo make install

echo -e "${GREEN}Now paste your Masternode key by using right mouse click ${NONE}";
read MNKEY

EXTIP=`wget -qO- eth0.me`
PASSW=`pwgen -1 20 -n`

echo -e "${GREEN}Preparing config file ${NONE}";

sudo mkdir $HOME/.lumencore
printf "addnode=45.32.216.236:13444\naddnode=45.63.40.183:13444\naddnode=54.38.52.103:13444\naddnode=8.9.4.78:13444\naddnode=167.99.236.102:13444\naddnode=45.77.18.75:13444\naddnode=185.243.53.67:13444\naddnode=107.173.16.30:13444\n\nrpcuser=lumenu\nrpcpassword=$PASSW\nrpcport=13445\nrpcallowip=127.0.0.1\ndaemon=1\nlisten=1\nserver=1\nmaxconnections=256\nexternalip=$EXTIP:13444\nmasternode=1\nmasternodeprivkey=$MNKEY" > /$HOME/.lumencore/lumen.conf

echo -e "${GREEN}Starting client...${NONE}";
lumend --daemon
echo -e "[12/${MAX}] Waiting for sync, it may take some time...${NONE}";
until lumen-cli mnsync status | grep -m 1 '"IsBlockchainSynced": true'; do sleep 1 ; done > /dev/null 2>&1
echo -e "${GREEN}* Blockchain Synced${NONE}";
until lumen-cli mnsync status | grep -m 1 '"IsMasternodeListSynced": true'; do sleep 1 ; done > /dev/null 2>&1
echo -e "${GREEN}* Masternode List Synced${NONE}";
until lumen-cli mnsync status | grep -m 1 '"IsWinnersListSynced": true'; do sleep 1 ; done > /dev/null 2>&1
echo -e "${GREEN}* Winners List Synced${NONE}";
until lumen-cli mnsync status | grep -m 1 '"IsSynced": true'; do sleep 1 ; done > /dev/null 2>&1
echo -e "${GREEN}* Done sync. If you have at least 15 confirmations on the 1000 LEN transaction you may start your MN.${NONE}";

