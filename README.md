# Initial-abstraction-layer-with-automated-PKCS11-signing
HSM-Abstraction-Layer

# HSM Abstraction Layer

A lightweight, modular PKCS#11 abstraction framework that separates application logic from Hardware Security Module (HSM) implementation.

The project provides a simple interface for applications to perform cryptographic signing operations without requiring any knowledge of the underlying HSM vendor, key storage location, or authentication mechanism.

Rather than embedding PKCS#11 logic into every application, the abstraction layer resolves the appropriate project, logical key, credentials and provider before securely performing the signing operation.

---

# Why this project exists

Many organisations use Hardware Security Modules to protect cryptographic keys, however applications often become tightly coupled to a specific HSM vendor or PKCS#11 implementation.

This project was created to solve that problem.

Applications should only know **what** they want to sign.

The abstraction layer decides **how** the signing is performed.

This approach allows organisations to migrate between HSM vendors, rotate keys, or modify authentication methods without changing application code.

---

# Design Principles

The project has been designed around a number of core engineering principles.

## Separation of Responsibilities

Every component has a single responsibility.

| Component | Responsibility |
|-----------|----------------|
| Application | Requests a signing operation |
| abstraction_Layer.sh | Resolves project configuration |
| Project.json | Maps projects to logical keys |
| SignWork.sh | Performs the signing operation |
| keys.json | Maps logical keys to HSM objects |
| HSM-Credential.conf | Stores authentication credentials |
| PKCS#11 | Interfaces with the HSM |

---

## Hardware Independence

Applications never communicate directly with the HSM.

Changing from SoftHSM to Thales Luna (or another PKCS#11 compliant HSM) should require only configuration changes rather than application changes.

---

## Configuration over Code

Business logic should not be hardcoded.

Projects, logical keys, providers and credentials are resolved from configuration files rather than embedded in scripts.

This makes the framework easier to maintain, audit and extend.

---

## Principle of Least Knowledge

Applications should never need to know:

- PKCS#11 module locations
- Token labels
- Key labels
- PINs
- HSM vendor implementation

They simply request:

```

projectA
document.pdf

```

The abstraction layer resolves everything else.

---

## Separation of Secrets

Authentication credentials are deliberately separated from key configuration.

This allows credentials to be replaced by:

- Environment Variables
- HashiCorp Vault
- CyberArk
- AWS Secrets Manager
- Azure Key Vault

without modifying the signing engine.

---

## Vendor Agnostic Design

The framework has been designed around the PKCS#11 standard.

Current testing:

- SoftHSM2

Planned support:

- Thales Luna
- Entrust nShield
- AWS CloudHSM
- Future PKCS#11 providers

---

# Current Architecture

```
                Application
                     │
                     ▼
         abstraction_Layer.sh
                     │
                     ▼
              Project.json
                     │
                     ▼
              Logical Key
                     │
                     ▼
              SignWork.sh
                     │
                     ▼
                keys.json
                     │
                     ▼
        HSM-Credential.conf
                     │
                     ▼
                 PKCS#11
                     │
                     ▼
           Hardware Security Module
```

---

# Current Features

✔ Project abstraction

✔ Logical key abstraction

✔ JSON configuration

✔ Automatic HSM authentication

✔ PKCS#11 signing

✔ RSA signing support

✔ Modular architecture

✔ Vendor independent design

---

# Roadmap

## Phase 1

- [x] Project abstraction
- [x] Logical key mapping
- [x] Automatic HSM login
- [x] PKCS#11 signing

## Phase 2

- [ ] Signature verification
- [ ] Certificate management
- [ ] Audit logging
- [ ] Improved error handling

## Phase 3

- [ ] REST API
- [ ] HashiCorp Vault integration
- [ ] Cloud HSM support
- [ ] FIPS support

## Phase 4

- [ ] Post-Quantum Cryptography
- [ ] ML-DSA support
- [ ] ML-KEM integration
- [ ] Hybrid signing

---

# Requirements

Oracle Enterprise Linux

OpenSSL

pkcs11-tool

jq

SoftHSM2 or compatible PKCS#11 provider

---

# Example

```
./abstraction_Layer.sh projectA document.pdf
```

Output

```
signed-document.pdf
signed-document.pdf.sig
```

---

# Project Status

This project is currently under active development.

The current focus is on building a clean, extensible abstraction layer for PKCS#11 compliant Hardware Security Modules.

Future work will focus on improving portability, automation, cloud integration and support for emerging cryptographic standards, including Post-Quantum Cryptography.

---

# Contributing

Contributions, ideas and constructive feedback are welcome.

Please open an Issue before submitting significant architectural changes so they can be discussed.

---

# Licence

This project is released under the MIT License.

See the LICENSE file for details.


