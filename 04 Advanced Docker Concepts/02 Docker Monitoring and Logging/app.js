const express = require('express');
const app = express();

app.get('/', (req, res) => {
    console.log(`[${new Date().toISOString()}] Request to / endpoint`);
    res.send('Hello from the Monitoring and Logging Demo!');
});

app.get('/metrics', (req, res) => {
    console.log(`[${new Date().toISOString()}] Request to /metrics endpoint`);
    res.json({
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});