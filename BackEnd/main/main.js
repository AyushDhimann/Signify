const express = require('express');
const multer = require('multer');
const path = require('path');
const { exec } = require('child_process');
const fs = require('fs/promises');
const app = express();
const port = 4000; // Change the port to 4000

// Create the "final" directory if it doesn't exist
const finalDir = path.join(__dirname, 'final');
fs.mkdir(finalDir, { recursive: true })
  .then(() => console.log(`Created "final" directory at ${finalDir}`))
  .catch((err) => console.error(`Error creating "final" directory: ${err}`));

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Create a unique folder for each uploaded file
    const uniqueFolderName = `uploads/${Date.now()}`;
    fs.mkdir(uniqueFolderName)
      .then(() => {
        cb(null, uniqueFolderName);
      })
      .catch((err) => {
        console.error(`Error creating folder: ${err}`);
        cb(err, 'uploads/');
      });
  },
  filename: (req, file, cb) => {
    // Reverse the original filename and save it
    const reversedFileName = file.originalname.split('').reverse().join('');
    console.log(`Saving file as: ${reversedFileName}`);
    cb(null, reversedFileName);
  },
});

const upload = multer({ storage });

app.use('/uploads', express.static('uploads'));

// An array to keep track of uploaded file details and processing results
const fileData = [];

// Define a POST route for file uploads
app.post('/uploads', upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded.');
  }

  const uploadedFileName = req.file.filename;
  console.log(`Uploaded file: ${uploadedFileName}`);

  // Process 1: Execute Python script on the uploaded file
  const process1ResultFileName = `process1-${uploadedFileName}`;
  console.log(`Executing Process 1 on: ${uploadedFileName}`);
  await executePythonScript(req.file.path, process1ResultFileName, 'pythonScript1.py', uploadedFileName);
  console.log(`Process 1 completed on: ${uploadedFileName}`);

  // Process 2: Execute another Python script on the uploaded file
const process2ResultFileName = `process2-${uploadedFileName}`;
console.log(`Executing Process 2 on: ${uploadedFileName}`);
const process2OutputPath = path.join(req.file.destination, process2ResultFileName); // Specify the correct path

await executePythonScript(process1ResultFileName, process2OutputPath, 'pythonScript2.py', uploadedFileName);
console.log(`Process 2 completed on: ${uploadedFileName}`);

// Move the final result to the "final" directory
const finalFilePath = path.join(finalDir, process2ResultFileName);

try {
  await fs.rename(process2OutputPath, finalFilePath);
  console.log(`Final result moved to "final" directory: ${finalFilePath}`);
} catch (error) {
  console.error(`Error moving final result: ${error}`);
}



try {
  await fs.rename(sourceFilePath, finalFilePath);
  console.log(`Final result moved to "final" directory: ${finalFilePath}`);
} catch (error) {
  console.error(`Error moving final result: ${error}`);
}


  // Store information about the uploaded file and process results
  fileData.push({
    uploadedFileName,
    process1ResultFileName,
    process2ResultFileName,
  });

  res.status(200).json({
    message: 'File uploaded and processed successfully',
    uploadedFileName,
    process1ResultFileName,
    process2ResultFileName,
  });
});

// Define a route to download a processed file
app.get('/download/:filename', (req, res) => {
  const requestedFileName = req.params.filename;

  // Find the file information by the requested filename
  const fileInfo = fileData.find((file) => {
    return (
      file.uploadedFileName === requestedFileName ||
      file.process1ResultFileName === requestedFileName ||
      file.process2ResultFileName === requestedFileName
    );
  });

  if (!fileInfo) {
    return res.status(404).send('File not found.');
  }

  const filePath = path.join('final', requestedFileName);
  console.log(`Downloading file: ${requestedFileName}`);
  res.download(filePath, (err) => {
    if (err) {
      console.error(`Error downloading file: ${err.message}`);
    } else {
      console.log(`File downloaded: ${requestedFileName}`);
    }
  });
});

// Function to execute a Python script
async function executePythonScript(inputFilePath, outputFileName, scriptFileName, filenameArg) {
  const command = `python ${scriptFileName} ${inputFilePath} ${outputFileName} "${filenameArg}"`;
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing Python script: ${error.message}`);
        reject(error);
      } else {
        console.log(`Python script executed successfully: ${stdout}`);
        resolve();
      }
    });
  });
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
