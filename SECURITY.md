# Security Policy

Factor House develops real-time data management tools including Kpow for Apache Kafka, Flex for Apache Flink, and the Factor Platform. We are committed to protecting our users' data and systems through responsible security practices. This policy provides a framework for security researchers and customers to report potential vulnerabilities in Factor House products and infrastructure.

## Reporting a Vulnerability

Factor House encourages security researchers, customers, and the broader public to report any potential security vulnerabilities in a responsible manner. All vulnerability reports should be directed to our dedicated security email address: security@factorhouse.io

We encourage detailed, human-verified reports with clear reproduction steps. Automated scanner outputs without specific context cannot be processed.

- Contact information: Your name, organisation, and preferred communication method
- Type of issue: Clearly identify the vulnerability category (e.g., XSS, SQL Injection, RCE, authentication bypass)
- Product and version/URL: Specify the exact Factor House product (Kpow, Flex, or Factor Platform) and precise version or affected URL
- Potential impact: Describe what data could be accessed, modified, or destroyed, and what services could be disrupted
- Step-by-step reproduction instructions: Provide clear, detailed instructions to reliably reproduce the issue

For security researchers, it would also be great if you could please include:

- Proof-of-concept (PoC): Include relevant code, scripts, screenshots, or videos demonstrating the vulnerability
- PGP encryption (Optional): For sensitive information, encrypt your submission using our PGP key (available upon request)

### Scope

#### In-Scope Systems
- Kpow for Apache Kafka: Web UI, API, Docker images, infrastructure
- Flex for Apache Flink: Web UI, API, enterprise features, infrastructure
- Factor Platform: Unified platform, Web UI, OpenAPI 3.1 REST API
- Public-facing applications: Factor House-owned web applications, APIs, services
- Official Docker repositories: Container images on Docker Hub

#### Out-of-Scope
- Third-party services not directly controlled by Factor House
- Customer environments and deployments

### Safe Harbor Protections
For good-faith security research conducted under this policy, Factor House provides:

- Legal Protection: Research considered authorized under applicable laws including Australian Cybercrime Act 2001 and international equivalents
- DMCA exemption: Circumvention necessary for legitimate security research
- Terms waiver: Limited waiver of conflicting Terms & Conditions
- Good faith recognition: Research considered lawful and helpful
- Researchers must comply with all applicable laws. Contact security@factorhouse.io with legal questions before proceeding.

### Response Process
1. Acknowledgment: Receipt confirmed within 2-3 business days
2. Investigation: Internal reproduction, impact assessment, engineering collaboration
3. Updates: Regular status communication throughout process
4. Remediation: Prioritized fixes based on severity and impact
5. Resolution: Notification when vulnerability is resolved and deployed
6. Recognition: Optional public recognition with researcher permission
   
> Note: Factor House does not currently operate a monetary bug bounty program.

### Disclosure Policy
We operate coordinated disclosure aligned with our SOC2 compliance:

- Researchers must provide reasonable notice before public disclosure
- Allow sufficient time for investigation, remediation, and deployment
- Reports containing customer data are not eligible for public disclosure
- Disclosure requests considered only after complete remediation via security@factorhouse.io

## Contact
Email: security@factorhouse.io

Factor House reserves the right to update this policy. Check this page for the latest version.
