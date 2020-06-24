#! /bin/bash

##### Check what is the latest number in the Peer #####
number=0
number=`ls *.conf | cut -d "." -f 1 | cut -c 5-10 | sort -n | tail -n 1`
number=$((number+1))
if [ "$number" -lt "5" ]; then
        number=5
fi
echo "Peer Number is $number"

##### Variable for where the files will be #####
scon="/etc/wireguard/wg0.conf"
pcon="/etc/wireguard/peer$number.conf"
port=""
pubip=""
spubk=`cat /etc/wireguard/server_publickey`
dnsaddr=""

##### Generate the actual keys#####
wg genkey | tee peer"$number"_privatekey | wg pubkey > peer"$number"_publickey

##### Load the keys to variables to write into the files #####
pubk=`cat peer"$number"_publickey`
prik=`cat peer"$number"_privatekey`

##### Write the configuration to the Server Config File #####
echo "[Peer]" >> $scon
echo "#Peer-$number" >> $scon
echo "PublicKey = $pubk" >> $scon
echo "AllowedIPs = 10.10.10.$number/32" >> $scon
echo "#PersistentkeepAlive = 60" >> $scon
echo "" >> $scon

##### Write the configuration to the Peer Config File #####
echo "[Interface]" > $pcon
echo "Address = 10.10.10."$number"/32" >> $pcon
echo "DNS = $dnsaddr" >> $pcon
echo "PrivateKey = $prik" >> $pcon
echo "" >> $pcon
echo "[Peer]" >> $pcon
echo "PublicKey = $spubk" >> $pcon
echo "Endpoint = $pubip:$port" >> $pcon
echo "AllowedIPs = 0.0.0.0/0, ::/0" >> $pcon
echo "#PersistentkeepAlive = 60" >> $pcon

##### Create the QR code for Phone Peer #####
qrencode -t ansiutf8 < $pcon
