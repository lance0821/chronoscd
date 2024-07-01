FROM alpine:3

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    openssl \
    ca-certificates \
    jq \
    gettext

# Install yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.13.4/yq_linux_arm64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install Helm
RUN HELM_LATEST_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name) && \
    curl -L https://get.helm.sh/helm-${HELM_LATEST_VERSION}-linux-arm64.tar.gz | tar -xz && \
    mv linux-arm64/helm /usr/local/bin/helm && \
    rm -rf linux-arm64

# Install Kustomize using the script
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    mv kustomize /usr/local/bin/kustomize

# Install Argo CD CLI
RUN ARGOCD_LATEST_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r .tag_name) && \
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_LATEST_VERSION}/argocd-linux-arm64 && \
    chmod +x /usr/local/bin/argocd

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

CMD ["/bin/bash"]
