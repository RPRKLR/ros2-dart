# A stand-in Nav2 NavigateToPose server for example/real_distro_check.dart.
#
# It does not navigate. It answers the way Nav2 does, so the check can see what
# reaches the client: a goal at x < 0 is aborted, and on a distro whose result
# carries error fields (Jazzy onwards) they say why; any other goal succeeds.
import rclpy
from rclpy.action import ActionServer
from rclpy.node import Node
from nav2_msgs.action import NavigateToPose


class NavResultServer(Node):
    def __init__(self):
        super().__init__('nav_result_server')
        ActionServer(self, NavigateToPose, 'navigate_to_pose', self.execute)

    def execute(self, goal_handle):
        result = NavigateToPose.Result()
        if goal_handle.request.pose.pose.position.x < 0:
            if hasattr(result, 'error_code'):
                result.error_code = 204
                result.error_msg = 'goal outside map'
            goal_handle.abort()
        else:
            goal_handle.succeed()
        return result


rclpy.init()
rclpy.spin(NavResultServer())
