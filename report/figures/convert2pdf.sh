#! /bin/bash
# base for script retrieved from:
# http://blog.nguyenvq.com/blog/2011/02/12/convert-eps-to-pdf-with-the-correct-page-size-or-boundaries/
# http://www.linuxquestions.org/questions/linux-general-1/bash-script-for-converting-ps-to-pdf-371620/

# TODO: Embbed this in the Makefile which generates the paper... Have tried it 
# before, but the stupid Makefile super-specific syntax always gave me a syntax 
# error of some kind :(

for file in $(find . -name "*.eps"); do
    #echo $file
    #echo "${file%%.eps}.pdf"
    ps2pdfwr -dEPSCrop "$file" "${file%%.eps}.pdf"
done

