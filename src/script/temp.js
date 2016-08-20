var {tmpdir} = require('os');
var {execSync, exec} = require('child_process');

function dirExists(dir) {
  res = execSync(`
    if [ -x '${dir}' ]; then
      printf 'yes'
    else
      printf 'no'
    fi
  `).toString();
  return res == 'yes'
}

function _tmpdir() {
  return `${tmpdir()}/_rstnote`;
}

exports.tmpdir = _tmpdir

exports.tempinit = () => {
  tmpd = _tmpdir();
  if ( dirExists(tmpd) ) {
    exec(`rm -r ${tmpd}`, (e,stdout,stderr) => {
      execSync(`mkdir ${tmpd}`);
    });
  } else {
    execSync(`mkdir ${tmpd}`);
  }
}

exports.tempclose = () => {
  execSync(`rm -r ${tmpd}`);
}
