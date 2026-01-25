# Step : base
FROM docker:cli

# Step : Install bash
RUN apk update && \
  apk add \
    bash

# Step : Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Step : Install CLI
ADD ./cli /usr/local/devops
RUN cat <<EOF > /bin/devops-cli
#!/bin/bash
cd /usr/local/devops
bash do.sh "\${@}"
EOF
RUN chmod +x /bin/devops-cli

## Setting container startup
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +rx /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
