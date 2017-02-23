FROM golang:1.7.5

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        rsync \
        python3 \
    && rm -rf /var/lib/apt/lists/*

RUN go get -u k8s.io/test-infra/kubetest

ENV KUBECTL_VERSION v1.5.3
ADD https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl /usr/bin/kubectl
RUN chmod +x /usr/bin/kubectl

COPY kubernetes /go/src/k8s.io/kubernetes

WORKDIR /go/src/k8s.io/kubernetes

# minimal needed for tests
RUN make ginkgo
RUN make WHAT='test/e2e/e2e.test'

ENV KUBECTL_PATH /usr/bin/kubectl
ENV KUBERNETES_PROVIDER skeleton
ENV KUBERNETES_CONFORMANCE_TEST Y
ENV KUBECONFIG /kubeconfig

# KUBERNETES_CONFORMANCE_TEST=Y \
#   KUBERNETES_PROVIDER=skeleton \
#   KUBECTL_PATH=$(which kubectl) \
  # KUBECONFIG=$(pwd)/config
  # kubetest -test -check_version_skew=false -v \
  # --test_args="--ginkgo.focus=\[Conformance\]"
