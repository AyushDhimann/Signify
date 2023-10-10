# pythonScript1.py

import sys

new_content = ""

def main():
    if len(sys.argv) != 4:
        sys.exit(1)

    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    original_file_name = sys.argv[3]

    # Read the original content from the input file
    with open(input_file_path, 'r') as input_file:
        original_content = input_file.read()

    # Add "line 2" to the original content
    new_content = original_content + "\nTHIS LINE WAS ADDED INTO THIS FILE FIRST"

    # Write the updated content to the output file
    with open(output_file_path, 'a+') as output_file:
        output_file.write(new_content)

if __name__ == "__main__":
    main()
