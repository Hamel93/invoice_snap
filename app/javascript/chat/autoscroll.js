document.addEventListener("turbo:load", () => {
  const messages = document.querySelectorAll(".message-target");

  if (messages.length > 0) {
    const lastMessage = messages[messages.length - 1];

    lastMessage.scrollIntoView({
      behavior: "smooth",
      block: "start"
    });
  }
});
