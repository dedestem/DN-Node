// Modules
import {Api, RegisterNode} from './DN-Node.js';

// Main
Api.get('/', (req, res) => {
    res.send('Hello!');
});

// Register
RegisterNode();