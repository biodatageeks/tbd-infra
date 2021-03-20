from diagrams import Cluster, Diagram, Edge
from diagrams.gcp.compute import GKE
from diagrams.gcp.storage import GCS
from diagrams.k8s.compute import Pod
from diagrams.k8s.others import CRD
from diagrams.onprem.analytics import Spark
from diagrams.onprem.monitoring import Grafana, Prometheus

with Diagram(show=False, outformat="png",
             filename="diagrams/tbd",
             direction="LR",
             node_attr ={"fontsize": "14"},
             edge_attr ={"labelfontsize": "14"}):
    storage = GCS("Google Cloud Storage")
    with Cluster("Kubernetes cluster"):
        with Cluster("Monitoring") as monitoring:
            metrics = Prometheus("Prometheus")
            metrics_push = Prometheus("Prometheus Gateway")
            metrics_push << Edge(label="pull metrics") << metrics
            service_monitor = CRD("ServiceMonitor")
            service_monitor << Edge(label="watch") << metrics
            metrics << Edge(label="query metrics") << Grafana("Grafana")
        with Cluster("Apache Spark application") as spark:
            Spark()
            driver = Pod("driver")
            driver << service_monitor
            exec_1 = Pod("executor 1")
            exec_2 = Pod("executor 2")
            exec_3 = Pod("executor 3")
            driver << exec_1
            driver << exec_2
            driver << exec_3
            driver >> Edge(label="push metrics") >> metrics_push
            driver << Edge(label="pull metrics") << metrics
            exec_1 >> Edge(label="read/write") >> storage
            exec_2 >> Edge(label="read/write") >> storage
            exec_3 >> Edge(label="read/write") >> storage
        operator = Pod("Spark Operator")
        crd = CRD("SparkApplication")
        crd << Edge(label="watch") << operator >> Edge(label="create") >> driver


