#-----------------------------------
# Annotation
#-----------------------------------

#' @export
athaliana_feather_annot <- function() 
{
  "annot.feather"
}


#' @export
athaliana_annot <- function(dir = file.path(athaliana_path(), athaliana_dir_rawdata()), 
  ...)
{
  ### inc
  stopifnot(requireNamespace("feather"))

  ### write feather
  path <- file.path(dir, athaliana_feather_annot())
  feather::read_feather(path)
} 


#' @export
athaliana_compute_annot <- function(snp, ids, 
  cores = getOption("cores")) 
{
  ### cores
  if(is.null(cores)) {  
    cores <- 1
  }

  ### parallel
  parallel <- (cores > 1)
  if(parallel) {
    # load required R package doParallel
    stopifnot(requireNamespace("doParallel", quietly = TRUE))
    
    doParallel::registerDoParallel(cores = cores)
  }  
  
  ### subset `snp`
  if(!missing(ids)) {
    snp <- subset(snp, id %in% ids)
  }

  snp <- select(snp, -id)
 
  ### variables
  num_snps <- ncol(snp)
  num_obs <- nrow(snp)
  
  ### compute `mac`
  #mac <- snp %>% summarize_each(funs(. %>% table %>% min)) %>% as.integer
  mac <- laply(snp, function(x) {
    x %>% table %>% min %>% as.integer
  }, .parallel = parallel)
  
  tibble(snp = names(snp), mac = mac, maf = mac / num_obs)
}

#' @export
athaliana_compute_annot_global <- function(snp, phen, ...)
{
  annot <- athaliana_compute_annot(snp, ...)

  ### FRI
  ids_FRI <- with(phen, id[!is.na(FRI)])  
  annot_FRI <- athaliana_compute_annot(snp, ids = ids_FRI, ...)
  
  annot_FRI <- subset(annot_FRI, select = c("snp", "mac", "maf"))
  names(annot_FRI) <- c("snp", "mac_FRI", "maf_FRI")
  
  annot <- left_join(annot, annot_FRI, by = "snp")
  
  ### return
  return(annot)
}



#-----------------------------------
# Genetic Relatedness Matrix (GRM)
#-----------------------------------

#' @export
athaliana_compute_relmat <- function(snp, center = TRUE, scale = TRUE) 
{
  ### prepare the matrix of genotypes: to be centered / scaled
  mat <- as.matrix(snp[-1])
  mat <- scale(mat, center = center, scale = scale)

  ### var
  M <- ncol(mat)
  ids <- snp[["id"]]
  
  ### compute the var-covar matrix
  relmat <- tcrossprod(mat) / M
  
  rownames(relmat) <- ids
  colnames(relmat) <- ids  
  
  return(relmat)
}

#' @export
athaliana_compute_relmat_rrblup <- function(snp) 
{
  ### inc
  stopifnot(requireNamespace("rrBLUP"))

  ### prepare the matrix of genotypes: to be centered / scaled
  mat <- as.matrix(snp[-1])

  ### var
  ids <- snp[["id"]]
  rownames(mat) <- ids
  
  ### compute the var-covar matrix
  relmat <- rrBLUP::A.mat(mat)
  
  rownames(relmat) <- ids
  colnames(relmat) <- ids  
  
  return(relmat)
}

#' @export
athaliana_rds_relmat <- function() 
{
  "relmat.rds"
}

#' @export
athaliana_write_relmat <- function(relmat, 
  dir = file.path(athaliana_path(), athaliana_dir_rawdata()),
  filename = athaliana_rds_relmat())
{
  file <- file.path(dir, filename)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
  saveRDS(relmat, file = file)
}

#' @export
athaliana_relmat <- function(dir = file.path(athaliana_path(), athaliana_dir_rawdata()),
  filename = athaliana_rds_relmat())
{
  file <- file.path(dir, filename)
  
  relmat <- readRDS(file)
  
  return(relmat)
}

