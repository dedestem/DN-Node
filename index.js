// Modules
import {Api, RegisterNode, State} from './DN-Node.js';

// Main
Api.get('/', (req, res) => {
    res.send('Hello!');
});

// Register
RegisterNode(3000);