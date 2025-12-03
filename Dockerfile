FROM tridalabs/tridapad:latest

COPY ./render-tridapad /bin/render-tridapad
RUN chmod +x /bin/render-tridapad

ENTRYPOINT ["/bin/render-tridapad"]
