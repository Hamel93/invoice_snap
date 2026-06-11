function scrollToBottom(container, smooth = false) {
  if (!container) return;
  container.scrollTo({
    top: container.scrollHeight,
    behavior: smooth ? "smooth" : "auto"
  });
}

function initChatAutoscroll() {
  const container = document.getElementById("messages");
  if (!container) return;

  scrollToBottom(container);

  const observer = new MutationObserver(() => scrollToBottom(container, true));
  observer.observe(container, { childList: true, subtree: true });

  const form = document.getElementById("chat-form");
  if (form) {
    form.addEventListener("submit", () => {
      requestAnimationFrame(() => scrollToBottom(container, true));
    });
  }
}

document.addEventListener("turbo:load", initChatAutoscroll);
document.addEventListener("turbo:render", initChatAutoscroll);
