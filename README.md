# TED-RDF Mapping Suites for eForms Notices

![GitHub Tag](https://img.shields.io/github/v/tag/OP-TED/ted-rdf-mapping-eforms?include_prereleases&sort=semver)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/OP-TED/ted-rdf-mapping-eforms)
![GitHub last commit](https://img.shields.io/github/last-commit/OP-TED/ted-rdf-mapping-eforms)

![GitHub contributors](https://img.shields.io/github/contributors-anon/OP-TED/ted-rdf-mapping-eforms)
![GitHub issues](https://img.shields.io/github/issues/OP-TED/ted-rdf-mapping-eforms)https://github.com/OP-TED/ted-rdf-mapping-eforms/blob/develop/README.md
![GitHub closed issues](https://img.shields.io/github/issues-closed/OP-TED/ted-rdf-mapping-eforms)
![GitHub Repo stars](https://img.shields.io/github/stars/OP-TED/ted-rdf-mapping-eforms?style=social)
![GitHub forks](https://img.shields.io/github/forks/OP-TED/ted-rdf-mapping-eforms?style=social)
![GitHub](https://img.shields.io/github/license/OP-TED/ted-rdf-mapping-eforms)

This repository provides mappings between [eForms SDK](https://github.com/OP-TED/eForms-SDK) representation and [eProcurement Ontology](https://github.com/OP-TED/ePO) representation of [eForms Notices](https://simap.ted.europa.eu/eforms).

The artefacts provided in this repository are provided in the [mappings](./mappings) folder and are organised in packages (https://docs.ted.europa.eu/ODS/latest/mapping_eforms/package_structure.html).

This project is under development. The current scope of this project includes the mapping of:
- all notice subtypes except X01 and X02, according to **eForms SDK versions 1.3 to 1.13**, _including_ the information **encoded in privacy fields** (represented by BT IDs `BT-195`, `BT-196`, `BT-197` and `BT-198`)

The official documentation of this project [is available here](http://docs.ted.europa.eu/ted-rdf-mapping-eforms/index.html) and will be integrated into the [TED Semantic Web Service Project Documentation](https://docs.ted.europa.eu/ODS/latest/).

## Requirements

Users need only to install the following external software tools, libraries
and/or runtimes if developing and testing the RML mapping:

- Java 11+ (tested up to 21)
- RMLMapper-Java==v6.2.2

RMLMapper is currently tied to v6.2.2 because of an
[issue with conditional
instantiation](https://github.com/RMLio/rmlmapper-java/issues/236) (which was later
[fixed](https://github.com/RMLio/rmlmapper-java/blob/144f9b4cb1ca3c7174f9453f28ec626996c19020/CHANGELOG.md)) and incompatibility of our rules with later versions.

## RDF URI Scheme

The eForms RML mappings use the URI scheme `{ns}/{notice}/{concept}/{trailer}`, where:

- `{ns}` is a base namespace, in this case `http://data.europa.eu/a4g/resource/` (prefixed `epd:`)
- `{notice}` is the shared context for all entities in the document, composed of two parts `{notice-id}-{notice-version}`; together with `{ns}` it forms the base `ns-notice` or _notice segment_ of the URI, e.g. `epd:14549263-b47b-4e59-96a1-2d0d13e19343-01`
- `{concept}` is either (i) an ontology fragment label, i.e. the class name or (ii) a source element label, i.e. the XML element name (without any prefix), depending on which provides better context for the resource being represented
- `{trailer}` is either (i) an ID value (if the resource has one) or, in the absence of a usable or reliable ID, (ii) a re-encoded and normalized XPath (to ensure uniqueness within the document), in which case it is preceded by a dollar symbol (`$`) and not slash (`/`) (to facilitate future rewriting or hashing), resulting in the scheme `{ns-notice}/{concept}${reencoded-xpath}`, for e.g. `epd:af0b8395-7498-4d0e-b5eb-3d1a4636eb1a-01/Procedure$_ContractAwardNotice1_TenderingProcess1_ProcessJustification1`
- Root concepts such as `epo:Notice` end at the `{concept}`, and their identifier simply appends `/Identifier`, resulting in the scheme `{ns-notice}/Notice/Identifier` (to avoid redundant repetition of the ID value which is already represented in the notice segment)
- Identifier instances, if not _technical identifiers_ with recognizable ID patterns according to the [eForms specification](https://docs.ted.europa.eu/eforms/latest/schema/identifiers.html) (e.g. `LOT-XXX`), may be preceded by the parent class and followed by the ID value, resulting in the scheme `{ns-notice}/{parent-class}/Identifier/{id-value}`
- In some cases, the `{trailer}` may be an aggregate of multiple values to produce uniqueness, e.g. when the ID is combined with its `schemeName`
- In the case of the externally referenced resources (e.g. a referenced notice or a child entity thereof), the base part is extended with the context of the referred notice, resulting in the scheme `{ns-notice}/Notice/{external-notice-id}/{concept}/{trailer}`

Note: Wherever _URI_ is mentioned, [IRI](https://www.w3.org/2001/Talks/0912-IUC-IRI/paper.html#:~:text=In%20principle%2C%20the%20definition%20of,us%2Dascii%20characters%20in%20URIs) is meant.

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

- `epo:Tender epo:isSubjectToGrouping epo:LotGroup` will _not_ have `epo:isSubmittedForLot epo:Lot` at the same time <https://github.com/OP-TED/ePO/issues/683>

- External resources such as a referenced notices will raise violations if tested standalone (as they will only contain information in the current notice's scope)

- `epo:hasAwardDecisionDate` data type misalignment between eForms and ePO <https://github.com/OP-TED/ted-rdf-mapping-eforms/issues/8>

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
