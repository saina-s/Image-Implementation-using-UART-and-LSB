def bit_text_to_bmp(input_text_file, original_bmp_path, output_bmp_path):
    # Read the bit string from the text file
    with open(input_text_file, 'r') as text_file:
        bit_string = text_file.read()
    
    # Convert the bit string back to bytes
    pixel_data = bytearray(int(bit_string[i:i+8], 2) for i in range(0, len(bit_string), 8))
    
    # Read the original BMP file to extract the header
    with open(original_bmp_path, 'rb') as bmp_file:
        bmp_data = bmp_file.read()
    
    # Extract the BMP header (14 bytes for file header + 40 bytes for DIB header)
    header_size = 14 + 40  # BMP file header + DIB header
    bmp_header = bmp_data[:header_size]
    
    # Combine the header and the reconstructed pixel data
    reconstructed_bmp_data = bmp_header + pixel_data
    
    # Write the reconstructed BMP data to a new file
    with open(output_bmp_path, 'wb') as output_file:
        output_file.write(reconstructed_bmp_data)

# Example usage
input_text_file = "encryption_file.txt"  # Text file containing the binary data
original_bmp_path = "input_image.bmp"  # Original BMP file (used to extract the header)
output_bmp_path = "reconstructed_image.bmp"  # Output BMP file

bit_text_to_bmp(input_text_file, original_bmp_path, output_bmp_path)

print(f"Reconstructed BMP image has been saved to {output_bmp_path}")
