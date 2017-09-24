ROOTDIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: debug resume
.DEFAULT: resume

resume_series := resume
resume_src    := $(resume_series)/*.adoc
resume_out    := $(addprefix $(resume_series),.pdf /index.html)

resumex_series := resumex
resumex_src    := $(resumex_series)/*.adoc
resumex_out    := $(addprefix $(resumex_series),.pdf /index.html)

resume: $(resume_out) $(resumex_out)

debug:
	@echo "======================="
	@echo $(resume_src)
	@echo $(resume_out)
	@echo "======================="
	@echo $(resumex_src)
	@echo $(resumex_out)
	@echo "======================="

resume.pdf: $(resume_src)
	@script/resume-pdf resume

resume/index.html: $(resume_src)
	@script/resume-html resume

resumex.pdf: $(resumex_src)
	@script/resume-pdf resumex

resumex/index.html: $(resumex_src)
	@script/resume-html resumex
