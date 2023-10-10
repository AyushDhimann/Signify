import sys

if len(sys.argv) < 2:
    print("Usage: python sign.py <file_path>")
else:
    file_path = sys.argv[1]
    print("Received file path:", file_path)
