// Shared SVG plush bunny drawings for the cover and icon.
// cute(): pink bunny with button eyes and a small stitched smile.
// wrong(): grey bunny, one ear too many, stitched-too-wide smile, torn seam with stuffing.
function bunny(opts) {
  const o = Object.assign({ body: "#ffd6e6", inner: "#ff9fc4", belly: "#fff2f7", wrong: false }, opts);
  const eye = (x) => `<ellipse cx="${x}" cy="150" rx="13" ry="15" fill="#281f37"/><circle cx="${x - 4}" cy="145" r="4" fill="#fff"/>`;
  const ears = o.wrong
    ? `<g fill="${o.body}"><ellipse cx="72" cy="45" rx="20" ry="58" transform="rotate(-14 72 45)"/><ellipse cx="128" cy="45" rx="20" ry="58" transform="rotate(14 128 45)"/><ellipse cx="100" cy="35" rx="18" ry="54"/></g>
       <g fill="${o.inner}"><ellipse cx="72" cy="48" rx="10" ry="42" transform="rotate(-14 72 48)"/><ellipse cx="128" cy="48" rx="10" ry="42" transform="rotate(14 128 48)"/><ellipse cx="100" cy="38" rx="9" ry="38"/></g>`
    : `<g fill="${o.body}"><ellipse cx="74" cy="45" rx="20" ry="58" transform="rotate(-10 74 45)"/><ellipse cx="126" cy="45" rx="20" ry="58" transform="rotate(16 126 45)"/></g>
       <g fill="${o.inner}"><ellipse cx="74" cy="48" rx="10" ry="42" transform="rotate(-10 74 48)"/><ellipse cx="126" cy="48" rx="10" ry="42" transform="rotate(16 126 48)"/></g>`;
  const mouth = o.wrong
    ? `<path d="M52 180 Q100 222 148 180" fill="none" stroke="#3a2a40" stroke-width="5" stroke-dasharray="9 5" stroke-linecap="round"/>`
    : `<path d="M88 182 Q100 194 112 182" fill="none" stroke="#7a4a66" stroke-width="5" stroke-dasharray="6 4" stroke-linecap="round"/>`;
  const tear = o.wrong
    ? `<path d="M118 112 L150 96" stroke="#5a1626" stroke-width="10" stroke-linecap="round"/>
       <g stroke="#b3203a" stroke-width="3" stroke-linecap="round"><path d="M122 104 l-4 -9"/><path d="M132 99 l-3 -9"/><path d="M142 95 l-4 -9"/><path d="M126 118 l5 8"/><path d="M137 112 l5 8"/></g>
       <circle cx="138" cy="102" r="9" fill="#fffaf2"/><circle cx="148" cy="96" r="7" fill="#fffaf2"/>
       <path d="M132 112 l0 38" stroke="#b3203a" stroke-width="3"/><circle cx="132" cy="152" r="4" fill="#b3203a"/>`
    : "";
  return `
  <svg viewBox="0 -20 200 300" xmlns="http://www.w3.org/2000/svg">
    ${ears}
    <ellipse cx="100" cy="240" rx="72" ry="62" fill="${o.body}"/>
    <ellipse cx="100" cy="246" rx="44" ry="40" fill="${o.belly}"/>
    <ellipse cx="100" cy="246" rx="44" ry="40" fill="none" stroke="${o.inner}" stroke-width="3" stroke-dasharray="7 5" opacity=".7"/>
    <ellipse cx="38" cy="232" rx="18" ry="30" fill="${o.body}" transform="rotate(25 38 232)"/>
    <ellipse cx="162" cy="232" rx="18" ry="30" fill="${o.body}" transform="rotate(-25 162 232)"/>
    <ellipse cx="100" cy="150" rx="78" ry="68" fill="${o.body}"/>
    <path d="M100 86 Q100 70 100 60" stroke="${o.inner}" stroke-width="3" stroke-dasharray="6 4" opacity=".6"/>
    ${eye(72)}${eye(128)}
    <ellipse cx="52" cy="172" rx="14" ry="8" fill="${o.inner}" opacity=".6"/>
    <ellipse cx="148" cy="172" rx="14" ry="8" fill="${o.inner}" opacity=".6"/>
    <ellipse cx="100" cy="168" rx="8" ry="6" fill="${o.inner}"/>
    ${mouth}${tear}
  </svg>`;
}
