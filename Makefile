# ICAIF '26 submission build
# Targets: make (build), make check (all submission gates), make clean

PDF   = main.pdf
TEX   = main.tex
ANON_PATTERN = 'Alswaidan|Cade Jin|Varner|Cornell|varnerlab|aa2725|cj383|jdv27|altashly|8f92968|2606\.23492|2603\.10202|CHMM-Model-Repository'

.PHONY: all check pages cites anon boxes clean

all: $(PDF)

$(PDF): $(TEX) sections/*.tex references.bib
	latexmk -pdf -interaction=nonstopmode $(TEX)

check: all pages cites anon boxes
	@echo "ALL CHECKS PASSED"

pages:
	@p=$$(pdfinfo $(PDF) | awk '/^Pages/{print $$2}'); \
	echo "Pages: $$p (limit 8)"; \
	[ $$p -le 8 ] || { echo "FAIL: over 8 pages"; exit 1; }

cites:
	@! grep -E "undefined (citation|reference)" main.log || { echo "FAIL: undefined refs"; exit 1; }
	@checkcites main 2>/dev/null | grep -q "no unused" && echo "checkcites: clean" || checkcites main || true

anon:
	@echo "-- source scan --"; \
	! grep -rEi $(ANON_PATTERN) sections/ $(TEX) references.bib || { echo "FAIL: identifying string in source"; exit 1; }
	@echo "-- pdf text scan --"; \
	! pdftotext $(PDF) - | grep -Ei $(ANON_PATTERN) || { echo "FAIL: identifying string in PDF text"; exit 1; }
	@echo "-- pdf metadata --"; \
	! pdfinfo $(PDF) | grep -Ei 'Author:.*[A-Za-z]' | grep -vEi 'anonymous' || { echo "WARN: check PDF Author field"; exit 1; }
	@echo "anonymization: clean"

boxes:
	@n=$$(grep -c "Overfull" main.log || true); echo "Overfull boxes: $$n"; \
	grep "Overfull" main.log | head -20 || true

clean:
	latexmk -C
	rm -f main.bbl comment.cut
