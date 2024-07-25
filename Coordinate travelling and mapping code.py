# Coordinate travelling and mapping code

# This Python script controls a drone equipped with a camera and GPS to perform a grid-based survey. It captures images at specified grid coordinates and records GPS data for each image. Key features include:

# Camera Integration: Uses the PiCamera to capture images.
# GPS Tracking: Records GPS coordinates for each image.
# PID Control: Moves the drone to target positions using PID controllers to ensure accurate navigation.
# Grid Survey: Moves the drone in a zigzag pattern across a defined grid size, capturing images and recording coordinates at each point.
import time
import picamera
import gps  # Assuming you have a GPS module and a suitable library installed
from simple_pid import PID

# Define the grid size and image capturing intervals
grid_size = 6
interval = 0.5

# Initialize the camera
camera = picamera.PiCamera()

# Initialize GPS
gpsd = gps.gps(mode=gps.WATCH_ENABLE)

# Function to capture an image
def capture_image(x, y):
    filename = f"image_{x}_{y}.jpg"
    camera.capture(filename)
    print(f"Captured {filename} at coordinates: ({x}, {y})")
    
    # Get GPS coordinates
    gpsd.next()
    lat = gpsd.fix.latitude
    lon = gpsd.fix.longitude
    
    # Save GPS coordinates with the image
    with open(f"{filename}.txt", 'w') as f:
        f.write(f"GPS Coordinates: {lat}, {lon}\n")

# Function to get current GPS position
def get_current_position():
    gpsd.next()
    return gpsd.fix.latitude, gpsd.fix.longitude

# Function to move the drone to a specific position using PID control
def move_to_position(target_lat, target_lon, pid_lat, pid_lon):
    current_lat, current_lon = get_current_position()
    while True:
        current_lat, current_lon = get_current_position()
        
        control_lat = pid_lat(current_lat)
        control_lon = pid_lon(current_lon)
        
        # Move the drone using control signals
        # This is a placeholder function. You'll need to implement this to actually control your drone.
        move_drone(control_lat, control_lon)
        
        # Check if the drone is within a small threshold of the target
        if abs(current_lat - target_lat) < 0.00001 and abs(current_lon - target_lon) < 0.00001:
            break
        
        time.sleep(0.1)  # Adjust the sleep time as needed

# Placeholder function to control drone movement (implement this based on your drone's SDK)
def move_drone(control_lat, control_lon):
    # Send control signals to the drone
    pass

# Main function to control the drone's flight and capture images
def main():
    # PID controllers for latitude and longitude
    pid_lat = PID(1.0, 0.1, 0.05, setpoint=0)
    pid_lon = PID(1.0, 0.1, 0.05, setpoint=0)
    
    for col in range(grid_size):
        if col % 2 == 0:
            # Ascending column
            for row in range(grid_size):
                x = col
                y = row * interval
                target_lat = initial_lat + (y / 111139)  # Convert meters to degrees
                target_lon = initial_lon + (x / (111139 * cos(initial_lat * pi / 180)))  # Adjust for longitude
                
                pid_lat.setpoint = target_lat
                pid_lon.setpoint = target_lon
                
                move_to_position(target_lat, target_lon, pid_lat, pid_lon)
                capture_image(x, y)
                time.sleep(2)  # Adjust based on drone speed
        else:
            # Descending column
            for row in range(grid_size - 1, -1, -1):
                x = col
                y = row * interval
                target_lat = initial_lat + (y / 111139)  # Convert meters to degrees
                target_lon = initial_lon + (x / (111139 * cos(initial_lat * pi / 180)))  # Adjust for longitude
                
                pid_lat.setpoint = target_lat
                pid_lon.setpoint = target_lon
                
                move_to_position(target_lat, target_lon, pid_lat, pid_lon)
                capture_image(x, y)
                time.sleep(2)  # Adjust based on drone speed

if _name_ == "_main_":
    # Define initial latitude and longitude
    initial_lat, initial_lon = get_current_position()
    main()
