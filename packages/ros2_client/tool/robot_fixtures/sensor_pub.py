import sys, math
sys.path.insert(0, '/opt/ros/humble/local/lib/python3.10/dist-packages')
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image, LaserScan, PointCloud2, PointField
from std_msgs.msg import Header

W, H = 640, 480
PTS = 20000

class Pub(Node):
    def __init__(self):
        super().__init__('sensor_pub')
        self.img = self.create_publisher(Image, '/camera/image_raw', 10)
        self.scan = self.create_publisher(LaserScan, '/scan', 10)
        self.pc = self.create_publisher(PointCloud2, '/points', 10)
        # Deterministic pattern so the client can verify every byte.
        self.pixels = bytes((i * 7 + 13) % 256 for i in range(W * H * 3))
        self.cloud = bytes((i * 3 + 1) % 256 for i in range(PTS * 16))
        self.create_timer(0.1, self.tick)

    def tick(self):
        h = Header(frame_id='camera')
        m = Image(header=h, height=H, width=W, encoding='rgb8',
                  is_bigendian=0, step=W * 3)
        m.data = self.pixels
        self.img.publish(m)

        s = LaserScan(header=Header(frame_id='laser'),
                      angle_min=-math.pi, angle_max=math.pi,
                      angle_increment=2 * math.pi / 1080,
                      range_min=0.1, range_max=30.0)
        # Include inf and nan: every real lidar emits them.
        s.ranges = [float('inf') if i % 100 == 0 else
                    (float('nan') if i % 101 == 0 else 1.0 + (i % 50) / 10.0)
                    for i in range(1080)]
        self.scan.publish(s)

        c = PointCloud2(header=Header(frame_id='lidar'), height=1, width=PTS,
                        is_bigendian=False, point_step=16,
                        row_step=16 * PTS, is_dense=True)
        c.fields = [PointField(name=n, offset=o, datatype=7, count=1)
                    for n, o in (('x', 0), ('y', 4), ('z', 8))]
        c.data = self.cloud
        self.pc.publish(c)

rclpy.init()
rclpy.spin(Pub())
