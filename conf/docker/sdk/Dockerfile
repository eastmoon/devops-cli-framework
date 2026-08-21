# Step : base
FROM docker:cli

# Step : Install bash
RUN apk update && \
  apk add \
    bash

# Step : Install CLI
ADD ./cli /usr/local/devops
ADD ./devops-cli /bin/devops-cli
RUN chmod +x /bin/devops-cli

## Setting container startup
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +rx /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
