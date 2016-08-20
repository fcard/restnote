var {getPort}                             = require('portfinder');
var {jupyterProc, restviewProc, waitPort} = require('../procs.js');
var {dirname, root, exists}               = require('../dirs.js');
var {tmpdir}                              = require('../temp.js');
var {writeFile, readFile}                 = require('fs');
var EventEmmiter                          = require('events');

function waitcall(t,callback) {
  return () => setTimeout(callback, t);
}

class JupyterNotebook extends EventEmmiter {
  constructor(editorFrame, previewFrame, loadfunc) {
    super();
    getPort((e,port) => {
      this.portURL = `http://localhost:${port}`;
      this.process = jupyterProc('notebook', {no_browser:true, notebook_dir:root, port:port, y:true, config:'config.py'})
      this.element = editorFrame;
      this.jupyter = null;
      this.prevElement = previewFrame;
      this.prevProcess = null;
      this.prevChanged = false;
      this.setLoading  = loadfunc;
    });
  }

  save(temp) {
    if (!temp) this.jupyter.notebook.save_checkpoint();
    writeFile(this.getFilepath(temp), JSON.stringify(this.jupyter.notebook.toJSON()));
  }

  unsavedChanges() {
    return this.jupyter.notebook.dirty;
  }

  lastModified() {
    return this.jupyter.notebook.last_modified;
  }

  getFilepath(temp=false) {
    var dir = root + dirname(this.jupyter.notebook.notebook_path);
    return dir + "/" + this.getFilename(temp);
  }

  getFilename(temp) {
    var file = this.jupyter.notebook.notebook_name;
    return temp? file.replace(".ipynb", ".~ipynb") : file;
  }

  preview() {
    if (this.jupyter == null) {
      this.prevElement.setAttribute('src', '');
      this.setLoading(true);
      this.once('open', this.preview);
    } else if (this.prevProcess && this.prevChanged) {
      this.prevElement.setAttribute('src', '');
      this.prevProcess.once('exit', waitcall(1000, ()=>{this.prevProcess=null; this.preview()}));
      this.prevProcess.kill('SIGTERM');
    } else if (!this.prevProcess) {
      this.setLoading(true);
      this.prevChanged = false;
      getPort((e,port) => {
        var file = this.compile(true);
        var url = `http://localhost:${port}`;
        exists(file, ()=>{
          this.prevProcess = restviewProc(this.compile(true), port);
          waitPort(port, ()=>{
            this.prevElement.setAttribute('src', url);
            this.prevElement.addEventListener('load', ()=>this.setLoading(false));
          });
        });
      });
    }
  }

  compile(temp=false) {
    if (this.jupyter != null) {
      if (!this.unsavedChanges() || temp ||
          confirm("You have to save your changes to continue.")) {
        this.save(temp);
        var input_dir  = dirname(this.getFilepath(false));
        var output_dir = temp ? tmpdir() + "/" : input_dir;
        this.compile_process = jupyterProc('nbconvert', {to:'rst', args:[this.getFilepath(temp)], output_dir:output_dir, template:`better_rst.tpl`});
        return output_dir + this.getFilename().replace(".ipynb", ".rst");
      }
    }
    return '';
  }

  kill() {
    this.close();
    this.process.kill('SIGTERM');
    if (this.prevProcess) {
      this.prevProcess.kill('SIGTERM');
    }
  }

  open(filepath) {
    var notebook = this;
    this.element.setAttribute("src", `${this.portURL}/tree/${filepath}`);
    this.element.addEventListener('load', function handler() {
      notebook.jupyter = notebook.element.contentWindow.Jupyter;
      notebook.element.removeEventListener('load', handler);
      notebook.element.contentWindow.document.addEventListener('load', () => {
        alert("pitagoras");
        notebook.jupyter.notebook.set_autosave_interval(0);
      });
      notebook.emit('open')
    });
    this.prevChanged = true;
  }

  close() {
    this.element.setAttribute("src", "");
    this.jupyter = null;
  }
}

exports.JupyterNotebook = JupyterNotebook;
