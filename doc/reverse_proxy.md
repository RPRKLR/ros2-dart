# Putting a reverse proxy in front of rosbridge

rosbridge has no authentication, and its TLS is a certificate file you manage
by hand. Off the workbench, put a reverse proxy in front of it. The proxy
terminates TLS, checks a token, and passes the WebSocket through. The robot's
bridge then listens only on localhost.

> **Status:** the nginx configuration was run end to end, with nginx 1.28
> in front of rosbridge 4.2.1 on Lyrical. Through it the bridge check passes
> 18/18. A wrong or missing token is refused with a 403 at the handshake. TLS
> works with the certificate pinned and fails without it. Chrome connects with
> the token either in the query or as a subprotocol, under dart2js and WASM.
> The `proxy_read_timeout` below keeps a silent link that nginx's default
> drops after 60 s. The Caddy configuration has **not** been run.

---

## 1. The bridge: localhost only

```bash
ros2 launch rosbridge_server rosbridge_websocket_launch.xml address:=127.0.0.1
```

Without `address:=127.0.0.1` the bridge keeps listening on every interface,
and anyone on the network can skip the proxy.

## 2. Where the token goes

The client can carry a credential in two places. Which one works depends on
the platform:

| | Native (Android, iOS, desktop) | Browser |
|---|---|---|
| Query string, `wss://robot/ros?token=…` | works | works |
| Subprotocol, `Ros2Client(protocols: ['token.…'])` | works | **only if the proxy selects it** |

A browser refuses a handshake whose response selects none of the
subprotocols it offered, and rosbridge never selects one. Measured in Chrome
against rosbridge 4.2.1: offering a subprotocol, the client never connects;
with the same token in the query, it does. So a proxy that reads the token
from the subprotocol must also answer with it, as the nginx example below
does.

The query string is the simple choice. It does show up in access logs, so keep
the token out of them, as below.

```dart
final ros = Ros2Client(Uri.parse('wss://robot.example.com/ros?token=$token'));
```

## 3. nginx

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

# Access log lines without the query string, so tokens are not written down.
log_format no_query '$remote_addr [$time_local] "$request_method $uri" $status';

server {
    listen 443 ssl;
    server_name robot.example.com;
    ssl_certificate     /etc/ssl/robot.crt;
    ssl_certificate_key /etc/ssl/robot.key;
    access_log /var/log/nginx/rosbridge.log no_query;

    location = /ros {
        # Token in the query. Use a long random value, not this one.
        if ($arg_token != "change-me-to-a-long-random-string") {
            return 403;
        }

        # The trailing slash matters: it replaces /ros with /, the only path
        # rosbridge serves. Without it the handshake fails with a 404.
        proxy_pass http://127.0.0.1:9090/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;

        # nginx closes a proxied connection after 60 s with no data from the
        # bridge. The client keeps a healthy link busier than that (native
        # pings every 5 s, browser idle probes), but a client with both off
        # was cut at 60 s without this, and kept with it.
        proxy_read_timeout 1h;
        proxy_send_timeout 1h;

        # Large messages (images, maps, point clouds) stream through, rather
        # than being buffered whole.
        proxy_buffering off;
    }
}
```

### Token as a subprotocol instead

For browsers that must not put the token in the URL. The client offers exactly
one subprotocol, `token.<value>`, and the proxy checks it and selects it in
its answer. `always` is needed because nginx otherwise adds headers only to
2xx and 3xx responses, and a WebSocket handshake is a 101.

```nginx
    location = /ros {
        if ($http_sec_websocket_protocol != "token.change-me-to-a-long-random-string") {
            return 403;
        }
        add_header Sec-WebSocket-Protocol $http_sec_websocket_protocol always;

        # ...the same proxy_* lines as above...
    }
```

```dart
final ros = Ros2Client(Uri.parse('wss://robot.example.com/ros'),
    protocols: ['token.$token']);
```

Offer only the one subprotocol. The selected value must be exactly one of
those offered, and this configuration echoes the whole header back. Checked
in Chrome: with the right token the browser connects and calls services, and
with a wrong one it is refused.

## 4. Caddy

Caddy gets and renews a certificate by itself, and proxies WebSockets without
extra configuration. With the token in the query (not yet run here, unlike
the nginx configuration):

```caddy
robot.example.com {
    @authorised {
        path /ros
        query token=change-me-to-a-long-random-string
    }
    handle @authorised {
        reverse_proxy 127.0.0.1:9090 {
            flush_interval -1
        }
    }
    respond 403
}
```

Caddy has no direct way to keep the query out of its logs. If it logs
requests, give each robot or user its own token, so that one leaked from a
log can be revoked alone.

## 5. Checking it

From the development machine, through the proxy:

```bash
cd packages/ros2_client
dart run example/real_connection_check.dart 'wss://robot.example.com/ros?token=…'
```

A wrong token should fail to connect, rather than connect and then go quiet.
The client then retries with backoff, and `RosConnectionStatus` shows the
countdown.
