<!-- An example from the book (ch07:132-152), not output of this repo. The Researcher writes this file as research/DONE.md when it finishes. -->

# Research Complete

## Files Produced
- research/osv-api.md: Full API documentation, auth requirements, rate limits
- research/libraries.md: Library recommendations with rationale

## Key Findings
- OSV API requires POST, not GET (unusual for a query endpoint)
- No authentication needed
- Rate limit: 100 requests/minute (generous for our use case)
- Response format nests vulnerability data 2 levels deep: response.vulns[].affected[]

## Recommendations for Builder
- Use node-fetch over axios (lighter, no config needed for this use case)
- Parse severity from CVSS scores in vulns[].severity[] array
- Handle the case where a package has zero vulns (API returns empty array, not 404)

## Open Questions
- Should we cache results locally? API is fast but 100/min limit matters for batch use.
