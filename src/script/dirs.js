var {dirname,sep,resolve} = require('path');
var fs = require('fs')

exports.dirname = dirname;

exports.root = resolve('.').split(sep)[0] + sep;

exports.exists = function(filename, callback) {
  return fs.watchFile(filename, (current,previous) => {
     if (current.isFile()) {
        fs.unwatchFile(filename);
        return callback();
     }
  });
}
