FROM tridalabs/tridapad:2.8.3

COPY --chmod=755 ./render-tridapad /usr/local/bin/render-tridapad

ENTRYPOINT ["/usr/local/bin/render-tridapad"]
