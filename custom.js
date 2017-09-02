// https://stackoverflow.com/questions/19669786/check-if-element-is-visible-in-dom#answer-21696585
function assertDisplayed(id) {
  try {
    var style = window.getComputedStyle(document.getElementById(id));
    return (style.display !== "none")
  }
  catch (err) {
    return err.toString()
  }
}

function getInputValue(id) {
  try {
    var val = document.querySelector("#" + CSS.escape(id) + " input").value;
    return val ? val: false
  }
  catch (err) {
    return err.toString()
  }
}


var errorCatcher =[];

/*
window.addEventListener("error", function (msg, url, lineNo, columnNo, error) {
try {
errorCatcher.push(msg);
}
catch(err) {
errorCatcher.push(err.message);
}
});
 */

try {
  window.alert = function (message) {
    errorCatcher.push(message);
  };
}
catch (err) {
  errorCatcher.push(err.message);
}
