TEX_MAIN ?= observer_geometry_1
TEX_SOURCE := $(TEX_MAIN).tex
BIB_SOURCE := observer_geometry_1.refs.bib

BUILD_DIR := .build
DIST_DIR := dist
BUILD_PDF := $(BUILD_DIR)/$(TEX_MAIN).pdf
DIST_PDF := $(DIST_DIR)/$(TEX_MAIN).pdf
TXT_OUTPUT := $(DIST_DIR)/$(TEX_MAIN).txt
TXT_SOURCE := $(BUILD_DIR)/$(TEX_MAIN).txtsource.tex
RAW_TXT := $(BUILD_DIR)/$(TEX_MAIN).raw.txt
CLEAN_TXT := $(BUILD_DIR)/$(TEX_MAIN).clean.txt
DEHYPHEN_TXT := $(BUILD_DIR)/$(TEX_MAIN).dehyphen.txt

LATEX := pdflatex
BIBER := biber
PANDOC := pandoc
PANDOC_FLAGS := --quiet --wrap=none -f latex -t plain
LATEX_FLAGS := -interaction=nonstopmode -file-line-error -output-directory=$(BUILD_DIR)

.PHONY: all pdf txt clean

all: pdf

pdf: $(DIST_PDF)

txt: $(TXT_OUTPUT)

$(DIST_PDF): $(TEX_SOURCE) $(BIB_SOURCE) | $(BUILD_DIR) $(DIST_DIR)
	$(LATEX) $(LATEX_FLAGS) $(TEX_SOURCE)
	$(BIBER) --input-directory $(BUILD_DIR) --output-directory $(BUILD_DIR) $(TEX_MAIN)
	$(LATEX) $(LATEX_FLAGS) $(TEX_SOURCE)
	$(LATEX) $(LATEX_FLAGS) $(TEX_SOURCE)
	cp -f $(BUILD_PDF) $(DIST_PDF)

$(TXT_OUTPUT): $(TEX_SOURCE) | $(BUILD_DIR) $(DIST_DIR)
	@command -v $(PANDOC) >/dev/null 2>&1 || { echo "Error: $(PANDOC) is required for 'make txt'."; exit 1; }
	awk 'BEGIN { infig=0; idx=0; cap="" } \
		{ \
			if (!infig && $$0 ~ /\\begin\{figure/) { infig=1; cap=""; next; } \
			if (infig) { \
				if ($$0 ~ /\\caption\{/) { \
					line=$$0; \
					sub(/^.*\\caption\{/, "", line); \
					sub(/\}[[:space:]]*$$/, "", line); \
					gsub(/[[:space:]]+/, " ", line); \
					gsub(/^ +| +$$/, "", line); \
					cap=line; \
				} \
				if ($$0 ~ /\\end\{figure/) { \
					idx++; \
					if (cap != "") print "<FIGURE " idx ": " cap ">"; \
					else print "<FIGURE " idx ">"; \
					infig=0; \
					next; \
				} \
				next; \
			} \
			print; \
		}' "$(TEX_SOURCE)" > "$(TXT_SOURCE)"
	$(PANDOC) $(PANDOC_FLAGS) "$(TXT_SOURCE)" -o "$(RAW_TXT)"
	awk '{ \
		gsub(/\r/, ""); \
		sub(/^[[:space:]]+/, "", $$0); \
		sub(/[[:space:]]+$$/, "", $$0); \
		if ($$0 == "") { \
			if (blank) next; \
			blank=1; \
			print ""; \
			next; \
		} \
		blank=0; \
		print $$0; \
	}' "$(RAW_TXT)" > "$(CLEAN_TXT)"
	perl -0777 -pe 's/-\n([[:lower:]])/$$1/g' "$(CLEAN_TXT)" > "$(DEHYPHEN_TXT)"
	cp -f "$(DEHYPHEN_TXT)" "$(TXT_OUTPUT)"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	rm -f $(TEX_MAIN).pdf $(TEX_MAIN).txt
