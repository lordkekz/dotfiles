{
  lib,
  kubenix,
  ...
}: {
  # in order to define options, we need to import their definitions
  imports = [kubenix.modules.k8s];
  # annotate the generated resources with a project name
  kubenix.project = "example";
  # define a target api version to validate output
  kubernetes.version = "1.30";

  kubernetes.resources = {
    deployments.kube-bootcamp.spec = {
      replicas = 100;
      selector.matchLabels.app = "kube-bootcamp";
      template = {
        metadata.labels.app = "kube-bootcamp";
        spec = {
          securityContext.fsGroup = 1000;
          containers.kube-bootcamp = {
            image = "gcr.io/google-samples/kubernetes-bootcamp:v1";
            imagePullPolicy = "IfNotPresent";
            ports = [
              {
                containerPort = 8080;
                protocol = "TCP";
              }
            ];
          };
        };
      };
    };

    services.kube-bootcamp.spec = {
      selector.app = "kube-bootcamp";
      ports = [
        {
          name = "http";
          port = 80;
          targetPort = 8080;
        }
      ];
      externalIPs = [
        "192.168.2.41"
        "192.168.2.42"
        "192.168.2.43"
      ];
      type = "NodePort";
      externalTrafficPolicy = "Cluster";
      internalTrafficPolicy = "Cluster";
    };
  };
}
