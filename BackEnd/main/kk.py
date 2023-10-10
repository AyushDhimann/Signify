import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python sign.py <file_path>")
        return

    file_path = sys.argv[1]
    print("Received file path:", file_path)

if __name__ == "__main__":
    main()
