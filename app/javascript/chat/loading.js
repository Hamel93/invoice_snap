document.addEventListener("turbo:load", () => {
  const form = document.getElementById("chat-form");
  const button = document.getElementById("send-button");

  if (!form || !button) return;

  form.addEventListener("submit", () => {
    button.disabled = true;
    button.innerHTML = "🤖 Invoice AI is thinking...";
  });
});
