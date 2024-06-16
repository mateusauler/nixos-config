# 1980-01-01 00:00:00
SOURCE_DATE_EPOCH=315532800

SRCS := $(wildcard *.tex)
OBJS := $(SRCS:%.tex=%.pdf)
INCL := $(include/*.tex)

all: $(OBJS)

%.pdf: $(INCL) %.tex
	latexmk -interaction=nonstopmode -pdflatex -pretex="\pdftrailerid{}" -usepretex -synctex=1 $<

clean:
	rm -f *.aux *.fdb_latexmk *.fls *.log *.synctex.gz *.nav *.out *.snm *.toc *.bbl *.blg

clean-all: clean
	rm -f $(OBJS)

install:
	install -Dt $(INSTALL_DIR) $(OBJS)

.PHONY: all clean clean-all install
