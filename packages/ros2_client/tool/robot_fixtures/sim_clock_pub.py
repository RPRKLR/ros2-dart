import sys
sys.path.insert(0, '/opt/ros/humble/local/lib/python3.10/dist-packages')
import rclpy
from rclpy.node import Node
from rclpy.clock import Clock, ClockType
from rclpy.executors import SingleThreadedExecutor
from rclpy.parameter import Parameter
from rosgraph_msgs.msg import Clock as ClockMsg
from tf2_ros import TransformBroadcaster
from geometry_msgs.msg import TransformStamped

# A simulator that keeps restarting, as Gazebo does whenever someone resets
# the world: /clock runs for PHASE seconds from 500 s, then from 0 s, then
# from 500 s again. So it jumps back and forward in turn.
PHASE = 6.0
STARTS = [500.0, 0.0]


class Sim(Node):
    """Owns /clock, like the simulator."""

    def __init__(self):
        super().__init__('sim_clock')
        self.pub = self.create_publisher(ClockMsg, '/clock', 10)
        self.wall = Clock(clock_type=ClockType.STEADY_TIME)
        self.began = self.wall.now()
        self.create_timer(0.01, self.tick, clock=self.wall)

    def tick(self):
        elapsed = (self.wall.now() - self.began).nanoseconds / 1e9
        phase = int(elapsed // PHASE)
        sim = STARTS[phase % 2] + (elapsed - phase * PHASE)
        m = ClockMsg()
        m.clock.sec = int(sim)
        m.clock.nanosec = int((sim - int(sim)) * 1e9)
        self.pub.publish(m)


class Robot(Node):
    """A use_sim_time node broadcasting map -> base_link, like a diff drive
    plugin. The pose encodes the stamp (x = sim seconds / 100) so the checker
    can tell which side of a restart an answer came from."""

    def __init__(self):
        super().__init__('sim_robot',
                         parameter_overrides=[Parameter('use_sim_time', value=True)])
        self.tf = TransformBroadcaster(self)
        # A wall-rate timer: a sim-time timer stalls when the clock goes back.
        wall = Clock(clock_type=ClockType.STEADY_TIME)
        self.create_timer(0.02, self.tick, clock=wall)

    def tick(self):
        now = self.get_clock().now()
        if now.nanoseconds == 0:
            return  # no /clock yet
        t = TransformStamped()
        t.header.stamp = now.to_msg()
        t.header.frame_id = 'map'
        t.child_frame_id = 'base_link'
        t.transform.translation.x = now.nanoseconds / 1e11
        t.transform.rotation.w = 1.0
        self.tf.sendTransform(t)


rclpy.init()
executor = SingleThreadedExecutor()
executor.add_node(Sim())
executor.add_node(Robot())
executor.spin()
