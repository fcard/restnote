var net     = require('net');
var {spawn} = require('child_process');
var fs      = require('fs')

var jupyterDir = process.cwd()+"/script/jupyter";
var jupyterEnv = Object.assign({}, process.env, {JUPYTER_CONFIG_DIR: jupyterDir});

exports.jupyterProc = function(command, opts) {
  var opts_parsed = [command];
  for (var opt in opts) {
    if (opt == 'args') {
      opts_parsed.push(...opts[opt]);
    } else {
      opts_parsed.push((opt.length == 1? "-" : "--") + opt.replace("_", "-"));
      if (opts[opt] !== true) {
        opts_parsed.push(opts[opt]);
      }
    }
  }
  return spawn("jupyter", opts_parsed, {cwd: jupyterDir, env: jupyterEnv});
}


exports.restviewProc = function(filename,port) {
  return spawn("restview", ["--listen", port.toString(), filename]);
}


exports.waitPort = function waitPort(port, action) {
  var tester = net.createConnection(port, () => {
    action();
    tester.destroy();
  });
  tester.on('error', (e) => {
    setTimeout(()=>waitPort(port,action), 1000);
  });
}
