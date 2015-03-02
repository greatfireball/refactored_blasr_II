Blasr installation and maual: 

    $ more Manual.md

To pull this project from git hub to your local system:

    $ git clone git@github.com:ylipacbio/refactored_blasr_II.git --recursive

To sync your code with the latest git code base:

    $ make pullfromgit -f blasr_gitp4.mk

To specify HDF5 headers and lib on your system, 

    $ edit blasr_git_common.mk

    or

    $ export HDF5_ROOT=path_to_your_hdf5

To make 'blasr' only:

    $ make blasr

To compile all tools, including blasr, pls2fasta, loadPusles, sawriter:

    $ make 

To clean all compiled tools and lib:

    $ make clean

To clean blasr and compiled lib:

    $ make clean_blasr

For developers, debug mode:

    $ make debug

For developers, steps to create blasr git repo from scratch.

    $ more create_gitp4_repo.sh

