const express = require('express');
const bodyParser = require('body-parser');
const { spawn } = require('child_process');

const app = express();
const port = 6000;

app.use(bodyParser.json());

app.post('/chat', (req, res) => {
  const { message, filePath } = req.body; // Include the filePath in the request body

  console.log('Received POST request to /chat'); // Checkpoint: Received the POST request

  // Spawn a Python process and send the message and filePath as command-line arguments
  const pythonProcess = spawn('python', ['chat.py', message, filePath]);

  // Listen for data from the Python process
  pythonProcess.stdout.on('data', (data) => {
    const botResponse = data.toString().trim();
    console.log('Python script response:', botResponse); // Checkpoint: Received response from Python
    res.status(200).json({ message: botResponse }); // Respond to the client
  });

  pythonProcess.stderr.on('data', (data) => {
    console.error('Python script error:', data.toString()); // Checkpoint: Python script error
    res.status(500).json({ error: 'Internal server error' }); // Respond with an error
  });

  pythonProcess.on('close', (code) => {
    if (code !== 0) {
      console.error('Python script exited with code', code); // Checkpoint: Python script exited with a non-zero code
      res.status(500).json({ error: 'Internal server error' }); // Respond with an error
    } else {
      console.log('Python script completed successfully'); // Checkpoint: Python script completed successfully
    }
  });
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`); // Checkpoint: Server is up and running
});
