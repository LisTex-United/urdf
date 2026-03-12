from launch import LaunchDescription
from launch_ros.actions import Node
import xacro


def generate_launch_description():
    urdf_file = '/opt/booster/Gait/configs/T1_7DofArm/robot.urdf'
    robot_description_config = xacro.process_file(urdf_file)
    robot_description = {'robot_description': robot_description_config.toxml()}

    return LaunchDescription([
        Node(
            package='robot_state_publisher',
            executable='robot_state_publisher',
            output='screen',
            parameters=[robot_description]
        )
    ])
