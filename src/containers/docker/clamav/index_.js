const NodeClam = require('clamscan');
const options = {
    preference: "clamscan",
    removeInfected: true,
    scanRecursively: true,
    debugMode: true,
    clamscan: {
        active: true,
        path: "/usr/bin/clamscan",
        // path: "/opt/homebrew/bin/clamscan",
    },
    clamdscan: {
        active: false,
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
