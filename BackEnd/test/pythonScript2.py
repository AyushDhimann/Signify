import sys
import os
import fitz
from docx import Document
from PIL import Image
from datetime import datetime
import re
import cv2
import numpy as np
import pytesseract
import pdf2docx
from PyPDF2 import PdfReader

file_extension = ""
lol = ""

def extract_file_extension(file_path):
    # Extract the file extension from the provided file path
    # print("Before : ",os.path.splitext(file_path)[-1].lower())

    # Split the file path by '/'
    parts = file_path.split('/')
    text_after_second_slash = ""
    if len(parts) >= 3:
        # Extract the text after the second forward slash
        text_after_second_slash = parts[2]
    file_path = text_after_second_slash
    file_path=file_path[::-1]
    # print("After : ",os.path.splitext(file_path)[-1].lower())
    return os.path.splitext(file_path)[-1].lower()

def extract_pdf_metadata(pdf_document):
    metadata = {}
    try:
        metadata["security_level"] = pdf_document.metadata.get("encrypt")
        metadata["producer"] = pdf_document.metadata.get("producer")
        mod_date = pdf_document.metadata.get("modDate")
        if mod_date:
            # Extract and clean the date part
            date_match = re.search(r'\d{14}', mod_date)
            if date_match:
                mod_date = date_match.group()
                metadata["modification_date"] = datetime.strptime(mod_date, "%Y%m%d%H%M%S")
    except Exception as e:
        print("Error extracting PDF metadata:", str(e))
    return metadata

def extract_docx_metadata(docx_document):
    metadata = {}
    try:
        metadata["security_level"] = "Not applicable"
        metadata["producer"] = "Not applicable"
        metadata["modification_date"] = datetime.fromtimestamp(os.path.getmtime(docx_document))
    except Exception as e:
        print("Error extracting DOCX metadata:", str(e))
    return metadata

def extract_metadata(file_path):
    new_file_path = ""
    # Remove "process2-" prefix
    if "process2-" in file_path:
        new_file_path = file_path.replace("process2-", "", 1)
    else:
        new_file_path = file_path
    file_path = new_file_path
    # print("METADATA : ", file_path)
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return {}
    
    file_extension = os.path.splitext(file_path)[-1].lower()

    if extract_file_extension(file_path) == ".pdf":
        try:
            pdf_document = fitz.open(file_path)
            metadata = extract_pdf_metadata(pdf_document)
            pdf_document.close()
            return metadata
        except Exception as e:
            print(f"Error opening PDF file: {str(e)}")

    elif extract_file_extension(file_path) == ".docx" or ".doc":
        try:
            docx_document = Document(file_path)
            metadata = extract_docx_metadata(docx_document)
            return metadata
        except Exception as e:
            print(f"Error opening DOCX file: {str(e)}")

    else:
        print(f"Unsupported file type: {file_path}")

    return {}

def count_empty_and_full_values(file_path):
    # print("For empty values: ",file_path)
    empty_matches, actual_values, full_matches = 0, 0, 0

    lol3 = file_path
    parts = file_path.split('/')
    text_after_second_slash = ""
    if len(parts) >= 3:
        text_after_second_slash = parts[2]
    ofile_name = text_after_second_slash    
    ofile_name = ofile_name[9:][::-1]
    # print(ofile_name)

    oglen3 = len(ofile_name)
    extoglen3 = oglen3 + 9
    lol3 = lol3[:-extoglen3]
    lol3 += ofile_name
    # print("LOL3: ",lol3)
    file_ext = os.path.splitext(lol3)[-1].lower()
    # print("FILEXT: ",file_ext)

    lol4 = lol3[:-extoglen3 + 9]
    lol4 += ofile_name[::-1]
    # print("LOL4 : ",lol4)
    ##################################################################################################################

    # Function to create an image from a paragraph of text
    def create_image_from_paragraph(paragraph):
        img = np.zeros((150, 800, 3), dtype=np.uint8)
        cv2.putText(img, paragraph, (10, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        for i in range(3):
            cv2.line(img, (10, 70 + i * 20), (790, 70 + i * 20), (255, 255, 255), 2)
        return img

    # Function to perform OCR on an image
    def perform_ocr_on_image(img):
        ocr_text = pytesseract.image_to_string(Image.fromarray(img))
        return ocr_text

    # Function to check if OCR text is similar to the original text
    def is_ocr_text_similar(original_text, ocr_text):
        return original_text == ocr_text

    def extract_text_from_pdf(pdf_file_path):
        try:
            pdf_text = ""
            pdf_reader = PdfReader(pdf_file_path)
            for page in pdf_reader.pages:
                pdf_text += page.extract_text()
            return pdf_text
        except Exception as e:
            print(f"Error extracting text from PDF: {str(e)}")
            return None

    # Function to convert the input file to a TXT file
    def convert_to_txt(input_file):
        print("CTT: ", input_file)
        file_extension = os.path.splitext(input_file)[1].lower()

        # print("FILEEXTT : ",file_extension,"extract_file_extension(lol3) :",extract_file_extension(lol3),"file_ext: ",file_ext)
        if file_ext == ".pdf":
            text = extract_text_from_pdf(input_file)
        elif file_ext in (".png", ".jpg", ".jpeg", ".heif"):
            text = extract_text_from_image(input_file)
        elif file_ext == ".docx":
            text = extract_text_from_docx(input_file)
        else:
            raise ValueError("Unsupported file format")

        # Create a new directory for the output TXT files
        output_dir = "output_txt"
        os.makedirs(output_dir, exist_ok=True)

        # Create the output file path with .txt extension
        output_file = os.path.join(output_dir, os.path.basename(input_file) + ".txt")

        with open(output_file, "w") as f:
            f.write(text)

        print(f"Converted {input_file} to {output_file}")

    # Function to extract text from a PNG image
    def extract_text_from_image(image_file):
        img = cv2.imread(image_file)
        ocr_text = perform_ocr_on_image(img)
        return ocr_text

    # Function to extract text from a DOCX file
    def extract_text_from_docx(docx_file):
        text = docx2txt.process(docx_file)
        return text

  
    convert_to_txt(lol4)
    #################################################################
    lol5 = ofile_name[::-1]


    file_path = f"output_txt/{lol5}.txt"
    # print("LOL5 :", file_path)
    # print("lol5.endswith", lol5.endswith(".txt"))
    if os.path.exists(file_path):
        # print("YESSSSSSSSSSSSSSSSSSSSS")
        try:
            with open(file_path, "r") as f:
                input_string = f.read()

            # Define regular expressions to match empty and full values.
            underscore_without_spaces = r'(?<!\w)_+(?!\w)'
            underscore_with_surrounding_characters = r'\b\w*_{2,}(?!\w|_\w)\b'

            # Find and count occurrences of empty and full values.
            empty_matches = len(re.findall(underscore_without_spaces, input_string))
            full_matches = len(re.findall(underscore_with_surrounding_characters, input_string))
            actual_values = full_matches - empty_matches
        except Exception as e:
            print(f"Error reading and processing text file: {str(e)}")
    else:
        print("File does not exist")

    return empty_matches, actual_values, full_matches

def process_file_name(file_name):
    if file_name.startswith("process1-"):
        file_name = file_name[len("process1-"):][::-1]
        file_name = "process1-" + file_name
    return file_name

def main():
    if len(sys.argv) != 4:
        print("Usage: python pythonScript1.py input_file output_file original_file_name")
        sys.exit(1)
    file_extension = ""
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    original_file_name = sys.argv[3]

    frlol2 = original_file_name

    print("input: ",input_file_path, "output: ",output_file_path, "original: ",original_file_name)

    lol = output_file_path
    original_file_name = original_file_name[::-1]

    oglen = len(original_file_name)
    extoglen = oglen
    lol = lol[:-extoglen]
    lol += original_file_name
    # print("LOL: ",lol)


    lol2 = lol[:-oglen]
    lol2 += frlol2
    # print("LOL2: ",lol2)
    input_file_path = lol2

    # Extract the file extension from the 'lol' variable
    file_extension = extract_file_extension(lol)

    # Process the file name
    original_file_name = process_file_name(original_file_name)

    metadata = extract_metadata(input_file_path)
    empty_values, actual_values, full_values = count_empty_and_full_values(input_file_path)

    # Create a string containing metadata and empty lines data
    result = f"File: {original_file_name}\n"
    # result += f"File Extension: {file_extension}\n"  # Add file extension to result

    if metadata:
        result += f"Security Level: {metadata.get('security_level', 'Not available')}\n"
        result += f"Producer: {metadata.get('producer', 'Not available')}\n"
        mod_date = metadata.get("modification_date")
        if mod_date:
            result += f"Modification Date: {mod_date.strftime('%Y-%m-%d %H:%M:%S')}\n"
    else:
        result += "No metadata available\n"

    result += "\nText File Values:\n"
    result += f"Empty values: {empty_values}\n"
    result += f"Actual values: {actual_values}\n"
    result += f"Full values: {full_values}\n"
    print()
    # Debugging output
    print("Result:")
    print(result)
    print("Output File Path:")
    print(output_file_path)
    smol_output_file_path = ""
    partss = output_file_path.split('/')
    print("Partss: ", partss)
    text_after_secondd_slash = ""
    if len(partss) >= 3:
        # Extract the text after the second forward slash
        text_after_secondd_slash = partss[2]
    smol_output_file_path = text_after_secondd_slash
    print(smol_output_file_path)
    ooutput_file_path = f"final/{smol_output_file_path}"

    # Write the result to the output file
    with open(ooutput_file_path, 'w') as output_file:
        output_file.write(result)

    try:
        # Check if the file exists before attempting to delete it
        if os.path.exists(input_file_path):
            os.remove(input_file_path)
        else:
            print(f"File '{input_file_path}' does not exist.")
    except Exception as e:
        print(f"Error deleting the file: {e}")

if __name__ == "__main__":
    main()
