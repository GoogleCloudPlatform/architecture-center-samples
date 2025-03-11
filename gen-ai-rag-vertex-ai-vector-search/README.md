# Infrastructure for a RAG-capable generative AI application using Vertex AI and Vector Search

This sample implements the [Infrastructure for a RAG-capable generative AI
application using Vertex AI and Vector
Search](https://cloud.google.com/architecture/gen-ai-rag-vertex-ai-vector-search)
reference architecture from the [Cloud Architecture
Center](https://cloud.google.com/architecture/).

To try this sample:

  1. [Enable the required APIs](https://console.cloud.google.com/flows/enableapi?apiid=run.googleapis.com,pubsub.googleapis.com,aiplatform.googleapis.com,iam.googleapis.com,storage.googleapis.com,cloudfunctions.googleapis.com,eventarc.googleapis.com,cloudbuild.googleapis.com).
  1. Follow the [setup instructions](/README.md#setup) to deploy the sample.

This will deploy the supporting infrastructure for the pattern.

If you want to install a functional example application, follow the
instructions in the [RAG Architectures - App Source
Code](https://github.com/GoogleCloudPlatform/devrel-demos/tree/main/ai-ml/rag-architectures).

> [!NOTE]
> The App Source Code was produced for a Google Cloud Next demo and is unmaintained.

We suggest deploying the terraform in this folder, then manually updating the deployment as described in the [sample application README](https://github.com/GoogleCloudPlatform/devrel-demos/tree/main/ai-ml/rag-architectures#steps) (i.e. building the container images and editing the deployed service in the Google Cloud console to use the new container image, add environment variables, etc).

## Comments within sample

This sample uses the following comment scheme:

`###`
: Major functional sections, mapping to the [architecture
diagram](https://cloud.google.com/architecture/gen-ai-rag-vertex-ai-vector-search#architecture).

`Edit Me:`
: Places to make changes to adapt the sample Terraform to customize the deployment.

`Design Considerations:`
: configurations mapping to recommendations in the [design
considerations](https://cloud.google.com/architecture/gen-ai-rag-vertex-ai-vector-search#design_considerations).

`Note:`
: Changes or modifications that should be considered when adjusting the sample
to deploy in production.
