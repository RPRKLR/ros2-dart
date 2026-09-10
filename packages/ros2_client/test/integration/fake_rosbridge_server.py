#!/usr/bin/env python3
"""A minimal rosbridge v2 server, enough to exercise a client end to end.

Implements the subset of the protocol the Dart client depends on: subscribe /
publish echo, call_service, and the action goal -> feedback -> result flow.
Uses Tornado, the same server rosbridge_suite itself is built on.
"""
import json
import sys

import tornado.httpserver
import tornado.ioloop
import tornado.netutil
import tornado.web
import tornado.websocket


class RosbridgeHandler(tornado.websocket.WebSocketHandler):
    def check_origin(self, origin):
        return True

    def open(self):
        self.subscriptions = {}

    def send(self, payload):
        self.write_message(json.dumps(payload))

    def on_message(self, message):
        msg = json.loads(message)
        op = msg.get("op")

        if op == "subscribe":
            topic = msg["topic"]
            self.subscriptions[topic] = msg
            # Echo one message back so the client can prove decoding works.
            if topic == "/chatter":
                self.send({"op": "publish", "topic": topic,
                           "msg": {"data": "hello from tornado"}})
            elif topic == "/cmd_vel":
                self.send({"op": "publish", "topic": topic, "msg": {
                    "linear": {"x": 1.5, "y": 0.0, "z": 0.0},
                    "angular": {"x": 0.0, "y": 0.0, "z": -0.5}}})

        elif op == "publish":
            # Reflect published messages back to any subscriber of that topic.
            if msg["topic"] in self.subscriptions:
                self.send({"op": "publish", "topic": msg["topic"],
                           "msg": msg["msg"]})

        elif op == "call_service":
            args = msg.get("args") or {}
            if msg["service"] == "/__drop__":
                # Lets a test exercise the client's reconnect path for real.
                # Delivered as a service call rather than a subscription:
                # subscriptions are replayed on reconnect, which would drop the
                # client forever.
                self.close(code=1001, reason="simulated drop")
                return
            if msg["service"] == "/rosapi/topics":
                values = {"topics": ["/chatter", "/cmd_vel"],
                          "types": ["std_msgs/msg/String",
                                    "geometry_msgs/msg/Twist"]}
            else:
                values = {"sum": args.get("a", 0) + args.get("b", 0)}
            self.send({"op": "service_response", "id": msg.get("id"),
                       "service": msg["service"], "values": values,
                       "result": True})

        elif op == "send_action_goal":
            goal_id = msg.get("id")
            action = msg["action"]
            order = (msg.get("args") or {}).get("order", 3)
            for i in range(order):
                self.send({"op": "action_feedback", "id": goal_id,
                           "action": action, "values": {"partial": i}})
            self.send({"op": "action_result", "id": goal_id, "action": action,
                       "values": {"sequence": "complete"}, "status": 4,
                       "result": True})

        # Deliberately no set_level and no outgoing "status" frames: real
        # rosbridge implements neither. rosbridge_protocol.py registers no
        # status capability, and Protocol.log writes to the robot's ROS logger
        # only. An earlier version of this fake answered both, which is exactly
        # why the client shipped a set_level op that every real bridge rejects
        # -- a fake that agrees with the client tests nothing.
        elif op == "advertise":
            pass


def main():
    # Bind an ephemeral port by default so concurrent test runs never collide,
    # then tell the harness which port we actually got.
    requested = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    app = tornado.web.Application([(r"/", RosbridgeHandler)])
    sockets = tornado.netutil.bind_sockets(requested, address="127.0.0.1")
    server = tornado.httpserver.HTTPServer(app)
    server.add_sockets(sockets)
    port = sockets[0].getsockname()[1]
    print(f"READY {port}", flush=True)
    tornado.ioloop.IOLoop.current().start()


if __name__ == "__main__":
    main()
