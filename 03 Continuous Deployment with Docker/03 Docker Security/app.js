const express = require('express');
const fs = require('fs');
const app = express();

app.get('/', (req, res) => {
    const secret = fs.readFileSync('/run/secrets/app_secret', 'utf8');
    res.send(`Hello from the Docker Security Demo! Secret: ${secret}`);
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});