install.packages(
  c("Rcpp",
    "remotes",
    "R6",
    "reticulate",
    "tensorflow",
    "keras",
    "pixmap",
    "misc3d",
    "tfruns",
    "visreg",
    "zeallot"),
    repos = "http://cran.us.r-project.org"
    )
reticulate::install_miniconda()
tensorflow::install_tensorflow()
reticulate::py_install("h5py")
