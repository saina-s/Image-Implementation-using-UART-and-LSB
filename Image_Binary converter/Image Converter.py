def bmp_to_bit_text(image_path, output_text_file):
    # Open the BMP file in binary mode
    with open(image_path, 'rb') as bmp_file:
        # Read the entire BMP file
        bmp_data = bmp_file.read()
    
    # Extract the BMP header size (14 bytes for file header + 40 bytes for DIB header)
    header_size = 14 + 40  # BMP file header + DIB header
    pixel_data_offset = int.from_bytes(bmp_data[10:14], byteorder='little')  # Offset to pixel data
    
    # Extract only the pixel data (ignoring the header and padding)
    pixel_data = bmp_data[pixel_data_offset:]
    
    # Convert pixel data to a string of bits
    bit_string = ''.join(format(byte, '08b') for byte in pixel_data)
    
    # Write the bit string to a text file
    with open(output_text_file, 'w') as text_file:
        text_file.write(bit_string)

# Example usage
image_path = "input_image.bmp"  # Replace with the path to your BMP image
output_text_file = "image_bits.txt"  # Output text file to store bit data

bmp_to_bit_text(image_path, output_text_file)

print(f"Bit data of the image has been written to {output_text_file}")



"""
from PIL import Image

def image_to_binary_text(image_path, output_text_file):
    # Open the image file
    with Image.open(image_path) as img:
        # Convert the image to grayscale (1-bit pixels, black and white)
        bitmap = img.convert('1')
        
        # Get the pixel data
        pixel_data = bitmap.getdata()
        
        # Convert pixel data to binary string
        binary_data = ''.join(format(pixel, '08b') for pixel in pixel_data)
        
        # Save the binary data to a text file
        with open(output_text_file, 'w') as f:
            f.write(binary_data)

# Example usage
image_to_binary_text('input_image.jpg', 'output_bitmap.txt')
"""
