# Infrastructure for a RAG-capable generative AI application using Vertex AI and Vector Search

This sample implements the [Infrastructure for a RAG-capable generative AI
application using Vertex AI and Vector
Search](https://cloud.google.com/architecture/gen-ai-rag-vertex-ai-vector-search)
reference architecture from the [Cloud Architecture
Center](https://cloud.google.com/architecture/).

To try this sample:

  1. [Enable the required APIs](https://console.cloud.google.com/flows/enableapi?apiid=run.googleapis.com,pubsub.googleapis.com,aiplatform.googleapis.com,iam.googleapis.com,storage.googleapis.com,cloudfunctions.googleapis.com,eventarc.googleapis.com,cloudbuild.googleapis.com).
  1. Follow the [setup instructions](/README.md#setup) to deploy the sample.

This will deploy the base architecture, but the applications will not be functional.

As an example application, follow the instructions in the [RAG Architectures - App Source Code](https://github.com/GoogleCloudPlatform/devrel-demos/tree/main/ai-ml/rag-architectures).

> [!NOTE]
> The App Source Code was produced for a Google Cloud Next demo and is unmaintained.
> We suggest manually changing the deployed infrastructure to try this example application.


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
