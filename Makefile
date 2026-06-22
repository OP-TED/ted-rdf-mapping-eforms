MAPPINGS_DIR = mappings
OUTPUT_DIR = dist
PKG_PREFIX = package_eforms_sdk
PKG_SUFFIX = _epo5.2
PKG_PREFIX_CN = package_cn
PKG_PREFIX_CAN = package_can
PKG_PREFIX_PIN = package_pin
SDK_NAME = eforms-sdk
DEFAULT_SDK_VERSION = 1.9
DEFAULT_PKG_CM_TYPE = pin
SDK_PROJECT_DIR = ../eForms-SDK
SDK_DATA_NAME_CN = sdk_examples_cn
SDK_DATA_NAME_CAN = sdk_examples_can
SDK_DATA_NAME_PIN = sdk_examples_pin
SAMPLES_NAME_CN = sampling_20231001-20240311
SAMPLES_NAME_CAN = sampling_manual_CAN_202404
SAMPLES_NAME_LANG = sampling_multilingual
SAMPLES_RANDOM_NAME = sampling_random
SAMPLES_ALL_BASENAME = sampling_eforms_all
ROOT_CONCEPTS_GREPFILTER = "_Organization_|_TouchPoint_|_Notice|_ProcurementProcessInformation_|_Lot_|_VehicleInformation_|_ChangeInformation_"
TEST_QUERY_RESULTS_FORMAT = CSV
XLSX_STRDATA = xl/sharedStrings.xml
CM_ID_PREFIX_CN = package_eforms
CM_TITLE_PREFIX_CN = Package EF
CM_ID_PREFIX_CAN = package_eforms
CM_TITLE_PREFIX_CAN = Package EF
CM_ID_PREFIX_PIN = package_eforms_1-9
CM_TITLE_PREFIX_PIN = Package EF1-EF9
CM_VER_STRING_PIN = v1.10
TRIM_DOWN_SHACL = 1
EXCLUDE_SPARQL_VALIDATIONS = 1
EXCLUDE_SELECT_VALIDATIONS = 1
INCLUDE_NEW_SAMPLES = 1
INCLUDE_OLD_SAMPLES = 0
INCLUDE_RANDOM_SAMPLES = 1
EXCLUDE_PROBLEM_SAMPLES = 1
INCLUDE_INVALID_EXAMPLES = 0
EXCLUDE_LARGE_EXAMPLE = 1
REPLACE_CM_METADATA_ID = 0 # TODO: combined CM, per version + analyse substitution logic required
REPLACE_CM_METADATA_ID_EXAMPLES = 0
PACKAGE_EXAMPLES_BY_DEFAULT = 1
REPLACE_CM_ASSERTIONS = 0

CN_TEST_OUTPUT = src/output-cn.ttl
CAN_TEST_OUTPUT = src/output-can.ttl
PIN_TEST_OUTPUT = src/output-pin.ttl
CANONLY_TEST_OUTPUT = src/output-canonly.ttl
VERSIONED_OUTPUT_DIR = src/output-versioned
CANONICAL_EXAMPLE = cn_24_maximal
CN_RML_DIR = src/mappings
CAN_RML_DIR = src/mappings-can
PIN_RML_DIR = src/mappings-pin
TEST_DATA_DIR = test_data
TEST_QUERIES_DIR = test_queries
TEST_SCRIPTS_DIR = test_scripts
POST_SCRIPTS_DIR = src/scripts
TX_DIR = transformation
VALIDATION_DIR_SPARQL_RDF = src/validation/sparql/genericRDF
VALIDATION_DIR_SPARQL_EPO = src/validation/sparql/genericEPO
CM_FILENAME = conceptual_mappings.xlsx
CM_ATTR_FILENAME = conceptual_mappings_all_attributes.xlsx
SHACL_FILE_EPO = ePO_core_shapes.ttl
SHACL_PATH_EPO = validation/shacl/epo/$(SHACL_FILE_EPO)
RELEASE_DIR = ../ted-rdf-mapping-eForms
ALL_CM_DIR = tmp/conceptual_mappings

JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
JENA_TOOLS_ARQ = $(JENA_TOOLS_DIR)/bin/arq
OWLCLI_DIR = $(shell test ! -z ${OWLCLI_HOME} && echo ${OWLCLI_HOME} || echo `pwd`/owlcli)
OWLCLI_BIN = OWLCLI_DIR/owl-cli.jar
OWLCLI_CMD = java -jar ~/.rmlmapper/owl-cli.jar write --indentSize 4
MULTIVER_SCRIPT = scripts/prep-multiver.sh
ANLYS_SCRIPTS_DIR = analysis_scripts

BUILD_PRINT = \e[1;34mSTEP: \e[0m
SDK_DATA_DIR_CN = $(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)
SDK_DATA_DIR_CAN = $(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)
SDK_DATA_DIR_PIN = $(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)
SAMPLES_DIR_CN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_CN)
SAMPLES_DIR_CAN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_CAN)
SAMPLES_DIR_LANG_CN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_LANG)_cn
SAMPLES_DIR_LANG_CAN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_LANG)_can
SAMPLES_RANDOM_DIR = $(TEST_DATA_DIR)/$(SAMPLES_RANDOM_NAME)
SAMPLES_ALL_CN = $(TEST_DATA_DIR)/$(SAMPLES_ALL_BASENAME)_cn
SAMPLES_ALL_CAN = $(TEST_DATA_DIR)/$(SAMPLES_ALL_BASENAME)_can
SAMPLES_ALL_PIN = $(TEST_DATA_DIR)/$(SAMPLES_ALL_BASENAME)_pin
CM_FILE = $(TX_DIR)/$(CM_FILENAME)

VERSIONS := $(shell seq 3 13 | grep -v 4)
# some versions don't currently have systematic and/or random samples
VERSIONS_SAMPLES := $(3 6 7 8 9)
DATA_REPO ?= tmp/sample_data

# we are not copying over CM for now -- leaving it under manual control
package_sync: package_prep package_sync_cn package_sync_can package_sync_pin
package_sync_combined: $(addprefix package_sync_combined_v, $(VERSIONS))
package_sync_cn: $(addprefix package_sync_cn_v, $(VERSIONS))
package_sync_can: $(addprefix package_sync_can_v, $(VERSIONS))
package_sync_pin: $(addprefix package_sync_pin_v, $(VERSIONS))
package_release_cn: $(addprefix package_release_cn_v, $(VERSIONS))
package_release_can: $(addprefix package_release_can_v, $(VERSIONS))
package_release_pin: $(addprefix package_release_pin_v, $(VERSIONS))
reformat_package_cn: $(addprefix reformat_package_cn_v, $(VERSIONS))
reformat_package_can: $(addprefix reformat_package_can_v, $(VERSIONS))
reformat_package_pin: $(addprefix reformat_package_pin_v, $(VERSIONS))
package_cn_minimal: $(addprefix package_cn_minimal_v, $(VERSIONS))
package_can_minimal: $(addprefix package_can_minimal_v, $(VERSIONS))
package_pin_minimal: $(addprefix package_pin_minimal_v, $(VERSIONS))
export_cn_minimal: $(addprefix export_cn_minimal_v, $(VERSIONS))
export_can_minimal: $(addprefix export_can_minimal_v, $(VERSIONS))
export_pin_minimal: $(addprefix export_pin_minimal_v, $(VERSIONS))
package_cn_examples: $(addprefix package_cn_examples_v, $(VERSIONS))
package_can_examples: $(addprefix package_can_examples_v, $(VERSIONS))
package_pin_examples: $(addprefix package_pin_examples_v, $(VERSIONS))
export_cn_examples: $(addprefix export_cn_examples_v, $(VERSIONS))
export_can_examples: $(addprefix export_can_examples_v, $(VERSIONS))
export_pin_examples: $(addprefix export_pin_examples_v, $(VERSIONS))
package_cn_samples: $(addprefix package_cn_samples_v, $(VERSIONS))
package_can_samples: $(addprefix package_can_samples_v, $(VERSIONS))
package_pin_samples: $(addprefix package_pin_samples_v, $(VERSIONS))
export_cn_samples: $(addprefix export_cn_samples_v, $(VERSIONS))
export_can_samples: $(addprefix export_can_samples_v, $(VERSIONS))
export_pin_samples: $(addprefix export_pin_samples_v, $(VERSIONS))
package_cn_maximal: $(addprefix package_cn_maximal_v, $(VERSIONS))
package_can_maximal: $(addprefix package_can_maximal_v, $(VERSIONS))
package_pin_maximal: $(addprefix package_pin_maximal_v, $(VERSIONS))
export_cn_maximal: $(addprefix export_cn_maximal_v, $(VERSIONS))
export_can_maximal: $(addprefix export_can_maximal_v, $(VERSIONS))
export_pin_maximal: $(addprefix export_pin_maximal_v, $(VERSIONS))
package_cn_lang: $(addprefix package_cn_lang_v, $(VERSIONS))
package_can_lang: $(addprefix package_can_lang_v, $(VERSIONS))
package_pin_lang: $(addprefix package_pin_lang_v, $(VERSIONS))
export_cn_lang: $(addprefix export_cn_lang_v, $(VERSIONS))
export_can_lang: $(addprefix export_can_lang_v, $(VERSIONS))
export_pin_lang: $(addprefix export_pin_lang_v, $(VERSIONS))
package_cn_attribs: $(addprefix package_cn_attribs_v, $(VERSIONS))
package_can_attribs: $(addprefix package_can_attribs_v, $(VERSIONS))
package_pin_attribs: $(addprefix package_pin_attribs_v, $(VERSIONS))
export_cn_attribs: $(addprefix export_cn_attribs_v, $(VERSIONS))
export_can_attribs: $(addprefix export_can_attribs_v, $(VERSIONS))
export_pin_attribs: $(addprefix export_pin_attribs_v, $(VERSIONS))
package_release: $(addprefix package_release_v, $(VERSIONS))
reformat_package: $(addprefix reformat_package_v, $(VERSIONS))
package_minimal: $(addprefix package_minimal_v, $(VERSIONS))
export_minimal: $(addprefix export_minimal_v, $(VERSIONS))
package_examples: $(addprefix package_examples_v, $(VERSIONS))
export_examples: $(addprefix export_examples_v, $(VERSIONS))
package_samples: $(addprefix package_samples_v, $(VERSIONS))
export_samples: $(addprefix export_samples_v, $(VERSIONS))
package_maximal: $(addprefix package_maximal_v, $(VERSIONS))
export_maximal: $(addprefix export_maximal_v, $(VERSIONS))
package_lang: $(addprefix package_lang_v, $(VERSIONS))
export_lang: $(addprefix export_lang_v, $(VERSIONS))
package_attribs: $(addprefix package_attribs_v, $(VERSIONS))
export_attribs: $(addprefix export_attribs_v, $(VERSIONS))
test_versioned: $(addprefix test_versioned_v, $(VERSIONS))
test_output_versioned: $(addprefix test_output_versioned_v, $(VERSIONS))

package_prep:
	@ echo "Staging versioned folders"
	@ cd src && bash $(MULTIVER_SCRIPT)

package_sync_combined_v%: package_prep
	@ echo "Syncing combined package v1.$*"
	@ $(eval PKG_DIR := mappings/$(PKG_PREFIX)1.$*$(PKG_SUFFIX))
	@ mkdir -p $(PKG_DIR)/$(TX_DIR)/
	@ rm -rfv $(PKG_DIR)/$(TX_DIR)/mappings*
	@ cp -rv src/mappings $(PKG_DIR)/$(TX_DIR)/
	@ cp -v src/mappings-can/* $(PKG_DIR)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-pin/* $(PKG_DIR)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-common/* $(PKG_DIR)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-unpublished/green/* $(PKG_DIR)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-1.$*/* $(PKG_DIR)/$(TX_DIR)/mappings/
	@ echo "Replacing resources"
	@ rm -rfv $(PKG_DIR)/$(TX_DIR)/resources
	@ cp -rv src/$(TX_DIR)/resources $(PKG_DIR)/$(TX_DIR)/
ifeq ($(REPLACE_CM_ASSERTIONS), 1)
	@ echo "Replacing validations"
	@ rm -rfv $(PKG_DIR)/validation
else
	@ echo "Replacing validations except cm_assertions"
	@ find $(PKG_DIR)/validation -mindepth 2 -type f -not -path "*/sparql/cm_assertions*" -exec rm -fv {} \;
endif
	@ cp -rv src/validation $(PKG_DIR)/
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ find $(PKG_DIR)/validation/sparql -mindepth 1 -depth -type d -not -path "*cm_assertions*" -exec rm -rfv {} \;
endif
# this will have no effect if the above is indeed 1 (true)
ifeq ($(EXCLUDE_SELECT_VALIDATIONS), 1)
	@ echo "Removing SELECT SPARQL validations"
	@ find $(PKG_DIR)/validation/sparql -name "*select.rq" -exec rm -fv {} \;
endif
ifeq ($(PACKAGE_EXAMPLES_BY_DEFAULT), 1)
	@ echo "Including CN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)-1.$*/
	@ echo "Including CAN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/* $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)-1.$*/
	@ echo "Including PIN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)/eforms-sdk-1.$*/* $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)_invalid/eforms-sdk-1.$*/* $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ echo "Including CAN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_CAN)_invalid/eforms-sdk-1.$*/* $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)_invalid-1.$*
	@ echo "Including PIN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)_invalid/eforms-sdk-1.$*/* $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
ifeq ($(EXCLUDE_LARGE_EXAMPLE), 1)
	@ echo "Removing large file cn_24_maximal_100_lots.xml"
	@ find $(PKG_DIR) -name "cn_24_maximal_100_lots.xml" -exec rm -v {} \;
endif
endif
ifeq ($(TRIM_DOWN_SHACL), 1)
	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' $(PKG_DIR)/$(SHACL_PATH_EPO)
	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' $(PKG_DIR)/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' $(PKG_DIR)/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' $(PKG_DIR)/$(SHACL_PATH_EPO)
endif

package_sync_cn_v%:
	@ echo "Syncing CN v1.$*"
	@ $(eval PKG_DIR_CN := mappings/$(PKG_PREFIX_CN)_v1.$*)
	@ mkdir -p $(PKG_DIR_CN)/$(TX_DIR)/
	@ rm -rfv $(PKG_DIR_CN)/$(TX_DIR)/mappings*
	@ cp -rv src/mappings $(PKG_DIR_CN)/$(TX_DIR)/
	@ cp -v src/mappings-common/* $(PKG_DIR_CN)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-unpublished/green/* $(PKG_DIR_CN)/$(TX_DIR)/mappings/	
	@ cp -v src/mappings-1.$*/* $(PKG_DIR_CN)/$(TX_DIR)/mappings/
	@ echo "Removing irrelevant versioned files"
	@ rm -fv $(PKG_DIR_CN)/$(TX_DIR)/mappings/*can_v*
	@ rm -fv $(PKG_DIR_CN)/$(TX_DIR)/mappings/*pin_v*
	@ echo "Replacing resources"
	@ rm -rfv $(PKG_DIR_CN)/$(TX_DIR)/resources
	@ cp -rv src/$(TX_DIR)/resources $(PKG_DIR_CN)/$(TX_DIR)/
ifeq ($(REPLACE_CM_ASSERTIONS), 1)
	@ echo "Replacing validations"
	@ rm -rfv $(PKG_DIR_CN)/validation
else
	@ echo "Replacing validations except cm_assertions"
	@ find $(PKG_DIR_CN)/validation -mindepth 2 -type f -not -path "*/sparql/cm_assertions*" -exec rm -fv {} \;
endif
	@ cp -rv src/validation $(PKG_DIR_CN)/
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ find $(PKG_DIR_CN)/validation/sparql -mindepth 1 -depth -type d -not -path "*cm_assertions*" -exec rm -rfv {} \;
endif
ifeq ($(EXCLUDE_SELECT_VALIDATIONS), 1)
	@ echo "Removing SELECT SPARQL validations"
	@ find $(PKG_DIR_CN)/validation/sparql -name "*select.rq" -exec rm -fv {} \;
endif
ifeq ($(PACKAGE_EXAMPLES_BY_DEFAULT), 1)
	@ echo "Including CN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR_CN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR_CN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR_CN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)_invalid/eforms-sdk-1.$*/* $(PKG_DIR_CN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)_invalid-1.$*
endif
endif
ifeq ($(TRIM_DOWN_SHACL), 1)
	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' $(PKG_DIR_CN)/$(SHACL_PATH_EPO)
	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' $(PKG_DIR_CN)/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' $(PKG_DIR_CN)/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' $(PKG_DIR_CN)/$(SHACL_PATH_EPO)
endif

package_sync_can_v%:
	@ echo "Syncing CAN v1.$*"
	@ $(eval PKG_DIR_CAN := mappings/$(PKG_PREFIX_CAN)_v1.$*)
	@ mkdir -p $(PKG_DIR_CAN)/$(TX_DIR)/
	@ rm -rfv $(PKG_DIR_CAN)/$(TX_DIR)/mappings*
	@ cp -rv src/mappings $(PKG_DIR_CAN)/$(TX_DIR)/
	@ cp -v src/mappings-can/* $(PKG_DIR_CAN)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-common/* $(PKG_DIR_CAN)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-unpublished/green/* $(PKG_DIR_CAN)/$(TX_DIR)/mappings/	
	@ cp -v src/mappings-1.$*/* $(PKG_DIR_CAN)/$(TX_DIR)/mappings/
	@ echo "Removing irrelevant versioned files"
	@ rm -fv $(PKG_DIR_CAN)/$(TX_DIR)/mappings/*pin_v*
	@ echo "Replacing resources"
	@ rm -rfv $(PKG_DIR_CAN)/$(TX_DIR)/resources
	@ cp -rv src/$(TX_DIR)/resources $(PKG_DIR_CAN)/$(TX_DIR)/
ifeq ($(REPLACE_CM_ASSERTIONS), 1)
	@ echo "Replacing validations"
	@ rm -rfv $(PKG_DIR_CAN)/validation
else
	@ echo "Replacing validations except cm_assertions"
	@ find $(PKG_DIR_CAN)/validation -mindepth 1 -not -path "*/sparql/cm_assertions*" -delete
endif
	@ cp -rv src/validation $(PKG_DIR_CAN)/
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ find $(PKG_DIR_CAN)/validation/sparql -mindepth 1 -depth -type d -not -path "*cm_assertions*" -exec rm -rfv {} \;
endif
ifeq ($(EXCLUDE_SELECT_VALIDATIONS), 1)
	@ echo "Removing SELECT SPARQL validations"
	@ find $(PKG_DIR_CAN)/validation/sparql -name "*select.rq" -exec rm -fv {} \;
endif
ifeq ($(PACKAGE_EXAMPLES_BY_DEFAULT), 1)
	@ echo "Including CAN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR_CAN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/* $(PKG_DIR_CAN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CAN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR_CAN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_CAN)_invalid/eforms-sdk-1.$*/* $(PKG_DIR_CAN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)_invalid-1.$*
endif
endif
ifeq ($(TRIM_DOWN_SHACL), 1)
	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' $(PKG_DIR_CAN)/$(SHACL_PATH_EPO)
	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' $(PKG_DIR_CAN)/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' $(PKG_DIR_CAN)/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' $(PKG_DIR_CAN)/$(SHACL_PATH_EPO)
endif

package_sync_pin_v%:
	@ echo "Syncing PIN v1.$*"
	@ $(eval PKG_DIR_PIN := mappings/$(PKG_PREFIX_PIN)_v1.$*)
	@ mkdir -p $(PKG_DIR_PIN)/$(TX_DIR)/
	@ rm -rfv $(PKG_DIR_PIN)/$(TX_DIR)/mappings*
	@ cp -rv src/mappings $(PKG_DIR_PIN)/$(TX_DIR)/
	@ cp -v src/mappings-pin/* $(PKG_DIR_PIN)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-common/* $(PKG_DIR_PIN)/$(TX_DIR)/mappings/
	@ cp -v src/mappings-unpublished/green/* $(PKG_DIR_PIN)/$(TX_DIR)/mappings/	
	@ cp -v src/mappings-1.$*/* $(PKG_DIR_PIN)/$(TX_DIR)/mappings/
	@ echo "Removing irrelevant versioned files"
	@ rm -fv $(PKG_DIR_PIN)/$(TX_DIR)/mappings/*can_v*
	@ echo "Replacing resources"
	@ rm -rfv $(PKG_DIR_PIN)/$(TX_DIR)/resources
	@ cp -rv src/$(TX_DIR)/resources $(PKG_DIR_PIN)/$(TX_DIR)/
ifeq ($(REPLACE_CM_ASSERTIONS), 1)
	@ echo "Replacing validations"
	@ rm -rfv $(PKG_DIR_PIN)/validation
else
	@ echo "Replacing validations except cm_assertions"
	@ find $(PKG_DIR_PIN)/validation -mindepth 1 -not -path "*/sparql/cm_assertions*" -delete
endif
	@ cp -rv src/validation $(PKG_DIR_PIN)/
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ find $(PKG_DIR_PIN)/validation/sparql -mindepth 1 -depth -type d -not -path "*cm_assertions*" -exec rm -rfv {} \;
endif
ifeq ($(EXCLUDE_SELECT_VALIDATIONS), 1)
	@ echo "Removing SELECT SPARQL validations"
	@ find $(PKG_DIR_PIN)/validation/sparql -name "*select.rq" -exec rm -fv {} \;
endif
ifeq ($(PACKAGE_EXAMPLES_BY_DEFAULT), 1)
	@ echo "Including PIN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR_PIN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)/eforms-sdk-1.$*/* $(PKG_DIR_PIN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including PIN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR_PIN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)_invalid/eforms-sdk-1.$*/* $(PKG_DIR_PIN)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
endif
ifeq ($(TRIM_DOWN_SHACL), 1)
	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' $(PKG_DIR_PIN)/$(SHACL_PATH_EPO)
	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' $(PKG_DIR_PIN)/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' $(PKG_DIR_PIN)/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' $(PKG_DIR_PIN)/$(SHACL_PATH_EPO)
endif

# TODO release target for combined packages

package_release_cn_v%: package_prep
	@ $(eval PKG_DIR := $(RELEASE_DIR)/mappings/$(PKG_PREFIX_CN)_v1.$*)
	@ $(eval PKG_EXISTS := $(shell test -d $(PKG_DIR) && echo yes || echo no))
	@ if [ "$(PKG_EXISTS)" = "yes" ]; then \
		echo "Syncing CN v1.$* to $(RELEASE_DIR)"; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/mappings ; \
		cp -rv src/mappings $(PKG_DIR)/$(TX_DIR)/ ; \
		cp -v src/mappings-common/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-unpublished/green/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-1.$*/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/resources ; \
		cp -rv src/$(TX_DIR)/resources $(PKG_DIR)/$(TX_DIR)/ ; \
	  fi
#   @ rm -rv $(PKG_DIR)/validation
#	@ cp -rv src/validation $(PKG_DIR)/
# ifeq ($(TRIM_DOWN_SHACL), 1)
# # TODO: is it better to just create and apply a patch?
# 	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
# 	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' $(PKG_DIR)/$(SHACL_PATH_EPO)
# 	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
# 	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' $(PKG_DIR)/$(SHACL_PATH_EPO)
# 	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' $(PKG_DIR)/$(SHACL_PATH_EPO)
# 	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' $(PKG_DIR)/$(SHACL_PATH_EPO)
# endif

package_release_can_v%: package_prep
	@ $(eval PKG_DIR := $(RELEASE_DIR)/mappings/$(PKG_PREFIX_CAN)_v1.$*)
	@ $(eval PKG_EXISTS := $(shell test -d $(PKG_DIR) && echo yes || echo no))
	@ if [ "$(PKG_EXISTS)" = "yes" ]; then \
		echo "Syncing CAN v1.$* to $(RELEASE_DIR)"; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/mappings ; \
		cp -rv src/mappings $(PKG_DIR)/$(TX_DIR)/ ; \
		cp -v src/mappings-can/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-common/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-unpublished/green/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-1.$*/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/resources ; \
		cp -rv src/$(TX_DIR)/resources $(PKG_DIR)/$(TX_DIR)/ ; \
	  fi

package_release_pin_v%: package_prep
	@ $(eval PKG_DIR := $(RELEASE_DIR)/mappings/$(PKG_PREFIX_PIN)_v1.$*)
	@ $(eval PKG_EXISTS := $(shell test -d $(PKG_DIR) && echo yes || echo no))
	@ if [ "$(PKG_EXISTS)" = "yes" ]; then \
		echo "Syncing PIN v1.$* to $(RELEASE_DIR)"; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/mappings ; \
		cp -rv src/mappings $(PKG_DIR)/$(TX_DIR)/ ; \
		cp -v src/mappings-can/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-common/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-unpublished/green/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-1.$*/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/resources ; \
		cp -rv src/$(TX_DIR)/resources $(PKG_DIR)/$(TX_DIR)/ ; \
	  fi

include packaging-cn.mk
include packaging-can.mk
include packaging-pin.mk
include packaging-all.mk
include testing.mk
include documentation.mk

setup-jena-tools:
	@ echo "Installing Apache Jena CLI tools locally"
	@ curl "https://archive.apache.org/dist/jena/binaries/apache-jena-4.10.0.zip" -o jena.zip
	@ unzip jena.zip
	@ mv apache-jena-4.10.0 jena
	@ echo "Done installing Jena tools, accessible at $(JENA_TOOLS_DIR)/bin"

setup-owl-cli:
	@ echo "Installing OWL CLI tool locally"
	@ mkdir -p owlcli
	@ curl -L "https://github.com/atextor/owl-cli/releases/download/snapshot/owl-cli-snapshot.jar" -o owlcli/owl-cli.jar
	@ echo "Done installing OWL CLI tool, accessible at $(OWLCLI_DIR)/owl-cli.jar"

clean:
	@ rm -fv jena.zip
	@ rm -rfv dist
	@ rm -rfv tmp
	@ rm -rfv src/mappings-1*

# requires jq, python (pandas for reading Excel, thefuzz for XPath str similarity)
# credit https://unix.stackexchange.com/a/249799 by nisetama
# TODO generate the diffs and handle different versions
# recommended to first generate diffs with analyse_versions.sh against a master CM (filtered to CN or CAN)
get_xpath_similarity_stats:
	@ echo "Frequency of Abs XPath similarity scores (no. of field-version range comparisons, score):" && echo && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | uniq -c | sort -nr
	@ echo
	@ echo -n "Min: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s min
	@ echo -n "Max: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s max
	@ echo -n "Avg: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s add/length
	@ echo -n "Med: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s 'sort|if length%2==1 then.[length/2|floor]else[.[length/2-1,length/2]]|add/2 end'

get_xpath_similarity_grouped:
	@ bash $(ANLYS_SCRIPTS_DIR)/xpath_sim_stats_grouped.sh

get_xpath_similarity_table:
	@ bash $(ANLYS_SCRIPTS_DIR)/xpath_sim_stats_table.sh

get_languageMap_reflengths: clean
	@ bash $(ANLYS_SCRIPTS_DIR)/langMap_ref_lengths.sh

get_languageMap_reflength_stats: clean
	@ echo "XPath reference lengths of languageMaps (no. of @languageId occurences, XPath length):"
	@ bash $(ANLYS_SCRIPTS_DIR)/langMap_ref_lengths.sh | awk -F" " '{print $$2}' | sort | uniq -c | sort -nr

list-versioned-pkg-assets:
	@find $(MAPPINGS_DIR) -type d \( -path "*/test_data/*-1.[0-9]*" -o -path "*/output/*-1.[0-9]*" \)

list-versioned-nested:
	@find $(MAPPINGS_DIR) -type d -path "*/test_data/*-1.[0-9]*/*-1.[0-9]*" -o -path "*/output/*-1.[0-9]*/*-1.[0-9]*"

unversion-pkg-assets-dry-run:
	@for dir in $$(find $(MAPPINGS_DIR) -type d \( -path "*/test_data/*-1.[0-9]*" -o -path "*/output/*-1.[0-9]*" \)); do \
		newdir=$$(echo "$$dir" | sed 's/-1\.[0-9]*$$//'); \
		echo "Would rename: $$dir -> $$newdir"; \
	done

unversion-pkg-assets:
	@echo "This will rename all versioned test_data and output directories. Are you sure? [y/N]" && read ans && [ $$ans = y ]
	@for dir in $$(find $(MAPPINGS_DIR) -type d \( -path "*/test_data/*-1.[0-9]*" -o -path "*/output/*-1.[0-9]*" \)); do \
		newdir=$$(echo "$$dir" | sed 's/-1\.[0-9]*$$//'); \
		echo "Renaming: $$dir -> $$newdir"; \
		mkdir -p "$$newdir"; \
		mv "$$dir"/* "$$newdir/" 2>/dev/null || true; \
		rmdir "$$dir"; \
	done

list-unversioned-pkg-assets:
	@find $(MAPPINGS_DIR) -maxdepth 3 -type d \( -path "*/test_data/*" -o -path "*/output/*" \) -not -path "*-1.[0-9]*" -not -path "*/*-1.[0-9]*/*"

version-pkg-assets-dry-run:
	@for dir in $$(find $(MAPPINGS_DIR) -maxdepth 3 -type d \( -path "*/test_data/*" -o -path "*/output/*" \) -not -path "*-1.[0-9]*" -not -path "*/*-1.[0-9]*/*"); do \
		pkg_version=$$(echo "$$dir" | grep -o "package_[^/]*/\|package_[^_]*_v1\." | grep -o "1\.[0-9]*" || echo "$(DEFAULT_SDK_VERSION)"); \
		newdir="$${dir}-$${pkg_version}"; \
		echo "Would rename: $$dir -> $$newdir"; \
	done

version-pkg-assets:
	@echo "This will rename all unversioned test_data and output directories. Are you sure? [y/N]" && read ans && [ $$ans = y ]
	@for dir in $$(find $(MAPPINGS_DIR) -maxdepth 3 -type d \( -path "*/test_data/*" -o -path "*/output/*" \) -not -path "*-1.[0-9]*" -not -path "*/*-1.[0-9]*/*"); do \
		pkg_version=$$(echo "$$dir" | grep -o "package_[^/]*/\|package_[^_]*_v1\." | grep -o "1\.[0-9]*" || echo "$(DEFAULT_SDK_VERSION)"); \
		newdir="$${dir}-$${pkg_version}"; \
		echo "Renaming: $$dir -> $$newdir"; \
		mkdir -p "$$newdir"; \
		mv "$$dir"/* "$$newdir/"; \
		rm -rfv "$$dir"; \
	done

list-pkgs-data-count:
	@ find $(MAPPINGS_DIR)/package*/test_data -type f | cut -d "/" -f 2 | sort | uniq -c | sort -nr

list-pkgs-data-count-cn:
	@ find $(MAPPINGS_DIR)/package*cn*/test_data -type f | cut -d "/" -f 2 | sort | uniq -c | sort -nr

list-pkgs-data-count-can:
	@ find $(MAPPINGS_DIR)/package*can*/test_data -type f | cut -d "/" -f 2 | sort | uniq -c | sort -nr

list-pkgs-data-size:
	@ du -sh $(MAPPINGS_DIR)/package*/test_data | sort -rh

list-pkgs-data-size-cn:
	@ du -sh $(MAPPINGS_DIR)/package*cn*/test_data | sort -rh

list-pkgs-data-size-can:
	@ du -sh $(MAPPINGS_DIR)/package*can*/test_data | sort -rh

list-mismatching-versions:
	@ for i in $$(find $(MAPPINGS_DIR) -type f -path "*/test_data/*"); do \
		version=$$(echo $$i | grep -o "package_[^/]*/\|package_[^_]*_v1\." | grep -o "1\.[0-9]*"); \
		grep eforms-sdk $$i | grep -v $$version && echo $$i; \
	done || true

list-latest-sdk-versions:
	@ cd $(SDK_PROJECT_DIR) && for i in $(VERSIONS); do echo -n "v1.$$i: " && git tag -l | grep 1.$$i | sed 's/-/~/' | sort -V | sed 's/~/-/' | tail -n1; done

copy_versioned_conceptual_mappings:
	@ cd $(ALL_CM_DIR) && for i in $(VERSIONS); do cp -v *1.$$i*xlsx ../../$(MAPPINGS_DIR)/package_cn_v1.$$i/transformation/conceptual_mappings.xlsx; done
	@ cd $(ALL_CM_DIR) && for i in $(VERSIONS); do cp -v *1.$$i*xlsx ../../$(MAPPINGS_DIR)/package_can_v1.$$i/transformation/conceptual_mappings.xlsx; done
	@ cd $(ALL_CM_DIR) && for i in $(VERSIONS); do cp -v *1.$$i*xlsx ../../$(MAPPINGS_DIR)/package_pin_v1.$$i/transformation/conceptual_mappings.xlsx; done

copy_combined_conceptual_mappings:
	@ cd $(ALL_CM_DIR) && for i in $(VERSIONS); do cp -v *1.$$i*xlsx ../../$(MAPPINGS_DIR)/$(PKG_PREFIX)1.$${i}$(PKG_SUFFIX)/transformation/conceptual_mappings.xlsx; done

move_combined_conceptual_mappings:
	@ cd $(MAPPINGS_DIR) && for i in $(VERSIONS); do cp -v package_$(DEFAULT_PKG_CM_TYPE)_v1.$$i/transformation/conceptual_mappings.xlsx $(PKG_PREFIX)1.$${i}$(PKG_SUFFIX)/transformation/; done

# Update sample data by copying XML files from DATA_REPO to sampling_eforms_all_* folders
# Notice types are distributed to the appropriate sampling folder (cn, can, or pin)
update_sample_data:
	@ echo "Updating sample data from $(DATA_REPO)"
	@ test -d "$(DATA_REPO)" || { echo "ERROR: Source directory $(DATA_REPO) does not exist"; exit 1; }
	@ # Process each SDK version folder in source
	@ for sdk_dir in $$(find "$(DATA_REPO)" -maxdepth 1 -type d -name "eforms-sdk-*"); do \
		sdk_version=$$(basename "$$sdk_dir"); \
		echo "Processing $$sdk_version"; \
		\
		# Clean and recreate destination folders for this SDK version \
		rm -rf "$(SAMPLES_ALL_CN)/$$sdk_version"; \
		rm -rf "$(SAMPLES_ALL_CAN)/$$sdk_version"; \
		rm -rf "$(SAMPLES_ALL_PIN)/$$sdk_version"; \
		mkdir -p "$(SAMPLES_ALL_CN)/$$sdk_version"; \
		mkdir -p "$(SAMPLES_ALL_CAN)/$$sdk_version"; \
		mkdir -p "$(SAMPLES_ALL_PIN)/$$sdk_version"; \
		\
		# Copy XML files at SDK version level (sibling to notice-type folders) to all three \
		for xml_file in $$(find "$$sdk_dir" -maxdepth 1 -type f -name "*.xml"); do \
			cp -v "$$xml_file" "$(SAMPLES_ALL_CN)/$$sdk_version/"; \
			cp -v "$$xml_file" "$(SAMPLES_ALL_CAN)/$$sdk_version/"; \
			cp -v "$$xml_file" "$(SAMPLES_ALL_PIN)/$$sdk_version/"; \
		done; \
		\
		# Process each notice-type folder \
		for notice_type_dir in $$(find "$$sdk_dir" -maxdepth 1 -type d ! -path "$$sdk_dir"); do \
			notice_type=$$(basename "$$notice_type_dir"); \
			\
			# Determine destination based on notice type \
			dest=""; \
			\
			# CN: cn-*, pin-cfc-social, pin-cfc-standard, qu-sy \
			if echo "$$notice_type" | grep -qE "^cn-"; then \
				dest="$(SAMPLES_ALL_CN)/$$sdk_version"; \
			elif [ "$$notice_type" = "pin-cfc-social" ] || [ "$$notice_type" = "pin-cfc-standard" ] || [ "$$notice_type" = "qu-sy" ]; then \
				dest="$(SAMPLES_ALL_CN)/$$sdk_version"; \
			\
			# CAN: can-*, compl, veat \
			elif echo "$$notice_type" | grep -qE "^can-"; then \
				dest="$(SAMPLES_ALL_CAN)/$$sdk_version"; \
			elif [ "$$notice_type" = "compl" ] || [ "$$notice_type" = "veat" ]; then \
				dest="$(SAMPLES_ALL_CAN)/$$sdk_version"; \
			\
			# PIN: pin-* (except pin-cfc-social, pin-cfc-standard which go to CN), pmc \
			elif echo "$$notice_type" | grep -qE "^pin-"; then \
				dest="$(SAMPLES_ALL_PIN)/$$sdk_version"; \
			elif [ "$$notice_type" = "pmc" ]; then \
				dest="$(SAMPLES_ALL_PIN)/$$sdk_version"; \
			fi; \
			\
			# op-*-issues or op-*-test folders go to all three \
			if echo "$$notice_type" | grep -qiE "op.*issues|op.*test"; then \
				echo "  Copying $$notice_type to all (op-issues/test pattern)"; \
				cp -rv "$$notice_type_dir" "$(SAMPLES_ALL_CN)/$$sdk_version/"; \
				cp -rv "$$notice_type_dir" "$(SAMPLES_ALL_CAN)/$$sdk_version/"; \
				cp -rv "$$notice_type_dir" "$(SAMPLES_ALL_PIN)/$$sdk_version/"; \
			elif [ -n "$$dest" ]; then \
				echo "  Copying $$notice_type to $$dest"; \
				cp -rv "$$notice_type_dir" "$$dest/"; \
			else \
				echo "  WARNING: Unknown notice type $$notice_type, skipping"; \
			fi; \
		done; \
	done
	@ echo "Sample data update complete"
