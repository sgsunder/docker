// Copyright (c) 2018 Shyam Sunder
const express = require('express');
const cors = require('cors');
const os = require('os');
const prettyMs = require('pretty-ms');
const exec = require('child_process').exec;
const fs = require('fs');

// boilerplate to async run a shell command
function fetchFromCommand(cmd, after) {
  return new Promise((p_res, p_rej) => {
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        console.warn(stderr);
        p_rej(stderr);
      } else {
        after(stdout.trim());
        p_res();
      }
    });
  });
}

function fetchFromFile(file, after) {
  return new Promise((p_res, p_rej) => {
    fs.readFile(file, (error, data) => {
      if (error) {
        p_rej(error);
      } else {
        after(data);
        p_res();
      }
    });
  });
}

let app = express();
app.use(cors());

// app.get('/', (req, res) => {
//   res.send('Server API available on /status');
// });
//
// app.get('/api/sitelist' (req, res) => {
//
// });

app.use('/', express.static('/opt/app/static'));

// app.use('/api/sitelist', express.static('/opt/app/sitelist.json'));
app.get('/api/sitelist', (req, res) => {
    output = {};
    fetchFromFile('/opt/app/sitelist.json', raw => {
        output = JSON.parse(raw);
    }).then(val => { res.send(output) });
});

app.get('/api/status', (req, res) => {
  let output = {};
  let cmds = [];

  // Get summary uptime
  output.uptime = prettyMs(os.uptime()*1000, {verbose: true});

  // Get OS info
  output.os = {
    release: os.release(),
    platform: os.platform(),
    arch: os.arch()
  }

  // Get load averages
  let loads = os.loadavg();
  output.load = {
    load1:  parseInt(loads[0]*100)/100,
    load5:  parseInt(loads[1]*100)/100,
    load15: parseInt(loads[2]*100)/100
  }

  // Get memory usage
  output.ram = parseInt(100*(1 - (os.freemem() / os.totalmem())));

  // --------------------------
  // Drive Health
  if (process.argv.includes('--drivehealth')) {
    cmds.push(fetchFromFile('/opt/app/drivehealth.json', raw => {
        let drivehealth = JSON.parse(raw);

        // Fetch Time
        let t = new Date(1970, 0, 1);
        t.setSeconds(drivehealth.time);

        // Fetch Temperatures and Drive Health Status
        let totalTemp = 0;
        let maxTemp = 0;
        let tempCount = 0;
        let failingDrives = [];
        Object.keys(drivehealth).forEach((key, index) => {
            let item = drivehealth[key];
            if (item instanceof Object) {
                if ('temp' in item) {
                    totalTemp += item.temp;
                    tempCount++;
                    maxTemp = item.temp > maxTemp ? item.temp : maxTemp;
                }
                if ('smart' in item) {
                    if (item.smart != 'passed') {
                        failingDrives.append(
                            '' + key + ' has message: ' + item.smart);
                    }
                }
            }
        });

        output.drives = {
            time: t,
            temp: {
                max: maxTemp,
                avg: parseInt(totalTemp/tempCount)
            },
            message: failingDrives.length === 0 ?
                'all drives are healthy' : failingDrives.join(', ')
        }
    }));
  }

  // --------------------------
  // ZFS
  if (process.argv.includes('--zfs')) {
    output.zfs = {};

    // Get ARC statistics
    cmds.push(fetchFromCommand(
            'awk \'{print $1, $3}\' < /proc/spl/kstat/zfs/arcstats', raw => {
        let arcstats = {};
        raw.split(os.EOL).map(item => {
            let splitItem = item.split(' ');
            arcstats[splitItem[0]] = parseInt(splitItem[1]);
        });

        // limit output
        output.zfs.arc = {
            hits: arcstats.hits,
            misses: arcstats.misses,
            size: arcstats.size
        }
    }));

    // Summary of pool status
    cmds.push(fetchFromCommand('zpool status -x', raw => {
      output.zfs.short = raw;
    }));

    // List space usage of ZFS
    cmds.push(fetchFromCommand('zfs list -Hp', raw => {
      items = raw.split('\n')[0].split('\t');
      output.zfs.used = parseInt(items[1]);
      output.zfs.avail = parseInt(items[2]);
      output.zfs.percent =
        parseInt(100*output.zfs.used/(output.zfs.used+output.zfs.avail));
    }));
  }

  // ------------------------------------
  // Call all promises and resolve
  Promise.all(cmds).then(vals => { res.send(output) });
});

let server = app.listen(3000, () => {
  console.log('> listening on port', server.address().port);
  console.log('> started on ' + new Date());
});
