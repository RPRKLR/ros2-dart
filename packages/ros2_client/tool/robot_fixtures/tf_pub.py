import sys, math
sys.path.insert(0, '/opt/ros/humble/local/lib/python3.10/dist-packages')
import rclpy
from rclpy.node import Node
from tf2_ros import TransformBroadcaster, StaticTransformBroadcaster
from geometry_msgs.msg import TransformStamped

def stamped(parent, child, x=0.0, y=0.0, z=0.0, yaw=0.0, stamp=None):
    t = TransformStamped()
    if stamp is not None:
        t.header.stamp = stamp
    t.header.frame_id = parent
    t.child_frame_id = child
    t.transform.translation.x = x
    t.transform.translation.y = y
    t.transform.translation.z = z
    t.transform.rotation.z = math.sin(yaw / 2)
    t.transform.rotation.w = math.cos(yaw / 2)
    return t

class TfPub(Node):
    def __init__(self):
        super().__init__('tf_pub')
        self.dyn = TransformBroadcaster(self)
        # Three separate latching broadcasters, as a real robot has: URDF
        # publisher plus one per sensor driver.
        self.s1 = StaticTransformBroadcaster(self)
        self.s2 = StaticTransformBroadcaster(self)
        self.s3 = StaticTransformBroadcaster(self)
        now = self.get_clock().now().to_msg()
        self.s1.sendTransform(stamped('base_link', 'laser', x=0.2, z=0.3, stamp=now))
        self.s2.sendTransform(stamped('base_link', 'camera', x=0.1, z=0.6, yaw=0.3, stamp=now))
        self.s3.sendTransform(stamped('base_link', 'imu', z=0.1, stamp=now))
        self.t = 0.0
        self.create_timer(0.02, self.tick)   # 50 Hz, like a real odom source

    def tick(self):
        now = self.get_clock().now().to_msg()
        self.t += 0.02
        self.dyn.sendTransform(stamped('map', 'odom', x=1.0, stamp=now))
        self.dyn.sendTransform(stamped(
            'odom', 'base_link',
            x=2.0 * math.cos(self.t), y=2.0 * math.sin(self.t),
            yaw=self.t, stamp=now))

rclpy.init()
rclpy.spin(TfPub())
