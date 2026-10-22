(function () {
  var started = false;
  function boot() {
    if (started) return;
    if (document.documentElement.getAttribute("data-style") !== "neutral") return;
    started = true;

  var dialog = document.getElementById("search-dialog");
  var trigger = document.querySelector("[data-search-open]");
  var input = document.getElementById("search-input");
  var results = document.getElementById("search-results");
  var kbd = document.querySelector(".search-kbd");
  var themeButton = document.querySelector("[data-theme-toggle]");

  if (kbd) {
    var mac = /Mac|iPhone|iPad/.test(navigator.userAgent);
    kbd.textContent = mac ? "⌘K" : "Ctrl K";
  }

  function activeTheme() {
    var theme = document.documentElement.getAttribute("data-theme");
    if (theme !== "light" && theme !== "dark") {
      theme = matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }
    return theme;
  }

  function applyChrome() {
    var theme = activeTheme();
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.content = theme === "dark" ? "#09090b" : "#ffffff";
    if (themeButton) {
      var dark = theme === "dark";
      themeButton.setAttribute("aria-pressed", dark ? "true" : "false");
      themeButton.setAttribute("aria-label", dark ? "Switch to light theme" : "Switch to dark theme");
    }
  }

  applyChrome();

  if (themeButton) {
    themeButton.addEventListener("click", function () {
      var next = activeTheme() === "dark" ? "light" : "dark";
      document.documentElement.setAttribute("data-theme", next);
      localStorage.setItem("theme", next);
      applyChrome();
      if (window.renderMermaid) window.renderMermaid();
    });
  }

  matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function () {
    if (document.documentElement.hasAttribute("data-theme")) return;
    applyChrome();
    if (window.renderMermaid) window.renderMermaid();
  });

  var tocQuery = matchMedia("(min-width: 960px)");
  document.querySelectorAll(".toc details").forEach(function (details) {
    var summary = details.querySelector("summary");
    function syncToc() {
      if (!tocQuery.matches) {
        if (summary) summary.removeAttribute("tabindex");
        return;
      }
      details.open = true;
      if (summary) summary.tabIndex = -1;
    }
    details.addEventListener("toggle", function () {
      if (tocQuery.matches && !details.open) details.open = true;
    });
    tocQuery.addEventListener("change", syncToc);
    syncToc();
  });

  if (!dialog || !trigger || !input || !results) return;

  var items = null;
  var pending = null;
  var active = 0;
  var lastFocus = null;

  function open() {
    lastFocus = document.activeElement;
    if (!dialog.open) dialog.showModal();
    trigger.setAttribute("aria-expanded", "true");
    input.value = "";
    active = 0;
    input.focus();
    ensureIndex().then(render).catch(showError);
  }

  function close() {
    if (dialog.open) dialog.close();
  }

  dialog.addEventListener("close", function () {
    trigger.setAttribute("aria-expanded", "false");
    if (lastFocus && lastFocus.focus) lastFocus.focus();
  });

  trigger.addEventListener("click", open);

  document.addEventListener("keydown", function (event) {
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      if (dialog.open) close();
      else open();
    }
  });

  dialog.addEventListener("click", function (event) {
    var rect = dialog.getBoundingClientRect();
    var inside = event.clientX >= rect.left && event.clientX <= rect.right && event.clientY >= rect.top && event.clientY <= rect.bottom;
    if (!inside) close();
  });

  input.addEventListener("input", function () {
    active = 0;
    render();
  });

  input.addEventListener("keydown", function (event) {
    var options = results.querySelectorAll("[role='option']");
    if (!options.length) return;
    if (event.key === "ArrowDown") {
      event.preventDefault();
      active = Math.min(active + 1, options.length - 1);
      paint(options);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      active = Math.max(active - 1, 0);
      paint(options);
    } else if (event.key === "Enter") {
      var chosen = options[active] && options[active].querySelector("a");
      if (chosen) {
        event.preventDefault();
        window.location.href = chosen.href;
      }
    }
  });

  function paint(options) {
    for (var i = 0; i < options.length; i++) {
      var on = i === active;
      options[i].setAttribute("aria-selected", on ? "true" : "false");
      if (on) options[i].id = "search-active";
      else options[i].removeAttribute("id");
    }
    var current = options[active];
    if (!current) {
      input.removeAttribute("aria-activedescendant");
      return;
    }
    input.setAttribute("aria-activedescendant", current.id);
    current.scrollIntoView({ block: "nearest" });
  }

  function showError() {
    pending = null;
    items = null;
    results.replaceChildren();
    var li = document.createElement("li");
    li.className = "search-empty";
    li.textContent = "Search is unavailable";
    results.appendChild(li);
  }

  function ensureIndex() {
    if (items) return Promise.resolve(items);
    if (pending) return pending;
    pending = fetch(dialog.dataset.index, { headers: { accept: "application/json" } })
      .then(function (response) {
        if (!response.ok) throw new Error("search index " + response.status);
        return response.json();
      })
      .then(function (data) {
        items = data;
        return items;
      });
    return pending;
  }

  function matches(item, query) {
    if (!query) return true;
    var hay = [item.title, item.summary, item.section].concat(item.tags).join(" ").toLowerCase();
    return hay.indexOf(query) !== -1;
  }

  function render() {
    if (!items) return;
    var query = input.value.trim().toLowerCase();
    var found = [];
    for (var i = 0; i < items.length && found.length < 8; i++) {
      if (matches(items[i], query)) found.push(items[i]);
    }
    results.replaceChildren();
    if (!found.length) {
      var empty = document.createElement("li");
      empty.className = "search-empty";
      empty.textContent = "No matching posts";
      results.appendChild(empty);
      input.removeAttribute("aria-activedescendant");
      return;
    }
    for (var j = 0; j < found.length; j++) {
      var item = found[j];
      var li = document.createElement("li");
      li.setAttribute("role", "option");
      var link = document.createElement("a");
      link.href = item.url;
      var title = document.createElement("span");
      title.className = "search-title";
      title.textContent = item.title;
      var meta = document.createElement("span");
      meta.className = "search-meta";
      meta.textContent = [item.date, item.section].filter(Boolean).join(" · ");
      link.append(title, meta);
      li.appendChild(link);
      results.appendChild(li);
    }
    paint(results.querySelectorAll("[role='option']"));
  }

  }
  document.documentElement.addEventListener("blog-style", boot);
  boot();
})();
