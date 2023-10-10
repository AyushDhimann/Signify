# Your extracted information and output_file_path
result = """
File: affidavit.pdf
Security Level: None
Producer: 
Modification Date: 2023-10-04 19:30:31

Text File Values:
Empty values: 4
Actual values: 10
Full values: 14
"""

output_file_path = "uploads/1696682908342/process2-fdp.tivadiffa"

# Write the result to the output file
with open(output_file_path, 'w') as output_file:
    output_file.write(result)
