FROM --platform=linux/amd64 node:alpine
RUN mkdir -p /usr/src/calc
WORKDIR /usr/src/calc
COPY . .
RUN npm install

#~~~~~~~SNYK test~~~~~~~~~~~~
RUN apk add curl
# Declare Snyktoken as a build-arg
ARG snyk_auth_token
# Set the SNYK_TOKEN environment variable
ENV SNYK_TOKEN=${snyk_auth_token}

# download, configure and run snyk. Break build if vulns present, post results to `https://snyk.io/`
#RUN latest_version=$(curl -Is "https://github.com/snyk/cli/releases/latest" | grep "^location" | sed 's#.*tag/##g' | tr -d "\r")

#RUN snyk_cli_dl_linux="https://github.com/snyk/cli/releases/download/${latest_version}/snyk-linux"
#RUN curl -Lo /usr/local/bin/snyk $snyk_cli_dl_linux
RUN curl -Lo ./snyk "https://github.com/snyk/snyk/releases/download/v1.210.0/snyk-linux"
#RUN chmod +x /usr/local/bin/snyk
RUN chmod -R +x ./snyk
#Auth set through environment variable
# authenticate the Snyk CLI
RUN ls -l .
RUN ./snyk auth $SNYK_TOKEN
# perform a Snyk SCA scan; continue if vulnerabilities are found
#RUN /usr/local/bin/snyk test || true
RUN ./snyk test --severity-threshold=medium
RUN ./snyk monitor
# upload a snapshot of the project to Snyk for continuous monitoring
#RUN /usr/local/bin/snyk monitor

#~~~~~~~END SNYK test~~~~~~~~~~~~

EXPOSE 3000
CMD [ "node", "app.js" ]
