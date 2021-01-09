#!/bin/bash

### Simple script to call zbx api methods ###

menu(){
    PS3="Select the operation: "
    select opt in "${options[@]}"; do
        case $opt in
            drule.create)
                drule.create
                ;;
            proxy.get)
                proxy.get
                ;;
            drule.get)
                proxy.get
                ;;
            quit)
                break
                ;;
            *) 
                echo "Invalid option $REPLY"
                ;;
        esac
    done
}

login(){
    json=$(cat user.login.json)
    json=${json/USERNAME/$zbxUser}
    json=${json/PASSWORD/$zbxPwd}
    token=$(curl --silent --show-error --insecure --header ${header} --data "${json}" ${zbxAPI} | jq '.result')
    if [[ $? -ne 0 ]]; then 
        echo "login error"
        exit 1 
    fi
}

logout(){
    json=`cat user.logout.json`
    json=${json/TOKEN/$token}
    curl --silent --show-error --insecure --header $header --data "${json}" ${zbxAPI}
    if [[ $? -ne 0 ]]; then 
        echo "logout error" 
        exit 0
    fi
}

drule.create(){
    login
    json=`cat drule.create.json`
    json=${json/TOKEN/$token}
    curl --silent --show-error --insecure --header $header --data "${json}" ${zbxAPI}
    if [[ $? -ne 0 ]]; then
        echo "error"
    fi
    logout    
}

proxy.get(){
    login
    json=`cat proxy.get.json`
    json=${json/TOKEN/$token}
    curl --silent --show-error --insecure --header $header --data "${json}" ${zbxAPI}
    if [[ $? -ne 0 ]]; then
        echo "error"
    fi
    logout    
}

main(){
    declare -r options=("quit" "drule.create" "drule.get" "proxy.get")
    declare -r zbxAPI='http://x.x.x.x/zabbix/api_jsonrpc.php'
    declare -r header='Content-Type:application/json'
    declare -r zbxUser=''
    declare -r zbxPwd=''
    
    menu
}

main