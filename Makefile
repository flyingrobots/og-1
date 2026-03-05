TEX_MAIN ?= observer_geometry_1
TEX_SOURCE := $(TEX_MAIN).tex
BIB_SOURCE := observer_geometry_1.refs.bib

BUILD_DIR := .build
DIST_DIR := dist
BUILD_PDF := $(BUILD_DIR)/$(TEX_MAIN).pdf
DIST_PDF := $(DIST_DIR)/$(TEX_MAIN).pdf
TXT_OUTPUT := $(DIST_DIR)/$(TEX_MAIN).txt
RAW_TXT := $(BUILD_DIR)/$(TEX_MAIN).raw.txt
CLEAN_TXT := $(BUILD_DIR)/$(TEX_MAIN).clean.txt
FIG_CAPTION_MAP := $(BUILD_DIR)/figure_captions.tsv

LATEX := pdflatex
BIBER := biber
PDFTOTEXT := pdftotext
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

$(TXT_OUTPUT): $(DIST_PDF) $(TEX_SOURCE) | $(BUILD_DIR) $(DIST_DIR)
	@command -v $(PDFTOTEXT) >/dev/null 2>&1 || { echo "Error: $(PDFTOTEXT) is required for 'make txt'."; exit 1; }
	$(PDFTOTEXT) "$(DIST_PDF)" "$(RAW_TXT)"
	awk 'BEGIN { infig=0; idx=0 } \
		/\\begin\{figure/ { infig=1 } \
		infig && /\\caption\{/ { \
			line=$$0; \
			sub(/^.*\\caption\{/, "", line); \
			sub(/\}[[:space:]]*$$/, "", line); \
			gsub(/[[:space:]]+/, " ", line); \
			gsub(/^ +| +$$/, "", line); \
			idx++; \
			printf "%d\t%s\n", idx, line; \
		} \
		/\\end\{figure/ { infig=0 }' "$(TEX_SOURCE)" > "$(FIG_CAPTION_MAP)"
	awk '{ \
		gsub(/\r/, ""); \
		gsub(/\f/, "\n"); \
		n=split($$0, parts, /\n/); \
		for (i=1; i<=n; i++) { \
			line=parts[i]; \
			sub(/^[[:space:]]+/, "", line); \
			sub(/[[:space:]]+$$/, "", line); \
			if (line == "Observer Geometry I: Beyond Distance") continue; \
			if (line ~ /^[0-9]+ of [0-9]+$$/) continue; \
			print line; \
		} \
	}' "$(RAW_TXT)" | awk 'NF == 0 { if (blank) next; blank=1; print ""; next } { blank=0; print }' > "$(CLEAN_TXT)"
	awk -v captions="$(FIG_CAPTION_MAP)" 'BEGIN { \
			while ((getline line < captions) > 0) { \
				sub(/^[^\t]*\t/, "", line); \
				num++; \
				cap[num]=line; \
			} \
			close(captions); \
		} \
		{ \
			if ($$0 ~ /^Figure [0-9]+:/) { \
				numstr=$$0; \
				sub(/^Figure /, "", numstr); \
				sub(/:.*$$/, "", numstr); \
				if (numstr in cap) { \
					print "<FIGURE " numstr ": " cap[numstr] ">"; \
				} else { \
					print "<FIGURE " numstr ">"; \
				} \
				in_caption=1; \
				next; \
			} \
			if (in_caption) { \
				if ($$0 == "") { in_caption=0; print ""; } \
				next; \
			} \
			print $$0; \
		}' "$(CLEAN_TXT)" > "$(TXT_OUTPUT)"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	rm -f $(TEX_MAIN).pdf $(TEX_MAIN).txt
