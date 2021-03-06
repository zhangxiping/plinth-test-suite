#!/bin/bash



# the driver should support 700k iops per controller.
# IN : N/A
# OUT: N/A
function fio_iops_controller()
{
    Test_Case_Title="fio_iops_controller"

    local max_value=0
    for iodepth in "${FIO_IODEPTH_LIST[@]}"
    do
        sed -i "{s/^iodepth=.*/iodepth=${iodepth}/g;}" ${FIO_CONFIG_PATH}/fio.conf
        info=`${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/fio ${FIO_CONFIG_PATH}/fio.conf | grep "iops="`
        iops=`echo ${info} | awk -F ',' '{print $3}' | awk -F '=' '{print $2}'`
        let iops=${iops}/1024
        if [ ${iops} -gt ${max_value} ]
        then
            max_value=${iops}
        fi
        echo "iodepth: ${iodepth},iops :${iops}" >> ${BaseDir}/log/${FIO_IOPS_DB_FILE}
    done

    if [ ${max_value} -lt ${IOPS_THRESHOLD} ]
    then
        MESSAGE="FAIL\tdriver 700k iops verify that ${max_value} is lower than ${IOPS_THRESHOLD}."
        echo ${MESSAGE}
        return 1
    fi

    MESSAGE="PASS"
    echo ${MESSAGE}
}


function main()
{
    #Judge the current environment, directly connected environment or expander environment.
    judgment_network_env
    if [ $? -ne 0 ]
    then
    MESSAGE="BLOCK\tthe current environment direct connection network, do not execute test cases."
    echo "the current environment direct connection network, do not execute test cases."
    return 0
    fi
    #get system disk partition information.
    fio_config

    # call the implementation of the automation use cases
    test_case_function_run
}

main
