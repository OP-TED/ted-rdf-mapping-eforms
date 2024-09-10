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

This project is under development. The current scope of this project includes the mapping of:
- all **Competition Notices (CNs)**, including **eForms subtypes 10-24** according to **eForms SDK versions 1.3 to 1.10**
- **Contract Award Notices (CANs)** of **eForms subtype 29** according to **eForms SDK versions 1.3 to 1.1**0, **_excluding_** the information **encoded in privacy fields** (represented by BT IDs `BT-195`, `BT-196`, `BT-197` and `BT-198`), and those that are **masked by such privacy fields**

The official documentation of this project [is available here](http://docs.ted.europa.eu/ted-rdf-mapping-eforms/index.html) and will be integrated into the [TED Semantic Web Service Project Documentation](https://docs.ted.europa.eu/SWS/index.html).

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

## RML Files Organization

The structure of the RML files (we call them _modules_ because they are modular
files with RML rules that work together when combined) is based on the
primary/root class of a set of mapping rules, which are part of one or more
_Mapping Groups_ (MGs) that share such a root class (the final segment of an MG
name). An MG represents a logical grouping of related instances/resources (like
a `foaf:Person` with all of its properties _and_ relationships together with
the instances of those relationships), in the form:

```
MG-{EndingClass}-{IntermediatePropertyAndClassPath}-{RootClass}
```

The class and property names in this case are separated by hyphens and do not
include prefixes. For example, to represent that a Company has a Location which
in turn has an Address:

```
MG-Address-hasAddress-Location-hasLocation-Company
```

In a technical mapping, the node will also be represented:

```
tedm:MG-Address-hasAddress-Location-hasLocation_ND-Company
```

This is because information for the same RDF resource can be in different
locations in the source XML.

## Known Issues

- `owl:sameAs` used to get through to the Organization of a TouchPoint for an
  `epo:AgentInRole`'s "contact point in role" due to technical difficulty
  <https://github.com/OP-TED/ted-rdf-mapping-eforms/issues/30>

- `Expected epo:hasTimePeriod --> [1..*] at-voc:timeperiod , but found 0 instances` predicate is an alternative and should not be mandatory

- `model declares a xsd:dateTime` data type misalignment between eForms and ePO <https://github.com/OP-TED/ted-rdf-mapping-eforms/issues/8>

- `epo:Tender epo:isSubjectToGrouping epo:LotGroup` will _not_ have `epo:isSubmittedForLot epo:Lot` at the same time <https://github.com/OP-TED/ePO/issues/683>

- External resources such as a referenced notices will raise violations if tested standalone (as they will only contain information in the current notice's scope)

- `cpov:ContactPoint adms:identifier / skos:notation ?value` ePO 4.0.0 does not foresee an Identifier for ContactPoint (OPT-201-Organization-TouchPoint)

- all `epo-not:CompetitionNotice` and associations of it will not exist for `epo:ResultNotice`

- all alternative values will not exist for all notices (e.g.  `used` vs. `n-used`)

- `epo hasAwardDecisionDate` data type misalignment between eForms and ePO <https://github.com/OP-TED/ted-rdf-mapping-eforms/issues/8>

- `epo hasOJSIssueNumber` data type misalignment between eForms and ePO

- `Expected epo:hasAwardCriteriaStatedInProcurementDocuments` <https://github.com/OP-TED/ePO/issues/679>

- `Expected epo:isSubjectToProcedureSpecificTerm --> [1..*] epo:ProcedureSpecificTerm , but found 0 instances` No Procedure defined in a ResultNotice (it is defined fully in another notice)

- `Expected epo:hasOfficialLanguage --> [1..*] at-voc:language , but found 0 instances` Subtypes of Document do not necessarily have languages in the data

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
