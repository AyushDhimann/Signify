const express = require('express');
const app = express();
const port = 3000; // You can choose any available port

// Set the view engine to EJS
app.set('view engine', 'ejs');

// Define a route to render the HTML template
app.get('/', (req, res) => {
    res.render('lol');
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
