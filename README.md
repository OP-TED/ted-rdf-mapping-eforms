# TED-RDF Mapping Suites for eForms Notices

![GitHub Tag](https://img.shields.io/github/v/tag/OP-TED/ted-rdf-mapping-eforms?include_prereleases&sort=semver)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/OP-TED/ted-rdf-mapping-eforms)
![GitHub last commit](https://img.shields.io/github/last-commit/OP-TED/ted-rdf-mapping-eforms)

![GitHub contributors](https://img.shields.io/github/contributors-anon/OP-TED/ted-rdf-mapping-eforms)
![GitHub issues](https://img.shields.io/github/issues/OP-TED/ted-rdf-mapping-eforms)
![GitHub closed issues](https://img.shields.io/github/issues-closed/OP-TED/ted-rdf-mapping-eforms)
![GitHub Repo stars](https://img.shields.io/github/stars/OP-TED/ted-rdf-mapping-eforms?style=social)
![GitHub forks](https://img.shields.io/github/forks/OP-TED/ted-rdf-mapping-eforms?style=social)
![GitHub](https://img.shields.io/github/license/OP-TED/ted-rdf-mapping-eforms)

This repository provides mappings between [eForms SDK](https://github.com/OP-TED/eForms-SDK) representation and [eProcurement Ontology](https://github.com/OP-TED/ePO) representation of [eForms Notices](https://simap.ted.europa.eu/eforms).

The artefacts provided in this repository are used by the [TED-SWS system](https://docs.ted.europa.eu/SWS/index.html). They are provided in the [mappings](./mappings) folder and are organised in packages called [Mapping Suites](https://docs.ted.europa.eu/SWS/mapping_suite/mapping-suite-structure.html).

[Project official documentation is available here.](https://docs.ted.europa.eu/rdf-mapping/index.html)

## Requirements

Users need only to install the following external software tools, libraries
and/or runtimes if developing and testing the RML mapping:

- Java 11+ (tested up to 17)
- RMLMapper-Java==v6.2.2

RMLMapper is currently tied to v6.2.2 because of an [issue with conditional
instantiation](https://github.com/RMLio/rmlmapper-java/issues/236) (currently
fixed but yet unreleased).

## RDF URI Scheme

The eForms RML mappings use the URI scheme `{ns}id_{notice-id}_{concept}_{trailer}`, where:

- `{ns}` is a base namespace, in this case `http://data.europa.eu/a4g/resource/`
- `{concept}` is either (i) an ontology fragment label or (ii) source element label, with a suffix or prefix
- `{trailer}` is either (i) an ID value (if the resource has one) or (ii) an _online_ computed, deterministic hash
- Root concepts such as `epo:Notice` end up to only the `{concept}`

Expanding on some of the components for further clarity:

- Whether a `concept` is an ontology fragment or source element label, and whether this label has a suffix (rarely) or prefix, depends on the subjective (human) evaluation of whether only having the class name is sufficient hint of what the URI represents.
- The trailer, when a hash, is computed (seeded) with the XPath named element (e.g. `cbc:ID`) or (often relative) path (e.g. `path(cbc:ID)`) of what is being mapped, and therefore lends a unique identity to the URI. This yields reproducible URIs across RML TripleMaps, in case a resource needed to be instantiated at different XPaths, for whatever purpose.
  - A Lot or any other resource with an inherent ID, would simply have its `cbc:ID` value as the trailer, for e.g. `epd:id_14549263-b47b-4e59-96a1-2d0d13e19343_Lot_LOT-0001`, which is very useful for linking purposes at orthogonal XPaths (e.g. wherever an `id-ref` is concerned, that ID could simply be used to produce a linkable URI without having to navigate XPaths).
  - Any other resource where there is no inherent ID would have a hash that is unique to the XPath it represents, e.g. an `epo:Purpose` instance, if instantiated at different XPaths for associating different attributes, would have the same URI across those instantiations, resulting in one unique instance and no duplication due to multiple mappings.
    - The `adms:Identifier`, although having an ID, may still get a hash instead of ID in its trailer, as it may not have a short ID that is sensible to use/read (however we may not have enforced this rule strongly)

Note: Wherever _URI_ is mentioned, [IRI](https://www.w3.org/2001/Talks/0912-IUC-IRI/paper.html#:~:text=In%20principle%2C%20the%20definition%20of,us%2Dascii%20characters%20in%20URIs) is meant. Also, the generation of hashes is done _online_ against a remote HTTP web API endpoint offering this function, during transformation (which can otherwise be an offline process).

## Contributing

You are more than welcome to help expand and mature this project.

When [contributing](./CONTRIBUTING.md) to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Please note that we adhere to a [Code of Conduct](./CODE_OF_CONDUCT.md), please follow it in all your interactions with the project.

## Issue labels

The issues are classified on two dimensions:

* type label
  * bug - something implemented incorrectly in a release
  * missing feature - something expected but missing from a release
  * feature request - something requested to be implemented in a future release
  * implementation question - something needs clarified, refined or decided before the implementation can continue
  * release question - something needs clarified before a release is considered accepted
* action label
  * for implementation - it can be implemented and closed, everything has been clarified
  * for closing - it can be closed but an additional confirmation is needed

## Licence

The content of this repository is licenced under [EUPL v1.2](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12) licence.
