---
name: ebs-wadl-to-client
description: "Use when: creating a new EBS REST service subclass from a WADL file; adding a new ebs_client service; analyzing an Oracle EBS WADL and XSD to generate a Python client class; implementing a new EBSBaseClient subclass in ebs_client/. Covers reading WADL/XSD, deriving endpoints, building payload envelopes, and registering the class."
argument-hint: "<service name or WADL path>"
---

# EBS WADL → ebs_client Subclass

## Overview

Analyze one or more WADL + XSD files from `MCPServers/mcp-oracle-ebs/WADL/` and
produce a new Python service class in `MCPServers/mcp-oracle-ebs/ebs_client/`.
Then register it in `__init__.py` and `client.py`.

**Never overwrite or edit existing files.**

---

## Procedure

### Step 1 — Locate WADL and XSD files

1. Find the target service directory under `MCPServers/mcp-oracle-ebs/WADL/`,
   e.g. `WADL/APINV/`, `WADL/vendor/`, `WADL/AccessControlService/`.
2. Read the `.wadl` file to identify:
   - `resources base="..."` — extract the `SERVICE_PATH` (the path segment after
     `/webservices/rest/`, e.g. `APINV/`, `vendor/`, `AuthenticationService/`).
   - Every `<resource path="...">` — the endpoint suffix used in `_get`/`_post` calls.
   - Every `<method name="...">` on each resource — HTTP verb (GET / POST / PUT /
     DELETE).
   - `<param>` elements on each method — query parameters for GET endpoints.
   - `<representation type="...">` — references XSD types for request/response.
   - `<include href="...?XSD=..."/>` in `<grammars>` — the XSD filenames to read.
3. Read each referenced XSD file to identify:
   - Input element name and fields (map to Python method parameters).
   - Output element name and significant response fields.
   - `minOccurs="0"` → `Optional[T] = None`; required fields → no default.
   - Field XSD types → Python types: `xsd:string` → `str`, `xsd:int`/`xsd:integer`
     → `int`, `xsd:decimal`/`xsd:double` → `float`, `xsd:boolean` → `bool`,
     `xsd:dateTime`/`xsd:date` → `str` (keep as string, format in docstring).

### Step 2 — Check existing services for patterns

Before writing, read the two most similar existing services:

- **PL/SQL-wrapper style** (InputParameters/OutputParameters envelope):
  See `ebs_client/vendor.py` and `ebs_client/apinv.py`.
  Payload: `{"<ENDPOINT>_Input": {"InputParameters": {<fields>}}}`

- **REST-resource style** (direct JSON body, RESTHeader required):
  See `ebs_client/access_control.py` and `ebs_client/apimpcc.py`.
  Use `self.wrap_payload_with_headers(service_type, payload)` when the XSD shows
  a `RESTHeader` complex sub-element inside the root input element.

- **GET-only / metadata style**: See `ebs_client/provider.py`.
  Pass a `params` dict; never construct a request body.

Determine which style applies based on the XSD root element structure.

### Step 3 — Identify naming conventions

| Artifact | Convention |
|---|---|
| File | `ebs_client/<service_lower>.py` (e.g. `fnd_user.py`, `apinv.py`) |
| Class | `<ServiceName>Service(EBSBaseClient)` (e.g. `ApInvService`) |
| `SERVICE_PATH` | Exact path segment from WADL base, with trailing `/` |
| Method | `async def <verb>_<resource_snake>(self, ...) -> Dict[str, Any]` |
| Endpoint arg | String matching `<resource path>` value from WADL (with trailing `/`) |

### Step 4 — Write the new service file

Structure:

```python
import logging
from typing import Any, Dict, List, Optional
from .base import EBSBaseClient

logger = logging.getLogger(__name__)


class <ServiceName>Service(EBSBaseClient):
    """Wraps the EBS <WadlName> REST endpoints.

    WADL: <service_path>
      <resource path>/    <HTTP_VERB>   — <brief description>
      ...
    """

    SERVICE_PATH = "<path_from_wadl>/"

    # -------------------------------------------------------------------------
    # <resource_path>/  —  <HTTP_VERB>
    # XSD: <XSD_filename>.xsd
    #
    # Input:  <root input element and key fields>
    # Output: <root output element and key response fields>
    # -------------------------------------------------------------------------

    async def <method_name>(
        self,
        <required_param>: <Type>,
        <optional_param>: Optional[<Type>] = None,
        ...
    ) -> Dict[str, Any]:
        """<One-sentence summary>.

        <Longer description if needed.>

        Args:
            <param>: <Description> (<XSD element name>).
            ...

        Returns:
            Raw response dict. <Describe key output fields.>

        Raises:
            httpx.HTTPStatusError: if the EBS server returns a non-2xx response.
        """
        # Build payload / params based on style (see Step 2):

        # --- PL/SQL wrapper style ---
        input_params: Dict[str, Any] = {}
        if <optional_field> is not None:
            input_params["<XSD_ELEMENT_NAME>"] = <optional_field>
        return await self._post(
            endpoint="<resource_path>/",
            service_path=<ServiceName>Service.SERVICE_PATH,
            data={"<ENDPOINT>_Input": {"InputParameters": input_params}},
        )

        # --- GET style ---
        params = {
            "filter": filter,
            "select": select,
            ...
        }
        return await self._get(
            endpoint="<resource_path>/",
            params=params,
            service_path=<ServiceName>Service.SERVICE_PATH,
        )
```

**Coding rules (must follow):**

- Import order: stdlib → `typing` → `.base` → (no third-party in service files).
- Always `logger = logging.getLogger(__name__)` — never `logging.basicConfig(...)`.
- Never build the URL manually — always call `_get`, `_post`, `_put`, or `_delete`.
- Pass `service_path=<ClassName>.SERVICE_PATH` explicitly in every helper call
  (matches the pattern used in `vendor.py` and `apinv.py`).
- Strip `None` values from params/input manually (build dict with `if x is not None`
  checks), or rely on `_merge_params` stripping them if passing full params dict.
- Preserve XSD field names exactly (UPPER_SNAKE or camelCase as in XSD).
- For complex nested records (e.g. `P_VENDOR_REC`), accept a `Dict[str, Any]` arg
  rather than flattening every sub-field.
- For list-returning endpoints (collection GET), document the response shape.
- Keep the section-comment block above each method group (resource path, HTTP verb,
  XSD filename, input/output summary).

### Step 5 — Register the new class

**`ebs_client/__init__.py`** (add import and `__all__` entry):
```python
from .<module_name> import <ServiceName>Service
# add "<ServiceName>Service" to __all__
```

**`ebs_client/client.py`** (add import and add to `EBSClient` base classes):
```python
from .<module_name> import <ServiceName>Service
# add <ServiceName>Service to the EBSClient(...) inheritance list
```

Do **not** edit either file if the service is already present.

---

## Decision Points

| Situation | Action |
|---|---|
| XSD has `RESTHeader` nested in root input element | Use `wrap_payload_with_headers(service_type, payload)` |
| XSD has `InputParameters` / `OutputParameters` wrapper | Use `{"<EP>_Input": {"InputParameters": {...}}}` envelope |
| WADL resource has only GET with query params | Build params dict, call `_get` |
| Field `minOccurs="0"` | `Optional[T] = None`, include in payload only if not None |
| Field is a complex XSD type | Accept as `Dict[str, Any]`; document key sub-fields in docstring |
| Multiple HTTP verbs on same resource | One method per verb, named `get_<resource>`, `create_<resource>`, `update_<resource>`, `delete_<resource>` |
| Pagination params (`filter`, `select`, `sort`, `offset`, `limit`) visible in WADL | Add as `Optional[str] = None` kwargs on GET methods |

---

## Quality Checklist

Before finishing, confirm:

- [ ] New `.py` file created; no existing file overwritten or edited.
- [ ] Class inherits from `EBSBaseClient` only.
- [ ] `SERVICE_PATH` matches WADL base resource path segment exactly.
- [ ] All WADL resources and HTTP verbs have corresponding async methods.
- [ ] Every method has a docstring with Args / Returns.
- [ ] XSD element names preserved verbatim in payload keys.
- [ ] `logger = logging.getLogger(__name__)` present.
- [ ] `__init__.py` and `client.py` updated (not overwritten — lines appended / inserted).
- [ ] No `logging.basicConfig(...)` calls in the new file.
- [ ] No hardcoded URLs — only `_get`/`_post`/`_put`/`_delete` helpers.

---

## References

- Base class: [`ebs_client/base.py`](../../../MCPServers/mcp-oracle-ebs/ebs_client/base.py)
- Example PL/SQL wrapper: [`ebs_client/vendor.py`](../../../MCPServers/mcp-oracle-ebs/ebs_client/vendor.py)
- Example interface table service: [`ebs_client/apinv.py`](../../../MCPServers/mcp-oracle-ebs/ebs_client/apinv.py)
- Example metadata/GET service: [`ebs_client/provider.py`](../../../MCPServers/mcp-oracle-ebs/ebs_client/provider.py)
- Example RESTHeader service: [`ebs_client/access_control.py`](../../../MCPServers/mcp-oracle-ebs/ebs_client/access_control.py)
- Client composition: [`ebs_client/client.py`](../../../MCPServers/mcp-oracle-ebs/ebs_client/client.py)
- WADL files: [`MCPServers/mcp-oracle-ebs/WADL/`](../../../MCPServers/mcp-oracle-ebs/WADL/)
