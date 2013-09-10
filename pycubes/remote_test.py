from OSC import OSCClient, OSCMessage
import math
import time

client = OSCClient()
client.connect(("127.0.0.1", 5560))

pixels_per_packet = 250
packets_per_frame = 40
max_points = pixels_per_packet * packets_per_frame

while True:
    for x in range(packets_per_frame):
        msg = OSCMessage("/framebuffer/set")
        msg.append("TEST SECURITY MESSAGE")       # String    security_code
        msg.append(-1)                             # int       frame_index
        msg.append(pixels_per_packet)              # int       payload_length
        starting_index = x * pixels_per_packet + 1
        msg.append(starting_index)                    # int       point_starting_index
        for y in range(pixels_per_packet):
            msg.append(-16711681 + x)
            # msg.append((0 << 24) + (125 << 16) + (125 << 8) + 125)
        client.send(msg)
    msg = OSCMessage("/framebuffer/ready")
    msg.append("TEST SECURITY MESSAGE FOR FRAME READY PACKET")
    msg.append(-1)
    client.send(msg)