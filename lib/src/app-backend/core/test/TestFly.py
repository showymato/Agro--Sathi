import argparse
import time

from dronekit import connect, VehicleMode


# Function to connect script to drone

def connect_copter():
    parser = argparse.ArgumentParser(description='commands')
    parser.add_argument('--connect')
    args = parser.parse_args()

    connection_string = args.connect

    vehicle = connect(connection_string, wait_ready=True)

    return vehicle


# Function to arm the drone and takeoff into the air##

def arm_and_takeoff(target_altitude):
    while not vehicle.is_armable:
        print("Waiting for vehicle to be armed")
        time.sleep(1)

    # Switch vehicle to GUIDED mode and wait for change
    vehicle.mode = VehicleMode("GUIDED")
    while vehicle.mode != "GUIDED":
        print("Waiting for vehicle to enter GUIDED mode")
        time.sleep(1)

    # Arm vehicle once GUIDED mode is confirmed
    vehicle.armed = True
    while not vehicle.armed:
        print("Waiting for vehicle to become armed.")
        time.sleep(1)

    vehicle.simple_takeoff(target_altitude)
    while True:
        print("Current Altitude: %d" % vehicle.location.global_relative_frame.alt)
        if vehicle.location.global_relative_frame.alt >= target_altitude * .95:
            break
        time.sleep(1)

    print("Target altitude reached")
    return None


# Mission

vehicle = connect_copter()
print("About to takeoff..")

vehicle.mode = VehicleMode("GUIDED")
arm_and_takeoff(2)  # Tell drone to fly 2 meters in the sky
vehicle.mode = VehicleMode("LAND")  # Once drone reaches altitude, tell it to land

time.sleep(2)

print("End of function")
print("Arducopter version is: %s" % vehicle.version)

while True:
    time.sleep(2)
