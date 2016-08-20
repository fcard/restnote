window.onload = function(){
  var nwWindow = require('nw.gui').Window.get();
  var {JupyterNotebook}    = require('./script/jupyter/jupyter.js');
  var {root}               = require('./script/dirs.js');
  var {tempinit,tempclose} = require('./script/temp.js');

  function fixScrollbar() {
    window.resizeBy(1,1);
    window.resizeBy(-1,-1);
  }

  tempinit();

  var notebookContent = document.querySelector("#notebook-content");

  function setViewtypeEditor() {
    notebookContent.setAttribute("type", "editor");
  }
  function setViewtypePreviewer() {
    notebookContent.setAttribute("type", "previewer");
  }
  function setViewtypeNone() {
    notebookContent.setAttribute("type", "none");
  }

  function getViewtype() {
    return notebookContent.getAttribute("type");
  }

  function setLoading(val) {
    notebookContent.setAttribute('loading', val);
  }


  var editNotebookButton = document.querySelector("#edit-notebook-button");
  var prevNotebookButton = document.querySelector("#prev-notebook-button");
  var compNotebookButton = document.querySelector("#comp-notebook-button");
  var fileNotebookSelect = document.querySelector("#file-notebook-select");
  var prevNotebookScreen = document.querySelector("#prev-notebook-screen");
  var editNotebookScreen = document.querySelector("#edit-notebook-screen");
  var activeNotebookTab  = null

  var notebook = new JupyterNotebook(editNotebookScreen, prevNotebookScreen, setLoading);
  var bodystyle;
  for (var rule of document.styleSheets[0].cssRules) {
    if (rule.selectorText == "body") {
      bodystyle = rule.style;
    }
  }

  var lastModified;

  function setupNotebook() {
    var filepath = fileNotebookSelect.files[0].path.replace(root, '', 1);
    lastModified = null;
    notebook.prevChanged = true;
    notebook.open(filepath);
    notebook.once('open', () => {
      if (!activeNotebookTab) {
        activeNotebookTab = editNotebookButton;
      }
      activeNotebookTab.click();
    });
  }

  editNotebookButton.addEventListener('click', function(){
    setViewtypeEditor();
    activeNotebookTab = editNotebookButton;
  });

  prevNotebookButton.addEventListener('click', function(){
    if (notebook.jupyter) {
      if (lastModified && lastModified < notebook.lastModified()) {
        notebook.prevChanged = true;
      }
      lastModified = notebook.lastModified();
    }
    setViewtypePreviewer();
    notebook.preview();
    fixScrollbar();
    activeNotebookTab = prevNotebookButton;
  });

  compNotebookButton.addEventListener('click', function(){
    var output = notebook.compile(false);
    notebook.compile_process.on('exit', (code)=> {
      if (code == 0) {
        alert("Compilation sucessful! Saved to file:\n"+output)
      } else {
        alert("A problem ocurred during compilation.");
      }
    });
  });

  fileNotebookSelect.addEventListener('change', function(){
    setupNotebook();
  });

  function reloadPreview(e) {
    if (getViewtype() == 'previewer' &&
         e.key == 'r' && !e.metaKey  &&
        !e.ctrlKey    && !e.shiftKey) {
      notebook.prevChanged = true;
      notebook.preview();
    }
  }

  window.addEventListener('keydown', reloadPreview);
  prevNotebookScreen.addEventListener('load', () => {
    prevNotebookScreen.contentWindow.document.addEventListener('keydown', reloadPreview);
  });

  nwWindow.on('close', function(){
    notebook.kill();
    tempclose();
    this.close(true);
  });

  nwWindow.on('resize', function(){
    var [w,h] = [nwWindow.width, nwWindow.height];
    bodystyle.width  = `calc(${w}px - 40px)`;
    bodystyle.height = `calc(${h}px - 76px)`;
  });

  window.notebook = notebook;
}
