#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
WITHOU_COLOR='\033[0m'
DELEGATOR_ADDRESS='<addr>' #cascadia...
VALIDATOR_ADDRESS='<addr>' #cascadiavaloper...
DELAY=300 #in sec
ACC_NAME=wallet #name wallet
NODE="tcp://localhost:26657" #or another rpc port
CHAIN_NAME=cascadia_6102-1
PWD=<PASS>
HOME_PATH="/root/.cascadiad"

for (( ;; )); do
        echo -e "Get reward from Delegation"
        echo -e "${PWD}\ny\n" | cascadiad tx distribution withdraw-rewards ${VALIDATOR_ADDRESS} --chain-id ${CHAIN_NAME} --from ${ACC_NAME} --home=${HOME_PATH} --gas-adjustment=1.2  --node ${NODE} --gas-prices=7aCC --yes

        for (( timer=30; timer>0; timer-- ))
        do
                printf "* sleep for ${RED_COLOR}%02d${WITHOUT_COLOR} sec\r" $timer
                sleep 1
        done
 
        BAL=$(cascadiad q bank balances ${DELEGATOR_ADDRESS} --node ${NODE} -o json | jq -r '.balances | .[].amount')
        echo -e "BALANCE: ${GREEN_COLOR}${BAL}${WITHOU_COLOR} aCC\n"

        echo -e "Claim rewards\n"
        echo -e "${PWD}\n${PWD}\n" | cascadiad tx distribution withdraw-all-rewards --chain-id ${CHAIN_NAME} --from ${ACC_NAME} --home=${HOME_PATH} --gas-adjustment=1.2 --node ${NODE} --gas-prices=7aCC --yes
        for (( timer=30; timer>0; timer-- ))
        do
                printf "* sleep for ${RED_COLOR}%02d${WITHOU_COLOR} sec\r" $timer
                sleep 1
        done
        BAL=$(cascadiad q bank balances ${DELEGATOR_ADDRESS} --node ${NODE} -o json | jq -r '.balances | .[].amount');
        BAL=$(($BAL-1000000))
        echo -e "BALANCE: ${GREEN_COLOR}${BAL}${WITHOU_COLOR} aCC\n"
        echo -e "Stake ALL\n"
        if (( BAL > 1000000 )); then
        echo -e "${PWD}\n${PWD}\n" | cascadiad tx staking delegate ${VALIDATOR_ADDRESS} ${BAL}aCC --from ${ACC_NAME} --home=${HOME_PATH} --gas-adjustment=1.2 --node ${NODE} --chain-id ${CHAIN_NAME} --gas-prices=7aCC --gas=auto --yes
        else
        echo -e "BALANCE: ${GREEN_COLOR}${BAL}${WITHOU_COLOR} aCC BAL < 10000000 ((((\n"
        fi
        for (( timer=${DELAY}; timer>0; timer-- ))
        do
                printf "* sleep for ${RED_COLOR}%02d${WITHOU_COLOR} sec\r" $timer
                sleep 1
        done       

done
