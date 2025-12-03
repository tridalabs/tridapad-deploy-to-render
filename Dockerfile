FROM tridalabs/tridapad:latest

COPY --chmod=755 ./render-tridapad /usr/local/bin/render-tridapad

ENTRYPOINT ["/usr/local/bin/render-tridapad"]
