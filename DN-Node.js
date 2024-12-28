//* 
// DN-Node
// 
// The core for Davidnet express api's
// https://github.com/dedestem/DN-Node/
// *\\

// Services
import Express from 'express';
import Helmet from 'helmet';

// Objects
export const Api = Express();
const Port = 3000;
const Server = Api.listen(Port);

// Configure
Api.use(Helmet());

// Modules
import { ReadJson, WriteJson } from './Utils.js';

// Collect information
(async () => {
    const Info = await ReadJson("./Info.json");

    // Preserve the Commit field
    Info.Start = new Date().toISOString();
    WriteJson('./Info.json', Info);
})();

export async function RegisterNode() {
    Api.get('/Uptime', async (req, res) => {
        const uptime = await GetUptime(); // Assuming GetUptime will now handle async
        res.send(uptime);
    });

    Api.get('/Commit', async (req, res) => {
        const commit = await GetCommit(); // Same for GetCommit
        res.send(commit);
    });

    // 404 - Not Found
    Api.use((req, res, next) => {
        res.status(404).send('404 - Not Found');
    });

    // 500 - Internal Server Error
    Api.use((err, req, res, next) => {
        console.error(err.stack);
        res.status(500).send('Something broke!');
    });
}

// Shutdown code!
process.on('SIGTERM', () => {
    console.debug('Server shutdown request received!');
    Server.close(() => {
        console.debug('HTTP server closed');
    });
});

//////////////////// END OF INIT CODE ///////////////////

export async function GetUptime() {
    const Info = await ReadJson("./Info.json");
    const UptimeMs = new Date() - new Date(Info.Start);

    const seconds = Math.floor(UptimeMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    const uptime = {
        days: days % 365,
        hours: hours % 24,
        minutes: minutes % 60,
        seconds: seconds % 60 
    };

    console.debug(uptime);
    return uptime;
}


export async function GetCommit() {
    const Info = await ReadJson("./Info.json");
    const Commit = Info.Commit;

    console.debug(Commit);
    return Commit.toString();
}
