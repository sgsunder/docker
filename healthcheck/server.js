// Copyright (c) 2018 Shyam Sunder
const express = require('express');
const cors = require('cors');
const os = require('os');
const prettyMs = require('pretty-ms');

// boilerplate to async run a shell command
function fetchFromCommand(cmd, after) {
  return new Promise((p_res, p_rej) => {
    const exec = require('child_process').exec;
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

let app = express();
app.use(cors());

app.get('/', (req, res) => {
  res.send('Server API available on /status');
});

app.get('/status', (req, res) => {
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

  if (process.argv.includes('--zfs')) {
    output.zfs = {};

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
