// SSR Worker — reads JSON from stdin, renders components, writes HTML to stdout
import { renderToString } from "react-dom/server";
import { createElement } from "react";

const components = {};

// Dynamic component loader
async function loadComponent(name) {
  if (!components[name]) {
    components[name] = (await import(`./components/${name}.jsx`)).default;
  }
  return components[name];
}

// Read stdin line by line
const decoder = new TextDecoder();
for await (const chunk of Bun.stdin.stream()) {
  const lines = decoder.decode(chunk).split("\n").filter(Boolean);
  for (const line of lines) {
    try {
      const { component, props } = JSON.parse(line);
      const Component = await loadComponent(component);
      const html = renderToString(createElement(Component, props));
      process.stdout.write(html + "\n---END---\n");
    } catch (err) {
      process.stdout.write(`<div>SSR Error: ${err.message}</div>\n---END---\n`);
    }
  }
}
