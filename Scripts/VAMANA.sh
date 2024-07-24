#!/bin/bash

clear

CURRENTUSER=$(whoami)
sudo rm -rf /home/$CURRENTUSER/.ssh/known_hosts
sudo rm -rf /root/.ssh/known_hosts
sudo rm -rf /root/.bash_history
sudo rm -rf /home/$CURRENTUSER/.bash_history

RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
DGRAY='\033[1;35m'
PURPLE='\033[0;35m'
RGRAY='\033[1;30m'
BOLD=$(tput bold)
NORM=$(tput sgr0)
ORANGE='\033[1;33m'

DoubleQuotes='"'
NoQuotes=''

BASE="/opt/Matsya"
sudo mkdir -p $BASE
sudo mkdir -p $BASE/tmp
sudo mkdir -p $BASE/Scripts
sudo mkdir -p $BASE/Secrets
sudo mkdir -p $BASE/Resources
sudo mkdir -p $BASE/Output
sudo mkdir -p $BASE/Output/Terraform

if [[ ! -d "$BASE/Output/Pem" ]]; then
	sudo mkdir -p $BASE/Output/Pem
	sudo chmod -R 777 $BASE/Output/Pem
fi

if [[ ! -d "$BASE/Output/Scope" ]]; then
	sudo mkdir -p $BASE/Output/Scope
	sudo chmod -R 777 $BASE/Output/Scope
fi

if [[ ! -d "$BASE/Output/Vision" ]]; then
	sudo mkdir -p $BASE/Output/Vision
	sudo chmod -R 777 $BASE/Output/Vision
fi

source $BASE/Resources/StackVersioningAndMisc

PORTSLIST=()

function GetNewPort {
    local FreshPort=$($BASE/Scripts/GetRandomPort.sh)
    if printf '%s\0' "${PORTSLIST[@]}" | grep -Fxqz -- $FreshPort; then
    	GetNewPort
    fi
    echo $FreshPort
}

function GetNewPortRange {
    local FreshPortRange=$($BASE/Scripts/GetRandomPortRange.sh 9100 9500)
    if printf '%s\0' "${PORTSLIST[@]}" | grep -Fxqz -- $FreshPortRange; then
    	GetNewPortRange
    fi
    echo $FreshPortRange
}

echo -e "${ORANGE}=============================================================${NC}"
echo -e "\x1b[1;34mV\x1b[mersatile \x1b[1;34mA\x1b[mutomation \x1b[1;34mM\x1b[managing \x1b[1;34mA\x1b[mssorted \x1b[1;34mN\x1b[metworked \x1b[1;34mA\x1b[mpplications"
echo -e "${GREEN}=============================================================${NC}"
echo ''
echo -e "\x1b[3mV   V  AAAAA  M   M  AAAAA  N   N  AAAAA\x1b[m"
echo -e "\x1b[3mV   V  A   A  MM MM  A   A  NN  N  A   A\x1b[m"
echo -e "\x1b[3mV   V  AAAAA  M M M  AAAAA  N N N  AAAAA\x1b[m"
echo -e "\x1b[3m V V   A   A  M   M  A   A  N  NN  A   A\x1b[m"
echo -e "\x1b[3m  V    A   A  M   M  A   A  N   N  A   A\x1b[m"
echo ''
echo -e "\x1b[3m\x1b[4mSTACK MAKER DOCKER BASED\x1b[m"
echo ''

THECHOICE="$1"
THEARGS="$2"

if [ "$THECHOICE" == "CORE" ] ; then
IFS='├' read -r -a THE_ARGS <<< $THEARGS
INSTANCE_DETAILS_FILE="${THE_ARGS[0]}"
VISION_KEY="${THE_ARGS[1]}"
ADMIN_PASSWORD="${THE_ARGS[2]}"
THEVISIONID="${THE_ARGS[3]}"
CLUSTERID="${THE_ARGS[4]}"
STACKPRETTYNAME="${THE_ARGS[5]}"
ISAUTOMATED="${THE_ARGS[6]}"
THENOHUPFILE="${THE_ARGS[7]}"
WEBSSH_PASSWORD="${THE_ARGS[8]}"

if [[ ! -d "$BASE/Output/Vision/V$THEVISIONID" ]]; then
	sudo mkdir -p "$BASE/Output/Vision/V$THEVISIONID"
	sudo chmod -R 777 "$BASE/Output/Vision/V$THEVISIONID"
fi

HASHED_PASSWORD=$(python3 -c "from bcrypt import hashpw, gensalt; print(hashpw(b'$ADMIN_PASSWORD', gensalt()).decode())")
PortainerAPort=$(GetNewPort) && PORTSLIST+=("$PortainerAPort")
PortainerSPort=$(GetNewPort) && PORTSLIST+=("$PortainerSPort")
VarahaPort1=$(GetNewPortRange) && PORTSLIST+=("$VarahaPort1")
VarahaPort2=$(GetNewPort) && PORTSLIST+=("$VarahaPort2")
VarahaPort3=$(GetNewPort) && PORTSLIST+=("$VarahaPort3")
VarahaPort4=$(GetNewPort) && PORTSLIST+=("$VarahaPort4")
BDDPort1=$(GetNewPort) && PORTSLIST+=("$BDDPort1")
BDDPort2=$(GetNewPort) && PORTSLIST+=("$BDDPort2")
WEBSSHPort1=$(GetNewPort) && PORTSLIST+=("$WEBSSHPort1")
STACKNAME="v""$THEVISIONID""c""$CLUSTERID"
UNLOCKFILEPATH="$BASE/Output/Vision/V$THEVISIONID/$STACKNAME.dsuk"
MJTFILEPATH="$BASE/Output/Vision/V$THEVISIONID/$STACKNAME.dsmjt"
WJTFILEPATH="$BASE/Output/Vision/V$THEVISIONID/$STACKNAME.dswjt"
REVERSED_PASSWORD=$(echo "$ADMIN_PASSWORD" | rev)
DOCKER_DATA_DIR="/shiva/local/storage/docker$STACKNAME"
DFS_DATA_DIR="/shiva/local/storage/dfs$STACKNAME"
DFS_DATA2_DIR="/shiva/local/storage/dfs$STACKNAME"
DFS_CLUSTER_DIR="/shiva/bdd/storage/$STACKNAME"
CERTS_DIR="/shiva/local/storage/certs$STACKNAME"

EXECUTESCRIPT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1) && touch $BASE/tmp/$EXECUTESCRIPT && sudo chmod 777 $BASE/tmp/$EXECUTESCRIPT
EXECUTE1SCRIPT='#!/bin/bash'"
"
echo "$EXECUTE1SCRIPT" | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null
		
# Arrays to hold manager and worker details
declare -a MANAGER_IPS
declare -a WORKER_IPS
declare -a ROUTER_IPS
declare -a VPN_IPS
declare -A HOST_NAMES
declare -A HOST_ALT_NAMES
declare -A PEM_FILES
declare -A PORTS
declare -A OS_TYPES
declare -A LOGIN_USERS
declare -A APP_MEM
declare -A APP_CORE
declare -A CLUSTER_TYPE
declare -A INTERNAL_IPS
NATIVE="1"

# Function to prepare swarm dynamically
create_instance_details() {
    input_file="$1"
    output_file="$2"
    thereqmode="$3"
    
    # Read the file into an array
    mapfile -t lines < "$input_file"

    # Check if the number of lines is less than 3
    if [ ${#lines[@]} -lt 3 ]; then
        echo "Swarm setup not possible. Minimum 3 rows required."
        exit 1
    fi

    # Create an array to track which lines have been updated
    declare -A updated_lines

    manager_count=0
    worker_count=0
    router_count=0

    # Assign one manager, one worker, and one router first
    for i in "${!lines[@]}"; do
        if [ $manager_count -eq 0 ]; then
            updated_lines[$i]="MANAGER"
            manager_count=$((manager_count + 1))
        elif [ $worker_count -eq 0 ]; then
            updated_lines[$i]="WORKER"
            worker_count=$((worker_count + 1))
        elif [ $router_count -eq 0 ]; then
            updated_lines[$i]="ROUTER"
            router_count=$((router_count + 1))
        fi

        # Exit the loop once we have at least one of each
        if [ $manager_count -eq 1 ] && [ $worker_count -eq 1 ] && [ $router_count -eq 1 ]; then
            break
        fi
    done

    # Assign remaining managers and workers
    for i in "${!lines[@]}"; do
        if [ -z "${updated_lines[$i]}" ]; then
            if [ $manager_count -lt 3 ]; then
                updated_lines[$i]="MANAGER"
                manager_count=$((manager_count + 1))
            else
                updated_lines[$i]="WORKER"
                worker_count=$((worker_count + 1))
            fi
        fi
    done

    # Process each line
    for i in "${!lines[@]}"; do
        line="${lines[$i]}"
        IFS=',' read -ra columns <<< "$line"
        
        uppercase_text=$(echo "${columns[8]}" | tr '[:lower:]' '[:upper:]')
        columns[8]="$uppercase_text"
        columns4=$(NARASIMHA "decrypt" "${columns[4]}" "$VISION_KEY")
        columns5=$(NARASIMHA "decrypt" "${columns[5]}" "$VISION_KEY")
        columns7=$(NARASIMHA "decrypt" "${columns[7]}" "$VISION_KEY")
        columns[4]="$columns4"
        columns[5]="$columns5"
        columns[7]="$columns7"
        
        if [[ "$thereqmode" == "Y" ]]; then
            if [[ "${updated_lines[$i]}" == "MANAGER" ]]; then
                columns[9]="MANAGER"
                columns[10]="1280"
                columns[11]="1"
            elif [[ "${updated_lines[$i]}" == "ROUTER" ]]; then
                columns[9]="ROUTER"
                columns[10]="1024"
                columns[11]="1"
            else
                columns[9]="WORKER"
                columns[10]="512"
                columns[11]="0.5"
            fi
        fi
        
        # Reconstruct the line
        lines[$i]=$(IFS=','; echo "${columns[*]}")
    done

    # Write the updated lines to the output file
    printf "%s\n" "${lines[@]}" > "$output_file"
    echo "Updated file saved as $output_file"
}

if [[ "$ISAUTOMATED" == "Y" ]]; then
	terminator -e "bash -c 'tail -f $THENOHUPFILE; exec bash'"
	# CREATE FILE FOR STACKMAKER
	header=$(head -n 1 $INSTANCE_DETAILS_FILE)
	csv_data=$(tail -n +2 $INSTANCE_DETAILS_FILE)
	JSNDT1=$(echo "$csv_data" | awk -v header="$header" 'BEGIN { FS=","; OFS=","; split(header, keys, ","); print "[" } { print "{"; for (i=1; i<=NF; i++) { printf "\"%s\":\"%s\"", keys[i], $i; if (i < NF) printf ","; } print "},"; } END { print "{}]"; }' | sed '$s/,$//')
	JSNDT2=$(echo "$JSNDT1" | jq 'map(select(.IP != null and .IP != ""))')
	JSNDT3=$(echo "$JSNDT2" | jq 'map(select(.IP != "TBD"))')
	JSNDT4=$(echo "$JSNDT3" | jq 'map(select(.Encrypted != "N"))')
	JSNDT5=$(echo "$JSNDT4" | jq 'map(select(.Deleted != "Y"))')	
	JSNDT6=$(echo "$JSNDT5" | jq 'map(select(.InstanceType != "NA"))')	
		
	THESFTSTK_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)	
	THESFTSTKFILE="$BASE/tmp/Stack_$THESFTSTK_FILE.csv"
	header=$(echo "$JSNDT6" | jq -r '.[0] | keys_unsorted | join(",")')
	echo "$header" > "$THESFTSTKFILE"
	echo "$JSNDT6" | jq -c '.[]' | while IFS= read -r obj; do
	    record=$(echo "$obj" | jq -r 'map(.) | @csv')
	    echo "$record" >> "$THESFTSTKFILE"
	done	
	sudo chmod 777 $THESFTSTKFILE
	sed -i 's/""//g' "$THESFTSTKFILE"
	sed -i 's/"//g' "$THESFTSTKFILE"	
	# CREATE FILE FOR STACKMAKER
	
	# CREATE FILE FOR INSTANCE INPUT FOR STACKMAKER
	THE1SFTSTK_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)	
	THE1SFTSTKFILE="$BASE/tmp/Stack_$THE1SFTSTK_FILE.csv"
	columns="1,2,7,17,24,26,18,23,3"
	awk -F',' -v columns="$columns" '
BEGIN {
    split(columns, col, ",")
    col_count = length(col)
}
NR > 1 {
    output = ""
    for (i = 1; i <= col_count; i++) {
        output = output (i == 1 ? "" : ",") $col[i]
    }
    output = output ",TBD,TBD,TBD"
    print output
}
' "$THESFTSTKFILE" > "$THE1SFTSTKFILE"
	THE1SFTSTK2_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)	
	THE1SFTSTK1FILE="$BASE/tmp/Stack_$THE1SFTSTK2_FILE.csv"
	create_instance_details "$THE1SFTSTKFILE" "$THE1SFTSTK1FILE" "Y"	
	# CREATE FILE FOR INSTANCE INPUT FOR STACKMAKER
	
	sudo rm -f $THESFTSTKFILE
	sudo rm -f $THE1SFTSTKFILE
	
	INSTANCE_DETAILS_FILE="$THE1SFTSTK1FILE"
else
	THE1SFTSTK2_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)	
	THE1SFTSTK1FILE="$BASE/tmp/Stack_$THE1SFTSTK2_FILE.csv"
	create_instance_details "$INSTANCE_DETAILS_FILE" "$THE1SFTSTK1FILE" "N"
	INSTANCE_DETAILS_FILE="$THE1SFTSTK1FILE"					
fi

# Function to parse the instance details file
parse_instance_details() {
    echo 'sudo -H -u root bash -c "echo \"\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null
    echo 'sudo -H -u root bash -c "echo \"#VAMANA => '"$STACKPRETTYNAME"' START \" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null 
    while IFS=',' read -r SCPID INSTID IP HOSTNAME PORT PEM OS U1SER C1TYPE ROLE M1EM C1ORE; do
        PEM_FILES["$IP"]="$PEM"
        PORTS["$IP"]="$PORT"
        OS_TYPES["$IP"]="$OS"
        LOGIN_USERS["$IP"]="$U1SER"
        APP_MEM["$IP"]="$M1EM"
        APP_CORE["$IP"]="$C1ORE" 
        CLUSTER_TYPE["$IP"]="$C1TYPE"
        hyphenated_ip="${IP//./-}"
        lowercase_text="${C1TYPE,,}"
        
        if [[ "$C1TYPE" == "ONPREM" ]]; then
        	echo "VPN NA"
        else
        	VPN_IPS+=("$IP,$PORT,$PEM,$U1SER")
        fi
                       
        echo 'sudo -H -u root bash -c "sed -i -e s~'"$IP"'~#'"$IP"'~g /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null                     
        if [ "$ROLE" == "MANAGER" ]; then
            MANAGER_IPS+=("$IP")
            HOST_NAMES["$IP"]="$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-m"
            HOST_ALT_NAMES["$IP"]="alt-$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-m"
            echo 'sudo -H -u root bash -c "echo \"'"$IP"' '"$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-m"'\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null            
        elif [ "$ROLE" == "WORKER" ]; then
            WORKER_IPS+=("$IP")
            HOST_NAMES["$IP"]="$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-w"
            HOST_ALT_NAMES["$IP"]="alt-$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-w"
            echo 'sudo -H -u root bash -c "echo \"'"$IP"' '"$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-w"'\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null
        elif [ "$ROLE" == "ROUTER" ]; then
            ROUTER_IPS+=("$IP")
            HOST_NAMES["$IP"]="$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-r"
            HOST_ALT_NAMES["$IP"]="alt-$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-r"
            echo 'sudo -H -u root bash -c "echo \"'"$IP"' '"$lowercase_text-$hyphenated_ip-v$THEVISIONID""-s$SCPID""-i$INSTID""-c$CLUSTERID-r"'\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null            
        fi                
    done < "$INSTANCE_DETAILS_FILE"
    echo 'sudo -H -u root bash -c "echo \"#VAMANA => '"$STACKPRETTYNAME"' END \" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null 
    echo 'sudo -H -u root bash -c "echo \"\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTESCRIPT > /dev/null
    
    for ip in "${!CLUSTER_TYPE[@]}"; do
        if [[ "${CLUSTER_TYPE[$ip]}" == "ONPREM" ]]; then
            NATIVE="2"
            break
        fi
    done 
    
    if [[ "$ISAUTOMATED" == "N" ]]; then
    	sudo rm -f $INSTANCE_DETAILS_FILE 
    fi  
}

# Function to run commands on remote hosts
run_remote() {
    local IP=$1
    local CMD=$2
    local PORT=${PORTS[$IP]}
    local THEREQUSER=${LOGIN_USERS[$IP]}
    ssh -i "${PEM_FILES[$IP]}" -o StrictHostKeyChecking=no -p $PORT $THEREQUSER@$IP "$CMD"
}

# Function to generate SSL certificates based on OS type
generate_ssl_certificates() {
    local IP=$1
    local ip=$1
    local OS=${OS_TYPES[$IP]}
    
    if [[ "$OS" == "UBU" ]]; then
        EXECUTE21SCRIPT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
        sudo cp $BASE/Resources/UbuntuPreInstallSanitize $BASE/tmp/$EXECUTE21SCRIPT    
        scp -i "${PEM_FILES[$ip]}" -o StrictHostKeyChecking=no -P ${PORTS[$ip]} "$BASE/tmp/$EXECUTE21SCRIPT" "${LOGIN_USERS[$ip]}@$ip:/home/${LOGIN_USERS[$ip]}"
        ssh -i "${PEM_FILES[$ip]}" -o StrictHostKeyChecking=no -p ${PORTS[$ip]} ${LOGIN_USERS[$ip]}@$ip "sudo chmod 777 /home/${LOGIN_USERS[$ip]}/$EXECUTE21SCRIPT && /home/${LOGIN_USERS[$ip]}/$EXECUTE21SCRIPT && sudo rm -f /home/${LOGIN_USERS[$ip]}/$EXECUTE21SCRIPT" 
        sudo rm -f $BASE/tmp/$EXECUTE21SCRIPT           
        run_remote $IP "sudo NEEDRESTART_MODE=a apt-get install -y openssl"
    elif [[ "$OS" == "AZL" ]]; then
        run_remote $IP "sudo yum install -y openssl"
    elif [[ "$OS" == "ROCKY" || "$OS" == "ALMA" ]]; then
        run_remote $IP "sudo dnf install -y openssl"
    fi
    
    local IPHF=$(echo "$IP" | sed 's/\./-/g')
    
    run_remote $IP "
        sudo mkdir -p $CERTS_DIR && sudo chmod -R 777 $CERTS_DIR && cd $CERTS_DIR
        openssl genpkey -algorithm RSA -out $IPHF-key.pem
        openssl req -x509 -new -nodes -key $IPHF-key.pem -sha256 -days 3650 -out $IPHF.pem -subj '/CN=vamana-swarm'
        openssl genpkey -algorithm RSA -out $IPHF-server-key.pem
        openssl req -new -key $IPHF-server-key.pem -out $IPHF.csr -subj '/CN=$IP'
        openssl x509 -req -in $IPHF.csr -CA $IPHF.pem -CAkey $IPHF-key.pem -CAcreateserial -out $IPHF-server-cert.pem -days 3650 -sha256  
        cat $IPHF-server-cert.pem $IPHF-server-key.pem > $IPHF-VARAHA.pem
                      
        sudo mkdir -p $CERTS_DIR/docker && sudo chmod -R 777 $CERTS_DIR/docker
        sudo rm -f $CERTS_DIR/docker/*
        sudo cp $IPHF.pem $IPHF-server-cert.pem $IPHF-server-key.pem $IPHF-VARAHA.pem $CERTS_DIR/docker/
        sudo rm -f $IPHF-key.pem
        sudo rm -f $IPHF.pem
        sudo rm -f $IPHF-server-key.pem
        sudo rm -f $IPHF.csr
        sudo rm -f $IPHF-server-cert.pem
        sudo rm -f $IPHF-VARAHA.pem        
        cd ~
    "
}

# Function to copy SSL certificates to other manager nodes via local machine
copy_ssl_certificates() {
    local SRC_IP=$1
    local IPHF=$(echo "$SRC_IP" | sed 's/\./-/g')
    local THESRCUSER=${LOGIN_USERS[$SRC_IP]}

    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker.pem
    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-cert.pem
    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-key.pem
    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-VARAHA.pem
            
    # Download certificates from the first manager to the local machine
    run_remote $SRC_IP "
        sudo chmod 644 $CERTS_DIR/docker/$IPHF.pem
        sudo chmod 644 $CERTS_DIR/docker/$IPHF-server-cert.pem
        sudo chmod 644 $CERTS_DIR/docker/$IPHF-server-key.pem
        sudo chmod 644 $CERTS_DIR/docker/$IPHF-VARAHA.pem        
    "    
    scp -i ${PEM_FILES[$SRC_IP]} -P ${PORTS[$SRC_IP]} -o StrictHostKeyChecking=no $THESRCUSER@$SRC_IP:$CERTS_DIR/docker/$IPHF.pem $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker.pem
    scp -i ${PEM_FILES[$SRC_IP]} -P ${PORTS[$SRC_IP]} -o StrictHostKeyChecking=no $THESRCUSER@$SRC_IP:$CERTS_DIR/docker/$IPHF-server-cert.pem $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-cert.pem
    scp -i ${PEM_FILES[$SRC_IP]} -P ${PORTS[$SRC_IP]} -o StrictHostKeyChecking=no $THESRCUSER@$SRC_IP:$CERTS_DIR/docker/$IPHF-server-key.pem $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-key.pem
    scp -i ${PEM_FILES[$SRC_IP]} -P ${PORTS[$SRC_IP]} -o StrictHostKeyChecking=no $THESRCUSER@$SRC_IP:$CERTS_DIR/docker/$IPHF-VARAHA.pem $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-VARAHA.pem    
    run_remote $SRC_IP "
        sudo chown root:root $CERTS_DIR/docker/$IPHF.pem
        sudo chown root:root $CERTS_DIR/docker/$IPHF-server-cert.pem
        sudo chown root:root $CERTS_DIR/docker/$IPHF-server-key.pem  
        sudo chown root:root $CERTS_DIR/docker/$IPHF-VARAHA.pem   
        sudo chmod 644 $CERTS_DIR/docker/$IPHF.pem
        sudo chmod 644 $CERTS_DIR/docker/$IPHF-server-cert.pem
        sudo chmod 644 $CERTS_DIR/docker/$IPHF-VARAHA.pem
        sudo chmod 600 $CERTS_DIR/docker/$IPHF-server-key.pem
    " 
        
    # Upload certificates to each of the other manager nodes
    sudo chmod 777 $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker.pem
    sudo chmod 777 $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-cert.pem
    sudo chmod 777 $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-key.pem
    sudo chmod 777 $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-VARAHA.pem    
    for IP in "${MANAGER_IPS[@]:1}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}"; do
        local THEREQUSER=${LOGIN_USERS[$IP]}
        
        scp -i "${PEM_FILES[$IP]}" -P "${PORTS[$IP]}" -o StrictHostKeyChecking=no $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker.pem $THEREQUSER@$IP:/home/$THEREQUSER/$IPHF.pem
        scp -i "${PEM_FILES[$IP]}" -P "${PORTS[$IP]}" -o StrictHostKeyChecking=no $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-cert.pem $THEREQUSER@$IP:/home/$THEREQUSER/$IPHF-server-cert.pem
        scp -i "${PEM_FILES[$IP]}" -P "${PORTS[$IP]}" -o StrictHostKeyChecking=no $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-key.pem $THEREQUSER@$IP:/home/$THEREQUSER/$IPHF-server-key.pem
        scp -i "${PEM_FILES[$IP]}" -P "${PORTS[$IP]}" -o StrictHostKeyChecking=no $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-VARAHA.pem $THEREQUSER@$IP:/home/$THEREQUSER/$IPHF-VARAHA.pem
                
        # Move the certificates to the correct location on the target manager
        I1PHF="$STACKNAME"
        run_remote $IP "
            sudo mkdir -p $CERTS_DIR/docker && sudo chmod -R 777 $CERTS_DIR/docker 
            sudo rm -f $CERTS_DIR/docker/*           
            sudo mv /home/$THEREQUSER/$IPHF.pem $CERTS_DIR/docker/$I1PHF.pem
            sudo mv /home/$THEREQUSER/$IPHF-server-key.pem $CERTS_DIR/docker/$I1PHF-server-key.pem
            sudo mv /home/$THEREQUSER/$IPHF-server-cert.pem $CERTS_DIR/docker/$I1PHF-server-cert.pem
            sudo mv /home/$THEREQUSER/$IPHF-VARAHA.pem $CERTS_DIR/docker/$I1PHF-VARAHA.pem            
            sudo chown root:root $CERTS_DIR/docker/$I1PHF.pem
            sudo chown root:root $CERTS_DIR/docker/$I1PHF-server-cert.pem
            sudo chown root:root $CERTS_DIR/docker/$I1PHF-server-key.pem       
            sudo chown root:root $CERTS_DIR/docker/$I1PHF-VARAHA.pem                              
            sudo chmod 644 $CERTS_DIR/docker/$I1PHF.pem
            sudo chmod 644 $CERTS_DIR/docker/$I1PHF-server-cert.pem
            sudo chmod 600 $CERTS_DIR/docker/$I1PHF-server-key.pem    
            sudo chmod 644 $CERTS_DIR/docker/$I1PHF-VARAHA.pem                    
            sudo rm -f /home/$THEREQUSER/$IPHF.pem
            sudo rm -f /home/$THEREQUSER/$IPHF-server-key.pem
            sudo rm -f /home/$THEREQUSER/$IPHF-server-cert.pem 
            sudo rm -f /home/$THEREQUSER/$IPHF-VARAHA.pem                       
        "
    done
    MGR=$(echo "${MANAGER_IPS[0]}" | sed 's/\./-/g')
    run_remote ${MANAGER_IPS[0]} "
            sudo mv $CERTS_DIR/docker/$MGR.pem $CERTS_DIR/docker/$STACKNAME.pem
            sudo mv $CERTS_DIR/docker/$MGR-server-key.pem $CERTS_DIR/docker/$STACKNAME-server-key.pem
            sudo mv $CERTS_DIR/docker/$MGR-server-cert.pem $CERTS_DIR/docker/$STACKNAME-server-cert.pem
            sudo mv $CERTS_DIR/docker/$MGR-VARAHA.pem $CERTS_DIR/docker/$STACKNAME-VARAHA.pem            
    "      
    
    # Clean up local files
    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker.pem
    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-cert.pem
    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-server-key.pem
    sudo rm -f $BASE/Output/Vision/V$THEVISIONID/$IPHF-docker-VARAHA.pem    
}

# Function to setup Docker
install_docker() {
    local IP=$2
    local MACTYPE=$1
    
    local OS=${OS_TYPES[$IP]}
    local P1ORT=${PORTS[$IP]}
    local THE1REQUSER=${LOGIN_USERS[$IP]}
    local THE1REQPEM=${PEM_FILES[$IP]}
    local THE1HOST1NAME=${HOST_NAMES[$IP]}
        
    TLSSTUFF=""
    TheReqRL=""
    local IPHF="$STACKNAME"
    if [ "$MACTYPE" == "M" ] ; then
    	TLSSTUFF="--tlsverify --tlscacert=$CERTS_DIR/docker/$IPHF.pem --tlscert=$CERTS_DIR/docker/$IPHF-server-cert.pem --tlskey=$CERTS_DIR/docker/$IPHF-server-key.pem "
    	TheReqRL="M"
    fi
    if [ "$MACTYPE" == "W" ] ; then
    	TLSSTUFF="--tlsverify --tlscacert=$CERTS_DIR/docker/$IPHF.pem --tlscert=$CERTS_DIR/docker/$IPHF-server-cert.pem --tlskey=$CERTS_DIR/docker/$IPHF-server-key.pem "
    	TheReqRL="W"
    fi
    if [ "$MACTYPE" == "R" ] ; then
    	TLSSTUFF="--tlsverify --tlscacert=$CERTS_DIR/docker/$IPHF.pem --tlscert=$CERTS_DIR/docker/$IPHF-server-cert.pem --tlskey=$CERTS_DIR/docker/$IPHF-server-key.pem "
    	TheReqRL="R"
    fi
            
    DOCKERTEMPLATE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
    sudo cp $BASE/Resources/DockerSetUpTemplate $BASE/tmp/$DOCKERTEMPLATE

    if [ "$NATIVE" -lt 2 ]; then
    	ALLHOSTS=$(IFS=','; echo "${HOST_ALT_NAMES[*]}") 
    else
	ALLHOSTS=$(IFS=','; echo "${HOST_NAMES[*]}")
    fi
    echo "ALLHOSTS : $ALLHOSTS"
    
    sed -i -e s~"THEREQIP"~"$IP"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THEREQHOSTNAME"~"$THE1HOST1NAME"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THEREQOS"~"$OS"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THEREQDDD"~"$DOCKER_DATA_DIR"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THEREQDFS"~"$DFS_DATA_DIR"~g $BASE/tmp/$DOCKERTEMPLATE 
    sed -i -e s~"THEREQCD2FS"~"$DFS_DATA2_DIR"~g $BASE/tmp/$DOCKERTEMPLATE 
    sed -i -e s~"THEREQCDFS"~"$DFS_CLUSTER_DIR"~g $BASE/tmp/$DOCKERTEMPLATE   
    sed -i -e s~"THEREQTLS"~"$TLSSTUFF"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THEREQAPORT"~"$PortainerAPort"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THEREQSPORT"~"$PortainerSPort"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THECURSTACK"~"$STACKNAME"~g $BASE/tmp/$DOCKERTEMPLATE 
    sed -i -e s~"THECURPNSTACK"~"$STACKPRETTYNAME"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"VP1"~"$VarahaPort1"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"VP2"~"$VarahaPort2"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"VP3"~"$VarahaPort3"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"VP4"~"$VarahaPort4"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"THEREQROLE"~"$TheReqRL"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"BDDPASSWORD"~"$ADMIN_PASSWORD"~g $BASE/tmp/$DOCKERTEMPLATE  
    sed -i -e s~"BDD1"~"$BDDPort1"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"BDD2"~"$BDDPort2"~g $BASE/tmp/$DOCKERTEMPLATE 
    sed -i -e s~"BDDHOSTS"~"$ALLHOSTS"~g $BASE/tmp/$DOCKERTEMPLATE 
    sed -i -e s~"THECERTS"~"$CERTS_DIR"~g $BASE/tmp/$DOCKERTEMPLATE
    sed -i -e s~"WSP1"~"$WEBSSHPort1"~g $BASE/tmp/$DOCKERTEMPLATE
    
    if [[ "$ELIGIBLEFORVPN" == "Y" ]]; then
    	sed -i -e s~"GETVPN"~"Y"~g $BASE/tmp/$DOCKERTEMPLATE
    else
    	sed -i -e s~"GETVPN"~"N"~g $BASE/tmp/$DOCKERTEMPLATE
    fi
    if [ "$NATIVE" -lt 2 ]; then
    	sed -i -e s~"BDDCURRHOST"~"${HOST_ALT_NAMES[$IP]}"~g $BASE/tmp/$DOCKERTEMPLATE
    else
	sed -i -e s~"BDDCURRHOST"~"${HOST_NAMES[$IP]}"~g $BASE/tmp/$DOCKERTEMPLATE
    fi       
        
    sudo chmod 777 $BASE/tmp/$DOCKERTEMPLATE

    if [ "$MACTYPE" == "R" ] ; then
	    DOCKER1TEMPLATE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	    sudo cp $BASE/Resources/ImageMaker.py $BASE/tmp/$DOCKER1TEMPLATE
	    sed -i -e s~"THEREQHEADER"~"$STACKPRETTYNAME"~g $BASE/tmp/$DOCKER1TEMPLATE
	    sed -i -e s~"THEREQFONT"~"/home/$THE1REQUSER/CoreFont.ttf"~g $BASE/tmp/$DOCKER1TEMPLATE
	    sed -i -e s~"THEREQLOC"~"$DFS_DATA2_DIR/Static$STACKNAME/Logo$STACKNAME.png"~g $BASE/tmp/$DOCKER1TEMPLATE        
	    sudo chmod 777 $BASE/tmp/$DOCKER1TEMPLATE
	    scp -i "$THE1REQPEM" -o StrictHostKeyChecking=no -P $P1ORT "$BASE/tmp/$DOCKER1TEMPLATE" "$THE1REQUSER@$IP:/home/$THE1REQUSER"
	    scp -i "$THE1REQPEM" -o StrictHostKeyChecking=no -P $P1ORT "$BASE/Resources/CoreFont.ttf" "$THE1REQUSER@$IP:/home/$THE1REQUSER/CoreFont.ttf"
	    ssh -i "$THE1REQPEM" -o StrictHostKeyChecking=no -p $P1ORT $THE1REQUSER@$IP "sudo rm -f /home/$THE1REQUSER/ImageMaker.py && sudo mv /home/$THE1REQUSER/$DOCKER1TEMPLATE /home/$THE1REQUSER/ImageMaker.py && sudo chmod 777 /home/$THE1REQUSER/ImageMaker.py"
	    sudo rm -f $BASE/tmp/$DOCKER1TEMPLATE
    fi
    
    max_attempts=5
    attempt=0
    while true; do
    	attempt=$((attempt + 1))
        scp -i "$THE1REQPEM" -o StrictHostKeyChecking=no -P $P1ORT "$BASE/tmp/$EXECUTESCRIPT" "$THE1REQUSER@$IP:/home/$THE1REQUSER"
        status=$?
        if [ $status -eq 0 ]; then
            ssh -i "$THE1REQPEM" -o StrictHostKeyChecking=no -p $P1ORT $THE1REQUSER@$IP "sudo rm -f /home/$THE1REQUSER/SetUpHosts.sh && sudo mv /home/$THE1REQUSER/$EXECUTESCRIPT /home/$THE1REQUSER/SetUpHosts.sh && sudo chmod 777 /home/$THE1REQUSER/SetUpHosts.sh && /home/$THE1REQUSER/SetUpHosts.sh"
            break
        else
            if [ $attempt -ge $max_attempts ]; then
                echo "Maximum attempts reached. Exiting."
                exit 1
            fi
            sleep 5
        fi
    done
     
    max_attempts=5
    attempt=0
    while true; do
    	attempt=$((attempt + 1))
        scp -i "$THE1REQPEM" -o StrictHostKeyChecking=no -P $P1ORT "$BASE/tmp/$DOCKERTEMPLATE" "$THE1REQUSER@$IP:/home/$THE1REQUSER"
        status=$?
        if [ $status -eq 0 ]; then
            ssh -i "$THE1REQPEM" -o StrictHostKeyChecking=no -p $P1ORT $THE1REQUSER@$IP "sudo rm -f /home/$THE1REQUSER/SetUpDocker.sh && sudo mv /home/$THE1REQUSER/$DOCKERTEMPLATE /home/$THE1REQUSER/SetUpDocker.sh && sudo chmod 777 /home/$THE1REQUSER/SetUpDocker.sh && nohup /home/$THE1REQUSER/SetUpDocker.sh > /home/$THE1REQUSER/DSULog$STACKNAME.out 2>&1 &" < /dev/null > /dev/null 2>&1 &
            sudo rm -f $BASE/tmp/$DOCKERTEMPLATE
            break
        else
            if [ $attempt -ge $max_attempts ]; then
                echo "Maximum attempts reached. Exiting."
                exit 1
            fi
            sleep 5
        fi
    done                
}

# Function to create an encrypted overlay network
create_encrypted_overlay_network() {
    run_remote ${MANAGER_IPS[0]} "
        docker network create \
          --driver overlay \
          --attachable \
          --opt encrypted \
          $STACKNAME-encrypted-overlay
    "
}

THEFINALVOLUMENAME="$STACKNAME"
   
# Function to create a GlusterFS volume cluster with retry logic
create_glusterfs_volume_cluster() {
    peer_probe_cmds=""
    volume_create_cmd=""
    retry_count=0
    max_retries=10
    success=false

    ALL_IPS=("${MANAGER_IPS[@]:1}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}")
    total_nodes=${#ALL_IPS[@]}
    max_nodes=$(( (total_nodes / 2) * 2 ))
    responsive_peer_ips=()
    
    # Function to check if GlusterFS is running and installed on a peer
    check_glusterfs_status() {
        local ip=$1
        glusterd_status=$(ssh -i "${PEM_FILES[$ip]}" -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p ${PORTS[$ip]} ${LOGIN_USERS[$ip]}@$ip "sudo systemctl is-active glusterd")
        gluster_command_status=$(ssh -i "${PEM_FILES[$ip]}" -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p ${PORTS[$ip]} ${LOGIN_USERS[$ip]}@$ip "which gluster")
        if [[ "$glusterd_status" == "active" ]] && [[ -n "$gluster_command_status" ]]; then
            return 0
        else
            return 1
        fi
    }
    
    # Filter responsive peers
    for ip in "${ALL_IPS[@]}"; do
        if check_glusterfs_status $ip; then
            responsive_peer_ips+=("$ip")
        else
            echo "Skipping unresponsive or improperly configured peer: $ip"
        fi
    done

    # Ensure there are enough responsive peers to create a volume
    if [ ${#responsive_peer_ips[@]} -lt 2 ]; then
        echo "Not enough responsive peers to create a replica 2 volume."
        return 1
    fi
    
    # Select peers for the volume creation
    peer_ips=($(shuf -e "${responsive_peer_ips[@]}" -n $max_nodes))            
        
    # Retry logic for probing and volume creation
    while [ $retry_count -lt $max_retries ] && [ "$success" = false ]; do
        echo "Attempting to probe peers and create volume, Attempt: $((retry_count + 1))"

        TMPRNDM=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)
        THEFINALVOLUMENAME="$STACKNAME""$TMPRNDM"
        peer_probe_cmds=""
        volume_create_cmd="" 
               
        # Prepare peer probing commands
        for ip in "${peer_ips[@]}"; do
            HOST=${HOST_NAMES[$ip]}
            if [ "$NATIVE" -lt 2 ]; then
                HOST=${INTERNAL_IPS[$ip]}
            fi
            peer_probe_cmds+="sudo gluster peer probe $HOST; "
        done
            
        # Prepare volume creation command
        volume_create_cmd="sudo gluster volume create $THEFINALVOLUMENAME replica 2 "
        for ip in "${peer_ips[@]}"; do
		HOST=${HOST_NAMES[$ip]}
		if [ "$NATIVE" -lt 2 ]; then
		    HOST=${INTERNAL_IPS[$ip]}
		fi
		volume_create_cmd+="$HOST:$DFS_DATA2_DIR/$STACKNAME "
        done
        volume_create_cmd+="force"        
	echo "create_glusterfs_volume_cluster : $peer_probe_cmds"
	echo "create_glusterfs_volume_cluster : $volume_create_cmd"        
        # Run the peer probing and volume creation commands
        run_remote ${MANAGER_IPS[0]} "
            $peer_probe_cmds
            $volume_create_cmd
            sudo gluster volume start $THEFINALVOLUMENAME
        "

        # Check if the volume is started successfully
        if run_remote ${MANAGER_IPS[0]} "sudo gluster volume info $THEFINALVOLUMENAME"; then
            success=true
            echo "Volume created and started successfully."
            break
        else
            echo "Failed to create/start volume, retrying..."
            sleep 10  # Wait before retrying
        fi
        retry_count=$((retry_count + 1))
    done

    if [ "$success" = false ]; then
        echo "Failed to create/start volume after $max_retries attempts."
    else
	    # Mount the volume on all IPs
	    glusterfs_addresses=""
	    for ip in "${peer_ips[@]}"; do
		HOST=${HOST_NAMES[$ip]}
		if [ "$NATIVE" -lt 2 ]; then
		    HOST=${INTERNAL_IPS[$ip]}
		fi
		glusterfs_addresses+="$HOST,"
	    done
	    glusterfs_addresses=${glusterfs_addresses%,}  # Remove trailing comma

	    ALL2_IPS=("${MANAGER_IPS[@]}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}")
	    for IP in "${ALL2_IPS[@]}"; do
		run_remote $IP "hostname && sudo mount -t glusterfs $glusterfs_addresses:/$THEFINALVOLUMENAME $DFS_CLUSTER_DIR -o log-level=DEBUG,log-file=/var/log/glusterfs/$THEFINALVOLUMENAME-mount.log"
	    done    
    fi
}

THEFINALVOLUME1NAME="$STACKNAME"

# Function to create portainer glusterfs volume
create_glusterfs_volume_portainer() {
	primary_ip=${MANAGER_IPS[0]}
	peer_ips=("${MANAGER_IPS[@]:1}")	
	retry_count=0
	max_retries=10
	success=false	
	
	# Retry logic for probing and volume creation
	while [ $retry_count -lt $max_retries ] && [ "$success" = false ]; do
		echo "Attempting to probe peers and create Portainer volume, Attempt: $((retry_count + 1))"
		
		TMPRNDM=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)
		THEFINALVOLUME1NAME="$STACKNAME""$TMPRNDM"		
		
		peer_probe_cmds=""	
		for ip in "${peer_ips[@]}"; do
			H1O1S1T=${HOST_NAMES[$ip]}
			if [ "$NATIVE" -lt 2 ]; then
				H1O1S1T=${INTERNAL_IPS[$ip]}
			fi
			peer_probe_cmds+="sudo gluster peer probe $H1O1S1T; "
		done
		volume_create_cmd="sudo gluster volume create Portainer$THEFINALVOLUME1NAME replica ${#MANAGER_IPS[@]} "
		for ip in "${MANAGER_IPS[@]}"; do
			H1O1S11T=${HOST_NAMES[$ip]}
			if [ "$NATIVE" -lt 2 ]; then
				H1O1S11T=${INTERNAL_IPS[$ip]}
			fi
			volume_create_cmd+="$H1O1S11T:$DFS_DATA_DIR/Portainer$STACKNAME "
		done
		volume_create_cmd+="force" 
		echo "create_glusterfs_volume_portainer : $peer_probe_cmds"
		echo "create_glusterfs_volume_portainer : $volume_create_cmd" 
		run_remote ${MANAGER_IPS[0]} "
		$peer_probe_cmds
		$volume_create_cmd
		sudo gluster volume start Portainer$THEFINALVOLUME1NAME
		"
		if run_remote ${MANAGER_IPS[0]} "sudo gluster volume info Portainer$THEFINALVOLUME1NAME"; then
		    success=true
		    echo "Portainer Volume created and started successfully."
		    break
		else
		    echo "Portainer Failed to create/start volume, retrying..."
		    sleep 10
		fi
		retry_count=$((retry_count + 1))
	done
    	
	if [ "$success" = false ]; then
		echo "Failed to create/start Portainer volume after $max_retries attempts."
		sudo mv $THENOHUPFILE $BASE/tmp/FATAL_ERROR_$STACKNAME && sudo chmod 777 FATAL_ERROR_$STACKNAME
		exit
	else    	
		glusterfs_addresses=""
		for ip in "${MANAGER_IPS[@]}"; do
			H11O1S11T=${HOST_NAMES[$ip]}
			if [ "$NATIVE" -lt 2 ]; then
				H11O1S11T=${INTERNAL_IPS[$ip]}
			fi
			glusterfs_addresses+="$H11O1S11T,"
		done
		glusterfs_addresses=${glusterfs_addresses%,}
		for IP in "${MANAGER_IPS[@]}"; do
		    run_remote $IP "hostname && sudo mount -t glusterfs $glusterfs_addresses:/Portainer$THEFINALVOLUME1NAME $DFS_DATA_DIR/PortainerMnt$STACKNAME -o log-level=DEBUG,log-file=/var/log/glusterfs/Portainer$STACKNAME-mount.log"
		done
	fi
}

# Function to create swarm labels
create_swarm_labels() {
	for IP in "${MANAGER_IPS[@]}"; do
		NODE_ID=$(run_remote $IP "docker info -f '{{.Swarm.NodeID}}'")
		if [ -n "$NODE_ID" ]; then
		    run_remote $IP "docker node update --label-add $STACKNAME""portainerreplica=true $NODE_ID"
		else
		    echo "Node $IP is not part of a Swarm"
		fi
	done
	for IP in "${ROUTER_IPS[@]}"; do
		NODE_ID=$(run_remote $IP "docker info -f '{{.Swarm.NodeID}}'")
		if [ -n "$NODE_ID" ]; then
		    run_remote ${MANAGER_IPS[0]} "docker node update --label-add $STACKNAME""routerreplica=true $NODE_ID"
		else
		    echo "Node $IP is not part of a Swarm"
		fi
	done
}

# Function to create cluster level cdn & proxy
create_cluster_cdn_proxy() {
    DOCKERTEMPLATE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
    sudo cp $BASE/Scripts/VARAHA.sh $BASE/tmp/$DOCKERTEMPLATE

    MGRIPS=$(IFS=','; echo "${MANAGER_IPS[*]}")
    THECFGPATH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
    THEDCYPATH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)    
    IWP="${ROUTER_IPS[0]}"
    THE1RAM=${APP_MEM[$IWP]}
    R2AM=$( [[ $THE1RAM == *,* ]] && echo "${THE1RAM#*,}" || echo "$THE1RAM" )
    THE1CORE=${APP_CORE[$IWP]}
    C2ORE=$( [[ $THE1CORE == *,* ]] && echo "${THE1CORE#*,}" || echo "$THE1CORE" ) 

    THEREQROUTER="${ROUTER_IPS[0]}"
    SYNCWITHIFCONFIG="N"
    if [ "$NATIVE" -lt 2 ]; then
    	THEREQROUTER="${INTERNAL_IPS[${ROUTER_IPS[0]}]}"
    	SYNCWITHIFCONFIG="Y"
    fi
   
    sudo chmod 777 $BASE/tmp/$DOCKERTEMPLATE
     
    max_attempts=5
    attempt=0
    while true; do
    	attempt=$((attempt + 1))
        scp -i "${PEM_FILES[${MANAGER_IPS[0]}]}" -o StrictHostKeyChecking=no -P ${PORTS[${MANAGER_IPS[0]}]} "$BASE/tmp/$DOCKERTEMPLATE" "${LOGIN_USERS[${MANAGER_IPS[0]}]}@${MANAGER_IPS[0]}:/home/${LOGIN_USERS[${MANAGER_IPS[0]}]}"
        status=$?
        if [ $status -eq 0 ]; then
            ssh -i "${PEM_FILES[${MANAGER_IPS[0]}]}" -o StrictHostKeyChecking=no -p ${PORTS[${MANAGER_IPS[0]}]} ${LOGIN_USERS[${MANAGER_IPS[0]}]}@${MANAGER_IPS[0]} "sudo rm -f /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/VARAHA.sh && sudo mv /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/$DOCKERTEMPLATE /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/VARAHA.sh && sudo chmod 777 /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/VARAHA.sh && /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/VARAHA.sh \"CORE\" \"$MGRIPS\" \"$STACKNAME\" \"$STACKPRETTYNAME\" \"$DFS_DATA2_DIR/Static$STACKNAME\" \"$VarahaPort1\" \"$VarahaPort2\" \"$DFS_DATA_DIR/Tmp$STACKNAME/$THECFGPATH.cfg\" \"$VarahaPort3\" \"$VarahaPort4\" \"$ADMIN_PASSWORD\" \"$PortainerSPort\" \"$DFS_DATA_DIR/Tmp$STACKNAME/$THEDCYPATH.yml\" \"$C2ORE\" \"$R2AM\" \"$CERTS_DIR\" \"$DFS_DATA_DIR/Errors$STACKNAME\" \"$DFS_DATA_DIR/Misc$STACKNAME/RunHAProxy\" \"$THEREQROUTER\" \"${CLUSTERAPPSMAPPING["ROUTER"]}\" \"${CLUSTER_APP_SMAPPING["ROUTER"]}\" \"$SYNCWITHIFCONFIG\" \"$WEBSSHPort1\" \"$WEBSSH_PASSWORD\" \"$DFS_DATA_DIR/Misc$STACKNAME/WebSSH\" \"$THEWEBSSHIDLELIMIT\" \"${CLUSTERAPPSMAPPING["WEBSSH"]}\" \"${CLUSTER_APP_SMAPPING["WEBSSH"]}\" && sudo rm -f /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/VARAHA.sh"
            sudo rm -f $BASE/tmp/$DOCKERTEMPLATE
            break
        else
            if [ $attempt -ge $max_attempts ]; then
                echo "Maximum attempts reached. Exiting."
                exit 1
            fi
            sleep 5
        fi
    done 
}

# Function to get the VPC
get_vpc() {
    local ip="$1"
    local pem_file="${PEM_FILES[$ip]}"
    local port="${PORTS[$ip]}"
    local theuser="${LOGIN_USERS[$ip]}"

    ssh -i "$pem_file" -o StrictHostKeyChecking=no -p "$port" "$theuser@$ip" "head -n 1 /opt/VPC"
}

# Parse instance details
parse_instance_details

# Generate SSL certificates on the first manager node
generate_ssl_certificates ${MANAGER_IPS[0]}

# Copy SSL certificates to the other manager nodes
copy_ssl_certificates ${MANAGER_IPS[0]}

# Check If VPN Required
declare -a VPCDET
for ip in "${MANAGER_IPS[@]}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}"; do
    VPCDET+=("$(get_vpc "$ip")")
done
declare -A unique_counts
for detail in "${VPCDET[@]}"; do
    ((unique_counts["$detail"]++))
done
ELIGIBLEFORVPN="N"
if [ "${#unique_counts[@]}" -gt 1 ]; then
    ELIGIBLEFORVPN="Y"
fi
echo "Eligible for VPN: $ELIGIBLEFORVPN"
if [[ "$ELIGIBLEFORVPN" == "Y" ]]; then
	VPNTEMPLATE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
	sudo cp $BASE/Resources/VPNTemplate $BASE/tmp/$VPNTEMPLATE
	
	THEVPNIPDET=$(IFS='|'; echo "${VPN_IPS[*]}")
	sed -i -e s~"THEIPLIST"~"$THEVPNIPDET"~g $BASE/tmp/$VPNTEMPLATE
	sed -i -e s~"THENIC"~"$STACKNAME"~g $BASE/tmp/$VPNTEMPLATE
	sed -i -e s~"THEWGPATH"~"/etc/wireguard"~g $BASE/tmp/$VPNTEMPLATE
	THEVPNPORT=$($BASE/Scripts/GetRandomPortRange.sh 51000 52000)
	sed -i -e s~"THEVPNPORT"~"$THEVPNPORT"~g $BASE/tmp/$VPNTEMPLATE
	num1=$((RANDOM % 241 + 10))
	num2=$((RANDOM % 241 + 10))
	num3=$((RANDOM % 241 + 10))
	THESUBNET="${num1}.${num2}.${num3}"	
	sed -i -e s~"THESUBNET"~"$THESUBNET"~g $BASE/tmp/$VPNTEMPLATE
	sudo chmod 777 $BASE/tmp/$VPNTEMPLATE
	$BASE/tmp/$VPNTEMPLATE
	sudo rm -f $BASE/tmp/$VPNTEMPLATE	
fi

# Install Docker on all nodes
for IP in "${MANAGER_IPS[@]}"; do
    install_docker "M" $IP
done
for IP in "${WORKER_IPS[@]}"; do
    install_docker "W" $IP
done
for IP in "${ROUTER_IPS[@]}"; do
    install_docker "R" $IP
done
sudo chmod 777 $BASE/tmp/$EXECUTESCRIPT
$BASE/tmp/$EXECUTESCRIPT
sudo rm -f $BASE/tmp/$EXECUTESCRIPT

ALL1_IPS=("${MANAGER_IPS[@]}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}")
check_status() {
    local ip=$1
    local pem_file=${PEM_FILES[$ip]}
    local port=${PORTS[$ip]}
    local user=${LOGIN_USERS[$ip]}
    ssh -o StrictHostKeyChecking=no -i "$pem_file" -p "$port" "$user@$ip" "[ -f /opt/DSUDONE$STACKNAME ]"
    if [ $? -eq 0 ]; then
        echo "$ip - completed"
    else
        echo "$ip - in progress"
    fi
}
COUNTER=0
while true; do
    echo ""
    echo "-----------------------" 
    echo "COUNTER : $COUNTER"
    echo "-----------------------"    
    all_done=true

    for ip in "${ALL1_IPS[@]}"; do
        status=$(check_status "$ip")
        echo "$status"
        if [[ $status == *"in progress"* ]]; then
            all_done=false
        fi
    done

    if [ "$all_done" = true ]; then
        echo "jobdone"
        break
    fi
    echo "-----------------------" 
    COUNTER=$((COUNTER + 1))
    sleep 15
done
COUNTER=0

ALL5_IPS=("${MANAGER_IPS[@]}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}")
for ip in "${ALL5_IPS[@]}"; do
    DOCKER2TEMPLATE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
    sudo cp $BASE/Resources/DockerRestartJoinTemplate $BASE/tmp/$DOCKER2TEMPLATE
    scp -i "${PEM_FILES[$ip]}" -o StrictHostKeyChecking=no -P ${PORTS[$ip]} "$BASE/tmp/$DOCKER2TEMPLATE" "${LOGIN_USERS[$ip]}@$ip:/home/${LOGIN_USERS[$ip]}"
    ssh -i "${PEM_FILES[$ip]}" -o StrictHostKeyChecking=no -p ${PORTS[$ip]} ${LOGIN_USERS[$ip]}@$ip "sudo rm -f $DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate && sudo mv /home/${LOGIN_USERS[$ip]}/$DOCKER2TEMPLATE $DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate$STACKNAME && sudo chmod 777 $DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate$STACKNAME"
    sudo rm -f $BASE/tmp/$DOCKER2TEMPLATE
done

fetch_internal_ip() {
    local IP=$1
    local PORT=${PORTS[$IP]}
    local THEREQUSER=${LOGIN_USERS[$IP]}
    if [[ "$ELIGIBLEFORVPN" == "Y" ]]; then
    	local internal_ip=$(ssh -i "${PEM_FILES[$IP]}" -o StrictHostKeyChecking=no -p $PORT $THEREQUSER@$IP "cat /opt/WHOAMI3") 
    else
    	local internal_ip=$(ssh -i "${PEM_FILES[$IP]}" -o StrictHostKeyChecking=no -p $PORT $THEREQUSER@$IP "cat /opt/WHOAMI2") 
    fi        
    echo $internal_ip   
}

if [ "$NATIVE" -lt 2 ]; then
	EXECUTE2SCRIPT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1) && touch $BASE/tmp/$EXECUTE2SCRIPT && sudo chmod 777 $BASE/tmp/$EXECUTE2SCRIPT
	EXECUTE3SCRIPT='#!/bin/bash'"
	"
	echo "$EXECUTE3SCRIPT" | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null
	echo 'sudo -H -u root bash -c "echo \"\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null
	echo 'sudo -H -u root bash -c "echo \"#VAMANA ALT => '"$STACKPRETTYNAME"' START \" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null
	for ip in "${MANAGER_IPS[@]}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}"; do
	    internal_ip=$(fetch_internal_ip $ip)
	    INTERNAL_IPS["$ip"]="$internal_ip"
	    echo 'sudo -H -u root bash -c "sed -i -e s~'"$internal_ip"'~#'"$internal_ip"'~g /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null  
	    echo 'sudo -H -u root bash -c "echo \"'"$internal_ip"' '"${HOST_ALT_NAMES[$ip]}"'\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null	    
	done
	for ip in "${!INTERNAL_IPS[@]}"; do
	    echo "$ip : ${INTERNAL_IPS[$ip]}"
	done
	echo 'sudo -H -u root bash -c "echo \"#VAMANA ALT => '"$STACKPRETTYNAME"' END \" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null 
	echo 'sudo -H -u root bash -c "echo \"\" >> /etc/hosts"' | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null
	#echo 'sudo systemctl enable BDDMinio'"$STACKNAME" | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null
	#echo 'sudo systemctl start BDDMinio'"$STACKNAME" | sudo tee -a $BASE/tmp/$EXECUTE2SCRIPT > /dev/null

	ALL_IPS=("${MANAGER_IPS[@]}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}")
	for ip in "${ALL_IPS[@]}"; do
		scp -i "${PEM_FILES[$ip]}" -o StrictHostKeyChecking=no -P ${PORTS[$ip]} "$BASE/tmp/$EXECUTE2SCRIPT" "${LOGIN_USERS[$ip]}@$ip:/home/${LOGIN_USERS[$ip]}"
		ssh -i "${PEM_FILES[$ip]}" -o StrictHostKeyChecking=no -p ${PORTS[$ip]} ${LOGIN_USERS[$ip]}@$ip "sudo chmod 777 /home/${LOGIN_USERS[$ip]}/$EXECUTE2SCRIPT && /home/${LOGIN_USERS[$ip]}/$EXECUTE2SCRIPT && sudo rm -f /home/${LOGIN_USERS[$ip]}/$EXECUTE2SCRIPT"
	done

	sudo rm -f $BASE/tmp/$EXECUTE2SCRIPT	  
fi

# Initialize Docker Swarm with custom ports and autolock on the first manager node
run_remote ${MANAGER_IPS[0]} "docker swarm init --advertise-addr ${MANAGER_IPS[0]} --autolock"

sudo rm -f $UNLOCKFILEPATH
sudo rm -f $MJTFILEPATH
sudo rm -f $WJTFILEPATH

SWARM_UNLOCK_KEY=$(run_remote ${MANAGER_IPS[0]} "docker swarm unlock-key -q")
ULFP_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
ULFP1_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
echo $SWARM_UNLOCK_KEY > $BASE/tmp/$ULFP1_FILE
$BASE/Scripts/SecretsFile-Encrypter "$BASE/tmp/$ULFP1_FILE├$UNLOCKFILEPATH├$ADMIN_PASSWORD├$ULFP_FILE"
sudo chmod 777 $UNLOCKFILEPATH
sudo rm -f $BASE/tmp/$ULFP1_FILE
MGR1IPS=$(IFS=','; echo "${MANAGER_IPS[*]}")

# Get the join token for manager and worker nodes
MANAGER_JOIN_TOKEN=$(run_remote ${MANAGER_IPS[0]} "docker swarm join-token manager -q")
WORKER_JOIN_TOKEN=$(run_remote ${MANAGER_IPS[0]} "docker swarm join-token worker -q")
MJTFP_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
MJTFP1_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
echo $MANAGER_JOIN_TOKEN > $BASE/tmp/$MJTFP1_FILE
$BASE/Scripts/SecretsFile-Encrypter "$BASE/tmp/$MJTFP1_FILE├$MJTFILEPATH├$ADMIN_PASSWORD├$MJTFP_FILE"
sudo chmod 777 $MJTFILEPATH
sudo rm -f $BASE/tmp/$MJTFP1_FILE
WJTFP_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
WJTFP1_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
echo $WORKER_JOIN_TOKEN > $BASE/tmp/$WJTFP1_FILE
$BASE/Scripts/SecretsFile-Encrypter "$BASE/tmp/$WJTFP1_FILE├$WJTFILEPATH├$ADMIN_PASSWORD├$WJTFP_FILE"
sudo chmod 777 $WJTFILEPATH
sudo rm -f $BASE/tmp/$WJTFP1_FILE

echo "$DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate$STACKNAME '$MGR1IPS' '$STACKNAME' '$DFS_DATA_DIR/Misc$STACKNAME'"
# Join remaining manager nodes to the Swarm
for IP in "${MANAGER_IPS[@]:1}"; do
    run_remote $IP "sudo rm -f /var/lib/.dsuk$STACKNAME && echo '$SWARM_UNLOCK_KEY' | sudo tee /var/lib/.dsuk$STACKNAME > /dev/null && sudo rm -f /var/lib/.dsjt$STACKNAME && echo '$MANAGER_JOIN_TOKEN' | sudo tee /var/lib/.dsjt$STACKNAME > /dev/null && docker swarm join --token $MANAGER_JOIN_TOKEN --advertise-addr $IP ${MANAGER_IPS[0]}:2377 && $DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate$STACKNAME '$MGR1IPS' '$STACKNAME' '$DFS_DATA_DIR/Misc$STACKNAME'"    
done

for IP in "${MANAGER_IPS[0]}"; do
    run_remote $IP "sudo rm -f /var/lib/.dsuk$STACKNAME && echo '$SWARM_UNLOCK_KEY' | sudo tee /var/lib/.dsuk$STACKNAME > /dev/null && sudo rm -f /var/lib/.dsjt$STACKNAME && echo '$MANAGER_JOIN_TOKEN' | sudo tee /var/lib/.dsjt$STACKNAME > /dev/null && $DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate$STACKNAME '$MGR1IPS' '$STACKNAME' '$DFS_DATA_DIR/Misc$STACKNAME'"    
done

# Join worker nodes to the Swarm
for IP in "${WORKER_IPS[@]}"; do
    run_remote $IP "sudo rm -f /var/lib/.dsuk$STACKNAME && echo '$SWARM_UNLOCK_KEY' | sudo tee /var/lib/.dsuk$STACKNAME > /dev/null && sudo rm -f /var/lib/.dsjt$STACKNAME && echo '$WORKER_JOIN_TOKEN' | sudo tee /var/lib/.dsjt$STACKNAME > /dev/null && docker swarm join --token $WORKER_JOIN_TOKEN --advertise-addr $IP ${MANAGER_IPS[0]}:2377 && $DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate$STACKNAME '$MGR1IPS' '$STACKNAME' '$DFS_DATA_DIR/Misc$STACKNAME'"
done

# Join router nodes to the Swarm
for IP in "${ROUTER_IPS[@]}"; do
    run_remote $IP "sudo rm -f /var/lib/.dsuk$STACKNAME && echo '$SWARM_UNLOCK_KEY' | sudo tee /var/lib/.dsuk$STACKNAME > /dev/null && sudo rm -f /var/lib/.dsjt$STACKNAME && echo '$WORKER_JOIN_TOKEN' | sudo tee /var/lib/.dsjt$STACKNAME > /dev/null && docker swarm join --token $WORKER_JOIN_TOKEN --advertise-addr $IP ${MANAGER_IPS[0]}:2377 && $DFS_DATA_DIR/Misc$STACKNAME/DockerRestartJoinTemplate$STACKNAME '$MGR1IPS' '$STACKNAME' '$DFS_DATA_DIR/Misc$STACKNAME'"
done

create_encrypted_overlay_network

THEMANGIP="${MANAGER_IPS[0]}"
THE1RAM=${APP_MEM[$THEMANGIP]}
R1AM=$( [[ $THE1RAM == *,* ]] && echo "${THE1RAM#*,}" || echo "$THE1RAM" )
THE1CORE=${APP_CORE[$THEMANGIP]}
C1ORE=$( [[ $THE1CORE == *,* ]] && echo "${THE1CORE#*,}" || echo "$THE1CORE" ) 
P1O1R1T=${PORTS[${MANAGER_IPS[0]}]}
THE1R1E1QUSE1R=${LOGIN_USERS[${MANAGER_IPS[0]}]}
SUBNET=$(ssh -i "${PEM_FILES[${MANAGER_IPS[0]}]}" -o StrictHostKeyChecking=no -p $P1O1R1T $THE1R1E1QUSE1R@${MANAGER_IPS[0]} "docker network inspect ${STACKNAME}-encrypted-overlay | grep -m 1 -oP '(?<=\"Subnet\": \")[^\"]+'")
echo "Using Subnet $SUBNET ..."

create_glusterfs_volume_cluster

create_glusterfs_volume_portainer
    
create_swarm_labels

create_cluster_cdn_proxy

ALL3_IPS=("${MANAGER_IPS[@]}" "${WORKER_IPS[@]}" "${ROUTER_IPS[@]}")
for ip in "${ALL3_IPS[@]}"; do
	ssh -i "${PEM_FILES[$ip]}" -o StrictHostKeyChecking=no -p ${PORTS[$ip]} ${LOGIN_USERS[$ip]}@$ip "sudo gluster volume heal $THEFINALVOLUMENAME full"
done

DOCKERPTEMPLATE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
sudo cp $BASE/Resources/DockerPortainer.yml $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"PortainerSPort"~"$PortainerSPort"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"PortainerAPort"~"$PortainerAPort"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"REVERSED_PASSWORD"~"$REVERSED_PASSWORD"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"STACKNAME"~"$STACKNAME"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"C1ORE"~"$C1ORE"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"R1AM"~"$R1AM"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"DOCKER_VOLUME_NAME"~"$DFS_DATA_DIR/PortainerMnt$STACKNAME"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"CERTS_DIR"~"$CERTS_DIR"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"ROUTERNAME"~"${HOST_NAMES[${ROUTER_IPS[0]}]}"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"ROUTERPORT"~"$VarahaPort2"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"WRKRVER"~"${CLUSTERAPPSMAPPING["WORKER"]}"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"MGRVER"~"${CLUSTERAPPSMAPPING["MANAGER"]}"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"WRKR1VER"~"${CLUSTER_APP_SMAPPING["WORKER"]}"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"MGR1VER"~"${CLUSTER_APP_SMAPPING["MANAGER"]}"~g $BASE/tmp/$DOCKERPTEMPLATE

IWP="${WORKER_IPS[0]}"
THE1RAM=${APP_MEM[$IWP]}
R2AM=$( [[ $THE1RAM == *,* ]] && echo "${THE1RAM#*,}" || echo "$THE1RAM" )
THE1CORE=${APP_CORE[$IWP]}
C2ORE=$( [[ $THE1CORE == *,* ]] && echo "${THE1CORE#*,}" || echo "$THE1CORE" ) 
sed -i -e s~"C2ORE"~"$C2ORE"~g $BASE/tmp/$DOCKERPTEMPLATE
sed -i -e s~"R2AM"~"$R2AM"~g $BASE/tmp/$DOCKERPTEMPLATE

sudo chmod 777 $BASE/tmp/$DOCKERPTEMPLATE
READYTOROCK="NO"
max_attempts=5
attempt=0
while true; do
attempt=$((attempt + 1))
scp -i "${PEM_FILES[${MANAGER_IPS[0]}]}" -o StrictHostKeyChecking=no -P ${PORTS[${MANAGER_IPS[0]}]} "$BASE/tmp/$DOCKERPTEMPLATE" "${LOGIN_USERS[${MANAGER_IPS[0]}]}@${MANAGER_IPS[0]}:/home/${LOGIN_USERS[${MANAGER_IPS[0]}]}"
status=$?
if [ $status -eq 0 ]; then
    READYTOROCK="YES"
    sudo rm -f $BASE/tmp/$DOCKERPTEMPLATE
    break
else
    if [ $attempt -ge $max_attempts ]; then
        echo "Maximum attempts reached. Exiting."
        exit 1
    fi
    sleep 5
fi
done
    
echo "" && echo "Install Portainer & Agent..."
# Deploy Portainer on the manager nodes with HTTPS
if [ "$READYTOROCK" == "YES" ] ; then
	run_remote ${MANAGER_IPS[0]} "sudo rm -f /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/Portainer.yml && sudo mv /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/$DOCKERPTEMPLATE /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/Portainer.yml && docker stack deploy --compose-file /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/Portainer.yml $STACKNAME && sudo rm -f /home/${LOGIN_USERS[${MANAGER_IPS[0]}]}/Portainer.yml"
fi
             
echo "Portainer Proxy : https://${HOST_NAMES[${ROUTER_IPS[0]}]}:$VarahaPort3"
echo "Portainer Admin : https://${HOST_NAMES[${ROUTER_IPS[0]}]}:$VarahaPort4"
echo "Static Local : https://${HOST_NAMES[${ROUTER_IPS[0]}]}:$VarahaPort1"
echo "Static Global : https://${HOST_NAMES[${ROUTER_IPS[0]}]}:$VarahaPort2"
if [[ "$ISAUTOMATED" == "Y" ]]; then
	/opt/firefox/firefox "https://${HOST_NAMES[${ROUTER_IPS[0]}]}:$VarahaPort3" "https://${HOST_NAMES[${ROUTER_IPS[0]}]}:$VarahaPort4" "https://${HOST_NAMES[${ROUTER_IPS[0]}]}:$VarahaPort2" &
fi

PORTAINER_URL="https://${MANAGER_IPS[0]}:$PortainerSPort/api"
USERNAME="admin"
MAX_RETRIES=100
SLEEP_INTERVAL=5
THENEW1ENV="$STACKPRETTYNAME"
set_admin_password() {
    curl -k -X POST "$PORTAINER_URL/users/admin/init" \
    -H "Content-Type: application/json" \
    --data "{\"Username\": \"$USERNAME\", \"Password\": \"$ADMIN_PASSWORD\"}"
}
is_portainer_up() {
    curl -k -s -o /dev/null -w "%{http_code}" "$PORTAINER_URL/system/status" | grep -q "200"
}
rename_environment() {
	THEORG1ENV="local"    
	THEREQ1TOKEN=$(curl -k -s -X POST "$PORTAINER_URL/auth" \
    -H "Content-Type: application/json" \
    --data "{\"Username\": \"$USERNAME\", \"Password\": \"$ADMIN_PASSWORD\"}" | jq -r '.jwt')    
	echo $THEREQ1TOKEN
	THEREQ1ENV=$(curl -k -s -X GET "$PORTAINER_URL/endpoints" \
        -H "Content-Type: application/json" \
        --header "Authorization: Bearer $THEREQ1TOKEN" | jq -r '.[] | select(.Name=="local").Id')  
	echo $THEREQ1ENV
	curl -k -X PUT "$PORTAINER_URL/endpoints/$THEREQ1ENV" \
    -H "Content-Type: application/json" \
    --header "Authorization: Bearer $THEREQ1TOKEN" \
    --data "{\"Name\": \"$THENEW1ENV\"}"
}
echo "Waiting for Portainer to be ready..."
RETRIES=0
until is_portainer_up || [ $RETRIES -eq $MAX_RETRIES ]; do
    echo "Portainer is not up yet. Retrying in $SLEEP_INTERVAL seconds..."
    sleep $SLEEP_INTERVAL
    RETRIES=$((RETRIES+1))
done
if [ $RETRIES -eq $MAX_RETRIES ]; then
    echo "Portainer did not become ready in time. Exiting."
    exit 1
fi

set_admin_password

PortainerGUI=$(ssh -i "${PEM_FILES[${MANAGER_IPS[0]}]}" -o StrictHostKeyChecking=no -p $P1O1R1T $THE1R1E1QUSE1R@${MANAGER_IPS[0]} "docker service ps $STACKNAME""_portainer --filter 'desired-state=running' --format '{{.Node}} {{.CurrentState}}' | grep 'Running' | sort -k2 -r | head -n 1 | awk '{print \$1}'")

echo "Docker Swarm setup completed successfully.Ports List ${PORTSLIST[@]}.URL : https://$PortainerGUI:$PortainerSPort"

simulate_first_login() {
    echo "camehere1"
    TOKEN=$(curl -k -s -X POST "$PORTAINER_URL/auth" \
    -H "Content-Type: application/json" \
    --data "{\"Username\": \"$USERNAME\", \"Password\": \"$ADMIN_PASSWORD\"}" | jq -r '.jwt')
    echo "camehere2 $TOKEN"
    if [ -z "$TOKEN" ]; then
    curl -k -s -X GET "$PORTAINER_URL/endpoints" \
        -H "Content-Type: application/json" \
        --header "Authorization: Bearer $TOKEN"
    fi
}
is_environment_ready() {
	echo "camehere3"
	TOKEN=$(curl -k -s -X POST "$PORTAINER_URL/auth" \
    -H "Content-Type: application/json" \
    --data "{\"Username\": \"$USERNAME\", \"Password\": \"$ADMIN_PASSWORD\"}" | jq -r '.jwt') 
    echo "camehere4 $TOKEN"   
	ENV_ID=$(curl -k -s -X GET "$PORTAINER_URL/endpoints" \
        -H "Content-Type: application/json" \
        --header "Authorization: Bearer $TOKEN" | jq -r '.[] | select(.Name=="local").Id')  
        echo "camehere5 $ENV_ID" 
    if [ -z "$ENV_ID" ]; then
        return 1
    else
        return 0
    fi
}
simulate_first_login
echo "Waiting for the local environment to be ready..."
RETRIES=0
until is_environment_ready || [ $RETRIES -eq $MAX_RETRIES ]; do
    echo "Local environment is not ready yet. Retrying in $SLEEP_INTERVAL seconds..."
    sleep $SLEEP_INTERVAL
    RETRIES=$((RETRIES+1))
done
if [ $RETRIES -eq $MAX_RETRIES ]; then
    echo "Local environment did not become ready in time. Exiting."
    exit 1
fi
rename_environment

sudo rm -f $THENOHUPFILE
fi

sudo rm -rf /home/$CURRENTUSER/.ssh/known_hosts
sudo rm -rf /root/.ssh/known_hosts
sudo rm -rf /root/.bash_history
sudo rm -rf /home/$CURRENTUSER/.bash_history

#https://github.com/portainer/portainer/issues/523
#https://github.com/portainer/portainer/issues/1205
#https://www.portainer.io/blog/monitoring-a-swarm-cluster-with-prometheus-and-grafana
#https://portainer-notes.readthedocs.io/en/latest/deployment.html

