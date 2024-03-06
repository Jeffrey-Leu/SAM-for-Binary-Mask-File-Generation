import cv2
import numpy as np
import os

# After the SAM code produces a desirable segmentation output, the SAM raw output files need image filtering methods for conversion into a binary mask file.
# This code uses color thresholding to convert the raw SAM output into a binary mask file. The raw output segments by overlaying a light blue mask on the original image. 
# The color threshold is set to be the light blue color used by SAM, and converts that area into white. All other regions of the image not overlaid in light blue are convert to black.
# After this code is done running, you may see that the binary mask files contain noisy edges or salt and pepper noise, likely a result of SAM. 
# If needed, refer to other image filtering codes to smooth edges and remove noise.

# All that is needed for this code is and input image sequence folder path, and the desired output folder path.

# Directory containing the image sequence
image_sequence_dir = r'c:\Users\jyl772\Desktop\Final SAM Codebase\Bubble Example Output'

# Output directory for the mask images
output_mask_dir = r'c:\Users\jyl772\Desktop\Final SAM Codebase\Bubble Binary'

# Define the lower and upper HSV threshold values for light blue
lower_threshold = np.array([90, 50, 50])  # Replace with your desired lower threshold
upper_threshold = np.array([140, 255, 255])  # Replace with your desired upper threshold

# Ensure the output directory exists
os.makedirs(output_mask_dir, exist_ok=True)

# List all image files in the input directory
image_files = sorted([f for f in os.listdir(image_sequence_dir) if f.endswith('.tif')])

# Process each image in the sequence
for image_file in image_files:
    # Load the image
    image = cv2.imread(os.path.join(image_sequence_dir, image_file))

    # Convert the image to the HSV color space for better color thresholding
    hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Create a mask using inRange function to threshold the light blue color
    mask = cv2.inRange(hsv_image, lower_threshold, upper_threshold)

    # Save the inverted mask as a separate image file
    mask_filename = os.path.join(output_mask_dir, image_file)
    cv2.imwrite(mask_filename, mask)



