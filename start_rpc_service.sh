#! /bin/bash

CUSTOM_ENV_CTL_SYSTEM_NAME=$(hostnamectl --json=pretty | jq -r .OperatingSystemPrettyName || exit)
export CUSTOM_ENV_CTL_SYSTEM_NAME
case "${CUSTOM_ENV_CTL_SYSTEM_NAME}" in
*"24.04"*)
  export CUSTOM_ENV_ROS_SUFFIX="kilted"
  ;;
*"22.04"*)
  export CUSTOM_ENV_ROS_SUFFIX="humble"
  ;;
esac



cleanupsub() {
    echo "clean up the rpc service node "
    sudo killall rpc_service_node
    sudo killall robot_state_publisher
}
cleanup() {
    cleanupsub
    exit 0
}

trap cleanup SIGTERM SIGINT

cleanupsub

export FASTRTPS_DEFAULT_PROFILES_FILE=/opt/booster/BoosterRos2/fastdds_profile_udp_only.xml
source /opt/ros/"${CUSTOM_ENV_ROS_SUFFIX}"/setup.bash

robot_info_path="/opt/booster/robot_info.txt"
model=$(grep -w "^Model:" $robot_info_path | awk -F ': ' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
echo "Extracted Model: \"$model\""
if [ -z "$model" ]; then
    echo "Model is empty"
elif [ "$model" = "Booster T1" ]; then
    echo "Running robot_state_publisher for Booster T1"
    ros2 run robot_state_publisher robot_state_publisher --ros-args -p robot_description:="$(xacro /opt/booster/Gait/configs/T1/robot.urdf)" &
elif [ "$model" = "Booster T1 7Dof-Arm" ]; then
    echo "Running robot_state_publisher for Booster T1 7Dof-Arm"
    ros2 launch /opt/booster/BoosterRos2/install/booster_t1_7dofarm_state_publisher.launch.py &
    # ros2 run robot_state_publisher robot_state_publisher --ros-args -p robot_description:="$(xacro /opt/booster/Gait/configs/T1_7DofArm/robot.urdf)" &
elif [ "$model" = "Booster K1" ]; then
    echo "Running robot_state_publisher for Booster K1"
    ros2 run robot_state_publisher robot_state_publisher --ros-args -p robot_description:="$(xacro /opt/booster/Gait/configs/K1/robot.urdf)" &
fi

echo "Running rpc_service_node"
source /opt/booster/BoosterRos2Interface/install/setup.bash
source /opt/booster/BoosterRos2/install/setup.bash
cd /opt/booster/BoosterRos2
ros2 launch booster_rpc_bridge rpc_bridge_launch_motion.py
    
