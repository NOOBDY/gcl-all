const vscode = acquireVsCodeApi();

/**
 * @type {EventListener}
 */
function handleReduce(event) {
  event.stopPropagation();

  const el = event.target;

  const redex = el.dataset.redex;
  const po = el.closest(".gcl-expr").dataset.po;

  vscode.postMessage({
    redex,
    po,
  });
}

const redexes = document.querySelectorAll(".gcl-redex");

for (const redex of redexes) {
  redex.addEventListener("click", handleReduce);
}
