ROOTDIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: resume
.DEFAULT: resume

resume: resume.pdf resume/index.html

resume.pdf: resume/resume.adoc resume/index.adoc
	@script/resume-pdf

resume/index.html: resume/resume.adoc resume/index.adoc
	@script/resume-html
