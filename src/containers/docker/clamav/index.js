const NodeClam = require('clamscan');
const options = {
    preference: "clamdscan",
    removeInfected: true,
    scanRecursively: true,
    debugMode: true,
    clamscan: {
        active: false
    },
    clamdscan: {
        socket: false,
        host: "127.0.0.1",
        // host: "clamav",
        port: 3310,
        active: true,
        path: "/opt/homebrew/bin/clamdscan"
    }
}
const ClamScan = new NodeClam().init(options);

ClamScan.then(async clamscan => {
    try {
        const version = await clamscan.getVersion();
        console.log(`ClamAV Version: ${version}`);
        const {isInfected, file, viruses} = await clamscan.isInfected('./package.json');
        if (isInfected) console.log(`${file} is infected with ${viruses}!`);
    } catch (err) {
        console.log(err);
    }
}).catch(err => {
    console.log(err);
})
