import sys
sys.path.insert(0, '/opt/ros/humble/local/lib/python3.10/dist-packages')
import rclpy
from rclpy.node import Node
from rclpy.qos import QoSProfile, DurabilityPolicy, ReliabilityPolicy
from nav_msgs.msg import OccupancyGrid

# Publishes two maps ONCE, latched, the way map_server does, then idles. A
# client that connects afterwards gets them only through transient_local.
#
#   /map      40x30: cell (c, r) holds -1, 0 or 100 by (c + r) % 3, and the
#             origin is (-2, -1.5) at 0.05 m/cell, so every field is checkable.
#   /big_map  2048x2048 (4 MiB of cells), a realistic SLAM map, to check a
#             map that size survives the bridge at all.


def grid(width, height, resolution, ox, oy, value):
    m = OccupancyGrid()
    m.header.frame_id = 'map'
    m.info.resolution = resolution
    m.info.width = width
    m.info.height = height
    m.info.origin.position.x = ox
    m.info.origin.position.y = oy
    m.info.origin.orientation.w = 1.0
    m.data = [value(c, r) for r in range(height) for c in range(width)]
    return m


def main():
    rclpy.init()
    node = Node('map_fixture')
    latched = QoSProfile(depth=1, durability=DurabilityPolicy.TRANSIENT_LOCAL,
                         reliability=ReliabilityPolicy.RELIABLE)
    small = node.create_publisher(OccupancyGrid, '/map', latched)
    big = node.create_publisher(OccupancyGrid, '/big_map', latched)
    small.publish(grid(40, 30, 0.05, -2.0, -1.5,
                       lambda c, r: (-1, 0, 100)[(c + r) % 3]))
    big.publish(grid(2048, 2048, 0.05, 0.0, 0.0,
                     lambda c, r: 100 if (c // 64 + r // 64) % 2 else 0))
    node.get_logger().info('maps published')
    rclpy.spin(node)


if __name__ == '__main__':
    main()
