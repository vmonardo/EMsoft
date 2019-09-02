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
# EMsoft:run_pyEMsoftHDF.sh
#--------------------------------------------------------------------------
#
# PROGRAM: run_pyEMsoftHDF.sh
#
#> @author Chayoi Zhu, Marc De Graef
# 
#> @note: bash script to generate python wrappers for the EMsoft HDF library
#
#> @known issues: 
#>   - the HDF_read* routines are currently not wrapped because they contain allocatable array(s) as arguments
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

# declare the arrays of source files that need to be included in this python wrapper build;
# these files are listed in the order that they are make'd in a regular single thread EMsoft build.
declare -a f90_HDF_source_files=("HDFsupport.f90")

declare -a f90_source_files=("typedefs.f90")

declare -a f90_generated_source_files=("stringconstants.f90"
                                       "local.f90")

#=======================
# no changes should need to be made below this line
#=======================

#=======================
# the following folders can probably be set via CMake variables
EMsoft_BUILDfolder=/Users/mdg/Files/EMsoftBuild
pyEMsoft_BUILDfolder=${EMsoft_BUILDfolder}/pyEMsoft
EMsoft_folder=/Users/mdg/Files/EMsoftPublic
pyEMsoft_folder=${EMsoft_folder}/Source/pyEMsoft
CondaLib=/Users/mdg/anaconda3/lib
EMsoft_SDK=/Users/Shared/EMsoft_SDK

#=======================
# derived folders
EMsoftLib=${EMsoft_folder}/Source/EMsoftLib
EMsoftHDFLib=${EMsoft_folder}/Source/EMsoftHDFLib
EMsoftBuildLib=${EMsoft_BUILDfolder}/EMsoft/EMsoftLib
EMsoftBuildHDFLib=${EMsoft_BUILDfolder}/EMsoft/EMsoftHDFLib

#=======================
# set the working directory to pyEMsoft_BUILDfolder (create it if necessary)
currentdir=`pwd`
[ ! -d ${pyEMsoft_BUILDfolder} ] && mkdir -p ${pyEMsoft_BUILDfolder}
[ ! -d ${pyEMsoft_BUILDfolder}/logs ] && mkdir -p ${pyEMsoft_BUILDfolder}/logs
[ ! -d ${pyEMsoft_BUILDfolder}/f90 ] && mkdir -p ${pyEMsoft_BUILDfolder}/f90
cd ${pyEMsoft_BUILDfolder}

#=======================
# copy all relevant source files to the present folder 
echo " run_pyEMsoftHDF.sh: copying source files into place"
for file in "${f90_HDF_source_files[@]}"
do
    cp ${EMsoftHDFLib}/${file} .
done
for file in "${f90_source_files[@]}"
do
	cp ${EMsoftLib}/${file} .
done
for file in "${f90_generated_source_files[@]}"
do
	cp ${EMsoftBuildLib}/${file} .
done 

#=======================
# execute the f90wrap program using all the files just copied
echo " run_pyEMsoftHDF.sh: executing f90wrap"
f90wrap -k ${pyEMsoft_folder}/kind_map -m pyEMsoftHDF ${f90_generated_source_files[*]} ${f90_source_files[*]} ${f90_HDF_source_files[*]} 1>buildHDF.log 2>buildHDF_error.log 

#=======================
# call f2py-f90wrap to build the wrapper library
echo " run_pyEMsoftHDF.sh: executing f2py-f90wrap ... this can take a long time ..."
f2py-f90wrap -c -m _pyEMsoftHDF f90wrap_*.f90 -I${EMsoftBuildLib} \
-I${EMsoftBuildHDFLib} \
-I$EMsoft_SDK/hdf5-1.8.20-Release/include/static \
-I$EMsoft_SDK/CLFortran-0.0.1-Release/include \
-I$EMsoft_SDK/jsonfortran-4.2.1-Release/include \
-I$EMsoft_SDK/fftw-3.3.8/include \
-L$EMsoft_BUILDfolder/Bin \
-L$EMsoft_SDK/jsonfortran-4.2.1-Release/lib \
-L$EMsoft_SDK/CLFortran-0.0.1-Release/lib \
-L$EMsoft_SDK/hdf5-1.8.20-Release/lib \
-L$EMsoft_SDK/fftw-3.3.8/lib \
-L$CondaLib \
-lblas -llapack -lEMsoftLib -lEMsoftHDFLib -ljsonfortran -lhdf5 -lclfortran -lfftw3  1>>buildHDF.log 2>>buildHDF_error.log

#=======================
# clean up all the .f90 files that we no longer need
echo " run_pyEMsoftHDF.sh: cleaning up"
mv f90wrap_*.f90 f90
for file in "${f90_HDF_source_files[@]}"
do
    rm ${file}
done
for file in "${f90_generated_source_files[@]}"
do
    rm ${file}
done
for file in "${f90_source_files[@]}"
do
    rm ${file}
done
mv *.log logs

# and return to the starting folder
echo " run_pyEMsoftHDF.sh: pyEMsoftHDF build completed"
cd ${currentdir}

# that's it
