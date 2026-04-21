# MrGoogle

`MrGoogle` is a specialist ADK sub-agent for live Google-based web research.
It is intended for requests that need **current external information** rather than data already stored in Oracle EBS.

## What it does

- Uses the built-in `google_search` ADK tool
- Researches recent or public web information
- Cross-checks findings when possible
- Returns concise summaries with source links

## Best use cases

- Oracle or Google product release notes
- Public documentation lookups
- Current market or vendor information
- General internet research that benefits from fresh sources

## Integration

This agent is loaded by `EBS_Master` as a sub-agent and can be routed to when recency or public web context matters.
