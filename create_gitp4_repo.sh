# Blasr directory name
export BLASR_DIR="blasr"
# Directory to save git-specific files e.g. Makefiles, README and etc
export BLASR_GIT_FILES_DIR="/home/UNIXHOME/yli/blasr/gitp4/git/blasr_git_files"

# Gits for blasr and submodules.
# note that all these repos need to be created in github 
# before anything is pushed to github.
export BLASR_GIT="git@github.com:ylipacbio/refactored_blasr_II.git"
export LIBCPP_GIT="git@github.com:ylipacbio/libcppII.git"
export TOOLS_GIT="git@github.com:ylipacbio/toolsII.git"

# Must-read files for gitp4 blasr.
export CREATE_GITP4_REPO=${BLASR_GIT_FILES_DIR}/create_gitp4_repo.sh
export README=${BLASR_GIT_FILES_DIR}/README.md
export MANUAL=${BLASR_GIT_FILES_DIR}/MANUAL.md

# Makefile under ${BLASR_DIR} for the whole project.
# Note that all Makefiles are kept separately from Makefiles in p4 build.
export BLASR_GIT_COMMON_MK=${BLASR_GIT_FILES_DIR}/blasr_git_common.mk
export BLASR_GITP4_MK=${BLASR_GIT_FILES_DIR}/blasr_gitp4.mk
export BLASR_MK=${BLASR_GIT_FILES_DIR}/blasr.mk
# Makefile under ${BLASR_DIR}/libcpp for compiling libblasr.
export LIBCPP_MK=${BLASR_GIT_FILES_DIR}/blasr_libcpp.mk
export LIBCPP_COMMON_MK=${BLASR_GIT_FILES_DIR}/blasr_libcpp_common.mk
export LIBCPP_ALIGNMENT_MK=${BLASR_GIT_FILES_DIR}/blasr_libcpp_alignment.mk
export LIBCPP_HDF_MK=${BLASR_GIT_FILES_DIR}/blasr_libcpp_hdf.mk
# Makefile under ${BLASR_DIR}/tools for compiling tools other than blasr.
export TOOLS_MK=${BLASR_GIT_FILES_DIR}/blasr_tools.mk

# Push origin to git master by force, overwrite existing repo.
export FORCE_GIT_PUSH="git push -f -u origin master"

# Create ${BLASR_DIR} by cloning from p4 depot.
git p4 clone //depot/software/smrtanalysis/bioinformatics/tools/blasr@all \
    --destination ${BLASR_DIR} \
    -//depot/software/smrtanalysis/bioinformatics/tools/blasr/Makefile

# Enter the project dirctory, add Makefile and add origin
cd ${BLASR_DIR}  || echo "Could not cd ${BLASR_DIR}"
cp ${README} README.md || echo "Could not find ${README}";
git add README.md
cp ${MANUAL} MANUAL.md || echo "Could not find ${MANUAL}";
git add MANUAL.md
cp ${BLASR_MK} Makefile || echo "Could not find ${BLASR_MK}";
git add Makefile
cp ${CREATE_GITP4_REPO} create_gitp4_repo.sh || echo "Could not find ${CREATE_GITP4_REPO}"; 
git add create_gitp4_repo.sh
cp ${BLASR_GIT_COMMON_MK} blasr_git_common.mk || echo "Could not find ${BLASR_GIT_COMMON_MK}"; 
git add blasr_git_common.mk
cp ${BLASR_GITP4_MK} blasr_gitp4.mk || echo "Could not find ${BLASR_GITP4_MK}"
git add blasr_gitp4.mk

git remote add origin ${BLASR_GIT}

# Create ${BLASR_DIR}/libcpp by cloning from p4 depot.
git p4 clone //depot/software/smrtanalysis/bioinformatics/lib/cpp@all \
    --destination libcpp \
    -//depot/software/smrtanalysis/bioinformatics/lib/cpp/ConsensusCore \
    -//depot/software/smrtanalysis/bioinformatics/lib/cpp/common.mk \
    -//depot/software/smrtanalysis/bioinformatics/lib/cpp/alignment/Makefile \
    -//depot/software/smrtanalysis/bioinformatics/lib/cpp/hdf/Makefile

# Create ${BLASR_DIR}/tools by cloning from two p4 depot directories.
git p4 clone //depot/software/smrtanalysis/bioinformatics/staging/pbihdftools@all \
    //depot/software/smrtanalysis/bioinformatics/staging/pbcpputils@all \
    --destination tools \
    -//depot/software/smrtanalysis/bioinformatics/staging/pbihdftools/Makefile \
    -//depot/software/smrtanalysis/bioinformatics/staging/pbcpputils/Makefile

# Enter submodule libcpp, sync rebase from p4, add origin to git,
# add Makefile, and then go back to ${BLASR_DIR}
cd libcpp; git p4 sync; git p4 rebase;
git remote add origin ${LIBCPP_GIT} 
cp ${LIBCPP_MK} Makefile || echo "Could not find ${LIBCPP_MK}";
git add Makefile
cp ${LIBCPP_COMMON_MK} common.mk  || echo "Could not find ${LIBCPP_COMMON_MK}"; 
git add common.mk
cp -p ${LIBCPP_ALIGNMENT_MK} alignment/Makefile  || echo "Could not find ${LIBCPP_ALIGNMENT_MK}"; 
git add alignment/Makefile
cp -p ${LIBCPP_HDF_MK} hdf/Makefile  || echo "Could not find ${LIBCPP_HDF_MK}"; 
git add hdf/Makefile
cd ..;

# Enter submodule tools, sync rebase from p4, add origin to git,
# add Makefile, and then go back to ${BLASR_DIR}
cd tools; git p4 sync; git p4 rebase; 
git remote add origin ${TOOLS_GIT} 
cp ${TOOLS_MK} Makefile || echo "Could not find ${TOOLS_MK}";
git add Makefile
cd ..;

# Add submodules to blasr main project.
git submodule add ${TOOLS_GIT} tools
git submodule add ${LIBCPP_GIT} libcpp

# Force git push submodules and then the main project, finally push all.
cd libcpp; git commit -m 'commit libcpp'; ${FORCE_GIT_PUSH}; cd ..;
cd tools; git commit -m 'commit tools'; ${FORCE_GIT_PUSH}; cd ..;
git commit -m 'commit blasr'; ${FORCE_GIT_PUSH}; 
make p4togit -f blasr_gitp4.mk #Important

