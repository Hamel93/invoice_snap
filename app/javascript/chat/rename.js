document.addEventListener("turbo:load", () => {
  const toggle = document.getElementById("rename-toggle");
  const form = document.getElementById("rename-form");

  if (!toggle || !form) return;

  toggle.addEventListener("click", () => {
    form.style.display =
      form.style.display === "none" ? "block" : "none";
  });
});
