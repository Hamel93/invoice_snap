document.addEventListener("turbo:load", () => {
  const input = document.getElementById("chat-input");

  document.querySelectorAll(".suggestion-btn").forEach((button) => {
    button.addEventListener("click", () => {
      input.value = button.dataset.suggestion;
      input.focus();
    });
  });
});
