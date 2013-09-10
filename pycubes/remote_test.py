from OSC import OSCClient, OSCMessage
import math
import time

client = OSCClient()
client.connect(("127.0.0.1", 5560))

bytes_per_payload = 4*250
pixels_per_packet = bytes_per_payload / 4
number_of_points = 16 * 16 * 60
packets_per_frame = int(math.ceil(number_of_points / pixels_per_packet))

print "Bytes per payload: " + str(bytes_per_payload)
print "Points per packet: " + str(pixels_per_packet)
print "Number of Points: " + str(number_of_points)
print "Packets per frame: " + str(packets_per_frame)
# print ": " + str()
# print ": " + str()

z = 0
while True:
    frame_time = time.time()
    total_packet_time = 0
    for x in range(packets_per_frame):
        packet_time = time.time()
        msg = OSCMessage("/framebuffer/set")
        msg.append("TEST SECURITY MESSAGE")       # String    security_code
        msg.append(-1)                             # int       frame_index
        msg.append(pixels_per_packet)              # int       payload_length
        starting_index = x * pixels_per_packet + 1
        msg.append(starting_index)                    # int       point_starting_index
        for y in range(pixels_per_packet):
            h_val = ((x+(z*10)) * (360/packets_per_frame)) % 360
            # h_val = 80
            hue = (h_val & 0xFFFF) << 16 
            sat = ((100) & 0xFF) << 8
            brt = ((100) & 0xFF) << 0
            msg.append(hue+sat+brt)
            # msg.append((0 << 24) + (125 << 16) + (125 << 8) + 125)
        client.send(msg)
        total_packet_time += (time.time() - packet_time)
    msg = OSCMessage("/framebuffer/ready")
    msg.append("TEST SECURITY MESSAGE FOR FRAME READY PACKET")
    msg.append(-1)
    client.send(msg)
    print "\nAverage packet time: ", (total_packet_time / packets_per_frame), " seconds"
    print "Frame time: ", time.time() - frame_time, " seconds"
    z += 1