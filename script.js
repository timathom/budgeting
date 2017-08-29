// https://stackoverflow.com/questions/19669786/check-if-element-is-visible-in-dom#answer-21696585
function assertDisplayed(control) {
  var style = window.getComputedStyle(control);
  return (style.display !== "none")
}
