#!/bin/bash
###################################################################
# Copyright (c) 2014-2019, Marc De Graef Research Group/Carnegie Mellon University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are 
# permitted provided that the following conditions are met:
#
#     - Redistributions of source code must retain the above copyright notice, this list 
#        of conditions and the following disclaimer.
#     - Redistributions in binary form must reproduce the above copyright notice, this 
#        list of conditions and the following disclaimer in the documentation and/or 
#        other materials provided with the distribution.
#     - Neither the names of Marc De Graef, Carnegie Mellon University nor the names 
#        of its contributors may be used to endorse or promote products derived from 
#        this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ###################################################################
#--------------------------------------------------------------------------
# EMsoft:run_docs.sh
#--------------------------------------------------------------------------
#
# PROGRAM: run_docs.sh
#
#> @author Chayoi Zhu, Marc De Graef
# 
#> @note: bash script to generate the pyEMsoft documentation
#
#> @date 09/02/19 MDG 1.0 original 
#--------------------------------------------------------------------------

#=======================
#=======================
# this script assumes a properly functioning anaconda 3 environment 
# along with a correctly installed f90wrap packagie; it is also assumed
# that the .bash_profile set up file has the correct "conda init bash"
# code in it.
#=======================
#=======================

currentdir=`pwd`


# declare the arrays of source files that need to be included in this python wrapper docs build;
declare -a doc_source_files=("index.rst"
	                         "Installation.rst"
	                         "pyEMsoft.rst")

declare -a module_source_files=("pyEMsoftLib.rst"
                             "pyEMsoftHDFLib.rst")

declare -a doc_config_files=("conf.py"
					         "Makefile"
					         "make.bat")

#=======================
# the following folders can probably be set via CMake variables
EMsoft_BUILDfolder=/Users/mdg/Files/EMsoftBuild
DOCfolder=${EMsoft_BUILDfolder}/Documentation
CODEfolder=${EMsoft_BUILDfolder}/pyEMsoft
pyEMsoft_DOCfolder=${DOCfolder}/pyEMsoft
EMsoft_folder=/Users/mdg/Files/EMsoftPublic
pyEMsoft_folder=${EMsoft_folder}/Source/pyEMsoft
DOCsourcefolder=${pyEMsoft_folder}/docs
staticfolder=${pyEMsoft_DOCfolder}/_static
modulefolder=${pyEMsoft_DOCfolder}/Modules

#=======================
# set the working directory to pyEMsoft_BUILDfolder (create it if necessary)
[ ! -d ${pyEMsoft_DOCfolder} ] && mkdir -p ${pyEMsoft_DOCfolder}
[ ! -d ${staticfolder} ] && mkdir -p ${staticfolder}
[ ! -d ${modulefolder} ] && mkdir -p ${modulefolder}
cd ${pyEMsoft_DOCfolder}

#=======================
# copy all relevant source files to the present folder 
echo " run_docs.sh: copying source files into place"
for file in "${doc_source_files[@]}"
do
    cp ${DOCsourcefolder}/${file} .
done
for file in "${module_source_files[@]}"
do
    cp ${DOCsourcefolder}/Modules/${file} ${modulefolder}
done
for file in "${doc_config_files[@]}"
do
	cp ${DOCsourcefolder}/${file} .
done

#=======================
# setting the correct document path
echo " run_docs.sh: setting the correct document path"
sed -i '.bak' "s|DOCPATH|${pyEMsoft_DOCfolder}|" conf.py 
sed -i '.bak' "s|SOURCEPATH|${CODEfolder}|" conf.py 

#=======================
# generate the doc files
echo " run_docs.sh: generating doc html files"
make html

#=======================
# cleaning up
echo " run_docs.sh: cleaning up"
# for file in "${doc_source_files[@]}"
# do
#     rm ${file} .
# done
# for file in "${doc_config_files[@]}"
# do
# 	rm ${file} .
# done

# and return to the starting folder
echo " run_docs.sh: run_docs build completed"
cd ${currentdir}





# that's it