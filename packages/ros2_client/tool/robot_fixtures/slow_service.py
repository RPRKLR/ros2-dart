import sys
import time
sys.path.insert(0, '/opt/ros/humble/local/lib/python3.10/dist-packages')
import rclpy
from rclpy.callback_groups import ReentrantCallbackGroup
from rclpy.executors import MultiThreadedExecutor
from rclpy.node import Node
from std_srvs.srv import Trigger

# /slow answers after 8 s, /fast at once. The server is multi-threaded, so
# any wait for /fast behind /slow is the bridge's doing, not this node's.


class Services(Node):
    def __init__(self):
        super().__init__('slow_service')
        group = ReentrantCallbackGroup()
        self.create_service(Trigger, '/slow', self.slow, callback_group=group)
        self.create_service(Trigger, '/fast', self.fast, callback_group=group)

    def slow(self, request, response):
        time.sleep(8.0)
        response.success = True
        response.message = 'slow'
        return response

    def fast(self, request, response):
        response.success = True
        response.message = 'fast'
        return response


def main():
    rclpy.init()
    executor = MultiThreadedExecutor(num_threads=4)
    executor.add_node(Services())
    executor.spin()


if __name__ == '__main__':
    main()
