// Express App 1
const express1 = require('express');
const bodyParser1 = require('body-parser');
const fs1 = require('fs');

const app1 = express1();
const port1 = 5001; // Change this to your desired port

app1.use(bodyParser1.json());

app1.post('/sign', async (req, res) => {
  console.log('Express App 1: Received POST request at /sign');

  if (req.body.action === 'Sign' && req.body.filePath) {
    const filePath = req.body.filePath;
    const part1FilePath = `${filePath}.part1`;
    console.log(`Express App 1: Checking for file1 at: ${part1FilePath}`);

    try {
      await waitForFile(part1FilePath, 10000, 500);
      fs1.access(part1FilePath, fs1.constants.F_OK, (err) => {
        if (!err) {
          fs1.readFile(part1FilePath, 'utf8', (err, data) => {
            if (err) {
              console.error(`Express App 1: Error reading ${part1FilePath}: ${err}`);
              res.status(500).json({ error: 'Internal Server Error' });
            } else {
              console.log(`Express App 1: Read data from ${part1FilePath}: ${data}`);
              res.status(200).json({ message: 'Signature request completed successfully', data });
            }
          });
        } else {
          console.log('Express App 1: File does not exist.');
          res.status(500).json({ timeout: true }); // Send a timeout response
        }
      });
    } catch (error) {
      console.log(`Express App 1: ${error.message}`);
      res.status(500).json({ timeout: true }); // Send a timeout response
    }
  } else {
    console.log('Express App 1: Invalid action or missing file path');
    res.status(400).json({ error: 'Invalid action or missing file path' });
  }
});

async function waitForFile(filePath, timeout, interval) {
  return new Promise((resolve, reject) => {
    const start = Date.now();
    
    const checkFile = () => {
      fs1.access(filePath, fs1.constants.F_OK, (err) => {
        if (!err) {
          resolve();
        } else if (Date.now() - start < timeout) {
          setTimeout(checkFile, interval);
        } else {
          reject(new Error('Timeout waiting for the file'));
        }
      });
    };
    
    checkFile();
  });
}

app1.listen(port1, () => {
  console.log(`Express App 1: Server is running on port ${port1}`);
});

// Express App 2
const express2 = require('express');
const bodyParser2 = require('body-parser');
const fs2 = require('fs');

const app2 = express2();
const port2 = 5002; // Change this to your desired port

app2.use(bodyParser2.json());

app2.post('/sign', async (req, res) => {
  console.log('Express App 2: Received POST request at /sign');

  if (req.body.action === 'Sign' && req.body.filePath) {
    const filePath = req.body.filePath;
    const part2FilePath = `${filePath}.part2`;
    console.log(`Express App 2: Checking for file2 at: ${part2FilePath}`);

    try {
      await waitForFile(part2FilePath, 240000, 2000);
      fs2.access(part2FilePath, fs2.constants.F_OK, (err) => {
        if (!err) {
          fs2.readFile(part2FilePath, 'utf8', (err, data) => {
            if (err) {
              console.error(`Express App 2: Error reading ${part2FilePath}: ${err}`);
              res.status(500).json({ error: 'Internal Server Error' });
            } else {
              console.log(`Express App 2: Read data from ${part2FilePath}: ${data}`);
              res.status(200).json({ message: 'Signature request completed successfully', data });
            }
          });
        } else {
          console.log('Express App 2: File does not exist.');
          res.status(500).json({ timeout: true }); // Send a timeout response
        }
      });
    } catch (error) {
      console.log(`Express App 2: ${error.message}`);
      res.status(500).json({ timeout: true }); // Send a timeout response
    }
  } else {
    console.log('Express App 2: Invalid action or missing file path');
    res.status(400).json({ error: 'Invalid action or missing file path' });
  }
});

app2.listen(port2, () => {
  console.log(`Express App 2: Server is running on port ${port2}`);
});

// Express App 3 (Python Execution)
const express3 = require('express');
const bodyParser3 = require('body-parser');
const { exec } = require('child_process');

const app3 = express3();
const port3 = 5000; // Change this to your desired port

app3.use(bodyParser3.json());

app3.post('/sign', (req, res) => {
  console.log('Express App 3: Received POST request at /sign');

  if (req.body.action === 'Sign' && req.body.filePath) {
    const filePath = req.body.filePath;

    // Execute the Python script using child_process, passing the file path as an argument
    const pythonProcess = exec(`python sign.py ${filePath}`, (error, stdout, stderr) => {
      if (error) {
        console.error(`Express App 3: Error: ${error}`);
        res.status(500).json({ error: 'Internal Server Error' });
      } else {
        console.log(`Express App 3: Python script executed successfully`);
        console.log(`Python script output: ${stdout}`);
        res.status(200).json({ message: 'Data received and execution started' });
      }
    });
  } else {
    console.log('Express App 3: Invalid action or missing file path');
    res.status(400).json({ error: 'Invalid action or missing file path' });
  }
});

app3.listen(port3, () => {
  console.log(`Express App 3: Server is running on port ${port3}`);
});
