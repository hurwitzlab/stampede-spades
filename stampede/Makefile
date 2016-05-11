EMAIL = kyclark@email.arizona.edu

clean:
	find . \( -name \*.conf -o -name \*.out -o -name \*.log -o -name \*.params -o -name launcher-\* \) -exec rm {} \;

submit:
	sbatch test-spades.sh

update:
	apps-addupdate -F app.json

upload:
	files-upload -F $(WORK)/spades-3.7.1 kyclark/applications

test:
	sbatch ./test-spades.sh

reilly:
	OUT_DIR=$(WORK)/reilly/spades IN_DIR=$(WORK)/reilly/RNA17_Klugipaussus_RawReads.fa.gz sbatch ./spades-template.sh

